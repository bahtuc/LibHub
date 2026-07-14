// src/librarian/LibrarianLayout.jsx
// Dùng chung khung/CSS với Admin (../admin/admin.css) để đồng bộ giao diện,
// chỉ khác menu điều hướng và nhãn thương hiệu.
import { NavLink, Outlet, Link } from "react-router-dom";
import Icon from "../components/Icon";
import { useAuth } from "../auth/useAuth";
import "../admin/admin.css";

const NAV = [
  { to: "/librarian", label: "Tổng quan", icon: "dashboard", end: true },
  { to: "/librarian/books", label: "Kho sách", icon: "book-open" },
  { to: "/librarian/borrow", label: "Mượn sách", icon: "plus" },
  { to: "/librarian/tickets", label: "Phiếu mượn", icon: "layers" },
  { to: "/librarian/fines", label: "Phạt", icon: "landmark" },
];

export default function LibrarianLayout() {
  const { user, logout } = useAuth();

  return (
    <div className="lh-admin lh-root">
      <aside className="lh-admin__sidebar">
        <div className="lh-admin__brand">
          <Icon name="book-open" size={20} />
          <span>
            Lib<strong>Hub</strong> Thủ thư
          </span>
        </div>

        <p className="lh-admin__nav-label">Nghiệp vụ</p>

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
