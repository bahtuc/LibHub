// src/pages/BookDetail.jsx
import { useState } from "react";
import { Link, useParams } from "react-router-dom";
import Header from "../components/Header";
import Footer from "../components/Footer";
import Icon from "../components/Icon";
import BookCard from "../components/BookCard";
import StarRating from "../components/StarRating";
import {
  getAuthorName,
  getCategory,
} from "../data/libraryData";
import { booksStore } from "../data/adminStore";
import { getAverageRating, getReviewsForBook, addReview } from "../data/reviews";
import { useBookCovers } from "../data/useBookCovers";
import "../styles/theme.css";
import "../styles/Library.css";
import "../styles/BookDetail.css";

export default function BookDetail() {
  const { bookId } = useParams();
  const covers = useBookCovers();
  const allBooks = booksStore.useCollection();
  // Sách bị thủ thư ẩn thì khách xem như không tồn tại (giống trạng thái 404).
  const book = allBooks.find((b) => b.book_id === Number(bookId) && !b.is_hidden);

  const [reviews, setReviews] = useState(() => getReviewsForBook(bookId));
  const [form, setForm] = useState({ reviewer_name: "", rating: 5, comment: "" });
  const [submitted, setSubmitted] = useState(false);

  if (!book) {
    return (
      <div className="lh-root">
        <Header />
        <section className="lh-section">
          <div className="lh-container lh-library-empty">
            <Icon name="book-open" size={28} />
            <p>Không tìm thấy cuốn sách này.</p>
            <Link to="/library" className="lh-btn lh-btn--ghost" style={{ marginTop: 12 }}>
              ← Quay lại thư viện
            </Link>
          </div>
        </section>
        <Footer />
      </div>
    );
  }

  const category = getCategory(book.category_id);
  const available = book.status === "available";
  const coverUrl = covers[book.book_id] || book.cover_image;
  const { average, count } = getAverageRating(book.book_id);
  const related = allBooks
    .filter((b) => b.category_id === book.category_id && b.book_id !== book.book_id && !b.is_hidden)
    .slice(0, 4);

  function handleSubmitReview(e) {
    e.preventDefault();
    if (!form.comment.trim()) return;
    addReview(book.book_id, form);
    setReviews(getReviewsForBook(book.book_id));
    setForm({ reviewer_name: "", rating: 5, comment: "" });
    setSubmitted(true);
    setTimeout(() => setSubmitted(false), 3000);
  }

  return (
    <div className="lh-root">
      <Header />

      <section className="lh-library-hero">
        <div className="lh-container">
          <Link to="/library" className="lh-link-arrow" style={{ display: "inline-flex" }}>
            <Icon name="arrow" size={14} style={{ transform: "rotate(180deg)" }} /> Quay lại thư
            viện
          </Link>
        </div>
      </section>

      <section className="lh-section" style={{ paddingTop: 20 }}>
        <div className="lh-container lh-book-detail">
          <div
            className="lh-book-detail__cover"
            style={{ "--spine": category?.color ?? "#3d6652" }}
          >
            {coverUrl ? (
              <img src={coverUrl} alt={book.title} />
            ) : (
              <span className="lh-book-detail__initial">{book.title.charAt(0)}</span>
            )}
          </div>

          <div className="lh-book-detail__info">
            <span
              className="lh-book-card__tag"
              style={{ color: category?.color, borderColor: category?.color }}
            >
              {category?.category_name}
            </span>

            <h1 className="lh-h1" style={{ fontSize: "clamp(1.7rem, 3vw, 2.3rem)", margin: "10px 0 8px" }}>
              {book.title}
            </h1>

            <p className="lh-book-detail__meta">
              {getAuthorName(book.author_id)} · {book.publish_year} · {book.pages} trang
            </p>

            <div className="lh-book-detail__rating">
              <StarRating value={average} />
              <span>
                {average > 0 ? average : "Chưa có"} {count > 0 && `(${count} đánh giá)`}
              </span>
            </div>

            <span className={`lh-book-card__status ${available ? "is-available" : "is-borrowed"} lh-book-detail__status`}>
              {available ? "Còn sách" : "Đã mượn hết"}
            </span>

            <p className="lh-book-detail__description">{book.description}</p>

            <button type="button" className="lh-btn lh-btn--primary" disabled={!available}>
              {available ? "Mượn sách này" : "Hiện đã hết sách"}
            </button>
          </div>
        </div>
      </section>

      <section className="lh-section lh-section--soft">
        <div className="lh-container lh-book-detail__reviews">
          <h2 className="lh-h2" style={{ marginBottom: 22 }}>
            Đánh giá từ độc giả ({reviews.length})
          </h2>

          {reviews.length > 0 ? (
            <div className="lh-review-list">
              {reviews.map((r) => (
                <div className="lh-review-card" key={r.review_id}>
                  <div className="lh-review-card__head">
                    <span className="lh-review-card__avatar">{r.reviewer_name.charAt(0)}</span>
                    <div>
                      <p className="lh-review-card__name">{r.reviewer_name}</p>
                      <StarRating value={r.rating} size={14} />
                    </div>
                    <span className="lh-review-card__date">{r.created_at}</span>
                  </div>
                  <p className="lh-review-card__comment">{r.comment}</p>
                </div>
              ))}
            </div>
          ) : (
            <p style={{ color: "var(--lh-text-muted)" }}>Chưa có đánh giá nào, hãy là người đầu tiên!</p>
          )}

          <form className="lh-review-form" onSubmit={handleSubmitReview}>
            <h3 className="lh-h3" style={{ marginBottom: 14 }}>
              Viết đánh giá của bạn
            </h3>

            <label className="lh-field">
              Tên của bạn
              <input
                type="text"
                value={form.reviewer_name}
                onChange={(e) => setForm((f) => ({ ...f, reviewer_name: e.target.value }))}
                placeholder="Nguyễn Văn A"
              />
            </label>

            <label className="lh-field">
              Đánh giá
              <StarRating
                value={form.rating}
                interactive
                onChange={(n) => setForm((f) => ({ ...f, rating: n }))}
              />
            </label>

            <label className="lh-field">
              Bình luận
              <textarea
                rows={3}
                value={form.comment}
                onChange={(e) => setForm((f) => ({ ...f, comment: e.target.value }))}
                placeholder="Cảm nhận của bạn về cuốn sách này…"
                required
              />
            </label>

            {submitted && <p className="lh-auth-form__success">Cảm ơn bạn đã đánh giá!</p>}

            <button type="submit" className="lh-btn lh-btn--primary" style={{ alignSelf: "flex-start" }}>
              Gửi đánh giá
            </button>
          </form>
        </div>
      </section>

      {related.length > 0 && (
        <section className="lh-section">
          <div className="lh-container">
            <div className="lh-section-head">
              <div>
                <p className="lh-eyebrow">Có thể bạn cũng thích</p>
                <h2 className="lh-h2">Sách cùng thể loại</h2>
              </div>
            </div>
            <div className="lh-books-grid">
              {related.map((b) => (
                <BookCard key={b.book_id} book={b} />
              ))}
            </div>
          </div>
        </section>
      )}

      <Footer />
    </div>
  );
}
