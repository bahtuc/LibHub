package com.library.libhub.service.impl;

import com.library.libhub.DTO.Request.ReturnBookRequest;
import com.library.libhub.DTO.Request.ReturnDetailRequest;
import com.library.libhub.dao.*;
import com.library.libhub.entity.*;
import org.junit.jupiter.api.Test;

import java.sql.Date;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class ReturnServiceImplTest {
    private final ReturnDAO returnDAO = mock(ReturnDAO.class);
    private final ReturnDetailDAO returnDetailDAO = mock(ReturnDetailDAO.class);
    private final BorrowTicketDAO ticketDAO = mock(BorrowTicketDAO.class);
    private final BorrowDetailDAO borrowDetailDAO = mock(BorrowDetailDAO.class);
    private final BookCopyDAO copyDAO = mock(BookCopyDAO.class);
    private final FineDAO fineDAO = mock(FineDAO.class);
    private final UserDAO userDAO = mock(UserDAO.class);
    private final ReturnServiceImpl service = new ReturnServiceImpl(
            returnDAO, returnDetailDAO, ticketDAO, borrowDetailDAO, copyDAO,
            fineDAO, userDAO, 5000, 100000, 300000);

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

        when(userDAO.findById(7L)).thenReturn(Optional.of(staff));
        when(ticketDAO.findById(10L)).thenReturn(Optional.of(ticket));
        when(returnDAO.findByTicketId(10L)).thenReturn(List.of());
        when(borrowDetailDAO.findByTicketIdAndCopyId(10L, 20L))
                .thenReturn(Optional.of(borrowDetail));
        when(copyDAO.findByIdForUpdate(20L)).thenReturn(Optional.of(copy));
        when(returnDAO.save(any(Returns.class))).thenAnswer(invocation -> {
            Returns record = invocation.getArgument(0);
            record.setReturnId(30L);
            return record;
        });
        when(returnDetailDAO.save(any(ReturnDetails.class))).thenAnswer(invocation -> {
            ReturnDetails detail = invocation.getArgument(0);
            detail.setReturnDetailId(40L);
            return detail;
        });
        when(borrowDetailDAO.countByTicketIdAndBorrowStatusNotIgnoreCase(10L, "Returned"))
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
        verify(fineDAO).save(argThat(fine ->
                fine.getReturnDetailId().equals(40L)
                        && fine.getAmount().equals(110000d)
                        && fine.getReason().contains("Quá hạn 2 ngày")
                        && fine.getReason().contains("hư hỏng")
                        && fine.getPaidStatus().equals("Unpaid")));
        verify(ticketDAO).save(ticket);
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

        when(userDAO.findById(7L)).thenReturn(Optional.of(staff));
        when(ticketDAO.findById(10L)).thenReturn(Optional.of(ticket));
        when(returnDAO.findByTicketId(10L)).thenReturn(List.of());
        when(borrowDetailDAO.findByTicketIdAndCopyId(10L, 20L)).thenReturn(Optional.of(detail));
        when(copyDAO.findByIdForUpdate(20L)).thenReturn(Optional.of(copy));
        when(returnDAO.save(any(Returns.class))).thenAnswer(invocation -> {
            Returns record = invocation.getArgument(0);
            record.setReturnId(30L);
            return record;
        });
        when(returnDetailDAO.save(any(ReturnDetails.class))).thenAnswer(invocation -> {
            ReturnDetails returnDetail = invocation.getArgument(0);
            returnDetail.setReturnDetailId(40L);
            return returnDetail;
        });
        when(borrowDetailDAO.countByTicketIdAndBorrowStatusNotIgnoreCase(10L, "Returned"))
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
        verify(fineDAO, never()).save(any());
    }
}
