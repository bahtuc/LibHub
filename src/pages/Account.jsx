// src/pages/Account.jsx
// Trang tài khoản cá nhân: sửa hồ sơ, đổi mật khẩu, xem phiếu mượn + phạt của
// chính người dùng đang đăng nhập (không phân biệt role — Admin/Librarian/User
// đều có trang này).
import { useState } from "react";
import Header from "../components/Header";
import Footer from "../components/Footer";
import Icon from "../components/Icon";
import Badge from "../admin/Badge";
import { useAuth } from "../auth/useAuth";
import { booksStore } from "../data/adminStore";
import { useTickets, getTicketStatus } from "../data/librarianStore";
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
};

export default function Account() {
  const { user } = useAuth();
  const [tab, setTab] = useState("profile");

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
        <div className="lh-container">
          <div className="lh-account__tabs">
            {TABS.map((t) => (
              <button
                key={t.id}
                className={`lh-account__tab ${tab === t.id ? "is-active" : ""}`}
                onClick={() => setTab(t.id)}
              >
                <Icon name={t.icon} size={16} />
                {t.label}
              </button>
            ))}
          </div>

          <div className="lh-account__panel">
            {tab === "profile" && <ProfileTab />}
            {tab === "password" && <PasswordTab />}
            {tab === "tickets" && <TicketsTab userId={user.user_id} />}
            {tab === "fines" && <FinesTab userId={user.user_id} />}
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

  function update(field) {
    return (e) => {
      setSuccess(false);
      setForm((f) => ({ ...f, [field]: e.target.value }));
    };
  }

  function handleSubmit(e) {
    e.preventDefault();
    updateProfile(form);
    setSuccess(true);
    setTimeout(() => setSuccess(false), 3000);
  }

  return (
    <form className="lh-account__form" onSubmit={handleSubmit}>
      <div className="lh-auth-form__row">
        <label className="lh-field">
          Họ và tên
          <input type="text" value={form.full_name} onChange={update("full_name")} required />
        </label>
        <label className="lh-field">
          Tên đăng nhập
          <input type="text" value={user.username} disabled />
        </label>
      </div>

      <div className="lh-auth-form__row">
        <label className="lh-field">
          Email
          <input type="email" value={form.email} onChange={update("email")} placeholder="ban@email.com" />
        </label>
        <label className="lh-field">
          Số điện thoại
          <input type="tel" value={form.phone} onChange={update("phone")} placeholder="09xxxxxxxx" />
        </label>
      </div>

      <label className="lh-field">
        Địa chỉ
        <input type="text" value={form.address} onChange={update("address")} placeholder="—" />
      </label>

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

  function handleSubmit(e) {
    e.preventDefault();
    if (form.next !== form.confirm) {
      setError("Mật khẩu mới nhập lại không khớp.");
      return;
    }
    const result = changePassword(form.current, form.next);
    if (!result.ok) {
      setError(result.message);
      return;
    }
    setForm({ current: "", next: "", confirm: "" });
    setSuccess(true);
    setTimeout(() => setSuccess(false), 3000);
  }

  return (
    <form className="lh-account__form" onSubmit={handleSubmit}>
      <label className="lh-field">
        Mật khẩu hiện tại
        <input type="password" value={form.current} onChange={update("current")} required />
      </label>
      <div className="lh-auth-form__row">
        <label className="lh-field">
          Mật khẩu mới
          <input type="password" value={form.next} onChange={update("next")} required />
        </label>
        <label className="lh-field">
          Nhập lại mật khẩu mới
          <input type="password" value={form.confirm} onChange={update("confirm")} required />
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

function TicketsTab({ userId }) {
  const allTickets = useTickets();
  const books = booksStore.useCollection();
  const myTickets = allTickets
    .filter((t) => t.user_id === userId)
    .sort((a, b) => b.ticket_id - a.ticket_id);

  function bookTitle(book_id) {
    return books.find((b) => b.book_id === book_id)?.title ?? "—";
  }

  if (myTickets.length === 0) {
    return <p style={{ color: "var(--lh-text-muted)" }}>Bạn chưa mượn cuốn sách nào.</p>;
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
            {myTickets.map((t) => {
              const s = TICKET_BADGE[getTicketStatus(t)];
              return (
                <tr key={t.ticket_id}>
                  <td>#{t.ticket_id}</td>
                  <td>{t.items.map((it) => bookTitle(it.book_id)).join(", ")}</td>
                  <td>{t.borrow_date}</td>
                  <td>{t.due_date}</td>
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

function FinesTab({ userId }) {
  const allTickets = useTickets();
  const books = booksStore.useCollection();

  const myFines = allTickets
    .filter((t) => t.user_id === userId)
    .flatMap((t) =>
      t.items
        .filter((it) => it.fine_amount > 0)
        .map((it) => ({ ...it, ticket_id: t.ticket_id }))
    )
    .sort((a, b) => b.ticket_id - a.ticket_id);

  function bookTitle(book_id) {
    return books.find((b) => b.book_id === book_id)?.title ?? "—";
  }
  function reasonLabel(condition_book) {
    if (condition_book === "mat") return "Làm mất sách";
    if (condition_book === "hu_hong") return "Trả sách hư hỏng";
    return "Trả trễ hạn";
  }

  if (myFines.length === 0) {
    return <p style={{ color: "var(--lh-text-muted)" }}>Bạn không có khoản phạt nào. 🎉</p>;
  }

  return (
    <div className="lh-admin-table-wrap">
      <div className="lh-admin-table-scroll">
        <table className="lh-admin-table">
          <thead>
            <tr>
              <th>Phiếu</th>
              <th>Sách</th>
              <th>Lý do</th>
              <th>Số tiền</th>
              <th>Trạng thái</th>
            </tr>
          </thead>
          <tbody>
            {myFines.map((f) => (
              <tr key={`${f.ticket_id}-${f.copy_id}`}>
                <td>#{f.ticket_id}</td>
                <td>{bookTitle(f.book_id)}</td>
                <td>{reasonLabel(f.condition_book)}</td>
                <td>{f.fine_amount.toLocaleString("vi-VN")}đ</td>
                <td>
                  {f.fine_paid ? (
                    <Badge tone="success">Đã thu</Badge>
                  ) : (
                    <Badge tone="danger">Chưa thu</Badge>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
