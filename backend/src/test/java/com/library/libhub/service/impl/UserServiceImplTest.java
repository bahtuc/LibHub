package com.library.libhub.service.impl;

import com.library.libhub.DTO.Response.UserSummaryResponse;
import com.library.libhub.entity.Roles;
import com.library.libhub.entity.Users;
import com.library.libhub.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class UserServiceImplTest {
    private final UserRepository userRepo = mock(UserRepository.class);
    private final PasswordEncoder passwordEncoder = mock(PasswordEncoder.class);
    private final UserServiceImpl service = new UserServiceImpl(userRepo, passwordEncoder);

    @Test
    void activeBorrowersReturnsOnlyMemberAccounts() {
        Users member = user(4L, "member01", "Member", "ACTIVE");
        Users librarian = user(2L, "staff01", "Librarian", "ACTIVE");
        when(userRepo.findByStatusIgnoreCase("ACTIVE")).thenReturn(List.of(member, librarian));

        List<UserSummaryResponse> result = service.getActiveBorrowers();

        assertEquals(1, result.size());
        assertEquals(4L, result.getFirst().getUserId());
        assertEquals("member01", result.getFirst().getUsername());
    }

    private Users user(long id, String username, String roleName, String status) {
        Roles role = new Roles();
        role.setRoleName(roleName);
        Users user = new Users();
        user.setUserId(id);
        user.setUsername(username);
        user.setFullName(username);
        user.setRole(role);
        user.setStatus(status);
        return user;
    }
}