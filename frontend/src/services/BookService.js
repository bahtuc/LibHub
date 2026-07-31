import { apiRequest } from "../JS/APi.js";

// GET /api/books — paginated + searchable list. Returns a PageResponse.
export function getBooks({ page = 0, size = 10, sortBy = "title", sortDir = "asc", keyword, includeHidden = false } = {}) {
    const params = new URLSearchParams({ page, size, sortBy, sortDir });
    if (keyword) params.set("keyword", keyword);
    if (includeHidden) params.set("includeHidden", "true");
    return apiRequest(`/books?${params.toString()}`, { method: "GET" });
}

export function getBookById(id) {
    return apiRequest(`/books/${id}`, { method: "GET" });
}

export function createBook(payload) {
    return apiRequest("/books", { method: "POST", body: payload });
}

export function updateBook(id, payload) {
    return apiRequest(`/books/${id}`, { method: "PUT", body: payload });
}

export function deleteBook(id) {
    return apiRequest(`/books/${id}`, { method: "DELETE" });
}

export function findBookByIsbn(isbn) {
    return apiRequest(`/books/isbn/${isbn}`, { method: "GET" });
}

export function findBooksByCategory(categoryId) {
    return apiRequest(`/books/category/${categoryId}`, { method: "GET" });
}

export function findBooksByAuthor(authorId) {
    return apiRequest(`/books/author/${authorId}`, { method: "GET" });
}

export function searchBooksByTitle(keyword) {
    return apiRequest(`/books/search?keyword=${encodeURIComponent(keyword)}`, { method: "GET" });
}
