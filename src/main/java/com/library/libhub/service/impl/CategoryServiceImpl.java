package com.library.libhub.service.impl;

import com.library.libhub.dao.CategoryDAO;
import com.library.libhub.entity.Categories;
import com.library.libhub.service.ICategoryService;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class CategoryServiceImpl implements ICategoryService {

    private final CategoryDAO categoryDAO;

    public CategoryServiceImpl(CategoryDAO categoryDAO) {
        this.categoryDAO = categoryDAO;
    }

    @Override
    public Categories createCategory(Categories category) {
        return categoryDAO.save(category);
    }

    @Override
    public Optional<Categories> getCategoryById(long categoryId) {
        return categoryDAO.findById(categoryId);
    }

    @Override
    public List<Categories> getAllCategories() {
        return categoryDAO.findAll();
    }

    @Override
    public Categories updateCategory(long categoryId, Categories category) {
        if (categoryDAO.existsById(categoryId)) {
            category.setCategoryId(categoryId);
            return categoryDAO.save(category);
        }
        throw new RuntimeException("Category not found with id: " + categoryId);
    }

    @Override
    public void deleteCategory(long categoryId) {
        if (categoryDAO.existsById(categoryId)) {
            categoryDAO.deleteById(categoryId);
        } else {
            throw new RuntimeException("Category not found with id: " + categoryId);
        }
    }

    @Override
    public Optional<Categories> findByName(String categoryName) {
        return categoryDAO.findByCategoryName(categoryName);
    }
}
