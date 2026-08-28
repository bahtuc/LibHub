package com.library.libhub.service;

import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import static org.mockito.Mockito.when;
import org.mockito.junit.jupiter.MockitoExtension;

import com.library.libhub.DTO.Response.BorrowTicketResponse;
import com.library.libhub.entity.BookCopies;
import com.library.libhub.entity.Books;
import com.library.libhub.entity.BorrowDetails;
import com.library.libhub.entity.BorrowTickets;
import com.library.libhub.entity.Fines;
import com.library.libhub.entity.ReturnDetails;
import com.library.libhub.entity.Returns;
import com.library.libhub.entity.Users;
import com.library.libhub.repository.BookCopyRepository;
import com.library.libhub.repository.BookRepository;
import com.library.libhub.repository.BorrowDetailRepository;
import com.library.libhub.repository.BorrowTicketRepository;
import com.library.libhub.repository.FineRepository;
import com.library.libhub.repository.ReturnDetailRepository;
import com.library.libhub.repository.ReturnRepository;
import com.library.libhub.repository.UserRepository;

@ExtendWith(MockitoExtension.class)
class LoanViewServiceTest {
    @Mock
    private BorrowTicketRepository ticketRepo;
    @Mock
    private BorrowDetailRepository detailRepo;
    @Mock
    private BookCopyRepository copyRepo;
    @Mock
    private BookRepository bookRepo;
    @Mock
    private UserRepository userRepo;
    @Mock
    private ReturnRepository returnRepo;
    @Mock
    private ReturnDetailRepository returnDetailRepo;
    @Mock
    private FineRepository fineRepo;

    private LoanViewService service;

    @BeforeEach
    void setUp() {
        service = new LoanViewService(
                ticketRepo,
                detailRepo,
                copyRepo,
                bookRepo,
                userRepo,
                returnRepo,
                returnDetailRepo,
                fineRepo);
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
        fine.setAmount(BigDecimal.valueOf(120000));
        fine.setReason("Bồi thường sách bị hư hỏng");
        fine.setPaidStatus("Unpaid");

        when(ticketRepo.findAll()).thenReturn(List.of(ticket));
        when(detailRepo.findAll()).thenReturn(List.of(detail));
        when(copyRepo.findAll()).thenReturn(List.of(copy));
        when(bookRepo.findAll()).thenReturn(List.of(book));
        when(userRepo.findAll()).thenReturn(List.of(user));
        when(returnRepo.findAll()).thenReturn(List.of(returned));
        when(returnDetailRepo.findAll()).thenReturn(List.of(returnDetail));
        when(fineRepo.findAll()).thenReturn(List.of(fine));

        BorrowTicketResponse view = service.getAllViews().getFirst();

        assertEquals(10L, view.getTicketId());
        assertEquals("Bạn đọc", view.getUserName());
        assertEquals("Đắc nhân tâm", view.getItems().getFirst().getBookTitle());
        assertEquals(Date.valueOf("2026-07-01"), view.getItems().getFirst().getBorrowDate());
        assertEquals(Date.valueOf("2026-07-15"), view.getItems().getFirst().getDueDate());
        assertEquals(Date.valueOf("2026-07-18"), view.getItems().getFirst().getReturnedDate());
        assertEquals("Damaged", view.getItems().getFirst().getConditionBook());
        assertEquals(80L, view.getItems().getFirst().getFineId());
        assertEquals("Unpaid", view.getItems().getFirst().getFinePaidStatus());
        assertNotNull(view.getItems().getFirst().getFineAmount());
    }

    @Test
    void usesGuestIdentityWhenTicketHasNoRegisteredUser() {
        BorrowTickets ticket = new BorrowTickets();
        ticket.setTicketId(11L);
        ticket.setGuestName("Walk-in Reader");
        ticket.setGuestPhone("0900000000");

        when(ticketRepo.findAll()).thenReturn(List.of(ticket));
        when(detailRepo.findAll()).thenReturn(List.of());
        when(copyRepo.findAll()).thenReturn(List.of());
        when(bookRepo.findAll()).thenReturn(List.of());
        when(userRepo.findAll()).thenReturn(List.of());
        when(returnRepo.findAll()).thenReturn(List.of());
        when(returnDetailRepo.findAll()).thenReturn(List.of());
        when(fineRepo.findAll()).thenReturn(List.of());

        BorrowTicketResponse view = service.getAllViews().getFirst();

        assertEquals("Walk-in Reader", view.getUserName());
        assertEquals("Walk-in Reader", view.getGuestName());
        assertEquals("0900000000", view.getGuestPhone());
    }
}
