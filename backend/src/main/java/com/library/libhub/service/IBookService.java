package com.library.libhub.service;

import com.library.libhub.entity.Books;
import java.util.List;
import java.util.Optional;

public interface IBookService {
    Books createBook(Books book);
    Optional<Books> getBookById(long bookId);
    List<Books> getAllBooks();
    Books updateBook(long bookId, Books book);
    void deleteBook(long bookId);
    Optional<Books> findByIsbn(String isbn);
    List<Books> findByCategory(long categoryId);
    List<Books> findByAuthor(long authorId);
    List<Books> searchByTitle(String keyword);
}
