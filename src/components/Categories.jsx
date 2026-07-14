import { Link } from "react-router-dom";
import Icon from "./Icon";
import { categories } from "../data/libraryData";
import "../styles/Categories.css";

export default function Categories() {
  return (
    <section className="lh-section lh-section--soft" id="categories">
      <div className="lh-container">
        <div className="lh-section-head">
          <div>
            <p className="lh-eyebrow">Duyệt kệ sách</p>
            <h2 className="lh-h2">Tìm theo thể loại</h2>
          </div>
          <Link to="/genres" className="lh-link-arrow">
            Xem tất cả thể loại <Icon name="arrow" size={16} />
          </Link>
        </div>

        <div className="lh-cat__grid">
          {categories.map((cat) => (
            <Link to={`/genres/${cat.category_id}`} className="lh-cat__card" key={cat.category_id}>
              <span className="lh-cat__icon" style={{ background: cat.color }}>
                <Icon name={cat.icon} size={18} />
              </span>
              <span className="lh-cat__name">{cat.category_name}</span>
              <Icon name="arrow" size={15} className="lh-cat__arrow" />
            </Link>
          ))}
        </div>
      </div>
    </section>
  );
}
