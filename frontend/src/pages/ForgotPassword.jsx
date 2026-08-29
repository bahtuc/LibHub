// src/pages/ForgotPassword.jsx
//
// Luồng quên mật khẩu 3 bước, chưa nối backend nên OTP được sinh + hiển thị
// ngay trên UI (devCode) thay vì gửi email/SMS thật. Khi có API, chỉ cần
// xoá phần hiển thị devCode và gọi endpoint gửi OTP thật ở bước "request".

import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import AuthLayout from "./AuthLayout";
import Icon from "../components/Icon";
import { useAuth } from "../auth/useAuth";
import { useLanguage } from "../i18n/LanguageContext";
import "../styles/AuthForm.css";

const STEP_REQUEST = "request";
const STEP_OTP = "otp";
const STEP_RESET = "reset";

export default function ForgotPassword() {
  const { requestPasswordReset, verifyOtp, resetPassword } = useAuth();
  const navigate = useNavigate();
  const { t } = useLanguage();

  const [step, setStep] = useState(STEP_REQUEST);
  const [username, setUsername] = useState("");
  const [otp, setOtp] = useState("");
  const [devCode, setDevCode] = useState("");
  const [passwords, setPasswords] = useState({ password: "", confirm: "" });
  const [error, setError] = useState("");

  function handleRequest(e) {
    e.preventDefault();
    setError("");
    const result = requestPasswordReset(username);
    if (!result.ok) {
      setError(result.message);
      return;
    }
    // Người dùng có thể đã nhập email — chuẩn hoá về đúng username nội bộ
    // để các bước xác thực OTP/đổi mật khẩu sau tra đúng.
    setUsername(result.username);
    setDevCode(result.devCode);
    setStep(STEP_OTP);
  }

  function handleVerify(e) {
    e.preventDefault();
    setError("");
    const result = verifyOtp(username, otp);
    if (!result.ok) {
      setError(result.message);
      return;
    }
    setStep(STEP_RESET);
  }

  function handleResend() {
    const result = requestPasswordReset(username);
    if (result.ok) {
      setDevCode(result.devCode);
      setOtp("");
      setError("");
    }
  }

  function handleReset(e) {
    e.preventDefault();
    setError("");

    if (passwords.password.length < 6) {
      setError(t("forgot.tooShort"));
      return;
    }
    if (passwords.password !== passwords.confirm) {
      setError(t("register.mismatch"));
      return;
    }

    const result = resetPassword(username, otp, passwords.password);
    if (!result.ok) {
      setError(result.message);
      return;
    }
    navigate("/login", { replace: true, state: { passwordReset: true } });
  }

  const titles = {
    [STEP_REQUEST]: {
      title: t("forgot.requestTitle"),
      subtitle: t("forgot.requestSubtitle"),
    },
    [STEP_OTP]: {
      title: t("forgot.otpTitle"),
      subtitle: t("forgot.otpSubtitle", { username }),
    },
    [STEP_RESET]: {
      title: t("forgot.resetTitle"),
      subtitle: t("forgot.resetSubtitle"),
    },
  };

  return (
    <AuthLayout hideTabs title={titles[step].title} subtitle={titles[step].subtitle}>
      <div className="lh-auth-form">
        <div className="lh-auth-steps" aria-hidden="true">
          <span className={step === STEP_REQUEST ? "is-active" : step !== STEP_REQUEST ? "is-done" : ""} />
          <span className={step === STEP_OTP ? "is-active" : step === STEP_RESET ? "is-done" : ""} />
          <span className={step === STEP_RESET ? "is-active" : ""} />
        </div>

        {step === STEP_REQUEST && (
          <form onSubmit={handleRequest} noValidate>
            <label className="lh-field">
              {t("forgot.identity")}
              <span className="lh-field__control">
                <Icon name="user" size={17} className="lh-field__icon" />
                <input
                  type="text"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  placeholder={t("forgot.identityPlaceholder")}
                  autoComplete="username"
                  required
                />
              </span>
            </label>

            {error && <p className="lh-auth-form__error">{error}</p>}

            <button type="submit" className="lh-btn lh-btn--primary lh-auth-form__submit">
              {t("forgot.send")}
            </button>
          </form>
        )}

        {step === STEP_OTP && (
          <form onSubmit={handleVerify} noValidate>
            {devCode && (
              <p className="lh-auth-form__success">
                {t("forgot.demoCode")} <strong>{devCode}</strong>
              </p>
            )}

            <label className="lh-field">
              {t("forgot.otp")}
              <input
                type="text"
                inputMode="numeric"
                maxLength={6}
                className="lh-otp-input"
                value={otp}
                onChange={(e) => setOtp(e.target.value.replace(/\D/g, "").slice(0, 6))}
                placeholder="••••••"
                required
              />
            </label>

            {error && <p className="lh-auth-form__error">{error}</p>}

            <button
              type="submit"
              className="lh-btn lh-btn--primary lh-auth-form__submit"
              disabled={otp.length !== 6}
            >
              {t("forgot.verify")}
            </button>

            <button type="button" className="lh-auth-form__linklike" onClick={handleResend}>
              {t("forgot.resend")}
            </button>
          </form>
        )}

        {step === STEP_RESET && (
          <form onSubmit={handleReset} noValidate>
            <label className="lh-field">
              {t("forgot.newPassword")}
              <span className="lh-field__control">
                <Icon name="lock" size={17} className="lh-field__icon" />
                <input
                  type="password"
                  value={passwords.password}
                  onChange={(e) => setPasswords((p) => ({ ...p, password: e.target.value }))}
                  placeholder="••••••••"
                  autoComplete="new-password"
                  required
                />
              </span>
            </label>
            <label className="lh-field">
              {t("forgot.confirmPassword")}
              <span className="lh-field__control">
                <Icon name="lock" size={17} className="lh-field__icon" />
                <input
                  type="password"
                  value={passwords.confirm}
                  onChange={(e) => setPasswords((p) => ({ ...p, confirm: e.target.value }))}
                  placeholder="••••••••"
                  autoComplete="new-password"
                  required
                />
              </span>
            </label>

            {error && <p className="lh-auth-form__error">{error}</p>}

            <button type="submit" className="lh-btn lh-btn--primary lh-auth-form__submit">
              {t("forgot.change")}
            </button>
          </form>
        )}

        <p className="lh-auth-form__switch-line">
          <Link to="/login">← {t("forgot.back")}</Link>
        </p>
      </div>
    </AuthLayout>
  );
}
