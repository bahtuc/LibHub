// src/librarian/RequireLibrarian.jsx
// Cho phép Librarian, và cả Admin (để tiện kiểm tra/hỗ trợ) vào khu vực này.
import { Navigate, useLocation } from "react-router-dom";
import { useAuth } from "../auth/useAuth";

export default function RequireLibrarian({ children }) {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) return null;
  if (!user) {
    return <Navigate to="/login" replace state={{ from: location.pathname }} />;
  }
  if (user.role_name !== "Librarian" && user.role_name !== "Admin") {
    return <Navigate to="/" replace />;
  }
  return children;
}
