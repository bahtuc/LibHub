package com.library.libhub.service;

import com.library.libhub.entity.BorrowDetails;
import java.util.List;
import java.util.Optional;

public interface IBorrowDetailService {
    BorrowDetails createBorrowDetail(BorrowDetails borrowDetail);
    Optional<BorrowDetails> getBorrowDetailById(long detailId);
    List<BorrowDetails> getAllBorrowDetails();
    BorrowDetails updateBorrowDetail(long detailId, BorrowDetails borrowDetail);
    void deleteBorrowDetail(long detailId);
    List<BorrowDetails> findByTicket(long ticketId);
    List<BorrowDetails> findByCopy(long copyId);
    List<BorrowDetails> findByStatus(String borrowStatus);
}
