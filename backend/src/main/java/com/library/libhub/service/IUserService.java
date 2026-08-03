package com.library.libhub.service;

import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

import com.library.libhub.DTO.Response.UserSummaryResponse;
import com.library.libhub.entity.Users;

public interface IUserService {
    Users createUser(Users user);
    Optional<Users> getUserById(long userId);
    List<Users> getAllUsers();
    Users updateUser(long userId, Users user);
    void deleteUser(long userId);
    Optional<Users> findByUsername(String username);
    Optional<Users> findByEmail(String email);
    boolean existsByUsername(String username);
    void updateLastLogin(long userId, Timestamp lastLogin);
    Users updateRole(long userId, long roleId);
    Users updateStatus(long userId, String status);
    List<UserSummaryResponse> getActiveBorrowers();
}
