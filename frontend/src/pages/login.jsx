import { useState } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import AuthLayout from "./AuthLayout";
import Icon from "../components/Icon";
import { useAuth } from "../auth/useAuth";
import "../styles/AuthForm.css";
export default function Login() {
  const { login } = useAuth(); const navigate = useNavigate(); const location = useLocation();
  const [form, setForm] = useState({ username: "", password: "" }); const [error, setError] = useState("");
  async function submit(event) { event.preventDefault(); try { await login(form.username, form.password); navigate(location.state?.from || "/", { replace: true }); } catch (err) { setError(err.message); } }
  return <AuthLayout mode="login" title="Chào mừng trở lại" subtitle="Đăng nhập để tiếp tục sử dụng LibHub."><div className="lh-auth-form"><form onSubmit={submit}><label className="lh-field">Tên đăng nhập hoặc email<span className="lh-field__control"><Icon name="user" size={17} className="lh-field__icon" /><input value={form.username} onChange={(e) => setForm({ ...form, username: e.target.value })} required /></span></label><label className="lh-field">Mật khẩu<span className="lh-field__control"><Icon name="lock" size={17} className="lh-field__icon" /><input type="password" value={form.password} onChange={(e) => setForm({ ...form, password: e.target.value })} required /></span></label>{error && <p className="lh-auth-form__error">{error}</p>}<button className="lh-btn lh-btn--primary lh-auth-form__submit">Đăng nhập</button></form><p className="lh-auth-form__switch-line">Chưa có tài khoản? <Link to="/register">Đăng ký ngay</Link></p></div></AuthLayout>;
}
