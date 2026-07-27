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
import com.library.libhub.DTO.Response.AuthResponse;
import com.library.libhub.entity.Users;
import com.library.libhub.service.IAuthService;

import jakarta.servlet.http.HttpSession;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final IAuthService authService;

    public AuthController(IAuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
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

    private Users getSessionUser(HttpSession session) {
        return (Users) session.getAttribute("USER_LOGIN");
    }
}
