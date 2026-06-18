package com.library.libhub.controller;

import com.library.libhub.entity.Books;
import com.library.libhub.service.IBookService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/books")
@CrossOrigin(origins = "*", maxAge = 3600)
public class BookController {

    private final IBookService bookService;

    public BookController(IBookService bookService) {
        this.bookService = bookService;
    }

    @GetMapping
    public ResponseEntity<List<Books>> getAllBooks() {
        return ResponseEntity.ok(bookService.getAllBooks());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Optional<Books>> getBookById(@PathVariable long id) {
        return ResponseEntity.ok(bookService.getBookById(id));
    }

    @PostMapping
    public ResponseEntity<Books> createBook(@RequestBody Books book) {
        Books createdBook = bookService.createBook(book);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdBook);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Books> updateBook(@PathVariable long id, @RequestBody Books book) {
        Books updatedBook = bookService.updateBook(id, book);
        return ResponseEntity.ok(updatedBook);
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
