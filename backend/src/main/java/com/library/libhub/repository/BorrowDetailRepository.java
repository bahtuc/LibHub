package com.library.libhub.repository;

import java.util.List;
import java.util.Optional;

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

    Optional<BorrowDetails> findByTicketIdAndCopyId(long ticketId, long copyId);

    long countByTicketIdAndBorrowStatusNotIgnoreCase(long ticketId, String borrowStatus);

    @Query("""
            SELECT CASE WHEN COUNT(d) > 0 THEN true ELSE false END
            FROM BorrowDetails d, BorrowTickets t, BookCopies c
            WHERE d.ticketId = t.ticketId
              AND d.copyId = c.copyId
              AND t.userId = :userId
              AND c.bookId = :bookId
              AND LOWER(t.status) NOT IN ('returned', 'cancelled')
              AND LOWER(d.borrowStatus) NOT IN ('returned', 'cancelled')
            """)
    boolean existsActiveBorrow(
            @Param("userId") long userId,
            @Param("bookId") long bookId);

    @Query("""
            SELECT b.bookId, b.title, COUNT(d)
            FROM BorrowDetails d, BookCopies c, Books b
            WHERE d.copyId = c.copyId
              AND c.bookId = b.bookId
              AND LOWER(d.borrowStatus) IN ('borrowed', 'overdue')
            GROUP BY b.bookId, b.title
            ORDER BY COUNT(d) DESC
            """)
    List<Object[]> countCurrentlyBorrowedByBook();

    @Query("""
            SELECT b.bookId, b.title, COUNT(d)
            FROM BorrowDetails d, BookCopies c, Books b
            WHERE d.copyId = c.copyId
              AND c.bookId = b.bookId
              AND LOWER(d.borrowStatus) <> 'cancelled'
            GROUP BY b.bookId, b.title
            ORDER BY COUNT(d) DESC
            """)
    List<Object[]> countAllLoansByBook();
}