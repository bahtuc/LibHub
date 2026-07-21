import { useEffect, useRef, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
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
  const { user } = useAuth();

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
            <UserMenu />
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
            <Icon name={open ? "x" : "layers"} size={18} />
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
            <MobileUserLinks onNavigate={() => setOpen(false)} />
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

function UserMenu() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [open, setOpen] = useState(false);
  const rootRef = useRef(null);

  useEffect(() => {
    function handleClickOutside(e) {
      if (rootRef.current && !rootRef.current.contains(e.target)) {
        setOpen(false);
      }
    }
    function handleEscape(e) {
      if (e.key === "Escape") setOpen(false);
    }
    document.addEventListener("mousedown", handleClickOutside);
    document.addEventListener("keydown", handleEscape);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
      document.removeEventListener("keydown", handleEscape);
    };
  }, []);

  const isAdmin = user.role_name === "Admin";
  const isLibrarian = user.role_name === "Librarian" || isAdmin;

  function go(path) {
    setOpen(false);
    navigate(path);
  }

  function handleLogout() {
    setOpen(false);
    logout();
  }

  return (
    <div className="lh-user-menu" ref={rootRef}>
      <button
        className="lh-user-menu__trigger"
        onClick={() => setOpen((v) => !v)}
        aria-haspopup="true"
        aria-expanded={open}
      >
        <span className="lh-user-menu__avatar">{user.full_name?.charAt(0)}</span>
        <span className="lh-user-menu__name">{user.full_name}</span>
        <Icon
          name="chevron-down"
          size={15}
          className={`lh-user-menu__chevron ${open ? "is-open" : ""}`}
        />
      </button>

      {open && (
        <div className="lh-user-menu__panel" role="menu">
          <div className="lh-user-menu__header">
            <span className="lh-user-menu__header-name">{user.full_name}</span>
            <span className="lh-user-menu__header-role">{user.role_name}</span>
          </div>

          <button className="lh-user-menu__item" role="menuitem" onClick={() => go("/account")}>
            <Icon name="user" size={16} />
            Tài khoản của tôi
          </button>

          {(isAdmin || isLibrarian) && (
            <>
              <div className="lh-user-menu__divider" />
              <p className="lh-user-menu__label">Công cụ</p>

              {isAdmin && (
                <button className="lh-user-menu__item" role="menuitem" onClick={() => go("/admin")}>
                  <Icon name="dashboard" size={16} />
                  Quản trị
                </button>
              )}
              {isLibrarian && (
                <button
                  className="lh-user-menu__item"
                  role="menuitem"
                  onClick={() => go("/librarian")}
                >
                  <Icon name="layers" size={16} />
                  Thủ thư
                </button>
              )}
            </>
          )}

          <div className="lh-user-menu__divider" />
          <button
            className="lh-user-menu__item lh-user-menu__item--danger"
            role="menuitem"
            onClick={handleLogout}
          >
            <Icon name="lock" size={16} />
            Đăng xuất
          </button>
        </div>
      )}
    </div>
  );
}

function MobileUserLinks({ onNavigate }) {
  const { user, logout } = useAuth();
  const isAdmin = user.role_name === "Admin";
  const isLibrarian = user.role_name === "Librarian" || isAdmin;

  return (
    <>
      <Link to="/account" onClick={onNavigate}>
        Tài khoản của tôi
      </Link>
      {isAdmin && (
        <Link to="/admin" onClick={onNavigate}>
          Quản trị
        </Link>
      )}
      {isLibrarian && (
        <Link to="/librarian" onClick={onNavigate}>
          Thủ thư
        </Link>
      )}
      <button
        className="lh-btn lh-btn--ghost"
        style={{ marginTop: 8 }}
        onClick={() => {
          logout();
          onNavigate();
        }}
      >
        Đăng xuất ({user.full_name})
      </button>
    </>
  );
}