import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import AuthLayout from "./AuthLayout";
import Icon from "../components/Icon";
import { useAuth } from "../auth/useAuth";
import { useLanguage } from "../i18n/LanguageContext";
import "../styles/AuthForm.css";

export default function Register() {
  const { register } = useAuth();
  const navigate = useNavigate();
  const { t } = useLanguage();
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
    if (form.password !== form.confirm) return setError(t("register.mismatch"));
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
    <AuthLayout mode="register" title={t("register.title")} subtitle={t("register.subtitle")}>
      <div className="lh-auth-form">
        <form onSubmit={submit}>
          {field(t("register.fullName"), "full_name", "user")}
          {field(t("register.username"), "username", "user")}
          {field(t("register.email"), "email", "mail", "email")}
          {field(t("register.phone"), "phone", "phone", "tel")}
          {field(t("register.password"), "password", "lock", "password")}
          {field(t("register.confirm"), "confirm", "lock", "password")}
          {error && <p className="lh-auth-form__error">{error}</p>}
          <button className="lh-btn lh-btn--primary lh-auth-form__submit">{t("register.submit")}</button>
        </form>
        <p className="lh-auth-form__switch-line">
          {t("register.haveAccount")} <Link to="/login">{t("register.signIn")}</Link>
        </p>
      </div>
    </AuthLayout>
  );
}
