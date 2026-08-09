import { useMemo, useState } from "react";

import Header from "../components/Header";
import Footer from "../components/Footer";
import Icon from "../components/Icon";
import BookCard from "../components/BookCard";
import { useCatalog } from "../context/CatalogContext";

import "../styles/theme.css";
import "../styles/Library.css";

export default function Library() {
  const { books, categories, authors, loading, error } = useCatalog();
  const [activeCategory, setActiveCategory] = useState("all");
  const [query, setQuery] = useState("");
  const [availability, setAvailability] = useState("all");
  const [sortBy, setSortBy] = useState("title");

  const filtered = useMemo(() => {
    const normalizedQuery = query.trim().toLocaleLowerCase("vi");
    const result = books.filter((book) => {
      const authorName = authors.find((author) => author.author_id === book.author_id)?.author_name ?? "";
      const matchesCategory = activeCategory === "all" || book.category_id === Number(activeCategory);
      const matchesAvailability = availability === "all" || Number(book.available_copies) > 0;
      const searchableText = `${book.title} ${authorName} ${book.isbn ?? ""}`.toLocaleLowerCase("vi");
      return matchesCategory && matchesAvailability && searchableText.includes(normalizedQuery);
    });

    return result.sort((left, right) => {
      if (sortBy === "newest") return Number(right.publish_year ?? 0) - Number(left.publish_year ?? 0);
      if (sortBy === "available") return Number(right.available_copies ?? 0) - Number(left.available_copies ?? 0);
      return String(left.title).localeCompare(String(right.title), "vi");
    });
  }, [books, authors, activeCategory, availability, query, sortBy]);

  const hasFilters = query.trim() || activeCategory !== "all" || availability !== "all";
  const availableTitles = books.filter((book) => Number(book.available_copies) > 0).length;

  function clearFilters() {
    setQuery("");
    setActiveCategory("all");
    setAvailability("all");
  }

  return (
    <div className="lh-root">
      <Header />

      <main className="lh-library-page">
        <section className="lh-library-hero">
          <div className="lh-container lh-library-hero__inner">
            <div>
              <p className="lh-eyebrow">Khám phá thư viện</p>
              <h1 className="lh-h1">Tìm cuốn sách tiếp theo của bạn</h1>
              <p className="lh-lede">
                Tìm theo tên, tác giả hoặc ISBN. Mở trang chi tiết để xem thông tin và đăng ký mượn.
              </p>
            </div>
            <div className="lh-library-stats" aria-label="Thống kê kho sách">
              <div><strong>{books.length}</strong><span>Đầu sách</span></div>
              <div><strong>{availableTitles}</strong><span>Đang còn sách</span></div>
            </div>
          </div>
        </section>

        <section className="lh-container lh-library-content">
          <div className="lh-library-toolbar">
            <label className="lh-library-search">
              <Icon name="search" size={19} />
              <input
                value={query}
                onChange={(event) => setQuery(event.target.value)}
                placeholder="Tìm tên sách, tác giả hoặc ISBN..."
                aria-label="Tìm kiếm sách"
              />
              {query && (
                <button type="button" onClick={() => setQuery("")} aria-label="Xóa từ khóa">
                  <Icon name="x" size={16} />
                </button>
              )}
            </label>

            <div className="lh-library-controls">
              <select value={availability} onChange={(event) => setAvailability(event.target.value)} aria-label="Lọc tình trạng sách">
                <option value="all">Tất cả tình trạng</option>
                <option value="available">Còn sách</option>
              </select>
              <select value={sortBy} onChange={(event) => setSortBy(event.target.value)} aria-label="Sắp xếp sách">
                <option value="title">Tên A–Z</option>
                <option value="newest">Mới xuất bản</option>
                <option value="available">Nhiều bản có sẵn</option>
              </select>
            </div>
          </div>

          <div className="lh-library-filters" aria-label="Lọc theo thể loại">
            <button
              type="button"
              className={`lh-library-filter ${activeCategory === "all" ? "is-active" : ""}`}
              onClick={() => setActiveCategory("all")}
            >
              Tất cả <span>{books.length}</span>
            </button>
            {categories.map((category) => {
              const count = books.filter((book) => book.category_id === category.category_id).length;
              return (
                <button
                  type="button"
                  key={category.category_id}
                  className={`lh-library-filter ${Number(activeCategory) === category.category_id ? "is-active" : ""}`}
                  onClick={() => setActiveCategory(category.category_id)}
                >
                  {category.category_name} <span>{count}</span>
                </button>
              );
            })}
          </div>

          <div className="lh-library-results-head">
            <p><strong>{filtered.length}</strong> kết quả</p>
            {hasFilters && <button type="button" onClick={clearFilters}>Xóa bộ lọc</button>}
          </div>

          {loading ? (
            <div className="lh-library-empty"><span className="lh-spinner" /><p>Đang tải kho sách...</p></div>
          ) : error ? (
            <div className="lh-library-empty is-error"><Icon name="alert-circle" size={28} /><p>{error}</p></div>
          ) : filtered.length > 0 ? (
            <div className="lh-books-grid lh-library-grid">
              {filtered.map((book) => <BookCard key={book.book_id} book={book} />)}
            </div>
          ) : (
            <div className="lh-library-empty">
              <Icon name="search" size={30} />
              <h2>Không tìm thấy sách phù hợp</h2>
              <p>Thử từ khóa khác hoặc xóa bớt bộ lọc.</p>
              <button type="button" className="lh-btn lh-btn--ghost" onClick={clearFilters}>Xóa bộ lọc</button>
            </div>
          )}
        </section>
      </main>

      <Footer />
    </div>
  );
}
