package com.library.libhub.dao;

import com.library.libhub.entity.Returns;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReturnDAO extends JpaRepository<Returns, Long> {

    List<Returns> findByTicketId(long ticketId);

    List<Returns> findByReceivedBy(long receivedBy);
}