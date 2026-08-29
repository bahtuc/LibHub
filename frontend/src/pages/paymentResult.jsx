import { Link, useSearchParams } from "react-router-dom";
import Header from "../components/Header";
import Footer from "../components/Footer";
import { useLanguage } from "../i18n/LanguageContext";
import "../styles/Payments.css";

const VIEW = {
    success: { icon: "✓", tone: "green", titleKey: "payment.successTitle", descKey: "payment.successDescription" },
    failed: { icon: "✕", tone: "red", titleKey: "payment.failedTitle", descKey: "payment.failedDescription" },
    invalid: { icon: "!", tone: "amber", titleKey: "payment.invalidTitle", descKey: "payment.invalidDescription" },
};

export default function PaymentResult() {
    const [params] = useSearchParams();
    const { t, formatCurrency } = useLanguage();
    const status = params.get("status") || "failed";
    const view = VIEW[status] || VIEW.failed;
    const amount = params.get("amount");
    const code = params.get("code");
    const paymentType = params.get("paymentType") || "fine";
    const description = status === "success" && paymentType === "borrow"
        ? t("payment.borrowSuccess")
        : t(view.descKey);

    return (
      <div className="lh-root">
        <Header />
        <main className="lh-page" style={{ maxWidth: 560 }}>
            <div className="lh-card" style={{ padding: 32, textAlign: "center" }}>
                <div className={`pay_icon pay_icon--${view.tone}`}>{view.icon}</div>
                <h1 style={{ fontSize: 22, margin: "16px 0 8px" }}>{t(view.titleKey)}</h1>
                <p className="lh-muted" style={{ marginBottom: 20 }}>{description}</p>

                {status === "success" && amount && (
                    <p style={{ fontSize: 18, fontWeight: 700, marginBottom: 8 }}>{formatCurrency(Number(amount) / 100)}</p>
                )}
                {code && <p className="lh-muted lh-mono" style={{ fontSize: 12, marginBottom: 20 }}>{t("payment.responseCode", { code })}</p>}

                <div className="lh-row" style={{ justifyContent: "center", gap: 10 }}>
                    <Link to={paymentType === "borrow" ? "/account?tab=tickets" : "/account?tab=fines"} className="lh-btn lh-btn--primary">
                        {paymentType === "borrow" ? t("payment.viewLoan") : t("payment.account")}
                    </Link>
                    <Link to="/" className="lh-btn">{t("nav.home")}</Link>
                </div>
            </div>
        </main>
        <Footer />
      </div>
    );
}
