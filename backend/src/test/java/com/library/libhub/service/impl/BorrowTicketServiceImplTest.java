
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
                Date.valueOf("2026-08-01"));

        request.setDueDate(
                Date.valueOf("2026-08-22"));
        request.setCopyIds(
                List.of(12L));
        request.setPaymentConfirmed(true);

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
        request.setPaymentConfirmed(true);

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
        request.setPaymentConfirmed(true);

        IllegalArgumentException error = assertThrows(
                IllegalArgumentException.class,
                () -> service.createBorrowTicketWithCopies(request));

        assertTrue(error.getMessage().contains("tối đa 5 cuốn"));
        verifyNoInteractions(copyRepo);
        verifyNoInteractions(Repo);
    }

    @Test
    void librarianCannotCreateTicketBeforeBorrowFeeIsConfirmed() {
        BorrowTicketRequest request = new BorrowTicketRequest();
        request.setUserId(3L);
        request.setBorrowDate(Date.valueOf("2026-08-01"));
        request.setDueDate(Date.valueOf("2026-08-15"));
        request.setCopyIds(List.of(12L));

        IllegalArgumentException error = assertThrows(
                IllegalArgumentException.class,
                () -> service.createBorrowTicketWithCopies(request));

        assertTrue(error.getMessage().contains("xác nhận đã thu phí mượn"));
        verifyNoInteractions(copyRepo);
        verifyNoInteractions(Repo);
    }

    @Test
    void memberCanChooseBorrowDaysAndFeeMatchesDuration() {
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
        when(copyRepo.findFirstByBookIdAndStatusIgnoreCaseOrderByCopyIdAsc(9L, "Available"))
                .thenReturn(Optional.of(copy));
        when(copyRepo.findByIdForUpdate(12L)).thenReturn(Optional.of(copy));
        when(Repo.save(any(BorrowTickets.class))).thenAnswer(invocation -> {
            BorrowTickets ticket = invocation.getArgument(0);
            ticket.setTicketId(20L);
            return ticket;
        });

        BorrowTickets ticket = service.borrowBooks(3L, List.of(9L), 7);

        assertEquals(Date.valueOf(LocalDate.now().plusDays(7)), ticket.getDueDate());
        assertEquals(new BigDecimal("35000"), ticket.getDepositAmount());
        assertEquals("Paid", ticket.getDepositPaidStatus());
    }

    @Test
    void memberCannotChooseBorrowDurationOutsideAllowedRange() {
        IllegalArgumentException tooShort = assertThrows(
                IllegalArgumentException.class,
                () -> service.borrowBooks(3L, List.of(9L), 0));
        IllegalArgumentException tooLong = assertThrows(
                IllegalArgumentException.class,
                () -> service.borrowBooks(3L, List.of(9L), 31));

        assertTrue(tooShort.getMessage().contains("1 đến 30"));
        assertTrue(tooLong.getMessage().contains("1 đến 30"));
        verifyNoInteractions(userRepo, bookRepo, copyRepo, Repo);
    }

    @Test
    void onlineBorrowRemainsReservedUntilVnpayCompletes() {
        Users user = new Users();
        user.setUserId(3L);
        user.setStatus("ACTIVE");
        Books book = new Books();
        book.setBookId(9L);
        book.setTitle("Sách online");
        BookCopies copy = new BookCopies();
        copy.setCopyId(12L);
        copy.setBookId(9L);
        copy.setStatus("Available");

        when(userRepo.findByIdForUpdate(3L)).thenReturn(Optional.of(user));
        when(bookRepo.findById(9L)).thenReturn(Optional.of(book));
        when(detailRepo.existsActiveBorrow(3L, 9L)).thenReturn(false);
        when(copyRepo.findFirstByBookIdAndStatusIgnoreCaseOrderByCopyIdAsc(9L, "Available"))
                .thenReturn(Optional.of(copy));
        when(copyRepo.findByIdForUpdate(12L)).thenReturn(Optional.of(copy));
        when(Repo.save(any(BorrowTickets.class))).thenAnswer(invocation -> {
            BorrowTickets ticket = invocation.getArgument(0);
            ticket.setTicketId(20L);
            return ticket;
        });

        BorrowTickets ticket = service.createOnlineBorrow(3L, List.of(9L), 7);

        assertEquals("PendingPayment", ticket.getStatus());
        assertEquals("Unpaid", ticket.getDepositPaidStatus());
        assertEquals(new BigDecimal("35000"), ticket.getDepositAmount());
        assertEquals("PendingPayment", copy.getStatus());

        BorrowDetails detail = new BorrowDetails();
        detail.setTicketId(20L);
        detail.setCopyId(12L);
        detail.setBorrowStatus("PendingPayment");
        when(Repo.findByIdForUpdate(20L)).thenReturn(Optional.of(ticket));
        when(detailRepo.findByTicketId(20L)).thenReturn(List.of(detail));

        BorrowTickets paidTicket = service.completeOnlinePayment(20L);

        assertEquals("Borrowed", paidTicket.getStatus());
        assertEquals("Paid", paidTicket.getDepositPaidStatus());
        assertEquals("Borrowed", detail.getBorrowStatus());
        assertEquals("Borrowed", copy.getStatus());
    }

    @Test
    void failedOnlinePaymentCancelsTicketAndReleasesCopy() {
        BorrowTickets ticket = ticket();
        ticket.setTicketId(20L);
        ticket.setStatus("PendingPayment");
        ticket.setDepositPaidStatus("Unpaid");
        BorrowDetails detail = new BorrowDetails();
        detail.setTicketId(20L);
        detail.setCopyId(12L);
        detail.setBorrowStatus("PendingPayment");
        BookCopies copy = new BookCopies();
        copy.setCopyId(12L);
        copy.setStatus("PendingPayment");

        when(Repo.findByIdForUpdate(20L)).thenReturn(Optional.of(ticket));
        when(detailRepo.findByTicketId(20L)).thenReturn(List.of(detail));
        when(copyRepo.findByIdForUpdate(12L)).thenReturn(Optional.of(copy));
        when(Repo.save(ticket)).thenReturn(ticket);

        BorrowTickets cancelled = service.cancelOnlinePayment(20L);

        assertEquals("Cancelled", cancelled.getStatus());
        assertEquals("Cancelled", detail.getBorrowStatus());
        assertEquals("Available", copy.getStatus());
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

    @Test
    void memberCanRenewOwnBorrowedTicket() {
        BorrowTickets existing = ticket();
        existing.setTicketId(7L);
        existing.setUserId(3L);
        existing.setStatus("Borrowed");
        existing.setDepositPaidStatus("Paid");
        existing.setRenewalCount(0);
        Date oldDueDate = existing.getDueDate();

        when(Repo.findByIdForUpdate(7L)).thenReturn(Optional.of(existing));
        when(Repo.save(existing)).thenReturn(existing);

        BorrowTickets renewed = service.renewBorrowTicket(7L, 3L, false, 7);

        assertEquals(Date.valueOf(oldDueDate.toLocalDate().plusDays(7)), renewed.getDueDate());
        assertEquals(1, renewed.getRenewalCount());
        assertNotNull(renewed.getLastRenewedAt());
        verify(Repo).save(existing);
    }

    @Test
    void memberCannotRenewAnotherUsersTicket() {
        BorrowTickets existing = ticket();
        existing.setTicketId(7L);
        existing.setUserId(4L);
        existing.setStatus("Borrowed");
        existing.setDepositPaidStatus("Paid");
        when(Repo.findByIdForUpdate(7L)).thenReturn(Optional.of(existing));

        IllegalArgumentException error = assertThrows(
                IllegalArgumentException.class,
                () -> service.renewBorrowTicket(7L, 3L, false, 7));

        assertTrue(error.getMessage().contains("không có quyền"));
        verify(Repo, never()).save(any());
    }

    @Test
    void overdueTicketCannotBeRenewed() {
        BorrowTickets existing = ticket();
        existing.setTicketId(7L);
        existing.setUserId(3L);
        existing.setStatus("Borrowed");
        existing.setDepositPaidStatus("Paid");
        existing.setDueDate(Date.valueOf(LocalDate.now().minusDays(1)));
        when(Repo.findByIdForUpdate(7L)).thenReturn(Optional.of(existing));

        IllegalArgumentException error = assertThrows(
                IllegalArgumentException.class,
                () -> service.renewBorrowTicket(7L, 3L, false, 7));

        assertTrue(error.getMessage().contains("quá hạn"));
        verify(Repo, never()).save(any());
    }

    @Test
    void ticketCannotBeRenewedMoreThanTwice() {
        BorrowTickets existing = ticket();
        existing.setTicketId(7L);
        existing.setUserId(3L);
        existing.setStatus("Borrowed");
        existing.setDepositPaidStatus("Paid");
        existing.setRenewalCount(2);
        when(Repo.findByIdForUpdate(7L)).thenReturn(Optional.of(existing));

        IllegalArgumentException error = assertThrows(
                IllegalArgumentException.class,
                () -> service.renewBorrowTicket(7L, 3L, false, 7));

        assertTrue(error.getMessage().contains("hết 2 lượt"));
        verify(Repo, never()).save(any());
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
