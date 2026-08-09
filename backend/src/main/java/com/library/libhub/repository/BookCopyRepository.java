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

<<<<<<< HEAD
    List<BookCopies> findByBookIdAndStatus(
            long bookId,
            String status
    );
=======
    List<BookCopies> findByBookIdAndStatus(Long bookId, String status);
>>>>>>> 904b812 (FRONTENDDDD)

    // =========================================================
    // Lấy tất cả bản sao AVAILABLE của nhiều đầu sách
    // =========================================================
    @Query("""
        SELECT c
        FROM BookCopies c
        WHERE c.bookId IN :bookIds
          AND LOWER(c.status) = 'available'
        ORDER BY c.bookId ASC, c.copyId ASC
        """)
    List<BookCopies> findAvailableCopiesByBookIds(
            @Param("bookIds") List<Long> bookIds
    );

    // =========================================================
    // Thống kê số lượng bản sao
    // =========================================================
    @Query("""
        SELECT c.bookId AS bookId,
               COUNT(c) AS totalCopies,
               SUM(
                   CASE
                       WHEN LOWER(c.status) = 'available'
                       THEN 1
                       ELSE 0
                   END
               ) AS availableCopies
        FROM BookCopies c
        WHERE c.bookId IN :bookIds
        GROUP BY c.bookId
        """)
    List<BookAvailability> summarizeAvailability(
            @Param("bookIds") List<Long> bookIds
    );

    // =========================================================
    // Lấy một bản sao AVAILABLE và khóa bản ghi
    // =========================================================
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<BookCopies> findFirstByBookIdAndStatusIgnoreCaseOrderByCopyIdAsc(
<<<<<<< HEAD
            long bookId,
            String status
    );
=======
            Long bookId,
            String status);
>>>>>>> 904b812 (FRONTENDDDD)

    // =========================================================
    // Khóa một bản sao theo ID
    // =========================================================
    @Lock(LockModeType.PESSIMISTIC_WRITE)
<<<<<<< HEAD
    @Query("""
        SELECT c
        FROM BookCopies c
        WHERE c.copyId = :copyId
        """)
    Optional<BookCopies> findByIdForUpdate(
            @Param("copyId") long copyId
    );
=======
    @Query("SELECT c FROM BookCopies c WHERE c.copyId = :copyId")
    Optional<BookCopies> findByIdForUpdate(@Param("copyId") Long copyId);
>>>>>>> 904b812 (FRONTENDDDD)

    // =========================================================
    // Update trạng thái bản sao
    // =========================================================
    @Modifying
<<<<<<< HEAD
    @Query("""
        UPDATE BookCopies c
        SET c.status = :status
        WHERE c.copyId = :copyId
        """)
    int updateStatus(
            @Param("copyId") long copyId,
            @Param("status") String status
    );
}
=======
    @Query("UPDATE BookCopies c SET c.status = :status WHERE c.copyId = :copyId")
    int updateStatus(@Param("copyId") Long copyId, @Param("status") String status);
}
>>>>>>> 904b812 (FRONTENDDDD)
