package com.library.libhub.service.impl;

import com.library.libhub.exception.ResourceNotFoundException;

import com.library.libhub.dao.BorrowTicketDAO;
import com.library.libhub.entity.BorrowTickets;
import com.library.libhub.service.IBorrowTicketService;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import java.sql.Timestamp;

@Service
@Transactional
public class BorrowTicketServiceImpl implements IBorrowTicketService {

    private final BorrowTicketDAO borrowTicketDAO;

    public BorrowTicketServiceImpl(BorrowTicketDAO borrowTicketDAO) {
        this.borrowTicketDAO = borrowTicketDAO;
    }

    @Override
    public BorrowTickets createBorrowTicket(BorrowTickets borrowTicket) {
        if (borrowTicket == null || borrowTicket.getUserId() == null || borrowTicket.getBorrowDate() == null
                || borrowTicket.getDueDate() == null) throw new IllegalArgumentException("Thiếu thông tin phiếu mượn");
        if (borrowTicket.getDueDate().before(borrowTicket.getBorrowDate()))
            throw new IllegalArgumentException("Hạn trả không thể trước ngày mượn");
        if (borrowTicket.getStatus() == null || borrowTicket.getStatus().isBlank()) borrowTicket.setStatus("Borrowed");
        if (borrowTicket.getCreatedAt() == null) borrowTicket.setCreatedAt(new Timestamp(System.currentTimeMillis()));
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
        BorrowTickets existing = borrowTicketDAO.findById(ticketId)
                .orElseThrow(() -> new ResourceNotFoundException("Borrow ticket not found with id: " + ticketId));
        if (borrowTicket.getUserId() != null) existing.setUserId(borrowTicket.getUserId());
        if (borrowTicket.getBorrowDate() != null) existing.setBorrowDate(borrowTicket.getBorrowDate());
        if (borrowTicket.getDueDate() != null) existing.setDueDate(borrowTicket.getDueDate());
        if (borrowTicket.getStatus() != null) existing.setStatus(borrowTicket.getStatus());
        if (borrowTicket.getNote() != null) existing.setNote(borrowTicket.getNote());
        if (existing.getBorrowDate() != null && existing.getDueDate() != null
                && existing.getDueDate().before(existing.getBorrowDate()))
            throw new IllegalArgumentException("Hạn trả không thể trước ngày mượn");
        return borrowTicketDAO.save(existing);
    }

    @Override
    public void deleteBorrowTicket(long ticketId) {
        if (borrowTicketDAO.existsById(ticketId)) {
            borrowTicketDAO.deleteById(ticketId);
        } else {
            throw new ResourceNotFoundException("Borrow ticket not found with id: " + ticketId);
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
