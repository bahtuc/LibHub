package com.library.libhub.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.library.libhub.DTO.Request.ChangePasswordRequest;
import com.library.libhub.DTO.Request.LoginRequest;
import com.library.libhub.DTO.Request.RegisterRequest;
import com.library.libhub.DTO.Request.UpdateProfileRequest;
import com.library.libhub.DTO.Request.VerifyOtpRequest;
import com.library.libhub.DTO.Request.UpdateTwoFactorRequest;
import com.library.libhub.DTO.Response.AuthResponse;
import com.library.libhub.DTO.Response.LoginStartResponse;
import com.library.libhub.entity.Users;
import com.library.libhub.service.EmailTwoFactorService;
import com.library.libhub.service.IAuthService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final IAuthService authService;
    private final EmailTwoFactorService twoFactorService;

    public AuthController(IAuthService authService,
            EmailTwoFactorService twoFactorService) {
        this.authService = authService;
        this.twoFactorService = twoFactorService;
    }

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<LoginStartResponse> login(
            @RequestBody LoginRequest request,
            HttpSession session,
            HttpServletRequest servletRequest) {
        Users user = authService.authenticate(request);
        if (twoFactorService.isEnabled() && user.isTwoFactorEnabled()) {
            return ResponseEntity.ok(twoFactorService.beginChallenge(user, session));
        }

        servletRequest.changeSessionId();
        return ResponseEntity.ok(LoginStartResponse.direct(
                authService.completeLogin(user.getUserId(), session)));
    }

    @PostMapping("/2fa/verify")
    public ResponseEntity<AuthResponse> verifyTwoFactor(
            @RequestBody VerifyOtpRequest request,
            HttpSession session,
            HttpServletRequest servletRequest) {
        long userId = twoFactorService.verify(request, session);
        servletRequest.changeSessionId();
        return ResponseEntity.ok(authService.completeLogin(userId, session));
    }

    @PostMapping("/logout")
    public ResponseEntity<String> logout(HttpSession session) {
        session.invalidate();
        return ResponseEntity.ok("Đăng xuất thành công");
    }

    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser(HttpSession session) {
        Users currentUser = getSessionUser(session);
        if (currentUser == null) {
            return ResponseEntity.status(401).body("Chưa đăng nhập");
        }
        return ResponseEntity.ok(authService.getProfile(currentUser.getUserId()));
    }

    @PutMapping("/profile")
    public ResponseEntity<?> updateProfile(
            @RequestBody UpdateProfileRequest request,
            HttpSession session) {
        Users currentUser = getSessionUser(session);
        if (currentUser == null) {
            return ResponseEntity.status(401).body("Chưa đăng nhập");
        }

        AuthResponse response =
                authService.updateProfile(currentUser.getUserId(), request);
        currentUser.setFullName(response.getFullName());
        currentUser.setEmail(response.getEmail());
        currentUser.setPhone(response.getPhone());
        currentUser.setAddress(response.getAddress());
        session.setAttribute("USER_LOGIN", currentUser);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(
            @RequestBody ChangePasswordRequest request,
            HttpSession session) {
        Users currentUser = getSessionUser(session);
        if (currentUser == null) {
            return ResponseEntity.status(401).body("Chưa đăng nhập");
        }
        return ResponseEntity.ok(
                authService.changePassword(currentUser.getUserId(), request));
    }

    @PutMapping("/two-factor")
    public ResponseEntity<?> updateTwoFactor(
            @RequestBody UpdateTwoFactorRequest request,
            HttpSession session) {
        Users currentUser = getSessionUser(session);
        if (currentUser == null) {
            return ResponseEntity.status(401).body("Chưa đăng nhập");
        }
        AuthResponse response = authService.updateTwoFactor(
                currentUser.getUserId(), request == null ? null : request.getEnabled());
        currentUser.setTwoFactorEnabled(response.isTwoFactorEnabled());
        session.setAttribute("USER_LOGIN", currentUser);
        return ResponseEntity.ok(response);
    }

    private Users getSessionUser(HttpSession session) {
        return (Users) session.getAttribute("USER_LOGIN");
    }
}
