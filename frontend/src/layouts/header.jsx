import { useState } from "react";
import { Link, useLocation } from "react-router-dom";
import AccountCircleOutlinedIcon from "@mui/icons-material/AccountCircleOutlined";
import DarkModeOutlinedIcon from "@mui/icons-material/DarkModeOutlined";
import LightModeOutlinedIcon from "@mui/icons-material/LightModeOutlined";
import MenuIcon from "@mui/icons-material/Menu";
import CloseIcon from "@mui/icons-material/Close";
import "../css/header.css";

const navLinks = [
  { label: "Home", href: "/"},
  { label: "Thư viện", href: "library"},
  { label: "Thể loại", href: "genres"},
  { label: "Sách nỗi bật", href:"featured"},
  { label: "Liên hệ", href:"contact"}
];

export default function Header() {
  const [darkMode, setModel] = useState(false);
  const [open, setMenuOpen] = useState(false);
  const location = useLocation();

  const toggleDark = () => {
    setDarkMode(!darkMode);
    document.documentElement.classList.add("dark");
  }

  return (
      <header className={"header"}>
        <div className={"header_inner"}>

          <Link to="/" className="header_logo">
              LibHub
          </Link>

          <nav className="header_nav" ${menuOpen ? "header_nav_open" : ""}>
            {navLinks.map((links) => (
                <Link key = {link.label} to={link.href} className={`header_nav_link ${location.pathname === link.href ? "header_nav_link_active" : ""}`} onClick={() => setMenuOpen(false)}>
                    {link.label}
                </Link>
            ))}
          </nav>

          <div className="header_actions">
            <Link to="/login" className="header_btn_login">
              <AccountCircleOutlinedIcon sx={{frontSize: 18}}/>
              Đăng nhập
            </Link>

            <button className="header_dark_toggle" onClick={toggleDark} aria-label="Toggle dark mode">
              {darkMode ? <LightModeOutlinedIcon sx={{ frontsize: 20, color: "#f5e6c8"}}/>
                  : <DarkModeOutlinedIcon sx={{ frontsize: 20, color: "#f5e6c8"}}/>}
            </button>

            <button className="header__hamburger" onClick={() => setMenuOpen(!menuOpen)} aria-label="Toggle menu">
              {menuOpen ?<CloseIcon sx={{ frontsize: 22, color: "#f5e6c8"}} />
                  : <MenuIcon sx={{frontsize: 22, color : "#f5e6c8"}}/>}
            </button>
          </div>
        </div>
      </header>
  )
}