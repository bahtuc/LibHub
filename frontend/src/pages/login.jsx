import { useState } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import AuthLayout from "./AuthLayout";
import Icon from "../components/Icon";
import { useAuth } from "../auth/useAuth";
import { useLanguage } from "../i18n/LanguageContext";
import "../styles/AuthForm.css";

export default function Login() {
  const { login, verifyLoginOtp } = useAuth();
  const { t } = useLanguage();
  const navigate = useNavigate();
  const location = useLocation();
  const [form, setForm] = useState({ username: "", password: "" });
  const [challenge, setChallenge] = useState(null);
  const [code, setCode] = useState("");
  const [error, setError] = useState("");
  const [submitting, setSubmitting] = useState(false);

  const finishLogin = () => navigate(location.state?.from || "/", { replace: true });

  async function submitCredentials(event) {
    event.preventDefault();
    setError("");
    setSubmitting(true);
    try {
      const result = await login(form.username, form.password);
      if (result.requiresTwoFactor) {
        setChallenge(result);
        setCode("");
      } else {
        finishLogin();
      }
    } catch (err) {
      setError(err.message);
    } finally {
      setSubmitting(false);
    }
  }

  async function submitCode(event) {
    event.preventDefault();
    setError("");
    setSubmitting(true);
    try {
      await verifyLoginOtp(challenge.challengeId, code);
      finishLogin();
    } catch (err) {
      setError(err.message);
    } finally {
      setSubmitting(false);
    }
  }

  function returnToCredentials() {
    setChallenge(null);
    setCode("");
    setError("");
  }

  const otpStep = Boolean(challenge);
  return (
    <AuthLayout
      mode="login"
      title={otpStep ? t("login.otpTitle") : t("login.welcome")}
      subtitle={otpStep
        ? t("login.otpSubtitle", { email: challenge.maskedEmail })
        : t("login.subtitle")}
      hideTabs={otpStep}
    >
      <div className="lh-auth-form">
        <div className="lh-auth-steps" aria-hidden="true">
          <span className={otpStep ? "is-done" : "is-active"} />
          <span className={otpStep ? "is-active" : ""} />
        </div>

        {otpStep ? (
          <form onSubmit={submitCode}>
            <label className="lh-field">
              {t("login.otpLabel")}
              <input
                className="lh-otp-input"
                value={code}
                onChange={(event) => setCode(event.target.value.replace(/\D/g, "").slice(0, 6))}
                inputMode="numeric"
                autoComplete="one-time-code"
                pattern="[0-9]{6}"
                maxLength={6}
                autoFocus
                required
              />
              <small className="lh-auth-form__hint">{t("login.otpHint")}</small>
            </label>
            {error && <p className="lh-auth-form__error" role="alert">{error}</p>}
            <button className="lh-btn lh-btn--primary lh-auth-form__submit" disabled={submitting || code.length !== 6}>
              {submitting ? t("login.verifying") : t("login.verify")}
            </button>
            <button type="button" className="lh-auth-form__linklike" onClick={returnToCredentials} disabled={submitting}>
              {t("login.back")}
            </button>
          </form>
        ) : (
          <form onSubmit={submitCredentials}>
            <label className="lh-field">
              {t("login.identity")}
              <span className="lh-field__control">
                <Icon name="user" size={17} className="lh-field__icon" />
                <input value={form.username} onChange={(event) => setForm({ ...form, username: event.target.value })} autoComplete="username" required />
              </span>
            </label>
            <label className="lh-field">
              {t("login.password")}
              <span className="lh-field__control">
                <Icon name="lock" size={17} className="lh-field__icon" />
                <input type="password" value={form.password} onChange={(event) => setForm({ ...form, password: event.target.value })} autoComplete="current-password" required />
              </span>
            </label>
            {error && <p className="lh-auth-form__error" role="alert">{error}</p>}
            <button className="lh-btn lh-btn--primary lh-auth-form__submit" disabled={submitting}>
              {submitting ? t("login.submitting") : t("login.submit")}
            </button>
          </form>
        )}

        {!otpStep && <p className="lh-auth-form__switch-line">{t("login.noAccount")} <Link to="/register">{t("login.registerNow")}</Link></p>}
      </div>
    </AuthLayout>
  );
}
