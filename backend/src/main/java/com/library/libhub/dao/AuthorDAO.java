package com.library.libhub.dao;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

import com.library.libhub.entity.Authors;

@Repository
public interface AuthorDAO extends JpaRepository<Authors, Long> {

    // Optional<Authors> findByAuthorName(String authorName);
}
