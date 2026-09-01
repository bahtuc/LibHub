package com.library.libhub.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.nio.file.Files;
import java.nio.file.Path;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.mock.web.MockMultipartFile;

class BookCoverStorageServiceTest {

    @TempDir
    Path tempDir;

    @Test
    void savesAndDeletesSupportedImage() {
        BookCoverStorageService storage = new BookCoverStorageService(tempDir.toString());
        MockMultipartFile image = new MockMultipartFile(
                "cover", "book.png", "image/png", new byte[] { 1, 2, 3 });

        String storedPath = storage.save(image);
        Path file = tempDir.resolve("books").resolve(storedPath.substring(storedPath.lastIndexOf('/') + 1));

        assertTrue(storedPath.matches("/uploads/books/[0-9a-f-]+\\.png"));
        assertTrue(Files.exists(file));
        storage.delete(storedPath);
        assertFalse(Files.exists(file));
    }

    @Test
    void rejectsNonImageFile() {
        BookCoverStorageService storage = new BookCoverStorageService(tempDir.toString());
        MockMultipartFile text = new MockMultipartFile(
                "cover", "notes.txt", "text/plain", "not an image".getBytes());

        IllegalArgumentException error = assertThrows(IllegalArgumentException.class, () -> storage.save(text));
        assertEquals("Ảnh bìa phải có định dạng JPG, PNG hoặc WEBP", error.getMessage());
    }
}
