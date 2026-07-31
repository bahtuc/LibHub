package com.library.libhub.controller;

import java.util.List;
import java.util.Optional;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.library.libhub.entity.Books;
import com.library.libhub.service.IBookService;
import jakarta.servlet.http.HttpSession;

@RestController
@RequestMapping("/api/books")
public class BookController {

    private final IBookService bookService;

    public BookController(IBookService bookService) {
        this.bookService = bookService;
    }

    @GetMapping
    public ResponseEntity<?> getAllBooks(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "title") String sortBy,
            @RequestParam(defaultValue = "asc") String sortDir,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "false") boolean includeHidden,
            HttpSession session) {

        String role = String.valueOf(session.getAttribute("ROLE"));
        boolean staffMaySeeHidden = includeHidden
                && ("Admin".equalsIgnoreCase(role) || "Librarian".equalsIgnoreCase(role));
        return ResponseEntity.ok(
                bookService.getAllBooks(
                        page,
                        size,
                        sortBy,
                        sortDir,
                        keyword,
                        staffMaySeeHidden));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Books> getBookById(@PathVariable long id, HttpSession session) {
        String role = String.valueOf(session.getAttribute("ROLE"));
        boolean includeHidden = "Admin".equalsIgnoreCase(role)
                || "Librarian".equalsIgnoreCase(role);
        return ResponseEntity.of(bookService.getBookById(id, includeHidden));
    }

    @PostMapping
    public ResponseEntity<Books> createBook(@RequestBody Books book) {
        Books createdBook = bookService.createBook(book);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdBook);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Books> updateBook(@PathVariable long id, @RequestBody Books book) {
        return ResponseEntity.ok(bookService.updateBook(id, book));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteBook(@PathVariable long id) {
        bookService.deleteBook(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/isbn/{isbn}")
    public ResponseEntity<Optional<Books>> findByIsbn(@PathVariable String isbn) {
        return ResponseEntity.ok(bookService.findByIsbn(isbn));
    }

    @GetMapping("/category/{categoryId}")
    public ResponseEntity<List<Books>> findByCategory(@PathVariable long categoryId) {
        return ResponseEntity.ok(bookService.findByCategory(categoryId));
    }

    @GetMapping("/author/{authorId}")
    public ResponseEntity<List<Books>> findByAuthor(@PathVariable long authorId) {
        return ResponseEntity.ok(bookService.findByAuthor(authorId));
    }

    @GetMapping("/search")
    public ResponseEntity<List<Books>> searchByTitle(@RequestParam String keyword) {
        return ResponseEntity.ok(bookService.searchByTitle(keyword));
    }
}
// Test Postman
// Request
// GET http://localhost:8080/api/books
// Phân trang:
// GET http://localhost:8080/api/books?page=0&size=5
// Tìm kiếm:
// GET http://localhost:8080/api/books?keyword=java
// Sắp xếp:
// GET http://localhost:8080/api/books?sortBy=title&sortDir=desc
