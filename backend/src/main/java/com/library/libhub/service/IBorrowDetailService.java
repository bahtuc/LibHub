package com.library.libhub.service;

import com.library.libhub.entity.BorrowDetails;
import java.util.List;
import java.util.Optional;

public interface IBorrowDetailService {
    BorrowDetails createBorrowDetail(BorrowDetails borrowDetail);
    Optional<BorrowDetails> getBorrowDetailById(Long detailId);
    List<BorrowDetails> getAllBorrowDetails();
    BorrowDetails updateBorrowDetail(Long detailId, BorrowDetails borrowDetail);
    void deleteBorrowDetail(Long detailId);
    List<BorrowDetails> findByTicket(Long ticketId);
    List<BorrowDetails> findByCopy(Long copyId);
    List<BorrowDetails> findByStatus(String borrowStatus);
}
