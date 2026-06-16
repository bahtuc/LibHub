package com.library.libhub.service.impl;

import java.sql.Timestamp;

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

import jakarta.transaction.Transactional;

@Service
@Transactional
public class AuthServiceImpl
                implements IAuthService {

        @Autowired
        private UserRepository userRepository;

        @Autowired
        private RoleRepository roleRepository;

        @Autowired
        private PasswordEncoder passwordEncoder;

        @Override
        public AuthResponse register(
                        RegisterRequest request) {

                if (userRepository.existsByUsername(
                                request.getUsername())) {

                        throw new RuntimeException(
                                        "Username đã tồn tại");
                }

                if (userRepository.existsByEmail(
                                request.getEmail())) {

                        throw new RuntimeException(
                                        "Email đã tồn tại");
                }

                Roles role = roleRepository
                                .findByRoleName("READER")
                                .orElseThrow();

                Users user = new Users();

                user.setUsername(
                                request.getUsername());

                user.setFullName(
                                request.getFullName());

                user.setEmail(
                                request.getEmail());

                user.setPasswordHash(
                                passwordEncoder.encode(
                                                request.getPassword()));

                user.setRole(role);

                user.setStatus("ACTIVE");

                userRepository.save(user);

                AuthResponse response = new AuthResponse();

                response.setUserId(
                                user.getUserId());

                response.setUsername(
                                user.getUsername());

                response.setFullName(
                                user.getFullName());

                response.setRole(
                                role.getRoleName());

                return response;
        }

        @Override
        public AuthResponse login(
                        LoginRequest request) {

                Users user = userRepository
                                .findByUsername(
                                                request.getUsername())
                                .orElseThrow(() -> new RuntimeException(
                                                "Tài khoản không tồn tại"));

                if (!passwordEncoder.matches(
                                request.getPassword(),
                                user.getPasswordHash())) {

                        throw new RuntimeException(
                                        "Sai mật khẩu");
                }

                if (!"ACTIVE".equals(
                                user.getStatus())) {

                        throw new RuntimeException(
                                        "Tài khoản bị khóa");
                }

                user.setLastLogin(
                                new Timestamp(
                                                System.currentTimeMillis()));

                userRepository.save(user);

                AuthResponse response = new AuthResponse();

                response.setUserId(
                                user.getUserId());

                response.setUsername(
                                user.getUsername());

                response.setFullName(
                                user.getFullName());

                response.setRole(
                                user.getRole()
                                                .getRoleName());

                return response;
        }
}
