import { useState } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import "../css/header.css";

const navLinks = [
  { label: "Home", href: "/" },
  { label: "Thư viện", href: "/library" },
  { label: "Thể loại", href: "/genres" },
  { label: "Sách nỗi bật", href: "/featured" },
  { label: "Liên hệ", href: "/contact" },
];

function BookIcon() {
  return (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
        <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20" />
        <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z" />
      </svg>
  );
}

function UserIcon({ size = 18 }) {
  return (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
        <circle cx="12" cy="8" r="4" />
        <path d="M4 21c0-3.5 3.5-6 8-6s8 2.5 8 6" />
      </svg>
  );
}

function MoonIcon({ size = 20 }) {
  return (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
        <path d="M21 12.5A9 9 0 1 1 11.5 3a7 7 0 0 0 9.5 9.5z" />
      </svg>
  );
}

function SunIcon({ size = 20 }) {
  return (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
        <circle cx="12" cy="12" r="4.5" />
        <path d="M12 2v2.5M12 19.5V22M4.2 4.2l1.8 1.8M18 18l1.8 1.8M2 12h2.5M19.5 12H22M4.2 19.8l1.8-1.8M18 6l1.8-1.8" />
      </svg>
  );
}

function MenuIcon({ size = 22 }) {
  return (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
        <path d="M3 6h18M3 12h18M3 18h18" />
      </svg>
  );
}

function CloseIcon({ size = 22 }) {
  return (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
        <path d="M18 6 6 18M6 6l12 12" />
      </svg>
  );
}

export default function Header() {
  const [darkMode, setDarkMode] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);
  const location = useLocation();
  const navigate = useNavigate();
  const { user, isAuthenticated, logout } = useAuth();

  const toggleDark = () => {
    const next = !darkMode;
    setDarkMode(next);
    document.documentElement.classList.toggle("dark", next);
  };

  async function handleLogout() {
    await logout();
    navigate("/");
  }

  return (
      <header className="header">
        <div className="header_inner">
          <Link to="/" className="header_logo">
          <span className="header_logo_icon" aria-hidden="true">
            <BookIcon />
          </span>
            LibHub
          </Link>

          <nav className={`header_nav ${menuOpen ? "header_nav--open" : ""}`}>
            {navLinks.map((link) => (
                <Link key={link.label} to={link.href} className={`header_nav_link ${location.pathname === link.href ? "header_nav_link_active" : ""}`} onClick={() => setMenuOpen(false)}>{link.label}</Link>
            ))}
          </nav>

          <div className="header_actions">
            {isAuthenticated ? (
                <div className="header_user">
                  <Link to="/profile" className="header_user_name">
                    <UserIcon size={16} />
                    <span>{user.fullName || user.username}</span>
                  </Link>
                  <button className="header_btn_logout" onClick={handleLogout}>
                    Đăng xuất
                  </button>
                </div>
            ) : (
                <Link to="/login" className="header_btn_login">
                  <UserIcon size={16} />
                  Đăng nhập
                </Link>
            )}

            <button className="header_dark_toggle" onClick={toggleDark} aria-label={darkMode ? "Chuyển sang chế độ sáng" : "Chuyển sang chế độ tối"}>{darkMode ? <SunIcon /> : <MoonIcon />}</button>

            <button className="header_hamburger" onClick={() => setMenuOpen(!menuOpen)} aria-label={menuOpen ? "Đóng menu" : "Mở menu"} aria-expanded={menuOpen}>{menuOpen ? <CloseIcon /> : <MenuIcon />}</button>
          </div>
        </div>
      </header>
  );
}