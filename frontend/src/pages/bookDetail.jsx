import { useState } from "react";
import { Link, useParams } from "react-router-dom";
import Header from "../components/Header";
import Footer from "../components/Footer";
import BookCard from "../components/BookCard";
import { useCatalog } from "../context/CatalogContext";
import { useAuth } from "../auth/useAuth";
import { createBorrowVnpayPayment } from "../services/PaymentService";
import "../styles/BookDetail.css";

export default function BookDetail() {
  const { bookId } = useParams();
  const { books, categories, authors, loading } = useCatalog();
  const { user } = useAuth();
  const [borrowing, setBorrowing] = useState(false);
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [borrowDays, setBorrowDays] = useState(14);

  const book = books.find((item) => item.book_id === Number(bookId));
  const category = categories.find((item) => item.category_id === book?.category_id);
  const author = authors.find((item) => item.author_id === book?.author_id);

  if (loading) return <div className="lh-root"><Header /><main className="lh-book-detail-state"><span className="lh-spinner" /><p>Đang tải thông tin sách...</p></main><Footer /></div>;
  if (!book) {
    return <div className="lh-root"><Header /><section className="lh-section"><div className="lh-container"><p>Không tìm thấy sách.</p></div></section><Footer /></div>;
  }

  const available = book.status === "available";
  const related = books
    .filter((item) => item.category_id === book.category_id && item.book_id !== book.book_id)
    .slice(0, 4);

  async function handleBorrow() {
    const fee = borrowDays * 5000;
    if (!window.confirm(`Bạn sẽ được chuyển sang VNPay để thanh toán ${fee.toLocaleString("vi-VN")}đ cho ${borrowDays} ngày mượn. Tiếp tục?`)) return;
    setBorrowing(true);
    setMessage("");
    setError("");
    try {
      const payment = await createBorrowVnpayPayment(book.book_id, borrowDays);
      if (!payment?.payUrl) throw new Error("Không nhận được đường dẫn thanh toán VNPay.");
      window.location.assign(payment.payUrl);
    } catch (requestError) {
      setError(requestError.message || "Không thể mượn sách.");
    } finally {
      setBorrowing(false);
    }
  }

  return (
    <div className="lh-root">
      <Header />
      <section className="lh-section">
        <div className="lh-container lh-book-detail">
          <div className="lh-book-detail__cover" style={{ "--spine": category?.color ?? "#3d6652" }}>
            {book.cover_image
              ? <img src={book.cover_image} alt={book.title} />
              : <span className="lh-book-detail__initial">{book.title.charAt(0)}</span>}
          </div>
          <div className="lh-book-detail__info">
            <Link to="/library" className="lh-link-arrow">← Quay lại thư viện</Link>
            <h1 className="lh-h1">{book.title}</h1>
            <p className="lh-book-detail__meta">
              {author?.author_name ?? "Chưa rõ tác giả"} · {book.publish_year} · {book.pages} trang
            </p>
            <p className="lh-book-detail__description">{book.description}</p>
            <div className="lh-book-detail__availability">
              <span className={`lh-book-detail__status ${available ? "is-available" : "is-borrowed"}`}>
                {available ? "Còn sách" : "Đã mượn hết"}
              </span>
              <span>{available ? `${book.available_copies} / ${book.total_copies} bản đang có sẵn` : `${book.total_copies} bản hiện đều đang được mượn`}</span>
            </div>

            <div className="lh-book-detail__actions">
              {user && available && !message && (
                <label className="lh-book-detail__duration">
                  <span>Thời hạn mượn</span>
                  <span className="lh-book-detail__duration-input">
                    <input
                      type="number"
                      min="1"
                      max="30"
                      value={borrowDays}
                      onChange={(event) => {
                        const days = Number(event.target.value);
                        setBorrowDays(Math.min(30, Math.max(1, Number.isFinite(days) ? days : 1)));
                      }}
                    />
                    ngày
                  </span>
                  <small>Phí: {(borrowDays * 5000).toLocaleString("vi-VN")}đ</small>
                </label>
              )}
              {!user ? (
                <Link to="/login" state={{ from: `/books/${book.book_id}` }} className="lh-btn lh-btn--primary">
                  Đăng nhập để mượn
                </Link>
              ) : (
                <button type="button" className="lh-btn lh-btn--primary" disabled={!available || borrowing || Boolean(message)} onClick={handleBorrow}>
                  {borrowing ? "Đang chuyển VNPay..." : message ? "Đã mượn thành công" : available ? "Mượn & thanh toán VNPay" : "Hiện đã hết sách"}
                </button>
              )}
            </div>
            {message && <p className="lh-auth-form__success" style={{ marginTop: 12 }}>{message}</p>}
            {error && <p className="lh-auth-form__error" style={{ marginTop: 12 }}>{error}</p>}
          </div>
        </div>
      </section>

      {related.length > 0 && (
        <section className="lh-section">
          <div className="lh-container">
            <h2 className="lh-h2">Sách cùng thể loại</h2>
            <div className="lh-books-grid">
              {related.map((item) => <BookCard key={item.book_id} book={item} />)}
            </div>
          </div>
        </section>
      )}
      <Footer />
    </div>
  );
}
