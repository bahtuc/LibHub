package com.library.libhub.utils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

public class DateTimeUtil {

    private DateTimeUtil() {
    }

    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private static final DateTimeFormatter DATETIME_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");

    // Ngày hiện tại
    public static LocalDate today() {
        return LocalDate.now();
    }

    // thời gian hiện tại
    public static LocalDateTime now() {
        return LocalDateTime.now();
    }

    // Format LocalDate
    public static String format(LocalDate date) {

        if (date == null) {
            return "";
        }

        return date.format(DATE_FORMAT);
    }

    // Format LocalDateTime
    public static String format(LocalDateTime dateTime) {

        if (dateTime == null) {
            return "";
        }

        return dateTime.format(DATETIME_FORMAT);
    }

    // Parse String -> LocalDate
    public static LocalDate parseDate(String date) {
        return LocalDate.parse(date, DATE_FORMAT);
    }

    //Parse String -> LocalDateTime
    public static LocalDateTime parseDateTime(String dateTime) {
        return LocalDateTime.parse(dateTime, DATETIME_FORMAT);
    }

    // tính tổng ngày 
    public static LocalDate addDays(
            LocalDate date,
            int days) {

        return date.plusDays(days);
    }

    //trừ ngày 
    public static LocalDate subtractDays(
            LocalDate date,
            int days) {

        return date.minusDays(days);
    }

    // kiểm tra quá hạn
    public static boolean isOverdue(LocalDate dueDate) {

        return dueDate.isBefore(LocalDate.now());
    }

    //đầu ngày
    public static LocalDateTime startOfDay(LocalDate date) {

        return date.atStartOfDay();
    }

    //cuối ngày
    public static LocalDateTime endOfDay(LocalDate date) {

        return date.atTime(LocalTime.MAX);
    }
}
