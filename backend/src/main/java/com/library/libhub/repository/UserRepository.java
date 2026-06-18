package com.library.libhub.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.library.libhub.entity.Users;

public interface UserRepository extends JpaRepository<Users, Long> {

    Optional<Users> findByUsername(String username);

    Optional<Users> findByEmail(String email);

    Optional<Users> findByUsernameOrEmail(String username, String email);

    boolean existsByUsername(String username);

    boolean existsByEmail(String email);
}