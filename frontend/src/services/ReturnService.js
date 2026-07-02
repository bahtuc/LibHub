import { apiRequest } from "../JS/APi.js";

export function getReturns() {
    return apiRequest("/returns", { method: "GET" });
}

export function getReturnById(id) {
    return apiRequest(`/returns/${id}`, { method: "GET" });
}

export function createReturn(payload) {
    return apiRequest("/returns", { method: "POST", body: payload });
}

export function updateReturn(id, payload) {
    return apiRequest(`/returns/${id}`, { method: "PUT", body: payload });
}

export function deleteReturn(id) {
    return apiRequest(`/returns/${id}`, { method: "DELETE" });
}

export function findReturnsByTicket(ticketId) {
    return apiRequest(`/returns/ticket/${ticketId}`, { method: "GET" });
}

export function findReturnsByReceivedBy(receivedBy) {
    return apiRequest(`/returns/received-by/${receivedBy}`, { method: "GET" });
}
