// src/pages/Account.jsx
// Trang tài khoản cá nhân — có "thẻ thành viên" bên trái (ăn theo motif thẻ
// mượn sách ở trang Đăng nhập/Đăng ký) + nội dung tab bên phải.
import { useEffect, useState } from "react";
import { useSearchParams } from "react-router-dom";
import Header from "../components/Header";
import Footer from "../components/Footer";
import Icon from "../components/Icon";
import Badge from "../admin/Badge";
import { useAuth } from "../auth/useAuth";
import { getTicketStatus } from "../utils/loanViews";
import { formatDate } from "../utils/format";
import { getMyDetailedBorrowHistory } from "../services/BorrowTicketService";
import { getMyFines } from "../services/FineService";
import { createVnpayPayment } from "../services/PaymentService";
import "../styles/theme.css";
import "../styles/Library.css";
import "../styles/AuthForm.css";
import "../styles/Account.css";

const TABS = [
  { id: "profile", label: "Hồ sơ", icon: "user" },
  { id: "password", label: "Đổi mật khẩu", icon: "lock" },
  { id: "tickets", label: "Phiếu mượn", icon: "layers" },
  { id: "fines", label: "Phạt", icon: "landmark" },
];

const TICKET_BADGE = {
  borrowing: { tone: "success", text: "Đang mượn" },
  overdue: { tone: "danger", text: "Quá hạn" },
  returned: { tone: "neutral", text: "Đã trả" },
  cancelled: { tone: "neutral", text: "Đã hủy" },
  payment_pending: { tone: "warning", text: "Chờ thanh toán VNPay" },
};

const ROLE_TONE = { Admin: "warning", User: "success", Librarian: "info" };

