package com.library.libhub.service.impl;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import org.junit.jupiter.api.Test;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.library.libhub.entity.Fines;
import com.library.libhub.repository.FineRepository;

class FineServiceImplTest {

    private final FineRepository repo = mock(FineRepository.class);
    private final FineServiceImpl service = new FineServiceImpl(repo);


    @Test
    void createRejectsNonPositiveAmount() {

        Fines fine = new Fines();

        fine.setReturnDetailId(1L);
        fine.setAmount(BigDecimal.ZERO);

        assertThrows(
            IllegalArgumentException.class,
            () -> service.createFine(fine)
        );
    }


    @Test
    void updatePaidStatusDoesNotEraseFineData() {

        Fines existing = new Fines();

        existing.setFineId(3L);
        existing.setReturnDetailId(8L);
        existing.setAmount(new BigDecimal("15000"));
        existing.setReason("Overdue");
        existing.setPaidStatus("Unpaid");
        existing.setCreatedAt(new Timestamp(1));


        Fines patch = new Fines();
        patch.setPaidStatus("Paid");


        when(repo.findById(3L))
                .thenReturn(Optional.of(existing));

        when(repo.save(existing))
                .thenReturn(existing);


        Fines result = service.updateFine(3L, patch);


        assertEquals("Paid", result.getPaidStatus());

        assertEquals(
            new BigDecimal("15000"),
            result.getAmount()
        );

        assertEquals("Overdue", result.getReason());

        assertEquals(
            8L,
            result.getReturnDetailId()
        );
    }
}