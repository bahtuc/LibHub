package com.library.libhub.service.impl;

import com.library.libhub.exception.ResourceNotFoundException;
import com.library.libhub.repository.AuthorRepository;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.library.libhub.entity.Authors;
import com.library.libhub.service.IAuthorService;
import com.library.libhub.utils.ValidationUtil;

import jakarta.transaction.Transactional;

@Service
@Transactional
public class AuthorServiceImpl implements IAuthorService {

    private final AuthorRepository authorRepo;

    public AuthorServiceImpl(AuthorRepository authorRepo) {
        this.authorRepo = authorRepo;
    }

    @Override
    public Authors createAuthor(Authors author) {
        validateAuthor(author);

        authorRepo.findByAuthorName(author.getAuthorName().trim())
                .ifPresent(a -> {
                    throw new RuntimeException("Tên tác giả đã tồn tại");
                });

        author.setAuthorName(author.getAuthorName().trim());
        return authorRepo.save(author);
    }

    @Override
    public Optional<Authors> getAuthorById(Long authorId) {
        return authorRepo.findById(authorId);
    }

    @Override
    public List<Authors> getAllAuthors() {
        return authorRepo.findAll();
    }

    @Override
    public Authors updateAuthor(Long authorId, Authors author) {
        if (!authorRepo.existsById(authorId)) {
            throw new ResourceNotFoundException("Author not found with id: " + authorId);
        }

        validateAuthor(author);

        authorRepo.findByAuthorName(author.getAuthorName().trim())
                .filter(a -> !a.getAuthorId().equals(authorId))
                .ifPresent(a -> {
                    throw new RuntimeException("Tên tác giả đã tồn tại");
                });

        author.setAuthorId(authorId);
        author.setAuthorName(author.getAuthorName().trim());
        return authorRepo.save(author);
    }

    @Override
    public void deleteAuthor(Long authorId) {
        if (authorRepo.existsById(authorId)) {
            authorRepo.deleteById(authorId);
        } else {
            throw new ResourceNotFoundException("Author not found with id: " + authorId);
        }
    }

    @Override
    public Optional<Authors> searchByName(String name) {
        return authorRepo.findAll().stream()
                .filter(a -> a.getAuthorName().toLowerCase().contains(name.toLowerCase()))
                .findFirst();
    }

    // ================= VALIDATE =================
    private void validateAuthor(Authors author) {

        if (author == null) {
            throw new RuntimeException("Dữ liệu không hợp lệ");
        }

        if (!ValidationUtil.isNotBlank(author.getAuthorName())) {
            throw new RuntimeException("Tên tác giả không được để trống");
        }

        if (!ValidationUtil.maxLength(author.getAuthorName().trim(), 100)) {
            throw new RuntimeException("Tên tác giả không được vượt quá 100 ký tự");
        }

        if (author.getBiography() != null
                && !ValidationUtil.maxLength(author.getBiography(), 1000)) {
            throw new RuntimeException("Tiểu sử không được vượt quá 1000 ký tự");
        }
    }

}


