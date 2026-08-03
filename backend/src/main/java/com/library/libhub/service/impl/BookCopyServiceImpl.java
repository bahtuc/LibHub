package com.library.libhub.service.impl;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.library.libhub.entity.BookCopies;
import com.library.libhub.exception.ResourceNotFoundException;
import com.library.libhub.repository.BookCopyRepository;
import com.library.libhub.service.IBookCopyService;

import jakarta.transaction.Transactional;

@Service
@Transactional
public class BookCopyServiceImpl implements IBookCopyService {

    private final BookCopyRepository bookCopyRepo;

    public BookCopyServiceImpl(BookCopyRepository bookCopyRepo) {
        this.bookCopyRepo = bookCopyRepo;
    }

    @Override
    public BookCopies createBookCopy(BookCopies bookCopy) {
        validate(bookCopy);
        if (bookCopyRepo.findByBarcode(bookCopy.getBarcode()).isPresent())
            throw new IllegalArgumentException("Mã vạch đã tồn tại");
        if (bookCopy.getStatus() == null || bookCopy.getStatus().isBlank()) bookCopy.setStatus("Available");
        return bookCopyRepo.save(bookCopy);
    }

    @Override
    public Optional<BookCopies> getBookCopyById(long copyId) {
        return bookCopyRepo.findById(copyId);
    }

    @Override
    public List<BookCopies> getAllBookCopies() {
        return bookCopyRepo.findAll();
    }

    @Override
    public BookCopies updateBookCopy(long copyId, BookCopies bookCopy) {
        BookCopies existing = bookCopyRepo.findById(copyId)
                .orElseThrow(() -> new ResourceNotFoundException("Book copy not found with id: " + copyId));

        // Chỉ cập nhật field được gửi lên
        if (bookCopy.getBookId() != null) existing.setBookId(bookCopy.getBookId());
        if (bookCopy.getBarcode() != null) existing.setBarcode(bookCopy.getBarcode());
        if (bookCopy.getShelfLocation() != null) existing.setShelfLocation(bookCopy.getShelfLocation());
        if (bookCopy.getStatus() != null) existing.setStatus(bookCopy.getStatus());
        if (bookCopy.getAcquiredDate() != null) existing.setAcquiredDate(bookCopy.getAcquiredDate());

        validate(existing);
        bookCopyRepo.findByBarcode(existing.getBarcode())
                .filter(other -> !other.getCopyId().equals(copyId))
                .ifPresent(other -> { throw new IllegalArgumentException("Mã vạch đã tồn tại"); });
        return bookCopyRepo.save(existing);
    }

    @Override
    public void deleteBookCopy(long copyId) {
        if (bookCopyRepo.existsById(copyId)) {
            bookCopyRepo.deleteById(copyId);
        } else {
            throw new ResourceNotFoundException("Book copy not found with id: " + copyId);
        }
    }

    @Override
    public Optional<BookCopies> findByBarcode(String barcode) {
        return bookCopyRepo.findByBarcode(barcode);
    }

    @Override
    public List<BookCopies> findByBook(long bookId) {
        return bookCopyRepo.findByBookId(bookId);
    }

    @Override
    public List<BookCopies> findByBookAndStatus(long bookId, String status) {
        return bookCopyRepo.findByBookIdAndStatus(bookId, status);
    }

    @Override
    @Transactional
    public void updateStatus(long copyId, String status) {
        if (status == null || status.isBlank()) throw new IllegalArgumentException("Trạng thái không được để trống");
        if (bookCopyRepo.updateStatus(copyId, status) == 0)
            throw new ResourceNotFoundException("Book copy not found with id: " + copyId);
    }

    private void validate(BookCopies copy) {
        if (copy == null || copy.getBookId() == null) throw new IllegalArgumentException("Thiếu bookId");
        if (copy.getBarcode() == null || copy.getBarcode().isBlank())
            throw new IllegalArgumentException("Mã vạch không được để trống");
    }

    @Override
    public BookCopies updateShelfLocation(long copyId, String shelfLocation) {
        throw new UnsupportedOperationException("Not supported yet.");
    }
}
