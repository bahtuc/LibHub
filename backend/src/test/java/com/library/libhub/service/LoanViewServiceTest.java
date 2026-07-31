package com.library.libhub.service;

import com.library.libhub.DTO.Response.BorrowTicketResponse;
import com.library.libhub.dao.BookCopyDAO;
import com.library.libhub.dao.BookDAO;
import com.library.libhub.dao.BorrowDetailDAO;
import com.library.libhub.dao.BorrowTicketDAO;
import com.library.libhub.dao.FineDAO;
import com.library.libhub.dao.ReturnDAO;
import com.library.libhub.dao.ReturnDetailDAO;
import com.library.libhub.dao.UserDAO;
import com.library.libhub.entity.BookCopies;
import com.library.libhub.entity.Books;
import com.library.libhub.entity.BorrowDetails;
import com.library.libhub.entity.BorrowTickets;
import com.library.libhub.entity.Fines;
import com.library.libhub.entity.ReturnDetails;
import com.library.libhub.entity.Returns;
import com.library.libhub.entity.Users;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.sql.Date;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class LoanViewServiceTest {
    @Mock private BorrowTicketDAO ticketDAO;
    @Mock private BorrowDetailDAO detailDAO;
    @Mock private BookCopyDAO copyDAO;
    @Mock private BookDAO bookDAO;
    @Mock private UserDAO userDAO;
    @Mock private ReturnDAO returnDAO;
    @Mock private ReturnDetailDAO returnDetailDAO;
    @Mock private FineDAO fineDAO;

    private LoanViewService service;

    @BeforeEach
    void setUp() {
        service = new LoanViewService(
                ticketDAO,
                detailDAO,
                copyDAO,
                bookDAO,
                userDAO,
                returnDAO,
                returnDetailDAO,
                fineDAO);
    }

    @Test
    void buildsOneDetailedViewAcrossLoanReturnAndFineTables() {
        BorrowTickets ticket = new BorrowTickets();
        ticket.setTicketId(10L);
        ticket.setUserId(20L);
        ticket.setBorrowDate(Date.valueOf("2026-07-01"));
        ticket.setDueDate(Date.valueOf("2026-07-15"));
        ticket.setStatus("Returned");

        BorrowDetails detail = new BorrowDetails();
        detail.setDetailId(30L);
        detail.setTicketId(10L);
        detail.setCopyId(40L);
        detail.setBorrowStatus("Returned");

        BookCopies copy = new BookCopies();
        copy.setCopyId(40L);
        copy.setBookId(50L);
        copy.setBarcode("LIB-0050");

        Books book = new Books();
        book.setBookId(50L);
        book.setTitle("Đắc nhân tâm");

        Users user = new Users();
        user.setUserId(20L);
        user.setUsername("member");
        user.setFullName("Bạn đọc");

        Returns returned = new Returns();
        returned.setReturnId(60L);
        returned.setTicketId(10L);
        returned.setReturnDate(Date.valueOf("2026-07-18"));

        ReturnDetails returnDetail = new ReturnDetails();
        returnDetail.setReturnDetailId(70L);
        returnDetail.setReturnId(60L);
        returnDetail.setCopyId(40L);
        returnDetail.setConditionBook("Damaged");

        Fines fine = new Fines();
        fine.setFineId(80L);
        fine.setReturnDetailId(70L);
        fine.setAmount(120000D);
        fine.setReason("Bồi thường sách bị hư hỏng");
        fine.setPaidStatus("Unpaid");

        when(ticketDAO.findAll()).thenReturn(List.of(ticket));
        when(detailDAO.findAll()).thenReturn(List.of(detail));
        when(copyDAO.findAll()).thenReturn(List.of(copy));
        when(bookDAO.findAll()).thenReturn(List.of(book));
        when(userDAO.findAll()).thenReturn(List.of(user));
        when(returnDAO.findAll()).thenReturn(List.of(returned));
        when(returnDetailDAO.findAll()).thenReturn(List.of(returnDetail));
        when(fineDAO.findAll()).thenReturn(List.of(fine));

        BorrowTicketResponse view = service.getAllViews().getFirst();

        assertEquals(10L, view.getTicketId());
        assertEquals("Bạn đọc", view.getUserName());
        assertEquals("Đắc nhân tâm", view.getItems().getFirst().getBookTitle());
        assertEquals(Date.valueOf("2026-07-18"), view.getItems().getFirst().getReturnedDate());
        assertEquals("Damaged", view.getItems().getFirst().getConditionBook());
        assertEquals(80L, view.getItems().getFirst().getFineId());
        assertEquals("Unpaid", view.getItems().getFirst().getFinePaidStatus());
        assertNotNull(view.getItems().getFirst().getFineAmount());
    }
}
