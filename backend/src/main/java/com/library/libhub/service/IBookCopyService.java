package com.library.libhub.service;

import com.library.libhub.entity.BookCopies;
import java.util.List;
import java.util.Optional;

public interface IBookCopyService {
    BookCopies createBookCopy(BookCopies bookCopy);
    Optional<BookCopies> getBookCopyById(Long copyId);
    List<BookCopies> getAllBookCopies();
    BookCopies updateBookCopy(Long copyId, BookCopies bookCopy);
    void deleteBookCopy(Long copyId);
    Optional<BookCopies> findByBarcode(String barcode);
    List<BookCopies> findByBook(Long bookId);
    List<BookCopies> findByBookAndStatus(Long bookId, String status);
    void updateStatus(Long copyId, String status);
    BookCopies updateShelfLocation(Long copyId, String shelfLocation);
}
