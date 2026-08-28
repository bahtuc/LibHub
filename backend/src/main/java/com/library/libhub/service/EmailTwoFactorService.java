package com.library.libhub.service;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.mail.MailException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import com.library.libhub.DTO.Request.VerifyOtpRequest;
import com.library.libhub.DTO.Response.LoginStartResponse;
import com.library.libhub.entity.Users;

import jakarta.servlet.http.HttpSession;

@Service
public class EmailTwoFactorService {

    private static final String CHALLENGE_ID = "PENDING_2FA_CHALLENGE_ID";
    private static final String USER_ID = "PENDING_2FA_USER_ID";
    private static final String CODE_HASH = "PENDING_2FA_CODE_HASH";
    private static final String EXPIRES_AT = "PENDING_2FA_EXPIRES_AT";
    private static final String ATTEMPTS = "PENDING_2FA_ATTEMPTS";
    private static final String LAST_SENT_AT = "LAST_2FA_SENT_AT";
    private static final String LAST_SENT_USER_ID = "LAST_2FA_SENT_USER_ID";

    private final JavaMailSender mailSender;
    private final PasswordEncoder passwordEncoder;
    private final SecureRandom secureRandom = new SecureRandom();
    private final String senderEmail;
    private final boolean enabled;
    private final long ttlSeconds;
    private final int maxAttempts;
    private final long resendCooldownSeconds;

    public EmailTwoFactorService(
            JavaMailSender mailSender,
            PasswordEncoder passwordEncoder,
            @Value("${spring.mail.username:}") String senderEmail,
            @Value("${library.auth.otp.enabled:true}") boolean enabled,
            @Value("${library.auth.otp.ttl-seconds:300}") long ttlSeconds,
            @Value("${library.auth.otp.max-attempts:5}") int maxAttempts,
            @Value("${library.auth.otp.resend-cooldown-seconds:60}") long resendCooldownSeconds) {
        this.mailSender = mailSender;
        this.passwordEncoder = passwordEncoder;
        this.senderEmail = senderEmail == null ? "" : senderEmail.trim();
        this.enabled = enabled;
        this.ttlSeconds = ttlSeconds;
        this.maxAttempts = maxAttempts;
        this.resendCooldownSeconds = resendCooldownSeconds;
    }

    public boolean isEnabled() {
        return enabled;
    }

    public LoginStartResponse beginChallenge(Users user, HttpSession session) {
        if (user.getEmail() == null || user.getEmail().isBlank()) {
            throw new IllegalArgumentException(
                    "Tài khoản chưa có email để nhận mã xác thực");
        }
        if (senderEmail.isBlank()) {
            throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Máy chủ chưa cấu hình email gửi mã xác thực");
        }

        enforceCooldown(user.getUserId(), session);

        String code = String.format("%06d", secureRandom.nextInt(1_000_000));
        String challengeId = UUID.randomUUID().toString();
        long expiresAt = Instant.now().plusSeconds(ttlSeconds).toEpochMilli();

        session.setAttribute(CHALLENGE_ID, challengeId);
        session.setAttribute(USER_ID, user.getUserId());
        session.setAttribute(CODE_HASH, passwordEncoder.encode(code));
        session.setAttribute(EXPIRES_AT, expiresAt);
        session.setAttribute(ATTEMPTS, 0);

        try {
            mailSender.send(createMessage(user, code));
        } catch (MailException exception) {
            clearPendingChallenge(session);
            throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Không thể gửi mã xác thực. Vui lòng thử lại sau.", exception);
        }

        session.setAttribute(LAST_SENT_AT, System.currentTimeMillis());
        session.setAttribute(LAST_SENT_USER_ID, user.getUserId());

        LoginStartResponse response = new LoginStartResponse();
        response.setRequiresTwoFactor(true);
        response.setChallengeId(challengeId);
        response.setMaskedEmail(maskEmail(user.getEmail()));
        response.setExpiresInSeconds(ttlSeconds);
        return response;
    }

