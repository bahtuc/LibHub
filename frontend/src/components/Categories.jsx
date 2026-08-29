import { Link } from "react-router-dom";
import Icon from "./Icon";
import { useCatalog } from "../context/CatalogContext";
import { useLanguage } from "../i18n/LanguageContext";
import "../styles/Categories.css";

export default function Categories() {
  const { categories, books } = useCatalog();
  const { t, translateCategory } = useLanguage();
  return (
    <section className="lh-section lh-section--soft" id="categories">
      <div className="lh-container">
        <div className="lh-section-head">
          <div><p className="lh-eyebrow">{t("categories.eyebrow")}</p><h2 className="lh-h2">{t("categories.title")}</h2></div>
          <Link to="/genres" className="lh-link-arrow">{t("categories.all")} <Icon name="arrow" size={16} /></Link>
        </div>
        <div className="lh-cat__grid">
          {categories.slice(0, 8).map((category, index) => {
            const count = books.filter((book) => book.category_id === category.category_id).length;
            return (
              <Link to={`/genres/${category.category_id}`} className="lh-cat__card" key={category.category_id}>
                <span className="lh-cat__index">{String(index + 1).padStart(2, "0")}</span>
                <span className="lh-cat__name">{translateCategory(category.category_name)}</span>
                <span className="lh-cat__count">{t("categories.bookCount", { count })}</span>
                <Icon name="arrow" size={17} className="lh-cat__arrow" />
              </Link>
            );
          })}
        </div>
      </div>
    </section>
  );
}
