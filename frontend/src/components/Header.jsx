import { useEffect, useState } from "react";
import { Link, NavLink, useLocation } from "react-router-dom";
import Icon from "./Icon";
import { useAuth } from "../auth/useAuth";
import BookChatbot from "./BookChatbot";
import LanguageToggle from "./LanguageToggle";
import { useLanguage } from "../i18n/LanguageContext";
import "../styles/Header.css";

const NAV_LINKS = [
  { labelKey: "nav.home", to: "/", end: true },
  { labelKey: "nav.library", to: "/library" },
  { labelKey: "nav.genres", to: "/genres" },
];

export default function Header() {
  const [open, setOpen] = useState(false);
  const { t } = useLanguage();
  const { user, logout } = useAuth();
  const location = useLocation();
  const role = String(user?.role_name ?? "").toLowerCase();
  const workspace = role === "admin"
    ? { to: "/admin", label: t("nav.admin") }
    : role === "librarian"
      ? { to: "/librarian", label: t("nav.librarian") }
      : null;

  useEffect(() => setOpen(false), [location.pathname]);

  return (
    <header className="lh-header">
      <div className="lh-container lh-header__inner">
        <Link to="/" className="lh-brand" aria-label={`LibHub — ${t("nav.home")}`}>
          <span className="lh-brand__mark"><Icon name="book-open" size={19} /></span>
          <span className="lh-brand__text">LIBHUB<small>{t("brand.subtitle")}</small></span>
        </Link>

        <nav className="lh-nav lh-nav--desktop" aria-label="Điều hướng chính">
          {NAV_LINKS.map((link) => (
            <NavLink key={link.to} to={link.to} end={link.end}>{t(link.labelKey)}</NavLink>
          ))}
        </nav>

        <div className="lh-header__actions">
          <LanguageToggle />
          <Link to="/library" className="lh-icon-btn" aria-label={t("nav.search")}><Icon name="search" size={18} /></Link>
          {workspace && <Link to={workspace.to} className="lh-btn lh-btn--dark lh-header__cta">{workspace.label}</Link>}
          {user ? (
            <>
              <Link to="/account" className="lh-header__profile" title={user.full_name}>
                <span>{user.full_name?.charAt(0)?.toUpperCase() || "U"}</span>
                <em>{user.full_name?.split(" ").slice(-1)[0]}</em>
              </Link>
              <button type="button" className="lh-btn lh-btn--ghost lh-header__cta" onClick={logout}>{t("nav.logout")}</button>
            </>
          ) : <Link to="/login" className="lh-btn lh-btn--primary lh-header__cta">{t("nav.login")}</Link>}
          <button type="button" className="lh-icon-btn lh-nav-toggle" aria-label={open ? t("nav.closeMenu") : t("nav.openMenu")} aria-expanded={open} aria-controls="mobile-navigation" onClick={() => setOpen((value) => !value)}>
            <Icon name={open ? "x" : "layers"} size={18} />
          </button>
        </div>
      </div>

      {open && (
        <nav id="mobile-navigation" className="lh-nav lh-nav--mobile" aria-label="Điều hướng di động">
          {NAV_LINKS.map((link) => <NavLink key={link.to} to={link.to} end={link.end}>{t(link.labelKey)}</NavLink>)}
          {workspace && <Link to={workspace.to}>{workspace.label}</Link>}
          <Link to="/account">{t("nav.account")}</Link>
          {user ? <button type="button" onClick={logout}>{t("nav.logout")}</button> : <Link to="/login">{t("nav.login")}</Link>}
        </nav>
      )}
      <BookChatbot />
    </header>
  );
}
