package com.library.libhub.repository;

import com.library.libhub.entity.Categories;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CategoryRepository extends JpaRepository<Categories, Long> {

    Optional<Categories> findByCategoryName(String categoryName);
}