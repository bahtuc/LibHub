package com.library.libhub.service;

import com.library.libhub.entity.Returns;
import java.util.List;
import java.util.Optional;

public interface IReturnService {
    Returns createReturn(Returns returns);
    Optional<Returns> getReturnById(long returnId);
    List<Returns> getAllReturns();
    Returns updateReturn(long returnId, Returns returns);
    void deleteReturn(long returnId);
    List<Returns> findByTicket(long ticketId);
    List<Returns> findByReceivedBy(long receivedBy);
}
