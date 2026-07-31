package com.library.libhub.controller;

import com.library.libhub.DTO.Request.UpdateAccountStatusRequest;
import com.library.libhub.DTO.Request.UpdateUserRoleRequest;
import com.library.libhub.entity.Users;
import com.library.libhub.DTO.Response.UserSummaryResponse;
import com.library.libhub.service.IUserService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final IUserService userService;

    public UserController(IUserService userService) {
        this.userService = userService;
    }

    @GetMapping
    public ResponseEntity<List<Users>> getAllUsers() {
        return ResponseEntity.ok(userService.getAllUsers());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Optional<Users>> getUserById(@PathVariable long id) {
        return ResponseEntity.ok(userService.getUserById(id));
    }

    @PostMapping
    public ResponseEntity<Users> createUser(@RequestBody Users user) {
        Users createdUser = userService.createUser(user);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdUser);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Users> updateUser(@PathVariable long id, @RequestBody Users user) {
        Users updatedUser = userService.updateUser(id, user);
        return ResponseEntity.ok(updatedUser);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable long id) {
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/username/{username}")
    public ResponseEntity<Optional<Users>> findByUsername(@PathVariable String username) {
        return ResponseEntity.ok(userService.findByUsername(username));
    }

    @GetMapping("/email/{email}")
    public ResponseEntity<Optional<Users>> findByEmail(@PathVariable String email) {
        return ResponseEntity.ok(userService.findByEmail(email));
    }

    @GetMapping("/check-username/{username}")
    public ResponseEntity<Boolean> existsByUsername(@PathVariable String username) {
        return ResponseEntity.ok(userService.existsByUsername(username));
    }

    @PutMapping("/{id}/last-login")
    public ResponseEntity<Void> updateLastLogin(@PathVariable long id) {
        userService.updateLastLogin(id, new Timestamp(System.currentTimeMillis()));
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/borrowers")
    public ResponseEntity<List<UserSummaryResponse>> getActiveBorrowers() {
        return ResponseEntity.ok(userService.getActiveBorrowers());
    }

    @PatchMapping("/{id}/role")
    public ResponseEntity<Users> updateRole(
            @PathVariable long id, @RequestBody UpdateUserRoleRequest request) {
        if (request == null || request.getRoleId() == null) {
            throw new IllegalArgumentException("Thiếu roleId");
        }
        return ResponseEntity.ok(userService.updateRole(id, request.getRoleId()));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<Users> updateStatus(
            @PathVariable long id, @RequestBody UpdateAccountStatusRequest request) {
        if (request == null) throw new IllegalArgumentException("Thiếu trạng thái");
        return ResponseEntity.ok(userService.updateStatus(id, request.getStatus()));
    }
}
