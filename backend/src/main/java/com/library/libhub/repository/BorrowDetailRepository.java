package com.library.libhub.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.library.libhub.entity.BorrowDetails;

@Repository
public interface BorrowDetailRepository extends JpaRepository<BorrowDetails, Long> {

    List<BorrowDetails> findByTicketId(Long ticketId);
    
}