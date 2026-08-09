package com.library.libhub.service;

import com.library.libhub.entity.Categories;
import java.util.List;
import java.util.Optional;

public interface ICategoryService {
    Categories createCategory(Categories category);
    Optional<Categories> getCategoryById(Long categoryId);
    List<Categories> getAllCategories();
    Categories updateCategory(Long categoryId, Categories category);
    void deleteCategory(Long categoryId);
    Optional<Categories> findByName(String categoryName);
}
