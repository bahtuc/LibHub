import { apiRequest } from "../JS/APi.js";

export function getCategories() {
    return apiRequest("/categories", { method: "GET" });
}

export function getCategoryById(id) {
    return apiRequest(`/categories/${id}`, { method: "GET" });
}

export function createCategory(payload) {
    return apiRequest("/categories", { method: "POST", body: payload });
}

export function updateCategory(id, payload) {
    return apiRequest(`/categories/${id}`, { method: "PUT", body: payload });
}

export function deleteCategory(id) {
    return apiRequest(`/categories/${id}`, { method: "DELETE" });
}

export function findCategoryByName(name) {
    return apiRequest(`/categories/name?name=${encodeURIComponent(name)}`, { method: "GET" });
}
