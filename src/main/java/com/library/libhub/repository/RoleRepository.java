package com.library.libhub.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.library.libhub.entity.Roles;

@Repository
public interface RoleRepository
        extends JpaRepository<Roles, Long> {

    Optional<Roles> findByRoleName(String roleName);
}
