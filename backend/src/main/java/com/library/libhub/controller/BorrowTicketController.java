package com.library.libhub.controller;

import com.library.libhub.DTO.Request.BorrowBookRequest;
import com.library.libhub.DTO.Request.BorrowTicketRequest;
import com.library.libhub.DTO.Request.UpdateBorrowStatusRequest;
import com.library.libhub.entity.BorrowTickets;
import com.library.libhub.entity.Users;
import com.library.libhub.service.IBorrowTicketService;
import com.library.libhub.service.LoanViewService;
import com.library.libhub.DTO.Response.BorrowTicketResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/api/borrow-tickets")
public class BorrowTicketController {
    private final IBorrowTicketService borrowTicketService;
    private final LoanViewService loanViewService;

    public BorrowTicketController(
            IBorrowTicketService borrowTicketService,
            LoanViewService loanViewService) {
        this.borrowTicketService = borrowTicketService;
        this.loanViewService = loanViewService;
    }

    @GetMapping
    public ResponseEntity<List<BorrowTickets>> getAllBorrowTickets() {
        return ResponseEntity.ok(borrowTicketService.getAllBorrowTickets());
    }

    @GetMapping("/views")
    public ResponseEntity<List<BorrowTicketResponse>> getBorrowTicketViews() {
        return ResponseEntity.ok(loanViewService.getAllViews());
    }

    @GetMapping("/{id}")
    public ResponseEntity<BorrowTickets> getBorrowTicketById(@PathVariable long id) {
        return ResponseEntity.of(borrowTicketService.getBorrowTicketById(id));
    }

    @PostMapping
    public ResponseEntity<BorrowTickets> createBorrowTicket(
            @RequestBody BorrowTicketRequest request,
            HttpSession session) {
        requireLibrarian(session);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(borrowTicketService.createBorrowTicketWithCopies(request));
    }

    @PostMapping("/borrow")
    public ResponseEntity<BorrowTickets> borrowBooks(@RequestBody BorrowBookRequest request, HttpSession session) {
        requireUser(session);
        throw new IllegalArgumentException("Mượn sách online phải thanh toán qua VNPay");
    }

    @PutMapping("/{id}")
    public ResponseEntity<BorrowTickets> updateBorrowTicket(
            @PathVariable long id, @RequestBody BorrowTickets ticket) {
        return ResponseEntity.ok(borrowTicketService.updateBorrowTicket(id, ticket));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<BorrowTickets> updateStatus(
            @PathVariable long id, @RequestBody UpdateBorrowStatusRequest request) {
        if (request == null) throw new IllegalArgumentException("Thiếu trạng thái");
        return ResponseEntity.ok(borrowTicketService.updateStatus(id, request.getStatus()));
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
    public ResponseEntity<List<BorrowTickets>> getBorrowHistory(HttpSession session) {
        Users user = requireUser(session);
        return ResponseEntity.ok(borrowTicketService.findByUser(user.getUserId()));
    }

    @GetMapping("/history/details")
    public ResponseEntity<List<BorrowTicketResponse>> getDetailedBorrowHistory(HttpSession session) {
        Users user = requireUser(session);
        return ResponseEntity.ok(loanViewService.getViewsForUser(user.getUserId()));
    }

    private Users requireUser(HttpSession session) {
        Users user = (Users) session.getAttribute("USER_LOGIN");
        if (user == null) throw new IllegalArgumentException("Chưa đăng nhập");
        return user;
    }

    private void requireLibrarian(HttpSession session) {
        String role = String.valueOf(session.getAttribute("ROLE"));
        if (!"Librarian".equalsIgnoreCase(role)) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Chỉ thủ thư mới được tạo phiếu và thu tiền mặt");
        }
    }
}
