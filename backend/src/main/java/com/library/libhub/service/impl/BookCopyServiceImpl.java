package com.library.libhub.service.impl;

import com.library.libhub.exception.ResourceNotFoundException;

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
        validate(bookCopy);
        if (bookCopyDAO.findByBarcode(bookCopy.getBarcode()).isPresent())
            throw new IllegalArgumentException("Mã vạch đã tồn tại");
        if (bookCopy.getStatus() == null || bookCopy.getStatus().isBlank()) bookCopy.setStatus("Available");
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
        BookCopies existing = bookCopyDAO.findById(copyId)
                .orElseThrow(() -> new ResourceNotFoundException("Book copy not found with id: " + copyId));

        // Chỉ cập nhật field được gửi lên
        if (bookCopy.getBookId() != null) existing.setBookId(bookCopy.getBookId());
        if (bookCopy.getBarcode() != null) existing.setBarcode(bookCopy.getBarcode());
        if (bookCopy.getShelfLocation() != null) existing.setShelfLocation(bookCopy.getShelfLocation());
        if (bookCopy.getStatus() != null) existing.setStatus(bookCopy.getStatus());
        if (bookCopy.getAcquiredDate() != null) existing.setAcquiredDate(bookCopy.getAcquiredDate());

        validate(existing);
        bookCopyDAO.findByBarcode(existing.getBarcode())
                .filter(other -> !other.getCopyId().equals(copyId))
                .ifPresent(other -> { throw new IllegalArgumentException("Mã vạch đã tồn tại"); });
        return bookCopyDAO.save(existing);
    }

    @Override
    public void deleteBookCopy(long copyId) {
        if (bookCopyDAO.existsById(copyId)) {
            bookCopyDAO.deleteById(copyId);
        } else {
            throw new ResourceNotFoundException("Book copy not found with id: " + copyId);
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
        if (status == null || status.isBlank()) throw new IllegalArgumentException("Trạng thái không được để trống");
        if (bookCopyDAO.updateStatus(copyId, status) == 0)
            throw new ResourceNotFoundException("Book copy not found with id: " + copyId);
    }

    private void validate(BookCopies copy) {
        if (copy == null || copy.getBookId() == null) throw new IllegalArgumentException("Thiếu bookId");
        if (copy.getBarcode() == null || copy.getBarcode().isBlank())
            throw new IllegalArgumentException("Mã vạch không được để trống");
    }
}
