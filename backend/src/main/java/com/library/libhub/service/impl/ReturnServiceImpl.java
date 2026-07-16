package com.library.libhub.service.impl;

import com.library.libhub.exception.ResourceNotFoundException;

import com.library.libhub.dao.ReturnDAO;
import com.library.libhub.entity.Returns;
import com.library.libhub.service.IReturnService;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class ReturnServiceImpl implements IReturnService {

    private final ReturnDAO returnDAO;

    public ReturnServiceImpl(ReturnDAO returnDAO) {
        this.returnDAO = returnDAO;
    }

    @Override
    public Returns createReturn(Returns returns) {
        if (returns == null || returns.getTicketId() == null || returns.getReturnDate() == null)
            throw new IllegalArgumentException("Thiếu thông tin trả sách");
        return returnDAO.save(returns);
    }

    @Override
    public Optional<Returns> getReturnById(long returnId) {
        return returnDAO.findById(returnId);
    }

    @Override
    public List<Returns> getAllReturns() {
        return returnDAO.findAll();
    }

    @Override
    public Returns updateReturn(long returnId, Returns returns) {
        Returns existing = returnDAO.findById(returnId)
                .orElseThrow(() -> new ResourceNotFoundException("Return not found with id: " + returnId));
        if (returns.getTicketId() != null) existing.setTicketId(returns.getTicketId());
        if (returns.getReturnDate() != null) existing.setReturnDate(returns.getReturnDate());
        if (returns.getReceivedBy() != null) existing.setReceivedBy(returns.getReceivedBy());
        if (returns.getNote() != null) existing.setNote(returns.getNote());
        return returnDAO.save(existing);
    }

    @Override
    public void deleteReturn(long returnId) {
        if (returnDAO.existsById(returnId)) {
            returnDAO.deleteById(returnId);
        } else {
            throw new ResourceNotFoundException("Return not found with id: " + returnId);
        }
    }

    @Override
    public List<Returns> findByTicket(long ticketId) {
        return returnDAO.findByTicketId(ticketId);
    }

    @Override
    public List<Returns> findByReceivedBy(long receivedBy) {
        return returnDAO.findByReceivedBy(receivedBy);
    }
}
