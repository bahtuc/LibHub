import { createContext, useContext, useEffect, useState } from "react";
import * as authService from "../services/AuthService";

const AuthContext = createContext(null);

function normaliseUser(user) {
  return { ...user, user_id: user.userId, full_name: user.fullName, role_name: user.role };
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    authService.getCurrentUser().then((data) => setUser(normaliseUser(data))).catch(() => setUser(null)).finally(() => setLoading(false));
  }, []);

  async function login(usernameOrEmail, password) {
    const session = normaliseUser(await authService.login({ usernameOrEmail, password }));
    setUser(session);
    return session;
  }

  function register({ full_name, username, email, password }) {
    return authService.register({ fullName: full_name, username, email, password });
  }

  async function logout() {
    try { await authService.logout(); } finally { setUser(null); }
  }

  async function changePassword(currentPassword, newPassword) {
    if (!user) throw new Error("Chưa đăng nhập");
    return authService.changePassword({ username: user.username, oldPassword: currentPassword, newPassword });
  }

  // These flows do not have corresponding backend endpoints yet. Keep the
  // existing screens functional while making the missing API explicit.
  const unavailable = () => ({ ok: false, message: "Chức năng này chưa được backend hỗ trợ." });

  return <AuthContext.Provider value={{ user, loading, login, register, logout, changePassword, updateProfile: unavailable, requestPasswordReset: unavailable, verifyOtp: unavailable, resetPassword: unavailable }}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used inside AuthProvider");
  return ctx;
}
