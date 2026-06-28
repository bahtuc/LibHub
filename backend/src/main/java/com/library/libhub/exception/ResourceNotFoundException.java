package com.library.libhub.exception;

/**
 * Ném ra khi không tìm thấy bản ghi theo id/khóa.
 * Được {@code GlobalExceptionHandler} ánh xạ thành HTTP 404.
 */
public class ResourceNotFoundException extends RuntimeException {

    public ResourceNotFoundException(String message) {
        super(message);
    }
}
