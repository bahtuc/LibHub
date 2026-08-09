package com.library.libhub.service.impl;

import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashSet;
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
import com.library.libhub.repository.UserRepository;
import com.library.libhub.service.IBorrowTicketService;

import jakarta.transaction.Transactional;

@Service
@Transactional
public class BorrowTicketServiceImpl implements IBorrowTicketService {

    private static final String STATUS_AVAILABLE = "Available";
    private static final String STATUS_BORROWED = "Borrowed";
    private static final String STATUS_RETURNED = "Returned";
    private static final String STATUS_CANCELLED = "Cancelled";

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

    // =========================================================
    // TẠO PHIẾU MƯỢN CƠ BẢN
    // =========================================================

    @Override
    public BorrowTickets createBorrowTicket(
            BorrowTickets borrowTicket) {

        if (borrowTicket == null) {
            throw new IllegalArgumentException(
                    "Dữ liệu phiếu mượn không được để trống.");
        }

        if (borrowTicket.getUserId() == null) {
            throw new IllegalArgumentException(
                    "User ID không được để trống.");
        }

        if (borrowTicket.getBorrowDate() == null) {
            throw new IllegalArgumentException(
                    "Ngày mượn không được để trống.");
        }

        if (borrowTicket.getDueDate() == null) {
            throw new IllegalArgumentException(
                    "Hạn trả không được để trống.");
        }

        Users user = userRepo.findById(
                borrowTicket.getUserId()).orElseThrow(
                        () -> new ResourceNotFoundException(
                                "Không tìm thấy người dùng: "
                                        + borrowTicket.getUserId()));

        checkActiveUser(user);

        if (borrowTicket.getDueDate()
                .before(borrowTicket.getBorrowDate())) {

            throw new IllegalArgumentException(
                    "Hạn trả không thể trước ngày mượn.");
        }

        if (borrowTicket.getStatus() == null
                || borrowTicket.getStatus().isBlank()) {

            borrowTicket.setStatus(STATUS_BORROWED);
        }

        if (borrowTicket.getCreatedAt() == null) {
            borrowTicket.setCreatedAt(
                    new Timestamp(System.currentTimeMillis()));
        }

        return borrowTicketRepo.save(borrowTicket);
    }

<<<<<<< HEAD
    // =========================================================
    // MƯỢN 1 ĐẦU SÁCH
    // =========================================================
=======
    @Override
    public BorrowTickets borrowBook(Long userId, Long bookId) {
        Users user = userRepo.findByIdForUpdate(userId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Không tìm thấy tài khoản"));
        if (!"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            throw new IllegalArgumentException("Tài khoản không thể mượn sách");
        }
>>>>>>> 904b812 (FRONTENDDDD)

    @Override
    public BorrowTickets borrowBook(
            long userId,
            long bookId) {

        Users user = userRepo.findByIdForUpdate(
                userId).orElseThrow(
                        () -> new ResourceNotFoundException(
                                "Không tìm thấy tài khoản: "
                                        + userId));

        checkActiveUser(user);

        Books book = bookRepo.findById(
                bookId).orElseThrow(
                        () -> new ResourceNotFoundException(
                                "Không tìm thấy sách: "
                                        + bookId));

        checkBookCanBorrow(book);

        if (borrowDetailRepo.existsActiveBorrow(
                userId,
                bookId)) {

            throw new IllegalArgumentException(
                    "Bạn đang mượn sách: "
                            + book.getTitle());
        }

        BookCopies copy = bookCopyRepo
                .findFirstByBookIdAndStatusIgnoreCaseOrderByCopyIdAsc(
                        bookId,
                        STATUS_AVAILABLE)
                .orElseThrow(() -> new IllegalArgumentException(
                        "Hiện không còn bản sao sẵn sàng để mượn."));

        LocalDate today = LocalDate.now();

        BorrowTickets ticket = new BorrowTickets();

        ticket.setUserId(userId);
        ticket.setBorrowDate(
                Date.valueOf(today));
        ticket.setDueDate(
                Date.valueOf(today.plusDays(14)));
        ticket.setStatus(STATUS_BORROWED);
        ticket.setCreatedAt(
                new Timestamp(System.currentTimeMillis()));

        ticket.setNote(
                buildLoanNote(book, copy));

        BorrowTickets savedTicket = borrowTicketRepo.save(ticket);

        BorrowDetails detail = new BorrowDetails();

        detail.setTicketId(
                savedTicket.getTicketId());

        detail.setCopyId(
                copy.getCopyId());

        detail.setBorrowStatus(
                STATUS_BORROWED);

        borrowDetailRepo.save(detail);

        copy.setStatus(
                STATUS_BORROWED);

        bookCopyRepo.save(copy);

        return savedTicket;
    }

    // =========================================================
    // MƯỢN NHIỀU ĐẦU SÁCH
    // =========================================================

    @Override
    public BorrowTickets borrowBooks(
            long userId,
            List<Long> bookIds) {

        if (bookIds == null || bookIds.isEmpty()) {
            throw new IllegalArgumentException(
                    "Danh sách sách không được để trống.");
        }

        Set<Long> uniqueBookIds = new HashSet<>(bookIds);

        if (uniqueBookIds.size() != bookIds.size()) {
            throw new IllegalArgumentException(
                    "Danh sách sách không được chứa sách trùng nhau.");
        }

        Users user = userRepo.findByIdForUpdate(userId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Không tìm thấy người dùng: "
                                + userId));

        checkActiveUser(user);

        List<BookCopies> selectedCopies = new ArrayList<>();

        for (Long bookId : bookIds) {

            if (bookId == null) {
                throw new IllegalArgumentException(
                        "Book ID không được để trống.");
            }

            Books book = bookRepo.findById(bookId)
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Không tìm thấy sách: "
                                    + bookId));

            checkBookCanBorrow(book);

            if (borrowDetailRepo.existsActiveBorrow(
                    userId,
                    bookId)) {

                throw new IllegalArgumentException(
                        "Bạn đang mượn sách: "
                                + book.getTitle());
            }

            BookCopies copy = bookCopyRepo
                    .findFirstByBookIdAndStatusIgnoreCaseOrderByCopyIdAsc(
                            bookId,
                            STATUS_AVAILABLE)
                    .orElseThrow(() -> new IllegalArgumentException(
                            "Sách \""
                                    + book.getTitle()
                                    + "\" không còn bản sao sẵn."));

            selectedCopies.add(copy);
        }

