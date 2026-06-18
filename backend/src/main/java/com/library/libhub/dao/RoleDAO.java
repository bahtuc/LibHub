package com.library.libhub.dao;

import com.library.libhub.entity.Roles;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface RoleDAO extends JpaRepository<Roles, Long> {

    Optional<Roles> findByRoleName(String roleName);
}