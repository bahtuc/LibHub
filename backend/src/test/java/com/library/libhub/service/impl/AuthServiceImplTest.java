package com.library.libhub.service.impl;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.sql.Timestamp;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.library.libhub.DTO.Request.ChangePasswordRequest;
import com.library.libhub.DTO.Request.UpdateProfileRequest;
import com.library.libhub.DTO.Response.AuthResponse;
import com.library.libhub.entity.Roles;
import com.library.libhub.entity.Users;
import com.library.libhub.repository.*;

import jakarta.servlet.http.HttpSession;

@ExtendWith(MockitoExtension.class)
class AuthServiceImplTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private RoleRepository roleRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private HttpSession session;

    @InjectMocks
    private AuthServiceImpl authService;

    private Users user;

    @BeforeEach
    void setUp() {
        Roles role = new Roles();
        role.setRoleName("Member");

        user = new Users();
        user.setUserId(7L);
        user.setUsername("member");
        user.setPasswordHash("old-hash");
        user.setFullName("Old Name");
        user.setEmail("old@example.com");
        user.setRole(role);
        user.setStatus("ACTIVE");
        user.setCreatedAt(Timestamp.valueOf("2026-01-01 10:00:00"));
    }

    @Test
    void getProfileReturnsAllAccountFields() {
        user.setPhone("0912345678");
        user.setAddress("Ho Chi Minh City");
        when(userRepository.findById(7L)).thenReturn(Optional.of(user));

        AuthResponse response = authService.getProfile(7L);

        assertEquals("member", response.getUsername());
        assertEquals("old@example.com", response.getEmail());
        assertEquals("0912345678", response.getPhone());
        assertEquals("Ho Chi Minh City", response.getAddress());
        assertEquals("Member", response.getRole());
        assertEquals(user.getCreatedAt(), response.getMemberSince());
    }

    @Test
    void updateProfileOnlyChangesSelfServiceFields() {
        UpdateProfileRequest request = new UpdateProfileRequest();
        request.setFullName(" New Name ");
        request.setEmail("new@example.com");
        request.setPhone("0912345678");
        request.setAddress(" District 1 ");

        when(userRepository.findById(7L)).thenReturn(Optional.of(user));
        when(userRepository.existsByEmail("new@example.com")).thenReturn(false);
        when(userRepository.save(user)).thenReturn(user);

        AuthResponse response = authService.updateProfile(7L, request);

        assertEquals("New Name", response.getFullName());
        assertEquals("new@example.com", response.getEmail());
        assertEquals("0912345678", response.getPhone());
        assertEquals("District 1", response.getAddress());
        assertEquals("member", response.getUsername());
    }

    @Test
    void changePasswordUsesAuthenticatedUserIdAndChecksConfirmation() {
        ChangePasswordRequest request = new ChangePasswordRequest();
        request.setOldPassword("old-password");
        request.setNewPassword("new-password");
        request.setConfirmPassword("new-password");

        when(userRepository.findById(7L)).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("old-password", "old-hash")).thenReturn(true);
        when(passwordEncoder.matches("new-password", "old-hash")).thenReturn(false);
        when(passwordEncoder.encode("new-password")).thenReturn("new-hash");
        when(userRepository.save(user)).thenReturn(user);

        authService.changePassword(7L, request);

        assertEquals("new-hash", user.getPasswordHash());
        verify(userRepository, never()).findByUsername(any());
        verify(userRepository).findById(7L);
    }

    @Test
    void changePasswordRejectsMismatchedConfirmation() {
        ChangePasswordRequest request = new ChangePasswordRequest();
        request.setOldPassword("old-password");
        request.setNewPassword("new-password");
        request.setConfirmPassword("different-password");

        assertThrows(IllegalArgumentException.class,
                () -> authService.changePassword(7L, request));
        verify(userRepository, never()).save(any());
    }
}
