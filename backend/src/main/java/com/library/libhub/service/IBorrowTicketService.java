package com.library.libhub.service;

import com.library.libhub.DTO.Request.BorrowTicketRequest;
import com.library.libhub.entity.BorrowTickets;
import java.util.List;
import java.util.Optional;

public interface IBorrowTicketService {
    BorrowTickets createBorrowTicket(BorrowTickets borrowTicket);
    BorrowTickets borrowBook(Long userId, Long bookId);
    BorrowTickets borrowBooks(Long userId, List<Long> bookIds);
    BorrowTickets createBorrowTicketWithCopies(BorrowTicketRequest request);
    BorrowTickets updateStatus(Long ticketId, String status);
    Optional<BorrowTickets> getBorrowTicketById(Long ticketId);
    List<BorrowTickets> getAllBorrowTickets();
    BorrowTickets updateBorrowTicket(Long ticketId, BorrowTickets borrowTicket);
    void deleteBorrowTicket(Long ticketId);
    List<BorrowTickets> findByUser(Long userId);
    List<BorrowTickets> findByStatus(String status);
}
