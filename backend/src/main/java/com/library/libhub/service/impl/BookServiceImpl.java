package com.library.libhub.service.impl;

import java.sql.Timestamp;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import com.library.libhub.DTO.Response.BookResponse;
import com.library.libhub.DTO.Response.PageResponse;
import com.library.libhub.entity.Books;
import com.library.libhub.exception.ResourceNotFoundException;
import com.library.libhub.repository.BookCopyRepository;
import com.library.libhub.repository.BookRepository;
import com.library.libhub.service.IBookService;

import jakarta.transaction.Transactional;

@Service
@Transactional
public class BookServiceImpl implements IBookService {

    private static final Set<String> SORT_FIELDS = Set.of("bookId", "title", "isbn", "publishYear", "createdAt");

    private final BookRepository bookRepo;
    private final BookCopyRepository bookCopyRepo;

    public BookServiceImpl(BookRepository bookRepo, BookCopyRepository bookCopyRepo) {
        this.bookRepo = bookRepo;
        this.bookCopyRepo = bookCopyRepo;
    }

    @Override
    public Books createBook(Books book) {
        validateBook(book);
        if (book.getCreatedAt() == null)
            book.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        return bookRepo.save(book);
    }

    @Override
    public Optional<Books> getBookById(long bookId) {
        return bookRepo.findById(bookId);
    }

    @Override
    public List<Books> getAllBooks() {
        return bookRepo.findAll();
    }

    @Override
    public Books updateBook(long bookId, Books book) {
        Books existing = bookRepo.findById(bookId)
                .orElseThrow(() -> new ResourceNotFoundException("Book not found with id: " + bookId));

        // Chỉ cập nhật field được gửi lên; giữ nguyên createdAt
        if (book.getTitle() != null)
            existing.setTitle(book.getTitle());
        if (book.getIsbn() != null)
            existing.setIsbn(book.getIsbn());
        if (book.getPublishYear() != null)
            existing.setPublishYear(book.getPublishYear());
        if (book.getDescription() != null)
            existing.setDescription(book.getDescription());
        if (book.getCoverImage() != null)
            existing.setCoverImage(book.getCoverImage());
        if (book.getLanguage() != null)
            existing.setLanguage(book.getLanguage());
        if (book.getPages() != null)
            existing.setPages(book.getPages());
        if (book.getCategoryId() != null)
            existing.setCategoryId(book.getCategoryId());
        if (book.getAuthorId() != null)
            existing.setAuthorId(book.getAuthorId());
        if (book.getPublisherId() != null)
            existing.setPublisherId(book.getPublisherId());
        if (book.getHidden() != null)
            existing.setHidden(book.getHidden());
        if (book.getFeatured() != null)
            existing.setFeatured(book.getFeatured());

        validateBook(existing);

        return bookRepo.save(existing);
    }

    @Override
    public void deleteBook(long bookId) {
        if (bookRepo.existsById(bookId)) {
            bookRepo.deleteById(bookId);
        } else {
            throw new ResourceNotFoundException("Book not found with id: " + bookId);
        }
    }

    @Override
    public Optional<Books> findByIsbn(String isbn) {
        return bookRepo.findByIsbn(isbn);
    }

    @Override
    public List<Books> findByCategory(long categoryId) {
        return bookRepo.findByCategoryId(categoryId);
    }

    @Override
    public List<Books> findByAuthor(long authorId) {
        return bookRepo.findByAuthorId(authorId);
    }

    @Override
    public List<Books> searchByTitle(String keyword) {
        return bookRepo.findByTitleContainingIgnoreCase(keyword);
    }

    @Override
    public PageResponse<BookResponse> getAllBooks(
            int page,
            int size,
            String sortBy,
            String sortDir,
            String keyword) {

        if (page < 0)
            throw new IllegalArgumentException("Số trang không hợp lệ");
        if (size < 1 || size > 1000)
            throw new IllegalArgumentException("Kích thước trang phải từ 1 đến 1000");
        if (!SORT_FIELDS.contains(sortBy))
            throw new IllegalArgumentException("Trường sắp xếp không hợp lệ");

        Sort sort = sortDir.equalsIgnoreCase("desc")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);

        Page<Books> booksPage;

        if (keyword != null && !keyword.isBlank()) {
            booksPage = bookRepo
                    .findByTitleContainingIgnoreCase(keyword, pageable);
        } else {
            booksPage = bookRepo.findAll(pageable);
        }

