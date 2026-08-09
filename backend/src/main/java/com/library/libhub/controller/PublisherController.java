package com.library.libhub.controller;

import com.library.libhub.entity.Publishers;
import com.library.libhub.service.IPublisherService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/publishers")
public class PublisherController {

    private final IPublisherService publisherService;

    public PublisherController(IPublisherService publisherService) {
        this.publisherService = publisherService;
    }

    @GetMapping
    public ResponseEntity<List<Publishers>> getAllPublishers() {
        return ResponseEntity.ok(publisherService.getAllPublishers());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Optional<Publishers>> getPublisherById(@PathVariable long id) {
        return ResponseEntity.ok(publisherService.getPublisherById(id));
    }

    @PostMapping
    public ResponseEntity<Publishers> createPublisher(@RequestBody Publishers publisher) {
        Publishers createdPublisher = publisherService.createPublisher(publisher);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdPublisher);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Publishers> updatePublisher(@PathVariable long id, @RequestBody Publishers publisher) {
        Publishers updatedPublisher = publisherService.updatePublisher(id, publisher);
        return ResponseEntity.ok(updatedPublisher);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePublisher(@PathVariable long id) {
        publisherService.deletePublisher(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/name")
    public ResponseEntity<Optional<Publishers>> findByName(@RequestParam String name) {
        return ResponseEntity.ok(publisherService.findByName(name));
    }
}