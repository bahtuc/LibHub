package com.library.libhub.repository;

import com.library.libhub.entity.Fines;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

@Repository
public interface FineRepository extends JpaRepository<Fines, Long> {

    List<Fines> findByReturnDetailId(long returnDetailId);

    List<Fines> findByPaidStatus(String paidStatus);

    boolean existsByReturnDetailId(long returnDetailId);

    @Query("""
            SELECT f.paidStatus, COUNT(f), COALESCE(SUM(f.amount), 0)
            FROM Fines f
            GROUP BY f.paidStatus
            ORDER BY f.paidStatus
            """)
    List<Object[]> summarizeByPaidStatus();

    @Query("""
            SELECT f
            FROM Fines f, ReturnDetails rd, Returns r, BorrowTickets t
            WHERE f.returnDetailId = rd.returnDetailId
              AND rd.returnId = r.returnId
              AND r.ticketId = t.ticketId
              AND t.userId = :userId
            ORDER BY f.createdAt DESC
            """)
    List<Fines> findByUserId(@Param("userId") long userId);
}