package com.library.libhub.utils;

import java.util.Date;

import org.springframework.stereotype.Component;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;

import java.security.Key;

@Component
public class JwtUtil {

    private final String SECRET = "libhub-secret-key-123456789-libhub-secret";

    private final long EXPIRATION = 1000 * 60 * 60 * 24; // 1 day

    private Key getKey() {
        return Keys.hmacShaKeyFor(SECRET.getBytes());
    }

    // CREATE TOKEN
    public String generateToken(String username, String role) {

        return Jwts.builder()
                .setSubject(username)
                .claim("role", role)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION))
                .signWith(getKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    // GET USERNAME
    public String extractUsername(String token) {
        return getClaims(token).getSubject();
    }

    // VALIDATE TOKEN
    public boolean isValid(String token) {
        try {
            getClaims(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    private Claims getClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }
}