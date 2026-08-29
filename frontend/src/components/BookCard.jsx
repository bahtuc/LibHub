import { Link } from "react-router-dom";
import { motion, useReducedMotion } from "motion/react";
import Icon from "./Icon";
import { useCatalog } from "../context/CatalogContext";
import { useLanguage } from "../i18n/LanguageContext";
import "../styles/BookCard.css";

export default function BookCard({ book }) {
  const { categories, authors } = useCatalog();
  const { t, translateCategory } = useLanguage();
  const reduceMotion = useReducedMotion();
  const category = categories.find((item) => item.category_id === book.category_id);
  const authorName = authors.find((item) => item.author_id === book.author_id)?.author_name ?? t("book.unknownAuthor");
  const availableCopies = Number(book.available_copies ?? 0);
  const available = availableCopies > 0 || String(book.status).toLowerCase() === "available";

  return (
    <motion.article className="lh-book-card" whileHover={reduceMotion ? undefined : { y: -7 }} transition={{ duration: 0.2 }}>
      <Link to={`/books/${book.book_id}`} className="lh-book-card__cover" aria-label={t("book.viewDetails", { title: book.title })}>
        <span className="lh-book-card__number">#{String(book.book_id).padStart(3, "0")}</span>
        {book.cover_image
          ? <img src={book.cover_image} alt="" className="lh-book-card__img" loading="lazy" />
          : <span className="lh-book-card__fallback" style={{ "--accent": category?.color ?? "#3758f9" }}><small>LIBHUB EDITION</small><strong>{book.title}</strong><em>{authorName}</em></span>}
        <span className={`lh-book-card__status ${available ? "is-available" : "is-borrowed"}`}>{available ? t("book.availableCopies", { count: availableCopies || 1 }) : t("book.borrowed")}</span>
      </Link>
      <div className="lh-book-card__body">
        <span className="lh-book-card__tag">{category ? translateCategory(category.category_name) : t("book.unclassified")}</span>
        <h3 className="lh-book-card__title"><Link to={`/books/${book.book_id}`}>{book.title}</Link></h3>
        <p className="lh-book-card__meta">{authorName}<span>{book.publish_year || "—"}</span></p>
        <Link to={`/books/${book.book_id}`} className="lh-book-card__link" aria-label={t("book.open", { title: book.title })}><Icon name="arrow" size={16} /></Link>
      </div>
    </motion.article>
  );
}
