import { createContext, useContext, useEffect, useState } from "react";
import * as authService from "../services/AuthService";

const AuthContext = createContext(null);

function normaliseUser(user) {
  if (!user || typeof user !== "object") {
    throw new Error("Server không trả về dữ liệu tài khoản hợp lệ.");
  }

  return {
    ...user,
    user_id: user.userId ?? user.user_id,
    full_name: user.fullName ?? user.full_name,
    role_name: user.role ?? user.role_name,
    member_since: (user.memberSince ?? user.member_since)?.slice?.(0, 10),
  };
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    authService
      .getCurrentUser()
      .then((data) => setUser(normaliseUser(data)))
      .catch(() => setUser(null))
      .finally(() => setLoading(false));
  }, []);

  async function login(usernameOrEmail, password) {
    const result = await authService.login({ usernameOrEmail, password });
    if (result.requiresTwoFactor) return result;

    // New backend wraps a direct login in `user`; older running builds return
    // AuthResponse directly. Supporting both prevents a stale backend process
    // from crashing the UI while it is being restarted.
    const authenticatedUser = normaliseUser(result?.user ?? result);
    setUser(authenticatedUser);
    return { ...(result ?? {}), requiresTwoFactor: false, user: authenticatedUser };
  }

  async function verifyLoginOtp(challengeId, code) {
    const authenticatedUser = normaliseUser(
      await authService.verifyLoginOtp({ challengeId, code }),
    );
    setUser(authenticatedUser);
    return authenticatedUser;
  }

  function register({ full_name, username, email, phone, password }) {
    return authService.register({
      fullName: full_name,
      username,
      email,
      phone,
      password,
    });
  }

  async function logout() {
    try {
      await authService.logout();
    } finally {
      setUser(null);
    }
  }

  async function updateProfile(profile) {
    if (!user) {
      return { ok: false, message: "Chưa đăng nhập" };
    }

    try {
      const updatedUser = normaliseUser(
        await authService.updateProfile({
          fullName: profile.full_name,
          email: profile.email,
          phone: profile.phone,
          address: profile.address,
        }),
      );
      setUser(updatedUser);
      return { ok: true, user: updatedUser };
    } catch (error) {
      return { ok: false, message: error.message };
    }
  }

  async function changePassword(currentPassword, newPassword) {
    if (!user) {
      throw new Error("Chưa đăng nhập");
    }
    return authService.changePassword({
      oldPassword: currentPassword,
      newPassword,
      confirmPassword: newPassword,
    });
  }

  // Password recovery still has no corresponding backend flow.
  const unavailable = () => ({
    ok: false,
    message: "Chức năng này chưa được backend hỗ trợ.",
  });

  return (
    <AuthContext.Provider
      value={{
        user,
        loading,
        login,
        verifyLoginOtp,
        register,
        logout,
        updateProfile,
        changePassword,
        requestPasswordReset: unavailable,
        verifyOtp: unavailable,
        resetPassword: unavailable,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used inside AuthProvider");
  }
  return context;
}
