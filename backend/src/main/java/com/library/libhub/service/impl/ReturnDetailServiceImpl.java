package com.library.libhub.service.impl;

import com.library.libhub.exception.ResourceNotFoundException;

import com.library.libhub.dao.ReturnDetailDAO;
import com.library.libhub.entity.ReturnDetails;
import com.library.libhub.service.IReturnDetailService;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class ReturnDetailServiceImpl implements IReturnDetailService {

    private final ReturnDetailDAO returnDetailDAO;

    public ReturnDetailServiceImpl(ReturnDetailDAO returnDetailDAO) {
        this.returnDetailDAO = returnDetailDAO;
    }

    @Override
    public ReturnDetails createReturnDetail(ReturnDetails returnDetail) {
        if (returnDetail == null || returnDetail.getReturnId() == null || returnDetail.getCopyId() == null)
            throw new IllegalArgumentException("Thiếu thông tin chi tiết trả sách");
        return returnDetailDAO.save(returnDetail);
    }

    @Override
    public Optional<ReturnDetails> getReturnDetailById(long returnDetailId) {
        return returnDetailDAO.findById(returnDetailId);
    }

    @Override
    public List<ReturnDetails> getAllReturnDetails() {
        return returnDetailDAO.findAll();
    }

    @Override
    public ReturnDetails updateReturnDetail(long returnDetailId, ReturnDetails returnDetail) {
        ReturnDetails existing = returnDetailDAO.findById(returnDetailId)
                .orElseThrow(() -> new ResourceNotFoundException("Return detail not found with id: " + returnDetailId));
        if (returnDetail.getReturnId() != null) existing.setReturnId(returnDetail.getReturnId());
        if (returnDetail.getCopyId() != null) existing.setCopyId(returnDetail.getCopyId());
        if (returnDetail.getConditionBook() != null) existing.setConditionBook(returnDetail.getConditionBook());
        return returnDetailDAO.save(existing);
    }

    @Override
    public void deleteReturnDetail(long returnDetailId) {
        if (returnDetailDAO.existsById(returnDetailId)) {
            returnDetailDAO.deleteById(returnDetailId);
        } else {
            throw new ResourceNotFoundException("Return detail not found with id: " + returnDetailId);
        }
    }

    @Override
    public List<ReturnDetails> findByReturn(long returnId) {
        return returnDetailDAO.findByReturnId(returnId);
    }

    @Override
    public List<ReturnDetails> findByCopy(long copyId) {
        return returnDetailDAO.findByCopyId(copyId);
    }

    @Override
    public List<ReturnDetails> findByCondition(String conditionBook) {
        return returnDetailDAO.findByConditionBook(conditionBook);
    }
}
