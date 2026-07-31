package com.library.libhub.service;

import com.library.libhub.dao.BorrowDetailDAO;
import com.library.libhub.dao.BorrowTicketDAO;
import com.library.libhub.dao.FineDAO;
import com.library.libhub.entity.BorrowTickets;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Date;
import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@Transactional(readOnly = true)
public class StatisticsService {
    private final BorrowDetailDAO borrowDetailDAO;
    private final BorrowTicketDAO borrowTicketDAO;
    private final FineDAO fineDAO;

    public StatisticsService(
            BorrowDetailDAO borrowDetailDAO, BorrowTicketDAO borrowTicketDAO, FineDAO fineDAO) {
        this.borrowDetailDAO = borrowDetailDAO;
        this.borrowTicketDAO = borrowTicketDAO;
        this.fineDAO = fineDAO;
    }

    public List<Map<String, Object>> currentlyBorrowed() {
        return bookCounts(borrowDetailDAO.countCurrentlyBorrowedByBook());
    }

    public List<BorrowTickets> overdueTickets() {
        return borrowTicketDAO.findOverdue(Date.valueOf(LocalDate.now()));
    }

    public List<Map<String, Object>> fineSummary() {
        return fineDAO.summarizeByPaidStatus().stream().map(row -> {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("paidStatus", row[0]);
            item.put("fineCount", row[1]);
            item.put("totalAmount", row[2]);
            return item;
        }).toList();
    }

    public List<Map<String, Object>> mostBorrowed(int limit) {
        if (limit < 1 || limit > 100) throw new IllegalArgumentException("limit phải từ 1 đến 100");
        return bookCounts(borrowDetailDAO.countAllLoansByBook()).stream().limit(limit).toList();
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
