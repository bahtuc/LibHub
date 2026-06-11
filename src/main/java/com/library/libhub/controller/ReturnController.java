package com.library.libhub.controller;

import com.library.libhub.entity.Returns;
import com.library.libhub.service.IReturnService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/returns")
@CrossOrigin(origins = "*", maxAge = 3600)
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
    public ResponseEntity<Optional<Returns>> getReturnById(@PathVariable long id) {
        return ResponseEntity.ok(returnService.getReturnById(id));
    }

    @PostMapping
    public ResponseEntity<Returns> createReturn(@RequestBody Returns returns) {
        Returns createdReturn = returnService.createReturn(returns);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdReturn);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Returns> updateReturn(@PathVariable long id, @RequestBody Returns returns) {
        Returns updatedReturn = returnService.updateReturn(id, returns);
        return ResponseEntity.ok(updatedReturn);
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
