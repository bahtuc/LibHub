import { Link } from "react-router-dom";
import Icon from "./Icon";
import { useCatalog } from "../context/CatalogContext";
import { useLanguage } from "../i18n/LanguageContext";
import "../styles/StatsBand.css";

export default function StatsBand() {
  const { books, categories, authors } = useCatalog();
  const { t } = useLanguage();
  const availableCopies = books.reduce((sum, book) => sum + Number(book.available_copies || 0), 0);
  const stats = [
    { value: books.length, label: t("stats.titles") },
    { value: availableCopies, label: t("stats.copies") },
    { value: authors.length, label: t("stats.authors") },
    { value: categories.length, label: t("stats.genres") },
  ];

  return (
    <section className="lh-section">
      <div className="lh-container">
        <div className="lh-stats">
          <div className="lh-stats__copy">
            <p className="lh-eyebrow">{t("stats.eyebrow")}</p>
            <h2 className="lh-h2">{t("stats.title1")}<br />{t("stats.title2")}</h2>
            <p>{t("stats.description")}</p>
            <Link to="/library" className="lh-btn lh-btn--light">{t("stats.start")} <Icon name="arrow" size={16} /></Link>
          </div>
          <div className="lh-stats__grid">
            {stats.map((stat) => <div className="lh-stats__item" key={stat.label}><strong>{stat.value || "—"}</strong><span>{stat.label}</span></div>)}
          </div>
        </div>
      </div>
    </section>
  );
}
