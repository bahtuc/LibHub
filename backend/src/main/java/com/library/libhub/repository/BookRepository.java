package com.library.libhub.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import com.library.libhub.entity.Books;

public interface BookRepository extends JpaRepository<Books, Long> {

    Page<Books> findByTitleContainingIgnoreCase(
            String keyword,
            Pageable pageable);

}