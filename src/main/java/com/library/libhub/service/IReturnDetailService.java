package com.library.libhub.service;

import com.library.libhub.entity.ReturnDetails;
import java.util.List;
import java.util.Optional;

public interface IReturnDetailService {
    ReturnDetails createReturnDetail(ReturnDetails returnDetail);
    Optional<ReturnDetails> getReturnDetailById(long returnDetailId);
    List<ReturnDetails> getAllReturnDetails();
    ReturnDetails updateReturnDetail(long returnDetailId, ReturnDetails returnDetail);
    void deleteReturnDetail(long returnDetailId);
    List<ReturnDetails> findByReturn(long returnId);
    List<ReturnDetails> findByCopy(long copyId);
    List<ReturnDetails> findByCondition(String conditionBook);
}
