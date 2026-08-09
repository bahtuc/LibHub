package com.library.libhub.controller;

import com.library.libhub.entity.ReturnDetails;
import com.library.libhub.service.IReturnDetailService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/return-details")
public class ReturnDetailController {

    private final IReturnDetailService returnDetailService;

    public ReturnDetailController(IReturnDetailService returnDetailService) {
        this.returnDetailService = returnDetailService;
    }

    @GetMapping
    public ResponseEntity<List<ReturnDetails>> getAllReturnDetails() {
        return ResponseEntity.ok(returnDetailService.getAllReturnDetails());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Optional<ReturnDetails>> getReturnDetailById(@PathVariable Long id) {
        return ResponseEntity.ok(returnDetailService.getReturnDetailById(id));
    }

    @PostMapping
    public ResponseEntity<ReturnDetails> createReturnDetail(@RequestBody ReturnDetails returnDetail) {
        ReturnDetails createdReturnDetail = returnDetailService.createReturnDetail(returnDetail);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdReturnDetail);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ReturnDetails> updateReturnDetail(@PathVariable Long id, @RequestBody ReturnDetails returnDetail) {
        ReturnDetails updatedReturnDetail = returnDetailService.updateReturnDetail(id, returnDetail);
        return ResponseEntity.ok(updatedReturnDetail);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReturnDetail(@PathVariable Long id) {
        returnDetailService.deleteReturnDetail(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/return/{returnId}")
    public ResponseEntity<List<ReturnDetails>> findByReturn(@PathVariable Long returnId) {
        return ResponseEntity.ok(returnDetailService.findByReturn(returnId));
    }

    @GetMapping("/copy/{copyId}")
    public ResponseEntity<List<ReturnDetails>> findByCopy(@PathVariable Long copyId) {
        return ResponseEntity.ok(returnDetailService.findByCopy(copyId));
    }

    @GetMapping("/condition/{condition}")
    public ResponseEntity<List<ReturnDetails>> findByCondition(@PathVariable String condition) {
        return ResponseEntity.ok(returnDetailService.findByCondition(condition));
    }
}
