import { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import "../css/auth.css";

function BookIcon() {
    return (
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
            <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20" />
            <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z" />
        </svg>
    );
}

export default function Login() {
    const navigate = useNavigate();
    const { login } = useAuth();

    const [form, setForm] = useState({
        usernameOrEmail: "",
        password: "",
    });
    const [remember, setRemember] = useState(false);
    const [error, setError] = useState("");
    const [submitting, setSubmitting] = useState(false);

    function handleChange(e) {
        const { name, value } = e.target;
        setForm((prev) => ({ ...prev, [name]: value }));
    }

    async function handleSubmit(e) {
        e.preventDefault();
        setError("");

        if (!form.usernameOrEmail.trim() || !form.password) {
            setError("Vui lòng nhập đầy đủ tài khoản và mật khẩu.");
            return;
        }

        setSubmitting(true);
        try {
            await login(form.usernameOrEmail.trim(), form.password);
            navigate("/");
        } catch (err) {
            setError(err.message || "Đăng nhập thất bại. Vui lòng thử lại.");
        } finally {
            setSubmitting(false);
        }
    }

    return (
        <div className="auth-page">
            <div className="auth-art" aria-hidden="true">
                <div className="auth-art-overlay" />
            </div>

            <div className="auth-form-side">
                <div className="auth-card">
                    <div className="auth-card-head">
                        <div className="auth-logo">
              <span className="auth-logo-icon">
                <BookIcon />
              </span>
                            LibHub
                        </div>
                        <h1 className="auth-title">Welcome Back</h1>
                        <p className="auth-subtitle">
                            Đăng nhập để tiếp tục mượn và quản lý sách.
                        </p>
                    </div>

                    {error && <div className="auth-error">{error}</div>}

                    <form className="auth-form" onSubmit={handleSubmit}>
                        <div className="auth-field">
                            <label className="auth-label" htmlFor="usernameOrEmail">
                                Username / Email
                            </label>
                            <input id="usernameOrEmail" name="usernameOrEmail" type="text" className="auth-input" placeholder="Nhập tên hoặc email của bạn..." value={form.usernameOrEmail} onChange={handleChange} autoComplete="username" disabled={submitting}/>
                        </div>

                        <div className="auth-field">
                            <label className="auth-label" htmlFor="password">
                                Password
                            </label>
                            <input id="password" name="password" type="password" className="auth-input" placeholder="Nhập mật khẩu..." value={form.password} onChange={handleChange} autoComplete="current-password" disabled={submitting}/>
                        </div>

                        <label className="auth-checkbox-row">
                            <input
                                type="checkbox"
                                checked={remember}
                                onChange={(e) => setRemember(e.target.checked)}
                                disabled={submitting}
                            />
                            Ghi nhớ đăng nhập
                        </label>

                        <button type="submit" className="auth-submit" disabled={submitting}>
                            {submitting ? "Đang đăng nhập..." : "Đăng nhập"}
                        </button>
                    </form>

                    <p className="auth-footer">
                        Chưa có tài khoản?{" "}
                        <Link className="auth-link" to="/register">
                            Đăng ký
                        </Link>
                    </p>
                </div>
            </div>
        </div>
    );
}