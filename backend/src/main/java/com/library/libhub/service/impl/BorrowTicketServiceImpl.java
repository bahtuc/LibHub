package com.library.libhub.service.impl;

import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.library.libhub.DTO.Request.BorrowTicketRequest;
import com.library.libhub.entity.BookCopies;
import com.library.libhub.entity.Books;
import com.library.libhub.entity.BorrowDetails;
import com.library.libhub.entity.BorrowTickets;
import com.library.libhub.entity.Users;
import com.library.libhub.exception.ResourceNotFoundException;
import com.library.libhub.repository.BookCopyRepository;
import com.library.libhub.repository.BookRepository;
import com.library.libhub.repository.BorrowDetailRepository;
import com.library.libhub.repository.BorrowTicketRepository;
import com.library.libhub.repository.UserRepository;
import com.library.libhub.service.IBorrowTicketService;

import jakarta.transaction.Transactional;

@Service
@Transactional
public class BorrowTicketServiceImpl implements IBorrowTicketService {

    private final BorrowTicketRepository borrowTicketRepo;
    private final BorrowDetailRepository borrowDetailRepo;
    private final BookCopyRepository bookCopyRepo;
    private final BookRepository bookRepo;
    private final UserRepository userRepo;

    public BorrowTicketServiceImpl(
            BorrowTicketRepository borrowTicketRepo,
            BorrowDetailRepository borrowDetailRepo,
            BookCopyRepository bookCopyRepo,
            BookRepository bookRepo,
            UserRepository userRepo) {
        this.borrowTicketRepo = borrowTicketRepo;
        this.borrowDetailRepo = borrowDetailRepo;
        this.bookCopyRepo = bookCopyRepo;
        this.bookRepo = bookRepo;
        this.userRepo = userRepo;
    }

    @Override
    public BorrowTickets createBorrowTicket(BorrowTickets borrowTicket) {
        if (borrowTicket == null || borrowTicket.getUserId() == null || borrowTicket.getBorrowDate() == null
                || borrowTicket.getDueDate() == null) throw new IllegalArgumentException("Thiếu thông tin phiếu mượn");
        if (borrowTicket.getDueDate().before(borrowTicket.getBorrowDate()))
            throw new IllegalArgumentException("Hạn trả không thể trước ngày mượn");
        if (borrowTicket.getStatus() == null || borrowTicket.getStatus().isBlank()) borrowTicket.setStatus("Borrowed");
        if (borrowTicket.getCreatedAt() == null) borrowTicket.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        return borrowTicketRepo.save(borrowTicket);
    }

    @Override
    public BorrowTickets borrowBook(long userId, long bookId) {
        Users user = userRepo.findByIdForUpdate(userId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Không tìm thấy tài khoản"));
        if (!"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            throw new IllegalArgumentException("Tài khoản không thể mượn sách");
        }

        Books book = bookRepo.findById(bookId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Không tìm thấy sách"));
        if (Boolean.TRUE.equals(book.getHidden())) {
            throw new IllegalArgumentException("Sách hiện không thể mượn");
        }
        if (borrowDetailRepo.existsActiveBorrow(userId, bookId)) {
            throw new IllegalArgumentException("Bạn đang mượn sách này");
        }

        BookCopies copy = bookCopyRepo
                .findFirstByBookIdAndStatusIgnoreCaseOrderByCopyIdAsc(
                        bookId, "Available")
                .orElseThrow(() -> new IllegalArgumentException(
                        "Hiện không còn bản sao sẵn sàng để mượn"));

        LocalDate today = LocalDate.now();
        BorrowTickets ticket = new BorrowTickets();
        ticket.setUserId(userId);
        ticket.setBorrowDate(Date.valueOf(today));
        ticket.setDueDate(Date.valueOf(today.plusDays(14)));
        ticket.setStatus("Borrowed");
        ticket.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        ticket.setNote(buildLoanNote(book, copy));
        ticket = borrowTicketRepo.save(ticket);

        BorrowDetails detail = new BorrowDetails();
        detail.setTicketId(ticket.getTicketId());
        detail.setCopyId(copy.getCopyId());
        detail.setBorrowStatus("Borrowed");
        borrowDetailRepo.save(detail);

        copy.setStatus("Borrowed");
        bookCopyRepo.save(copy);
        return ticket;
    }

    private String buildLoanNote(Books book, BookCopies copy) {
        return "{\"b\":" + book.getBookId()
                + ",\"c\":" + copy.getCopyId()
                + ",\"t\":\"" + escapeJson(book.getTitle()) + "\"}";
    }

    private String escapeJson(String value) {
        StringBuilder escaped = new StringBuilder();
        for (int index = 0; index < value.length(); index++) {
            char character = value.charAt(index);
            switch (character) {
                case '"' -> escaped.append("\\\"");
                case '\\' -> escaped.append("\\\\");
                case '\b' -> escaped.append("\\b");
                case '\f' -> escaped.append("\\f");
                case '\n' -> escaped.append("\\n");
                case '\r' -> escaped.append("\\r");
                case '\t' -> escaped.append("\\t");
                default -> {
                    if (character < 0x20) {
                        escaped.append(String.format("\\u%04x", (int) character));
                    } else {
                        escaped.append(character);
                    }
                }
            }
        }
        return escaped.toString();
    }

    @Override
    public Optional<BorrowTickets> getBorrowTicketById(long ticketId) {
        return borrowTicketRepo.findById(ticketId);
    }

    @Override
    public List<BorrowTickets> getAllBorrowTickets() {
        return borrowTicketRepo.findAll();
    }

    @Override
    public BorrowTickets updateBorrowTicket(long ticketId, BorrowTickets borrowTicket) {
        BorrowTickets existing = borrowTicketRepo.findById(ticketId)
                .orElseThrow(() -> new ResourceNotFoundException("Borrow ticket not found with id: " + ticketId));
        if (borrowTicket.getUserId() != null) existing.setUserId(borrowTicket.getUserId());
        if (borrowTicket.getBorrowDate() != null) existing.setBorrowDate(borrowTicket.getBorrowDate());
        if (borrowTicket.getDueDate() != null) existing.setDueDate(borrowTicket.getDueDate());
        if (borrowTicket.getStatus() != null) existing.setStatus(borrowTicket.getStatus());
        if (borrowTicket.getNote() != null) existing.setNote(borrowTicket.getNote());
        if (existing.getBorrowDate() != null && existing.getDueDate() != null
                && existing.getDueDate().before(existing.getBorrowDate()))
            throw new IllegalArgumentException("Hạn trả không thể trước ngày mượn");
        return borrowTicketRepo.save(existing);
    }

    @Override
    public void deleteBorrowTicket(long ticketId) {
        if (borrowTicketRepo.existsById(ticketId)) {
            borrowTicketRepo.deleteById(ticketId);
        } else {
            throw new ResourceNotFoundException("Borrow ticket not found with id: " + ticketId);
        }
    }

    @Override
    public List<BorrowTickets> findByUser(long userId) {
        return borrowTicketRepo.findByUserId(userId);
    }

    @Override
    public List<BorrowTickets> findByStatus(String status) {
        return borrowTicketRepo.findByStatus(status);
    }

    @Override
    public BorrowTickets borrowBooks(long userId, List<Long> bookIds) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public BorrowTickets createBorrowTicketWithCopies(BorrowTicketRequest request) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public BorrowTickets updateStatus(long ticketId, String status) {
        throw new UnsupportedOperationException("Not supported yet.");
    }
}
