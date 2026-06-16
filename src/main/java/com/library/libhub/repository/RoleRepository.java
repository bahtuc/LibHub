package com.library.libhub.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.library.libhub.entity.Roles;

public interface RoleRepository extends JpaRepository<Roles, Long> {

    Optional<Roles> findByRoleName(String roleName);
}