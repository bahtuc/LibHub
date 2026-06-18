package com.library.libhub.dao;

import com.library.libhub.entity.Fines;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FineDAO extends JpaRepository<Fines, Long> {

    List<Fines> findByReturnDetailId(long returnDetailId);

    List<Fines> findByPaidStatus(String paidStatus);
}