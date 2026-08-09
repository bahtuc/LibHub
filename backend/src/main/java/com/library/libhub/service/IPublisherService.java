package com.library.libhub.service;

import com.library.libhub.entity.Publishers;
import java.util.List;
import java.util.Optional;

public interface IPublisherService {
    Publishers createPublisher(Publishers publisher);
    Optional<Publishers> getPublisherById(Long publisherId);
    List<Publishers> getAllPublishers();
    Publishers updatePublisher(Long publisherId, Publishers publisher);
    void deletePublisher(Long publisherId);
    Optional<Publishers> findByName(String publisherName);
}
