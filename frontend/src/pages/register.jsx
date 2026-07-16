import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import AuthLayout from "./AuthLayout";
import { useAuth } from "../auth/useAuth";
import "../styles/AuthForm.css";
export default function Register() {
  const { register } = useAuth(); const navigate = useNavigate(); const [form, setForm] = useState({ full_name: "", username: "", email: "", password: "", confirm: "" }); const [error, setError] = useState("");
  async function submit(event) { event.preventDefault(); if (form.password !== form.confirm) return setError("Mật khẩu nhập lại không khớp."); try { await register(form); navigate("/login", { replace: true, state: { registered: true } }); } catch (err) { setError(err.message); } }
  const field = (label, key, type = "text") => <label className="lh-field">{label}<input type={type} value={form[key]} onChange={(e) => setForm({ ...form, [key]: e.target.value })} required /></label>;
  return <AuthLayout mode="register" title="Tạo tài khoản LibHub" subtitle="Đăng ký để mượn và theo dõi sách."><div className="lh-auth-form"><form onSubmit={submit}>{field("Họ và tên", "full_name")}{field("Tên đăng nhập", "username")}{field("Email", "email", "email")}{field("Mật khẩu", "password", "password")}{field("Nhập lại mật khẩu", "confirm", "password")}{error && <p className="lh-auth-form__error">{error}</p>}<button className="lh-btn lh-btn--primary lh-auth-form__submit">Đăng ký</button></form><p className="lh-auth-form__switch-line">Đã có tài khoản? <Link to="/login">Đăng nhập</Link></p></div></AuthLayout>;
}
