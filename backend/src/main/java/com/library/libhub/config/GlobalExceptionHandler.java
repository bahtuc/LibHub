package com.library.libhub.config;

import java.sql.Timestamp;
import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import com.library.libhub.exception.ResourceNotFoundException;

import jakarta.servlet.http.HttpServletRequest;

@RestControllerAdvice
public class GlobalExceptionHandler {

    // Không tìm thấy bản ghi → 404
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<Map<String, Object>> handleNotFound(
            ResourceNotFoundException ex,
            HttpServletRequest request) {

        return build(HttpStatus.NOT_FOUND, ex.getMessage(), request);
    }

    // Lỗi nghiệp vụ / validation → trả về 400 kèm message
    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<Map<String, Object>> handleRuntime(
            RuntimeException ex,
            HttpServletRequest request) {

        return build(HttpStatus.BAD_REQUEST, ex.getMessage(), request);
    }

    // Các lỗi còn lại → 500, vẫn kèm message để dễ debug
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleOther(
            Exception ex,
            HttpServletRequest request) {

        return build(HttpStatus.INTERNAL_SERVER_ERROR, ex.getMessage(), request);
    }

    private ResponseEntity<Map<String, Object>> build(
            HttpStatus status,
            String message,
            HttpServletRequest request) {

        Map<String, Object> body = new HashMap<>();
        body.put("timestamp", new Timestamp(System.currentTimeMillis()));
        body.put("status", status.value());
        body.put("error", status.getReasonPhrase());
        body.put("message", message);
        body.put("path", request.getRequestURI());

        return ResponseEntity.status(status).body(body);
    }
}
