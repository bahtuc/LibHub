package com.library.libhub.repository;

import com.library.libhub.entity.BorrowTickets;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.sql.Date;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.data.jpa.repository.Modifying;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.Lock;
import java.sql.Timestamp;

@Repository
public interface BorrowTicketRepository extends JpaRepository<BorrowTickets, Long> {

    List<BorrowTickets> findByUserId(long userId);

    List<BorrowTickets> findByStatus(String status);

    List<BorrowTickets> findByStatusIgnoreCaseAndCreatedAtBefore(String status, Timestamp createdAt);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT t FROM BorrowTickets t WHERE t.ticketId = :ticketId")
    java.util.Optional<BorrowTickets> findByIdForUpdate(@Param("ticketId") long ticketId);

    @Query("""
            SELECT t FROM BorrowTickets t
            WHERE t.dueDate < :date
              AND LOWER(t.status) NOT IN ('returned', 'cancelled')
            ORDER BY t.dueDate
            """)
    List<BorrowTickets> findOverdue(@Param("date") Date date);

    @Modifying
    @Query("""
            UPDATE BorrowTickets t SET t.status = 'Overdue'
            WHERE t.dueDate < :date AND LOWER(t.status) = 'borrowed'
            """)
    int markOverdue(@Param("date") Date date);
}
