package com.library.libhub.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import com.library.libhub.entity.ReturnDetails;

@Repository
public interface ReturnDetailRepository extends JpaRepository<ReturnDetails, Long> {

    List<ReturnDetails> findByReturnId(Long returnId);

}