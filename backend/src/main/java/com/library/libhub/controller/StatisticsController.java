package com.library.libhub.controller;

import com.library.libhub.entity.BorrowTickets;
import com.library.libhub.service.StatisticsService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.time.LocalDate;

@RestController
@RequestMapping("/api/statistics")
public class StatisticsController {
    private final StatisticsService statisticsService;

    public StatisticsController(StatisticsService statisticsService) {
        this.statisticsService = statisticsService;
    }

    @GetMapping("/borrowed-books")
    public ResponseEntity<List<Map<String, Object>>> borrowedBooks() {
        return ResponseEntity.ok(statisticsService.currentlyBorrowed());
    }

    @GetMapping("/overdue-tickets")
    public ResponseEntity<List<BorrowTickets>> overdueTickets() {
        return ResponseEntity.ok(statisticsService.overdueTickets());
    }

    @GetMapping("/fines")
    public ResponseEntity<List<Map<String, Object>>> fines() {
        return ResponseEntity.ok(statisticsService.fineSummary());
    }

    @GetMapping("/most-borrowed")
    public ResponseEntity<List<Map<String, Object>>> mostBorrowed(
            @RequestParam(defaultValue = "10") int limit) {
        return ResponseEntity.ok(statisticsService.mostBorrowed(limit));
    }

    @GetMapping("/monthly-summary")
    public ResponseEntity<Map<String, Object>> monthlySummary(
            @RequestParam(required = false) String month) {
        LocalDate selected = month == null || month.isBlank()
                ? LocalDate.now()
                : LocalDate.parse(month + "-01");
        return ResponseEntity.ok(statisticsService.monthlySummary(selected));
    }
}