export default function Account() {
  const { user } = useAuth();
  const [searchParams] = useSearchParams();
  const requestedTab = searchParams.get("tab");
  const [tab, setTab] = useState(
    TABS.some((item) => item.id === requestedTab) ? requestedTab : "profile",
  );
  const [fines, setFines] = useState([]);
  const [finesLoading, setFinesLoading] = useState(true);
  const [finesError, setFinesError] = useState("");
  const [tickets, setTickets] = useState([]);
  const [ticketsLoading, setTicketsLoading] = useState(true);
  const [ticketsError, setTicketsError] = useState("");

  useEffect(() => {
    if (!user) {
      setFines([]);
      setFinesLoading(false);
      setTickets([]);
      setTicketsLoading(false);
      return;
    }

    let active = true;
    setFinesLoading(true);
    setTicketsLoading(true);
    getMyFines()
      .then((data) => {
        if (active) {
          setFines(Array.isArray(data) ? data : []);
          setFinesError("");
        }
      })
      .catch((error) => {
        if (active) setFinesError(error.message || "Không tải được khoản phạt.");
      })
      .finally(() => {
        if (active) setFinesLoading(false);
      });

    getMyDetailedBorrowHistory()
      .then((data) => {
        if (active) {
          setTickets(Array.isArray(data) ? data : []);
          setTicketsError("");
        }
      })
      .catch((error) => {
        if (active) setTicketsError(error.message || "Không tải được lịch sử mượn sách.");
      })
      .finally(() => {
        if (active) setTicketsLoading(false);
      });

    return () => {
      active = false;
    };
  }, [user?.user_id]);

  if (!user) {
    return <div className="lh-root"><Header /><section className="lh-section"><div className="lh-container lh-library-empty"><Icon name="user" size={28} /><h1 className="lh-h2">Guest account</h1><p>Browse books as a guest. Sign in to save loan history and manage your account.</p></div></section><Footer /></div>;
  }
  const activeCount = tickets.filter(
    (ticket) => !["returned", "cancelled"].includes(getTicketStatus(ticket)),
  ).length;
  const unpaidFines = fines.filter(
    (fine) => String(fine.paidStatus).toLowerCase() !== "paid",
  ).length;

  return (
    <div className="lh-root">
      <Header />

      <section className="lh-library-hero">
        <div className="lh-container">
          <p className="lh-eyebrow">Tài khoản</p>
          <h1 className="lh-h1" style={{ fontSize: "clamp(2rem, 3.4vw, 2.8rem)" }}>
            Xin chào, {user.full_name}
          </h1>
          <p className="lh-lede">Quản lý thông tin cá nhân, mật khẩu và lịch sử mượn sách.</p>
        </div>
      </section>

      <section className="lh-section" style={{ paddingTop: 28 }}>
        <div className="lh-container lh-account">
          {/* --- Thẻ thành viên --- */}
          <aside className="lh-member-card">
            <div className="lh-member-card__tab">
              <Icon name="book-open" size={18} />
            </div>
            <div className="lh-member-card__perforation" aria-hidden="true" />

            <div className="lh-member-card__avatar">{user.full_name?.charAt(0)}</div>
            <h2 className="lh-member-card__name">{user.full_name}</h2>
            <Badge tone={ROLE_TONE[user.role_name] ?? "neutral"}>{user.role_name}</Badge>

            <dl className="lh-member-card__meta">
              <div>
                <dt>Tên đăng nhập</dt>
                <dd>{user.username}</dd>
              </div>
              <div>
                <dt>Thành viên từ</dt>
                <dd>{formatDate(user.member_since)}</dd>
              </div>
            </dl>

            <div className="lh-member-card__stats">
              <div>
                <span className="lh-member-card__stat-value">{activeCount}</span>
                <span className="lh-member-card__stat-label">Đang mượn</span>
              </div>
              <div>
                <span className="lh-member-card__stat-value">{unpaidFines}</span>
                <span className="lh-member-card__stat-label">Phạt chưa thu</span>
              </div>
            </div>
          </aside>

          {/* --- Tabs + nội dung --- */}
          <div className="lh-account__main">
            <div className="lh-account__tabs">
              {TABS.map((t) => (
                <button
                  key={t.id}
                  className={`lh-account__tab ${tab === t.id ? "is-active" : ""}`}
                  onClick={() => setTab(t.id)}
                >
                  <span className="lh-account__tab-icon">
                    <Icon name={t.icon} size={15} />
                  </span>
                  {t.label}
                </button>
              ))}
            </div>

            <div className="lh-account__panel">
              {tab === "profile" && <ProfileTab />}
              {tab === "password" && <PasswordTab />}
              {tab === "tickets" && (
                <TicketsTab
                  tickets={tickets}
                  loading={ticketsLoading}
                  loadError={ticketsError}
                />
              )}
              {tab === "fines" && (
                <FinesTab
                  fines={fines}
                  loading={finesLoading}
                  loadError={finesError}
                />
              )}
            </div>
          </div>
        </div>
      </section>

      <Footer />
    </div>
  );
}

function ProfileTab() {
  const { user, updateProfile } = useAuth();
  const [form, setForm] = useState({
    full_name: user.full_name || "",
    email: user.email || "",
    phone: user.phone || "",
    address: user.address || "",
  });
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState("");

  function update(field) {
    return (e) => {
      setSuccess(false);
      setError("");
      setForm((f) => ({ ...f, [field]: e.target.value }));
    };
  }

  async function handleSubmit(e) {
    e.preventDefault();
    const result = await updateProfile(form);
    if (!result?.ok) {
      setError(result?.message || "Không thể cập nhật hồ sơ.");
      return;
    }
    setSuccess(true);
  }

  return (
    <form className="lh-account__form" onSubmit={handleSubmit}>
      <div className="lh-auth-form__row">
        <label className="lh-field">
          Họ và tên
          <span className="lh-field__control">
            <Icon name="user" size={16} className="lh-field__icon" />
            <input type="text" value={form.full_name} onChange={update("full_name")} required />
          </span>
        </label>
        <label className="lh-field">
          Tên đăng nhập
          <span className="lh-field__control">
            <Icon name="lock" size={16} className="lh-field__icon" />
            <input type="text" value={user.username} disabled />
          </span>
        </label>
      </div>

      <div className="lh-auth-form__row">
        <label className="lh-field">
          Email
          <span className="lh-field__control">
            <Icon name="mail" size={16} className="lh-field__icon" />
            <input type="email" value={form.email} onChange={update("email")} placeholder="ban@email.com" />
          </span>
        </label>
        <label className="lh-field">
          Số điện thoại
          <span className="lh-field__control">
            <Icon name="phone" size={16} className="lh-field__icon" />
            <input type="tel" value={form.phone} onChange={update("phone")} placeholder="09xxxxxxxx" />
          </span>
        </label>
      </div>

      <label className="lh-field">
        Địa chỉ
        <span className="lh-field__control">
          <Icon name="map-pin" size={16} className="lh-field__icon" />
          <input type="text" value={form.address} onChange={update("address")} placeholder="—" />
        </span>
      </label>

      {error && <p className="lh-auth-form__error">{error}</p>}
      {success && <p className="lh-auth-form__success">Đã lưu thông tin.</p>}

      <button type="submit" className="lh-btn lh-btn--primary" style={{ alignSelf: "flex-start" }}>
        Lưu thay đổi
      </button>
    </form>
  );
}

