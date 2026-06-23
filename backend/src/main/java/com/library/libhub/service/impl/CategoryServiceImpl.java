package com.library.libhub.service.impl;

import com.library.libhub.dao.CategoryDAO;
import com.library.libhub.entity.Categories;
import com.library.libhub.service.ICategoryService;
import com.library.libhub.utils.ValidationUtil;
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
        validateCategory(category);

        categoryDAO.findByCategoryName(category.getCategoryName().trim())
                .ifPresent(c -> {
                    throw new RuntimeException("Tên thể loại đã tồn tại");
                });

        category.setCategoryName(category.getCategoryName().trim());
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
        if (!categoryDAO.existsById(categoryId)) {
            throw new RuntimeException("Category not found with id: " + categoryId);
        }

        validateCategory(category);

        // Tên thể loại không được trùng với thể loại khác
        categoryDAO.findByCategoryName(category.getCategoryName().trim())
                .filter(c -> !c.getCategoryId().equals(categoryId))
                .ifPresent(c -> {
                    throw new RuntimeException("Tên thể loại đã tồn tại");
                });

        category.setCategoryId(categoryId);
        category.setCategoryName(category.getCategoryName().trim());
        return categoryDAO.save(category);
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
