
// src/pages/BorrowBooks.jsx

import { useEffect, useState } from "react";
import { Link } from "react-router-dom";

import Header from "../components/Header";
import Footer from "../components/Footer";

import { useCatalog } from "../context/CatalogContext";
import { useAuth } from "../auth/useAuth";

import { getMyBorrowHistory } from "../services/BorrowTicketService.js";
import { createBorrowVnpayPayment } from "../services/PaymentService.js";

import "../styles/Library.css";
import "../styles/BorrowBooks.css";

export default function BorrowBooks() {
  // =========================
  // DATA
  // =========================

  const { books = [], loading: booksLoading } = useCatalog();
  const { user } = useAuth();

  // =========================
  // STATE
  // =========================

  const [borrowedBooks, setBorrowedBooks] = useState([]);

  const [historyLoading, setHistoryLoading] = useState(false);

  const [borrowingId, setBorrowingId] = useState(null);

  const [message, setMessage] = useState("");

  const [error, setError] = useState("");

  const [borrowDays, setBorrowDays] = useState(14);

  // =========================
  // LOAD BORROW HISTORY
  // =========================

  useEffect(() => {
    if (user) {
      loadBorrowHistory();
    }
  }, [user]);

  async function loadBorrowHistory() {
    try {
      setHistoryLoading(true);
      setError("");

      const data = await getMyBorrowHistory();

      setBorrowedBooks(
        Array.isArray(data) ? data : []
      );
    } catch (err) {
      console.error(
        "Lỗi lấy lịch sử mượn:",
        err
      );

      setError(
        err?.message ||
          "Không thể tải lịch sử mượn sách."
      );
    } finally {
      setHistoryLoading(false);
    }
  }

  // =========================
  // BORROW BOOK
  // =========================

  async function handleBorrow(bookId) {
    if (!user) {
      setError(
        "Bạn cần đăng nhập để mượn sách."
      );

      return;
    }

    const fee = borrowDays * 5000;
    if (!window.confirm(`Bạn sẽ được chuyển sang VNPay để thanh toán ${fee.toLocaleString("vi-VN")}đ cho ${borrowDays} ngày mượn. Tiếp tục?`)) return;

    try {
      setBorrowingId(bookId);

      setMessage("");

      setError("");

      const payment = await createBorrowVnpayPayment(bookId, borrowDays);
      if (!payment?.payUrl) throw new Error("Không nhận được đường dẫn thanh toán VNPay.");
      window.location.assign(payment.payUrl);
    } catch (err) {
      console.error(
        "Lỗi mượn sách:",
        err
      );

      setError(
        err?.message ||
          "Không thể mượn sách. Vui lòng thử lại."
      );
    } finally {
      setBorrowingId(null);
    }
  }

  // =========================
  // BOOK TITLE
  // =========================

  function getBookTitle(bookId) {
    const book = books.find(
      (item) =>
        Number(item.book_id) ===
        Number(bookId)
    );

    return (
      book?.title ||
      `Sách #${bookId}`
    );
  }

  // =========================
  // STATUS
  // =========================

  function getStatusLabel(status) {
    switch (String(status).toLowerCase()) {
      case "pending":
        return "Chờ duyệt";

      case "approved":
        return "Đã duyệt";

      case "borrowed":
        return "Đang mượn";

      case "returned":
        return "Đã trả";

      case "rejected":
        return "Từ chối";

      case "overdue":
        return "Quá hạn";

      default:
        return status || "Không xác định";
    }
  }

  function getStatusClass(status) {
    switch (String(status).toLowerCase()) {
      case "pending":
        return "borrow-status pending";

      case "approved":
        return "borrow-status approved";

      case "borrowed":
        return "borrow-status borrowed";

      case "returned":
        return "borrow-status returned";

      case "rejected":
        return "borrow-status rejected";

      case "overdue":
        return "borrow-status overdue";

      default:
        return "borrow-status";
    }
  }

  // =========================
  // BOOK AVAILABLE
  // =========================

  function isBookAvailable(book) {
    const status = String(
      book?.status || ""
    ).toLowerCase();

    return (
      status === "available" ||
      status === "còn sách" ||
      status === "available "
    );
  }

  // =========================
  // LOADING
  // =========================

  if (booksLoading) {
    return (
      <div className="borrow-page">
        <Header />

        <main className="lh-container">
          <div className="borrow-loading">
            Đang tải danh sách sách...
          </div>
        </main>

        <Footer />
      </div>
    );
  }

  // =========================
  // RENDER
  // =========================

  return (
    <div className="borrow-page">

      <Header />

      <main className="lh-container">

        {/* =====================================
            HEADER
        ====================================== */}

        <section className="borrow-header">

          <h1>Mượn sách</h1>

          <p>
            Chọn sách bạn muốn mượn
            từ thư viện LibHub.
          </p>

        </section>

        {/* =====================================
            NOT LOGIN
        ====================================== */}

        {!user && (
          <div className="borrow-login-warning">

            <p>
              Bạn cần đăng nhập để
              mượn sách.
            </p>

            <Link
              to="/login"
              className="lh-btn lh-btn--primary"
            >
              Đăng nhập
            </Link>

          </div>
        )}

        {/* =====================================
            SUCCESS MESSAGE
        ====================================== */}

        {message && (
          <div className="borrow-success">
            {message}
          </div>
        )}

        {/* =====================================
            ERROR MESSAGE
        ====================================== */}

        {error && (
          <div className="borrow-error">
            {error}
          </div>
        )}

        {/* =====================================
            BOOK LIST
        ====================================== */}

        <section className="borrow-books-section">

          <div className="borrow-duration-panel">
            <label htmlFor="borrow-days">Số ngày muốn mượn</label>
            <div className="borrow-duration-panel__controls">
              <input
                id="borrow-days"
                type="number"
                min="1"
                max="30"
                value={borrowDays}
                onChange={(event) => {
                  const days = Number(event.target.value);
                  setBorrowDays(Math.min(30, Math.max(1, Number.isFinite(days) ? days : 1)));
                }}
              />
              <span>ngày</span>
            </div>
            <strong>Phí mượn: {(borrowDays * 5000).toLocaleString("vi-VN")}đ</strong>
            <small>5.000đ × {borrowDays} ngày · tối đa 30 ngày</small>
          </div>

          <div className="borrow-section-header">

            <h2>
              Danh sách sách
            </h2>

            <span>
              {books.length} sách
            </span>

          </div>

          {books.length === 0 ? (

            <div className="borrow-empty">
              <p>
                Không có sách nào
                trong thư viện.
              </p>
            </div>

          ) : (

            <div className="borrow-book-grid">

              {books.map((book) => {

                const available =
                  isBookAvailable(book);

                const isBorrowing =
                  borrowingId ===
                  book.book_id;

                return (
                  <article
                    className="borrow-book-card"
                    key={book.book_id}
                  >

                    {/* COVER */}

                    <div className="borrow-book-cover">

                      {book.cover_image ? (

                        <img
                          src={book.cover_image}
                          alt={book.title}
                        />

                      ) : (

                        <div className="borrow-book-cover-placeholder">
                          {book.title
                            ?.charAt(0)
                            ?.toUpperCase() || "S"}
                        </div>

                      )}

                    </div>

                    {/* INFO */}

                    <div className="borrow-book-info">

                      <h3>
                        {book.title}
                      </h3>

                      {book.author_name && (
                        <p>
                          <strong>
                            Tác giả:
                          </strong>{" "}
                          {book.author_name}
                        </p>
                      )}

                      {book.isbn && (
                        <p>
                          <strong>
                            ISBN:
                          </strong>{" "}
                          {book.isbn}
                        </p>
                      )}

                      {book.publish_year && (
                        <p>
                          <strong>
                            Năm xuất bản:
                          </strong>{" "}
                          {book.publish_year}
                        </p>
                      )}

                      {/* STATUS */}

                      <div className="borrow-book-status">

                        <span
                          className={
                            available
                              ? "book-available"
                              : "book-unavailable"
                          }
                        >
                          {available
                            ? "Còn sách"
                            : "Đã mượn hết"}
                        </span>

                      </div>

                      {/* ACTION */}

                      <div className="borrow-book-actions">

                        <Link
                          to={`/books/${book.book_id}`}
                          className="lh-btn"
                        >
                          Chi tiết
                        </Link>

                        <button
                          type="button"
                          className="lh-btn lh-btn--primary"
                          disabled={
                            !user ||
                            !available ||
                            isBorrowing
                          }
                          onClick={() =>
                            handleBorrow(
                              book.book_id
                            )
                          }
                        >

                          {isBorrowing
                            ? "Đang chuyển VNPay..."
                            : available
                              ? "Mượn & thanh toán"
                              : "Hết sách"}

                        </button>

                      </div>

                    </div>

                  </article>
                );
              })}

            </div>

          )}

        </section>

        {/* =====================================
            BORROW HISTORY
        ====================================== */}

        {user && (
          <section className="borrow-history-section">

            <div className="borrow-section-header">

              <h2>
                Lịch sử mượn sách
              </h2>

              <button
                type="button"
                onClick={loadBorrowHistory}
                disabled={historyLoading}
              >
                {historyLoading
                  ? "Đang tải..."
                  : "Làm mới"}
              </button>

            </div>

            {/* LOADING */}

            {historyLoading ? (

              <div className="borrow-loading">
                Đang tải lịch sử mượn...
              </div>

            ) : borrowedBooks.length === 0 ? (

              <div className="borrow-empty">

                <p>
                  Bạn chưa có phiếu
                  mượn nào.
                </p>

              </div>

            ) : (

              <div className="borrow-history">

                {borrowedBooks.map(
                  (ticket) => (

                    <article
                      className="borrow-history-item"
                      key={
                        ticket.borrow_ticket_id
                      }
                    >

                      {/* TICKET INFO */}

                      <div className="borrow-history-info">

                        <h3>
                          Phiếu #
                          {
                            ticket.borrow_ticket_id
                          }
                        </h3>

                        {/* Nếu API có book_id */}

                        {ticket.book_id && (
                          <p>
                            <strong>
                              Sách:
                            </strong>{" "}
                            {getBookTitle(
                              ticket.book_id
                            )}
                          </p>
                        )}

                        <p>
                          <strong>
                            Ngày mượn:
                          </strong>{" "}
                          {ticket.borrow_date ||
                            "—"}
                        </p>

                        <p>
                          <strong>
                            Hạn trả:
                          </strong>{" "}
                          {ticket.due_date ||
                            "—"}
                        </p>

                        {ticket.note && (
                          <p>
                            <strong>
                              Ghi chú:
                            </strong>{" "}
                            {ticket.note}
                          </p>
                        )}

                      </div>

                      {/* STATUS */}

                      <div className="borrow-history-status">

                        <span
                          className={getStatusClass(
                            ticket.status
                          )}
                        >
                          {getStatusLabel(
                            ticket.status
                          )}
                        </span>

                      </div>

                    </article>

                  )
                )}

              </div>

            )}

          </section>
        )}

      </main>

      <Footer />

    </div>
  );
}
