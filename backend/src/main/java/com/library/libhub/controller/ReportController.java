package com.library.libhub.controller;

import com.library.libhub.entity.BorrowTickets;
import com.library.libhub.service.StatisticsService;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.util.Map;

@RestController
@RequestMapping("/api/reports")
public class ReportController {
    private final StatisticsService statisticsService;

    public ReportController(StatisticsService statisticsService) {
        this.statisticsService = statisticsService;
    }

    @GetMapping(value = "/statistics.csv", produces = "text/csv")
    public ResponseEntity<byte[]> exportStatistics() {
        StringBuilder csv = new StringBuilder("\uFEFF");
        csv.append("SÁCH ĐANG MƯỢN\nbook_id,title,borrow_count\n");
        for (Map<String, Object> row : statisticsService.currentlyBorrowed()) {
            csv.append(row.get("bookId")).append(',')
                    .append(escape(row.get("title"))).append(',')
                    .append(row.get("borrowCount")).append('\n');
        }
        csv.append("\nPHIẾU QUÁ HẠN\nticket_id,user_id,borrow_date,due_date,status\n");
        for (BorrowTickets ticket : statisticsService.overdueTickets()) {
            csv.append(ticket.getTicketId()).append(',').append(ticket.getUserId()).append(',')
                    .append(ticket.getBorrowDate()).append(',').append(ticket.getDueDate()).append(',')
                    .append(escape(ticket.getStatus())).append('\n');
        }
        csv.append("\nTIỀN PHẠT\npaid_status,fine_count,total_amount\n");
        for (Map<String, Object> row : statisticsService.fineSummary()) {
            csv.append(escape(row.get("paidStatus"))).append(',')
                    .append(row.get("fineCount")).append(',')
                    .append(row.get("totalAmount")).append('\n');
        }
        csv.append("\nSÁCH MƯỢN NHIỀU NHẤT\nbook_id,title,borrow_count\n");
        for (Map<String, Object> row : statisticsService.mostBorrowed(100)) {
            csv.append(row.get("bookId")).append(',')
                    .append(escape(row.get("title"))).append(',')
                    .append(row.get("borrowCount")).append('\n');
        }
        byte[] body = csv.toString().getBytes(StandardCharsets.UTF_8);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename=\"libhub-statistics-" + LocalDate.now() + ".csv\"")
                .contentType(MediaType.parseMediaType("text/csv;charset=UTF-8"))
                .body(body);
    }

    private String escape(Object value) {
        String text = value == null ? "" : String.valueOf(value);
        return "\"" + text.replace("\"", "\"\"") + "\"";
    }
}
