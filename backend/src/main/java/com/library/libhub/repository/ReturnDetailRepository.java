package com.library.libhub.repository;

import com.library.libhub.entity.ReturnDetails;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReturnDetailRepository extends JpaRepository<ReturnDetails, Long> {

    List<ReturnDetails> findByReturnId(Long returnId);

    List<ReturnDetails> findByCopyId(Long copyId);

    List<ReturnDetails> findByConditionBook(String conditionBook);

    boolean existsByCopyId(Long copyId);
}
