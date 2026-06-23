package com.library.libhub.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.library.libhub.entity.BookCopies;
import org.springframework.stereotype.Repository;
@Repository
public interface BookCopyRepository extends JpaRepository<BookCopies, Long> {
}