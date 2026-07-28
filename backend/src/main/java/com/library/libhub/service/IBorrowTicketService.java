package com.library.libhub.service;

import com.library.libhub.entity.BorrowTickets;
import java.util.List;
import java.util.Optional;

public interface IBorrowTicketService {
    BorrowTickets createBorrowTicket(BorrowTickets borrowTicket);
    BorrowTickets borrowBook(long userId, long bookId);
    Optional<BorrowTickets> getBorrowTicketById(long ticketId);
    List<BorrowTickets> getAllBorrowTickets();
    BorrowTickets updateBorrowTicket(long ticketId, BorrowTickets borrowTicket);
    void deleteBorrowTicket(long ticketId);
    List<BorrowTickets> findByUser(long userId);
    List<BorrowTickets> findByStatus(String status);
}
