package com.library.libhub.service.impl;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.library.libhub.entity.BorrowDetails;
import com.library.libhub.exception.ResourceNotFoundException;
import com.library.libhub.repository.BorrowDetailRepository;
import com.library.libhub.service.IBorrowDetailService;

import jakarta.transaction.Transactional;

@Service
@Transactional
public class BorrowDetailServiceImpl implements IBorrowDetailService {

    private final BorrowDetailRepository borrowDetailRepo;

    public BorrowDetailServiceImpl(BorrowDetailRepository borrowDetailRepo) {
        this.borrowDetailRepo = borrowDetailRepo;
    }

    @Override
    public BorrowDetails createBorrowDetail(BorrowDetails borrowDetail) {
        if (borrowDetail == null || borrowDetail.getTicketId() == null || borrowDetail.getCopyId() == null)
            throw new IllegalArgumentException("Thiếu thông tin chi tiết mượn");
        if (borrowDetail.getBorrowStatus() == null || borrowDetail.getBorrowStatus().isBlank())
            borrowDetail.setBorrowStatus("Borrowed");
        return borrowDetailRepo.save(borrowDetail);
    }

    @Override
    public Optional<BorrowDetails> getBorrowDetailById(long detailId) {
        return borrowDetailRepo.findById(detailId);
    }

    @Override
    public List<BorrowDetails> getAllBorrowDetails() {
        return borrowDetailRepo.findAll();
    }

    @Override
    public BorrowDetails updateBorrowDetail(long detailId, BorrowDetails borrowDetail) {
        BorrowDetails existing = borrowDetailRepo.findById(detailId)
                .orElseThrow(() -> new ResourceNotFoundException("Borrow detail not found with id: " + detailId));
        if (borrowDetail.getTicketId() != null) existing.setTicketId(borrowDetail.getTicketId());
        if (borrowDetail.getCopyId() != null) existing.setCopyId(borrowDetail.getCopyId());
        if (borrowDetail.getBorrowStatus() != null) existing.setBorrowStatus(borrowDetail.getBorrowStatus());
        return borrowDetailRepo.save(existing);
    }

    @Override
    public void deleteBorrowDetail(long detailId) {
        if (borrowDetailRepo.existsById(detailId)) {
            borrowDetailRepo.deleteById(detailId);
        } else {
            throw new ResourceNotFoundException("Borrow detail not found with id: " + detailId);
        }
    }

    @Override
    public List<BorrowDetails> findByTicket(long ticketId) {
        return borrowDetailRepo.findByTicketId(ticketId);
    }

    @Override
    public List<BorrowDetails> findByCopy(long copyId) {
        return borrowDetailRepo.findByCopyId(copyId);
    }

    @Override
    public List<BorrowDetails> findByStatus(String borrowStatus) {
        return borrowDetailRepo.findByBorrowStatus(borrowStatus);
    }
}
