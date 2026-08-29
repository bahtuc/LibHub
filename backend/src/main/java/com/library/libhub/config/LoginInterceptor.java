package com.library.libhub.config;

import java.nio.charset.StandardCharsets;

import org.jspecify.annotations.NullMarked;
import org.springframework.stereotype.Component;
import org.springframework.web.cors.CorsUtils;
import org.springframework.web.servlet.HandlerInterceptor;

import com.library.libhub.entity.Users;
import com.library.libhub.repository.UserRepository;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@Component
public class LoginInterceptor implements HandlerInterceptor {
    private final UserRepository userRepo;

    public LoginInterceptor(UserRepository userRepo) {
        this.userRepo = userRepo;
    }

    @Override
    @NullMarked
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {
        if (CorsUtils.isPreFlightRequest(request))
            return true;
        String path = request.getServletPath();
        if ("GET".equalsIgnoreCase(request.getMethod()) && isPublicCataloguePath(path))
            return true;
        if (path.equals("/api/payments/vnpay/return")
                || path.equals("/api/payments/vnpay/ipn"))
            return true;

        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("USER_LOGIN") instanceof Users sessionUser)
                || sessionUser.getUserId() == null) {
            return reject(response, HttpServletResponse.SC_UNAUTHORIZED, "Chưa đăng nhập");
        }
        Users user = userRepo.findById(sessionUser.getUserId()).orElse(null);
        if (user == null || !"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            session.invalidate();
            return reject(response, HttpServletResponse.SC_UNAUTHORIZED, "Tài khoản đã bị khóa hoặc không tồn tại");
        }
        String role = user.getRole() == null ? "" : user.getRole().getRoleName();
        session.setAttribute("USER_LOGIN", user);
        session.setAttribute("ROLE", role);

        if (isSelfServicePath(path))
            return true;
        if ("Admin".equalsIgnoreCase(role))
            return true;
        if ("Librarian".equalsIgnoreCase(role) && isLibrarianPath(path))
            return true;
        return reject(response, HttpServletResponse.SC_FORBIDDEN, "Không có quyền truy cập");
    }

    private boolean isPublicCataloguePath(String path) {
        return path.startsWith("/api/books")
                || path.startsWith("/api/categories")
                || path.startsWith("/api/authors")
                || path.startsWith("/api/publishers");
    }

    private boolean isSelfServicePath(String path) {
        return path.equals("/api/auth/me") || path.equals("/api/auth/logout")
                || path.equals("/api/auth/profile") || path.equals("/api/auth/change-password")
                || path.equals("/api/auth/two-factor")
                || path.equals("/api/borrow-tickets/history")
                || path.equals("/api/borrow-tickets/history/details")
                || path.equals("/api/borrow-tickets/borrow")
                || path.startsWith("/api/payments/");
    }

    private boolean isLibrarianPath(String path) {
        return path.startsWith("/api/books") || path.startsWith("/api/book-copies")
                || path.startsWith("/api/borrow-tickets") || path.startsWith("/api/borrow-details")
                || path.startsWith("/api/returns") || path.startsWith("/api/return-details")
                || path.startsWith("/api/fines") || path.startsWith("/api/statistics")
                || path.startsWith("/api/reports")
                || path.equals("/api/users/borrowers");
    }

    private boolean reject(HttpServletResponse response, int status, String message) throws Exception {
        response.setStatus(status);
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.setContentType("text/plain;charset=UTF-8");
        response.getWriter().write(message);
        return false;
    }
}
