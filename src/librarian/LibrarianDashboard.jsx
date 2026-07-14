// src/librarian/LibrarianDashboard.jsx
import Icon from "../components/Icon";
import { useTickets, getTicketStatus } from "../data/librarianStore";
import { copiesStore } from "../data/adminStore";

export default function LibrarianDashboard() {
  const tickets = useTickets();
  const copies = copiesStore.useCollection();
  const fines = tickets.flatMap((t) => t.items.filter((it) => it.fine_amount > 0));

  const borrowing = tickets.filter((t) => getTicketStatus(t) === "borrowing").length;
  const overdue = tickets.filter((t) => getTicketStatus(t) === "overdue").length;
  const unpaidFineTotal = fines.filter((f) => !f.fine_paid).reduce((s, f) => s + f.fine_amount, 0);
  const availableCopies = copies.filter((c) => c.status === "available").length;

  const stats = [
    { label: "Phiếu đang mượn", value: borrowing, icon: "layers", accent: "var(--lh-gold)" },
    { label: "Phiếu quá hạn", value: overdue, icon: "check-circle", accent: "var(--lh-rust)" },
    {
      label: "Tiền phạt chưa thu",
      value: unpaidFineTotal.toLocaleString("vi-VN") + "đ",
      icon: "landmark",
      accent: "#8a5a9e",
    },
    { label: "Bản sách còn sẵn", value: availableCopies, icon: "compass", accent: "var(--lh-forest)" },
  ];

  return (
    <div className="lh-admin-page">
      <div className="lh-admin-page__head">
        <div>
          <h1 className="lh-admin-page__title">Tổng quan</h1>
          <p className="lh-admin-page__subtitle">Tình hình mượn/trả sách hiện tại.</p>
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

      <p style={{ color: "var(--lh-text-muted)", fontSize: "0.88rem" }}>
        Dùng menu bên trái để thêm/ẩn sách, tạo phiếu mượn mới, xử lý trả sách và theo dõi tiền
        phạt.
      </p>
    </div>
  );
}
