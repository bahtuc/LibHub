package com.library.libhub.service;

import java.util.List;
import java.util.Optional;

import com.library.libhub.entity.Authors;

public interface IAuthorService {
    Authors createAuthor(Authors author);
    Optional<Authors> getAuthorById(Long authorId);
    List<Authors> getAllAuthors();
    Authors updateAuthor(Long authorId, Authors author);
    void deleteAuthor(Long authorId);
    Optional<Authors> searchByName(String name);
}