function PasswordTab() {
  const { changePassword } = useAuth();
  const [form, setForm] = useState({ current: "", next: "", confirm: "" });
  const [error, setError] = useState("");
  const [success, setSuccess] = useState(false);

  function update(field) {
    return (e) => {
      setError("");
      setSuccess(false);
      setForm((f) => ({ ...f, [field]: e.target.value }));
    };
  }

  async function handleSubmit(e) {
    e.preventDefault();
    if (form.next !== form.confirm) {
      setError("Mật khẩu mới nhập lại không khớp.");
      return;
    }
    try {
      await changePassword(form.current, form.next);
      setForm({ current: "", next: "", confirm: "" });
      setSuccess(true);
    } catch (err) {
      setError(err.message || "Không thể đổi mật khẩu.");
    }
  }

  return (
    <form className="lh-account__form" onSubmit={handleSubmit}>
      <label className="lh-field">
        Mật khẩu hiện tại
        <span className="lh-field__control">
          <Icon name="lock" size={16} className="lh-field__icon" />
          <input type="password" value={form.current} onChange={update("current")} required />
        </span>
      </label>
      <div className="lh-auth-form__row">
        <label className="lh-field">
          Mật khẩu mới
          <span className="lh-field__control">
            <Icon name="lock" size={16} className="lh-field__icon" />
            <input type="password" value={form.next} onChange={update("next")} required />
          </span>
        </label>
        <label className="lh-field">
          Nhập lại mật khẩu mới
          <span className="lh-field__control">
            <Icon name="lock" size={16} className="lh-field__icon" />
            <input type="password" value={form.confirm} onChange={update("confirm")} required />
          </span>
        </label>
      </div>

      {error && <p className="lh-auth-form__error">{error}</p>}
      {success && <p className="lh-auth-form__success">Đổi mật khẩu thành công.</p>}

      <button type="submit" className="lh-btn lh-btn--primary" style={{ alignSelf: "flex-start" }}>
        Đổi mật khẩu
      </button>
    </form>
  );
}

