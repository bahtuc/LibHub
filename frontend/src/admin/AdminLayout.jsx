// src/admin/AdminLayout.jsx
import { NavLink, Outlet, Link } from "react-router-dom";
import Icon from "../components/Icon";
import { useAuth } from "../auth/useAuth";
import "./admin.css";

const NAV = [
  { to: "/admin", label: "Tổng quan", icon: "dashboard", end: true },
  { to: "/admin/books", label: "Kho sách", icon: "book-open" },
  { to: "/admin/copies", label: "Bản sao sách", icon: "layers" },
  { to: "/admin/categories", label: "Thể loại", icon: "compass" },
  { to: "/admin/authors", label: "Tác giả", icon: "users" },
  { to: "/admin/Publishers", label: "Nhà xuất bản", icon: "users" },
  { to: "/librarian/borrow", label: "Mượn sách", icon: "plus" },
  { to: "/admin/users", label: "Người dùng", icon: "user" },
];

export default function AdminLayout() {
  const { user, logout } = useAuth();

  return (
    <div className="lh-admin lh-root">
      <aside className="lh-admin__sidebar">
        <div className="lh-admin__brand">
          <Icon name="book-open" size={20} />
          <span>
            Lib<strong>Hub</strong> Admin
          </span>
        </div>

        <p className="lh-admin__nav-label">Quản lý</p>

        <nav className="lh-admin__nav">
          {NAV.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.end}
              className={({ isActive }) => (isActive ? "is-active" : "")}
            >
              <Icon name={item.icon} size={17} />
              {item.label}
            </NavLink>
          ))}
        </nav>

        <div className="lh-admin__sidebar-foot">
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
              <Icon name="arrow" size={14} style={{ transform: "rotate(180deg)" }} /> Về trang chủ
            </Link>
            <button onClick={logout}>
              <Icon name="lock" size={14} /> Đăng xuất
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
