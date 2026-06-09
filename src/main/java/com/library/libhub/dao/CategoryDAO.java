package com.library.libhub.dao;

import com.library.libhub.entity.Categories;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CategoryDAO extends JpaRepository<Categories, Long> {

    Optional<Categories> findByCategoryName(String categoryName);
}