package com.library.libhub.DTO.Request;
import java.util.List;
public record ChatRecommendationRequest(String message, List<ChatTurn> history) {
    public record ChatTurn(String role, String text) {}
}
