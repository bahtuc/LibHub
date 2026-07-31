package com.library.libhub.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.library.libhub.entity.BorrowDetails;

@Repository
public interface BorrowDetailRepository extends JpaRepository<BorrowDetails, Long> {

    List<BorrowDetails> findByTicketId(long ticketId);

    List<BorrowDetails> findByCopyId(long copyId);

    List<BorrowDetails> findByBorrowStatus(String borrowStatus);

    @Query("""
            SELECT CASE WHEN COUNT(d) > 0 THEN true ELSE false END
            FROM BorrowDetails d, BorrowTickets t, BookCopies c
            WHERE d.ticketId = t.ticketId
              AND d.copyId = c.copyId
              AND t.userId = :userId
              AND c.bookId = :bookId
              AND LOWER(t.status) <> 'returned'
              AND LOWER(d.borrowStatus) <> 'returned'
            """)
    boolean existsActiveBorrow(
            @Param("userId") long userId,
            @Param("bookId") long bookId);
}
