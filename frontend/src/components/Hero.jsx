import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { motion, useReducedMotion } from "motion/react";
import Icon from "./Icon";
import { useCatalog } from "../context/CatalogContext";
import { useLanguage } from "../i18n/LanguageContext";
import "../styles/Hero.css";

export default function Hero() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const reduceMotion = useReducedMotion();
  const { books, categories } = useCatalog();
  const [query, setQuery] = useState("");
  const available = books.filter((book) => Number(book.available_copies) > 0).length;

  function handleSearch(event) {
    event.preventDefault();
    const keyword = query.trim();
    navigate(keyword ? `/library?q=${encodeURIComponent(keyword)}` : "/library");
  }

  const reveal = reduceMotion ? {} : { initial: { opacity: 0, y: 18 }, animate: { opacity: 1, y: 0 } };

  return (
    <section className="lh-hero" id="top">
      <div className="lh-container lh-hero__inner">
        <motion.div className="lh-hero__copy" {...reveal} transition={{ duration: 0.55, ease: "easeOut" }}>
          <p className="lh-eyebrow"><span /> {t("hero.eyebrow")}</p>
          <h1 className="lh-h1">{t("hero.title1")}<br /><em>{t("hero.title2")}</em></h1>
          <p className="lh-lede">{t("hero.description")}</p>
          <form className="lh-catalog-search" onSubmit={handleSearch}>
            <Icon name="search" size={19} className="lh-catalog-search__icon" />
            <input type="search" value={query} onChange={(event) => setQuery(event.target.value)} placeholder={t("hero.searchPlaceholder")} aria-label={t("nav.search")} />
            <button type="submit" className="lh-btn lh-btn--primary">{t("hero.explore")}</button>
          </form>
          <div className="lh-hero__ctas">
            <Link to="/library">{t("hero.viewAll")} <Icon name="arrow" size={15} /></Link>
            <span>{available} {t("hero.available")}</span>
          </div>
        </motion.div>

        <motion.div className="lh-hero__visual" aria-hidden="true" initial={reduceMotion ? false : { opacity: 0, y: 24 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.7, delay: 0.1 }}>
          <div className="lh-hero__issue">PHÒNG ĐỌC / 2026</div>
          <div className="lh-hero__shelf">
            <span className="lh-spine lh-spine--one">VĂN HỌC</span>
            <span className="lh-spine lh-spine--two">LỊCH SỬ</span>
            <span className="lh-spine lh-spine--three">KHOA HỌC</span>
            <span className="lh-spine lh-spine--four">TRIẾT HỌC</span>
            <span className="lh-spine lh-spine--five">NGHỆ THUẬT</span>
          </div>
          <blockquote>“Một thư viện tốt không chỉ lưu giữ sách. Nó lưu giữ những khả năng.”</blockquote>
          <div className="lh-hero__visual-meta">
            <strong>{books.length || "—"}</strong><span>{t("hero.books")}</span>
            <strong>{categories.length || "—"}</strong><span>{t("hero.genres")}</span>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
