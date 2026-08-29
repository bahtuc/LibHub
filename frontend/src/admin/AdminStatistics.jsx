import { useEffect, useState } from "react";
import Icon from "../components/Icon";
import { getMonthlySummary } from "../services/StatisticsService";
import { useLanguage } from "../i18n/LanguageContext";

export default function AdminStatistics() {
  const { translateLabel, formatCurrency } = useLanguage();
  const [summary, setSummary] = useState(null);
  const [error, setError] = useState("");
  useEffect(() => { getMonthlySummary().then(setSummary).catch((e) => setError(e.message || "Không tải được thống kê.")); }, []);
  const money = formatCurrency;
  const stats = [
    { label: "Sách mượn trong tháng", value: summary?.borrowedBookCount, icon: "book-open", accent: "var(--lh-gold)" },
    { label: "Sách trả trong tháng", value: summary?.returnedBookCount, icon: "check-circle", accent: "var(--lh-forest)" },
    { label: "Sách chưa có người mượn", value: summary?.neverBorrowedBookCount, icon: "compass", accent: "#8a5a9e" },
  ];
  const revenueRows = [
    { source: "Phí mượn sách", amount: summary?.borrowFeeRevenue, note: "Các phiếu đã thanh toán trong tháng" },
    { source: "Tiền phạt đã thu", amount: summary?.paidFineTotal, note: "Các khoản phạt đã thanh toán trong tháng" },
  ];
  return <div className="lh-admin-page">
    <div className="lh-admin-page__head"><div><h1 className="lh-admin-page__title">{translateLabel("Thống kê")}</h1><p className="lh-admin-page__subtitle">{translateLabel("Hiệu quả lưu thông sách và doanh thu trong tháng hiện tại.")}</p></div></div>
    {error && <p className="lh-auth-form__error">{error}</p>}
    <div className="lh-admin-stats">{stats.map((s) => <div className={`lh-admin-stat-card ${String(s.value ?? "…").length > 6 ? "has-long-value" : ""}`} key={s.label} style={{ "--accent": s.accent }}><span className="lh-admin-stat-card__icon"><Icon name={s.icon} size={18}/></span><span className="lh-admin-stat-card__value">{s.value ?? "…"}</span><span className="lh-admin-stat-card__label">{translateLabel(s.label)}</span></div>)}</div>
    <section className="lh-dashboard-section"><div className="lh-dashboard-section__head"><div><h2>{translateLabel("Thống kê tài chính")}</h2><p>{translateLabel("Doanh thu và cơ cấu tiền phạt trong tháng hiện tại.")}</p></div></div>
      <div className="lh-statistics-financial">
        <div className="lh-admin-table-wrap"><div className="lh-statistics-rankings__title">{translateLabel("Doanh thu theo nguồn")}</div><div className="lh-admin-table-scroll"><table className="lh-admin-table"><thead><tr><th>{translateLabel("Nguồn thu")}</th><th>{translateLabel("Số tiền")}</th><th>{translateLabel("Ghi chú")}</th></tr></thead><tbody>{revenueRows.map((row) => <tr key={row.source}><td>{translateLabel(row.source)}</td><td className="lh-statistics-money">{summary ? money(row.amount) : "…"}</td><td>{translateLabel(row.note)}</td></tr>)}<tr className="lh-statistics-total"><td>{translateLabel("Tổng doanh thu")}</td><td className="lh-statistics-money">{summary ? money(summary.totalRevenue) : "…"}</td><td>{translateLabel("Phí mượn và tiền phạt đã thu")}</td></tr></tbody></table></div></div>
        <div className="lh-admin-table-wrap"><div className="lh-statistics-rankings__title">Tiền phạt theo loại</div><div className="lh-admin-table-scroll"><table className="lh-admin-table"><thead><tr><th>Loại phạt</th><th>Số khoản</th><th>Đã thu</th><th>Chưa thu</th><th>Tổng phát sinh</th></tr></thead><tbody>{(summary?.fineBreakdown || []).map((row) => <tr key={row.fineType}><td>{row.fineType}</td><td>{row.fineCount}</td><td className="lh-statistics-money">{money(row.paidAmount)}</td><td className="lh-statistics-money">{money(row.unpaidAmount)}</td><td className="lh-statistics-money">{money(row.totalAmount)}</td></tr>)}{summary && !(summary.fineBreakdown || []).length && <tr><td colSpan="5" className="lh-admin-table__empty">Chưa phát sinh tiền phạt trong tháng.</td></tr>}{!summary && <tr><td colSpan="5" className="lh-admin-table__empty">Đang tải dữ liệu…</td></tr>}</tbody></table></div></div>
      </div>
    </section>
    <section className="lh-dashboard-section"><div className="lh-dashboard-section__head"><div><h2>{translateLabel("Mức độ đọc sách")}</h2><p>{translateLabel("Xếp theo tổng lượt mượn, bao gồm sách chưa từng được đọc.")}</p></div></div>
      <div className="lh-statistics-rankings">{[["Được đọc nhiều nhất", summary?.mostBorrowedBooks], ["Được đọc ít nhất", summary?.leastBorrowedBooks]].map(([title, rows]) => <div className="lh-admin-table-wrap" key={title}><div className="lh-statistics-rankings__title">{title}</div><table className="lh-admin-table"><thead><tr><th>Sách</th><th>Lượt mượn</th></tr></thead><tbody>{(rows || []).map((b) => <tr key={b.bookId}><td>{b.title}</td><td>{b.borrowCount}</td></tr>)}{summary && !(rows || []).length && <tr><td colSpan="2" className="lh-admin-table__empty">Chưa có dữ liệu.</td></tr>}</tbody></table></div>)}</div>
    </section>
  </div>;
}
