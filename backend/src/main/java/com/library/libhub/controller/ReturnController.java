package com.library.libhub.controller;

import com.library.libhub.DTO.Request.ReturnBookRequest;
import com.library.libhub.entity.Returns;
import com.library.libhub.entity.Users;
import com.library.libhub.service.IReturnService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/returns")
public class ReturnController {
    private final IReturnService returnService;

    public ReturnController(IReturnService returnService) {
        this.returnService = returnService;
    }

    @GetMapping
    public ResponseEntity<List<Returns>> getAllReturns() {
        return ResponseEntity.ok(returnService.getAllReturns());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Returns> getReturnById(@PathVariable long id) {
        return ResponseEntity.of(returnService.getReturnById(id));
    }

    @PostMapping
    public ResponseEntity<Returns> returnBooks(
            @RequestBody ReturnBookRequest request, HttpSession session) {
        Users staff = (Users) session.getAttribute("USER_LOGIN");
        if (staff == null) throw new IllegalArgumentException("Chưa đăng nhập");
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(returnService.returnBooks(request, staff.getUserId()));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Returns> updateReturn(@PathVariable long id, @RequestBody Returns returns) {
        return ResponseEntity.ok(returnService.updateReturn(id, returns));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReturn(@PathVariable long id) {
        returnService.deleteReturn(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/ticket/{ticketId}")
    public ResponseEntity<List<Returns>> findByTicket(@PathVariable long ticketId) {
        return ResponseEntity.ok(returnService.findByTicket(ticketId));
    }

    @GetMapping("/received-by/{receivedBy}")
    public ResponseEntity<List<Returns>> findByReceivedBy(@PathVariable long receivedBy) {
        return ResponseEntity.ok(returnService.findByReceivedBy(receivedBy));
    }
}
