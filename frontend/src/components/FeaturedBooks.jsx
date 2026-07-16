import { Link } from "react-router-dom";
import Icon from "./Icon";
import BookCard from "./BookCard";
import { useCatalog } from "../context/CatalogContext";
export default function FeaturedBooks() {
  const { books, loading, error } = useCatalog();
  return <section className="lh-section" id="featured-books"><div className="lh-container"><div className="lh-section-head"><div><p className="lh-eyebrow">Kho sách</p><h2 className="lh-h2">Sách nổi bật</h2></div><Link to="/library" className="lh-link-arrow">Xem tất cả sách <Icon name="arrow" size={16} /></Link></div>{loading ? <p>Đang tải sách...</p> : error ? <p>{error}</p> : <div className="lh-books-grid">{books.slice(0, 6).map((book) => <BookCard key={book.book_id} book={book} />)}</div>}</div></section>;
}
