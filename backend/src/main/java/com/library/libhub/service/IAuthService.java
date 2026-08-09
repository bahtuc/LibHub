package com.library.libhub.service;

import com.library.libhub.DTO.Request.ChangePasswordRequest;
import com.library.libhub.DTO.Request.LoginRequest;
import com.library.libhub.DTO.Request.RegisterRequest;
import com.library.libhub.DTO.Request.UpdateProfileRequest;
import com.library.libhub.DTO.Response.AuthResponse;

public interface IAuthService {
    AuthResponse register(RegisterRequest request);
    AuthResponse login(LoginRequest request);
    AuthResponse getProfile(long userId);
    AuthResponse updateProfile(long userId, UpdateProfileRequest request);
    AuthResponse changePassword(long userId, ChangePasswordRequest request);
}