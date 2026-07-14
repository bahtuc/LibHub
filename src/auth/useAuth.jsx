// src/auth/useAuth.jsx
//
// Context + hook quản lý phiên đăng nhập phía client (demo, chưa có backend).
// - login/register/quên mật khẩu đều thao tác trên localStorage.
// - Khi nhóm có API thật: thay nội dung các hàm bằng fetch("/api/auth/...")
//   tương ứng (login, register, forgot-password/request-otp,
//   forgot-password/verify-otp, forgot-password/reset), phần còn lại
//   (Context, useAuth(), cách các trang gọi hàm) giữ nguyên.

import { createContext, useContext, useEffect, useState } from "react";
import { mockUsers, getRole } from "./mockUsers";

const AuthContext = createContext(null);

const SESSION_KEY = "libhub_session";
const REGISTERED_KEY = "libhub_registered_users";
const PASSWORD_OVERRIDES_KEY = "libhub_password_overrides";
const OTP_KEY = "libhub_otp_requests";

const OTP_TTL_MS = 5 * 60 * 1000; // mã OTP demo có hạn 5 phút

function loadRegisteredUsers() {
  try {
    const raw = localStorage.getItem(REGISTERED_KEY);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

function loadPasswordOverrides() {
  try {
    const raw = localStorage.getItem(PASSWORD_OVERRIDES_KEY);
    return raw ? JSON.parse(raw) : {};
  } catch {
    return {};
  }
}

function loadOtpStore() {
  try {
    const raw = localStorage.getItem(OTP_KEY);
    return raw ? JSON.parse(raw) : {};
  } catch {
    return {};
  }
}

function getAllUsers() {
  const overrides = loadPasswordOverrides();
  return [...mockUsers, ...loadRegisteredUsers()].map((u) => ({
    ...u,
    password: overrides[u.username] ?? u.password,
  }));
}

function loadSession() {
  try {
    const raw = localStorage.getItem(SESSION_KEY);
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
}

function generateOtp() {
  return String(Math.floor(100000 + Math.random() * 900000));
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(loadSession);

  useEffect(() => {
    if (user) localStorage.setItem(SESSION_KEY, JSON.stringify(user));
    else localStorage.removeItem(SESSION_KEY);
  }, [user]);

  function login(username, password) {
    const cleanUsername = username.trim();
    const found = getAllUsers().find(
      (u) => u.username === cleanUsername && u.password === password
    );

    if (!found) {
      return { ok: false, message: "Sai tên đăng nhập hoặc mật khẩu." };
    }

    const role = getRole(found.role_id);
    const session = {
      user_id: found.user_id,
      username: found.username,
      full_name: found.full_name,
      role_id: found.role_id,
      role_name: role?.role_name ?? "User",
    };
    setUser(session);
    return { ok: true, user: session };
  }

  function register({ full_name, username, password }) {
    const cleanUsername = username.trim();

    if (!full_name.trim() || !cleanUsername || !password) {
      return { ok: false, message: "Vui lòng điền đầy đủ thông tin." };
    }
    if (getAllUsers().some((u) => u.username === cleanUsername)) {
      return { ok: false, message: "Tên đăng nhập này đã được sử dụng." };
    }

    const registered = loadRegisteredUsers();
    const newUser = {
      user_id: 1000 + registered.length + 1,
      username: cleanUsername,
      password,
      full_name: full_name.trim(),
      role_id: 2, // tài khoản tự đăng ký mặc định là "User" (bạn đọc)
    };
    localStorage.setItem(
      REGISTERED_KEY,
      JSON.stringify([...registered, newUser])
    );
    return { ok: true };
  }

  function logout() {
    setUser(null);
  }

  // --- Quên mật khẩu (demo, chưa nối SMS/email thật) ---

  function requestPasswordReset(username) {
    const cleanUsername = username.trim();
    const found = getAllUsers().find((u) => u.username === cleanUsername);

    if (!found) {
      return { ok: false, message: "Không tìm thấy tài khoản này." };
    }

    const code = generateOtp();
    const store = loadOtpStore();
    store[cleanUsername] = { code, expiresAt: Date.now() + OTP_TTL_MS };
    localStorage.setItem(OTP_KEY, JSON.stringify(store));

    // Demo: chưa có dịch vụ gửi email/SMS thật nên trả mã OTP về thẳng UI.
    // Khi có backend, bỏ trường devCode này đi — OTP chỉ nên nằm trong email/SMS.
    return { ok: true, devCode: code };
  }

  function verifyOtp(username, code) {
    const cleanUsername = username.trim();
    const store = loadOtpStore();
    const record = store[cleanUsername];

    if (!record) {
      return { ok: false, message: "Chưa yêu cầu mã OTP cho tài khoản này." };
    }
    if (Date.now() > record.expiresAt) {
      return { ok: false, message: "Mã OTP đã hết hạn, hãy gửi lại mã mới." };
    }
    if (record.code !== code.trim()) {
      return { ok: false, message: "Mã OTP không đúng." };
    }
    return { ok: true };
  }

  function resetPassword(username, code, newPassword) {
    const verify = verifyOtp(username, code);
    if (!verify.ok) return verify;

    const cleanUsername = username.trim();
    const overrides = loadPasswordOverrides();
    overrides[cleanUsername] = newPassword;
    localStorage.setItem(PASSWORD_OVERRIDES_KEY, JSON.stringify(overrides));

    const store = loadOtpStore();
    delete store[cleanUsername];
    localStorage.setItem(OTP_KEY, JSON.stringify(store));

    return { ok: true };
  }

  return (
    <AuthContext.Provider
      value={{
        user,
        login,
        register,
        logout,
        requestPasswordReset,
        verifyOtp,
        resetPassword,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) {
    throw new Error("useAuth() phải được gọi bên trong <AuthProvider>");
  }
  return ctx;
}
