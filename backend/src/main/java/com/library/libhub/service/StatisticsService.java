package com.library.libhub.service;


import com.library.libhub.entity.BorrowTickets;

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

@Service
@Transactional(readOnly = true)
public class StatisticsService {
    private final BorrowDetailRepository borrowDetailRepo;
    private final BorrowTicketRepository borrowTicketRepo;
    private final FineRepository fineRepo;

    public StatisticsService(
            BorrowDetailRepository borrowDetailRepo, BorrowTicketRepository borrowTicketRepo, FineRepository fineRepo) {
        this.borrowDetailRepo = borrowDetailRepo;
        this.borrowTicketRepo = borrowTicketRepo;
        this.fineRepo = fineRepo;
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
