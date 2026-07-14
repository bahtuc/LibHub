// src/pages/Login.jsx
import { useState } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import AuthLayout from "./AuthLayout";
import Icon from "../components/Icon";
import { useAuth } from "../auth/useAuth";
import "../styles/AuthForm.css";

export default function Login() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const [form, setForm] = useState({ username: "", password: "" });
  const [error, setError] = useState("");

  function update(field) {
    return (e) => {
      setError("");
      setForm((f) => ({ ...f, [field]: e.target.value }));
    };
  }

  function handleSubmit(e) {
    e.preventDefault();
    const result = login(form.username, form.password);
    if (!result.ok) {
      setError(result.message);
      return;
    }
    const redirectTo = location.state?.from || "/";
    navigate(redirectTo, { replace: true });
  }

  return (
    <AuthLayout
      mode="login"
      title="Chào mừng trở lại"
      subtitle="Đăng nhập để tiếp tục mượn và quản lý sách tại LibHub."
    >
      <div className="lh-auth-form">
        {location.state?.registered && (
          <p className="lh-auth-form__success" style={{ marginBottom: 16 }}>
            Tạo tài khoản thành công, hãy đăng nhập để tiếp tục.
          </p>
        )}
        {location.state?.passwordReset && (
          <p className="lh-auth-form__success" style={{ marginBottom: 16 }}>
            Đổi mật khẩu thành công, hãy đăng nhập lại.
          </p>
        )}

        <form onSubmit={handleSubmit} noValidate>
          <label className="lh-field">
            Tên đăng nhập
            <span className="lh-field__control">
              <Icon name="user" size={17} className="lh-field__icon" />
              <input
                type="text"
                value={form.username}
                onChange={update("username")}
                placeholder="vd: admin"
                autoComplete="username"
                required
              />
            </span>
          </label>

          <label className="lh-field">
            <span className="lh-field__label-row">
              Mật khẩu
              <Link to="/forgot-password" className="lh-field__forgot">
                Quên mật khẩu?
              </Link>
            </span>
            <span className="lh-field__control">
              <Icon name="lock" size={17} className="lh-field__icon" />
              <input
                type="password"
                value={form.password}
                onChange={update("password")}
                placeholder="••••••••"
                autoComplete="current-password"
                required
              />
            </span>
          </label>

          {error && <p className="lh-auth-form__error">{error}</p>}

          <button type="submit" className="lh-btn lh-btn--primary lh-auth-form__submit">
            Đăng nhập
          </button>
        </form>

        <p className="lh-auth-form__switch-line">
          Chưa có tài khoản? <Link to="/register">Đăng ký ngay</Link>
        </p>
      </div>
    </AuthLayout>
  );
}
