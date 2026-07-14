// src/pages/Library.jsx
// Hiển thị toàn bộ kho sách, lọc theo thể loại + tìm theo tên/tác giả.
import { useMemo, useState } from "react";
import Header from "../components/Header";
import Footer from "../components/Footer";
import Icon from "../components/Icon";
import BookCard from "../components/BookCard";
import { categories, getAuthorName } from "../data/libraryData";
import { booksStore } from "../data/adminStore";
import "../styles/theme.css";
import "../styles/Library.css";

export default function Library() {
  const [activeCategory, setActiveCategory] = useState("all");
  const [query, setQuery] = useState("");

  // Đọc từ booksStore (chung với Admin/Thủ thư) để sách bị ẩn không hiện ở đây.
  const allBooks = booksStore.useCollection();
  const books = allBooks.filter((b) => !b.is_hidden);

  const filteredBooks = useMemo(() => {
    const q = query.trim().toLowerCase();
    return books.filter((book) => {
      const matchesCategory =
        activeCategory === "all" || book.category_id === Number(activeCategory);
      const matchesQuery =
        !q ||
        book.title.toLowerCase().includes(q) ||
        getAuthorName(book.author_id).toLowerCase().includes(q);
      return matchesCategory && matchesQuery;
    });
  }, [activeCategory, query, books]);

  return (
    <div className="lh-root">
      <Header />

      <section className="lh-library-hero">
        <div className="lh-container">
          <p className="lh-eyebrow">Kho sách</p>
          <h1 className="lh-h1" style={{ fontSize: "clamp(2rem, 3.4vw, 2.8rem)" }}>
            Toàn bộ thư viện
          </h1>
          <p className="lh-lede">
            {books.length} đầu sách đang có tại LibHub — lọc theo thể loại hoặc tìm theo tên
            sách, tác giả.
          </p>

          <div className="lh-library-search">
            <Icon name="search" size={18} />
            <input
              type="text"
              placeholder="Tìm theo tên sách hoặc tác giả…"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
            />
          </div>
        </div>
      </section>

      <section className="lh-section" style={{ paddingTop: 28 }}>
        <div className="lh-container">
          <div className="lh-library-filters">
            <button
              className={`lh-library-filter ${activeCategory === "all" ? "is-active" : ""}`}
              onClick={() => setActiveCategory("all")}
            >
              Tất cả ({books.length})
            </button>
            {categories.map((cat) => {
              const count = books.filter((b) => b.category_id === cat.category_id).length;
              return (
                <button
                  key={cat.category_id}
                  className={`lh-library-filter ${
                    activeCategory === cat.category_id ? "is-active" : ""
                  }`}
                  style={
                    activeCategory === cat.category_id
                      ? { background: cat.color, borderColor: cat.color }
                      : undefined
                  }
                  onClick={() => setActiveCategory(cat.category_id)}
                >
                  {cat.category_name} ({count})
                </button>
              );
            })}
          </div>

          {filteredBooks.length > 0 ? (
            <div className="lh-books-grid" style={{ marginTop: 28 }}>
              {filteredBooks.map((book) => (
                <BookCard key={book.book_id} book={book} />
              ))}
            </div>
          ) : (
            <div className="lh-library-empty">
              <Icon name="search" size={28} />
              <p>Không tìm thấy sách phù hợp. Thử từ khoá khác xem sao.</p>
            </div>
          )}
        </div>
      </section>

      <Footer />
    </div>
  );
}
