package com.library.libhub.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.library.libhub.entity.BookCopies;

import jakarta.persistence.LockModeType;

@Repository
public interface BookCopyRepository extends JpaRepository<BookCopies, Long> {

    interface BookAvailability {
        Long getBookId();
        Long getTotalCopies();
        Long getAvailableCopies();
    }

    Optional<BookCopies> findByBarcode(String barcode);

    List<BookCopies> findByBookId(Long bookId);

    List<BookCopies> findByBookIdAndStatus(Long bookId, String status);

    @Query("""
            SELECT c.bookId AS bookId,
                   COUNT(c) AS totalCopies,
                   SUM(CASE WHEN LOWER(c.status) = 'available' THEN 1 ELSE 0 END) AS availableCopies
            FROM BookCopies c
            WHERE c.bookId IN :bookIds
            GROUP BY c.bookId
            """)
    List<BookAvailability> summarizeAvailability(@Param("bookIds") List<Long> bookIds);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<BookCopies> findFirstByBookIdAndStatusIgnoreCaseOrderByCopyIdAsc(
            Long bookId,
            String status);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT c FROM BookCopies c WHERE c.copyId = :copyId")
    Optional<BookCopies> findByIdForUpdate(@Param("copyId") Long copyId);

    @Modifying
    @Query("UPDATE BookCopies c SET c.status = :status WHERE c.copyId = :copyId")
    int updateStatus(@Param("copyId") Long copyId, @Param("status") String status);
}
