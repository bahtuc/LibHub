package com.library.libhub.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.beans.factory.annotation.Value;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Autowired
    private LoginInterceptor loginInterceptor;
    private final String[] allowedOriginPatterns;

    public WebConfig(@Value("${library.cors.allowed-origin-patterns:http://localhost:*,http://127.0.0.1:*}")
                     String allowedOriginPatterns) {
        this.allowedOriginPatterns = allowedOriginPatterns.split("\\s*,\\s*");
    }

    // Cho phép SPA (Vite) gọi API kèm cookie session.
    // Lưu ý: allowCredentials(true) thì KHÔNG được dùng origin "*".
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOriginPatterns(allowedOriginPatterns)
                .allowedMethods("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {

        registry.addInterceptor(loginInterceptor)
                .addPathPatterns("/api/**")   // chặn tất cả API
                .excludePathPatterns(
                        "/api/auth/login",
                        "/api/auth/2fa/verify",
                        "/api/auth/register",
                        "/api/chat/recommendations"
                );
    }
}
