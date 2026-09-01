package com.library.libhub.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.beans.factory.annotation.Value;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Autowired
    private LoginInterceptor loginInterceptor;
    private final String[] allowedOriginPatterns;
    private final String uploadRoot;

    public WebConfig(@Value("${library.cors.allowed-origin-patterns:http://localhost:*,http://127.0.0.1:*}")
                     String allowedOriginPatterns,
                     @Value("${library.upload.root:uploads}") String uploadRoot) {
        this.allowedOriginPatterns = allowedOriginPatterns.split("\\s*,\\s*");
        this.uploadRoot = uploadRoot;
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String location = java.nio.file.Paths.get(uploadRoot).toAbsolutePath().normalize().toUri().toString();
        if (!location.endsWith("/")) {
            location += "/";
        }
        registry.addResourceHandler("/uploads/**").addResourceLocations(location);
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
                        "/api/chat/recommendations",
                        "/uploads/**"
                );
    }
}
