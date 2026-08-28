package com.library.libhub.controller;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.library.libhub.DTO.Request.ChatRecommendationRequest;
import com.library.libhub.DTO.Response.ChatRecommendationResponse;
import com.library.libhub.service.GeminiBookRecommendationService;
@RestController
@RequestMapping("/api/chat/recommendations")
public class ChatRecommendationController {
    private final GeminiBookRecommendationService service;
    public ChatRecommendationController(GeminiBookRecommendationService service) { this.service = service; }
    @PostMapping
    public ResponseEntity<ChatRecommendationResponse> recommend(@RequestBody ChatRecommendationRequest request) {
        return ResponseEntity.ok(service.recommend(request));
    }
}
