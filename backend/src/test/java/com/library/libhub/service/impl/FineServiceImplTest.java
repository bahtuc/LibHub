package com.library.libhub.service.impl;

import com.library.libhub.entity.Fines;
import com.library.libhub.repository.FineRepository;

import org.junit.jupiter.api.Test;

import java.sql.Timestamp;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class FineServiceImplTest {
    private final FineRepository Repo = mock(FineRepository.class);
    private final FineServiceImpl service = new FineServiceImpl(Repo);

    @Test
    void createRejectsNonPositiveAmount() {
        Fines fine = new Fines();
        fine.setReturnDetailId(1L);
        fine.setAmount(0d);
        assertThrows(IllegalArgumentException.class, () -> service.createFine(fine));
    }

    @Test
    void updatePaidStatusDoesNotEraseFineData() {
        Fines existing = new Fines();
        existing.setFineId(3L);
        existing.setReturnDetailId(8L);
        existing.setAmount(15000d);
        existing.setReason("Overdue");
        existing.setPaidStatus("Unpaid");
        existing.setCreatedAt(new Timestamp(1));
        Fines patch = new Fines();
        patch.setPaidStatus("Paid");
        when(Repo.findById(3L)).thenReturn(Optional.of(existing));
        when(Repo.save(existing)).thenReturn(existing);

        Fines result = service.updateFine(3L, patch);

        assertEquals("Paid", result.getPaidStatus());
        assertEquals(15000d, result.getAmount());
        assertEquals("Overdue", result.getReason());
        assertEquals(8L, result.getReturnDetailId());
    }
}
