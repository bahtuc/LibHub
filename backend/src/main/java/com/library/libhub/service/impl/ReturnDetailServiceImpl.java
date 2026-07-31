package com.library.libhub.service.impl;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.library.libhub.entity.ReturnDetails;
import com.library.libhub.exception.ResourceNotFoundException;
import com.library.libhub.repository.ReturnDetailRepository;
import com.library.libhub.service.IReturnDetailService;

import jakarta.transaction.Transactional;

@Service
@Transactional
public class ReturnDetailServiceImpl implements IReturnDetailService {

    private final ReturnDetailRepository returnDetailRepo;

    public ReturnDetailServiceImpl(ReturnDetailRepository returnDetailRepo) {
        this.returnDetailRepo = returnDetailRepo;
    }

    @Override
    public ReturnDetails createReturnDetail(ReturnDetails returnDetail) {
        if (returnDetail == null || returnDetail.getReturnId() == null || returnDetail.getCopyId() == null)
            throw new IllegalArgumentException("Thiếu thông tin chi tiết trả sách");
        return returnDetailRepo.save(returnDetail);
    }

    @Override
    public Optional<ReturnDetails> getReturnDetailById(long returnDetailId) {
        return returnDetailRepo.findById(returnDetailId);
    }

    @Override
    public List<ReturnDetails> getAllReturnDetails() {
        return returnDetailRepo.findAll();
    }

    @Override
    public ReturnDetails updateReturnDetail(long returnDetailId, ReturnDetails returnDetail) {
        ReturnDetails existing = returnDetailRepo.findById(returnDetailId)
                .orElseThrow(() -> new ResourceNotFoundException("Return detail not found with id: " + returnDetailId));
        if (returnDetail.getReturnId() != null) existing.setReturnId(returnDetail.getReturnId());
        if (returnDetail.getCopyId() != null) existing.setCopyId(returnDetail.getCopyId());
        if (returnDetail.getConditionBook() != null) existing.setConditionBook(returnDetail.getConditionBook());
        return returnDetailRepo.save(existing);
    }

    @Override
    public void deleteReturnDetail(long returnDetailId) {
        if (returnDetailRepo.existsById(returnDetailId)) {
            returnDetailRepo.deleteById(returnDetailId);
        } else {
            throw new ResourceNotFoundException("Return detail not found with id: " + returnDetailId);
        }
    }

    @Override
    public List<ReturnDetails> findByReturn(long returnId) {
        return returnDetailRepo.findByReturnId(returnId);
    }

    @Override
    public List<ReturnDetails> findByCopy(long copyId) {
        return returnDetailRepo.findByCopyId(copyId);
    }

    @Override
    public List<ReturnDetails> findByCondition(String conditionBook) {
        return returnDetailRepo.findByConditionBook(conditionBook);
    }
}
