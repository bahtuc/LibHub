package com.library.libhub.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import com.library.libhub.entity.Returns;
import org.springframework.stereotype.Repository;
@Repository
public interface ReturnRepository extends JpaRepository<Returns, Long> {

    List<Returns> findByTicketId(Long ticketId);
    List<Returns> findByReceivedBy(Long receivedBy);
    
}
