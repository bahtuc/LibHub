import { useEffect, useMemo, useState } from "react";
import Icon from "../components/Icon";
import { booksStore, copiesStore } from "../data/adminStore";
import { createBorrowTicket } from "../services/BorrowTicketService";
import { getBorrowers } from "../services/UserService";

function defaultDueDate() {
  const date = new Date();
  date.setDate(date.getDate() + 14);
  return date.toISOString().slice(0, 10);
}

export default function LibrarianBorrow() {
  const books = booksStore.useCollection();
  const copies = copiesStore.useCollection();
  const [borrowers, setBorrowers] = useState([]);
  const [borrowerType, setBorrowerType] = useState("member");
  const [userId, setUserId] = useState("");
  const [guestName, setGuestName] = useState("");
  const [guestPhone, setGuestPhone] = useState("");
  const [dueDate, setDueDate] = useState(defaultDueDate());
  const [bookId, setBookId] = useState("");
  const [selectedCopyIds, setSelectedCopyIds] = useState([]);
  const [note, setNote] = useState("");
  const [success, setSuccess] = useState(null);
  const [error, setError] = useState("");
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    let active = true;
    getBorrowers()
      .then((data) => {
        if (!active) return;
        const next = Array.isArray(data) ? data : [];
        setBorrowers(next);
        setUserId((current) => current || String(next[0]?.userId ?? ""));
        setError("");
      })
      .catch((requestError) => {
        if (active) setError(requestError.message || "Không tải được danh sách bạn đọc.");
      });
    return () => {
      active = false;
    };
  }, []);

  const visibleBooks = useMemo(
    () => books.filter((book) => !book.is_hidden),
    [books],
  );

  const availableCopiesForBook = useMemo(() => {
    if (!bookId) return [];
    return copies.filter(
      (copy) =>
        copy.book_id === Number(bookId) &&
        copy.status === "available" &&
        !selectedCopyIds.includes(copy.copy_id),
    );
  }, [bookId, copies, selectedCopyIds]);

  const cart = selectedCopyIds
    .map((id) => copies.find((copy) => copy.copy_id === id))
    .filter(Boolean);

  function addCopy(copyId) {
    const numericId = Number(copyId);
    if (!numericId || selectedCopyIds.includes(numericId)) return;
    setSelectedCopyIds((ids) => [...ids, numericId]);
  }

  function removeCopy(copyId) {
    setSelectedCopyIds((ids) => ids.filter((id) => id !== copyId));
  }

  async function handleSubmit(event) {
    event.preventDefault();
    const isGuest = borrowerType === "guest";
    if ((!isGuest && !userId) || (isGuest && !guestName.trim()) || selectedCopyIds.length === 0) return;
    setSubmitting(true);
    setError("");
    setSuccess(null);
    try {
      const ticket = await createBorrowTicket({
        userId: isGuest ? null : Number(userId),
        guestName: isGuest ? guestName.trim() : null,
        guestPhone: isGuest ? guestPhone.trim() || null : null,
        borrowDate: new Date().toISOString().slice(0, 10),
        dueDate,
        copyIds: selectedCopyIds,
        note: note.trim() || null,
      });
      setSuccess(ticket.ticketId);
      setSelectedCopyIds([]);
      setBookId("");
      setNote("");
      setGuestName("");
      setGuestPhone("");
      setDueDate(defaultDueDate());
      await copiesStore.refresh();
    } catch (requestError) {
      setError(requestError.message || "Không thể tạo phiếu mượn.");
    } finally {
      setSubmitting(false);
    }
  }

  function bookTitle(id) {
    return books.find((book) => book.book_id === id)?.title ?? "—";
  }

  return (
    <div className="lh-admin-page">
      <div className="lh-admin-page__head">
        <div>
          <h1 className="lh-admin-page__title">Mượn sách</h1>
          <p className="lh-admin-page__subtitle">Tạo phiếu mượn mới và lưu trực tiếp vào hệ thống.</p>
        </div>
      </div>

      {success && (
        <p className="lh-auth-form__success" style={{ marginBottom: 18 }}>
          Đã tạo phiếu mượn #{success} thành công.
        </p>
      )}
      {error && <p className="lh-auth-form__error">{error}</p>}

      <form className="lh-admin-form" onSubmit={handleSubmit}>
        <h2 className="lh-admin-form__heading">
          <Icon name="plus" size={18} /> Phiếu mượn mới
        </h2>

        <div className="lh-admin-form__grid">
          <label className="lh-field lh-admin-form__field">
            Loại bạn đọc
            <select value={borrowerType} onChange={(event) => setBorrowerType(event.target.value)}>
              <option value="member">Thành viên</option>
              <option value="guest">Khách vãng lai</option>
            </select>
          </label>

          {borrowerType === "member" ? (
          <label className="lh-field lh-admin-form__field">
            Bạn đọc
            <select value={userId} onChange={(event) => setUserId(event.target.value)} required>
              {borrowers.length === 0 && <option value="">— Chưa có bạn đọc đang hoạt động —</option>}
              {borrowers.map((borrower) => (
                <option key={borrower.userId} value={borrower.userId}>
                  {borrower.fullName || borrower.username} ({borrower.username})
                </option>
              ))}
            </select>
          </label>
          ) : (
            <>
              <label className="lh-field lh-admin-form__field">
                Tên khách
                <input
                  type="text"
                  value={guestName}
                  onChange={(event) => setGuestName(event.target.value)}
                  required
                />
              </label>
              <label className="lh-field lh-admin-form__field">
                Số điện thoại khách
                <input
                  type="tel"
                  value={guestPhone}
                  onChange={(event) => setGuestPhone(event.target.value)}
                  placeholder="Tùy chọn"
                />
              </label>
            </>
          )}

          <label className="lh-field lh-admin-form__field">
            Hạn trả
            <input
              type="date"
              min={new Date().toISOString().slice(0, 10)}
              value={dueDate}
              onChange={(event) => setDueDate(event.target.value)}
              required
            />
          </label>

          <label className="lh-field lh-admin-form__field">
            Ghi chú (tùy chọn)
            <input type="text" value={note} onChange={(event) => setNote(event.target.value)} placeholder="—" />
          </label>
        </div>

        <div className="lh-admin-form__grid" style={{ marginTop: -4 }}>
          <label className="lh-field lh-admin-form__field">
            Chọn sách
            <select value={bookId} onChange={(event) => setBookId(event.target.value)}>
              <option value="">— Chọn một đầu sách —</option>
              {visibleBooks.map((book) => (
                <option key={book.book_id} value={book.book_id}>
                  {book.title}
                </option>
              ))}
            </select>
          </label>

          <label className="lh-field lh-admin-form__field">
            Bản sao còn sẵn
            <select value="" onChange={(event) => addCopy(event.target.value)} disabled={!bookId}>
              <option value="">
                {bookId
                  ? availableCopiesForBook.length
                    ? "— Chọn bản để thêm vào phiếu —"
                    : "Sách này không còn bản sẵn"
                  : "Chọn sách trước"}
              </option>
              {availableCopiesForBook.map((copy) => (
                <option key={copy.copy_id} value={copy.copy_id}>
                  {copy.barcode} · {copy.shelf_location || "Chưa xếp kệ"}
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
                  <th />
                </tr>
              </thead>
              <tbody>
                {cart.map((copy) => (
                  <tr key={copy.copy_id}>
                    <td>{bookTitle(copy.book_id)}</td>
                    <td>{copy.barcode}</td>
                    <td>{copy.shelf_location || "—"}</td>
                    <td className="lh-admin-table__actions">
                      <button
                        type="button"
                        className="lh-admin-icon-btn lh-admin-icon-btn--danger"
                        aria-label="Bỏ khỏi phiếu"
                        onClick={() => removeCopy(copy.copy_id)}
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
          <button
            type="submit"
            className="lh-btn lh-btn--primary"
            disabled={submitting
              || (borrowerType === "member" ? !userId : !guestName.trim())
              || cart.length === 0}
          >
            {submitting ? "Đang tạo..." : `Tạo phiếu mượn (${cart.length} cuốn)`}
          </button>
        </div>
      </form>
    </div>
  );
}
