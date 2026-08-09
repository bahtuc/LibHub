import { Link } from "react-router-dom";
import Icon from "./Icon";
import { useCatalog } from "../context/CatalogContext";
import "../styles/BookCard.css";

export default function BookCard({ book }) {
  const { categories, authors } = useCatalog();
  const category = categories.find((item) => item.category_id === book.category_id);
  const authorName = authors.find((item) => item.author_id === book.author_id)?.author_name ?? "Unknown author";
  const available = book.status === "available";
  const coverUrl = book.cover_image;
  return <article className="lh-book-card">
    <Link to={`/books/${book.book_id}`} className="lh-book-card__cover" style={{ "--spine": category?.color ?? "#3d6652" }} aria-label={`Xem chi tiết ${book.title}`}>
      {coverUrl ? <img src={coverUrl} alt={book.title} className="lh-book-card__img" /> : <span className="lh-book-card__initial">{book.title.charAt(0)}</span>}
      <span className={`lh-book-card__status ${available ? "is-available" : "is-borrowed"}`}>{available ? "Còn sách" : "Đã mượn hết"}</span>
    </Link>
    <div className="lh-book-card__body">
      <span className="lh-book-card__tag" style={{ color: category?.color, borderColor: category?.color }}>{category?.category_name}</span>
      <h3 className="lh-book-card__title"><Link to={`/books/${book.book_id}`}>{book.title}</Link></h3>
      <p className="lh-book-card__meta">{authorName} · {book.publish_year}</p>
      <p className="lh-book-card__copies">{available ? `${book.available_copies} bản có sẵn` : "Bạn có thể xem chi tiết và quay lại sau"}</p>
      <Link to={`/books/${book.book_id}`} className="lh-link-arrow lh-book-card__link">Xem chi tiết <Icon name="arrow" size={14} /></Link>
    </div>
  </article>;
}
