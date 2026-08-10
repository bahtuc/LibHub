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

  // =========================
  // Load danh sách bạn đọc
  // =========================
  useEffect(() => {
    let active = true;

    getBorrowers()
      .then((data) => {
        if (!active) return;

        const next = Array.isArray(data) ? data : [];

        setBorrowers(next);

        setUserId((current) => {
          if (current) return current;

          return next[0]?.userId
            ? String(next[0].userId)
            : "";
        });

        setError("");
      })
      .catch((requestError) => {
        if (active) {
          setError(
            requestError.message ||
              "Không tải được danh sách bạn đọc."
          );
        }
      });

    return () => {
      active = false;
    };
  }, []);

  // =========================
  // Chỉ lấy sách đang hiển thị
  // =========================
  const visibleBooks = useMemo(
    () =>
      books.filter(
        (book) => !book.is_hidden
      ),
    [books]
  );

  // =========================
  // Các bản sao còn available
  // =========================
  const availableCopiesForBook = useMemo(() => {
    if (!bookId) return [];

    return copies.filter(
      (copy) =>
        copy.book_id === Number(bookId) &&
        copy.status === "available" &&
        !selectedCopyIds.includes(copy.copy_id)
    );
  }, [bookId, copies, selectedCopyIds]);

  // =========================
  // Danh sách bản sao đã chọn
  // =========================
  const cart = selectedCopyIds
    .map((id) =>
      copies.find(
        (copy) => copy.copy_id === id
      )
    )
    .filter(Boolean);

  // =========================
  // Thêm bản sao vào phiếu
  // =========================
  function addCopy(copyId) {
    const numericId = Number(copyId);

    if (
      !numericId ||
      selectedCopyIds.includes(numericId)
    ) {
      return;
    }

    if (selectedCopyIds.length >= 5) {
      setError("Mỗi người chỉ được mượn tối đa 5 cuốn sách.");
      return;
    }

    setError("");
    setSelectedCopyIds((ids) => [
      ...ids,
      numericId,
    ]);
  }

  // =========================
  // Xóa bản sao khỏi phiếu
  // =========================
  function removeCopy(copyId) {
    setSelectedCopyIds((ids) =>
      ids.filter((id) => id !== copyId)
    );
  }

  // =========================
  // Thay đổi loại bạn đọc
  // =========================
  function handleBorrowerTypeChange(event) {
    const type = event.target.value;

    setBorrowerType(type);

    if (type === "guest") {
      setUserId("");
    } else {
      setGuestName("");
      setGuestPhone("");
    }

    setError("");
    setSuccess(null);
  }

  // =========================
  // Tạo phiếu mượn
  // =========================
  async function handleSubmit(event) {
    event.preventDefault();

    const isGuest = borrowerType === "guest";

    if (
      (!isGuest && !userId) ||
      (isGuest && !guestName.trim()) ||
      selectedCopyIds.length === 0
    ) {
      return;
    }

    setSubmitting(true);
    setError("");
    setSuccess(null);

    try {
      const ticket = await createBorrowTicket({
        userId: isGuest
          ? null
          : Number(userId),

        guestName: isGuest
          ? guestName.trim()
          : null,

        guestPhone: isGuest
          ? guestPhone.trim() || null
          : null,

        borrowDate: new Date()
          .toISOString()
          .slice(0, 10),

        dueDate,

        copyIds: selectedCopyIds,

        note: note.trim() || null,
      });

      setSuccess(ticket.ticketId);

      // Reset form
      setSelectedCopyIds([]);
      setBookId("");
      setNote("");
      setGuestName("");
      setGuestPhone("");
      setDueDate(defaultDueDate());

      // Reload trạng thái bản sao
      await copiesStore.refresh();
    } catch (requestError) {
      setError(
        requestError.message ||
          "Không thể tạo phiếu mượn."
      );
    } finally {
      setSubmitting(false);
    }
  }

  // =========================
  // Lấy tên sách
  // =========================
  function bookTitle(id) {
    return (
      books.find(
        (book) => book.book_id === id
      )?.title ?? "—"
    );
  }

  return (
    <div className="lh-admin-page">

      {/* =========================
          Header
      ========================= */}
      <div className="lh-admin-page__header">
        <div>
          <h1>Mượn sách</h1>

          <p>
            Tạo phiếu mượn mới và lưu trực tiếp
            vào hệ thống.
          </p>
        </div>
      </div>

      {/* =========================
          Success
      ========================= */}
      {success && (
        <p
          className="lh-auth-form__success"
          style={{ marginBottom: 18 }}
        >
          Đã tạo phiếu mượn #{success} thành công.
        </p>
      )}

      {/* =========================
          Error
      ========================= */}
      {error && (
        <p className="lh-auth-form__error">
          {error}
        </p>
      )}

      {/* =========================
          Form
      ========================= */}
      <form
        className="lh-admin-form"
        onSubmit={handleSubmit}
      >
        <h2 className="lh-admin-form__heading">
          <Icon name="plus" size={18} />
          Phiếu mượn mới
        </h2>

        {/* =====================
            Thông tin phiếu mượn
        ====================== */}
        <div className="lh-admin-form__grid">

          {/* Loại bạn đọc */}
          <label className="lh-field lh-admin-form__field">
            Loại bạn đọc

            <select
              value={borrowerType}
              onChange={handleBorrowerTypeChange}
            >
              <option value="member">
                Thành viên
              </option>

              <option value="guest">
                Khách vãng lai
              </option>
            </select>
          </label>

          {/* =====================
              Thành viên
          ====================== */}
          {borrowerType === "member" ? (
            <label className="lh-field lh-admin-form__field">
              Bạn đọc

              <select
                value={userId}
                onChange={(event) =>
                  setUserId(event.target.value)
                }
                required
              >
                {borrowers.length === 0 ? (
                  <option value="">
                    — Chưa có bạn đọc đang hoạt động —
                  </option>
                ) : (
                  <>
                    <option value="">
                      — Chọn bạn đọc —
                    </option>

                    {borrowers.map((borrower) => (
                      <option
                        key={borrower.userId}
                        value={borrower.userId}
                      >
                        {borrower.fullName ||
                          borrower.username}{" "}
                        ({borrower.username})
                      </option>
                    ))}
                  </>
                )}
              </select>
            </label>
          ) : (
            <>
              {/* =====================
                  Khách vãng lai
              ====================== */}
              <label className="lh-field lh-admin-form__field">
                Tên khách

                <input
                  type="text"
                  value={guestName}
                  onChange={(event) =>
                    setGuestName(event.target.value)
                  }
                  placeholder="Nhập tên khách"
                  required
                />
              </label>

              <label className="lh-field lh-admin-form__field">
                Số điện thoại khách

                <input
                  type="tel"
                  value={guestPhone}
                  onChange={(event) =>
                    setGuestPhone(event.target.value)
                  }
                  placeholder="Tùy chọn"
                />
              </label>
            </>
          )}

          {/* Hạn trả */}
          <label className="lh-field lh-admin-form__field">
            Hạn trả

            <input
              type="date"
              min={new Date()
                .toISOString()
                .slice(0, 10)}
              value={dueDate}
              onChange={(event) =>
                setDueDate(event.target.value)
              }
              required
            />
          </label>

          {/* Ghi chú */}
          <label className="lh-field lh-admin-form__field">
            Ghi chú (tùy chọn)

            <input
              type="text"
              value={note}
              onChange={(event) =>
                setNote(event.target.value)
              }
              placeholder="—"
            />
          </label>
        </div>

        {/* =====================
            Chọn sách
        ====================== */}
        <div
          className="lh-admin-form__grid"
          style={{ marginTop: -4 }}
        >
          {/* Chọn đầu sách */}
          <label className="lh-field lh-admin-form__field">
            Chọn sách

            <select
              value={bookId}
              onChange={(event) =>
                setBookId(event.target.value)
              }
            >
              <option value="">
                — Chọn một đầu sách —
              </option>

              {visibleBooks.map((book) => (
                <option
                  key={book.book_id}
                  value={book.book_id}
                >
                  {book.title}
                </option>
              ))}
            </select>
          </label>

          {/* Chọn bản sao */}
          <label className="lh-field lh-admin-form__field">
            Bản sao còn sẵn

            <select
              value=""
              onChange={(event) =>
                addCopy(event.target.value)
              }
              disabled={!bookId || selectedCopyIds.length >= 5}
            >
              <option value="">
                {selectedCopyIds.length >= 5
                  ? "Đã đạt giới hạn 5 cuốn"
                  : bookId
                  ? availableCopiesForBook.length
                    ? "— Chọn bản để thêm vào phiếu —"
                    : "Sách này không còn bản sẵn"
                  : "Chọn sách trước"}
              </option>

              {availableCopiesForBook.map(
                (copy) => (
                  <option
                    key={copy.copy_id}
                    value={copy.copy_id}
                  >
                    {copy.barcode} ·{" "}
                    {copy.shelf_location ||
                      "Chưa xếp kệ"}
                  </option>
                )
              )}
            </select>
          </label>
        </div>

        {/* =====================
            Danh sách sách đã chọn
        ====================== */}
        {cart.length > 0 && (
          <div
            className="lh-admin-table-wrap"
            style={{ marginBottom: 20 }}
          >
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
                    <td>
                      {bookTitle(copy.book_id)}
                    </td>

                    <td>
                      {copy.barcode}
                    </td>

                    <td>
                      {copy.shelf_location ||
                        "—"}
                    </td>

                    <td className="lh-admin-table__actions">
                      <button
                        type="button"
                        className="lh-admin-icon-btn lh-admin-icon-btn--danger"
                        aria-label="Bỏ khỏi phiếu"
                        onClick={() =>
                          removeCopy(
                            copy.copy_id
                          )
                        }
                      >
                        <Icon
                          name="x"
                          size={14}
                        />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
        <p style={{ margin: "-8px 0 18px", color: "var(--lh-text-muted)", fontSize: "0.86rem" }}>
          Đã chọn {selectedCopyIds.length}/5 cuốn.
        </p>

        {/* =====================
            Submit
        ====================== */}
        <div className="lh-admin-form__actions">
          <button
            type="submit"
            className="lh-btn lh-btn--primary"
            disabled={
              submitting ||
              (
                borrowerType === "member"
                  ? !userId
                  : !guestName.trim()
              ) ||
              cart.length === 0
            }
          >
            {submitting
              ? "Đang tạo..."
              : `Tạo phiếu mượn (${cart.length} cuốn)`}
          </button>
        </div>
      </form>
    </div>
  );
}
