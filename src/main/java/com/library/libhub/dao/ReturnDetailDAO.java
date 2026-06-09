package com.library.libhub.dao;

import com.library.libhub.entity.ReturnDetails;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReturnDetailDAO extends JpaRepository<ReturnDetails, Long> {

    List<ReturnDetails> findByReturnId(long returnId);

    List<ReturnDetails> findByCopyId(long copyId);

    List<ReturnDetails> findByConditionBook(String conditionBook);
}