package com.library.libhub.service.impl;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.library.libhub.entity.Categories;
import com.library.libhub.exception.ResourceNotFoundException;
import com.library.libhub.repository.CategoryRepository;
import com.library.libhub.service.ICategoryService;
import com.library.libhub.utils.ValidationUtil;

import jakarta.transaction.Transactional;

@Service
@Transactional
public class CategoryServiceImpl implements ICategoryService {

    private final CategoryRepository categoryRepo;

    public CategoryServiceImpl(CategoryRepository categoryRepo) {
        this.categoryRepo = categoryRepo;
    }

    @Override
    public Categories createCategory(Categories category) {
        validateCategory(category);

        categoryRepo.findByCategoryName(category.getCategoryName().trim())
                .ifPresent(c -> {
                    throw new RuntimeException("Tên thể loại đã tồn tại");
                });

        category.setCategoryName(category.getCategoryName().trim());
        return categoryRepo.save(category);
    }

    @Override
    public Optional<Categories> getCategoryById(long categoryId) {
        return categoryRepo.findById(categoryId);
    }

    @Override
    public List<Categories> getAllCategories() {
        return categoryRepo.findAll();
    }

    @Override
    public Categories updateCategory(long categoryId, Categories category) {
        if (!categoryRepo.existsById(categoryId)) {
            throw new ResourceNotFoundException("Category not found with id: " + categoryId);
        }

        validateCategory(category);

        // Tên thể loại không được trùng với thể loại khác
        categoryRepo.findByCategoryName(category.getCategoryName().trim())
                .filter(c -> !c.getCategoryId().equals(categoryId))
                .ifPresent(c -> {
                    throw new RuntimeException("Tên thể loại đã tồn tại");
                });

        category.setCategoryId(categoryId);
        category.setCategoryName(category.getCategoryName().trim());
        return categoryRepo.save(category);
    }

    @Override
    public void deleteCategory(long categoryId) {
        if (categoryRepo.existsById(categoryId)) {
            categoryRepo.deleteById(categoryId);
        } else {
            throw new ResourceNotFoundException("Category not found with id: " + categoryId);
        }
    }

    @Override
    public Optional<Categories> findByName(String categoryName) {
        return categoryRepo.findByCategoryName(categoryName);
    }

    // ================= VALIDATE =================
    private void validateCategory(Categories category) {

        if (category == null) {
            throw new RuntimeException("Dữ liệu không hợp lệ");
        }

        if (!ValidationUtil.isNotBlank(category.getCategoryName())) {
            throw new RuntimeException("Tên thể loại không được để trống");
        }

        if (!ValidationUtil.maxLength(category.getCategoryName().trim(), 100)) {
            throw new RuntimeException("Tên thể loại không được vượt quá 100 ký tự");
        }

        if (category.getDescription() != null
                && !ValidationUtil.maxLength(category.getDescription(), 500)) {
            throw new RuntimeException("Mô tả không được vượt quá 500 ký tự");
        }
    }
}
