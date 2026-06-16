package com.library.libhub.service;

import java.util.List;
import java.util.Optional;

import com.library.libhub.entity.Authors;

public interface IAuthorService {
    Authors createAuthor(Authors author);
    Optional<Authors> getAuthorById(long authorId);
    List<Authors> getAllAuthors();
    Authors updateAuthor(long authorId, Authors author);
    void deleteAuthor(long authorId);
    Optional<Authors> searchByName(String name);
}
