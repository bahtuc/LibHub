package com.library.libhub.controller;

import com.library.libhub.entity.BorrowTickets;
import com.library.libhub.entity.Users;
import com.library.libhub.service.IBorrowTicketService;

import jakarta.servlet.http.HttpSession;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/borrow-tickets")
public class BorrowTicketController {

    private final IBorrowTicketService borrowTicketService;

    public BorrowTicketController(IBorrowTicketService borrowTicketService) {
        this.borrowTicketService = borrowTicketService;
    }

    @GetMapping
    public ResponseEntity<List<BorrowTickets>> getAllBorrowTickets() {
        return ResponseEntity.ok(borrowTicketService.getAllBorrowTickets());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Optional<BorrowTickets>> getBorrowTicketById(@PathVariable long id) {
        return ResponseEntity.ok(borrowTicketService.getBorrowTicketById(id));
    }

    @PostMapping
    public ResponseEntity<BorrowTickets> createBorrowTicket(@RequestBody BorrowTickets borrowTicket) {
        BorrowTickets createdBorrowTicket = borrowTicketService.createBorrowTicket(borrowTicket);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdBorrowTicket);
    }

    @PutMapping("/{id}")
    public ResponseEntity<BorrowTickets> updateBorrowTicket(@PathVariable long id, @RequestBody BorrowTickets borrowTicket) {
        BorrowTickets updatedBorrowTicket = borrowTicketService.updateBorrowTicket(id, borrowTicket);
        return ResponseEntity.ok(updatedBorrowTicket);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteBorrowTicket(@PathVariable long id) {
        borrowTicketService.deleteBorrowTicket(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<BorrowTickets>> findByUser(@PathVariable long userId) {
        return ResponseEntity.ok(borrowTicketService.findByUser(userId));
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<List<BorrowTickets>> findByStatus(@PathVariable String status) {
        return ResponseEntity.ok(borrowTicketService.findByStatus(status));
    }

    @GetMapping("/history")
    public ResponseEntity<?> getBorrowHistory(
            HttpSession session) {

        Users user =
                (Users) session.getAttribute(
                        "USER_LOGIN");

        if (user == null) {

            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body("Chưa đăng nhập");
        }

        List<BorrowTickets> tickets =
                borrowTicketService.findByUser(
                        user.getUserId());

        return ResponseEntity.ok(tickets);
    }

}
