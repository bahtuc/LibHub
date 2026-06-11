package com.library.libhub.service;

import com.library.libhub.entity.Authors;
import java.util.List;
import java.util.Optional;

public interface IAuthorService {
    Authors createAuthor(Authors author);
    Optional<Authors> getAuthorById(long authorId);
    List<Authors> getAllAuthors();
    Authors updateAuthor(long authorId, Authors author);
    void deleteAuthor(long authorId);
    Optional<Authors> searchByName(String name);
}
