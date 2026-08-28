
package com.library.libhub.service.impl;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import org.junit.jupiter.api.Test;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import com.library.libhub.DTO.Request.BorrowTicketRequest;
import com.library.libhub.entity.BookCopies;
import com.library.libhub.entity.Books;
import com.library.libhub.entity.BorrowDetails;
import com.library.libhub.entity.BorrowTickets;
import com.library.libhub.entity.Users;
import com.library.libhub.repository.BookCopyRepository;
import com.library.libhub.repository.BookRepository;
import com.library.libhub.repository.BorrowDetailRepository;
import com.library.libhub.repository.BorrowTicketRepository;
import com.library.libhub.repository.ReturnRepository;
import com.library.libhub.repository.UserRepository;

class BorrowTicketServiceImplTest {

    private final BorrowTicketRepository Repo = mock(BorrowTicketRepository.class);

    private final BorrowDetailRepository detailRepo = mock(BorrowDetailRepository.class);

    private final BookCopyRepository copyRepo = mock(BookCopyRepository.class);

    private final BookRepository bookRepo = mock(BookRepository.class);

    private final UserRepository userRepo = mock(UserRepository.class);

    private final ReturnRepository returnRepo = mock(ReturnRepository.class);

    private final BorrowTicketServiceImpl service = new BorrowTicketServiceImpl(
            Repo,
            detailRepo,
            copyRepo,
            bookRepo,
            userRepo,
            returnRepo);

    @Test
    void createRejectsDueDateBeforeBorrowDate() {

        BorrowTickets ticket = ticket();

        ticket.setDueDate(
                Date.valueOf(LocalDate.now().minusDays(1)));

        assertThrows(
                IllegalArgumentException.class,
                () -> service.createBorrowTicket(ticket));

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

        when(Repo.findById(7L))
                .thenReturn(Optional.of(existing));

        when(Repo.save(existing))
                .thenReturn(existing);

        BorrowTickets result = service.updateBorrowTicket(7L, patch);

        assertEquals("Returned", result.getStatus());
        assertEquals("keep", result.getNote());
        assertEquals(
                1L,
                result.getCreatedAt().getTime());
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

        when(userRepo.findByIdForUpdate(3L))
                .thenReturn(Optional.of(user));

        when(bookRepo.findById(9L))
                .thenReturn(Optional.of(book));

        when(detailRepo.existsActiveBorrow(3L, 9L))
                .thenReturn(false);

        when(copyRepo
                .findFirstByBookIdAndStatusIgnoreCaseOrderByCopyIdAsc(
                        9L,
                        "Available"))
                .thenReturn(Optional.of(copy));

        when(Repo.save(any(BorrowTickets.class)))
                .thenAnswer(invocation -> {

                    BorrowTickets ticket = invocation.getArgument(0);

                    ticket.setTicketId(20L);

                    return ticket;
                });

        BorrowTickets ticket = service.borrowBook(3L, 9L);

        assertEquals(3L, ticket.getUserId());
        assertEquals("Borrowed", ticket.getStatus());

        assertEquals(
                Date.valueOf(
                        LocalDate.now().plusDays(14)),
                ticket.getDueDate());

        assertTrue(
                ticket.getNote()
                        .contains("Dế Mèn phiêu lưu ký"));

        assertEquals(
                "Borrowed",
                copy.getStatus());

        verify(detailRepo).save(
                argThat(detail -> detail.getTicketId().equals(20L)
                        && detail.getCopyId().equals(12L)
                        && detail.getBorrowStatus()
                                .equals("Borrowed")));

        verify(copyRepo).save(copy);
    }

    @Test
    void borrowBookRejectsDuplicateActiveLoanBeforeLockingCopy() {

        Users user = new Users();
        user.setStatus("ACTIVE");

        Books book = new Books();
        book.setBookId(9L);
        book.setTitle("Book");

        when(userRepo.findByIdForUpdate(3L))
                .thenReturn(Optional.of(user));

        when(bookRepo.findById(9L))
                .thenReturn(Optional.of(book));

        when(detailRepo.existsActiveBorrow(3L, 9L))
                .thenReturn(true);

        assertThrows(
                IllegalArgumentException.class,
                () -> service.borrowBook(3L, 9L));

        verify(
                copyRepo,
                never()).findFirstByBookIdAndStatusIgnoreCaseOrderByCopyIdAsc(
                        anyLong(),
                        anyString());

        verify(
                Repo,
                never()).save(any());
    }

    @Test
    void borrowBookRejectsWhenNoCopyIsAvailable() {

        Users user = new Users();
        user.setStatus("ACTIVE");

        Books book = new Books();
        book.setBookId(9L);
        book.setTitle("Book");

        when(userRepo.findByIdForUpdate(3L))
                .thenReturn(Optional.of(user));

        when(bookRepo.findById(9L))
                .thenReturn(Optional.of(book));

        when(copyRepo
                .findFirstByBookIdAndStatusIgnoreCaseOrderByCopyIdAsc(
                        9L,
                        "Available"))
                .thenReturn(Optional.empty());

        assertThrows(
                IllegalArgumentException.class,
                () -> service.borrowBook(3L, 9L));

        verify(
                Repo,
                never()).save(any());

        verify(
                detailRepo,
                never()).save(any(BorrowDetails.class));
    }

