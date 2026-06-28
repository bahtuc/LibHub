package com.library.libhub.service.impl;

import com.library.libhub.exception.ResourceNotFoundException;

import com.library.libhub.DTO.Response.BookResponse;
import com.library.libhub.DTO.Response.PageResponse;
import com.library.libhub.dao.BookDAO;
import com.library.libhub.entity.Books;
import com.library.libhub.service.IBookService;

import jakarta.transaction.Transactional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class BookServiceImpl implements IBookService {

    private final BookDAO bookDAO;

    public BookServiceImpl(BookDAO bookDAO) {
        this.bookDAO = bookDAO;
    }

    @Override
    public Books createBook(Books book) {
        return bookDAO.save(book);
    }

    @Override
    public Optional<Books> getBookById(long bookId) {
        return bookDAO.findById(bookId);
    }

    @Override
    public List<Books> getAllBooks() {
        return bookDAO.findAll();
    }

    @Override
    public Books updateBook(long bookId, Books book) {
        Books existing = bookDAO.findById(bookId)
                .orElseThrow(() -> new ResourceNotFoundException("Book not found with id: " + bookId));

        // Chỉ cập nhật field được gửi lên; giữ nguyên createdAt
        if (book.getTitle() != null) existing.setTitle(book.getTitle());
        if (book.getIsbn() != null) existing.setIsbn(book.getIsbn());
        if (book.getPublishYear() != null) existing.setPublishYear(book.getPublishYear());
        if (book.getDescription() != null) existing.setDescription(book.getDescription());
        if (book.getCoverImage() != null) existing.setCoverImage(book.getCoverImage());
        if (book.getLanguage() != null) existing.setLanguage(book.getLanguage());
        if (book.getPages() != null) existing.setPages(book.getPages());
        if (book.getCategoryId() != null) existing.setCategoryId(book.getCategoryId());
        if (book.getAuthorId() != null) existing.setAuthorId(book.getAuthorId());
        if (book.getPublisherId() != null) existing.setPublisherId(book.getPublisherId());

        return bookDAO.save(existing);
    }

    @Override
    public void deleteBook(long bookId) {
        if (bookDAO.existsById(bookId)) {
            bookDAO.deleteById(bookId);
        } else {
            throw new ResourceNotFoundException("Book not found with id: " + bookId);
        }
    }

    @Override
    public Optional<Books> findByIsbn(String isbn) {
        return bookDAO.findByIsbn(isbn);
    }

    @Override
    public List<Books> findByCategory(long categoryId) {
        return bookDAO.findByCategoryId(categoryId);
    }

    @Override
    public List<Books> findByAuthor(long authorId) {
        return bookDAO.findByAuthorId(authorId);
    }

    @Override
    public List<Books> searchByTitle(String keyword) {
        return bookDAO.findByTitleContainingIgnoreCase(keyword);
    }

    @Override
    public PageResponse<BookResponse> getAllBooks(
            int page,
            int size,
            String sortBy,
            String sortDir,
            String keyword) {

        Sort sort = sortDir.equalsIgnoreCase("desc")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);

        Page<Books> booksPage;

        if (keyword != null && !keyword.isBlank()) {
            booksPage = bookDAO
                    .findByTitleContainingIgnoreCase(keyword, pageable);
        } else {
            booksPage = bookDAO.findAll(pageable);
        }

        List<BookResponse> content = booksPage.getContent()
                .stream()
                .map(this::convertToResponse)
                .toList();

        PageResponse<BookResponse> response = new PageResponse<>();

        response.setContent(content);
        response.setPage(page);
        response.setSize(size);
        response.setTotalElements(booksPage.getTotalElements());
        response.setTotalPages(booksPage.getTotalPages());

        return response;
    }

    private BookResponse convertToResponse(Books book) {

        BookResponse response = new BookResponse();

        // Sửa lại theo entity thực tế của bạn
        response.setBookId(book.getBookId());
        response.setTitle(book.getTitle());
        response.setIsbn(book.getIsbn());

        return response;
    }
}