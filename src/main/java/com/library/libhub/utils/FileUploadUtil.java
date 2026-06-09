package com.library.libhub.utils;

import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.*;
import java.util.UUID;

public class FileUploadUtil {

    private FileUploadUtil() {}

    /**
     * Upload file
     *
     * @param rootDir uploads
     * @param folder books hoặc avatars
     * @param file MultipartFile
     * @return tên file đã lưu
     */
    public static String saveFile(
            String rootDir,
            String folder,
            MultipartFile file) throws IOException {

        // Kiểm tra file
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("File không hợp lệ");
        }

        // Lấy tên gốc
        String originalName = file.getOriginalFilename();

        // Lấy đuôi file
        String extension = "";

        if (originalName != null
                && originalName.contains(".")) {

            extension = originalName.substring(
                    originalName.lastIndexOf("."));
        }

        // Tạo tên file mới
        String newFileName =
                UUID.randomUUID() + extension;

        // uploads/books
        Path uploadPath =
                Paths.get(rootDir, folder);

        // Tạo thư mục nếu chưa có
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        // uploads/books/abc.jpg
        Path filePath =
                uploadPath.resolve(newFileName);

        Files.copy(
                file.getInputStream(),
                filePath,
                StandardCopyOption.REPLACE_EXISTING
        );

        return newFileName;
    }

    /**
     * Xóa file
     */
    public static void deleteFile(
            String rootDir,
            String folder,
            String fileName)
            throws IOException {

        Path path =
                Paths.get(rootDir,
                        folder,
                        fileName);

        Files.deleteIfExists(path);
    }

}