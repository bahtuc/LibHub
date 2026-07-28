import { useState } from "react";
import { Link, useParams } from "react-router-dom";
import Header from "../components/Header";
import Footer from "../components/Footer";
import BookCard from "../components/BookCard";
import { useCatalog } from "../context/CatalogContext";
import { useAuth } from "../auth/useAuth";
import { borrowBook } from "../services/BorrowTicketService";
import "../styles/BookDetail.css";

export default function BookDetail() {
  const { bookId } = useParams();
  const { books, categories, authors, loading, refresh } = useCatalog();
  const { user } = useAuth();
  const [borrowing, setBorrowing] = useState(false);
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  const book = books.find((item) => item.book_id === Number(bookId));
  const category = categories.find((item) => item.category_id === book?.category_id);
  const author = authors.find((item) => item.author_id === book?.author_id);

  if (loading) return <p>Đang tải...</p>;
  if (!book) {
    return <div className="lh-root"><Header /><section className="lh-section"><div className="lh-container"><p>Không tìm thấy sách.</p></div></section><Footer /></div>;
  }

  const available = book.status === "available";
  const related = books
    .filter((item) => item.category_id === book.category_id && item.book_id !== book.book_id)
    .slice(0, 4);

  async function handleBorrow() {
    setBorrowing(true);
    setMessage("");
    setError("");
    try {
      const ticket = await borrowBook(book.book_id);
      setMessage(`Mượn sách thành công. Hạn trả: ${String(ticket.dueDate).slice(0, 10)}.`);
      await refresh();
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
            <span className={`lh-book-card__status ${available ? "is-available" : "is-borrowed"}`}>
              {available ? "Còn sách" : "Đã mượn hết"}
            </span>

            <div style={{ marginTop: 20 }}>
              {!user ? (
                <Link to="/login" state={{ from: `/books/${book.book_id}` }} className="lh-btn lh-btn--primary">
                  Đăng nhập để mượn
                </Link>
              ) : (
                <button type="button" className="lh-btn lh-btn--primary" disabled={!available || borrowing} onClick={handleBorrow}>
                  {borrowing ? "Đang mượn..." : "Mượn sách"}
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
