package com.library.libhub.service;

import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

import com.library.libhub.DTO.Response.UserSummaryResponse;
import com.library.libhub.entity.Users;

public interface IUserService {
    Users createUser(Users user);
    Optional<Users> getUserById(Long userId);
    List<Users> getAllUsers();
    Users updateUser(Long userId, Users user);
    void deleteUser(Long userId);
    Optional<Users> findByUsername(String username);
    Optional<Users> findByEmail(String email);
    boolean existsByUsername(String username);
    void updateLastLogin(Long userId, Timestamp lastLogin);
    Users updateRole(Long userId, Long roleId);
    Users updateStatus(Long userId, String status);
    List<UserSummaryResponse> getActiveBorrowers();
}
