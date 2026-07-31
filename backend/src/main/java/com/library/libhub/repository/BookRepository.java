package com.library.libhub.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.library.libhub.entity.Books;

@Repository
public interface BookRepository extends JpaRepository<Books, Long> {

    Optional<Books> findByIsbn(String isbn);

    List<Books> findByCategoryId(long categoryId);

    List<Books> findByAuthorId(long authorId);

    List<Books> findByTitleContainingIgnoreCase(String keyword);

    Page<Books> findByTitleContainingIgnoreCase(String keyword, Pageable pageable);
}