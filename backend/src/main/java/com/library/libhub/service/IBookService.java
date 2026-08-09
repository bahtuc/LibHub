package com.library.libhub.service;

import java.util.List;
import java.util.Optional;

import com.library.libhub.DTO.Response.BookResponse;
import com.library.libhub.DTO.Response.PageResponse;
import com.library.libhub.entity.Books;

public interface IBookService {
    Books createBook(Books book);

    Optional<Books> getBookById(Long bookId);
    Optional<Books> getBookById(Long bookId, boolean includeHidden);

    List<Books> getAllBooks();

    Books updateBook(Long bookId, Books book);

    void deleteBook(Long bookId);

    Optional<Books> findByIsbn(String isbn);

    List<Books> findByCategory(Long categoryId);

    List<Books> findByAuthor(Long authorId);

    List<Books> searchByTitle(String keyword);

    PageResponse<BookResponse> getAllBooks(
        int page,
        int size,
        String sortBy,
        String sortDir,
        String keyword);

    PageResponse<BookResponse> getAllBooks(
        int page, int size, String sortBy, String sortDir, String keyword, boolean includeHidden);
}
