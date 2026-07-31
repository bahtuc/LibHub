package com.library.libhub.controller;

import com.library.libhub.entity.BookCopies;
import com.library.libhub.service.IBookCopyService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;
import java.util.Map;

@RestController
@RequestMapping("/api/book-copies")
public class BookCopyController {

    private final IBookCopyService bookCopyService;

    public BookCopyController(IBookCopyService bookCopyService) {
        this.bookCopyService = bookCopyService;
    }

    @GetMapping
    public ResponseEntity<List<BookCopies>> getAllBookCopies() {
        return ResponseEntity.ok(bookCopyService.getAllBookCopies());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Optional<BookCopies>> getBookCopyById(@PathVariable long id) {
        return ResponseEntity.ok(bookCopyService.getBookCopyById(id));
    }

    @PostMapping
    public ResponseEntity<BookCopies> createBookCopy(@RequestBody BookCopies bookCopy) {
        BookCopies createdBookCopy = bookCopyService.createBookCopy(bookCopy);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdBookCopy);
    }

    @PutMapping("/{id}")
    public ResponseEntity<BookCopies> updateBookCopy(@PathVariable long id, @RequestBody BookCopies bookCopy) {
        BookCopies updatedBookCopy = bookCopyService.updateBookCopy(id, bookCopy);
        return ResponseEntity.ok(updatedBookCopy);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteBookCopy(@PathVariable long id) {
        bookCopyService.deleteBookCopy(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/barcode/{barcode}")
    public ResponseEntity<Optional<BookCopies>> findByBarcode(@PathVariable String barcode) {
        return ResponseEntity.ok(bookCopyService.findByBarcode(barcode));
    }

    @GetMapping("/book/{bookId}")
    public ResponseEntity<List<BookCopies>> findByBook(@PathVariable long bookId) {
        return ResponseEntity.ok(bookCopyService.findByBook(bookId));
    }

    @GetMapping("/book/{bookId}/status/{status}")
    public ResponseEntity<List<BookCopies>> findByBookAndStatus(@PathVariable long bookId, @PathVariable String status) {
        return ResponseEntity.ok(bookCopyService.findByBookAndStatus(bookId, status));
    }

    @PutMapping("/{id}/status/{status}")
    public ResponseEntity<Void> updateStatus(@PathVariable long id, @PathVariable String status) {
        bookCopyService.updateStatus(id, status);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/shelf-location")
    public ResponseEntity<BookCopies> updateShelfLocation(
            @PathVariable long id, @RequestBody Map<String, String> body) {
        String shelfLocation = body == null ? null : body.get("shelfLocation");
        return ResponseEntity.ok(bookCopyService.updateShelfLocation(id, shelfLocation));
    }
}
