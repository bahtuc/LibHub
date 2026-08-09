package com.library.libhub.repository;

import com.library.libhub.entity.BorrowTickets;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.sql.Date;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.data.jpa.repository.Modifying;

@Repository
public interface BorrowTicketRepository extends JpaRepository<BorrowTickets, Long> {

    List<BorrowTickets> findByUserId(Long userId);

    List<BorrowTickets> findByStatus(String status);

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