        List<BookResponse> content = convertToResponses(booksPage.getContent());

        PageResponse<BookResponse> response = new PageResponse<>();

        response.setContent(content);
        response.setPage(page);
        response.setSize(size);
        response.setTotalElements(booksPage.getTotalElements());
        response.setTotalPages(booksPage.getTotalPages());

        return response;
    }

    private void validateBook(Books book) {
        if (book == null || book.getTitle() == null || book.getTitle().isBlank())
            throw new IllegalArgumentException("Tên sách không được để trống");
        if (book.getPages() != null && book.getPages() <= 0)
            throw new IllegalArgumentException("Số trang phải lớn hơn 0");
        if (book.getPublishYear() != null && (book.getPublishYear() < 0 || book.getPublishYear() > 9999))
            throw new IllegalArgumentException("Năm xuất bản không hợp lệ");
    }

    private List<BookResponse> convertToResponses(List<Books> books) {
        if (books.isEmpty()) {
            return List.of();
        }

        List<Long> bookIds = books.stream()
                .map(Books::getBookId)
                .filter(id -> id != null)
                .toList();

        Map<Long, BookCopyRepository.BookAvailability> availabilityByBook = bookIds.isEmpty()
                ? Map.of()
                : bookCopyRepo.summarizeAvailability(bookIds).stream()
                        .collect(Collectors.toMap(
                                BookCopyRepository.BookAvailability::getBookId,
                                Function.identity()));

        return books.stream()
                .map(book -> convertToResponse(book, availabilityByBook.get(book.getBookId())))
                .toList();
    }

    private BookResponse convertToResponse(
            Books book,
            BookCopyRepository.BookAvailability availability) {

        BookResponse response = new BookResponse();

        // Sửa lại theo entity thực tế của bạn
        response.setBookId(book.getBookId());
        response.setTitle(book.getTitle());
        response.setIsbn(book.getIsbn());
        response.setDescription(book.getDescription());
        response.setPublishYear(book.getPublishYear());
        response.setCoverImage(book.getCoverImage());
        response.setLanguage(book.getLanguage());
        response.setPages(book.getPages());
        response.setAuthorId(book.getAuthorId());
        response.setCategoryId(book.getCategoryId());
        response.setPublisherId(book.getPublisherId());
        response.setHidden(book.getHidden());
        response.setFeatured(book.getFeatured());
        response.setTotalCopies(availability == null ? 0L : availability.getTotalCopies());
        response.setAvailableCopies(availability == null ? 0L : availability.getAvailableCopies());

        return response;
    }

    @Override
    public Optional<Books> getBookById(long bookId, boolean includeHidden) {

        Optional<Books> book = bookRepo.findById(bookId);

        if (book.isEmpty()) {
            return Optional.empty();
        }

        if (!includeHidden && Boolean.TRUE.equals(book.get().getHidden())) {
            return Optional.empty();
        }

        return book;
    }

    @Override
    public PageResponse<BookResponse> getAllBooks(
            int page,
            int size,
            String sortBy,
            String sortDir,
            String keyword,
            boolean includeHidden) {

        if (page < 0)
            throw new IllegalArgumentException("Số trang không hợp lệ");

        if (size < 1 || size > 1000)
            throw new IllegalArgumentException("Kích thước trang phải từ 1 đến 1000");

        if (!SORT_FIELDS.contains(sortBy))
            throw new IllegalArgumentException("Trường sắp xếp không hợp lệ");

        Sort sort = sortDir.equalsIgnoreCase("desc")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);

        Page<Books> booksPage;

        if (keyword != null && !keyword.isBlank()) {

            booksPage = bookRepo.findByTitleContainingIgnoreCase(keyword, pageable);

        } else {

            booksPage = bookRepo.findAll(pageable);
        }

        List<Books> visibleBooks = booksPage.getContent()
                .stream()

                // nếu không được xem sách ẩn thì loại bỏ
                .filter(book -> includeHidden || !Boolean.TRUE.equals(book.getHidden()))
                .toList();

        List<BookResponse> content = convertToResponses(visibleBooks);

        PageResponse<BookResponse> response = new PageResponse<>();

        response.setContent(content);
        response.setPage(page);
        response.setSize(size);
        response.setTotalElements(includeHidden
                ? booksPage.getTotalElements()
                : content.size());

        response.setTotalPages(booksPage.getTotalPages());

        return response;
    }

}
