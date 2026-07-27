package com.library.libhub.config;

import org.springframework.stereotype.Component;
import org.springframework.web.cors.CorsUtils;
import org.springframework.web.servlet.HandlerInterceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.nio.charset.StandardCharsets;

@Component
public class LoginInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(
            HttpServletRequest request,
            HttpServletResponse response,
            Object handler) throws Exception {

        // Cho qua CORS preflight (OPTIONS): trình duyệt không gửi cookie kèm
        // preflight, nên nếu chặn ở đây sẽ trả 401 và fetch() báo lỗi mạng.
        if (CorsUtils.isPreFlightRequest(request)) {
            return true;
        }

        // The public React catalogue must be browseable before a visitor logs in.
        if ("GET".equalsIgnoreCase(request.getMethod()) &&
                (request.getRequestURI().startsWith("/api/books") ||
                 request.getRequestURI().startsWith("/api/categories") ||
                 request.getRequestURI().startsWith("/api/authors") ||
                 request.getRequestURI().startsWith("/api/book-copies"))) {
            return true;
        }

        if (request.getRequestURI().equals("/api/payments/vnpay/return")) return true;
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("USER_LOGIN") == null) {
            writeTextResponse(response, HttpServletResponse.SC_UNAUTHORIZED, "Chưa đăng nhập");
            return false;
        }

        String role = String.valueOf(session.getAttribute("ROLE"));
        String path = request.getRequestURI();
        if (path.equals("/api/auth/me") || path.equals("/api/auth/logout") ||
                path.equals("/api/auth/profile") || path.equals("/api/auth/change-password") ||
                path.equals("/api/borrow-tickets/history") ||
                path.startsWith("/api/payments/")) return true;
        if ("Admin".equalsIgnoreCase(role)) return true;
        boolean librarianEndpoint = path.startsWith("/api/books") || path.startsWith("/api/book-copies") ||
                path.startsWith("/api/borrow-tickets") || path.startsWith("/api/borrow-details") ||
                path.startsWith("/api/returns") || path.startsWith("/api/return-details") || path.startsWith("/api/fines");
        if ("Librarian".equalsIgnoreCase(role) && librarianEndpoint) return true;
        writeTextResponse(response, HttpServletResponse.SC_FORBIDDEN, "Không có quyền truy cập");
        return false;
    }

    private void writeTextResponse(HttpServletResponse response, int status, String message) throws Exception {
        response.setStatus(status);
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.setContentType("text/plain;charset=UTF-8");
        response.getWriter().write(message);
    }
}
