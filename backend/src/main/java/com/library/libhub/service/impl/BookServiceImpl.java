package com.library.libhub.service.impl;

import com.library.libhub.DTO.Response.BookResponse;
import com.library.libhub.DTO.Response.PageResponse;
import com.library.libhub.dao.BookDAO;
import com.library.libhub.entity.Books;
import com.library.libhub.repository.BookRepository;
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
    private final BookRepository bookRepository;

    public BookServiceImpl(
            BookDAO bookDAO,
            BookRepository bookRepository) {

        this.bookDAO = bookDAO;
        this.bookRepository = bookRepository;
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
        if (bookDAO.existsById(bookId)) {
            book.setBookId(bookId);
            return bookDAO.save(book);
        }
        throw new RuntimeException("Book not found with id: " + bookId);
    }

    @Override
    public void deleteBook(long bookId) {
        if (bookDAO.existsById(bookId)) {
            bookDAO.deleteById(bookId);
        } else {
            throw new RuntimeException("Book not found with id: " + bookId);
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
            booksPage = bookRepository
                    .findByTitleContainingIgnoreCase(keyword, pageable);
        } else {
            booksPage = bookRepository.findAll(pageable);
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