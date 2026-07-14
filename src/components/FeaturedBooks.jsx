import { Link } from "react-router-dom";
import Icon from "./Icon";
import BookCard from "./BookCard";
import { booksStore } from "../data/adminStore";

export default function FeaturedBooks() {
  // Đọc từ booksStore (chung với Admin/Thủ thư) để sách bị ẩn hoặc vừa thêm
  // luôn khớp với những gì hiển thị công khai ở đây.
  const books = booksStore.useCollection();
  const featured = books.filter((b) => b.is_featured && !b.is_hidden);

  return (
    <section className="lh-section" id="featured-books">
      <div className="lh-container">
        <div className="lh-section-head">
          <div>
            <p className="lh-eyebrow">Kho sách</p>
            <h2 className="lh-h2">Sách nổi bật</h2>
          </div>
          <Link to="/library" className="lh-link-arrow">
            Xem tất cả sách <Icon name="arrow" size={16} />
          </Link>
        </div>

        <div className="lh-books-grid">
          {featured.map((book) => (
            <BookCard key={book.book_id} book={book} />
          ))}
        </div>
      </div>
    </section>
  );
}
