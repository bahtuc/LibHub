package com.library.libhub.service.impl;

import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

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
import com.library.libhub.repository.ReturnRepository;
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
    private final ReturnRepository returnRepo;

    public BorrowTicketServiceImpl(
            BorrowTicketRepository borrowTicketRepo,
            BorrowDetailRepository borrowDetailRepo,
            BookCopyRepository bookCopyRepo,
            BookRepository bookRepo,
            UserRepository userRepo,
            ReturnRepository returnRepo) {
        this.borrowTicketRepo = borrowTicketRepo;
        this.borrowDetailRepo = borrowDetailRepo;
        this.bookCopyRepo = bookCopyRepo;
        this.bookRepo = bookRepo;
        this.userRepo = userRepo;
        this.returnRepo = returnRepo;
    }

    @Override
    public BorrowTickets createBorrowTicket(BorrowTickets borrowTicket) {
        if (borrowTicket == null || !hasValidBorrower(borrowTicket.getUserId(), borrowTicket.getGuestName())
                || borrowTicket.getBorrowDate() == null
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
        if (borrowTicket.getUserId() != null) {
            existing.setUserId(borrowTicket.getUserId());
            existing.setGuestName(null);
            existing.setGuestPhone(null);
        }
        if (borrowTicket.getGuestName() != null) {
            existing.setGuestName(normalizeGuestValue(borrowTicket.getGuestName()));
            existing.setGuestPhone(normalizeGuestValue(borrowTicket.getGuestPhone()));
        }
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
        BorrowTickets ticket = borrowTicketRepo.findById(ticketId).orElse(null);
        if (ticket == null) {
            throw new ResourceNotFoundException("Borrow ticket not found with id: " + ticketId);
        }
        if (!returnRepo.findByTicketId(ticketId).isEmpty()) {
            throw new IllegalArgumentException("Returned tickets cannot be deleted because they have return history");
        }

        List<BorrowDetails> details = borrowDetailRepo.findByTicketId(ticketId);
        for (BorrowDetails detail : details) {
            bookCopyRepo.findByIdForUpdate(detail.getCopyId()).ifPresent(copy -> {
                copy.setStatus("Available");
                bookCopyRepo.save(copy);
            });
        }
        borrowDetailRepo.deleteAll(details);
        borrowTicketRepo.delete(ticket);
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
        if (bookIds == null || bookIds.isEmpty()) {
            throw new IllegalArgumentException("Book list is required");
        }
        Set<Long> uniqueBookIds = new LinkedHashSet<>(bookIds);
        if (uniqueBookIds.size() != bookIds.size() || uniqueBookIds.contains(null)) {
            throw new IllegalArgumentException("Book list contains duplicate or invalid IDs");
        }

        requireActiveUser(userId);
        List<Long> copyIds = uniqueBookIds.stream().map(bookId -> {
            Books book = bookRepo.findById(bookId)
                    .orElseThrow(() -> new ResourceNotFoundException("Book not found with id: " + bookId));
            if (Boolean.TRUE.equals(book.getHidden())) {
                throw new IllegalArgumentException("Book is currently unavailable");
            }
            if (borrowDetailRepo.existsActiveBorrow(userId, bookId)) {
                throw new IllegalArgumentException("Member is already borrowing book " + bookId);
            }
            return bookCopyRepo.findFirstByBookIdAndStatusIgnoreCaseOrderByCopyIdAsc(bookId, "Available")
                    .orElseThrow(() -> new IllegalArgumentException("No available copy for book " + bookId))
                    .getCopyId();
        }).toList();

        LocalDate today = LocalDate.now();
        return createTicketWithCopies(
                userId,
                null,
                null,
                Date.valueOf(today),
                Date.valueOf(today.plusDays(14)),
                null,
                copyIds);
    }

    @Override
    public BorrowTickets createBorrowTicketWithCopies(BorrowTicketRequest request) {
        if (request == null || !hasValidBorrower(request.getUserId(), request.getGuestName())
                || request.getDueDate() == null
                || request.getCopyIds() == null || request.getCopyIds().isEmpty()) {
            throw new IllegalArgumentException("A member or guest, due date, and at least one copy are required");
        }
        Set<Long> uniqueCopyIds = new LinkedHashSet<>(request.getCopyIds());
        if (uniqueCopyIds.size() != request.getCopyIds().size() || uniqueCopyIds.contains(null)) {
            throw new IllegalArgumentException("Copy list contains duplicate or invalid IDs");
        }
        return createTicketWithCopies(
                request.getUserId(),
                normalizeGuestValue(request.getGuestName()),
                normalizeGuestValue(request.getGuestPhone()),
                request.getBorrowDate() == null
                        ? Date.valueOf(LocalDate.now())
                        : new Date(request.getBorrowDate().getTime()),
                new Date(request.getDueDate().getTime()),
                request.getNote(),
                List.copyOf(uniqueCopyIds));
    }

    @Override
    public BorrowTickets updateStatus(long ticketId, String status) {
        if (status == null || status.isBlank()) {
            throw new IllegalArgumentException("Status is required");
        }
        String canonicalStatus = switch (status.trim().toLowerCase()) {
            case "borrowed" -> "Borrowed";
            case "overdue" -> "Overdue";
            case "returned" -> "Returned";
            case "cancelled" -> "Cancelled";
            default -> throw new IllegalArgumentException("Unsupported borrow-ticket status: " + status);
        };
        BorrowTickets ticket = borrowTicketRepo.findById(ticketId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Borrow ticket not found with id: " + ticketId));
        ticket.setStatus(canonicalStatus);
        return borrowTicketRepo.save(ticket);
    }

    private Users requireActiveUser(long userId) {
        Users user = userRepo.findByIdForUpdate(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));
        if (!"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            throw new IllegalArgumentException("User account is not active");
        }
        return user;
    }

    private BorrowTickets createTicketWithCopies(
            Long userId,
            String guestName,
            String guestPhone,
            Date borrowDate,
            Date dueDate,
            String note,
            List<Long> copyIds) {
        if (!hasValidBorrower(userId, guestName)) {
            throw new IllegalArgumentException("Choose an active member or enter a guest name");
        }
        if (userId != null) {
            requireActiveUser(userId);
        }
        if (dueDate.before(borrowDate)) {
            throw new IllegalArgumentException("Due date cannot be before borrow date");
        }

        List<BookCopies> copies = copyIds.stream().map(copyId -> {
            BookCopies copy = bookCopyRepo.findByIdForUpdate(copyId)
                    .orElseThrow(() -> new ResourceNotFoundException("Book copy not found with id: " + copyId));
            if (!"Available".equalsIgnoreCase(copy.getStatus())) {
                throw new IllegalArgumentException("Book copy " + copyId + " is not available");
            }
            Books book = bookRepo.findById(copy.getBookId())
                    .orElseThrow(() -> new ResourceNotFoundException("Book not found for copy " + copyId));
            if (Boolean.TRUE.equals(book.getHidden())) {
                throw new IllegalArgumentException("Book copy " + copyId + " belongs to a hidden book");
            }
            if (userId != null && borrowDetailRepo.existsActiveBorrow(userId, copy.getBookId())) {
                throw new IllegalArgumentException("Member is already borrowing book " + copy.getBookId());
            }
            return copy;
        }).toList();

        BorrowTickets ticket = new BorrowTickets();
        ticket.setUserId(userId);
        ticket.setGuestName(userId == null ? guestName : null);
        ticket.setGuestPhone(userId == null ? guestPhone : null);
        ticket.setBorrowDate(borrowDate);
        ticket.setDueDate(dueDate);
        ticket.setStatus("Borrowed");
        ticket.setNote(note);
        ticket.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        ticket = borrowTicketRepo.save(ticket);

        for (BookCopies copy : copies) {
            BorrowDetails detail = new BorrowDetails();
            detail.setTicketId(ticket.getTicketId());
            detail.setCopyId(copy.getCopyId());
            detail.setBorrowStatus("Borrowed");
            borrowDetailRepo.save(detail);
            copy.setStatus("Borrowed");
            bookCopyRepo.save(copy);
        }
        return ticket;
    }

    private boolean hasValidBorrower(Long userId, String guestName) {
        boolean hasUser = userId != null;
        boolean hasGuest = guestName != null && !guestName.isBlank();
        return hasUser != hasGuest;
    }

    private String normalizeGuestValue(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
