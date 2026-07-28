import { apiRequest } from "../JS/APi.js";

export function getBorrowTickets() {
    return apiRequest("/borrow-tickets", { method: "GET" });
}

export function getBorrowTicketById(id) {
    return apiRequest(`/borrow-tickets/${id}`, { method: "GET" });
}

export function createBorrowTicket(payload) {
    return apiRequest("/borrow-tickets", { method: "POST", body: payload });
}

export function borrowBook(bookId) {
    return apiRequest("/borrow-tickets/borrow", {
        method: "POST",
        body: { bookId },
    });
}

export function updateBorrowTicket(id, payload) {
    return apiRequest(`/borrow-tickets/${id}`, { method: "PUT", body: payload });
}

export function deleteBorrowTicket(id) {
    return apiRequest(`/borrow-tickets/${id}`, { method: "DELETE" });
}

export function findBorrowTicketsByUser(userId) {
    return apiRequest(`/borrow-tickets/user/${userId}`, { method: "GET" });
}

export function findBorrowTicketsByStatus(status) {
    return apiRequest(`/borrow-tickets/status/${status}`, { method: "GET" });
}

// Borrow history of the currently logged-in user (derived from the session).
export function getMyBorrowHistory() {
    return apiRequest("/borrow-tickets/history", { method: "GET" });
}
