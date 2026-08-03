package com.library.libhub.service.impl;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.library.libhub.DTO.Request.ReturnBookRequest;
import com.library.libhub.DTO.Request.ReturnDetailRequest;
import com.library.libhub.entity.BookCopies;
import com.library.libhub.entity.BorrowDetails;
import com.library.libhub.entity.BorrowTickets;
import com.library.libhub.entity.Fines;
import com.library.libhub.entity.ReturnDetails;
import com.library.libhub.entity.Returns;
import com.library.libhub.entity.Users;
import com.library.libhub.exception.ResourceNotFoundException;
import com.library.libhub.repository.BookCopyRepository;
import com.library.libhub.repository.BorrowDetailRepository;
import com.library.libhub.repository.BorrowTicketRepository;
import com.library.libhub.repository.FineRepository;
import com.library.libhub.repository.ReturnDetailRepository;
import com.library.libhub.repository.ReturnRepository;
import com.library.libhub.repository.UserRepository;
import com.library.libhub.service.IReturnService;

import jakarta.transaction.Transactional;

@Service
@Transactional
public class ReturnServiceImpl implements IReturnService {

    private final UserRepository userRepo;
    private final FineRepository fineRepo;
    private final BookCopyRepository copyRepo;
    private final BorrowDetailRepository borrowDetailRepo;
    private final BorrowTicketRepository ticketRepo;
    private final ReturnDetailRepository returnDetailRepo;
    private final ReturnRepository returnRepo;

    public ReturnServiceImpl(
            ReturnRepository returnRepo,
            ReturnDetailRepository returnDetailRepo,
            BorrowTicketRepository ticketRepo,
            BorrowDetailRepository borrowDetailRepo,
            BookCopyRepository copyRepo,
            FineRepository fineRepo,
            UserRepository userRepo) {

        this.returnRepo = returnRepo;
        this.returnDetailRepo = returnDetailRepo;
        this.ticketRepo = ticketRepo;
        this.borrowDetailRepo = borrowDetailRepo;
        this.copyRepo = copyRepo;
        this.fineRepo = fineRepo;
        this.userRepo = userRepo;
    }

    @Override
    public Returns createReturn(Returns returns) {
        if (returns == null || returns.getTicketId() == null || returns.getReturnDate() == null)
            throw new IllegalArgumentException("Thiếu thông tin trả sách");
        return returnRepo.save(returns);
    }

    @Override
    public Optional<Returns> getReturnById(long returnId) {
        return returnRepo.findById(returnId);
    }

    @Override
    public List<Returns> getAllReturns() {
        return returnRepo.findAll();
    }

    @Override
    public Returns updateReturn(long returnId, Returns returns) {
        Returns existing = returnRepo.findById(returnId)
                .orElseThrow(() -> new ResourceNotFoundException("Return not found with id: " + returnId));
        if (returns.getTicketId() != null)
            existing.setTicketId(returns.getTicketId());
        if (returns.getReturnDate() != null)
            existing.setReturnDate(returns.getReturnDate());
        if (returns.getReceivedBy() != null)
            existing.setReceivedBy(returns.getReceivedBy());
        if (returns.getNote() != null)
            existing.setNote(returns.getNote());
        return returnRepo.save(existing);
    }

    @Override
    public void deleteReturn(long returnId) {
        if (returnRepo.existsById(returnId)) {
            returnRepo.deleteById(returnId);
        } else {
            throw new ResourceNotFoundException("Return not found with id: " + returnId);
        }
    }

    @Override
    public List<Returns> findByTicket(long ticketId) {
        return returnRepo.findByTicketId(ticketId);
    }

    @Override
    public List<Returns> findByReceivedBy(long receivedBy) {
        return returnRepo.findByReceivedBy(receivedBy);
    }

    @Override
    public Returns returnBooks(ReturnBookRequest request, long currentStaffId) {

        Users staff = userRepo.findById(currentStaffId)
                .orElseThrow(() -> new ResourceNotFoundException("Staff not found"));

        BorrowTickets ticket = ticketRepo.findById(request.getTicketId())
                .orElseThrow(() -> new ResourceNotFoundException("Borrow ticket not found"));

        Returns returns = new Returns();
        returns.setTicketId(ticket.getTicketId());
        returns.setReceivedBy(staff.getUserId());
        returns.setReturnDate(new java.sql.Date(System.currentTimeMillis()));
        returns.setNote(request.getNote());

        returns = returnRepo.save(returns);

        for (ReturnDetailRequest item : request.getDetails()) {

            BorrowDetails borrowDetail = borrowDetailRepo
                    .findByTicketIdAndCopyId(ticket.getTicketId(), item.getCopyId())
                    .orElseThrow(() -> new ResourceNotFoundException("Borrow detail not found"));

            BookCopies copy = copyRepo.findByIdForUpdate(item.getCopyId())
                    .orElseThrow(() -> new ResourceNotFoundException("Book copy not found"));

            borrowDetail.setBorrowStatus("Returned");
            borrowDetailRepo.save(borrowDetail);

            if ("Good".equalsIgnoreCase(item.getConditionBook())) {
                copy.setStatus("Available");
            } else {
                copy.setStatus(item.getConditionBook());
            }

            copyRepo.save(copy);

            ReturnDetails detail = new ReturnDetails();
            detail.setReturnId(returns.getReturnId());
            detail.setCopyId(copy.getCopyId());
            detail.setConditionBook(item.getConditionBook());

            detail = returnDetailRepo.save(detail);

            BigDecimal fineAmount = BigDecimal.ZERO;
            StringBuilder reason = new StringBuilder();

            if (ticket.getDueDate() != null &&
                    ticket.getDueDate().before(new java.sql.Date(System.currentTimeMillis()))) {

                long overdueDays = java.time.temporal.ChronoUnit.DAYS.between(
                        ticket.getDueDate().toLocalDate(),
                        java.time.LocalDate.now());

                if (overdueDays > 0) {
                    fineAmount = fineAmount.add(
                            BigDecimal.valueOf(overdueDays * 5000));

                    reason.append("Quá hạn ")
                            .append(overdueDays)
                            .append(" ngày");
                }
            }

            if (!"Good".equalsIgnoreCase(item.getConditionBook())) {

                if (fineAmount.compareTo(BigDecimal.ZERO) > 0) {
                    reason.append(", ");
                }

                fineAmount = fineAmount.add(BigDecimal.valueOf(100000));

                reason.append("Sách hư hỏng");
            }

            if (fineAmount.compareTo(BigDecimal.ZERO) > 0) {

                Fines fine = new Fines();
                fine.setReturnDetailId(detail.getReturnDetailId());
                fine.setAmount(fineAmount);
                fine.setReason(reason.toString());
                fine.setPaidStatus("Unpaid");
                fine.setCreatedAt(new java.sql.Timestamp(System.currentTimeMillis()));

                fineRepo.save(fine);
            }
        }

        long remain = borrowDetailRepo.countByTicketIdAndBorrowStatusNotIgnoreCase(
                ticket.getTicketId(),
                "Returned");

        if (remain == 0) {
            ticket.setStatus("Returned");
        }

        ticketRepo.save(ticket);

        return returns;
    }
}
