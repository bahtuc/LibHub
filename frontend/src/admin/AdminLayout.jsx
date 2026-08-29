// src/admin/AdminLayout.jsx
import { NavLink, Outlet, Link } from "react-router-dom";
import Icon from "../components/Icon";
import { useAuth } from "../auth/useAuth";
import LanguageToggle from "../components/LanguageToggle";
import { useLanguage } from "../i18n/LanguageContext";
import "./admin.css";

const NAV_SECTIONS = [
  { label: "Điều hành", items: [
    { to: "/admin", label: "Tổng quan", icon: "dashboard", end: true },
    { to: "/admin/statistics", label: "Thống kê", icon: "star" },
  ]},
  { label: "Nghiệp vụ thủ thư", items: [
    { to: "/admin/borrow", label: "Lập phiếu mượn", icon: "plus" },
    { to: "/admin/circulation", label: "Mượn · trả sách", icon: "layers" },
    { to: "/admin/fine-collection", label: "Thu khoản phạt", icon: "landmark" },
    { to: "/admin/books", label: "Kho sách", icon: "book-open" },
    { to: "/admin/copies", label: "Bản sao sách", icon: "layers" },
  ]},
  { label: "Quản trị hệ thống", items: [
    { to: "/admin/categories", label: "Thể loại", icon: "compass" },
    { to: "/admin/authors", label: "Tác giả", icon: "users" },
    { to: "/admin/publishers", label: "Nhà xuất bản", icon: "users" },
    { to: "/admin/users", label: "Người dùng", icon: "user" },
    { to: "/admin/borrow-tickets", label: "Quản lý phiếu mượn", icon: "book-open" },
    { to: "/admin/fines", label: "Quản lý khoản phạt", icon: "briefcase" },
  ]},
];

export default function AdminLayout() {
  const { user, logout } = useAuth();
  const { t, translateLabel } = useLanguage();

  return (
    <div className="lh-admin lh-root">
      <aside className="lh-admin__sidebar">
        <div className="lh-admin__brand">
          <Icon name="book-open" size={20} />
          <span>
            Lib<strong>Hub</strong> {t("admin.brand")}
          </span>
        </div>

        <nav className="lh-admin__nav">
          {NAV_SECTIONS.map((section) => <div className="lh-admin__nav-section" key={section.label}>
            <p className="lh-admin__nav-label">{translateLabel(section.label)}</p>
            {section.items.map((item) => <NavLink key={item.to} to={item.to} end={item.end} className={({ isActive }) => (isActive ? "is-active" : "")}>
              <Icon name={item.icon} size={17} />{translateLabel(item.label)}
            </NavLink>)}
          </div>)}
        </nav>

        <div className="lh-admin__sidebar-foot">
          <LanguageToggle className="lh-language--sidebar" />
          <div className="lh-admin__whoami">
            <span className="lh-admin__whoami-avatar">{user?.full_name?.charAt(0)}</span>
            <span>
              <span className="lh-admin__whoami-name">{user?.full_name}</span>
              <br />
              <span className="lh-admin__whoami-role">{user?.role_name}</span>
            </span>
          </div>
          <div className="lh-admin__sidebar-foot-links">
            <Link to="/">
              <Icon name="arrow" size={14} style={{ transform: "rotate(180deg)" }} /> {t("admin.home")}
            </Link>
            <button onClick={logout}>
              <Icon name="lock" size={14} /> {t("nav.logout")}
            </button>
          </div>
        </div>
      </aside>

      <div className="lh-admin__content">
        <Outlet />
      </div>
    </div>
  );
}
