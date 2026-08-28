import Icon from "../components/Icon";
import { copiesStore } from "../data/adminStore";
import { getBorrowTicketViews } from "../services/BorrowTicketService";
import useLoanViews from "../hooks/useLoanViews";
import { getTicketStatus, isFinePaid } from "../utils/loanViews";
import { formatDate } from "../utils/format";

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
  const revenueTotal = fines
    .filter((fine) => isFinePaid(fine))
    .reduce((total, fine) => total + Number(fine.fineAmount || 0), 0);
  const availableCopies = copies.filter((copy) => copy.status === "available").length;
  const borrowedBooks = tickets.flatMap((ticket) =>
    ["borrowing", "overdue"].includes(getTicketStatus(ticket))
      ? (ticket.items ?? [])
        .filter((item) => !item.returnedDate && !["returned", "lost", "cancelled"].includes(String(item.borrowStatus || "").toLowerCase()))
        .map((item) => ({ ...item, ticketId: ticket.ticketId, userName: ticket.userName, borrowDate: item.borrowDate || ticket.borrowDate, dueDate: item.dueDate || ticket.dueDate }))
      : [],
  );

  const stats = [
    { label: "Phiếu đang mượn", value: borrowing, icon: "layers", accent: "var(--lh-gold)" },
    { label: "Phiếu quá hạn", value: overdue, icon: "check-circle", accent: "var(--lh-rust)" },
    {
      label: "Tiền phạt chưa thu",
      value: `${unpaidFineTotal.toLocaleString("vi-VN")}đ`,
      icon: "landmark",
      accent: "#8a5a9e",
    },
    {
      label: "Doanh số phạt đã thu",
      value: `${revenueTotal.toLocaleString("vi-VN")}đ`,
      icon: "landmark",
      accent: "#2d7a53",
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
          <div className={`lh-admin-stat-card ${String(stat.value).length > 6 ? "has-long-value" : ""}`} key={stat.label} style={{ "--accent": stat.accent }}>
            <span className="lh-admin-stat-card__icon"><Icon name={stat.icon} size={18} /></span>
            <span className="lh-admin-stat-card__value">{loading ? "…" : stat.value}</span>
            <span className="lh-admin-stat-card__label">{stat.label}</span>
          </div>
        ))}
      </div>

      <section className="lh-dashboard-section">
        <div className="lh-dashboard-section__head">
          <div>
            <h2>Sách đang mượn</h2>
            <p>{loading ? "Đang tải dữ liệu…" : `${borrowedBooks.length} cuốn chưa được trả`}</p>
          </div>
        </div>
        <div className="lh-admin-table-wrap">
          <div className="lh-admin-table-scroll">
            <table className="lh-admin-table">
              <thead><tr><th>Sách</th><th>Bạn đọc</th><th>Phiếu</th><th>Ngày mượn</th><th>Hạn trả</th></tr></thead>
              <tbody>
                {borrowedBooks.map((book) => (
                  <tr key={`${book.ticketId}-${book.detailId ?? book.copyId}`}>
                    <td>{book.bookTitle || book.barcode || "—"}</td>
                    <td>{book.userName || "Khách vãng lai"}</td>
                    <td>#{book.ticketId}</td>
                    <td className="lh-mono">{formatDate(book.borrowDate)}</td>
                    <td className="lh-mono">{formatDate(book.dueDate)}</td>
                  </tr>
                ))}
                {!loading && borrowedBooks.length === 0 && (
                  <tr><td colSpan={5} className="lh-admin-table__empty">Hiện không có cuốn sách nào đang mượn.</td></tr>
                )}
                {loading && <tr><td colSpan={5} className="lh-admin-table__empty">Đang tải...</td></tr>}
              </tbody>
            </table>
          </div>
        </div>
      </section>

    </div>
  );
}
