package com.library.libhub.service;

import com.library.libhub.entity.BookCopies;
import java.util.List;
import java.util.Optional;

public interface IBookCopyService {
    BookCopies createBookCopy(BookCopies bookCopy);
    Optional<BookCopies> getBookCopyById(long copyId);
    List<BookCopies> getAllBookCopies();
    BookCopies updateBookCopy(long copyId, BookCopies bookCopy);
    void deleteBookCopy(long copyId);
    Optional<BookCopies> findByBarcode(String barcode);
    List<BookCopies> findByBook(long bookId);
    List<BookCopies> findByBookAndStatus(long bookId, String status);
    void updateStatus(long copyId, String status);
    BookCopies updateShelfLocation(long copyId, String shelfLocation);
}
