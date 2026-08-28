package com.library.libhub.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import com.library.libhub.DTO.Request.VerifyOtpRequest;
import com.library.libhub.DTO.Response.LoginStartResponse;
import com.library.libhub.entity.Users;

import jakarta.servlet.http.HttpSession;

class EmailTwoFactorServiceTest {

    private JavaMailSender mailSender;
    private HttpSession session;
    private Map<String, Object> sessionValues;
    private EmailTwoFactorService service;

    @BeforeEach
    void setUp() {
        mailSender = mock(JavaMailSender.class);
        session = mock(HttpSession.class);
        sessionValues = new HashMap<>();
        when(session.getAttribute(anyString()))
                .thenAnswer(invocation -> sessionValues.get(invocation.getArgument(0)));
        doAnswer(invocation -> {
            sessionValues.put(invocation.getArgument(0), invocation.getArgument(1));
            return null;
        }).when(session).setAttribute(anyString(), any());
        doAnswer(invocation -> {
            sessionValues.remove(invocation.getArgument(0));
            return null;
        }).when(session).removeAttribute(anyString());

        service = new EmailTwoFactorService(
                mailSender,
                new BCryptPasswordEncoder(),
                "sender@libhub.test",
                true,
                300,
                5,
                60);
    }

    @Test
    void challengeSendsMaskedEmailAndValidCodeCompletesIt() {
        Users user = user();

        LoginStartResponse challenge = service.beginChallenge(user, session);

        assertEquals("tu***@example.com", challenge.getMaskedEmail());
        assertFalse(sessionValues.containsKey("USER_LOGIN"));

        ArgumentCaptor<SimpleMailMessage> messageCaptor =
                ArgumentCaptor.forClass(SimpleMailMessage.class);
        verify(mailSender).send(messageCaptor.capture());
        Matcher codeMatcher = Pattern.compile("\\b\\d{6}\\b")
                .matcher(messageCaptor.getValue().getText());
        codeMatcher.find();

        VerifyOtpRequest request = new VerifyOtpRequest();
        request.setChallengeId(challenge.getChallengeId());
        request.setCode(codeMatcher.group());

        assertEquals(7L, service.verify(request, session));
        assertFalse(sessionValues.containsKey("PENDING_2FA_USER_ID"));
    }

    @Test
    void invalidCodeIsRejected() {
        LoginStartResponse challenge = service.beginChallenge(user(), session);
        ArgumentCaptor<SimpleMailMessage> messageCaptor =
                ArgumentCaptor.forClass(SimpleMailMessage.class);
        verify(mailSender).send(messageCaptor.capture());
        Matcher codeMatcher = Pattern.compile("\\b\\d{6}\\b")
                .matcher(messageCaptor.getValue().getText());
        codeMatcher.find();
        String sentCode = codeMatcher.group();
        VerifyOtpRequest request = new VerifyOtpRequest();
        request.setChallengeId(challenge.getChallengeId());
        request.setCode("000000".equals(sentCode) ? "000001" : "000000");

        assertThrows(IllegalArgumentException.class,
                () -> service.verify(request, session));
    }

    private Users user() {
        Users user = new Users();
        user.setUserId(7L);
        user.setUsername("tung");
        user.setFullName("Tung Tran");
        user.setEmail("tung@example.com");
        return user;
    }
}
