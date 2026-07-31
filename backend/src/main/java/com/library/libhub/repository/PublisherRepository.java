package com.library.libhub.repository;

import com.library.libhub.entity.Publishers;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PublisherRepository extends JpaRepository<Publishers, Long> {

    Optional<Publishers> findByPublisherName(String publisherName);
}