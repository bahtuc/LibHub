package com.library.libhub.service.impl;

import com.library.libhub.exception.ResourceNotFoundException;

import com.library.libhub.dao.FineDAO;
import com.library.libhub.entity.Fines;
import com.library.libhub.service.IFineService;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import java.sql.Timestamp;

@Service
@Transactional
public class FineServiceImpl implements IFineService {

    private final FineDAO fineDAO;

    public FineServiceImpl(FineDAO fineDAO) {
        this.fineDAO = fineDAO;
    }

    @Override
    public Fines createFine(Fines fine) {
        if (fine == null || fine.getReturnDetailId() == null || fine.getAmount() == null || fine.getAmount() <= 0)
            throw new IllegalArgumentException("Khoản phạt không hợp lệ");
        if (fine.getPaidStatus() == null || fine.getPaidStatus().isBlank()) fine.setPaidStatus("Unpaid");
        if (fine.getCreatedAt() == null) fine.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        return fineDAO.save(fine);
    }

    @Override
    public Optional<Fines> getFineById(long fineId) {
        return fineDAO.findById(fineId);
    }

    @Override
    public List<Fines> getAllFines() {
        return fineDAO.findAll();
    }

    @Override
    public Fines updateFine(long fineId, Fines fine) {
        Fines existing = fineDAO.findById(fineId)
                .orElseThrow(() -> new ResourceNotFoundException("Fine not found with id: " + fineId));
        if (fine.getReturnDetailId() != null) existing.setReturnDetailId(fine.getReturnDetailId());
        if (fine.getAmount() != null) {
            if (fine.getAmount() <= 0) throw new IllegalArgumentException("Số tiền phạt phải lớn hơn 0");
            existing.setAmount(fine.getAmount());
        }
        if (fine.getReason() != null) existing.setReason(fine.getReason());
        if (fine.getPaidStatus() != null) existing.setPaidStatus(fine.getPaidStatus());
        return fineDAO.save(existing);
    }

    @Override
    public void deleteFine(long fineId) {
        if (fineDAO.existsById(fineId)) {
            fineDAO.deleteById(fineId);
        } else {
            throw new ResourceNotFoundException("Fine not found with id: " + fineId);
        }
    }

    @Override
    public List<Fines> findByReturnDetail(long returnDetailId) {
        return fineDAO.findByReturnDetailId(returnDetailId);
    }

    @Override
    public List<Fines> findByPaidStatus(String paidStatus) {
        return fineDAO.findByPaidStatus(paidStatus);
    }
}
