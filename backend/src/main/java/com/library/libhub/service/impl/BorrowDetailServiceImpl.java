package com.library.libhub.service.impl;

import com.library.libhub.exception.ResourceNotFoundException;

import com.library.libhub.dao.BorrowDetailDAO;
import com.library.libhub.entity.BorrowDetails;
import com.library.libhub.service.IBorrowDetailService;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class BorrowDetailServiceImpl implements IBorrowDetailService {

    private final BorrowDetailDAO borrowDetailDAO;

    public BorrowDetailServiceImpl(BorrowDetailDAO borrowDetailDAO) {
        this.borrowDetailDAO = borrowDetailDAO;
    }

    @Override
    public BorrowDetails createBorrowDetail(BorrowDetails borrowDetail) {
        return borrowDetailDAO.save(borrowDetail);
    }

    @Override
    public Optional<BorrowDetails> getBorrowDetailById(long detailId) {
        return borrowDetailDAO.findById(detailId);
    }

    @Override
    public List<BorrowDetails> getAllBorrowDetails() {
        return borrowDetailDAO.findAll();
    }

    @Override
    public BorrowDetails updateBorrowDetail(long detailId, BorrowDetails borrowDetail) {
        if (borrowDetailDAO.existsById(detailId)) {
            borrowDetail.setDetailId(detailId);
            return borrowDetailDAO.save(borrowDetail);
        }
        throw new ResourceNotFoundException("Borrow detail not found with id: " + detailId);
    }

    @Override
    public void deleteBorrowDetail(long detailId) {
        if (borrowDetailDAO.existsById(detailId)) {
            borrowDetailDAO.deleteById(detailId);
        } else {
            throw new ResourceNotFoundException("Borrow detail not found with id: " + detailId);
        }
    }

    @Override
    public List<BorrowDetails> findByTicket(long ticketId) {
        return borrowDetailDAO.findByTicketId(ticketId);
    }

    @Override
    public List<BorrowDetails> findByCopy(long copyId) {
        return borrowDetailDAO.findByCopyId(copyId);
    }

    @Override
    public List<BorrowDetails> findByStatus(String borrowStatus) {
        return borrowDetailDAO.findByBorrowStatus(borrowStatus);
    }
}
