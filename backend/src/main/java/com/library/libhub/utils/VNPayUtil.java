package com.library.libhub.utils;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public final class VNPayUtil {

    private VNPayUtil() {
    }

    public static String hmacSHA512(String key, String data) {
        try {
            Mac mac = Mac.getInstance("HmacSHA512");
            SecretKeySpec secretKey = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512");
            mac.init(secretKey);
            byte[] bytes = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(2 * bytes.length);
            for (byte b : bytes) {
                sb.append(String.format("%02x", b & 0xff));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("Không tạo được chữ ký VNPay", e);
        }
    }

    private static String enc(String value) {
        return URLEncoder.encode(value, StandardCharsets.US_ASCII);
    }

    public static String buildHashData(Map<String, String> params) {
        TreeMap<String, String> sorted = new TreeMap<>(params);
        List<String> parts = new ArrayList<>();
        for (Map.Entry<String, String> e : sorted.entrySet()) {
            if (e.getValue() == null || e.getValue().isEmpty()) {
                continue;
            }
            parts.add(enc(e.getKey()) + "=" + enc(e.getValue()));
        }
        return String.join("&", parts);
    }

    public static String buildQuery(Map<String, String> params) {
        return buildHashData(params);
    }

    public static boolean verifySignature(Map<String, String> allParams, String hashSecret) {
        Map<String, String> params = new TreeMap<>(allParams);
        String received = params.remove("vnp_SecureHash");
        params.remove("vnp_SecureHashType");
        if (received == null) {
            return false;
        }
        String calculated = hmacSHA512(hashSecret, buildHashData(params));
        return calculated.equalsIgnoreCase(received);
    }

    public static String randomTxnRef() {
        SecureRandom rnd = new SecureRandom();
        StringBuilder sb = new StringBuilder(8);
        for (int i = 0; i < 8; i++) {
            sb.append(rnd.nextInt(10));
        }
        return sb.toString();
    }
}
