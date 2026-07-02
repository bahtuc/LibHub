import { apiRequest } from "../JS/APi.js";

export function getPublishers() {
    return apiRequest("/publishers", { method: "GET" });
}

export function getPublisherById(id) {
    return apiRequest(`/publishers/${id}`, { method: "GET" });
}

export function createPublisher(payload) {
    return apiRequest("/publishers", { method: "POST", body: payload });
}

export function updatePublisher(id, payload) {
    return apiRequest(`/publishers/${id}`, { method: "PUT", body: payload });
}

export function deletePublisher(id) {
    return apiRequest(`/publishers/${id}`, { method: "DELETE" });
}

export function findPublisherByName(name) {
    return apiRequest(`/publishers/name?name=${encodeURIComponent(name)}`, { method: "GET" });
}
