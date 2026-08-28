package com.library.libhub.service;

import java.util.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import com.library.libhub.DTO.Request.ChatRecommendationRequest;
import com.library.libhub.DTO.Response.ChatRecommendationResponse;
import com.library.libhub.DTO.Response.ChatRecommendationResponse.BookSuggestion;
import com.library.libhub.entity.Books;
import com.library.libhub.repository.BookRepository;

@Service
public class GeminiBookRecommendationService {
    private final BookRepository books;
    private final RestClient gemini;
    private final ObjectMapper json;
    private final String apiKey;
    private final String model;

    public GeminiBookRecommendationService(BookRepository books, RestClient.Builder builder, ObjectMapper json,
            @Value("${gemini.api-key:${GEMINI_API_KEY:AIzaSyCv_pR_QLGEs5tnWQ8d-2U-FyGr9Ytq76I}}") String apiKey,
            @Value("${gemini.model:gemini-2.5-flash}") String model) {
        this.books = books;
        this.gemini = builder.baseUrl("https://generativelanguage.googleapis.com").build();
        this.json = json;
        this.apiKey = apiKey;
        this.model = model;
    }

    public ChatRecommendationResponse recommend(ChatRecommendationRequest request) {
        String message = request == null ? "" : Objects.toString(request.message(), "").trim();
        if (message.isEmpty()) throw new IllegalArgumentException("Hãy cho Libby biết bạn muốn đọc gì.");
        if (message.length() > 1200) throw new IllegalArgumentException("Tin nhắn tối đa 1.200 ký tự.");
        if (apiKey.isBlank()) throw new IllegalStateException("Chatbot chưa được cấu hình GEMINI_API_KEY.");

        Map<Long, Books> catalog = new LinkedHashMap<>();
        StringBuilder catalogText = new StringBuilder();
        for (Books book : books.findAllVisible()) {
            catalog.put(book.getBookId(), book);
            String description = Objects.toString(book.getDescription(), "").replaceAll("\\s+", " ");
            if (description.length() > 240) description = description.substring(0, 240) + "…";
            catalogText.append("ID=").append(book.getBookId()).append(" | ").append(book.getTitle())
                    .append(" | ").append(description).append('\n');
        }

        StringBuilder history = new StringBuilder();
        List<ChatRecommendationRequest.ChatTurn> turns = request.history() == null ? List.of() : request.history();
        turns.stream().skip(Math.max(0, turns.size() - 8)).forEach(turn -> {
            String text = Objects.toString(turn.text(), "").replaceAll("\\s+", " ");
            history.append("assistant".equals(turn.role()) ? "LIBBY: " : "BẠN ĐỌC: ")
                    .append(text, 0, Math.min(text.length(), 500)).append('\n');
        });

        String prompt = """
                Bạn là Libby, thủ thư tư vấn sách của LibHub. Trả lời bằng tiếng Việt tự nhiên, ấm áp, ngắn gọn.
                Chỉ giới thiệu sách trong danh mục. Nếu yêu cầu mơ hồ, hãy hỏi thêm. Nếu đủ thông tin, chọn tối đa 4 cuốn phù hợp.
                Không bịa ID hoặc tựa sách. Trả JSON thuần đúng dạng:
                {"reply":"lời tư vấn hoặc câu hỏi","recommendations":[{"bookId":123,"reason":"lý do cụ thể"}]}
                LỊCH SỬ:
                %s
                YÊU CẦU: %s
                DANH MỤC:
                %s
                """.formatted(history, message, catalogText);

        Map<String, Object> body = Map.of(
                "contents", List.of(Map.of("role", "user", "parts", List.of(Map.of("text", prompt)))),
                "generationConfig", Map.of("temperature", 0.45, "maxOutputTokens", 900, "responseMimeType", "application/json"));
        JsonNode response = gemini.post().uri("/v1beta/models/{model}:generateContent", model)
                .header("x-goog-api-key", apiKey).contentType(MediaType.APPLICATION_JSON).body(body)
                .retrieve().body(JsonNode.class);
        String answer = response == null ? "" : response.path("candidates").path(0).path("content").path("parts").path(0).path("text").asText();
        if (answer.isBlank()) throw new IllegalStateException("Gemini không trả về gợi ý. Hãy thử lại.");
        try {
            JsonNode root = json.readTree(answer);
            List<BookSuggestion> suggestions = new ArrayList<>();
            for (JsonNode item : root.path("recommendations")) {
                Books book = catalog.get(item.path("bookId").asLong(-1));
                if (book != null && suggestions.size() < 4)
                    suggestions.add(new BookSuggestion(book.getBookId(), book.getTitle(), book.getCoverImage(), item.path("reason").asText("Phù hợp với bạn.")));
            }
            return new ChatRecommendationResponse(root.path("reply").asText("Mình đã tìm được vài cuốn phù hợp."), suggestions);
        } catch (Exception ex) {
            throw new IllegalStateException("Gemini trả về dữ liệu không hợp lệ. Hãy thử lại.", ex);
        }
    }
}
