package com.library.libhub.controller;

import com.library.libhub.entity.BorrowDetails;
import com.library.libhub.service.IBorrowDetailService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/borrow-details")
@CrossOrigin(origins = "*", maxAge = 3600)
public class BorrowDetailController {

    private final IBorrowDetailService borrowDetailService;

    public BorrowDetailController(IBorrowDetailService borrowDetailService) {
        this.borrowDetailService = borrowDetailService;
    }

    @GetMapping
    public ResponseEntity<List<BorrowDetails>> getAllBorrowDetails() {
        return ResponseEntity.ok(borrowDetailService.getAllBorrowDetails());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Optional<BorrowDetails>> getBorrowDetailById(@PathVariable long id) {
        return ResponseEntity.ok(borrowDetailService.getBorrowDetailById(id));
    }

    @PostMapping
    public ResponseEntity<BorrowDetails> createBorrowDetail(@RequestBody BorrowDetails borrowDetail) {
        BorrowDetails createdBorrowDetail = borrowDetailService.createBorrowDetail(borrowDetail);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdBorrowDetail);
    }

    @PutMapping("/{id}")
    public ResponseEntity<BorrowDetails> updateBorrowDetail(@PathVariable long id, @RequestBody BorrowDetails borrowDetail) {
        BorrowDetails updatedBorrowDetail = borrowDetailService.updateBorrowDetail(id, borrowDetail);
        return ResponseEntity.ok(updatedBorrowDetail);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteBorrowDetail(@PathVariable long id) {
        borrowDetailService.deleteBorrowDetail(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/ticket/{ticketId}")
    public ResponseEntity<List<BorrowDetails>> findByTicket(@PathVariable long ticketId) {
        return ResponseEntity.ok(borrowDetailService.findByTicket(ticketId));
    }

    @GetMapping("/copy/{copyId}")
    public ResponseEntity<List<BorrowDetails>> findByCopy(@PathVariable long copyId) {
        return ResponseEntity.ok(borrowDetailService.findByCopy(copyId));
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<List<BorrowDetails>> findByStatus(@PathVariable String status) {
        return ResponseEntity.ok(borrowDetailService.findByStatus(status));
    }
}
