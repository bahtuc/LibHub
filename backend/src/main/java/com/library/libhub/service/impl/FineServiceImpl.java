package com.library.libhub.service.impl;

import com.library.libhub.exception.ResourceNotFoundException;

import com.library.libhub.dao.FineDAO;
import com.library.libhub.entity.Fines;
import com.library.libhub.service.IFineService;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class FineServiceImpl implements IFineService {

    private final FineDAO fineDAO;

    public FineServiceImpl(FineDAO fineDAO) {
        this.fineDAO = fineDAO;
    }

    @Override
    public Fines createFine(Fines fine) {
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
        if (fineDAO.existsById(fineId)) {
            fine.setFineId(fineId);
            return fineDAO.save(fine);
        }
        throw new ResourceNotFoundException("Fine not found with id: " + fineId);
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
