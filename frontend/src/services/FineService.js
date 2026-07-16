import { apiRequest } from "../JS/APi.js";

// Member-safe endpoint: the backend resolves fine -> return -> ticket and
// only returns fines belonging to the current session user.
export function getMyFines() {
    return apiRequest("/payments/fines", { method: "GET" });
}

export function getFines() {
    return apiRequest("/fines", { method: "GET" });
}

export function getFineById(id) {
    return apiRequest(`/fines/${id}`, { method: "GET" });
}

export function createFine(payload) {
    return apiRequest("/fines", { method: "POST", body: payload });
}

export function updateFine(id, payload) {
    return apiRequest(`/fines/${id}`, { method: "PUT", body: payload });
}

export function deleteFine(id) {
    return apiRequest(`/fines/${id}`, { method: "DELETE" });
}

export function findFinesByReturnDetail(returnDetailId) {
    return apiRequest(`/fines/return-detail/${returnDetailId}`, { method: "GET" });
}

export function findFinesByPaidStatus(paidStatus) {
    return apiRequest(`/fines/paid-status/${paidStatus}`, { method: "GET" });
}
