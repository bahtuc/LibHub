package com.library.libhub.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.library.libhub.entity.BookCopies;

@Repository
public interface BookCopyRepository extends JpaRepository<BookCopies, Long> {
}