package com.library.libhub.service;

import com.library.libhub.entity.Categories;
import java.util.List;
import java.util.Optional;

public interface ICategoryService {
    Categories createCategory(Categories category);
    Optional<Categories> getCategoryById(long categoryId);
    List<Categories> getAllCategories();
    Categories updateCategory(long categoryId, Categories category);
    void deleteCategory(long categoryId);
    Optional<Categories> findByName(String categoryName);
}
