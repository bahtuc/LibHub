package com.library.libhub.service;

import com.library.libhub.DTO.Response.BorrowedItemResponse;
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
    private final BorrowTicketRepository ticketRepo;
    private final BorrowDetailRepository detailRepo;
    private final BookCopyRepository copyRepo;
    private final BookRepository bookRepo;
    private final UserRepository userRepo;
    private final ReturnRepository returnRepo;
    private final ReturnDetailRepository returnDetailRepo;
    private final FineRepository fineRepo;

    public LoanViewService(
            BorrowTicketRepository ticketRepo,
            BorrowDetailRepository detailRepo,
            BookCopyRepository copyRepo,
            BookRepository bookRepo,
            UserRepository userRepo,
            ReturnRepository returnRepo,
            ReturnDetailRepository returnDetailRepo,
            FineRepository fineRepo) {
        this.ticketRepo = ticketRepo;
        this.detailRepo = detailRepo;
        this.copyRepo = copyRepo;
        this.bookRepo = bookRepo;
        this.userRepo = userRepo;
        this.returnRepo = returnRepo;
        this.returnDetailRepo = returnDetailRepo;
        this.fineRepo = fineRepo;
    }

    public List<BorrowTicketResponse> getAllViews() {
        return buildViews(ticketRepo.findAll());
    }

    public List<BorrowTicketResponse> getViewsForUser(long userId) {
        return buildViews(ticketRepo.findByUserId(userId));
    }

    private List<BorrowTicketResponse> buildViews(List<BorrowTickets> tickets) {
        if (tickets.isEmpty()) return List.of();

        Set<Long> ticketIds = tickets.stream()
                .map(BorrowTickets::getTicketId)
                .collect(Collectors.toSet());

        Map<Long, Users> users = indexBy(userRepo.findAll(), Users::getUserId);
        Map<Long, BookCopies> copies = indexBy(copyRepo.findAll(), BookCopies::getCopyId);
        Map<Long, Books> books = indexBy(bookRepo.findAll(), Books::getBookId);
        Map<Long, Returns> returns = indexBy(returnRepo.findAll(), Returns::getReturnId);
        Map<Long, Fines> fines = fineRepo.findAll().stream()
                .filter(fine -> fine.getReturnDetailId() != null)
                .collect(Collectors.toMap(
                        Fines::getReturnDetailId,
                        Function.identity(),
                        (left, right) -> greaterId(left.getFineId(), right.getFineId()) ? left : right));

        Map<Long, List<BorrowDetails>> detailsByTicket = detailRepo.findAll().stream()
                .filter(detail -> ticketIds.contains(detail.getTicketId()))
                .collect(Collectors.groupingBy(BorrowDetails::getTicketId));

        Map<TicketCopyKey, ReturnedItem> returnedByTicketAndCopy = new HashMap<>();
        for (ReturnDetails detail : returnDetailRepo.findAll()) {
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
                ? ticket.getGuestName()
                : firstNonBlank(user.getFullName(), user.getUsername()));
        response.setGuestName(ticket.getGuestName());
        response.setGuestPhone(ticket.getGuestPhone());
        response.setBorrowDate(ticket.getBorrowDate());
        response.setDueDate(ticket.getDueDate());
        response.setStatus(ticket.getStatus());
        response.setNote(ticket.getNote());
        response.setDepositAmount(ticket.getDepositAmount());
        response.setDepositPaidStatus(ticket.getDepositPaidStatus());
        response.setRenewalCount(ticket.getRenewalCount());
        response.setLastRenewedAt(ticket.getLastRenewedAt());

        List<BorrowedItemResponse> items = detailsByTicket
                .getOrDefault(ticket.getTicketId(), List.of())
                .stream()
                .sorted(Comparator.comparing(
                        BorrowDetails::getDetailId,
                        Comparator.nullsLast(Comparator.naturalOrder())))
                .map(detail -> toItem(
                        ticket.getTicketId(),
                        ticket.getBorrowDate(),
                        ticket.getDueDate(),
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
            java.sql.Date borrowDate,
            java.sql.Date dueDate,
            BorrowDetails detail,
            Map<Long, BookCopies> copies,
            Map<Long, Books> books,
            Map<TicketCopyKey, ReturnedItem> returnedItems,
            Map<Long, Fines> fines) {
        BorrowedItemResponse response = new BorrowedItemResponse();
        response.setDetailId(detail.getDetailId());
        response.setCopyId(detail.getCopyId());
        response.setBorrowStatus(detail.getBorrowStatus());
        response.setBorrowDate(borrowDate);
        response.setDueDate(dueDate);

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
