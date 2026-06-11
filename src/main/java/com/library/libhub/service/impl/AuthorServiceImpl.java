package com.library.libhub.service.impl;

import com.library.libhub.dao.AuthorDAO;
import com.library.libhub.entity.Authors;
import com.library.libhub.service.IAuthorService;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class AuthorServiceImpl implements IAuthorService {

    private final AuthorDAO authorDAO;

    public AuthorServiceImpl(AuthorDAO authorDAO) {
        this.authorDAO = authorDAO;
    }

    @Override
    public Authors createAuthor(Authors author) {
        return authorDAO.save(author);
    }

    @Override
    public Optional<Authors> getAuthorById(long authorId) {
        return authorDAO.findById(authorId);
    }

    @Override
    public List<Authors> getAllAuthors() {
        return authorDAO.findAll();
    }

    @Override
    public Authors updateAuthor(long authorId, Authors author) {
        if (authorDAO.existsById(authorId)) {
            author.setAuthorId(authorId);
            return authorDAO.save(author);
        }
        throw new RuntimeException("Author not found with id: " + authorId);
    }

    @Override
    public void deleteAuthor(long authorId) {
        if (authorDAO.existsById(authorId)) {
            authorDAO.deleteById(authorId);
        } else {
            throw new RuntimeException("Author not found with id: " + authorId);
        }
    }

    @Override
    public Optional<Authors> searchByName(String name) {
        return authorDAO.findAll().stream()
                .filter(a -> a.getAuthorName().toLowerCase().contains(name.toLowerCase()))
                .findFirst();
    }
}