        LocalDate today = LocalDate.now();

        BorrowTickets ticket = new BorrowTickets();

        ticket.setUserId(userId);
        ticket.setBorrowDate(
                Date.valueOf(today));
        ticket.setDueDate(
                Date.valueOf(today.plusDays(14)));
        ticket.setStatus(
                STATUS_BORROWED);
        ticket.setCreatedAt(
                new Timestamp(System.currentTimeMillis()));

        BorrowTickets savedTicket = borrowTicketRepo.save(ticket);

        for (BookCopies copy : selectedCopies) {

            if (!STATUS_AVAILABLE.equalsIgnoreCase(
                    copy.getStatus())) {

                throw new IllegalArgumentException(
                        "Bản sao "
                                + copy.getBarcode()
                                + " không còn sẵn để mượn.");
            }

            BorrowDetails detail = new BorrowDetails();

            detail.setTicketId(
                    savedTicket.getTicketId());

            detail.setCopyId(
                    copy.getCopyId());

            detail.setBorrowStatus(
                    STATUS_BORROWED);

            borrowDetailRepo.save(detail);

            copy.setStatus(
                    STATUS_BORROWED);

            bookCopyRepo.save(copy);
        }

        return savedTicket;
    }

    // =========================================================
    // TẠO PHIẾU MƯỢN BẰNG COPY IDS
    // DÙNG CHO LibrarianBorrow.jsx
    // =========================================================

    @Override
    public BorrowTickets createBorrowTicketWithCopies(
            BorrowTicketRequest request) {

        // -----------------------------------------------------
        // 1. Validate request
        // -----------------------------------------------------

        if (request == null) {
            throw new IllegalArgumentException(
                    "Dữ liệu phiếu mượn không được để trống.");
        }

        if (request.getUserId() == null) {
            throw new IllegalArgumentException(
                    "Chưa chọn bạn đọc.");
        }

        if (request.getCopyIds() == null
                || request.getCopyIds().isEmpty()) {

            throw new IllegalArgumentException(
                    "Chưa chọn bản sao sách.");
        }

        // Vì dueDate là java.sql.Date
        // KHÔNG dùng .isBlank()
        if (request.getDueDate() == null) {
            throw new IllegalArgumentException(
                    "Hạn trả không được để trống.");
        }

        // -----------------------------------------------------
        // 2. Không cho copy trùng
        // -----------------------------------------------------

        Set<Long> uniqueCopyIds = new HashSet<>(
                request.getCopyIds());

        if (uniqueCopyIds.size() != request.getCopyIds().size()) {

            throw new IllegalArgumentException(
                    "Danh sách bản sao không được chứa bản sao trùng nhau.");
        }

        // -----------------------------------------------------
        // 3. Kiểm tra user
        // -----------------------------------------------------

        Users user = userRepo.findByIdForUpdate(
                request.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Không tìm thấy người dùng: "
                                + request.getUserId()));

        checkActiveUser(user);

        // -----------------------------------------------------
        // 4. Lấy dueDate trực tiếp
        // -----------------------------------------------------

        Date dueDate = request.getDueDate();

        if (dueDate == null) {
            throw new IllegalArgumentException(
                    "Hạn trả không được để trống.");
        }

        Date today = Date.valueOf(LocalDate.now());

        if (dueDate.before(today)) {
            throw new IllegalArgumentException(
                    "Hạn trả không được ở quá khứ.");
        }
        // -----------------------------------------------------
        // 5. Kiểm tra các copy
        // -----------------------------------------------------

        List<BookCopies> lockedCopies = new ArrayList<>();

        Set<Long> selectedBookIds = new HashSet<>();

        for (Long copyId : request.getCopyIds()) {

            if (copyId == null) {
                throw new IllegalArgumentException(
                        "Copy ID không được để trống.");
            }

            BookCopies copy = bookCopyRepo.findByIdForUpdate(
                    copyId)
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Không tìm thấy bản sao: "
                                    + copyId));

            // Kiểm tra available
            if (!STATUS_AVAILABLE.equalsIgnoreCase(
                    copy.getStatus())) {

                throw new IllegalArgumentException(
                        "Bản sao "
                                + copy.getBarcode()
                                + " không còn sẵn để mượn.");
            }

            // -------------------------------------------------
            // Kiểm tra sách
            // -------------------------------------------------

            Books book = bookRepo.findById(
                    copy.getBookId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Không tìm thấy sách của bản sao: "
                                    + copy.getCopyId()));

            checkBookCanBorrow(book);

            // -------------------------------------------------
            // Không cho chọn 2 bản sao cùng một đầu sách
            // -------------------------------------------------

            if (!selectedBookIds.add(
                    copy.getBookId())) {

                throw new IllegalArgumentException(
                        "Không thể mượn nhiều bản sao của cùng một đầu sách: "
                                + book.getTitle());
            }

            // -------------------------------------------------
            // Kiểm tra user đã mượn đầu sách chưa
            // -------------------------------------------------

            if (borrowDetailRepo.existsActiveBorrow(
                    request.getUserId(),
                    copy.getBookId())) {

                throw new IllegalArgumentException(
                        "Bạn đang mượn sách: "
                                + book.getTitle());
            }

            lockedCopies.add(copy);
        }

        // -----------------------------------------------------
        // 6. Tạo ticket
        // -----------------------------------------------------

        BorrowTickets ticket = new BorrowTickets();

        ticket.setUserId(
                request.getUserId());

        ticket.setBorrowDate(
                today);

        ticket.setDueDate(
                dueDate);

        ticket.setStatus(
                STATUS_BORROWED);

        ticket.setNote(
                request.getNote());

        ticket.setCreatedAt(
                new Timestamp(
                        System.currentTimeMillis()));

        BorrowTickets savedTicket = borrowTicketRepo.save(ticket);

        // -----------------------------------------------------
        // 7. Tạo BorrowDetails
        // + đổi trạng thái BookCopies
        // -----------------------------------------------------

        for (BookCopies copy : lockedCopies) {

            BorrowDetails detail = new BorrowDetails();

            detail.setTicketId(
                    savedTicket.getTicketId());

            detail.setCopyId(
                    copy.getCopyId());

            detail.setBorrowStatus(
                    STATUS_BORROWED);

            borrowDetailRepo.save(detail);

            copy.setStatus(
                    STATUS_BORROWED);

            bookCopyRepo.save(copy);
        }

        return savedTicket;
    }

    // =========================================================
    // UPDATE STATUS PHIẾU
    // =========================================================

    @Override
    public BorrowTickets updateStatus(
            long ticketId,
            String status) {

        if (status == null
                || status.isBlank()) {

            throw new IllegalArgumentException(
                    "Trạng thái không được để trống.");
        }

        BorrowTickets ticket = borrowTicketRepo.findById(
                ticketId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Không tìm thấy phiếu mượn: "
                                + ticketId));

        String newStatus = status.trim();

        // -----------------------------------------------------
        // Trả sách
        // -----------------------------------------------------

        if (STATUS_RETURNED.equalsIgnoreCase(
                newStatus)) {

            List<BorrowDetails> details = borrowDetailRepo.findByTicketId(
                    ticketId);

            if (details == null
                    || details.isEmpty()) {

                throw new IllegalArgumentException(
                        "Phiếu mượn không có sách.");
            }

            for (BorrowDetails detail : details) {

                BookCopies copy = bookCopyRepo.findByIdForUpdate(
                        detail.getCopyId())
                        .orElseThrow(() -> new ResourceNotFoundException(
                                "Không tìm thấy bản sao: "
                                        + detail.getCopyId()));

                copy.setStatus(
                        STATUS_AVAILABLE);

                bookCopyRepo.save(copy);

                detail.setBorrowStatus(
                        STATUS_RETURNED);

                borrowDetailRepo.save(detail);
            }
        }

        // -----------------------------------------------------
        // Hủy phiếu
        // -----------------------------------------------------

        if (STATUS_CANCELLED.equalsIgnoreCase(
                newStatus)) {

            List<BorrowDetails> details = borrowDetailRepo.findByTicketId(
                    ticketId);

            if (details != null) {

                for (BorrowDetails detail : details) {

                    if (STATUS_BORROWED.equalsIgnoreCase(
                            detail.getBorrowStatus())) {

                        BookCopies copy = bookCopyRepo.findByIdForUpdate(
                                detail.getCopyId())
                                .orElseThrow(() -> new ResourceNotFoundException(
                                        "Không tìm thấy bản sao: "
                                                + detail.getCopyId()));

                        copy.setStatus(
                                STATUS_AVAILABLE);

                        bookCopyRepo.save(copy);

                        detail.setBorrowStatus(
                                STATUS_CANCELLED);

                        borrowDetailRepo.save(detail);
                    }
                }
            }
        }

        ticket.setStatus(
                newStatus);

        return borrowTicketRepo.save(ticket);
    }

    // =========================================================
    // GET
    // =========================================================

    @Override
