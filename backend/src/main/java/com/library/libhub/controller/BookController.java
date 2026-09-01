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
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;

import com.library.libhub.entity.Books;
import com.library.libhub.service.IBookService;
import com.library.libhub.service.BookImportService;
import com.library.libhub.service.BookCoverStorageService;
import com.library.libhub.DTO.Response.BookImportResponse;
import jakarta.servlet.http.HttpSession;

@RestController
@RequestMapping("/api/books")
public class BookController {

    private final IBookService bookService;
    private final BookImportService bookImportService;
    private final BookCoverStorageService coverStorage;

    public BookController(IBookService bookService, BookImportService bookImportService,
            BookCoverStorageService coverStorage) {
        this.bookService = bookService;
        this.bookImportService = bookImportService;
        this.coverStorage = coverStorage;
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

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Books> createBook(
            @RequestPart("book") Books book,
            @RequestPart(value = "cover", required = false) MultipartFile cover) {
        String coverPath = coverStorage.save(cover);
        book.setCoverImage(coverPath);
        try {
            return ResponseEntity.status(HttpStatus.CREATED).body(bookService.createBook(book));
        } catch (RuntimeException ex) {
            coverStorage.delete(coverPath);
            throw ex;
        }
    }

    @PostMapping(value = "/import", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<BookImportResponse> importBooks(@RequestPart("file") MultipartFile file) {
        return ResponseEntity.ok(bookImportService.importBooks(file));
    }

    @GetMapping("/import/template.csv")
    public ResponseEntity<byte[]> downloadCsvTemplate() {
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=libhub-book-import-template.csv")
                .contentType(MediaType.parseMediaType("text/csv;charset=UTF-8"))
                .body(bookImportService.csvTemplate());
    }

    @GetMapping("/import/template.xlsx")
    public ResponseEntity<byte[]> downloadXlsxTemplate() {
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=libhub-book-import-template.xlsx")
                .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                .body(bookImportService.xlsxTemplate());
    }

    @PutMapping(value = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Books> updateBook(
            @PathVariable long id,
            @RequestPart("book") Books book,
            @RequestPart(value = "cover", required = false) MultipartFile cover) {
        String oldCover = bookService.getBookById(id)
                .map(Books::getCoverImage)
                .orElse(null);
        String newCover = coverStorage.save(cover);
        if (newCover != null) {
            book.setCoverImage(newCover);
        } else {
            book.setCoverImage(null);
        }
        try {
            Books updated = bookService.updateBook(id, book);
            if (newCover != null) {
                coverStorage.delete(oldCover);
            }
            return ResponseEntity.ok(updated);
        } catch (RuntimeException ex) {
            coverStorage.delete(newCover);
            throw ex;
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteBook(@PathVariable long id) {
        String coverPath = bookService.getBookById(id)
                .map(Books::getCoverImage)
                .orElse(null);
        bookService.deleteBook(id);
        coverStorage.delete(coverPath);
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
