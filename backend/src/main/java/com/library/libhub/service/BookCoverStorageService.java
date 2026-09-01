package com.library.libhub.service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class BookCoverStorageService {

    private static final Set<String> ALLOWED_EXTENSIONS = Set.of(".jpg", ".jpeg", ".png", ".webp");
    private final Path booksDirectory;

    public BookCoverStorageService(@Value("${library.upload.root:uploads}") String uploadRoot) {
        this.booksDirectory = Paths.get(uploadRoot).toAbsolutePath().normalize().resolve("books");
    }

    public String save(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return null;
        }

        String contentType = file.getContentType();
        String originalName = file.getOriginalFilename() == null ? "" : file.getOriginalFilename();
        String extension = extensionOf(originalName);
        if (contentType == null || !contentType.toLowerCase(Locale.ROOT).startsWith("image/")
                || !ALLOWED_EXTENSIONS.contains(extension)) {
            throw new IllegalArgumentException("Ảnh bìa phải có định dạng JPG, PNG hoặc WEBP");
        }

        try {
            Files.createDirectories(booksDirectory);
            String fileName = UUID.randomUUID() + extension;
            Path destination = booksDirectory.resolve(fileName).normalize();
            if (!destination.startsWith(booksDirectory)) {
                throw new IllegalArgumentException("Tên file ảnh không hợp lệ");
            }
            file.transferTo(destination);
            return "/uploads/books/" + fileName;
        } catch (IOException ex) {
            throw new IllegalStateException("Không thể lưu ảnh bìa", ex);
        }
    }

    public void delete(String coverPath) {
        if (coverPath == null || !coverPath.startsWith("/uploads/books/")) {
            return;
        }

        Path target = booksDirectory.resolve(coverPath.substring("/uploads/books/".length())).normalize();
        if (!target.startsWith(booksDirectory)) {
            return;
        }
        try {
            Files.deleteIfExists(target);
        } catch (IOException ex) {
            throw new IllegalStateException("Không thể xóa ảnh bìa cũ", ex);
        }
    }

    private String extensionOf(String fileName) {
        int dot = fileName.lastIndexOf('.');
        return dot < 0 ? "" : fileName.substring(dot).toLowerCase(Locale.ROOT);
    }
}
