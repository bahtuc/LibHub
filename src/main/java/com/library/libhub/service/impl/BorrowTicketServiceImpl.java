package com.library.libhub.service.impl;

import com.library.libhub.dao.BorrowTicketDAO;
import com.library.libhub.entity.BorrowTickets;
import com.library.libhub.service.IBorrowTicketService;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class BorrowTicketServiceImpl implements IBorrowTicketService {

    private final BorrowTicketDAO borrowTicketDAO;

    public BorrowTicketServiceImpl(BorrowTicketDAO borrowTicketDAO) {
        this.borrowTicketDAO = borrowTicketDAO;
    }

    @Override
    public BorrowTickets createBorrowTicket(BorrowTickets borrowTicket) {
        return borrowTicketDAO.save(borrowTicket);
    }

    @Override
    public Optional<BorrowTickets> getBorrowTicketById(long ticketId) {
        return borrowTicketDAO.findById(ticketId);
    }

    @Override
    public List<BorrowTickets> getAllBorrowTickets() {
        return borrowTicketDAO.findAll();
    }

    @Override
    public BorrowTickets updateBorrowTicket(long ticketId, BorrowTickets borrowTicket) {
        if (borrowTicketDAO.existsById(ticketId)) {
            borrowTicket.setTicketId(ticketId);
            return borrowTicketDAO.save(borrowTicket);
        }
        throw new RuntimeException("Borrow ticket not found with id: " + ticketId);
    }

    @Override
    public void deleteBorrowTicket(long ticketId) {
        if (borrowTicketDAO.existsById(ticketId)) {
            borrowTicketDAO.deleteById(ticketId);
        } else {
            throw new RuntimeException("Borrow ticket not found with id: " + ticketId);
        }
    }

    @Override
    public List<BorrowTickets> findByUser(long userId) {
        return borrowTicketDAO.findByUserId(userId);
    }

    @Override
    public List<BorrowTickets> findByStatus(String status) {
        return borrowTicketDAO.findByStatus(status);
    }
}
