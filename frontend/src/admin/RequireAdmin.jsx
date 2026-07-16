// src/admin/RequireAdmin.jsx
// Chỉ cho phép user đã đăng nhập với role "Admin" vào khu vực /admin.
import { Navigate, useLocation } from "react-router-dom";
import { useAuth } from "../auth/useAuth";

export default function RequireAdmin({ children }) {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) return null;
  if (!user) {
    return <Navigate to="/login" replace state={{ from: location.pathname }} />;
  }
  if (user.role_name !== "Admin") {
    return <Navigate to="/" replace />;
  }
  return children;
}
