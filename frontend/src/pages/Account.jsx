// src/pages/Account.jsx
// Trang tài khoản cá nhân — có "thẻ thành viên" bên trái (ăn theo motif thẻ
// mượn sách ở trang Đăng nhập/Đăng ký) + nội dung tab bên phải.
import { useState } from "react";
import { Link } from "react-router-dom";
import Header from "../components/Header";
import Footer from "../components/Footer";
import Icon from "../components/Icon";
import Badge from "../admin/Badge";
import { useAuth } from "../auth/useAuth";
import { booksStore } from "../data/adminStore";
import { categories } from "../data/libraryData";
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

const ROLE_TONE = { Admin: "warning", User: "success", Librarian: "info" };

function formatDate(iso) {
  if (!iso) return "—";
  const [y, m, d] = iso.split("-");
  return `${d}/${m}/${y}`;
}

export default function Account() {
  const { user } = useAuth();
  const [tab, setTab] = useState("profile");

  const allTickets = useTickets();
  if (!user) {
    return <div className="lh-root"><Header /><section className="lh-section"><div className="lh-container lh-library-empty"><Icon name="user" size={28} /><h1 className="lh-h2">Guest account</h1><p>Browse books as a guest. Sign in to save loan history and manage your account.</p></div></section><Footer /></div>;
  }
  const myTickets = allTickets.filter((t) => t.user_id === user.user_id);
  const activeCount = myTickets.filter((t) => getTicketStatus(t) !== "returned").length;
  const unpaidFines = myTickets
    .flatMap((t) => t.items)
    .filter((it) => it.fine_amount > 0 && !it.fine_paid).length;

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
              {tab === "tickets" && <TicketsTab tickets={myTickets} />}
              {tab === "fines" && <FinesTab tickets={myTickets} />}
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

function TicketsTab({ tickets }) {
  const books = booksStore.useCollection();
  const sorted = [...tickets].sort((a, b) => b.ticket_id - a.ticket_id);

  function bookInfo(book_id) {
    const b = books.find((x) => x.book_id === book_id);
    return { title: b?.title ?? "—", category_id: b?.category_id };
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
              const s = TICKET_BADGE[getTicketStatus(t)];
              return (
                <tr key={t.ticket_id}>
                  <td>#{t.ticket_id}</td>
                  <td>
                    {t.items.map((it, idx) => {
                      const info = bookInfo(it.book_id);
                      const cat = categories.find((c) => c.category_id === info.category_id);
                      return (
                        <span className="lh-account__book-cell" key={idx}>
                          <span
                            className="lh-account__book-dot"
                            style={{ background: cat?.color ?? "var(--lh-gold)" }}
                          />
                          {info.title}
                        </span>
                      );
                    })}
                  </td>
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

function FinesTab({ tickets }) {
  const books = booksStore.useCollection();

  const myFines = tickets
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
    return (
      <div className="lh-account__empty">
        <Icon name="check-circle" size={26} />
        <p>Bạn không có khoản phạt nào.</p>
        <Link to="/fines" className="lh-btn lh-btn--primary">Kiểm tra khoản phạt trên hệ thống</Link>
      </div>
    );
  }

  const totalUnpaid = myFines.filter((f) => !f.fine_paid).reduce((s, f) => s + f.fine_amount, 0);

  return (
    <>
      {totalUnpaid > 0 && (
        <p className="lh-auth-form__error" style={{ marginBottom: 16 }}>
          Tổng còn nợ: <strong>{totalUnpaid.toLocaleString("vi-VN")}đ</strong>
          {" — "}<Link to="/fines" style={{ textDecoration: "underline", fontWeight: 700 }}>Thanh toán khoản phạt</Link>
        </p>
      )}
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
    </>
  );
}
