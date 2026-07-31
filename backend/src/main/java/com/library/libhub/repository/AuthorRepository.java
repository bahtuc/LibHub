package com.library.libhub.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.library.libhub.entity.Authors;

@Repository
public interface AuthorRepository extends JpaRepository<Authors, Long> {

    Optional<Authors> findByAuthorName(String authorName);
}
