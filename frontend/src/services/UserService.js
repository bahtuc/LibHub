import { apiRequest } from "../JS/APi.js";

export function getUsers() {
    return apiRequest("/users", { method: "GET" });
}

export function getBorrowers() {
    return apiRequest("/users/borrowers", { method: "GET" });
}

export function getUserById(id) {
    return apiRequest(`/users/${id}`, { method: "GET" });
}

export function createUser(payload) {
    return apiRequest("/users", { method: "POST", body: payload });
}

export function updateUser(id, payload) {
    return apiRequest(`/users/${id}`, { method: "PUT", body: payload });
}

export function deleteUser(id) {
    return apiRequest(`/users/${id}`, { method: "DELETE" });
}

export function findUserByUsername(username) {
    return apiRequest(`/users/username/${username}`, { method: "GET" });
}

export function findUserByEmail(email) {
    return apiRequest(`/users/email/${email}`, { method: "GET" });
}

export function checkUsernameExists(username) {
    return apiRequest(`/users/check-username/${username}`, { method: "GET" });
}

export function updateUserLastLogin(id) {
    return apiRequest(`/users/${id}/last-login`, { method: "PUT" });
}
