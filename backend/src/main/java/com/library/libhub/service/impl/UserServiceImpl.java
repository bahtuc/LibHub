package com.library.libhub.service.impl;

import com.library.libhub.exception.ResourceNotFoundException;

import com.library.libhub.dao.UserDAO;
import com.library.libhub.entity.Users;
import com.library.libhub.service.IUserService;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class UserServiceImpl implements IUserService {

    private final UserDAO userDAO;

    public UserServiceImpl(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    @Override
    public Users createUser(Users user) {
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
        if (user.getUsername() != null) existing.setUsername(user.getUsername());
        if (user.getFullName() != null) existing.setFullName(user.getFullName());
        if (user.getEmail() != null) existing.setEmail(user.getEmail());
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
