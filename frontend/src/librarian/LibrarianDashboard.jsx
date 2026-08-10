import Icon from "../components/Icon";
import { copiesStore } from "../data/adminStore";
import { getBorrowTicketViews } from "../services/BorrowTicketService";
import useLoanViews from "../hooks/useLoanViews";
import { getTicketStatus, isFinePaid } from "../utils/loanViews";

export default function LibrarianDashboard() {
  const { tickets, loading, error } = useLoanViews(getBorrowTicketViews);
  const copies = copiesStore.useCollection();
  const fines = tickets.flatMap((ticket) =>
    (ticket.items ?? []).filter((item) => item.fineId != null),
  );

  const borrowing = tickets.filter((ticket) => getTicketStatus(ticket) === "borrowing").length;
  const overdue = tickets.filter((ticket) => getTicketStatus(ticket) === "overdue").length;
  const unpaidFineTotal = fines
    .filter((fine) => !isFinePaid(fine))
    .reduce((total, fine) => total + Number(fine.fineAmount || 0), 0);
  const availableCopies = copies.filter((copy) => copy.status === "available").length;

  const stats = [
    { label: "Phiếu đang mượn", value: borrowing, icon: "layers", accent: "var(--lh-gold)" },
    { label: "Phiếu quá hạn", value: overdue, icon: "check-circle", accent: "var(--lh-rust)" },
    {
      label: "Tiền phạt chưa thu",
      value: `${unpaidFineTotal.toLocaleString("vi-VN")}đ`,
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
          <p className="lh-admin-page__subtitle">Tình hình mượn, trả và phạt hiện tại.</p>
        </div>
      </div>

      {error && <p className="lh-auth-form__error">{error}</p>}

      <div className="lh-admin-stats">
        {stats.map((stat) => (
          <div className="lh-admin-stat-card" key={stat.label} style={{ "--accent": stat.accent }}>
            <span className="lh-admin-stat-card__icon"><Icon name={stat.icon} size={18} /></span>
            <span className="lh-admin-stat-card__value">{loading ? "…" : stat.value}</span>
            <span className="lh-admin-stat-card__label">{stat.label}</span>
          </div>
        ))}
      </div>

    </div>
  );
}
