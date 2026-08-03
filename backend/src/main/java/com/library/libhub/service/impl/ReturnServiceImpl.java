package com.library.libhub.service.impl;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.library.libhub.DTO.Request.ReturnBookRequest;
import com.library.libhub.entity.Returns;
import com.library.libhub.exception.ResourceNotFoundException;
import com.library.libhub.repository.ReturnRepository;
import com.library.libhub.service.IReturnService;

import jakarta.transaction.Transactional;

@Service
@Transactional
public class ReturnServiceImpl implements IReturnService {

    private final ReturnRepository returnRepo;

    public ReturnServiceImpl(ReturnRepository returnRepo) {
        this.returnRepo = returnRepo;
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
        throw new UnsupportedOperationException("Not implemented yet");
    }
}
