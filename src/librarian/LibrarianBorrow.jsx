// src/librarian/LibrarianBorrow.jsx
// Tạo phiếu mượn mới: chọn bạn đọc, chọn (các) bản sao còn sẵn, đặt hạn trả.
import { useMemo, useState } from "react";
import Icon from "../components/Icon";
import { usersStore, booksStore, copiesStore, getRoleLabel } from "../data/adminStore";
import { createTicket } from "../data/librarianStore";

function defaultDueDate() {
  const d = new Date();
  d.setDate(d.getDate() + 14);
  return d.toISOString().slice(0, 10);
}

export default function LibrarianBorrow() {
  const users = usersStore.useCollection();
  const books = booksStore.useCollection();
  const copies = copiesStore.useCollection();

  const [userId, setUserId] = useState(users[0]?.user_id ?? "");
  const [dueDate, setDueDate] = useState(defaultDueDate());
  const [bookId, setBookId] = useState("");
  const [selectedCopyIds, setSelectedCopyIds] = useState([]);
  const [note, setNote] = useState("");
  const [success, setSuccess] = useState(null);

  const availableCopiesForBook = useMemo(() => {
    if (!bookId) return [];
    return copies.filter((c) => c.book_id === Number(bookId) && c.status === "available");
  }, [bookId, copies]);

  const cart = selectedCopyIds
    .map((id) => copies.find((c) => c.copy_id === id))
    .filter(Boolean);

  function addCopy(copyId) {
    if (!copyId || selectedCopyIds.includes(Number(copyId))) return;
    setSelectedCopyIds((ids) => [...ids, Number(copyId)]);
  }
  function removeCopy(copyId) {
    setSelectedCopyIds((ids) => ids.filter((id) => id !== copyId));
  }

  function handleSubmit(e) {
    e.preventDefault();
    if (!userId || selectedCopyIds.length === 0) return;
    const ticket = createTicket({ user_id: userId, due_date: dueDate, copy_ids: selectedCopyIds, note });
    setSuccess(ticket.ticket_id);
    setSelectedCopyIds([]);
    setBookId("");
    setNote("");
    setDueDate(defaultDueDate());
  }

  function bookTitle(book_id) {
    return books.find((b) => b.book_id === book_id)?.title ?? "—";
  }

  return (
    <div className="lh-admin-page">
      <div className="lh-admin-page__head">
        <div>
          <h1 className="lh-admin-page__title">Mượn sách</h1>
          <p className="lh-admin-page__subtitle">Tạo phiếu mượn mới cho bạn đọc.</p>
        </div>
      </div>

      {success && (
        <p className="lh-auth-form__success" style={{ marginBottom: 18 }}>
          Đã tạo phiếu mượn #{success} thành công. Xem ở mục "Phiếu mượn".
        </p>
      )}

      <form className="lh-admin-form" onSubmit={handleSubmit}>
        <h2 className="lh-admin-form__heading">
          <Icon name="plus" size={18} /> Phiếu mượn mới
        </h2>

        <div className="lh-admin-form__grid">
          <label className="lh-field lh-admin-form__field">
            Bạn đọc
            <select value={userId} onChange={(e) => setUserId(e.target.value)} required>
              {users.map((u) => (
                <option key={u.user_id} value={u.user_id}>
                  {u.full_name} ({u.username}) — {getRoleLabel(u.role_id)}
                </option>
              ))}
            </select>
          </label>

          <label className="lh-field lh-admin-form__field">
            Hạn trả
            <input type="date" value={dueDate} onChange={(e) => setDueDate(e.target.value)} required />
          </label>

          <label className="lh-field lh-admin-form__field">
            Ghi chú (tùy chọn)
            <input type="text" value={note} onChange={(e) => setNote(e.target.value)} placeholder="—" />
          </label>
        </div>

        <div className="lh-admin-form__grid" style={{ marginTop: -4 }}>
          <label className="lh-field lh-admin-form__field">
            Chọn sách
            <select
              value={bookId}
              onChange={(e) => {
                setBookId(e.target.value);
              }}
            >
              <option value="">— Chọn 1 đầu sách —</option>
              {books.map((b) => (
                <option key={b.book_id} value={b.book_id}>
                  {b.title}
                </option>
              ))}
            </select>
          </label>

          <label className="lh-field lh-admin-form__field">
            Bản sao còn sẵn
            <select value="" onChange={(e) => addCopy(e.target.value)} disabled={!bookId}>
              <option value="">
                {bookId
                  ? availableCopiesForBook.length
                    ? "— Chọn bản để thêm vào phiếu —"
                    : "Sách này hết bản còn sẵn"
                  : "Chọn sách trước"}
              </option>
              {availableCopiesForBook.map((c) => (
                <option key={c.copy_id} value={c.copy_id}>
                  {c.barcode} · {c.shelf_location}
                </option>
              ))}
            </select>
          </label>
        </div>

        {cart.length > 0 && (
          <div className="lh-admin-table-wrap" style={{ marginBottom: 20 }}>
            <table className="lh-admin-table">
              <thead>
                <tr>
                  <th>Sách</th>
                  <th>Mã vạch</th>
                  <th>Vị trí kệ</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {cart.map((c) => (
                  <tr key={c.copy_id}>
                    <td>{bookTitle(c.book_id)}</td>
                    <td>{c.barcode}</td>
                    <td>{c.shelf_location}</td>
                    <td className="lh-admin-table__actions">
                      <button
                        type="button"
                        className="lh-admin-icon-btn lh-admin-icon-btn--danger"
                        aria-label="Bỏ khỏi phiếu"
                        onClick={() => removeCopy(c.copy_id)}
                      >
                        <Icon name="x" size={14} />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        <div className="lh-admin-form__actions">
          <button type="submit" className="lh-btn lh-btn--primary" disabled={cart.length === 0}>
            Tạo phiếu mượn ({cart.length} cuốn)
          </button>
        </div>
      </form>
    </div>
  );
}
