package com.library.libhub.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.library.libhub.entity.BorrowTickets;

@Repository
public interface BorrowTicketRepository extends JpaRepository<BorrowTickets, Long> {

    List<BorrowTickets> findByUserId(Long userId);
    List<BorrowTickets> findByStatus(String status);
    
}