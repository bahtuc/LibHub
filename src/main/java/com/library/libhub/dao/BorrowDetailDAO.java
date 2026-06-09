package com.library.libhub.dao;

import com.library.libhub.entity.BorrowDetails;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BorrowDetailDAO extends JpaRepository<BorrowDetails, Long> {

    List<BorrowDetails> findByTicketId(long ticketId);

    List<BorrowDetails> findByCopyId(long copyId);

    List<BorrowDetails> findByBorrowStatus(String borrowStatus);
}