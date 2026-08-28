// src/admin/AdminDashboard.jsx
import Icon from "../components/Icon";
import { useEffect, useState } from "react";
import { booksStore, categoriesStore, authorsStore, copiesStore, usersStore } from "../data/adminStore";
import { getMonthlySummary } from "../services/StatisticsService";
import "./admin.css";

export default function AdminDashboard() {
  const bookList = booksStore.useCollection();
  const categoryList = categoriesStore.useCollection();
  const authorList = authorsStore.useCollection();
  const copyList = copiesStore.useCollection();
  const userList = usersStore.useCollection();
  const [monthlySummary, setMonthlySummary] = useState(null);

  useEffect(() => {
    getMonthlySummary()
      .then(setMonthlySummary)
      .catch(() => setMonthlySummary(null));
  }, []);

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
  const monthlyStats = [
    { label: "Sách mượn trong tháng", value: monthlySummary?.borrowedBookCount ?? "…", icon: "book-open", accent: "var(--lh-gold)" },
    { label: "Sách trả trong tháng", value: monthlySummary?.returnedBookCount ?? "…", icon: "check-circle", accent: "var(--lh-forest)" },
    { label: "Sách chưa có người mượn", value: monthlySummary?.neverBorrowedBookCount ?? "…", icon: "compass", accent: "#8a5a9e" },
    { label: "Tiền phạt đã thu", value: monthlySummary ? `${Number(monthlySummary.paidFineTotal || 0).toLocaleString("vi-VN")}đ` : "…", icon: "landmark", accent: "var(--lh-rust)" },
    { label: "Doanh thu tiền cọc", value: monthlySummary ? `${Number(monthlySummary.depositRevenue || 0).toLocaleString("vi-VN")}đ` : "…", icon: "landmark", accent: "#2d7a53" },
    { label: "Tổng doanh thu", value: monthlySummary ? `${Number(monthlySummary.totalRevenue || 0).toLocaleString("vi-VN")}đ` : "…", icon: "landmark", accent: "#2e4a6b" },
  ];

  return (
    <div className="lh-admin-page">
      <div className="lh-admin-page__head">
        <div>
          <h1 className="lh-admin-page__title">Tổng quan</h1>
          <p className="lh-admin-page__subtitle">
            Số liệu nhanh từ dữ liệu hiện có trong hệ thống (đã tính cả thay đổi bạn thêm/sửa).
          </p>
        </div>
      </div>

      <div className="lh-admin-stats">
        {stats.map((s) => (
          <div className="lh-admin-stat-card" key={s.label} style={{ "--accent": s.accent }}>
            <span className="lh-admin-stat-card__icon">
              <Icon name={s.icon} size={18} />
            </span>
            <span className="lh-admin-stat-card__value">{s.value}</span>
            <span className="lh-admin-stat-card__label">{s.label}</span>
          </div>
        ))}
      </div>

      <section className="lh-dashboard-section">
        <div className="lh-dashboard-section__head">
          <div>
            <h2>Thống kê tháng này</h2>
            <p>Tiền phạt được tính theo các khoản đã thanh toán; doanh thu gồm tiền phạt và tiền cọc đã thu.</p>
          </div>
        </div>
        <div className="lh-admin-stats">
          {monthlyStats.map((s) => (
            <div className="lh-admin-stat-card" key={s.label} style={{ "--accent": s.accent }}>
              <span className="lh-admin-stat-card__icon"><Icon name={s.icon} size={18} /></span>
              <span className="lh-admin-stat-card__value">{s.value}</span>
              <span className="lh-admin-stat-card__label">{s.label}</span>
            </div>
          ))}
        </div>
      </section>

      <p style={{ color: "var(--lh-text-muted)", fontSize: "0.88rem" }}>
        Dùng menu bên trái để quản lý chi tiết từng bảng: Kho sách, Bản sao sách, Thể loại, Tác
        giả, Người dùng.
      </p>
    </div>
  );
}
