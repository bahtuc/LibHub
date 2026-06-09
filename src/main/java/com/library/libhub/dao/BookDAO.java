package com.library.libhub.dao;

import com.library.libhub.entity.Books;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BookDAO extends JpaRepository<Books, Long> {

    Optional<Books> findByIsbn(String isbn);

    List<Books> findByCategoryId(long categoryId);

    List<Books> findByAuthorId(long authorId);

    List<Books> findByTitleContainingIgnoreCase(String keyword);
}