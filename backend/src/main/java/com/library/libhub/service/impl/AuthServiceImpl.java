package com.library.libhub.service.impl;

import java.sql.Timestamp;

import com.library.libhub.DTO.Request.ChangePasswordRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.library.libhub.DTO.Request.LoginRequest;
import com.library.libhub.DTO.Request.RegisterRequest;
import com.library.libhub.DTO.Response.AuthResponse;
import com.library.libhub.entity.Roles;
import com.library.libhub.entity.Users;
import com.library.libhub.repository.RoleRepository;
import com.library.libhub.repository.UserRepository;
import com.library.libhub.service.IAuthService;
import com.library.libhub.utils.ValidationUtil;

import jakarta.servlet.http.HttpSession;
import jakarta.transaction.Transactional;

@Service
@Transactional
public class AuthServiceImpl implements IAuthService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    // ================= REGISTER =================
    @Override
    public AuthResponse register(RegisterRequest request) {

        validateRegister(request);

        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Username đã tồn tại");
        }

        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email đã tồn tại");
        }

        Roles role = roleRepository.findByRoleName("Member")
                .orElseThrow(() -> new RuntimeException("Không tìm thấy role Member"));

        Users user = new Users();
        user.setUsername(request.getUsername());
        user.setFullName(request.getFullName());
        user.setEmail(request.getEmail());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setRole(role);
        user.setStatus("ACTIVE");
        user.setCreatedAt(new Timestamp(System.currentTimeMillis()));

        userRepository.save(user);

        return mapToResponse(user);
    }

    // ================= LOGIN =================
    @Autowired
    private HttpSession session;

    @Override
    public AuthResponse login(LoginRequest request) {

        validateLogin(request);

        Users user = userRepository.findByUsernameOrEmail(
                request.getUsernameOrEmail(),
                request.getUsernameOrEmail()).orElseThrow(() -> new RuntimeException("Tài khoản không tồn tại"));

        if (user.getStatus() == null ||
                !"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            throw new RuntimeException("Tài khoản bị khóa");
        }

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new RuntimeException("Sai mật khẩu");
        }

        // 🔥 CREATE SESSION
        session.setAttribute("USER_LOGIN", user);
        session.setAttribute("ROLE", user.getRole().getRoleName());

        user.setLastLogin(new Timestamp(System.currentTimeMillis()));
        userRepository.save(user);

        return mapToResponse(user);
    }

    @Override
    public AuthResponse changePassword(ChangePasswordRequest request) {

        if (isBlank(request.getUsername())) {
            throw new RuntimeException("Username không được để trống");
        }

        if (isBlank(request.getOldPassword())) {
            throw new RuntimeException("Mật khẩu cũ không được để trống");
        }

        if (isBlank(request.getNewPassword()) || request.getNewPassword().length() < 6) {
            throw new RuntimeException("Mật khẩu mới phải từ 6 ký tự");
        }

        Users user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new RuntimeException("Tài khoản không tồn tại"));

        if (!passwordEncoder.matches(request.getOldPassword(), user.getPasswordHash())) {
            throw new RuntimeException("Mật khẩu cũ không đúng");
        }

        if (passwordEncoder.matches(request.getNewPassword(), user.getPasswordHash())) {
            throw new RuntimeException("Mật khẩu mới không được trùng mật khẩu cũ");
        }

        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        return null;
    }

    // ================= VALIDATE REGISTER =================
    private void validateRegister(RegisterRequest request) {

        if (request == null) {
            throw new RuntimeException("Dữ liệu không hợp lệ");
        }

        if (isBlank(request.getUsername())) {
            throw new RuntimeException("Username không được để trống");
        }

        if (isBlank(request.getFullName())) {
            throw new RuntimeException("Họ tên không được để trống");
        }

        if (isBlank(request.getEmail())) {
            throw new RuntimeException("Email không được để trống");
        }

        if (!ValidationUtil.isEmail(request.getEmail())) {
            throw new RuntimeException("Email không hợp lệ");
        }

        if (request.getPassword() == null || request.getPassword().length() < 6) {
            throw new RuntimeException("Mật khẩu phải từ 6 ký tự");
        }
    }

    // ================= VALIDATE LOGIN =================
    private void validateLogin(LoginRequest request) {

        if (request == null) {
            throw new RuntimeException("Dữ liệu không hợp lệ");
        }

        if (isBlank(request.getUsernameOrEmail())) {
            throw new RuntimeException("Username/Email không được để trống");
        }

        if (isBlank(request.getPassword())) {
            throw new RuntimeException("Mật khẩu không được để trống");
        }
    }

    // ================= MAPPING =================
    private AuthResponse mapToResponse(Users user) {

        AuthResponse response = new AuthResponse();
        response.setUserId(user.getUserId());
        response.setUsername(user.getUsername());
        response.setFullName(user.getFullName());
        response.setRole(user.getRole().getRoleName());

        return response;
    }

    // ================= UTIL =================
    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}