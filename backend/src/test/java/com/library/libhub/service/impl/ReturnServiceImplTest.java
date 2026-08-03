package com.library.libhub.service.impl;

import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.Test;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.library.libhub.DTO.Request.ReturnBookRequest;
import com.library.libhub.DTO.Request.ReturnDetailRequest;
import com.library.libhub.entity.BookCopies;
import com.library.libhub.entity.BorrowDetails;
import com.library.libhub.entity.BorrowTickets;
import com.library.libhub.entity.ReturnDetails;
import com.library.libhub.entity.Returns;
import com.library.libhub.entity.Users;
import com.library.libhub.repository.BookCopyRepository;
import com.library.libhub.repository.BorrowDetailRepository;
import com.library.libhub.repository.BorrowTicketRepository;
import com.library.libhub.repository.FineRepository;
import com.library.libhub.repository.ReturnDetailRepository;
import com.library.libhub.repository.ReturnRepository;
import com.library.libhub.repository.UserRepository;

class ReturnServiceImplTest {
    private final ReturnRepository returnRepo = mock(ReturnRepository.class);
    private final ReturnDetailRepository returnDetailRepo = mock(ReturnDetailRepository.class);
    private final BorrowTicketRepository ticketRepo = mock(BorrowTicketRepository.class);
    private final BorrowDetailRepository borrowDetailRepo = mock(BorrowDetailRepository.class);
    private final BookCopyRepository copyRepo = mock(BookCopyRepository.class);
    private final FineRepository fineRepo = mock(FineRepository.class);
    private final UserRepository userRepo = mock(UserRepository.class);
    private final ReturnServiceImpl service = new ReturnServiceImpl(returnRepo,
            returnDetailRepo,
            ticketRepo,
            borrowDetailRepo,
            copyRepo,
            fineRepo,
            userRepo);

    @Test
    void returnBooksSynchronizesStateAndCreatesCombinedFine() {
        Users staff = new Users();
        staff.setUserId(7L);
        BorrowTickets ticket = new BorrowTickets();
        ticket.setTicketId(10L);
        ticket.setUserId(3L);
        ticket.setStatus("Overdue");
        ticket.setDueDate(Date.valueOf(LocalDate.now().minusDays(2)));
        BorrowDetails borrowDetail = new BorrowDetails();
        borrowDetail.setDetailId(11L);
        borrowDetail.setTicketId(10L);
        borrowDetail.setCopyId(20L);
        borrowDetail.setBorrowStatus("Borrowed");
        BookCopies copy = new BookCopies();
        copy.setCopyId(20L);
        copy.setStatus("Borrowed");

        when(userRepo.findById(7L)).thenReturn(Optional.of(staff));
        when(ticketRepo.findById(10L)).thenReturn(Optional.of(ticket));
        when(returnRepo.findByTicketId(10L)).thenReturn(List.of());
        when(borrowDetailRepo.findByTicketIdAndCopyId(10L, 20L))
                .thenReturn(Optional.of(borrowDetail));
        when(copyRepo.findByIdForUpdate(20L)).thenReturn(Optional.of(copy));
        when(returnRepo.save(any(Returns.class))).thenAnswer(invocation -> {
            Returns record = invocation.getArgument(0);
            record.setReturnId(30L);
            return record;
        });
        when(returnDetailRepo.save(any(ReturnDetails.class))).thenAnswer(invocation -> {
            ReturnDetails detail = invocation.getArgument(0);
            detail.setReturnDetailId(40L);
            return detail;
        });
        when(borrowDetailRepo.countByTicketIdAndBorrowStatusNotIgnoreCase(10L, "Returned"))
                .thenReturn(0L);

        ReturnBookRequest request = new ReturnBookRequest();
        request.setTicketId(10L);
        ReturnDetailRequest item = new ReturnDetailRequest();
        item.setCopyId(20L);
        item.setConditionBook("Damaged");
        request.setDetails(List.of(item));

        Returns result = service.returnBooks(request, 7L);

        assertEquals(30L, result.getReturnId());
        assertEquals("Returned", ticket.getStatus());
        assertEquals("Returned", borrowDetail.getBorrowStatus());
        assertEquals("Damaged", copy.getStatus());
        verify(fineRepo).save(argThat(fine -> fine.getReturnDetailId().equals(40L)
                && fine.getAmount().compareTo(BigDecimal.valueOf(110000)) == 0
                && fine.getReason().contains("Quá hạn 2 ngày")
                && fine.getReason().contains("hư hỏng")
                && fine.getPaidStatus().equals("Unpaid")));
        verify(ticketRepo).save(ticket);
    }

    @Test
    void partialReturnKeepsTicketBorrowed() {
        Users staff = new Users();
        BorrowTickets ticket = new BorrowTickets();
        ticket.setTicketId(10L);
        ticket.setStatus("Borrowed");
        ticket.setDueDate(Date.valueOf(LocalDate.now().plusDays(2)));
        BorrowDetails detail = new BorrowDetails();
        detail.setTicketId(10L);
        detail.setCopyId(20L);
        detail.setBorrowStatus("Borrowed");
        BookCopies copy = new BookCopies();
        copy.setCopyId(20L);
        copy.setStatus("Borrowed");

        when(userRepo.findById(7L)).thenReturn(Optional.of(staff));
        when(ticketRepo.findById(10L)).thenReturn(Optional.of(ticket));
        when(returnRepo.findByTicketId(10L)).thenReturn(List.of());
        when(borrowDetailRepo.findByTicketIdAndCopyId(10L, 20L)).thenReturn(Optional.of(detail));
        when(copyRepo.findByIdForUpdate(20L)).thenReturn(Optional.of(copy));
        when(returnRepo.save(any(Returns.class))).thenAnswer(invocation -> {
            Returns record = invocation.getArgument(0);
            record.setReturnId(30L);
            return record;
        });
        when(returnDetailRepo.save(any(ReturnDetails.class))).thenAnswer(invocation -> {
            ReturnDetails returnDetail = invocation.getArgument(0);
            returnDetail.setReturnDetailId(40L);
            return returnDetail;
        });
        when(borrowDetailRepo.countByTicketIdAndBorrowStatusNotIgnoreCase(10L, "Returned"))
                .thenReturn(1L);

        ReturnDetailRequest item = new ReturnDetailRequest();
        item.setCopyId(20L);
        item.setConditionBook("Good");
        ReturnBookRequest request = new ReturnBookRequest();
        request.setTicketId(10L);
        request.setDetails(List.of(item));

        service.returnBooks(request, 7L);

        assertEquals("Borrowed", ticket.getStatus());
        assertEquals("Available", copy.getStatus());
        verify(fineRepo, never()).save(any());
    }
}
