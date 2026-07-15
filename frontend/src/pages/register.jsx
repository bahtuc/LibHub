// src/pages/Register.jsx
import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import AuthLayout from "./AuthLayout";
import Icon from "../components/Icon";
import { useAuth } from "../auth/useAuth";
import "../styles/AuthForm.css";

export default function Register() {
  const { register } = useAuth();
  const navigate = useNavigate();

  const [form, setForm] = useState({
    full_name: "",
    username: "",
    email: "",
    password: "",
    confirm: "",
  });
  const [error, setError] = useState("");

  function update(field) {
    return (e) => {
      setError("");
      setForm((f) => ({ ...f, [field]: e.target.value }));
    };
  }

  function handleSubmit(e) {
    e.preventDefault();

    if (form.password !== form.confirm) {
      setError("Mật khẩu nhập lại không khớp.");
      return;
    }
    if (form.password.length < 6) {
      setError("Mật khẩu cần tối thiểu 6 ký tự.");
      return;
    }

    const result = register({
      full_name: form.full_name,
      username: form.username,
      email: form.email,
      password: form.password,
    });

    if (!result.ok) {
      setError(result.message);
      return;
    }

    navigate("/login", { replace: true, state: { registered: true } });
  }

  return (
    <AuthLayout
      mode="register"
      title="Tạo tài khoản LibHub"
      subtitle="Đăng ký để mượn sách, theo dõi phiếu mượn và gia hạn trực tuyến."
    >
      <div className="lh-auth-form">
        <form onSubmit={handleSubmit} noValidate>
          <label className="lh-field">
            Họ và tên
            <span className="lh-field__control">
              <Icon name="user" size={17} className="lh-field__icon" />
              <input
                type="text"
                value={form.full_name}
                onChange={update("full_name")}
                placeholder="Nguyễn Văn A"
                autoComplete="name"
                required
              />
            </span>
          </label>

          <label className="lh-field">
            Tên đăng nhập
            <span className="lh-field__control">
              <Icon name="user" size={17} className="lh-field__icon" />
              <input
                type="text"
                value={form.username}
                onChange={update("username")}
                placeholder="vd: nguyenvana"
                autoComplete="username"
                required
              />
            </span>
          </label>

          <label className="lh-field">
            Email
            <span className="lh-field__control">
              <Icon name="mail" size={17} className="lh-field__icon" />
              <input
                type="email"
                value={form.email}
                onChange={update("email")}
                placeholder="ban@email.com"
                autoComplete="email"
                required
              />
            </span>
          </label>

          <div className="lh-auth-form__row">
            <label className="lh-field">
              Mật khẩu
              <span className="lh-field__control">
                <Icon name="lock" size={17} className="lh-field__icon" />
                <input
                  type="password"
                  value={form.password}
                  onChange={update("password")}
                  placeholder="••••••••"
                  autoComplete="new-password"
                  required
                />
              </span>
            </label>
            <label className="lh-field">
              Nhập lại
              <span className="lh-field__control">
                <Icon name="lock" size={17} className="lh-field__icon" />
                <input
                  type="password"
                  value={form.confirm}
                  onChange={update("confirm")}
                  placeholder="••••••••"
                  autoComplete="new-password"
                  required
                />
              </span>
            </label>
          </div>

          {error && <p className="lh-auth-form__error">{error}</p>}

          <button type="submit" className="lh-btn lh-btn--primary lh-auth-form__submit">
            Đăng ký
          </button>
        </form>

        <p className="lh-auth-form__switch-line">
          Đã có tài khoản? <Link to="/login">Đăng nhập</Link>
        </p>
      </div>
    </AuthLayout>
  );
}
