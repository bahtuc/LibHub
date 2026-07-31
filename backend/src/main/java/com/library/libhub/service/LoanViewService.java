package com.library.libhub.service;

import com.library.libhub.DTO.Response.BorrowedItemResponse;
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
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class LoanViewService {
    private final BorrowTicketDAO ticketDAO;
    private final BorrowDetailDAO detailDAO;
    private final BookCopyDAO copyDAO;
    private final BookDAO bookDAO;
    private final UserDAO userDAO;
    private final ReturnDAO returnDAO;
    private final ReturnDetailDAO returnDetailDAO;
    private final FineDAO fineDAO;

    public LoanViewService(
            BorrowTicketDAO ticketDAO,
            BorrowDetailDAO detailDAO,
            BookCopyDAO copyDAO,
            BookDAO bookDAO,
            UserDAO userDAO,
            ReturnDAO returnDAO,
            ReturnDetailDAO returnDetailDAO,
            FineDAO fineDAO) {
        this.ticketDAO = ticketDAO;
        this.detailDAO = detailDAO;
        this.copyDAO = copyDAO;
        this.bookDAO = bookDAO;
        this.userDAO = userDAO;
        this.returnDAO = returnDAO;
        this.returnDetailDAO = returnDetailDAO;
        this.fineDAO = fineDAO;
    }

    public List<BorrowTicketResponse> getAllViews() {
        return buildViews(ticketDAO.findAll());
    }

    public List<BorrowTicketResponse> getViewsForUser(long userId) {
        return buildViews(ticketDAO.findByUserId(userId));
    }

    private List<BorrowTicketResponse> buildViews(List<BorrowTickets> tickets) {
        if (tickets.isEmpty()) return List.of();

        Set<Long> ticketIds = tickets.stream()
                .map(BorrowTickets::getTicketId)
                .collect(Collectors.toSet());

        Map<Long, Users> users = indexBy(userDAO.findAll(), Users::getUserId);
        Map<Long, BookCopies> copies = indexBy(copyDAO.findAll(), BookCopies::getCopyId);
        Map<Long, Books> books = indexBy(bookDAO.findAll(), Books::getBookId);
        Map<Long, Returns> returns = indexBy(returnDAO.findAll(), Returns::getReturnId);
        Map<Long, Fines> fines = fineDAO.findAll().stream()
                .filter(fine -> fine.getReturnDetailId() != null)
                .collect(Collectors.toMap(
                        Fines::getReturnDetailId,
                        Function.identity(),
                        (left, right) -> greaterId(left.getFineId(), right.getFineId()) ? left : right));

        Map<Long, List<BorrowDetails>> detailsByTicket = detailDAO.findAll().stream()
                .filter(detail -> ticketIds.contains(detail.getTicketId()))
                .collect(Collectors.groupingBy(BorrowDetails::getTicketId));

        Map<TicketCopyKey, ReturnedItem> returnedByTicketAndCopy = new HashMap<>();
        for (ReturnDetails detail : returnDetailDAO.findAll()) {
            Returns returned = returns.get(detail.getReturnId());
            if (returned == null || !ticketIds.contains(returned.getTicketId())) continue;
            TicketCopyKey key = new TicketCopyKey(returned.getTicketId(), detail.getCopyId());
            ReturnedItem candidate = new ReturnedItem(returned, detail);
            returnedByTicketAndCopy.merge(
                    key,
                    candidate,
                    (left, right) -> greaterId(
                            left.returned().getReturnId(),
                            right.returned().getReturnId()) ? left : right);
        }

        List<BorrowTicketResponse> result = new ArrayList<>();
        tickets.stream()
                .sorted(Comparator.comparing(
                        BorrowTickets::getTicketId,
                        Comparator.nullsLast(Comparator.reverseOrder())))
                .forEach(ticket -> result.add(toResponse(
                        ticket,
                        users,
                        copies,
                        books,
                        detailsByTicket,
                        returnedByTicketAndCopy,
                        fines)));
        return result;
    }

    private BorrowTicketResponse toResponse(
            BorrowTickets ticket,
            Map<Long, Users> users,
            Map<Long, BookCopies> copies,
            Map<Long, Books> books,
            Map<Long, List<BorrowDetails>> detailsByTicket,
            Map<TicketCopyKey, ReturnedItem> returnedItems,
            Map<Long, Fines> fines) {
        BorrowTicketResponse response = new BorrowTicketResponse();
        response.setTicketId(ticket.getTicketId());
        response.setUserId(ticket.getUserId());
        Users user = users.get(ticket.getUserId());
        response.setUserName(user == null
                ? null
                : firstNonBlank(user.getFullName(), user.getUsername()));
        response.setBorrowDate(ticket.getBorrowDate());
        response.setDueDate(ticket.getDueDate());
        response.setStatus(ticket.getStatus());
        response.setNote(ticket.getNote());

        List<BorrowedItemResponse> items = detailsByTicket
                .getOrDefault(ticket.getTicketId(), List.of())
                .stream()
                .sorted(Comparator.comparing(
                        BorrowDetails::getDetailId,
                        Comparator.nullsLast(Comparator.naturalOrder())))
                .map(detail -> toItem(
                        ticket.getTicketId(),
                        detail,
                        copies,
                        books,
                        returnedItems,
                        fines))
                .toList();
        response.setItems(items);
        return response;
    }

    private BorrowedItemResponse toItem(
            long ticketId,
            BorrowDetails detail,
            Map<Long, BookCopies> copies,
            Map<Long, Books> books,
            Map<TicketCopyKey, ReturnedItem> returnedItems,
            Map<Long, Fines> fines) {
        BorrowedItemResponse response = new BorrowedItemResponse();
        response.setDetailId(detail.getDetailId());
        response.setCopyId(detail.getCopyId());
        response.setBorrowStatus(detail.getBorrowStatus());

        BookCopies copy = copies.get(detail.getCopyId());
        if (copy != null) {
            response.setBookId(copy.getBookId());
            response.setBarcode(copy.getBarcode());
            Books book = books.get(copy.getBookId());
            response.setBookTitle(book == null ? null : book.getTitle());
        }

        ReturnedItem returnedItem = returnedItems.get(new TicketCopyKey(ticketId, detail.getCopyId()));
        if (returnedItem != null) {
            ReturnDetails returnDetail = returnedItem.detail();
            response.setReturnedDate(returnedItem.returned().getReturnDate());
            response.setConditionBook(returnDetail.getConditionBook());
            response.setReturnDetailId(returnDetail.getReturnDetailId());
            Fines fine = fines.get(returnDetail.getReturnDetailId());
            if (fine != null) {
                response.setFineId(fine.getFineId());
                response.setFineAmount(fine.getAmount());
                response.setFineReason(fine.getReason());
                response.setFinePaidStatus(fine.getPaidStatus());
            }
        }
        return response;
    }

    private static <T> Map<Long, T> indexBy(List<T> values, Function<T, Long> id) {
        return values.stream()
                .filter(value -> id.apply(value) != null)
                .collect(Collectors.toMap(id, Function.identity(), (left, right) -> right));
    }

    private static boolean greaterId(Long left, Long right) {
        if (left == null) return false;
        return right == null || left > right;
    }

    private static String firstNonBlank(String preferred, String fallback) {
        return preferred == null || preferred.isBlank() ? fallback : preferred;
    }

    private record TicketCopyKey(Long ticketId, Long copyId) {}
    private record ReturnedItem(Returns returned, ReturnDetails detail) {}
}
