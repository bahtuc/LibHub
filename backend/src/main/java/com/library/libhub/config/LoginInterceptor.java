package com.library.libhub.config;

import org.springframework.stereotype.Component;
import org.springframework.web.cors.CorsUtils;
import org.springframework.web.servlet.HandlerInterceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

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

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("USER_LOGIN") == null) {

            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("Chưa đăng nhập");
            return false;
        }

        return true;
    }
}