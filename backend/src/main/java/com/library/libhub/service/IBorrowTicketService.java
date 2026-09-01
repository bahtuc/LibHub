package com.library.libhub.service;

import com.library.libhub.DTO.Request.BorrowTicketRequest;
import com.library.libhub.entity.BorrowTickets;
import java.util.List;
import java.util.Optional;

public interface IBorrowTicketService {
    BorrowTickets createBorrowTicket(BorrowTickets borrowTicket);
    BorrowTickets borrowBook(long userId, long bookId);
    BorrowTickets borrowBooks(long userId, List<Long> bookIds);
    BorrowTickets borrowBooks(long userId, List<Long> bookIds, int borrowDays);
    BorrowTickets createOnlineBorrow(long userId, List<Long> bookIds, int borrowDays);
    BorrowTickets completeOnlinePayment(long ticketId);
    BorrowTickets cancelOnlinePayment(long ticketId);
    BorrowTickets createBorrowTicketWithCopies(BorrowTicketRequest request);
    BorrowTickets updateStatus(long ticketId, String status);
    BorrowTickets renewBorrowTicket(long ticketId, long requesterUserId, boolean staff, int extensionDays);
    Optional<BorrowTickets> getBorrowTicketById(long ticketId);
    List<BorrowTickets> getAllBorrowTickets();
    BorrowTickets updateBorrowTicket(long ticketId, BorrowTickets borrowTicket);
    void deleteBorrowTicket(long ticketId);
    List<BorrowTickets> findByUser(long userId);
    List<BorrowTickets> findByStatus(String status);
}
