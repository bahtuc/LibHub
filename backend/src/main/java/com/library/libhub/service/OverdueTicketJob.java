package com.library.libhub.service;

import com.library.libhub.dao.BorrowTicketDAO;
import jakarta.transaction.Transactional;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.sql.Date;
import java.time.LocalDate;

@Component
public class OverdueTicketJob {
    private final BorrowTicketDAO borrowTicketDAO;

    public OverdueTicketJob(BorrowTicketDAO borrowTicketDAO) {
        this.borrowTicketDAO = borrowTicketDAO;
    }

    @Scheduled(cron = "${library.overdue.cron:0 5 0 * * *}", zone = "Asia/Ho_Chi_Minh")
    @Transactional
    public void markOverdueTickets() {
        borrowTicketDAO.markOverdue(Date.valueOf(LocalDate.now()));
    }
}
