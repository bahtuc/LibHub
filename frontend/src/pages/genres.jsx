// src/pages/Genres.jsx
import { Link } from "react-router-dom";
import Header from "../components/Header";
import Footer from "../components/Footer";
import Icon from "../components/Icon";
import { categories, getBookCountByCategory } from "../data/libraryData";
import "../styles/theme.css";
import "../styles/Genres.css";

export default function Genres() {
  return (
    <div className="lh-root">
      <Header />

      <section className="lh-library-hero">
        <div className="lh-container">
          <p className="lh-eyebrow">Duyệt kệ sách</p>
          <h1 className="lh-h1" style={{ fontSize: "clamp(2rem, 3.4vw, 2.8rem)" }}>
            Thể loại
          </h1>
          <p className="lh-lede">Chọn 1 thể loại để xem toàn bộ sách thuộc thể loại đó.</p>
        </div>
      </section>

      <section className="lh-section" style={{ paddingTop: 28 }}>
        <div className="lh-container">
          <div className="lh-genres-grid">
            {categories.map((cat) => (
              <Link to={`/genres/${cat.category_id}`} className="lh-genre-card" key={cat.category_id}>
                <span className="lh-genre-card__icon" style={{ background: cat.color }}>
                  <Icon name={cat.icon} size={26} />
                </span>
                <span className="lh-genre-card__name">{cat.category_name}</span>
                <span className="lh-genre-card__count">
                  {getBookCountByCategory(cat.category_id)} đầu sách
                </span>
                <span className="lh-genre-card__go">
                  Xem sách <Icon name="arrow" size={14} />
                </span>
              </Link>
            ))}
          </div>
        </div>
      </section>

      <Footer />
    </div>
  );
}