<<<<<<< HEAD
    public Optional<BorrowTickets> getBorrowTicketById(
            long ticketId) {

        return borrowTicketRepo.findById(
                ticketId);
=======
    public Optional<BorrowTickets> getBorrowTicketById(Long ticketId) {
        return borrowTicketRepo.findById(ticketId);
>>>>>>> 904b812 (FRONTENDDDD)
    }

    @Override
    public List<BorrowTickets> getAllBorrowTickets() {

        return borrowTicketRepo.findAll();
    }

    @Override
<<<<<<< HEAD
    public List<BorrowTickets> findByUser(
            long userId) {

        return borrowTicketRepo.findByUserId(
                userId);
    }

    @Override
    public List<BorrowTickets> findByStatus(
            String status) {

        return borrowTicketRepo.findByStatus(
                status);
    }

    // =========================================================
    // UPDATE PHIẾU
    // =========================================================

    @Override
    public BorrowTickets updateBorrowTicket(
            long ticketId,
            BorrowTickets borrowTicket) {

        if (borrowTicket == null) {
            throw new IllegalArgumentException(
                    "Dữ liệu cập nhật không được để trống.");
        }

        BorrowTickets existing = borrowTicketRepo.findById(
                ticketId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Không tìm thấy phiếu mượn: "
                                + ticketId));

        // User
=======
    public BorrowTickets updateBorrowTicket(Long ticketId, BorrowTickets borrowTicket) {
        BorrowTickets existing = borrowTicketRepo.findById(ticketId)
                .orElseThrow(() -> new ResourceNotFoundException("Borrow ticket not found with id: " + ticketId));
>>>>>>> 904b812 (FRONTENDDDD)
        if (borrowTicket.getUserId() != null) {

            Users user = userRepo.findById(
                    borrowTicket.getUserId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Không tìm thấy người dùng: "
                                    + borrowTicket.getUserId()));

            checkActiveUser(user);

            existing.setUserId(
                    borrowTicket.getUserId());
        }

        // Borrow date
        if (borrowTicket.getBorrowDate() != null) {

            existing.setBorrowDate(
                    borrowTicket.getBorrowDate());
        }

        // Due date
        if (borrowTicket.getDueDate() != null) {

            existing.setDueDate(
                    borrowTicket.getDueDate());
        }

        // Status
        if (borrowTicket.getStatus() != null
                && !borrowTicket.getStatus().isBlank()) {

            existing.setStatus(
                    borrowTicket.getStatus().trim());
        }

        // Note
        if (borrowTicket.getNote() != null) {

            existing.setNote(
                    borrowTicket.getNote());
        }

        // Kiểm tra ngày
        if (existing.getBorrowDate() != null
                && existing.getDueDate() != null
                && existing.getDueDate()
                        .before(existing.getBorrowDate())) {

            throw new IllegalArgumentException(
                    "Hạn trả không thể trước ngày mượn.");
        }

        return borrowTicketRepo.save(existing);
    }

    // =========================================================
    // DELETE
    // =========================================================

    @Override
