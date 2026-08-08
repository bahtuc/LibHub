import { useMemo, useState } from "react";

import Header from "../components/Header";
import Footer from "../components/Footer";
import Icon from "../components/Icon";
import BookCard from "../components/BookCard";
import { useCatalog } from "../context/CatalogContext";

import "../styles/theme.css";
import "../styles/Library.css";

export default function BorrowBooks() {
  const {
    books,
    categories,
    authors,
    loading,
    error,
  } = useCatalog();

  const [activeCategory, setActiveCategory] = useState("all");
  const [query, setQuery] = useState("");

  const filtered = useMemo(() => {
    return books.filter((book) => {
      const matchCategory =
        activeCategory === "all" ||
        book.category_id === Number(activeCategory);

      const authorName =
        authors.find(
          (a) => a.author_id === book.author_id
        )?.author_name ?? "";

      const keyword =
        `${book.title} ${authorName}`.toLowerCase();

      const matchQuery = keyword.includes(
        query.trim().toLowerCase()
      );

      return matchCategory && matchQuery;
    });
  }, [books, authors, activeCategory, query]);

  const handleBorrow = (book) => {
    console.log("Mượn sách:", book);

    // Sau này gọi API:
    // BorrowService.createBorrow({
    //   book_id: book.book_id
    // });
  };

  return (
    <>
      <Header />

      <main className="lh-library">
        <div className="lh-library-header">
          <div>
            <h1>Kho sách</h1>
            <p>
              Tìm kiếm và đăng ký mượn sách từ thư viện.
            </p>
          </div>

          <div className="lh-library-count">
            {books.length} đầu sách
          </div>
        </div>

        {/* Search */}
        <div className="lh-library-search">
          <Icon name="search" />

          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Tìm theo tên sách hoặc tác giả..."
          />
        </div>

        {/* Category */}
        <div className="lh-library-filters">
          <button
            className={`lh-library-filter ${
              activeCategory === "all" ? "is-active" : ""
            }`}
            onClick={() => setActiveCategory("all")}
          >
            Tất cả ({books.length})
          </button>

          {categories.map((cat) => {
            const count = books.filter(
              (book) => book.category_id === cat.category_id
            ).length;

            return (
              <button
                key={cat.category_id}
                className={`lh-library-filter ${
                  activeCategory === cat.category_id
                    ? "is-active"
                    : ""
                }`}
                onClick={() =>
                  setActiveCategory(cat.category_id)
                }
              >
                {cat.category_name} ({count})
              </button>
            );
          })}
        </div>

        {/* Books */}
        {loading ? (
          <div className="lh-library-empty">
            Đang tải sách...
          </div>
        ) : error ? (
          <div className="lh-library-empty">
            {error}
          </div>
        ) : filtered.length > 0 ? (
          <div
            className="lh-books-grid"
            style={{ marginTop: 28 }}
          >
            {filtered.map((book) => (
              <div
                key={book.book_id}
                className="lh-book-borrow-item"
              >
                <BookCard
                  book={book}
                  authors={authors}
                />

                <button
                  className="lh-btn lh-btn-primary"
                  onClick={() => handleBorrow(book)}
                >
                  <Icon name="book-open" />
                  Mượn sách
                </button>
              </div>
            ))}
          </div>
        ) : (
          <div className="lh-library-empty">
            Không tìm thấy sách phù hợp.
          </div>
        )}
      </main>

      <Footer />
    </>
  );
}