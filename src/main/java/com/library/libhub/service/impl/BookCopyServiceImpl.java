package com.library.libhub.service.impl;

import com.library.libhub.dao.BookCopyDAO;
import com.library.libhub.entity.BookCopies;
import com.library.libhub.service.IBookCopyService;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class BookCopyServiceImpl implements IBookCopyService {

    private final BookCopyDAO bookCopyDAO;

    public BookCopyServiceImpl(BookCopyDAO bookCopyDAO) {
        this.bookCopyDAO = bookCopyDAO;
    }

    @Override
    public BookCopies createBookCopy(BookCopies bookCopy) {
        return bookCopyDAO.save(bookCopy);
    }

    @Override
    public Optional<BookCopies> getBookCopyById(long copyId) {
        return bookCopyDAO.findById(copyId);
    }

    @Override
    public List<BookCopies> getAllBookCopies() {
        return bookCopyDAO.findAll();
    }

    @Override
    public BookCopies updateBookCopy(long copyId, BookCopies bookCopy) {
        if (bookCopyDAO.existsById(copyId)) {
            bookCopy.setCopyId(copyId);
            return bookCopyDAO.save(bookCopy);
        }
        throw new RuntimeException("Book copy not found with id: " + copyId);
    }

    @Override
    public void deleteBookCopy(long copyId) {
        if (bookCopyDAO.existsById(copyId)) {
            bookCopyDAO.deleteById(copyId);
        } else {
            throw new RuntimeException("Book copy not found with id: " + copyId);
        }
    }

    @Override
    public Optional<BookCopies> findByBarcode(String barcode) {
        return bookCopyDAO.findByBarcode(barcode);
    }

    @Override
    public List<BookCopies> findByBook(long bookId) {
        return bookCopyDAO.findByBookId(bookId);
    }

    @Override
    public List<BookCopies> findByBookAndStatus(long bookId, String status) {
        return bookCopyDAO.findByBookIdAndStatus(bookId, status);
    }

    @Override
    @Transactional
    public void updateStatus(long copyId, String status) {
        bookCopyDAO.updateStatus(copyId, status);
    }
}
