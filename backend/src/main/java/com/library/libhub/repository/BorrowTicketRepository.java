package com.library.libhub.repository;

import com.library.libhub.entity.BorrowTickets;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BorrowTicketRepository extends JpaRepository<BorrowTickets, Long> {

    List<BorrowTickets> findByUserId(long userId);

    List<BorrowTickets> findByStatus(String status);
}