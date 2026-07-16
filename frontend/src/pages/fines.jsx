import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { getMyFines } from "../services/FineService";
import { createVnpayPayment } from "../services/PaymentService";
import { formatDate } from "../utils/format";
import "../styles/Payments.css";

function formatVnd(n) {
    const v = Number(n || 0);
    return v.toLocaleString("vi-VN") + " ₫";
}

function isPaid(fine) {
    return (fine?.paidStatus || "").toLowerCase() === "paid";
}

export default function Fines() {
    const [fines, setFines] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [payingId, setPayingId] = useState(null);

    async function load() {
        try {
            const data = await getMyFines();
            const list = Array.isArray(data) ? data : [];
            list.sort((a, b) => (b.fineId || 0) - (a.fineId || 0));
            setFines(list);
            setError("");
        } catch (err) {
            setError(err.message || "Không tải được danh sách phạt.");
        } finally {
            setLoading(false);
        }
    }

    useEffect(() => { load(); }, []);

    const unpaidTotal = useMemo(
        () => fines.filter((f) => !isPaid(f)).reduce((s, f) => s + Number(f.amount || 0), 0),
        [fines]
    );

    async function handlePay(fine) {
        setPayingId(fine.fineId);
        setError("");
        try {
            const { payUrl } = await createVnpayPayment(fine.fineId);
            if (!payUrl) throw new Error("Không tạo được liên kết thanh toán.");
            window.location.assign(payUrl);
        } catch (err) {
            setError(err.message || "Không khởi tạo được thanh toán VNPay.");
            setPayingId(null);
        }
    }

    return (
        <div className="lh-page">
            <div className="lh-page-head">
                <div>
                    <h1 className="lh-page-title">Khoản phạt của tôi</h1>
                    <p className="lh-page-sub">Thanh toán phí trả sách trễ qua VNPay.</p>
                </div>
                <Link to="/account" className="lh-btn">← Tài khoản</Link>
            </div>

            {unpaidTotal > 0 && (
                <div className="lh-alert lh-alert--info">
                    Tổng số tiền chưa thanh toán: <strong>{formatVnd(unpaidTotal)}</strong>
                </div>
            )}
            {error && <div className="lh-alert lh-alert--error">{error}</div>}

            {loading ? (
                <div className="lh-loading"><span className="lh-spinner" /> Đang tải…</div>
            ) : fines.length === 0 ? (
                <div className="lh-card lh-empty">
                    <p className="lh-empty-title">Bạn không có khoản phạt nào 🎉</p>
                    <p>Trả sách đúng hạn để tránh bị phạt.</p>
                </div>
            ) : (
                <div className="lh-table--wrap">
                    <table className="lh-table">
                        <thead>
                            <tr>
                                <th>Mã</th><th>Lý do</th><th>Số tiền</th><th>Ngày tạo</th><th>Trạng thái</th><th></th>
                            </tr>
                        </thead>
                        <tbody>
                            {fines.map((f) => {
                                const paid = isPaid(f);
                                return (
                                    <tr key={f.fineId}>
                                        <td className="lh-mono lh-muted">#{f.fineId}</td>
                                        <td>{f.reason || "Phí thư viện"}</td>
                                        <td className="lh-mono" style={{ fontWeight: 600 }}>{formatVnd(f.amount)}</td>
                                        <td className="lh-mono">{formatDate(f.createdAt)}</td>
                                        <td>
                                            {paid
                                                ? <span className="lh-badge lh-badge--green">Đã thanh toán</span>
                                                : <span className="lh-badge lh-badge--red">Chưa thanh toán</span>}
                                        </td>
                                        <td style={{ textAlign: "right" }}>
                                            {!paid && (
                                                <button
                                                    className="lh-btn lh-btn--primary lh-btn--sm"
                                                    disabled={payingId === f.fineId}
                                                    onClick={() => handlePay(f)}
                                                >
                                                    {payingId === f.fineId ? "Đang chuyển…" : "Thanh toán VNPay"}
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
