import { Navigate, useLocation } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

// Gate for authenticated routes. `adminOnly` additionally requires the Admin role.
export default function ProtectedRoute({ children, adminOnly = false }) {
    const { isAuthenticated, loading, user } = useAuth();
    const location = useLocation();

    if (loading) {
        return (
            <div className="lh-loading">
                <span className="lh-spinner" /> Đang tải…
            </div>
        );
    }

    if (!isAuthenticated) {
        return <Navigate to="/login" replace state={{ from: location.pathname }} />;
    }

    if (adminOnly && (user?.role || "").toLowerCase() !== "admin") {
        return <Navigate to="/" replace />;
    }

    return children;
}
