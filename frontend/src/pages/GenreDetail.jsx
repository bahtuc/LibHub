import { Link, useParams, useSearchParams } from "react-router-dom";
import Header from "../components/Header";
import Footer from "../components/Footer";
import Icon from "../components/Icon";
import BookCard from "../components/BookCard";
import Pagination from "../components/Pagination";
import { useCatalog } from "../context/CatalogContext";
import "../styles/theme.css";
import "../styles/Library.css";

const BOOKS_PER_PAGE = 12;

export default function GenreDetail() {
  const { categoryId } = useParams();
  const [searchParams, setSearchParams] = useSearchParams();
  const { categories, books, loading } = useCatalog();
  const category = categories.find((item) => item.category_id === Number(categoryId));
  const items = books.filter((item) => item.category_id === Number(categoryId));
  const pageParam = Number.parseInt(searchParams.get("page") ?? "1", 10);
  const requestedPage = Number.isFinite(pageParam) && pageParam > 0 ? pageParam : 1;
  const totalPages = Math.max(1, Math.ceil(items.length / BOOKS_PER_PAGE));
  const currentPage = Math.min(requestedPage, totalPages);
  const pageStart = (currentPage - 1) * BOOKS_PER_PAGE;
  const visibleBooks = items.slice(pageStart, pageStart + BOOKS_PER_PAGE);

  function changePage(page) {
    const next = new URLSearchParams(searchParams);
    if (page === 1) next.delete("page");
    else next.set("page", String(page));
    setSearchParams(next);
    requestAnimationFrame(() => document.getElementById("genre-results")?.scrollIntoView({ behavior: "smooth", block: "start" }));
  }

  return (
    <div className="lh-root">
      <Header />
      <section className="lh-library-hero">
        <div className="lh-container">
          <Link to="/genres" className="lh-link-arrow"><Icon name="arrow" size={14} /> Tất cả thể loại</Link>
          <h1 className="lh-h1">{category?.category_name ?? "Thể loại"}</h1>
          <p className="lh-lede">{items.length} đầu sách · {totalPages} trang</p>
        </div>
      </section>

      <section className="lh-section" id="genre-results">
        <div className="lh-container">
          {loading ? (
            <div className="lh-library-empty"><span className="lh-spinner" /><p>Đang tải sách...</p></div>
          ) : !category ? (
            <div className="lh-library-empty"><Icon name="search" size={28} /><p>Không tìm thấy thể loại.</p></div>
          ) : items.length === 0 ? (
            <div className="lh-library-empty"><Icon name="book-open" size={28} /><p>Thể loại này chưa có sách.</p></div>
          ) : (
            <>
              <div className="lh-library-results-head">
                <p>Trang <strong>{currentPage}</strong> / {totalPages}<span> · Hiển thị {pageStart + 1}–{Math.min(pageStart + BOOKS_PER_PAGE, items.length)}</span></p>
              </div>
              <div className="lh-books-grid">{visibleBooks.map((book) => <BookCard key={book.book_id} book={book} />)}</div>
              <Pagination currentPage={currentPage} totalPages={totalPages} onPageChange={changePage} label={`Các trang sách thuộc thể loại ${category.category_name}`} />
            </>
          )}
        </div>
      </section>
      <Footer />
    </div>
  );
}