    public long verify(VerifyOtpRequest request, HttpSession session) {
        if (request == null || request.getChallengeId() == null
                || request.getCode() == null || !request.getCode().trim().matches("\\d{6}")) {
            throw new IllegalArgumentException("Mã xác thực phải gồm 6 chữ số");
        }

        String expectedChallengeId = (String) session.getAttribute(CHALLENGE_ID);
        Long userId = asLong(session.getAttribute(USER_ID));
        String codeHash = (String) session.getAttribute(CODE_HASH);
        Long expiresAt = asLong(session.getAttribute(EXPIRES_AT));
        Integer attempts = asInteger(session.getAttribute(ATTEMPTS));

        if (expectedChallengeId == null || userId == null || codeHash == null
                || !expectedChallengeId.equals(request.getChallengeId())) {
            throw new IllegalArgumentException(
                    "Phiên xác thực không hợp lệ. Vui lòng đăng nhập lại.");
        }
        if (expiresAt == null || System.currentTimeMillis() > expiresAt) {
            clearPendingChallenge(session);
            throw new IllegalArgumentException(
                    "Mã xác thực đã hết hạn. Vui lòng đăng nhập lại.");
        }

        int nextAttempt = (attempts == null ? 0 : attempts) + 1;
        if (!passwordEncoder.matches(request.getCode().trim(), codeHash)) {
            if (nextAttempt >= maxAttempts) {
                clearPendingChallenge(session);
                throw new IllegalArgumentException(
                        "Bạn đã nhập sai quá số lần cho phép. Vui lòng đăng nhập lại.");
            }
            session.setAttribute(ATTEMPTS, nextAttempt);
            throw new IllegalArgumentException("Mã xác thực không đúng");
        }

        clearPendingChallenge(session);
        return userId;
    }

    private SimpleMailMessage createMessage(Users user, String code) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(senderEmail);
        message.setTo(user.getEmail().trim());
        message.setSubject("[LibHub] Mã xác thực đăng nhập / Sign-in code");
        message.setText("Xin chào " + displayName(user) + ",\n\n"
                + "Mã xác thực đăng nhập LibHub của bạn là: " + code + "\n"
                + "Mã có hiệu lực trong " + (ttlSeconds / 60) + " phút. "
                + "Không chia sẻ mã này với bất kỳ ai.\n\n"
                + "---\n\nHello " + displayName(user) + ",\n\n"
                + "Your LibHub sign-in code is: " + code + "\n"
                + "This code expires in " + (ttlSeconds / 60) + " minutes. "
                + "Do not share it with anyone.");
        return message;
    }

    private void enforceCooldown(Long userId, HttpSession session) {
        Long lastSentAt = asLong(session.getAttribute(LAST_SENT_AT));
        Long lastUserId = asLong(session.getAttribute(LAST_SENT_USER_ID));
        if (lastSentAt != null && userId.equals(lastUserId)
                && System.currentTimeMillis() - lastSentAt < resendCooldownSeconds * 1000) {
            throw new ResponseStatusException(HttpStatus.TOO_MANY_REQUESTS,
                    "Vui lòng chờ trước khi yêu cầu mã xác thực mới");
        }
    }

    private void clearPendingChallenge(HttpSession session) {
        session.removeAttribute(CHALLENGE_ID);
        session.removeAttribute(USER_ID);
        session.removeAttribute(CODE_HASH);
        session.removeAttribute(EXPIRES_AT);
        session.removeAttribute(ATTEMPTS);
    }

    private String displayName(Users user) {
        return user.getFullName() == null || user.getFullName().isBlank()
                ? user.getUsername() : user.getFullName().trim();
    }

    private String maskEmail(String email) {
        String[] parts = email.trim().split("@", 2);
        if (parts.length != 2) {
            return "***";
        }
        String local = parts[0];
        String visible = local.length() <= 2 ? local.substring(0, 1)
                : local.substring(0, 2);
        return visible + "***@" + parts[1];
    }

    private Long asLong(Object value) {
        return value instanceof Number number ? number.longValue() : null;
    }

    private Integer asInteger(Object value) {
        return value instanceof Number number ? number.intValue() : null;
    }
}
