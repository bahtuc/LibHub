import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { getMyBorrowHistory } from "../services/BorrowTicketService";
import { isReturned, loanTitle, returnLoan } from "../utils/loans";
import { formatDate, daysUntil } from "../utils/format";

const TABS = [
    { key: "active", label: "Đang mượn" },
    { key: "returned", label: "Đã trả" },
    { key: "all", label: "Tất cả" },
];

export default function Loans() {
    const [tickets, setTickets] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [notice, setNotice] = useState("");
    const [tab, setTab] = useState("active");
    const [busyId, setBusyId] = useState(null);

    async function load() {
        try {
            const data = await getMyBorrowHistory();
            const list = Array.isArray(data) ? data : [];
            list.sort((a, b) => (b.ticketId || 0) - (a.ticketId || 0));
            setTickets(list);
            setError("");
        } catch (err) {
            setError(err.message || "Không tải được phiếu mượn.");
        } finally {
            setLoading(false);
        }
    }

    useEffect(() => { load(); }, []);

    const filtered = useMemo(() => {
        if (tab === "active") return tickets.filter((t) => !isReturned(t));
        if (tab === "returned") return tickets.filter(isReturned);
        return tickets;
    }, [tickets, tab]);

    async function handleReturn(ticket) {
        setBusyId(ticket.ticketId);
        setNotice("");
        setError("");
        try {
            const { fine } = await returnLoan(ticket);
            if (fine) {
                const amt = Number(fine.amount || 0).toLocaleString("vi-VN");
                setNotice(`Đã trả "${loanTitle(ticket)}". Trả trễ — phát sinh phí ${amt} ₫. Xem ở mục Khoản phạt.`);
            } else {
                setNotice(`Đã trả "${loanTitle(ticket)}".`);
            }
            await load();
        } catch (err) {
            setError(err.message || "Trả sách thất bại.");
        } finally {
            setBusyId(null);
        }
    }

    return (
        <div className="lh-page">
            <div className="lh-page-head">
                <div>
                    <h1 className="lh-page-title">Phiếu mượn của tôi</h1>
                    <p className="lh-page-sub">Theo dõi sách đang mượn, hạn trả và lịch sử mượn.</p>
                </div>
                <Link to="/catalog" className="lh-btn lh-btn--primary">+ Mượn thêm sách</Link>
            </div>

            <div className="lh-row" style={{ gap: 6, marginBottom: 18 }}>
                {TABS.map((t) => (
                    <button
                        key={t.key}
                        className={`lh-btn lh-btn--sm ${tab === t.key ? "lh-btn--primary" : ""}`}
                        onClick={() => setTab(t.key)}
                    >
                        {t.label}
                    </button>
                ))}
            </div>

            {notice && <div className="lh-alert lh-alert--success">{notice}</div>}
            {error && <div className="lh-alert lh-alert--error">{error}</div>}

            {loading ? (
                <div className="lh-loading"><span className="lh-spinner" /> Đang tải…</div>
            ) : filtered.length === 0 ? (
                <div className="lh-card lh-empty">
                    <p className="lh-empty-title">Không có phiếu mượn</p>
                    <p>{tab === "active" ? "Bạn không có sách nào đang mượn." : "Chưa có dữ liệu."}</p>
                </div>
            ) : (
                <div className="lh-table--wrap">
                    <table className="lh-table">
                        <thead>
                            <tr>
                                <th>Mã</th><th>Sách</th><th>Ngày mượn</th><th>Hạn trả</th><th>Tình trạng</th><th></th>
                            </tr>
                        </thead>
                        <tbody>
                            {filtered.map((t) => {
                                const returned = isReturned(t);
                                const d = daysUntil(t.dueDate);
                                const overdue = !returned && d !== null && d < 0;
                                return (
                                    <tr key={t.ticketId}>
                                        <td className="lh-mono lh-muted">#{t.ticketId}</td>
                                        <td style={{ fontWeight: 600 }}>{loanTitle(t)}</td>
                                        <td className="lh-mono">{formatDate(t.borrowDate)}</td>
                                        <td className="lh-mono">{formatDate(t.dueDate)}</td>
                                        <td>
                                            {returned ? (
                                                <span className="lh-badge lh-badge--slate">Đã trả</span>
                                            ) : overdue ? (
                                                <span className="lh-badge lh-badge--red">Quá hạn {Math.abs(d)} ngày</span>
                                            ) : (
                                                <span className="lh-badge lh-badge--green">Còn {d} ngày</span>
                                            )}
                                        </td>
                                        <td style={{ textAlign: "right" }}>
                                            {!returned && (
                                                <button className="lh-btn lh-btn--sm" disabled={busyId === t.ticketId} onClick={() => handleReturn(t)}>
                                                    {busyId === t.ticketId ? "Đang trả…" : "Trả sách"}
                                                </button>
                                            )}
                                        </td>
                                    </tr>
                                );
                            })}
                        </tbody>
                    </table>
                </div>
            )}
        </div>
    );
}
