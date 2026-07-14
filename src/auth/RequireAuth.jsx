// src/auth/RequireAuth.jsx
// Chỉ cần đã đăng nhập (không giới hạn role) — dùng cho /account.
import { Navigate, useLocation } from "react-router-dom";
import { useAuth } from "./useAuth";

export default function RequireAuth({ children }) {
  const { user } = useAuth();
  const location = useLocation();

  if (!user) {
    return <Navigate to="/login" replace state={{ from: location.pathname }} />;
  }
  return children;
}
