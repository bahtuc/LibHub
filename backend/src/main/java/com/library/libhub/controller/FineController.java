package com.library.libhub.controller;

import com.library.libhub.entity.Fines;
import com.library.libhub.service.IFineService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/fines")
@CrossOrigin(origins = "*", maxAge = 3600)
public class FineController {

    private final IFineService fineService;

    public FineController(IFineService fineService) {
        this.fineService = fineService;
    }

    @GetMapping
    public ResponseEntity<List<Fines>> getAllFines() {
        return ResponseEntity.ok(fineService.getAllFines());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Optional<Fines>> getFineById(@PathVariable long id) {
        return ResponseEntity.ok(fineService.getFineById(id));
    }

    @PostMapping
    public ResponseEntity<Fines> createFine(@RequestBody Fines fine) {
        Fines createdFine = fineService.createFine(fine);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdFine);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Fines> updateFine(@PathVariable long id, @RequestBody Fines fine) {
        Fines updatedFine = fineService.updateFine(id, fine);
        return ResponseEntity.ok(updatedFine);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteFine(@PathVariable long id) {
        fineService.deleteFine(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/return-detail/{returnDetailId}")
    public ResponseEntity<List<Fines>> findByReturnDetail(@PathVariable long returnDetailId) {
        return ResponseEntity.ok(fineService.findByReturnDetail(returnDetailId));
    }

    @GetMapping("/paid-status/{paidStatus}")
    public ResponseEntity<List<Fines>> findByPaidStatus(@PathVariable String paidStatus) {
        return ResponseEntity.ok(fineService.findByPaidStatus(paidStatus));
    }
}
