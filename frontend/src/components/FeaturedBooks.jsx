import { Link } from "react-router-dom";
import Icon from "./Icon";
import BookCard from "./BookCard";
import { useCatalog } from "../context/CatalogContext";
import { useLanguage } from "../i18n/LanguageContext";

export default function FeaturedBooks() {
  const { books, loading, error } = useCatalog();
  const { t } = useLanguage();
  const featuredBooks = books.filter((book) => book.is_featured).slice(0, 4);
  return (
    <section className="lh-section" id="featured-books">
      <div className="lh-container">
        <div className="lh-section-head">
          <div><p className="lh-eyebrow">{t("featured.eyebrow")}</p><h2 className="lh-h2">{t("featured.title")}</h2></div>
          <Link to="/library" className="lh-link-arrow">{t("common.viewAll")} <Icon name="arrow" size={16} /></Link>
        </div>
        {loading ? (
          <div className="lh-books-grid" aria-label={t("common.loadingBooks")}>{Array.from({ length: 4 }).map((_, index) => <div className="lh-book-skeleton" key={index} />)}</div>
        ) : error ? (
          <div className="lh-state-card"><Icon name="book-open" size={24} /><p>{error}</p></div>
        ) : featuredBooks.length === 0 ? (
          <div className="lh-state-card"><Icon name="star" size={24} /><p>Chưa có sách nổi bật.</p></div>
        ) : (
          <div className="lh-books-grid">{featuredBooks.map((book) => <BookCard key={book.book_id} book={book} />)}</div>
        )}
      </div>
    </section>
  );
}
