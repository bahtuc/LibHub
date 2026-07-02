import { apiRequest } from "../JS/APi.js";

export function getBookCopies() {
    return apiRequest("/book-copies", { method: "GET" });
}

export function getBookCopyById(id) {
    return apiRequest(`/book-copies/${id}`, { method: "GET" });
}

export function createBookCopy(payload) {
    return apiRequest("/book-copies", { method: "POST", body: payload });
}

export function updateBookCopy(id, payload) {
    return apiRequest(`/book-copies/${id}`, { method: "PUT", body: payload });
}

export function deleteBookCopy(id) {
    return apiRequest(`/book-copies/${id}`, { method: "DELETE" });
}

export function findBookCopyByBarcode(barcode) {
    return apiRequest(`/book-copies/barcode/${barcode}`, { method: "GET" });
}

export function findCopiesByBook(bookId) {
    return apiRequest(`/book-copies/book/${bookId}`, { method: "GET" });
}

export function findCopiesByBookAndStatus(bookId, status) {
    return apiRequest(`/book-copies/book/${bookId}/status/${status}`, { method: "GET" });
}

export function updateBookCopyStatus(id, status) {
    return apiRequest(`/book-copies/${id}/status/${status}`, { method: "PUT" });
}
