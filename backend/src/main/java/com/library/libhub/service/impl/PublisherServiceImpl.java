package com.library.libhub.service.impl;

import com.library.libhub.dao.PublisherDAO;
import com.library.libhub.entity.Publishers;
import com.library.libhub.service.IPublisherService;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class PublisherServiceImpl implements IPublisherService {

    private final PublisherDAO publisherDAO;

    public PublisherServiceImpl(PublisherDAO publisherDAO) {
        this.publisherDAO = publisherDAO;
    }

    @Override
    public Publishers createPublisher(Publishers publisher) {
        return publisherDAO.save(publisher);
    }

    @Override
    public Optional<Publishers> getPublisherById(long publisherId) {
        return publisherDAO.findById(publisherId);
    }

    @Override
    public List<Publishers> getAllPublishers() {
        return publisherDAO.findAll();
    }

    @Override
    public Publishers updatePublisher(long publisherId, Publishers publisher) {
        if (publisherDAO.existsById(publisherId)) {
            publisher.setPublisherId(publisherId);
            return publisherDAO.save(publisher);
        }
        throw new RuntimeException("Publisher not found with id: " + publisherId);
    }

    @Override
    public void deletePublisher(long publisherId) {
        if (publisherDAO.existsById(publisherId)) {
            publisherDAO.deleteById(publisherId);
        } else {
            throw new RuntimeException("Publisher not found with id: " + publisherId);
        }
    }

    @Override
    public Optional<Publishers> findByName(String publisherName) {
        return publisherDAO.findByPublisherName(publisherName);
    }
}
