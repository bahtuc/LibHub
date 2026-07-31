package com.library.libhub.service;

import com.library.libhub.entity.Fines;
import java.util.List;
import java.util.Optional;

public interface IFineService {
    Fines createFine(Fines fine);
    Optional<Fines> getFineById(long fineId);
    List<Fines> getAllFines();
    Fines updateFine(long fineId, Fines fine);
    void deleteFine(long fineId);
    List<Fines> findByReturnDetail(long returnDetailId);
    List<Fines> findByPaidStatus(String paidStatus);
    List<Fines> findByUser(long userId);
}
