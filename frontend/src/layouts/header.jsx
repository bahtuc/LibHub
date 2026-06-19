import { useState } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import AccountCircleOutlinedIcon from "@mui/icons-material/AccountCircleOutlined";
import DarkModeOutlinedIcon from "@mui/icons-material/DarkModeOutlined";
import LightModeOutlinedIcon from "@mui/icons-material/LightModeOutlined";
import MenuIcon from "@mui/icons-material/Menu";
import CloseIcon from "@mui/icons-material/Close";
import { useAuth } from "../context/AuthContext";
import "../css/header.css";

const navLinks = [
  { label: "Home", href: "/" },
  { label: "Thư viện", href: "/library" },
  { label: "Thể loại", href: "/genres" },
  { label: "Sách nỗi bật", href: "/featured" },
  { label: "Liên hệ", href: "/contact" },
];

// SVG icon sách — thay cho emoji, theo chuẩn icon vector của skill UI/UX
function BookIcon() {
  return (
      <svg
          width="20"
          height="20"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.8"
          strokeLinecap="round"
          strokeLinejoin="round"
          aria-hidden="true"
      >
        <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20" />
        <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z" />
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
                <Link
                    key={link.label}
                    to={link.href}
                    className={`header_nav_link ${
                        location.pathname === link.href ? "header_nav_link_active" : ""
                    }`}
                    onClick={() => setMenuOpen(false)}
                >
                  {link.label}
                </Link>
            ))}
          </nav>

          <div className="header_actions">
            {isAuthenticated ? (
                <div className="header_user">
                  <Link to="/profile" className="header_user_name">
                    <AccountCircleOutlinedIcon sx={{ fontSize: 18 }} />
                    <span>{user.fullName || user.username}</span>
                  </Link>
                  <button className="header_btn_logout" onClick={handleLogout}>
                    Đăng xuất
                  </button>
                </div>
            ) : (
                <Link to="/login" className="header_btn_login">
                  <AccountCircleOutlinedIcon sx={{ fontSize: 18 }} />
                  Đăng nhập
                </Link>
            )}

            <button
                className="header_dark_toggle"
                onClick={toggleDark}
                aria-label={darkMode ? "Chuyển sang chế độ sáng" : "Chuyển sang chế độ tối"}
            >
              {darkMode ? (
                  <LightModeOutlinedIcon sx={{ fontSize: 20, color: "#f5e6c8" }} />
              ) : (
                  <DarkModeOutlinedIcon sx={{ fontSize: 20, color: "#f5e6c8" }} />
              )}
            </button>

            <button
                className="header_hamburger"
                onClick={() => setMenuOpen(!menuOpen)}
                aria-label={menuOpen ? "Đóng menu" : "Mở menu"}
                aria-expanded={menuOpen}
            >
              {menuOpen ? (
                  <CloseIcon sx={{ fontSize: 22, color: "#f5e6c8" }} />
              ) : (
                  <MenuIcon sx={{ fontSize: 22, color: "#f5e6c8" }} />
              )}
            </button>
          </div>
        </div>
      </header>
  );
}