package com.library.libhub.service.impl;

import java.sql.Timestamp;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.library.libhub.DTO.Request.ChangePasswordRequest;
import com.library.libhub.DTO.Request.LoginRequest;
import com.library.libhub.DTO.Request.RegisterRequest;
import com.library.libhub.DTO.Request.UpdateProfileRequest;
import com.library.libhub.DTO.Response.AuthResponse;
import com.library.libhub.dao.RoleDAO;
import com.library.libhub.dao.UserDAO;
import com.library.libhub.entity.Roles;
import com.library.libhub.entity.Users;
import com.library.libhub.exception.ResourceNotFoundException;
import com.library.libhub.service.IAuthService;
import com.library.libhub.utils.ValidationUtil;

import jakarta.servlet.http.HttpSession;
import jakarta.transaction.Transactional;

@Service
@Transactional
public class AuthServiceImpl implements IAuthService {

    @Autowired
    private UserDAO userDAO;

    @Autowired
    private RoleDAO roleDAO;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private HttpSession session;

    @Override
    public AuthResponse register(RegisterRequest request) {
        validateRegister(request);

        if (userDAO.existsByUsername(request.getUsername())) {
            throw new IllegalArgumentException("Username đã tồn tại");
        }
        if (userDAO.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email đã tồn tại");
        }

        Roles role = roleDAO.findByRoleName("Member")
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Không tìm thấy role Member"));

        Users user = new Users();
        user.setUsername(request.getUsername().trim());
        user.setFullName(request.getFullName().trim());
        user.setEmail(request.getEmail().trim());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setRole(role);
        user.setStatus("ACTIVE");
        user.setCreatedAt(new Timestamp(System.currentTimeMillis()));

        return mapToResponse(userDAO.save(user));
    }

    @Override
    public AuthResponse login(LoginRequest request) {
        validateLogin(request);

        Users user = userDAO.findByUsernameOrEmail(
                        request.getUsernameOrEmail(), request.getUsernameOrEmail())
                .orElseThrow(() -> new IllegalArgumentException(
                        "Tên đăng nhập hoặc mật khẩu không đúng"));

        if (!"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            throw new IllegalArgumentException("Tài khoản bị khóa");
        }
        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new IllegalArgumentException("Tên đăng nhập hoặc mật khẩu không đúng");
        }

        user.setLastLogin(new Timestamp(System.currentTimeMillis()));
        userDAO.save(user);
        session.setAttribute("USER_LOGIN", user);
        session.setAttribute("ROLE",
                user.getRole() != null ? user.getRole().getRoleName() : null);

        return mapToResponse(user);
    }

    @Override
    public AuthResponse getProfile(long userId) {
        return mapToResponse(findUser(userId));
    }

    @Override
    public AuthResponse updateProfile(long userId, UpdateProfileRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("Dữ liệu không hợp lệ");
        }
        if (isBlank(request.getFullName())) {
            throw new IllegalArgumentException("Họ tên không được để trống");
        }

        String email = trimToNull(request.getEmail());
        String phone = trimToNull(request.getPhone());
        if (email != null && !ValidationUtil.isEmail(email)) {
            throw new IllegalArgumentException("Email không hợp lệ");
        }
        if (phone != null && !ValidationUtil.isPhone(phone)) {
            throw new IllegalArgumentException("Số điện thoại không hợp lệ");
        }

        Users user = findUser(userId);
        if (email != null
                && (user.getEmail() == null || !email.equalsIgnoreCase(user.getEmail()))
                && userDAO.existsByEmail(email)) {
            throw new IllegalArgumentException("Email đã tồn tại");
        }

        user.setFullName(request.getFullName().trim());
        user.setEmail(email);
        user.setPhone(phone);
        user.setAddress(trimToNull(request.getAddress()));
        return mapToResponse(userDAO.save(user));
    }

    @Override
    public AuthResponse changePassword(long userId, ChangePasswordRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("Dữ liệu không hợp lệ");
        }
        if (isBlank(request.getOldPassword())) {
            throw new IllegalArgumentException("Mật khẩu cũ không được để trống");
        }
        if (isBlank(request.getNewPassword()) || request.getNewPassword().length() < 6) {
            throw new IllegalArgumentException("Mật khẩu mới phải từ 6 ký tự");
        }
        if (isBlank(request.getConfirmPassword())) {
            throw new IllegalArgumentException("Vui lòng xác nhận mật khẩu mới");
        }
        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            throw new IllegalArgumentException("Mật khẩu xác nhận không khớp");
        }

        Users user = findUser(userId);
        if (!passwordEncoder.matches(request.getOldPassword(), user.getPasswordHash())) {
            throw new IllegalArgumentException("Mật khẩu cũ không đúng");
        }
        if (passwordEncoder.matches(request.getNewPassword(), user.getPasswordHash())) {
            throw new IllegalArgumentException(
                    "Mật khẩu mới không được trùng mật khẩu cũ");
        }

        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        return mapToResponse(userDAO.save(user));
    }

    private void validateRegister(RegisterRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("Dữ liệu không hợp lệ");
        }
        if (isBlank(request.getUsername())) {
            throw new IllegalArgumentException("Username không được để trống");
        }
        if (isBlank(request.getFullName())) {
            throw new IllegalArgumentException("Họ tên không được để trống");
        }
        if (!ValidationUtil.isEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email không hợp lệ");
        }
        if (request.getPassword() == null || request.getPassword().length() < 6) {
            throw new IllegalArgumentException("Mật khẩu phải từ 6 ký tự");
        }
    }

    private void validateLogin(LoginRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("Dữ liệu không hợp lệ");
        }
        if (isBlank(request.getUsernameOrEmail())) {
            throw new IllegalArgumentException("Username/Email không được để trống");
        }
        if (isBlank(request.getPassword())) {
            throw new IllegalArgumentException("Mật khẩu không được để trống");
        }
    }

    private AuthResponse mapToResponse(Users user) {
        AuthResponse response = new AuthResponse();
        response.setUserId(user.getUserId());
        response.setUsername(user.getUsername());
        response.setFullName(user.getFullName());
        response.setRole(user.getRole() != null ? user.getRole().getRoleName() : null);
        response.setEmail(user.getEmail());
        response.setPhone(user.getPhone());
        response.setAddress(user.getAddress());
        response.setAvatar(user.getAvatar());
        response.setStatus(user.getStatus());
        response.setMemberSince(user.getCreatedAt());
        response.setLastLogin(user.getLastLogin());
        return response;
    }

    private Users findUser(long userId) {
        return userDAO.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "User not found with id: " + userId));
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private String trimToNull(String value) {
        return isBlank(value) ? null : value.trim();
    }
}
