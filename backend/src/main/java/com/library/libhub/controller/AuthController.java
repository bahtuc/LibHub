package com.library.libhub.controller;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.library.libhub.DTO.Request.LoginRequest;
import com.library.libhub.DTO.Request.RegisterRequest;
import com.library.libhub.DTO.Request.ChangePasswordRequest;
import com.library.libhub.DTO.Response.AuthResponse;

import com.library.libhub.entity.Users;

import com.library.libhub.service.IAuthService;

import jakarta.servlet.http.HttpSession;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private IAuthService authService;

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logout(HttpSession session) {

        session.invalidate(); // xóa toàn bộ session

        return ResponseEntity.ok("Đăng xuất thành công");
    }

    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser(HttpSession session) {

        Users user = (Users) session.getAttribute("USER_LOGIN");

        if (user == null) {
            return ResponseEntity.status(401).body("Chưa đăng nhập");
        }

        // Trả về cùng shape với login() để frontend xử lý nhất quán
        AuthResponse response = new AuthResponse();
        response.setUserId(user.getUserId());
        response.setUsername(user.getUsername());
        response.setFullName(user.getFullName());
        response.setRole(user.getRole() != null ? user.getRole().getRoleName() : null);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(
            @RequestBody ChangePasswordRequest request,
            HttpSession session) {
        Users currentUser = (Users) session.getAttribute("USER_LOGIN");
        if (currentUser == null) {
            return ResponseEntity.status(401).body("Chưa đăng nhập");
        }
        // Never trust a username supplied by the browser for this operation.
        request.setUsername(currentUser.getUsername());
        return ResponseEntity.ok(
                authService.changePassword(request));
    }

}
