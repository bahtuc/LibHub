// src/admin/AdminDashboard.jsx
import Icon from "../components/Icon";
import { Link } from "react-router-dom";
import { booksStore, categoriesStore, authorsStore, copiesStore, usersStore } from "../data/adminStore";
import { useLanguage } from "../i18n/LanguageContext";
import "./admin.css";

export default function AdminDashboard() {
  const { translateLabel } = useLanguage();
  const bookList = booksStore.useCollection();
  const categoryList = categoriesStore.useCollection();
  const authorList = authorsStore.useCollection();
  const copyList = copiesStore.useCollection();
  const userList = usersStore.useCollection();

  const borrowedCopies = copyList.filter((c) => c.status === "borrowed").length;
  const availableCopies = copyList.filter((c) => c.status === "available").length;

  const stats = [
    { label: "Đầu sách", value: bookList.length, icon: "book-open", accent: "var(--lh-gold)" },
    { label: "Bản sao sách", value: copyList.length, icon: "layers", accent: "#2e4a6b" },
    { label: "Đang được mượn", value: borrowedCopies, icon: "check-circle", accent: "var(--lh-rust)" },
    { label: "Bản còn sẵn", value: availableCopies, icon: "compass", accent: "var(--lh-forest)" },
    { label: "Thể loại", value: categoryList.length, icon: "compass", accent: "#8a5a9e" },
    { label: "Tác giả", value: authorList.length, icon: "users", accent: "var(--lh-gold)" },
    { label: "Người dùng", value: userList.length, icon: "user", accent: "var(--lh-forest)" },
  ];
  const librarianActions = [
    { to: "/admin/borrow", title: "Lập phiếu mượn", text: "Cho thành viên hoặc khách vãng lai mượn sách.", icon: "plus" },
    { to: "/admin/circulation", title: "Xử lý mượn · trả", text: "Theo dõi phiếu, nhận sách trả và ghi nhận tình trạng.", icon: "layers" },
    { to: "/admin/fine-collection", title: "Thu khoản phạt", text: "Kiểm tra và xác nhận các khoản phạt đã thu.", icon: "landmark" },
    { to: "/admin/books", title: "Vận hành kho sách", text: "Thêm, chỉnh sửa, nhập dữ liệu và ẩn hiện đầu sách.", icon: "book-open" },
  ];

  return (
    <div className="lh-admin-page">
      <div className="lh-admin-page__head">
        <div>
          <h1 className="lh-admin-page__title">{translateLabel("Tổng quan")}</h1>
          <p className="lh-admin-page__subtitle">
            {translateLabel("Số liệu nhanh từ dữ liệu hiện có trong hệ thống (đã tính cả thay đổi bạn thêm/sửa).")}
          </p>
        </div>
      </div>

      <div className="lh-admin-stats">
        {stats.map((s) => (
          <div className={`lh-admin-stat-card ${String(s.value).length > 6 ? "has-long-value" : ""}`} key={s.label} style={{ "--accent": s.accent }}>
            <span className="lh-admin-stat-card__icon">
              <Icon name={s.icon} size={18} />
            </span>
            <span className="lh-admin-stat-card__value">{s.value}</span>
            <span className="lh-admin-stat-card__label">{translateLabel(s.label)}</span>
          </div>
        ))}
      </div>

      <section className="lh-dashboard-section">
        <div className="lh-dashboard-section__head"><div><h2>{translateLabel("Nghiệp vụ thủ thư")}</h2><p>{translateLabel("Admin có đầy đủ quyền vận hành quầy mượn trả.")}</p></div><Link className="lh-btn lh-btn--ghost" to="/admin/statistics">{translateLabel("Xem thống kê")} <Icon name="arrow" size={14}/></Link></div>
        <div className="lh-admin-actions">{librarianActions.map((action) => <Link to={action.to} className="lh-admin-action" key={action.to}><span><Icon name={action.icon} size={20}/></span><div><strong>{translateLabel(action.title)}</strong><small>{translateLabel(action.text)}</small></div><Icon name="arrow" size={16}/></Link>)}</div>
      </section>

      <p style={{ color: "var(--lh-text-muted)", fontSize: "0.88rem" }}>
        {translateLabel("Dùng menu bên trái để truy cập nghiệp vụ thủ thư, quản trị dữ liệu và báo cáo thống kê.")}
      </p>
    </div>
  );
}
