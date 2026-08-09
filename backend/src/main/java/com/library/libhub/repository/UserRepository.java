package com.library.libhub.repository;

import java.sql.Timestamp;
import java.util.Optional;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.library.libhub.entity.Users;

import jakarta.persistence.LockModeType;

@Repository
public interface UserRepository extends JpaRepository<Users, Long> {

    Optional<Users> findByUsername(String username);

    Optional<Users> findByEmail(String email);

    Optional<Users> findByUsernameOrEmail(String username, String email);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT u FROM Users u WHERE u.userId = :userId")
    Optional<Users> findByIdForUpdate(@Param("userId") long userId);

    boolean existsByUsername(String username);

    boolean existsByEmail(String email);

    List<Users> findByStatusIgnoreCase(String status);

    @Modifying
    @Query("UPDATE Users u SET u.lastLogin = :lastLogin WHERE u.userId = :userId")
    void updateLastLogin(@Param("userId") long userId, @Param("lastLogin") Timestamp lastLogin);
}