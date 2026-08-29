import { Link, useParams, useSearchParams } from "react-router-dom";
import Header from "../components/Header";
import Footer from "../components/Footer";
import Icon from "../components/Icon";
import BookCard from "../components/BookCard";
import Pagination from "../components/Pagination";
import { useCatalog } from "../context/CatalogContext";
import { useLanguage } from "../i18n/LanguageContext";
import "../styles/theme.css";
import "../styles/Library.css";

const BOOKS_PER_PAGE = 12;

export default function GenreDetail() {
  const { categoryId } = useParams();
  const [searchParams, setSearchParams] = useSearchParams();
  const { categories, books, loading } = useCatalog();
  const { t, translateCategory } = useLanguage();
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
          <Link to="/genres" className="lh-link-arrow"><Icon name="arrow" size={14} /> {t("genres.all")}</Link>
          <h1 className="lh-h1">{category ? translateCategory(category.category_name) : t("genres.title")}</h1>
          <p className="lh-lede">{t("genres.summary", { count: items.length, pages: totalPages })}</p>
        </div>
      </section>

      <section className="lh-section" id="genre-results">
        <div className="lh-container">
          {loading ? (
            <div className="lh-library-empty"><span className="lh-spinner" /><p>{t("library.loading")}</p></div>
          ) : !category ? (
            <div className="lh-library-empty"><Icon name="search" size={28} /><p>{t("genres.notFound")}</p></div>
          ) : items.length === 0 ? (
            <div className="lh-library-empty"><Icon name="book-open" size={28} /><p>{t("genres.empty")}</p></div>
          ) : (
            <>
              <div className="lh-library-results-head">
                <p>{t("genres.page", { current: currentPage, total: totalPages })}<span> · {t("genres.showing", { from: pageStart + 1, to: Math.min(pageStart + BOOKS_PER_PAGE, items.length) })}</span></p>
              </div>
              <div className="lh-books-grid">{visibleBooks.map((book) => <BookCard key={book.book_id} book={book} />)}</div>
              <Pagination currentPage={currentPage} totalPages={totalPages} onPageChange={changePage} label={t("genres.pagination", { name: translateCategory(category.category_name) })} />
            </>
          )}
        </div>
      </section>
      <Footer />
    </div>
  );
}
