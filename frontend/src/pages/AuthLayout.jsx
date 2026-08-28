// src/pages/AuthLayout.jsx
//
// Signature concept: thẻ mượn sách kiểu "card catalog" xưa — 1 tấm thẻ nổi
// giữa trang, có "tab" ở mép trên (như tab của thẻ phích trong tủ mục lục
// thư viện) và 1 đường răng cưa (perforation) ngăn phần tab với nội dung.
// Ảnh nền chỉ còn là lớp khí quyển mờ phía sau, không còn chia đôi màn hình.

import { Link } from "react-router-dom";
import Icon from "../components/Icon";
import LanguageToggle from "../components/LanguageToggle";
import { useLanguage } from "../i18n/LanguageContext";
import "../styles/AuthLayout.css";

export default function AuthLayout({ mode, title, subtitle, children, hideTabs = false }) {
  const { t } = useLanguage();
  return (
    <div className="lh-auth lh-root">
      <div className="lh-auth__bg" aria-hidden="true" />
      <div className="lh-auth__overlay" aria-hidden="true" />

      <div className="lh-auth__stage">
        <Link to="/" className="lh-auth__home-link">
          <span aria-hidden="true">←</span> {t("auth.backHome")}
        </Link>
        <LanguageToggle className="lh-language--auth" />

        <div className="lh-auth-card">
          <div className="lh-auth-card__tab">
            <Icon name="book-open" size={20} />
          </div>
          <div className="lh-auth-card__perforation" aria-hidden="true" />

          {!hideTabs && (
            <div className="lh-auth-card__switch" role="tablist" aria-label={t("auth.switchLabel")}>
              <Link
                to="/login"
                role="tab"
                aria-selected={mode === "login"}
                className={`lh-auth-card__switch-btn ${mode === "login" ? "is-active" : ""}`}
              >
                {t("auth.login")}
              </Link>
              <Link
                to="/register"
                role="tab"
                aria-selected={mode === "register"}
                className={`lh-auth-card__switch-btn ${mode === "register" ? "is-active" : ""}`}
              >
                {t("auth.register")}
              </Link>
              <span
                className="lh-auth-card__switch-highlight"
                style={{ transform: mode === "register" ? "translateX(100%)" : "translateX(0%)" }}
                aria-hidden="true"
              />
            </div>
          )}

          <h1 className="lh-auth-card__title">{title}</h1>
          <p className="lh-auth-card__subtitle">{subtitle}</p>

          {children}
        </div>

        <ul className="lh-auth__bullets">
          <li>
            <Icon name="check-circle" size={15} /> {t("auth.bullet1")}
          </li>
          <li>
            <Icon name="check-circle" size={15} /> {t("auth.bullet2")}
          </li>
          <li>
            <Icon name="check-circle" size={15} /> {t("auth.bullet3")}
          </li>
        </ul>
      </div>
    </div>
  );
}
