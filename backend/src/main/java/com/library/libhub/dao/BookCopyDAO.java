package com.library.libhub.dao;

import com.library.libhub.entity.BookCopies;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BookCopyDAO extends JpaRepository<BookCopies, Long> {

    Optional<BookCopies> findByBarcode(String barcode);

    List<BookCopies> findByBookId(long bookId);

    List<BookCopies> findByBookIdAndStatus(long bookId, String status);

    @Modifying
    @Query("UPDATE BookCopies c SET c.status = :status WHERE c.copyId = :copyId")
    int updateStatus(@Param("copyId") long copyId, @Param("status") String status);
}