package com.library.libhub.service.impl;

import com.library.libhub.dao.BorrowTicketDAO;
import com.library.libhub.entity.BorrowTickets;
import org.junit.jupiter.api.Test;

import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class BorrowTicketServiceImplTest {

    private final BorrowTicketDAO dao = mock(BorrowTicketDAO.class);
    private final BorrowTicketServiceImpl service = new BorrowTicketServiceImpl(dao);

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

    private BorrowTickets ticket() {
        BorrowTickets ticket = new BorrowTickets();
        ticket.setUserId(1L);
        ticket.setBorrowDate(Date.valueOf(LocalDate.now()));
        ticket.setDueDate(Date.valueOf(LocalDate.now().plusDays(14)));
        return ticket;
    }
}
