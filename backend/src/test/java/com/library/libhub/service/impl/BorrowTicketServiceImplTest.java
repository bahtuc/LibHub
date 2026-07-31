package com.library.libhub.service.impl;

import com.library.libhub.entity.BookCopies;
import com.library.libhub.entity.Books;
import com.library.libhub.entity.BorrowDetails;
import com.library.libhub.entity.BorrowTickets;
import com.library.libhub.entity.Users;
import com.library.libhub.repository.BookCopyRepository;
import com.library.libhub.repository.BookRepository;
import com.library.libhub.repository.BorrowDetailRepository;
import com.library.libhub.repository.BorrowTicketRepository;
import com.library.libhub.repository.UserRepository;

import org.junit.jupiter.api.Test;

import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.Mockito.*;

class BorrowTicketServiceImplTest {

    private final BorrowTicketRepository Repo = mock(BorrowTicketRepository.class);
    private final BorrowDetailRepository detailRepo = mock(BorrowDetailRepository.class);
    private final BookCopyRepository copyRepo = mock(BookCopyRepository.class);
    private final BookRepository bookRepo = mock(BookRepository.class);
    private final UserRepository userRepo = mock(UserRepository.class);
    private final BorrowTicketServiceImpl service = new BorrowTicketServiceImpl(
            Repo, detailRepo, copyRepo, bookRepo, userRepo);

    @Test
    void createRejectsDueDateBeforeBorrowDate() {
        BorrowTickets ticket = ticket();
        ticket.setDueDate(Date.valueOf(LocalDate.now().minusDays(1)));
        assertThrows(IllegalArgumentException.class, () -> service.createBorrowTicket(ticket));
        verifyNoInteractions(Repo);
    }

    @Test
    void createSetsDefaults() {
        BorrowTickets ticket = ticket();
        when(Repo.save(ticket)).thenReturn(ticket);
        service.createBorrowTicket(ticket);
        assertEquals("Borrowed", ticket.getStatus());
        assertNotNull(ticket.getCreatedAt());
        verify(Repo).save(ticket);
    }

    @Test
    void updatePreservesFieldsMissingFromPatch() {
        BorrowTickets existing = ticket();
        existing.setTicketId(7L);
        existing.setNote("keep");
        existing.setCreatedAt(new Timestamp(1));
        BorrowTickets patch = new BorrowTickets();
        patch.setStatus("Returned");
        when(Repo.findById(7L)).thenReturn(Optional.of(existing));
        when(Repo.save(existing)).thenReturn(existing);

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

        when(userRepo.findByIdForUpdate(3L)).thenReturn(Optional.of(user));
        when(bookRepo.findById(9L)).thenReturn(Optional.of(book));
        when(detailRepo.existsActiveBorrow(3L, 9L)).thenReturn(false);
        when(copyRepo.findFirstByBookIdAndStatusIgnoreCaseOrderByCopyIdAsc(
                9L, "Available")).thenReturn(Optional.of(copy));
        when(Repo.save(any(BorrowTickets.class))).thenAnswer(invocation -> {
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
        verify(detailRepo).save(argThat(detail ->
                detail.getTicketId().equals(20L)
                        && detail.getCopyId().equals(12L)
                        && detail.getBorrowStatus().equals("Borrowed")));
        verify(copyRepo).save(copy);
    }

    @Test
    void borrowBookRejectsDuplicateActiveLoanBeforeLockingCopy() {
        Users user = new Users();
        user.setStatus("ACTIVE");
        Books book = new Books();
        book.setBookId(9L);
        book.setTitle("Book");

        when(userRepo.findByIdForUpdate(3L)).thenReturn(Optional.of(user));
        when(bookRepo.findById(9L)).thenReturn(Optional.of(book));
        when(detailRepo.existsActiveBorrow(3L, 9L)).thenReturn(true);

        assertThrows(IllegalArgumentException.class,
                () -> service.borrowBook(3L, 9L));
        verify(copyRepo, never())
                .findFirstByBookIdAndStatusIgnoreCaseOrderByCopyIdAsc(
                        anyLong(), anyString());
        verify(Repo, never()).save(any());
    }

    @Test
    void borrowBookRejectsWhenNoCopyIsAvailable() {
        Users user = new Users();
        user.setStatus("ACTIVE");
        Books book = new Books();
        book.setBookId(9L);
        book.setTitle("Book");

        when(userRepo.findByIdForUpdate(3L)).thenReturn(Optional.of(user));
        when(bookRepo.findById(9L)).thenReturn(Optional.of(book));
        when(copyRepo.findFirstByBookIdAndStatusIgnoreCaseOrderByCopyIdAsc(
                9L, "Available")).thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class,
                () -> service.borrowBook(3L, 9L));
        verify(Repo, never()).save(any());
        verify(detailRepo, never()).save(any(BorrowDetails.class));
    }

    private BorrowTickets ticket() {
        BorrowTickets ticket = new BorrowTickets();
        ticket.setUserId(1L);
        ticket.setBorrowDate(Date.valueOf(LocalDate.now()));
        ticket.setDueDate(Date.valueOf(LocalDate.now().plusDays(14)));
        return ticket;
    }
}
