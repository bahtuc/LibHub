package com.library.libhub.service.impl;

import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.library.libhub.DTO.Response.UserSummaryResponse;
import com.library.libhub.entity.Users;
import com.library.libhub.exception.ResourceNotFoundException;
import com.library.libhub.repository.UserRepository;
import com.library.libhub.service.IUserService;

import jakarta.transaction.Transactional;

@Service
@Transactional
public class UserServiceImpl implements IUserService {

    private final UserRepository userRepo;
    private final PasswordEncoder passwordEncoder;

    public UserServiceImpl(UserRepository userRepo, PasswordEncoder passwordEncoder) {
        this.userRepo = userRepo;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public Users createUser(Users user) {
        if (user == null || user.getUsername() == null || user.getUsername().isBlank())
            throw new IllegalArgumentException("Username không được để trống");
        if (user.getPasswordHash() == null || user.getPasswordHash().length() < 6)
            throw new IllegalArgumentException("Mật khẩu phải từ 6 ký tự");
        if (userRepo.existsByUsername(user.getUsername()))
            throw new IllegalArgumentException("Username đã tồn tại");
        if (user.getEmail() != null && userRepo.existsByEmail(user.getEmail()))
            throw new IllegalArgumentException("Email đã tồn tại");
        user.setPasswordHash(passwordEncoder.encode(user.getPasswordHash()));
        if (user.getStatus() == null || user.getStatus().isBlank())
            user.setStatus("ACTIVE");
        if (user.getCreatedAt() == null)
            user.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        return userRepo.save(user);
    }

    @Override
    public Optional<Users> getUserById(long userId) {
        return userRepo.findById(userId);
    }

    @Override
    public List<Users> getAllUsers() {
        return userRepo.findAll();
    }

    @Override
    public Users updateUser(long userId, Users user) {
        Users existing = userRepo.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));

        // Chỉ cập nhật field được gửi lên; giữ nguyên passwordHash, createdAt,
        // lastLogin
        if (user.getUsername() != null && !user.getUsername().equals(existing.getUsername())) {
            if (userRepo.existsByUsername(user.getUsername()))
                throw new IllegalArgumentException("Username đã tồn tại");
            existing.setUsername(user.getUsername());
        }
        if (user.getFullName() != null)
            existing.setFullName(user.getFullName());
        if (user.getEmail() != null && !user.getEmail().equals(existing.getEmail())) {
            if (userRepo.existsByEmail(user.getEmail()))
                throw new IllegalArgumentException("Email đã tồn tại");
            existing.setEmail(user.getEmail());
        }
        if (user.getPhone() != null)
            existing.setPhone(user.getPhone());
        if (user.getAddress() != null)
            existing.setAddress(user.getAddress());
        if (user.getAvatar() != null)
            existing.setAvatar(user.getAvatar());
        if (user.getStatus() != null)
            existing.setStatus(user.getStatus());
        if (user.getRole() != null)
            existing.setRole(user.getRole());

        return userRepo.save(existing);
    }

    @Override
    public void deleteUser(long userId) {
        if (userRepo.existsById(userId)) {
            userRepo.deleteById(userId);
        } else {
            throw new ResourceNotFoundException("User not found with id: " + userId);
        }
    }

    @Override
    public Optional<Users> findByUsername(String username) {
        return userRepo.findByUsername(username);
    }

    @Override
    public Optional<Users> findByEmail(String email) {
        return userRepo.findByEmail(email);
    }

    @Override
    public boolean existsByUsername(String username) {
        return userRepo.existsByUsername(username);
    }

    @Override
    @Transactional
    public void updateLastLogin(long userId, Timestamp lastLogin) {
        userRepo.updateLastLogin(userId, lastLogin);
    }

    @Override
    public List<UserSummaryResponse> getActiveBorrowers() {
        return userRepo.findByStatusIgnoreCase("ACTIVE").stream()
                .filter(user -> user.getRole() != null)
                .filter(user -> {
                    String roleName = user.getRole().getRoleName();
                    return "Member".equalsIgnoreCase(roleName) || "User".equalsIgnoreCase(roleName);
                })
                .map(user -> {
                    UserSummaryResponse response = new UserSummaryResponse();
                    response.setUserId(user.getUserId());
                    response.setUsername(user.getUsername());
                    response.setFullName(user.getFullName());
                    response.setRoleName(user.getRole().getRoleName());
                    response.setStatus(user.getStatus());
                    return response;
                })
                .toList();
    }

    @Override
    public Users updateRole(long userId, long roleId) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public Users updateStatus(long userId, String status) {
        throw new UnsupportedOperationException("Not supported yet.");
    }
}