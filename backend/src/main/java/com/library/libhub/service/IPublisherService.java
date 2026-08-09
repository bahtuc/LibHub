package com.library.libhub.service;

import com.library.libhub.entity.Publishers;
import java.util.List;
import java.util.Optional;

public interface IPublisherService {
    Publishers createPublisher(Publishers publisher);
    Optional<Publishers> getPublisherById(long publisherId);
    List<Publishers> getAllPublishers();
    Publishers updatePublisher(long publisherId, Publishers publisher);
    void deletePublisher(long publisherId);
    Optional<Publishers> findByName(String publisherName);
}