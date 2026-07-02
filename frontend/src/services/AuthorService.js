import { apiRequest } from "../JS/APi.js";

export function getAuthors() {
    return apiRequest("/authors", { method: "GET" });
}

export function getAuthorById(id) {
    return apiRequest(`/authors/${id}`, { method: "GET" });
}

export function createAuthor(payload) {
    return apiRequest("/authors", { method: "POST", body: payload });
}

export function updateAuthor(id, payload) {
    return apiRequest(`/authors/${id}`, { method: "PUT", body: payload });
}

export function deleteAuthor(id) {
    return apiRequest(`/authors/${id}`, { method: "DELETE" });
}

export function searchAuthorByName(name) {
    return apiRequest(`/authors/search?name=${encodeURIComponent(name)}`, { method: "GET" });
}
