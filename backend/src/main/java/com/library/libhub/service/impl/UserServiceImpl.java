package com.library.libhub.service.impl;

import com.library.libhub.exception.ResourceNotFoundException;

import com.library.libhub.dao.UserDAO;
import com.library.libhub.entity.Users;
import com.library.libhub.service.IUserService;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import org.springframework.security.crypto.password.PasswordEncoder;
import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class UserServiceImpl implements IUserService {

    private final UserDAO userDAO;
    private final PasswordEncoder passwordEncoder;

    public UserServiceImpl(UserDAO userDAO, PasswordEncoder passwordEncoder) {
        this.userDAO = userDAO;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public Users createUser(Users user) {
        if (user == null || user.getUsername() == null || user.getUsername().isBlank())
            throw new IllegalArgumentException("Username không được để trống");
        if (user.getPasswordHash() == null || user.getPasswordHash().length() < 6)
            throw new IllegalArgumentException("Mật khẩu phải từ 6 ký tự");
        if (userDAO.existsByUsername(user.getUsername()))
            throw new IllegalArgumentException("Username đã tồn tại");
        if (user.getEmail() != null && userDAO.existsByEmail(user.getEmail()))
            throw new IllegalArgumentException("Email đã tồn tại");
        user.setPasswordHash(passwordEncoder.encode(user.getPasswordHash()));
        if (user.getStatus() == null || user.getStatus().isBlank()) user.setStatus("ACTIVE");
        if (user.getCreatedAt() == null) user.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        return userDAO.save(user);
    }

    @Override
    public Optional<Users> getUserById(long userId) {
        return userDAO.findById(userId);
    }

    @Override
    public List<Users> getAllUsers() {
        return userDAO.findAll();
    }

    @Override
    public Users updateUser(long userId, Users user) {
        Users existing = userDAO.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));

        // Chỉ cập nhật field được gửi lên; giữ nguyên passwordHash, createdAt, lastLogin
        if (user.getUsername() != null && !user.getUsername().equals(existing.getUsername())) {
            if (userDAO.existsByUsername(user.getUsername())) throw new IllegalArgumentException("Username đã tồn tại");
            existing.setUsername(user.getUsername());
        }
        if (user.getFullName() != null) existing.setFullName(user.getFullName());
        if (user.getEmail() != null && !user.getEmail().equals(existing.getEmail())) {
            if (userDAO.existsByEmail(user.getEmail())) throw new IllegalArgumentException("Email đã tồn tại");
            existing.setEmail(user.getEmail());
        }
        if (user.getPhone() != null) existing.setPhone(user.getPhone());
        if (user.getAddress() != null) existing.setAddress(user.getAddress());
        if (user.getAvatar() != null) existing.setAvatar(user.getAvatar());
        if (user.getStatus() != null) existing.setStatus(user.getStatus());
        if (user.getRole() != null) existing.setRole(user.getRole());

        return userDAO.save(existing);
    }

    @Override
    public void deleteUser(long userId) {
        if (userDAO.existsById(userId)) {
            userDAO.deleteById(userId);
        } else {
            throw new ResourceNotFoundException("User not found with id: " + userId);
        }
    }

    @Override
    public Optional<Users> findByUsername(String username) {
        return userDAO.findByUsername(username);
    }

    @Override
    public Optional<Users> findByEmail(String email) {
        return userDAO.findByEmail(email);
    }

    @Override
    public boolean existsByUsername(String username) {
        return userDAO.existsByUsername(username);
    }

    @Override
    @Transactional
    public void updateLastLogin(long userId, Timestamp lastLogin) {
        userDAO.updateLastLogin(userId, lastLogin);
    }
}
