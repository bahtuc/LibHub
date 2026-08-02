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
    phone: "",
    password: "",
    confirm: "",
  });
  const [error, setError] = useState("");

  async function submit(event) {
    event.preventDefault();
    if (form.password !== form.confirm) return setError("Mật khẩu nhập lại không khớp.");
    try {
      await register(form);
      navigate("/login", { replace: true, state: { registered: true } });
    } catch (err) {
      setError(err.message);
    }
  }

  const field = (label, key, icon, type = "text") => (
    <label className="lh-field">
      {label}
      <div className="lh-field__control">
        <input
          type={type}
          value={form[key]}
          onChange={(e) => setForm({ ...form, [key]: e.target.value })}
          required
        />
        <Icon name={icon} size={16} className="lh-field__icon" />
      </div>
    </label>
  );

  return (
    <AuthLayout mode="register" title="Tạo tài khoản LibHub" subtitle="Đăng ký để mượn và theo dõi sách.">
      <div className="lh-auth-form">
        <form onSubmit={submit}>
          {field("Họ và tên", "full_name", "user")}
          {field("Tên đăng nhập", "username", "at-sign")}
          {field("Email", "email", "mail", "email")}
          {field("Số điện thoại", "phone", "phone", "tel")}
          {field("Mật khẩu", "password", "lock", "password")}
          {field("Nhập lại mật khẩu", "confirm", "lock", "password")}
          {error && <p className="lh-auth-form__error">{error}</p>}
          <button className="lh-btn lh-btn--primary lh-auth-form__submit">Đăng ký</button>
        </form>
        <p className="lh-auth-form__switch-line">
          Đã có tài khoản? <Link to="/login">Đăng nhập</Link>
        </p>
      </div>
    </AuthLayout>
  );
}