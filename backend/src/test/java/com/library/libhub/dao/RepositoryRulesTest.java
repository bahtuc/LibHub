package com.library.libhub.dao;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.data.domain.PageRequest;

import com.library.libhub.entity.BookCopies;
import com.library.libhub.entity.Books;
import com.library.libhub.entity.BorrowDetails;
import com.library.libhub.entity.BorrowTickets;
import com.library.libhub.repository.BookCopyRepository;
import com.library.libhub.repository.BookRepository;
import com.library.libhub.repository.BorrowDetailRepository;
import com.library.libhub.repository.BorrowTicketRepository;

@DataJpaTest
class RepositoryRulesTest {
    @Autowired
    private BookRepository bookRepo;
    @Autowired
    private BookCopyRepository copyRepo;
    @Autowired
    private BorrowTicketRepository ticketRepo;
    @Autowired
    private BorrowDetailRepository detailRepo;

    @Test
    void legacyNullHiddenFlagStillCountsAsVisible() {
        Books legacyBook = new Books();
        legacyBook.setTitle("Legacy visible book");
        legacyBook.setHidden(null);
        bookRepo.saveAndFlush(legacyBook);

        assertTrue(bookRepo.findByHiddenFalse(PageRequest.of(0, 20))
                .stream()
                .anyMatch(book -> book.getBookId().equals(legacyBook.getBookId())));
        assertTrue(bookRepo.findByBookIdAndHiddenFalse(legacyBook.getBookId()).isPresent());
    }

    @Test
    void cancelledTicketDoesNotBlockBorrowingTheSameBookAgain() {
        Books book = new Books();
        book.setTitle("Borrowable after cancellation");
        book = bookRepo.saveAndFlush(book);

        BookCopies copy = new BookCopies();
        copy.setBookId(book.getBookId());
        copy.setBarcode("TEST-CANCELLED-COPY");
        copy.setStatus("Available");
        copy = copyRepo.saveAndFlush(copy);

        BorrowTickets cancelled = new BorrowTickets();
        cancelled.setUserId(42L);
        cancelled.setStatus("Cancelled");
        cancelled = ticketRepo.saveAndFlush(cancelled);

        BorrowDetails cancelledDetail = new BorrowDetails();
        cancelledDetail.setTicketId(cancelled.getTicketId());
        cancelledDetail.setCopyId(copy.getCopyId());
        cancelledDetail.setBorrowStatus("Borrowed");
        detailRepo.saveAndFlush(cancelledDetail);

        assertFalse(detailRepo.existsActiveBorrow(42L, book.getBookId()));

        BorrowTickets active = new BorrowTickets();
        active.setUserId(43L);
        active.setStatus("Borrowed");
        active = ticketRepo.saveAndFlush(active);

        BorrowDetails activeDetail = new BorrowDetails();
        activeDetail.setTicketId(active.getTicketId());
        activeDetail.setCopyId(copy.getCopyId());
        activeDetail.setBorrowStatus("Borrowed");
        detailRepo.saveAndFlush(activeDetail);

        assertTrue(detailRepo.existsActiveBorrow(43L, book.getBookId()));
    }
}
