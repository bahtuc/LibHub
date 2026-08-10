package com.library.libhub.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.io.ByteArrayInputStream;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.junit.jupiter.api.Test;

import com.library.libhub.service.StatisticsService;

class ReportControllerTest {

    @Test
    void excelReportContainsAllRequiredSheets() throws Exception {
        StatisticsService statistics = mock(StatisticsService.class);
        when(statistics.inventory()).thenReturn(List.of(Map.of(
                "bookId", 1L,
                "title", "Book",
                "isbn", "ISBN-1",
                "totalCopies", 3L,
                "availableCopies", 2L,
                "unavailableCopies", 1L,
                "hidden", false)));
        when(statistics.currentlyBorrowed()).thenReturn(List.of());
        when(statistics.overdueTickets()).thenReturn(List.of());
        when(statistics.fineSummary()).thenReturn(List.of(Map.of(
                "paidStatus", "Unpaid",
                "fineCount", 1L,
                "totalAmount", BigDecimal.valueOf(5000))));
        when(statistics.mostBorrowed(100)).thenReturn(List.of());

        byte[] body = new ReportController(statistics).exportStatisticsXlsx().getBody();

        assertTrue(body != null && body.length > 1_000);
        try (var workbook = WorkbookFactory.create(new ByteArrayInputStream(body))) {
            assertEquals(5, workbook.getNumberOfSheets());
            assertEquals("Ton kho", workbook.getSheetAt(0).getSheetName());
            assertEquals("Sach muon nhieu", workbook.getSheetAt(4).getSheetName());
        }
    }
}
