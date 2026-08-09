package com.library.libhub.service;

import java.util.List;
import java.util.Optional;

import com.library.libhub.DTO.Response.BookResponse;
import com.library.libhub.DTO.Response.PageResponse;
import com.library.libhub.entity.Books;

public interface IBookService {
    Books createBook(Books book);

    Optional<Books> getBookById(long bookId);
    Optional<Books> getBookById(long bookId, boolean includeHidden);

    List<Books> getAllBooks();

    Books updateBook(long bookId, Books book);

    void deleteBook(long bookId);

    Optional<Books> findByIsbn(String isbn);

    List<Books> findByCategory(long categoryId);

    List<Books> findByAuthor(long authorId);

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