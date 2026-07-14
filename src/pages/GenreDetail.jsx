// src/pages/GenreDetail.jsx
import { Link, useParams } from "react-router-dom";
import Header from "../components/Header";
import Footer from "../components/Footer";
import Icon from "../components/Icon";
import BookCard from "../components/BookCard";
import { categories, getBooksByCategory } from "../data/libraryData";
import "../styles/theme.css";
import "../styles/Library.css";

export default function GenreDetail() {
  const { categoryId } = useParams();
  const category = categories.find((c) => c.category_id === Number(categoryId));
  const booksInGenre = getBooksByCategory(categoryId);

  if (!category) {
    return (
      <div className="lh-root">
        <Header />
        <section className="lh-section">
          <div className="lh-container lh-library-empty">
            <Icon name="layers" size={28} />
            <p>Không tìm thấy thể loại này.</p>
            <Link to="/genres" className="lh-btn lh-btn--ghost" style={{ marginTop: 12 }}>
              ← Quay lại danh sách thể loại
            </Link>
          </div>
        </section>
        <Footer />
      </div>
    );
  }

  return (
    <div className="lh-root">
      <Header />

      <section className="lh-library-hero">
        <div className="lh-container">
          <Link to="/genres" className="lh-link-arrow" style={{ marginBottom: 14, display: "inline-flex" }}>
            <Icon name="arrow" size={14} style={{ transform: "rotate(180deg)" }} /> Tất cả thể loại
          </Link>

          <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
            <span
              style={{
                display: "grid",
                placeItems: "center",
                width: 52,
                height: 52,
                borderRadius: 14,
                background: category.color,
                color: "#fff",
                flexShrink: 0,
              }}
            >
              <Icon name={category.icon} size={26} />
            </span>
            <div>
              <p className="lh-eyebrow">Thể loại</p>
              <h1 className="lh-h1" style={{ fontSize: "clamp(1.8rem, 3vw, 2.4rem)" }}>
                {category.category_name}
              </h1>
            </div>
          </div>

          <p className="lh-lede" style={{ marginTop: 14 }}>
            {booksInGenre.length} đầu sách thuộc thể loại {category.category_name.toLowerCase()}.
          </p>
        </div>
      </section>

      <section className="lh-section" style={{ paddingTop: 28 }}>
        <div className="lh-container">
          {booksInGenre.length > 0 ? (
            <div className="lh-books-grid">
              {booksInGenre.map((book) => (
                <BookCard key={book.book_id} book={book} />
              ))}
            </div>
          ) : (
            <div className="lh-library-empty">
              <Icon name="book-open" size={28} />
              <p>Chưa có sách nào trong thể loại này.</p>
            </div>
          )}
        </div>
      </section>

      <Footer />
    </div>
  );
}
