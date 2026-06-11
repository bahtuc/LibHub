package com.library.libhub.service.impl;

import com.library.libhub.dao.BookDAO;
import com.library.libhub.entity.Books;
import com.library.libhub.service.IBookService;
import jakarta.transaction.Transactional;
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
}
