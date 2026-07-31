package com.library.libhub.dao;

import com.library.libhub.entity.BookCopies;
import com.library.libhub.entity.Books;
import com.library.libhub.entity.BorrowDetails;
import com.library.libhub.entity.BorrowTickets;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.data.domain.PageRequest;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

@DataJpaTest
class RepositoryRulesTest {
    @Autowired
    private BookDAO bookDAO;
    @Autowired
    private BookCopyDAO copyDAO;
    @Autowired
    private BorrowTicketDAO ticketDAO;
    @Autowired
    private BorrowDetailDAO detailDAO;

    @Test
    void legacyNullHiddenFlagStillCountsAsVisible() {
        Books legacyBook = new Books();
        legacyBook.setTitle("Legacy visible book");
        legacyBook.setHidden(null);
        bookDAO.saveAndFlush(legacyBook);

        assertTrue(bookDAO.findByHiddenFalse(PageRequest.of(0, 20))
                .stream()
                .anyMatch(book -> book.getBookId().equals(legacyBook.getBookId())));
        assertTrue(bookDAO.findByBookIdAndHiddenFalse(legacyBook.getBookId()).isPresent());
    }

    @Test
    void cancelledTicketDoesNotBlockBorrowingTheSameBookAgain() {
        Books book = new Books();
        book.setTitle("Borrowable after cancellation");
        book = bookDAO.saveAndFlush(book);

        BookCopies copy = new BookCopies();
        copy.setBookId(book.getBookId());
        copy.setBarcode("TEST-CANCELLED-COPY");
        copy.setStatus("Available");
        copy = copyDAO.saveAndFlush(copy);

        BorrowTickets cancelled = new BorrowTickets();
        cancelled.setUserId(42L);
        cancelled.setStatus("Cancelled");
        cancelled = ticketDAO.saveAndFlush(cancelled);

        BorrowDetails cancelledDetail = new BorrowDetails();
        cancelledDetail.setTicketId(cancelled.getTicketId());
        cancelledDetail.setCopyId(copy.getCopyId());
        cancelledDetail.setBorrowStatus("Borrowed");
        detailDAO.saveAndFlush(cancelledDetail);

        assertFalse(detailDAO.existsActiveBorrow(42L, book.getBookId()));

        BorrowTickets active = new BorrowTickets();
        active.setUserId(43L);
        active.setStatus("Borrowed");
        active = ticketDAO.saveAndFlush(active);

        BorrowDetails activeDetail = new BorrowDetails();
        activeDetail.setTicketId(active.getTicketId());
        activeDetail.setCopyId(copy.getCopyId());
        activeDetail.setBorrowStatus("Borrowed");
        detailDAO.saveAndFlush(activeDetail);

        assertTrue(detailDAO.existsActiveBorrow(43L, book.getBookId()));
    }
}