function TicketsTab({ tickets, loading, loadError }) {
  const sorted = [...tickets].sort((a, b) => Number(b.ticketId) - Number(a.ticketId));

  if (loading) {
    return (
      <div className="lh-account__empty">
        <span className="lh-spinner" />
        <p>Đang tải lịch sử mượn sách...</p>
      </div>
    );
  }

  if (loadError) {
    return <p className="lh-auth-form__error">{loadError}</p>;
  }

  if (sorted.length === 0) {
    return (
      <div className="lh-account__empty">
        <Icon name="layers" size={26} />
        <p>Bạn chưa mượn cuốn sách nào.</p>
      </div>
    );
  }

  return (
    <div className="lh-admin-table-wrap">
      <div className="lh-admin-table-scroll">
        <table className="lh-admin-table">
          <thead>
            <tr>
              <th>Mã phiếu</th>
              <th>Sách</th>
              <th>Ngày mượn</th>
              <th>Hạn trả</th>
              <th>Trạng thái</th>
            </tr>
          </thead>
          <tbody>
            {sorted.map((t) => {
              const s = TICKET_BADGE[getTicketStatus(t)] ?? TICKET_BADGE.borrowing;
              return (
                <tr key={t.ticketId}>
                  <td>#{t.ticketId}</td>
                  <td>
                    {(t.items ?? []).map((item) => (
                      <span
                        className="lh-account__book-cell"
                        key={item.detailId ?? item.copyId}
                      >
                        <span
                          className="lh-account__book-dot"
                          style={{ background: "var(--lh-gold)" }}
                        />
                        {item.bookTitle || "—"}
                      </span>
                    ))}
                  </td>
                  <td>{formatDate(t.borrowDate)}</td>
                  <td>{formatDate(t.dueDate)}</td>
                  <td>
                    <Badge tone={s.tone}>{s.text}</Badge>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function FinesTab({ fines, loading, loadError }) {
  const [payingId, setPayingId] = useState(null);
  const [paymentError, setPaymentError] = useState("");
  const sorted = [...fines].sort((a, b) => (b.fineId || 0) - (a.fineId || 0));

  function paid(fine) {
    return String(fine.paidStatus).toLowerCase() === "paid";
  }

  async function pay(fine) {
    setPayingId(fine.fineId);
    setPaymentError("");
    try {
      const result = await createVnpayPayment(fine.fineId);
      if (!result?.payUrl) throw new Error("Không tạo được liên kết thanh toán.");
      window.location.assign(result.payUrl);
    } catch (error) {
      setPaymentError(error.message || "Không thể khởi tạo thanh toán VNPay.");
      setPayingId(null);
    }
  }

  if (loading) {
    return (
      <div className="lh-account__empty">
        <span className="lh-spinner" />
        <p>Đang tải khoản phạt...</p>
      </div>
    );
  }

  if (loadError) {
    return <p className="lh-auth-form__error">{loadError}</p>;
  }

  if (sorted.length === 0) {
    return (
      <div className="lh-account__empty">
        <Icon name="check-circle" size={26} />
        <p>Bạn không có khoản phạt nào.</p>
      </div>
    );
  }

  const totalUnpaid = sorted
    .filter((fine) => !paid(fine))
    .reduce((total, fine) => total + Number(fine.amount || 0), 0);

  return (
    <>
      {totalUnpaid > 0 && (
        <p className="lh-auth-form__error" style={{ marginBottom: 16 }}>
          Tổng còn nợ: <strong>{totalUnpaid.toLocaleString("vi-VN")}đ</strong>
        </p>
      )}
      {paymentError && <p className="lh-auth-form__error">{paymentError}</p>}
      <div className="lh-admin-table-wrap">
        <div className="lh-admin-table-scroll">
          <table className="lh-admin-table">
            <thead>
              <tr>
                <th>Mã phạt</th>
                <th>Lý do</th>
                <th>Ngày tạo</th>
                <th>Số tiền</th>
                <th>Trạng thái</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {sorted.map((fine) => {
                const isPaid = paid(fine);
                return (
                  <tr key={fine.fineId}>
                    <td>#{fine.fineId}</td>
                    <td>{fine.reason || "Phí thư viện"}</td>
                    <td>{fine.createdAt ? String(fine.createdAt).slice(0, 10) : "—"}</td>
                    <td>{Number(fine.amount || 0).toLocaleString("vi-VN")}đ</td>
                    <td>
                      <Badge tone={isPaid ? "success" : "danger"}>
                        {isPaid ? "Đã thanh toán" : "Chưa thanh toán"}
                      </Badge>
                    </td>
                    <td>
                      {!isPaid && (
                        <button
                          type="button"
                          className="lh-btn lh-btn--primary"
                          disabled={payingId === fine.fineId}
                          onClick={() => pay(fine)}
                        >
                          {payingId === fine.fineId ? "Đang chuyển..." : "Thanh toán"}
                        </button>
                      )}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    </>
  );
}
