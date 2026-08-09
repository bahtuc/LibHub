package com.library.libhub.repository;

import com.library.libhub.entity.Returns;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReturnRepository extends JpaRepository<Returns, Long> {

    List<Returns> findByTicketId(Long ticketId);

    List<Returns> findByReceivedBy(Long receivedBy);
}