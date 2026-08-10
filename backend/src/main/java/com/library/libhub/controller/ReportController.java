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
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.ss.util.CellRangeAddress;

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
        csv.append("TỒN KHO SÁCH\nbook_id,title,isbn,total_copies,available_copies,unavailable_copies,hidden\n");
        for (Map<String, Object> row : statisticsService.inventory()) {
            csv.append(row.get("bookId")).append(',').append(escape(row.get("title"))).append(',')
                    .append(escape(row.get("isbn"))).append(',').append(row.get("totalCopies")).append(',')
                    .append(row.get("availableCopies")).append(',').append(row.get("unavailableCopies")).append(',')
                    .append(row.get("hidden")).append('\n');
        }
        csv.append('\n');
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

    @GetMapping(value = "/statistics.xlsx", produces = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    public ResponseEntity<byte[]> exportStatisticsXlsx() {
        try (Workbook workbook = new XSSFWorkbook(); ByteArrayOutputStream output = new ByteArrayOutputStream()) {
            CellStyle headerStyle = headerStyle(workbook);

            Sheet inventory = sheet(workbook, "Ton kho", headerStyle,
                    "book_id", "title", "isbn", "total_copies", "available_copies", "unavailable_copies", "hidden");
            for (Map<String, Object> item : statisticsService.inventory()) {
                append(inventory, item.get("bookId"), item.get("title"), item.get("isbn"), item.get("totalCopies"),
                        item.get("availableCopies"), item.get("unavailableCopies"), item.get("hidden"));
            }

            Sheet borrowed = sheet(workbook, "Dang muon", headerStyle, "book_id", "title", "borrow_count");
            for (Map<String, Object> item : statisticsService.currentlyBorrowed()) {
                append(borrowed, item.get("bookId"), item.get("title"), item.get("borrowCount"));
            }

            Sheet overdue = sheet(workbook, "Phieu qua han", headerStyle,
                    "ticket_id", "user_id", "guest_name", "borrow_date", "due_date", "status");
            for (BorrowTickets ticket : statisticsService.overdueTickets()) {
                append(overdue, ticket.getTicketId(), ticket.getUserId(), ticket.getGuestName(),
                        ticket.getBorrowDate(), ticket.getDueDate(), ticket.getStatus());
            }

            Sheet fines = sheet(workbook, "Tien phat", headerStyle, "paid_status", "fine_count", "total_amount");
            for (Map<String, Object> item : statisticsService.fineSummary()) {
                append(fines, item.get("paidStatus"), item.get("fineCount"), item.get("totalAmount"));
            }

            Sheet popular = sheet(workbook, "Sach muon nhieu", headerStyle, "book_id", "title", "borrow_count");
            for (Map<String, Object> item : statisticsService.mostBorrowed(100)) {
                append(popular, item.get("bookId"), item.get("title"), item.get("borrowCount"));
            }

            for (int index = 0; index < workbook.getNumberOfSheets(); index++) {
                Sheet current = workbook.getSheetAt(index);
                if (current.getRow(0) != null) {
                    for (int column = 0; column < current.getRow(0).getLastCellNum(); column++) {
                        current.autoSizeColumn(column);
                        current.setColumnWidth(column, Math.min(current.getColumnWidth(column) + 700, 18_000));
                    }
                }
                current.createFreezePane(0, 1);
                current.setAutoFilter(new CellRangeAddress(
                        0,
                        Math.max(0, current.getLastRowNum()),
                        0,
                        current.getRow(0).getLastCellNum() - 1));
            }

            workbook.write(output);
            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION,
                            "attachment; filename=libhub-statistics-" + LocalDate.now() + ".xlsx")
                    .contentType(MediaType.parseMediaType(
                            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                    .body(output.toByteArray());
        } catch (IOException exception) {
            throw new IllegalStateException("Không tạo được báo cáo Excel", exception);
        }
    }

    private CellStyle headerStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        style.setFont(font);
        return style;
    }

    private Sheet sheet(Workbook workbook, String name, CellStyle headerStyle, String... headers) {
        Sheet sheet = workbook.createSheet(name);
        Row row = sheet.createRow(0);
        for (int column = 0; column < headers.length; column++) {
            Cell cell = row.createCell(column);
            cell.setCellValue(headers[column]);
            cell.setCellStyle(headerStyle);
        }
        return sheet;
    }

    private void append(Sheet sheet, Object... values) {
        Row row = sheet.createRow(sheet.getLastRowNum() + 1);
        for (int column = 0; column < values.length; column++) {
            Object value = values[column];
            Cell cell = row.createCell(column);
            if (value instanceof Number number) cell.setCellValue(number.doubleValue());
            else if (value instanceof Boolean bool) cell.setCellValue(bool);
            else if (value instanceof java.util.Date date) cell.setCellValue(date);
            else if (value instanceof BigDecimal decimal) cell.setCellValue(decimal.doubleValue());
            else cell.setCellValue(value == null ? "" : String.valueOf(value));
        }
    }

    private String escape(Object value) {
        String text = value == null ? "" : String.valueOf(value);
        return "\"" + text.replace("\"", "\"\"") + "\"";
    }
}
