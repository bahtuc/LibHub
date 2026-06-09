package com.library.libhub.service;

import com.library.libhub.dao.UserDAO;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;

@Service
public class UserService {

    private final UserDAO userDAO;

    public UserService(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    @Transactional
    public void updateLastLogin(long userId, Timestamp lastLogin) {
        userDAO.updateLastLogin(userId, lastLogin);
    }
}