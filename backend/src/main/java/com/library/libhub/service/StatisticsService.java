package com.library.libhub.service;


import com.library.libhub.entity.BorrowTickets;
import com.library.libhub.entity.Books;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Date;
import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.library.libhub.repository.BorrowDetailRepository;
import com.library.libhub.repository.BorrowTicketRepository;
import com.library.libhub.repository.FineRepository;
import com.library.libhub.repository.BookRepository;
import com.library.libhub.repository.BookCopyRepository;
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

    public StatisticsService(
            BorrowDetailRepository borrowDetailRepo,
            BorrowTicketRepository borrowTicketRepo,
            FineRepository fineRepo,
            BookRepository bookRepo,
            BookCopyRepository bookCopyRepo) {
        this.borrowDetailRepo = borrowDetailRepo;
        this.borrowTicketRepo = borrowTicketRepo;
        this.fineRepo = fineRepo;
        this.bookRepo = bookRepo;
        this.bookCopyRepo = bookCopyRepo;
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
        return bookCounts(borrowDetailRepo.countAllLoansByBook()).stream().limit(limit).toList();
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
