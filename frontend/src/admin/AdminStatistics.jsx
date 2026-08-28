import { useEffect, useState } from "react";
import Icon from "../components/Icon";
import { getMonthlySummary } from "../services/StatisticsService";

export default function AdminStatistics() {
  const [summary, setSummary] = useState(null);
  const [error, setError] = useState("");
  useEffect(() => { getMonthlySummary().then(setSummary).catch((e) => setError(e.message || "Không tải được thống kê.")); }, []);
  const money = (value) => `${Number(value || 0).toLocaleString("vi-VN")}đ`;
  const stats = [
    { label: "Sách mượn trong tháng", value: summary?.borrowedBookCount, icon: "book-open", accent: "var(--lh-gold)" },
    { label: "Sách trả trong tháng", value: summary?.returnedBookCount, icon: "check-circle", accent: "var(--lh-forest)" },
    { label: "Sách chưa có người mượn", value: summary?.neverBorrowedBookCount, icon: "compass", accent: "#8a5a9e" },
    { label: "Tiền phạt đã thu", value: summary && money(summary.paidFineTotal), icon: "landmark", accent: "var(--lh-rust)" },
    { label: "Doanh thu phí mượn", value: summary && money(summary.borrowFeeRevenue), icon: "landmark", accent: "#2d7a53" },
    { label: "Tổng doanh thu", value: summary && money(summary.totalRevenue), icon: "landmark", accent: "#2e4a6b" },
  ];
  return <div className="lh-admin-page">
    <div className="lh-admin-page__head"><div><h1 className="lh-admin-page__title">Thống kê</h1><p className="lh-admin-page__subtitle">Hiệu quả lưu thông sách và doanh thu trong tháng hiện tại.</p></div></div>
    {error && <p className="lh-auth-form__error">{error}</p>}
    <div className="lh-admin-stats">{stats.map((s) => <div className={`lh-admin-stat-card ${String(s.value ?? "…").length > 6 ? "has-long-value" : ""}`} key={s.label} style={{ "--accent": s.accent }}><span className="lh-admin-stat-card__icon"><Icon name={s.icon} size={18}/></span><span className="lh-admin-stat-card__value">{s.value ?? "…"}</span><span className="lh-admin-stat-card__label">{s.label}</span></div>)}</div>
    <section className="lh-dashboard-section"><div className="lh-dashboard-section__head"><div><h2>Mức độ đọc sách</h2><p>Xếp theo tổng lượt mượn, bao gồm sách chưa từng được đọc.</p></div></div>
      <div className="lh-statistics-rankings">{[["Được đọc nhiều nhất", summary?.mostBorrowedBooks], ["Được đọc ít nhất", summary?.leastBorrowedBooks]].map(([title, rows]) => <div className="lh-admin-table-wrap" key={title}><div className="lh-statistics-rankings__title">{title}</div><table className="lh-admin-table"><thead><tr><th>Sách</th><th>Lượt mượn</th></tr></thead><tbody>{(rows || []).map((b) => <tr key={b.bookId}><td>{b.title}</td><td>{b.borrowCount}</td></tr>)}{summary && !(rows || []).length && <tr><td colSpan="2" className="lh-admin-table__empty">Chưa có dữ liệu.</td></tr>}</tbody></table></div>)}</div>
    </section>
  </div>;
}
