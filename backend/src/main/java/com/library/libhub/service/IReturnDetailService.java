package com.library.libhub.service;

import com.library.libhub.entity.ReturnDetails;
import java.util.List;
import java.util.Optional;

public interface IReturnDetailService {
    ReturnDetails createReturnDetail(ReturnDetails returnDetail);
    Optional<ReturnDetails> getReturnDetailById(Long returnDetailId);
    List<ReturnDetails> getAllReturnDetails();
    ReturnDetails updateReturnDetail(Long returnDetailId, ReturnDetails returnDetail);
    void deleteReturnDetail(Long returnDetailId);
    List<ReturnDetails> findByReturn(Long returnId);
    List<ReturnDetails> findByCopy(Long copyId);
    List<ReturnDetails> findByCondition(String conditionBook);
}
