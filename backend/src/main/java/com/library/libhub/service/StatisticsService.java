package com.library.libhub.service;


import com.library.libhub.entity.BorrowTickets;
import com.library.libhub.entity.Books;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Date;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Comparator;

import com.library.libhub.repository.BorrowDetailRepository;
import com.library.libhub.repository.BorrowTicketRepository;
import com.library.libhub.repository.FineRepository;
import com.library.libhub.repository.BookRepository;
import com.library.libhub.repository.BookCopyRepository;
import com.library.libhub.repository.ReturnDetailRepository;
import com.library.libhub.repository.ReturnRepository;
import com.library.libhub.entity.BookCopies;
import com.library.libhub.entity.BorrowDetails;
import com.library.libhub.entity.Fines;
import com.library.libhub.entity.ReturnDetails;
import com.library.libhub.entity.Returns;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class StatisticsService {
    private final BorrowDetailRepository borrowDetailRepo;
    private final BorrowTicketRepository borrowTicketRepo;
    private final FineRepository fineRepo;
    private final BookRepository bookRepo;
    private final BookCopyRepository bookCopyRepo;
    private final ReturnRepository returnRepo;
    private final ReturnDetailRepository returnDetailRepo;

    public StatisticsService(
            BorrowDetailRepository borrowDetailRepo,
            BorrowTicketRepository borrowTicketRepo,
            FineRepository fineRepo,
            BookRepository bookRepo,
            BookCopyRepository bookCopyRepo,
            ReturnRepository returnRepo,
            ReturnDetailRepository returnDetailRepo) {
        this.borrowDetailRepo = borrowDetailRepo;
        this.borrowTicketRepo = borrowTicketRepo;
        this.fineRepo = fineRepo;
        this.bookRepo = bookRepo;
        this.bookCopyRepo = bookCopyRepo;
        this.returnRepo = returnRepo;
        this.returnDetailRepo = returnDetailRepo;
    }

    public List<Map<String, Object>> inventory() {
        List<Books> books = bookRepo.findAll();
        if (books.isEmpty()) return List.of();
        Map<Long, BookCopyRepository.BookAvailability> availability = bookCopyRepo
                .summarizeAvailability(books.stream().map(Books::getBookId).toList())
                .stream()
                .collect(Collectors.toMap(BookCopyRepository.BookAvailability::getBookId, Function.identity()));
        return books.stream().map(book -> {
            BookCopyRepository.BookAvailability counts = availability.get(book.getBookId());
            long total = counts == null ? 0 : counts.getTotalCopies();
            long available = counts == null ? 0 : counts.getAvailableCopies();
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("bookId", book.getBookId());
            item.put("title", book.getTitle());
            item.put("isbn", book.getIsbn());
            item.put("totalCopies", total);
            item.put("availableCopies", available);
            item.put("unavailableCopies", total - available);
            item.put("hidden", Boolean.TRUE.equals(book.getHidden()));
            return item;
        }).toList();
    }

    public List<Map<String, Object>> currentlyBorrowed() {
        return bookCounts(borrowDetailRepo.countCurrentlyBorrowedByBook());
    }

    public List<BorrowTickets> overdueTickets() {
        return borrowTicketRepo.findOverdue(Date.valueOf(LocalDate.now()));
    }

    public List<Map<String, Object>> fineSummary() {
        return fineRepo.summarizeByPaidStatus().stream().map(row -> {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("paidStatus", row[0]);
            item.put("fineCount", row[1]);
            item.put("totalAmount", row[2]);
            return item;
        }).toList();
    }

    public List<Map<String, Object>> mostBorrowed(int limit) {
        if (limit < 1 || limit > 100) throw new IllegalArgumentException("limit phải từ 1 đến 100");
        return rankedBorrowedBooks(limit, false);
    }

    public List<Map<String, Object>> leastBorrowed(int limit) {
        if (limit < 1 || limit > 100) throw new IllegalArgumentException("limit phải từ 1 đến 100");
        return rankedBorrowedBooks(limit, true);
    }

    public Map<String, Object> monthlySummary(LocalDate month) {
        LocalDate start = month.withDayOfMonth(1);
        LocalDate end = start.plusMonths(1);
        List<BorrowTickets> tickets = borrowTicketRepo.findAll();
        List<BorrowDetails> details = borrowDetailRepo.findAll();
        Set<Long> monthlyTicketIds = tickets.stream()
                .filter(ticket -> isInMonth(ticket.getBorrowDate(), start, end))
                .map(BorrowTickets::getTicketId)
                .collect(Collectors.toSet());
        long borrowedBooks = details.stream().filter(detail -> monthlyTicketIds.contains(detail.getTicketId())).count();

        Set<Long> monthlyReturnIds = returnRepo.findAll().stream()
                .filter(returned -> isInMonth(returned.getReturnDate(), start, end))
                .map(Returns::getReturnId)
                .collect(Collectors.toSet());
        long returnedBooks = returnDetailRepo.findAll().stream()
                .filter(detail -> monthlyReturnIds.contains(detail.getReturnId())).count();

        List<Fines> monthlyFines = fineRepo.findAll().stream()
                .filter(fine -> fine.getCreatedAt() != null
                        && isInMonth(new Date(fine.getCreatedAt().getTime()), start, end))
                .toList();
        BigDecimal paidFines = monthlyFines.stream()
                .filter(fine -> "paid".equalsIgnoreCase(fine.getPaidStatus()))
                .map(fine -> fine.getAmount() == null ? BigDecimal.ZERO : fine.getAmount())
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal paidBorrowFees = tickets.stream()
                .filter(ticket -> "paid".equalsIgnoreCase(ticket.getDepositPaidStatus()))
                .filter(ticket -> isInMonth(ticket.getBorrowDate(), start, end))
                .map(ticket -> ticket.getDepositAmount() == null ? BigDecimal.ZERO : ticket.getDepositAmount())
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        Map<Long, Long> bookByCopy = bookCopyRepo.findAll().stream()
                .collect(Collectors.toMap(BookCopies::getCopyId, BookCopies::getBookId));
        Set<Long> borrowedBookIds = details.stream()
                .map(BorrowDetails::getCopyId)
                .map(bookByCopy::get)
                .filter(java.util.Objects::nonNull)
                .collect(Collectors.toSet());
        long unreadBooks = bookRepo.findAll().stream()
                .filter(book -> !borrowedBookIds.contains(book.getBookId()))
                .count();

        Map<String, Object> summary = new LinkedHashMap<>();
        summary.put("month", start.toString());
        summary.put("paidFineTotal", paidFines);
        summary.put("borrowedBookCount", borrowedBooks);
        summary.put("returnedBookCount", returnedBooks);
        summary.put("neverBorrowedBookCount", unreadBooks);
        summary.put("borrowFeeRevenue", paidBorrowFees);
        summary.put("depositRevenue", paidBorrowFees); // tương thích frontend cũ
        summary.put("fineRevenue", paidFines);
        summary.put("totalRevenue", paidBorrowFees.add(paidFines));
        summary.put("fineBreakdown", fineBreakdown(monthlyFines));
        summary.put("mostBorrowedBooks", rankedBorrowedBooks(5, false));
        summary.put("leastBorrowedBooks", rankedBorrowedBooks(5, true));
        return summary;
    }

    private List<Map<String, Object>> fineBreakdown(List<Fines> fines) {
        Map<String, List<Fines>> grouped = fines.stream()
                .collect(Collectors.groupingBy(this::fineType, LinkedHashMap::new, Collectors.toList()));

        return List.of("Quá hạn", "Sách hư hỏng", "Quá hạn và hư hỏng", "Khác").stream()
                .filter(grouped::containsKey)
                .map(type -> {
                    List<Fines> rows = grouped.get(type);
                    BigDecimal paidAmount = fineAmount(rows, true);
                    BigDecimal unpaidAmount = fineAmount(rows, false);
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("fineType", type);
                    item.put("fineCount", rows.size());
                    item.put("paidAmount", paidAmount);
                    item.put("unpaidAmount", unpaidAmount);
                    item.put("totalAmount", paidAmount.add(unpaidAmount));
                    return item;
                })
                .toList();
    }

    private BigDecimal fineAmount(List<Fines> fines, boolean paid) {
        return fines.stream()
                .filter(fine -> paid == "paid".equalsIgnoreCase(fine.getPaidStatus()))
                .map(fine -> fine.getAmount() == null ? BigDecimal.ZERO : fine.getAmount())
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private String fineType(Fines fine) {
        String reason = fine.getReason() == null ? "" : fine.getReason().toLowerCase(java.util.Locale.ROOT);
        boolean overdue = reason.contains("quá hạn");
        boolean damaged = reason.contains("hư hỏng");
        if (overdue && damaged) return "Quá hạn và hư hỏng";
        if (overdue) return "Quá hạn";
        if (damaged) return "Sách hư hỏng";
        return "Khác";
    }

    private List<Map<String, Object>> rankedBorrowedBooks(int limit, boolean ascending) {
        Map<Long, Long> bookByCopy = bookCopyRepo.findAll().stream()
                .collect(Collectors.toMap(BookCopies::getCopyId, BookCopies::getBookId));
        Map<Long, Long> counts = borrowDetailRepo.findAll().stream()
                .filter(detail -> !"cancelled".equalsIgnoreCase(detail.getBorrowStatus()))
                .map(BorrowDetails::getCopyId)
                .map(bookByCopy::get)
                .filter(java.util.Objects::nonNull)
                .collect(Collectors.groupingBy(Function.identity(), Collectors.counting()));

        Comparator<Map<String, Object>> comparator = Comparator
                .comparingLong(item -> ((Number) item.get("borrowCount")).longValue());
        if (!ascending) comparator = comparator.reversed();
        comparator = comparator.thenComparing(item -> String.valueOf(item.get("title")));

        return bookRepo.findAll().stream()
                .map(book -> {
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("bookId", book.getBookId());
                    item.put("title", book.getTitle());
                    item.put("borrowCount", counts.getOrDefault(book.getBookId(), 0L));
                    return item;
                })
                .sorted(comparator)
                .limit(limit)
                .toList();
    }

    private boolean isInMonth(Date date, LocalDate start, LocalDate end) {
        return date != null && !date.toLocalDate().isBefore(start) && date.toLocalDate().isBefore(end);
    }

    private List<Map<String, Object>> bookCounts(List<Object[]> rows) {
        return rows.stream().map(row -> {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("bookId", row[0]);
            item.put("title", row[1]);
            item.put("borrowCount", row[2]);
            return item;
        }).toList();
    }
}
