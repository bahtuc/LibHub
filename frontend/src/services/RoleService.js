import { apiRequest } from "../JS/APi.js";

export function getRoles() {
    return apiRequest("/roles", { method: "GET" });
}

export function getRoleById(id) {
    return apiRequest(`/roles/${id}`, { method: "GET" });
}

export function createRole(payload) {
    return apiRequest("/roles", { method: "POST", body: payload });
}

export function updateRole(id, payload) {
    return apiRequest(`/roles/${id}`, { method: "PUT", body: payload });
}

export function deleteRole(id) {
    return apiRequest(`/roles/${id}`, { method: "DELETE" });
}

export function findRoleByName(name) {
    return apiRequest(`/roles/name?name=${encodeURIComponent(name)}`, { method: "GET" });
}
