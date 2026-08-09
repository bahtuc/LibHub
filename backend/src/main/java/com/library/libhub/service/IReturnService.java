package com.library.libhub.service;

import com.library.libhub.DTO.Request.ReturnBookRequest;
import com.library.libhub.entity.Returns;
import java.util.List;
import java.util.Optional;

public interface IReturnService {
    Returns createReturn(Returns returns);
    Returns returnBooks(ReturnBookRequest request, Long currentStaffId);
    Optional<Returns> getReturnById(Long returnId);
    List<Returns> getAllReturns();
    Returns updateReturn(Long returnId, Returns returns);
    void deleteReturn(Long returnId);
    List<Returns> findByTicket(Long ticketId);
    List<Returns> findByReceivedBy(Long receivedBy);
}
