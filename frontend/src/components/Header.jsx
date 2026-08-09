import { useState } from "react";
import { Link } from "react-router-dom";
import Icon from "./Icon";
import { useAuth } from "../auth/useAuth";
import "../styles/Header.css";

const NAV_LINKS = [{ label: "Kho sách", to: "/library" }, { label: "Thể loại", to: "/genres" }, { label: "Liên hệ", to: "/#contact" }];
export default function Header() {
  const [open, setOpen] = useState(false); const { user, logout } = useAuth();
  const panel = user?.role_name === "Admin" ? { to: "/admin", label: "Quản trị" } : user?.role_name === "Librarian" ? { to: "/librarian", label: "Thủ thư" } : null;
  return <header className="lh-header"><div className="lh-container lh-header__inner"><Link to="/" className="lh-brand"><span className="lh-brand__mark"><Icon name="book-open" size={20}/></span><span className="lh-brand__text">Lib<strong>Hub</strong></span></Link><nav className="lh-nav lh-nav--desktop">{NAV_LINKS.map((link) => <Link key={link.to} to={link.to}>{link.label}</Link>)}</nav><div className="lh-header__actions"><Link to="/library" className="lh-icon-btn" aria-label="Tìm sách"><Icon name="search" size={18}/></Link>{panel && <Link to={panel.to} className="lh-btn lh-btn--primary lh-header__cta">{panel.label}</Link>}<Link to="/account" className="lh-btn lh-btn--ghost lh-header__cta">{user ? `Xin chào, ${user.full_name}` : "Trang của tôi"}</Link>{user ? <button className="lh-btn lh-btn--ghost lh-header__cta" onClick={logout}>Đăng xuất</button> : <Link to="/login" className="lh-btn lh-btn--primary lh-header__cta">Đăng nhập</Link>}<button className="lh-icon-btn lh-nav-toggle" aria-label={open ? "Đóng menu" : "Mở menu"} aria-expanded={open} onClick={() => setOpen(!open)}><Icon name={open ? "arrow" : "layers"} size={18}/></button></div></div>{open && <nav className="lh-nav lh-nav--mobile">{NAV_LINKS.map((link) => <Link key={link.to} to={link.to} onClick={() => setOpen(false)}>{link.label}</Link>)}{panel && <Link to={panel.to} onClick={() => setOpen(false)}>{panel.label}</Link>}<Link to="/account" onClick={() => setOpen(false)}>Trang của tôi</Link>{user ? <button onClick={logout}>Đăng xuất</button> : <Link to="/login">Đăng nhập</Link>}</nav>}</header>;
}
