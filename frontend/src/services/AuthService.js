import { apiRequest } from "../JS/APi.js";

export function login(payload) {
    return apiRequest("/auth/login", { method: "POST", body: payload });
}

export function verifyLoginOtp(payload) {
    return apiRequest("/auth/2fa/verify", { method: "POST", body: payload });
}

export function register(payload) {
    return apiRequest("/auth/register", { method: "POST", body: payload });
}

export function logout() {
    return apiRequest("/auth/logout", { method: "POST" });
}

export function getCurrentUser() {
    return apiRequest("/auth/me", { method: "GET" });
}

export function updateProfile(payload) {
    return apiRequest("/auth/profile", { method: "PUT", body: payload });
}

export function changePassword(payload) {
    return apiRequest("/auth/change-password", { method: "POST", body: payload });
}

export function updateTwoFactor(enabled) {
    return apiRequest("/auth/two-factor", { method: "PUT", body: { enabled } });
}
