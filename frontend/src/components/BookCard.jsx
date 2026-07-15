// src/components/BookCard.jsx
// Card sách dùng chung cho Home / Library / Genres.
// Bìa có tỉ lệ dọc (2:3) như 1 quyển sách thật. Nếu book_id có ảnh trong
// localStorage (xem src/data/useBookCovers.js) thì hiện ảnh đó, không thì
// fallback về khối gradient màu theo thể loại + chữ cái đầu tên sách.

import { Link } from "react-router-dom";
import Icon from "./Icon";
import { getAuthorName, getCategory } from "../data/libraryData";
import { useBookCovers } from "../data/useBookCovers";
import "../styles/BookCard.css";

export default function BookCard({ book }) {
  const covers = useBookCovers();
  const category = getCategory(book.category_id);
  const available = book.status === "available";
  const coverUrl = covers[book.book_id] || book.cover_image;

  return (
    <article className="lh-book-card">
      <div
        className="lh-book-card__cover"
        style={{ "--spine": category?.color ?? "#3d6652" }}
      >
        {coverUrl ? (
          <img src={coverUrl} alt={book.title} className="lh-book-card__img" />
        ) : (
          <span className="lh-book-card__initial">{book.title.charAt(0)}</span>
        )}
        <span className={`lh-book-card__status ${available ? "is-available" : "is-borrowed"}`}>
          {available ? "Còn sách" : "Đã mượn hết"}
        </span>
      </div>

      <div className="lh-book-card__body">
        <span
          className="lh-book-card__tag"
          style={{ color: category?.color, borderColor: category?.color }}
        >
          {category?.category_name}
        </span>
        <h3 className="lh-book-card__title">{book.title}</h3>
        <p className="lh-book-card__meta">
          {getAuthorName(book.author_id)} · {book.publish_year}
        </p>
        <Link to={`/books/${book.book_id}`} className="lh-link-arrow lh-book-card__link">
          Xem chi tiết <Icon name="arrow" size={14} />
        </Link>
      </div>
    </article>
  );
}
