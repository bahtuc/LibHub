package com.library.libhub.dao;

import com.library.libhub.entity.Authors;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface AuthorDAO extends JpaRepository<Authors, Long> {

    Optional<Authors> findByAuthorName(String authorName);
}
