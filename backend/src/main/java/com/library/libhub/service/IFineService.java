package com.library.libhub.service;

import com.library.libhub.entity.Fines;
import java.util.List;
import java.util.Optional;

public interface IFineService {
    Fines createFine(Fines fine);
    Optional<Fines> getFineById(Long fineId);
    List<Fines> getAllFines();
    Fines updateFine(Long fineId, Fines fine);
    void deleteFine(Long fineId);
    List<Fines> findByReturnDetail(Long returnDetailId);
    List<Fines> findByPaidStatus(String paidStatus);
    List<Fines> findByUser(Long userId);
}
