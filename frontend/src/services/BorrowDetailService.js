import { apiRequest } from "../JS/APi.js";

export function getBorrowDetails() {
    return apiRequest("/borrow-details", { method: "GET" });
}

export function getBorrowDetailById(id) {
    return apiRequest(`/borrow-details/${id}`, { method: "GET" });
}

export function createBorrowDetail(payload) {
    return apiRequest("/borrow-details", { method: "POST", body: payload });
}

export function updateBorrowDetail(id, payload) {
    return apiRequest(`/borrow-details/${id}`, { method: "PUT", body: payload });
}

export function deleteBorrowDetail(id) {
    return apiRequest(`/borrow-details/${id}`, { method: "DELETE" });
}

export function findBorrowDetailsByTicket(ticketId) {
    return apiRequest(`/borrow-details/ticket/${ticketId}`, { method: "GET" });
}

export function findBorrowDetailsByCopy(copyId) {
    return apiRequest(`/borrow-details/copy/${copyId}`, { method: "GET" });
}

export function findBorrowDetailsByStatus(status) {
    return apiRequest(`/borrow-details/status/${status}`, { method: "GET" });
}
