import { Link, useSearchParams } from "react-router-dom";
import "../styles/Payments.css";

function formatVnd(amountX100) {
    const v = Number(amountX100 || 0) / 100; // VNPay amounts are ×100
    return v.toLocaleString("vi-VN") + " ₫";
}

const VIEW = {
    success: { icon: "✓", tone: "green", title: "Thanh toán thành công", desc: "Khoản phạt của bạn đã được ghi nhận là đã thanh toán." },
    failed: { icon: "✕", tone: "red", title: "Thanh toán thất bại", desc: "Giao dịch chưa hoàn tất hoặc đã bị hủy. Bạn có thể thử lại." },
    invalid: { icon: "!", tone: "amber", title: "Không xác thực được giao dịch", desc: "Chữ ký VNPay không hợp lệ. Vui lòng thử lại hoặc liên hệ thủ thư." },
};

export default function PaymentResult() {
    const [params] = useSearchParams();
    const status = params.get("status") || "failed";
    const view = VIEW[status] || VIEW.failed;
    const amount = params.get("amount");
    const code = params.get("code");

    return (
        <div className="lh-page" style={{ maxWidth: 560 }}>
            <div className="lh-card" style={{ padding: 32, textAlign: "center" }}>
                <div className={`pay_icon pay_icon--${view.tone}`}>{view.icon}</div>
                <h1 style={{ fontSize: 22, margin: "16px 0 8px" }}>{view.title}</h1>
                <p className="lh-muted" style={{ marginBottom: 20 }}>{view.desc}</p>

                {status === "success" && amount && (
                    <p style={{ fontSize: 18, fontWeight: 700, marginBottom: 8 }}>{formatVnd(amount)}</p>
                )}
                {code && <p className="lh-muted lh-mono" style={{ fontSize: 12, marginBottom: 20 }}>Mã phản hồi VNPay: {code}</p>}

                <div className="lh-row" style={{ justifyContent: "center", gap: 10 }}>
                    <Link to="/account?tab=fines" className="lh-btn lh-btn--primary">Về tài khoản</Link>
                    <Link to="/" className="lh-btn">Trang chủ</Link>
                </div>
            </div>
        </div>
    );
}
