package com.library.libhub.service;

import com.library.libhub.DTO.Request.ChangePasswordRequest;
import com.library.libhub.DTO.Request.LoginRequest;
import com.library.libhub.DTO.Request.RegisterRequest;
import com.library.libhub.DTO.Request.UpdateProfileRequest;
import com.library.libhub.DTO.Response.AuthResponse;
import com.library.libhub.entity.Users;

import jakarta.servlet.http.HttpSession;

public interface IAuthService {
    AuthResponse register(RegisterRequest request);
    AuthResponse login(LoginRequest request);
    Users authenticate(LoginRequest request);
    AuthResponse completeLogin(long userId, HttpSession session);
    AuthResponse getProfile(long userId);
    AuthResponse updateProfile(long userId, UpdateProfileRequest request);
    AuthResponse changePassword(long userId, ChangePasswordRequest request);
    AuthResponse updateTwoFactor(long userId, Boolean enabled);
}
