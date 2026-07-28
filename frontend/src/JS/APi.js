// Base URL is read from Vite env (VITE_API_BASE_URL). Falls back to the local
// backend so `npm run dev` works out of the box without an .env file.
export const API_BASE_URL =
    import.meta.env.VITE_API_BASE_URL || "http://localhost:8080/api";

export async function apiRequest(endpoint, options = {}) {
    const { method = "GET", body, headers = {} } = options;

    const config = {
        method,
        headers: {
            "Content-Type": "application/json",
            ...headers,
        },
        credentials: "include", // QUAN TRỌNG: gửi cookie JSESSIONID kèm mỗi request
    };

    if (body !== undefined) {
        config.body = JSON.stringify(body);
    }

    let response;
    try {
        response = await fetch(`${API_BASE_URL}${endpoint}`, config);
    } catch (networkErr) {
        throw new Error(
            "Không thể kết nối tới server. Kiểm tra backend đã chạy chưa hoặc cấu hình CORS.",
            { cause: networkErr }
        );
    }

    const contentType = response.headers.get("content-type") || "";
    let data;
    if (contentType.includes("application/json")) {
        data = await response.json().catch(() => null);
    } else {
        data = await response.text().catch(() => null);
    }

    if (!response.ok) {
        const message =
            (data && typeof data === "object" && (data.message || data.error)) ||
            (typeof data === "string" && data) ||
            `Lỗi ${response.status}`;
        throw new Error(message);
    }

    return data;
}
