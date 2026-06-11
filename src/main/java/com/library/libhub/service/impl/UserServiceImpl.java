package com.library.libhub.service.impl;

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
        if (userDAO.existsById(userId)) {
            user.setUserId(userId);
            return userDAO.save(user);
        }
        throw new RuntimeException("User not found with id: " + userId);
    }

    @Override
    public void deleteUser(long userId) {
        if (userDAO.existsById(userId)) {
            userDAO.deleteById(userId);
        } else {
            throw new RuntimeException("User not found with id: " + userId);
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
