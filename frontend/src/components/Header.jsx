import { useState } from "react";
import { Link } from "react-router-dom";
import Icon from "./Icon";
import { useAuth } from "../auth/useAuth";
import "../styles/Header.css";

const NAV_LINKS = [
  { label: "Kho sách", to: "/library" },
  { label: "Thể loại", to: "/genres" },
  { label: "Liên hệ", to: "/#contact" },
];

export default function Header() {
  const [open, setOpen] = useState(false);
  const { user, logout } = useAuth();

  return (
    <header className="lh-header">
      <div className="lh-container lh-header__inner">
        <Link to="/" className="lh-brand">
          <span className="lh-brand__mark">
            <Icon name="book-open" size={20} />
          </span>
          <span className="lh-brand__text">
            Lib<strong>Hub</strong>
          </span>
        </Link>

        <nav className="lh-nav lh-nav--desktop" aria-label="Điều hướng chính">
          {NAV_LINKS.map((link) => (
            <Link key={link.to} to={link.to}>
              {link.label}
            </Link>
          ))}
        </nav>

        <div className="lh-header__actions">
          <Link to="/library" className="lh-icon-btn" aria-label="Tìm sách">
            <Icon name="search" size={18} />
          </Link>

          {user ? (
            <div className="lh-header__user">
              <Link to="/account" className="lh-header__user-name">
                Xin chào, {user.full_name}
              </Link>
              {user.role_name === "Admin" && (
                <Link to="/admin" className="lh-btn lh-btn--ghost lh-header__cta">
                  Quản trị
                </Link>
              )}
              {(user.role_name === "Librarian" || user.role_name === "Admin") && (
                <Link to="/librarian" className="lh-btn lh-btn--ghost lh-header__cta">
                  Thủ thư
                </Link>
              )}
              <button className="lh-btn lh-btn--ghost lh-header__cta" onClick={logout}>
                Đăng xuất
              </button>
            </div>
          ) : (
            <Link to="/login" className="lh-btn lh-btn--primary lh-header__cta">
              Đăng nhập
            </Link>
          )}

          <button
            className="lh-icon-btn lh-nav-toggle"
            aria-label="Mở menu"
            aria-expanded={open}
            onClick={() => setOpen((v) => !v)}
          >
            <Icon name={open ? "arrow" : "layers"} size={18} />
          </button>
        </div>
      </div>

      {open && (
        <nav className="lh-nav lh-nav--mobile" aria-label="Điều hướng di động">
          {NAV_LINKS.map((link) => (
            <Link key={link.to} to={link.to} onClick={() => setOpen(false)}>
              {link.label}
            </Link>
          ))}
          {user ? (
            <>
              {user.role_name === "Admin" && (
                <Link to="/admin" onClick={() => setOpen(false)}>
                  Quản trị
                </Link>
              )}
              {(user.role_name === "Librarian" || user.role_name === "Admin") && (
                <Link to="/librarian" onClick={() => setOpen(false)}>
                  Thủ thư
                </Link>
              )}
              <Link to="/account" onClick={() => setOpen(false)}>
                Tài khoản của tôi
              </Link>
              <button
                className="lh-btn lh-btn--ghost"
                style={{ marginTop: 8 }}
                onClick={() => {
                  logout();
                  setOpen(false);
                }}
              >
                Đăng xuất ({user.full_name})
              </button>
            </>
          ) : (
            <Link to="/login" onClick={() => setOpen(false)}>
              Đăng nhập
            </Link>
          )}
        </nav>
      )}
    </header>
  );
}
