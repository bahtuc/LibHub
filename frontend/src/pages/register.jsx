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

const initialForm = {
    username: "",
    fullName: "",
    email: "",
    password: "",
    confirmPassword: "",
};

export default function Register() {
    const navigate = useNavigate();
    const { register } = useAuth();

    const [form, setForm] = useState(initialForm);
    const [error, setError] = useState("");
    const [success, setSuccess] = useState("");
    const [submitting, setSubmitting] = useState(false);

    function handleChange(e) {
        const { name, value } = e.target;
        setForm((prev) => ({ ...prev, [name]: value }));
    }

    function validate() {
        if (!form.username.trim()) return "Vui lòng nhập tên đăng nhập.";
        if (!form.fullName.trim()) return "Vui lòng nhập họ tên.";
        if (!form.email.trim()) return "Vui lòng nhập email.";

        const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailPattern.test(form.email.trim())) return "Email không hợp lệ.";

        if (form.password.length < 6) return "Mật khẩu phải từ 6 ký tự.";
        if (form.password !== form.confirmPassword) return "Mật khẩu nhập lại không khớp.";

        return "";
    }

    async function handleSubmit(e) {
        e.preventDefault();
        setError("");
        setSuccess("");

        const validationError = validate();
        if (validationError) {
            setError(validationError);
            return;
        }

        setSubmitting(true);
        try {
            await register(
                form.username.trim(),
                form.password,
                form.fullName.trim(),
                form.email.trim()
            );
            setSuccess("Đăng ký thành công! Đang chuyển tới trang đăng nhập...");
            setForm(initialForm);
            setTimeout(() => navigate("/login"), 1200);
        } catch (err) {
            setError(err.message || "Đăng ký thất bại. Vui lòng thử lại.");
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
                            Đăng ký để bắt đầu mượn sách tại LibHub.
                        </p>
                    </div>

                    {error && <div className="auth-error">{error}</div>}
                    {success && <div className="auth-success">{success}</div>}

                    <form className="auth-form" onSubmit={handleSubmit}>
                        <div className="auth-field">
                            <label className="auth-label" htmlFor="username">
                                Username
                            </label>
                            <input id="username" name="username" type="text" className="auth-input" placeholder="Nhập tên hoặc email của bạn..." value={form.username} onChange={handleChange} autoComplete="username" disabled={submitting}/>
                        </div>

                        <div className="auth-field">
                            <label className="auth-label" htmlFor="fullName">
                                Họ và tên
                            </label>
                            <input id="fullName" name="fullName" type="text" className="auth-input" placeholder="Nguyễn Văn A" value={form.fullName} onChange={handleChange} autoComplete="name" disabled={submitting}/>
                        </div>

                        <div className="auth-field">
                            <label className="auth-label" htmlFor="email">
                                Email
                            </label>
                            <input id="email" name="email" type="email" className="auth-input" placeholder="a@email.com" value={form.email} onChange={handleChange} autoComplete="email" disabled={submitting}/>
                        </div>

                        <div className="auth-field">
                            <label className="auth-label" htmlFor="password">
                                Password
                            </label>
                            <input id="password" name="password" type="password" className="auth-input" placeholder="Nhập mật khẩu..." value={form.password} onChange={handleChange} autoComplete="new-password" disabled={submitting}/>
                        </div>

                        <div className="auth-field">
                            <label className="auth-label" htmlFor="confirmPassword">
                                Confirm password
                            </label>
                            <input id="confirmPassword" name="confirmPassword" type="password" className="auth-input" placeholder="Nhập lại mật khẩu..." value={form.confirmPassword} onChange={handleChange} autoComplete="new-password" disabled={submitting}/>
                        </div>

                        <button type="submit" className="auth-submit" disabled={submitting}>
                            {submitting ? "Đang đăng ký..." : "Đăng ký"}
                        </button>
                    </form>

                    <p className="auth-footer">
                        Đã có tài khoản?{" "}
                        <Link className="auth-link" to="/login">
                            Đăng nhập
                        </Link>
                    </p>
                </div>
            </div>
        </div>
    );
}