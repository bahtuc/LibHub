package com.library.libhub.utils;


import java.util.regex.Pattern;

public class ValidationUtil {

    private ValidationUtil() {
    }

    private static final Pattern EMAIL_PATTERN =
            Pattern.compile(
                    "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");

    private static final Pattern PHONE_PATTERN =
            Pattern.compile(
                    "^(0|84)(3|5|7|8|9)[0-9]{8}$");

    // Kiểm tra mail
    public static boolean isEmail(String email) {

        if (email == null || email.isBlank()) {
            return false;
        }

        return EMAIL_PATTERN.matcher(email).matches();
    }

    // kiểm tra số điện thoại
    public static boolean isPhone(String phone) {

        if (phone == null || phone.isBlank()) {
            return false;
        }

        return PHONE_PATTERN.matcher(phone).matches();
    }

    // kiểm tra rỗng
    public static boolean isNotBlank(String value) {

        return value != null
                && !value.trim().isEmpty();
    }

    // Độ dài thối thiểu
    public static boolean minLength(
            String value,
            int length) {

        if (value == null) {
            return false;
        }

        return value.length() >= length;
    }

    // Độ dài tối đa
    public static boolean maxLength(
            String value,
            int length) {

        if (value == null) {
            return false;
        }

        return value.length() <= length;
    }

    /**
     * Mật khẩu mạnh
     * >=8 ký tự
     * 1 chữ hoa
     * 1 chữ thường
     * 1 số
     */
    public static boolean isStrongPassword(
            String password) {

        if (password == null) {
            return false;
        }

        return password.matches(
                "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$");
    }
}
