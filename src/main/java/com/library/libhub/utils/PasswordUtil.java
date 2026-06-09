package com.library.libhub.utils;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordUtil {

    private static final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    private PasswordUtil() {
    }

    // Mã hóa mật khẩu
    public static String hash(String password) {
        return encoder.encode(password);
    }

    // Kiểm tra mật khẩu
    public static boolean matches(String rawPassword,
            String encodedPassword) {

        return encoder.matches(rawPassword, encodedPassword);
    }
}