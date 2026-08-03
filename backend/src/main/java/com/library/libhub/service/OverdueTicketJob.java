package com.library.libhub.service;


import jakarta.transaction.Transactional;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.sql.Date;
import java.time.LocalDate;

import com.library.libhub.repository.BorrowTicketRepository;

@Component
public class OverdueTicketJob {
    private final BorrowTicketRepository borrowTicketRepo;

    public OverdueTicketJob(BorrowTicketRepository borrowTicketRepo) {
        this.borrowTicketRepo = borrowTicketRepo;
    }

    @Scheduled(cron = "${library.overdue.cron:0 5 0 * * *}", zone = "Asia/Ho_Chi_Minh")
    @Transactional
    public void markOverdueTickets() {
        borrowTicketRepo.markOverdue(Date.valueOf(LocalDate.now()));
    }
}
