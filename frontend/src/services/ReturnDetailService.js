import { apiRequest } from "../JS/APi.js";

export function getReturnDetails() {
    return apiRequest("/return-details", { method: "GET" });
}

export function getReturnDetailById(id) {
    return apiRequest(`/return-details/${id}`, { method: "GET" });
}

export function createReturnDetail(payload) {
    return apiRequest("/return-details", { method: "POST", body: payload });
}

export function updateReturnDetail(id, payload) {
    return apiRequest(`/return-details/${id}`, { method: "PUT", body: payload });
}

export function deleteReturnDetail(id) {
    return apiRequest(`/return-details/${id}`, { method: "DELETE" });
}

export function findReturnDetailsByReturn(returnId) {
    return apiRequest(`/return-details/return/${returnId}`, { method: "GET" });
}

export function findReturnDetailsByCopy(copyId) {
    return apiRequest(`/return-details/copy/${copyId}`, { method: "GET" });
}

export function findReturnDetailsByCondition(condition) {
    return apiRequest(`/return-details/condition/${condition}`, { method: "GET" });
}
