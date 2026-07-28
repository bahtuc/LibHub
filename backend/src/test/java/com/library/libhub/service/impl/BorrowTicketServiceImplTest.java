package com.library.libhub.service.impl;

import com.library.libhub.dao.BookCopyDAO;
import com.library.libhub.dao.BookDAO;
import com.library.libhub.dao.BorrowDetailDAO;
import com.library.libhub.dao.BorrowTicketDAO;
import com.library.libhub.dao.UserDAO;
import com.library.libhub.entity.BookCopies;
import com.library.libhub.entity.Books;
import com.library.libhub.entity.BorrowDetails;
import com.library.libhub.entity.BorrowTickets;
import com.library.libhub.entity.Users;
import org.junit.jupiter.api.Test;

import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class BorrowTicketServiceImplTest {

    private final BorrowTicketDAO dao = mock(BorrowTicketDAO.class);
    private final BorrowDetailDAO detailDAO = mock(BorrowDetailDAO.class);
    private final BookCopyDAO copyDAO = mock(BookCopyDAO.class);
    private final BookDAO bookDAO = mock(BookDAO.class);
    private final UserDAO userDAO = mock(UserDAO.class);
    private final BorrowTicketServiceImpl service = new BorrowTicketServiceImpl(
            dao, detailDAO, copyDAO, bookDAO, userDAO);

    @Test
    void createRejectsDueDateBeforeBorrowDate() {
        BorrowTickets ticket = ticket();
        ticket.setDueDate(Date.valueOf(LocalDate.now().minusDays(1)));
        assertThrows(IllegalArgumentException.class, () -> service.createBorrowTicket(ticket));
        verifyNoInteractions(dao);
    }

    @Test
    void createSetsDefaults() {
        BorrowTickets ticket = ticket();
        when(dao.save(ticket)).thenReturn(ticket);
        service.createBorrowTicket(ticket);
        assertEquals("Borrowed", ticket.getStatus());
        assertNotNull(ticket.getCreatedAt());
        verify(dao).save(ticket);
    }

    @Test
    void updatePreservesFieldsMissingFromPatch() {
        BorrowTickets existing = ticket();
        existing.setTicketId(7L);
        existing.setNote("keep");
        existing.setCreatedAt(new Timestamp(1));
        BorrowTickets patch = new BorrowTickets();
        patch.setStatus("Returned");
        when(dao.findById(7L)).thenReturn(Optional.of(existing));
        when(dao.save(existing)).thenReturn(existing);

        BorrowTickets result = service.updateBorrowTicket(7L, patch);

        assertEquals("Returned", result.getStatus());
        assertEquals("keep", result.getNote());
        assertEquals(1L, result.getCreatedAt().getTime());
    }

    @Test
    void borrowBookCreatesTicketDetailAndMarksCopyBorrowed() {
        Users user = new Users();
        user.setUserId(3L);
        user.setStatus("ACTIVE");
        Books book = new Books();
        book.setBookId(9L);
        book.setTitle("Dế Mèn phiêu lưu ký");
        BookCopies copy = new BookCopies();
        copy.setCopyId(12L);
        copy.setBookId(9L);
        copy.setStatus("Available");

        when(userDAO.findByIdForUpdate(3L)).thenReturn(Optional.of(user));
        when(bookDAO.findById(9L)).thenReturn(Optional.of(book));
        when(detailDAO.existsActiveBorrow(3L, 9L)).thenReturn(false);
        when(copyDAO.findFirstByBookIdAndStatusIgnoreCaseOrderByCopyIdAsc(
                9L, "Available")).thenReturn(Optional.of(copy));
        when(dao.save(any(BorrowTickets.class))).thenAnswer(invocation -> {
            BorrowTickets ticket = invocation.getArgument(0);
            ticket.setTicketId(20L);
            return ticket;
        });

        BorrowTickets ticket = service.borrowBook(3L, 9L);

        assertEquals(3L, ticket.getUserId());
        assertEquals("Borrowed", ticket.getStatus());
        assertEquals(Date.valueOf(LocalDate.now().plusDays(14)), ticket.getDueDate());
        assertTrue(ticket.getNote().contains("Dế Mèn phiêu lưu ký"));
        assertEquals("Borrowed", copy.getStatus());
        verify(detailDAO).save(argThat(detail ->
                detail.getTicketId().equals(20L)
                        && detail.getCopyId().equals(12L)
                        && detail.getBorrowStatus().equals("Borrowed")));
        verify(copyDAO).save(copy);
    }

    @Test
    void borrowBookRejectsDuplicateActiveLoanBeforeLockingCopy() {
        Users user = new Users();
        user.setStatus("ACTIVE");
        Books book = new Books();
        book.setBookId(9L);
        book.setTitle("Book");

        when(userDAO.findByIdForUpdate(3L)).thenReturn(Optional.of(user));
        when(bookDAO.findById(9L)).thenReturn(Optional.of(book));
        when(detailDAO.existsActiveBorrow(3L, 9L)).thenReturn(true);

        assertThrows(IllegalArgumentException.class,
                () -> service.borrowBook(3L, 9L));
        verify(copyDAO, never())
                .findFirstByBookIdAndStatusIgnoreCaseOrderByCopyIdAsc(
                        anyLong(), anyString());
        verify(dao, never()).save(any());
    }

    @Test
    void borrowBookRejectsWhenNoCopyIsAvailable() {
        Users user = new Users();
        user.setStatus("ACTIVE");
        Books book = new Books();
        book.setBookId(9L);
        book.setTitle("Book");

        when(userDAO.findByIdForUpdate(3L)).thenReturn(Optional.of(user));
        when(bookDAO.findById(9L)).thenReturn(Optional.of(book));
        when(copyDAO.findFirstByBookIdAndStatusIgnoreCaseOrderByCopyIdAsc(
                9L, "Available")).thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class,
                () -> service.borrowBook(3L, 9L));
        verify(dao, never()).save(any());
        verify(detailDAO, never()).save(any(BorrowDetails.class));
    }

    private BorrowTickets ticket() {
        BorrowTickets ticket = new BorrowTickets();
        ticket.setUserId(1L);
        ticket.setBorrowDate(Date.valueOf(LocalDate.now()));
        ticket.setDueDate(Date.valueOf(LocalDate.now().plusDays(14)));
        return ticket;
    }
}
