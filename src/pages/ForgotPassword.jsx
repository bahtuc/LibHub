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
import "../styles/AuthForm.css";

const STEP_REQUEST = "request";
const STEP_OTP = "otp";
const STEP_RESET = "reset";

export default function ForgotPassword() {
  const { requestPasswordReset, verifyOtp, resetPassword } = useAuth();
  const navigate = useNavigate();

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
      setError("Mật khẩu cần tối thiểu 6 ký tự.");
      return;
    }
    if (passwords.password !== passwords.confirm) {
      setError("Mật khẩu nhập lại không khớp.");
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
      title: "Quên mật khẩu",
      subtitle: "Nhập tên đăng nhập, mình sẽ gửi mã OTP 6 số để xác nhận.",
    },
    [STEP_OTP]: {
      title: "Nhập mã OTP",
      subtitle: `Mã OTP 6 số đã "gửi" cho tài khoản ${username}.`,
    },
    [STEP_RESET]: {
      title: "Đặt mật khẩu mới",
      subtitle: "Xác thực thành công, nhập mật khẩu mới cho tài khoản của bạn.",
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
              Tên đăng nhập
              <span className="lh-field__control">
                <Icon name="user" size={17} className="lh-field__icon" />
                <input
                  type="text"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  placeholder="vd: admin"
                  autoComplete="username"
                  required
                />
              </span>
            </label>

            {error && <p className="lh-auth-form__error">{error}</p>}

            <button type="submit" className="lh-btn lh-btn--primary lh-auth-form__submit">
              Gửi mã OTP
            </button>
          </form>
        )}

        {step === STEP_OTP && (
          <form onSubmit={handleVerify} noValidate>
            {devCode && (
              <p className="lh-auth-form__success">
                Demo (chưa nối email/SMS): mã OTP của bạn là <strong>{devCode}</strong>
              </p>
            )}

            <label className="lh-field">
              Mã OTP (6 số)
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
              Xác nhận mã OTP
            </button>

            <button type="button" className="lh-auth-form__linklike" onClick={handleResend}>
              Gửi lại mã
            </button>
          </form>
        )}

        {step === STEP_RESET && (
          <form onSubmit={handleReset} noValidate>
            <label className="lh-field">
              Mật khẩu mới
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
              Xác nhận mật khẩu mới
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
              Đổi mật khẩu
            </button>
          </form>
        )}

        <p className="lh-auth-form__switch-line">
          <Link to="/login">← Quay lại đăng nhập</Link>
        </p>
      </div>
    </AuthLayout>
  );
}