    @Test
    void borrowBookRejectsMemberWhoAlreadyHasFiveActiveLoans() {
        Users user = new Users();
        user.setStatus("ACTIVE");

        when(userRepo.findByIdForUpdate(3L)).thenReturn(Optional.of(user));
        when(detailRepo.countActiveBorrowsByUserId(3L)).thenReturn(5L);

        IllegalArgumentException error = assertThrows(
                IllegalArgumentException.class,
                () -> service.borrowBook(3L, 9L));

        assertTrue(error.getMessage().contains("tối đa 5 cuốn"));
        verifyNoInteractions(bookRepo);
        verifyNoInteractions(copyRepo);
    }

    @Test
    void adminCreateTicketCreatesDetailsAndMarksExactCopiesBorrowed() {

        Users user = new Users();
        user.setStatus("ACTIVE");

        BookCopies copy = new BookCopies();
        copy.setCopyId(12L);
        copy.setBookId(9L);
        copy.setStatus("Available");

        Books book = new Books();
        book.setBookId(9L);

        BorrowTicketRequest request = new BorrowTicketRequest();

        request.setUserId(3L);
        request.setBorrowDate(
                Date.valueOf("2026-08-08"));
        request.setBorrowDate(
                Date.valueOf("2026-08-01"));

        request.setDueDate(
                Date.valueOf("2026-08-22"));
        request.setCopyIds(
                List.of(12L));

        when(userRepo.findByIdForUpdate(3L))
                .thenReturn(Optional.of(user));

        when(copyRepo.findByIdForUpdate(12L))
                .thenReturn(Optional.of(copy));

        when(bookRepo.findById(9L))
                .thenReturn(Optional.of(book));

        when(Repo.save(any(BorrowTickets.class)))
                .thenAnswer(invocation -> {

                    BorrowTickets saved = invocation.getArgument(0);

                    saved.setTicketId(20L);

                    return saved;
                });

        BorrowTickets result = service.createBorrowTicketWithCopies(request);

        assertEquals(
                20L,
                result.getTicketId());

        assertEquals(
                "Borrowed",
                result.getStatus());

        assertEquals(
                "Borrowed",
                copy.getStatus());

        verify(detailRepo).save(
                argThat(detail -> detail.getTicketId().equals(20L)
                        && detail.getCopyId().equals(12L)));

        verify(copyRepo).save(copy);
    }

    @Test
    void librarianCanCreateTicketForGuestWithoutUserAccount() {

        BookCopies copy = new BookCopies();
        copy.setCopyId(12L);
        copy.setBookId(9L);
        copy.setStatus("Available");

        Books book = new Books();
        book.setBookId(9L);

        BorrowTicketRequest request = new BorrowTicketRequest();

        request.setGuestName("Nguyen Van Guest");
        request.setGuestPhone("0901234567");
        request.setBorrowDate(Date.valueOf("2026-08-01"));
        request.setDueDate(
                Date.valueOf("2026-08-22"));
        request.setCopyIds(
                List.of(12L));

        when(copyRepo.findByIdForUpdate(12L))
                .thenReturn(Optional.of(copy));

        when(bookRepo.findById(9L))
                .thenReturn(Optional.of(book));

        when(Repo.save(any(BorrowTickets.class)))
                .thenAnswer(invocation -> {

                    BorrowTickets saved = invocation.getArgument(0);

                    saved.setTicketId(21L);

                    return saved;
                });

        BorrowTickets result = service.createBorrowTicketWithCopies(request);

        assertNull(result.getUserId());

        assertEquals(
                "Nguyen Van Guest",
                result.getGuestName());

        assertEquals(
                "0901234567",
                result.getGuestPhone());

        assertEquals(BigDecimal.valueOf(105000), result.getDepositAmount());
        assertEquals("Paid", result.getDepositPaidStatus());

        assertEquals(
                Date.valueOf("2026-08-01"),
                result.getBorrowDate());

        verifyNoInteractions(userRepo);
    }

    @Test
    void librarianCannotCreateGuestTicketWithMoreThanFiveCopies() {
        BorrowTicketRequest request = new BorrowTicketRequest();
        request.setGuestName("Guest");
        request.setDueDate(Date.valueOf("2026-08-22"));
        request.setCopyIds(List.of(1L, 2L, 3L, 4L, 5L, 6L));

        IllegalArgumentException error = assertThrows(
                IllegalArgumentException.class,
                () -> service.createBorrowTicketWithCopies(request));

        assertTrue(error.getMessage().contains("tối đa 5 cuốn"));
        verifyNoInteractions(copyRepo);
        verifyNoInteractions(Repo);
    }

    @Test
    void updateStatusNormalizesSupportedValue() {

        BorrowTickets existing = ticket();

        existing.setTicketId(7L);

        when(Repo.findById(7L))
                .thenReturn(Optional.of(existing));

        when(Repo.save(existing))
                .thenReturn(existing);

        BorrowTickets result = service.updateStatus(
                7L,
                "overdue");

        assertEquals(
                "Overdue",
                result.getStatus());
    }

    private BorrowTickets ticket() {

        BorrowTickets ticket = new BorrowTickets();

        ticket.setUserId(1L);

        ticket.setBorrowDate(
                Date.valueOf(LocalDate.now()));

        ticket.setDueDate(
                Date.valueOf(
                        LocalDate.now().plusDays(14)));

        return ticket;
    }
}
