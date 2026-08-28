package com.library.libhub.DTO.Response;
import java.util.List;
public record ChatRecommendationResponse(String reply, List<BookSuggestion> books) {
    public record BookSuggestion(Long bookId, String title, String coverImage, String reason) {}
}