<<<<<<< HEAD
    public void deleteBorrowTicket(
            long ticketId) {

        if (!borrowTicketRepo.existsById(
                ticketId)) {

            throw new ResourceNotFoundException(
                    "Không tìm thấy phiếu mượn: "
                            + ticketId);
=======
    public void deleteBorrowTicket(Long ticketId) {
        BorrowTickets ticket = borrowTicketRepo.findById(ticketId).orElse(null);
        if (ticket == null) {
            throw new ResourceNotFoundException("Borrow ticket not found with id: " + ticketId);
        }
        if (!returnRepo.findByTicketId(ticketId).isEmpty()) {
            throw new IllegalArgumentException("Returned tickets cannot be deleted because they have return history");
>>>>>>> 904b812 (FRONTENDDDD)
        }

        borrowTicketRepo.deleteById(
                ticketId);
    }

<<<<<<< HEAD
    // =========================================================
    // HELPER
    // =========================================================
=======
    @Override
    public List<BorrowTickets> findByUser(Long userId) {
        return borrowTicketRepo.findByUserId(userId);
    }
>>>>>>> 904b812 (FRONTENDDDD)

    private void checkActiveUser(
            Users user) {

<<<<<<< HEAD
        if (user == null) {
            throw new IllegalArgumentException(
                    "Người dùng không tồn tại.");
=======
    @Override
    public BorrowTickets borrowBooks(Long userId, List<Long> bookIds) {
        if (bookIds == null || bookIds.isEmpty()) {
            throw new IllegalArgumentException("Book list is required");
        }
        Set<Long> uniqueBookIds = new LinkedHashSet<>(bookIds);
        if (uniqueBookIds.size() != bookIds.size() || uniqueBookIds.contains(null)) {
            throw new IllegalArgumentException("Book list contains duplicate or invalid IDs");
>>>>>>> 904b812 (FRONTENDDDD)
        }

        if (!"ACTIVE".equalsIgnoreCase(
                user.getStatus())) {

            throw new IllegalArgumentException(
                    "Tài khoản người dùng không hoạt động.");
        }
    }

    private void checkBookCanBorrow(
            Books book) {

        if (book == null) {
            throw new IllegalArgumentException(
                    "Sách không tồn tại.");
        }

        if (Boolean.TRUE.equals(
                book.getHidden())) {

            throw new IllegalArgumentException(
                    "Sách \""
                            + book.getTitle()
                            + "\" hiện không thể mượn.");
        }
    }

    private String buildLoanNote(
            Books book,
            BookCopies copy) {

        return "{\"b\":"
                + book.getBookId()
                + ",\"c\":"
                + copy.getCopyId()
                + ",\"t\":\""
                + escapeJson(book.getTitle())
                + "\"}";
    }

    private String escapeJson(
            String value) {

        if (value == null) {
            return "";
        }

        StringBuilder escaped = new StringBuilder();

        for (int index = 0; index < value.length(); index++) {

            char character = value.charAt(index);

            switch (character) {

                case '"' ->
                    escaped.append("\\\"");

                case '\\' ->
                    escaped.append("\\\\");

                case '\b' ->
                    escaped.append("\\b");

                case '\f' ->
                    escaped.append("\\f");

                case '\n' ->
                    escaped.append("\\n");

                case '\r' ->
                    escaped.append("\\r");

                case '\t' ->
                    escaped.append("\\t");

                default -> {

                    if (character < 0x20) {

                        escaped.append(
                                String.format(
                                        "\\u%04x",
                                        (int) character));

                    } else {

                        escaped.append(
                                character);
                    }
                }
            }
        }

        return escaped.toString();
    }
<<<<<<< HEAD
}
=======

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
    public BorrowTickets updateStatus(Long ticketId, String status) {
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

    private Users requireActiveUser(Long userId) {
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
>>>>>>> 904b812 (FRONTENDDDD)
