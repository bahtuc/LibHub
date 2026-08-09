package com.library.libhub.service.impl;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.library.libhub.entity.Fines;
import com.library.libhub.exception.ResourceNotFoundException;
import com.library.libhub.repository.FineRepository;
import com.library.libhub.service.IFineService;

import jakarta.transaction.Transactional;

@Service
@Transactional
public class FineServiceImpl implements IFineService {

    private final FineRepository fineRepo;

    public FineServiceImpl(FineRepository fineRepo) {
        this.fineRepo = fineRepo;
    }

    @Override
    public Fines createFine(Fines fine) {

        if (fine == null
                || fine.getReturnDetailId() == null
                || fine.getAmount() == null
                || fine.getAmount().compareTo(BigDecimal.ZERO) <= 0) {

            throw new IllegalArgumentException("Khoản phạt không hợp lệ");
        }

        if (fine.getPaidStatus() == null || fine.getPaidStatus().isBlank()) {
            fine.setPaidStatus("Unpaid");
        }

        if (fine.getCreatedAt() == null) {
            fine.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        }

        return fineRepo.save(fine);
    }

    @Override
    public Optional<Fines> getFineById(long fineId) {
        return fineRepo.findById(fineId);
    }

    @Override
    public List<Fines> getAllFines() {
        return fineRepo.findAll();
    }

    @Override
    public Fines updateFine(long fineId, Fines fine) {
        Fines existing = fineRepo.findById(fineId)
                .orElseThrow(() -> new ResourceNotFoundException("Fine not found with id: " + fineId));
        if (fine.getReturnDetailId() != null)
            existing.setReturnDetailId(fine.getReturnDetailId());
        if (fine.getAmount() != null) {

            if (fine.getAmount().compareTo(java.math.BigDecimal.ZERO) <= 0) {
                throw new IllegalArgumentException("Số tiền phạt phải lớn hơn 0");
            }

            existing.setAmount(fine.getAmount());
        }
        if (fine.getReason() != null)
            existing.setReason(fine.getReason());
        if (fine.getPaidStatus() != null)
            existing.setPaidStatus(fine.getPaidStatus());
        return fineRepo.save(existing);
    }

    @Override
    public void deleteFine(long fineId) {
        if (fineRepo.existsById(fineId)) {
            fineRepo.deleteById(fineId);
        } else {
            throw new ResourceNotFoundException("Fine not found with id: " + fineId);
        }
    }

    @Override
    public List<Fines> findByReturnDetail(long returnDetailId) {
        return fineRepo.findByReturnDetailId(returnDetailId);
    }

    @Override
    public List<Fines> findByPaidStatus(String paidStatus) {
        return fineRepo.findByPaidStatus(paidStatus);
    }

    @Override
    public List<Fines> findByUser(long userId) {
        return fineRepo.findByUserId(userId);
    }

}