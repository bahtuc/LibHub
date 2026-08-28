import { useEffect, useMemo, useState } from "react";
import { useSearchParams } from "react-router-dom";

import Header from "../components/Header";
import Footer from "../components/Footer";
import Icon from "../components/Icon";
import BookCard from "../components/BookCard";
import Pagination from "../components/Pagination";
import { useCatalog } from "../context/CatalogContext";
import { useLanguage } from "../i18n/LanguageContext";

import "../styles/theme.css";
import "../styles/Library.css";

const BOOKS_PER_PAGE = 12;

export default function Library() {
  const { books, categories, authors, loading, error } = useCatalog();
  const { language, t } = useLanguage();
  const [searchParams, setSearchParams] = useSearchParams();
  const [activeCategory, setActiveCategory] = useState("all");
  const [query, setQuery] = useState(() => searchParams.get("q") ?? "");
  const [availability, setAvailability] = useState("all");
  const [sortBy, setSortBy] = useState("title");

  useEffect(() => {
    setQuery(searchParams.get("q") ?? "");
  }, [searchParams]);

  const filtered = useMemo(() => {
    const normalizedQuery = query.trim().toLocaleLowerCase(language);
    const result = books.filter((book) => {
      const authorName = authors.find((author) => author.author_id === book.author_id)?.author_name ?? "";
      const matchesCategory = activeCategory === "all" || book.category_id === Number(activeCategory);
      const matchesAvailability = availability === "all" || Number(book.available_copies) > 0;
      const searchableText = `${book.title} ${authorName} ${book.isbn ?? ""}`.toLocaleLowerCase(language);
      return matchesCategory && matchesAvailability && searchableText.includes(normalizedQuery);
    });

    return result.sort((left, right) => {
      if (sortBy === "newest") return Number(right.publish_year ?? 0) - Number(left.publish_year ?? 0);
      if (sortBy === "available") return Number(right.available_copies ?? 0) - Number(left.available_copies ?? 0);
      return String(left.title).localeCompare(String(right.title), language);
    });
  }, [books, authors, activeCategory, availability, query, sortBy, language]);

  const hasFilters = query.trim() || activeCategory !== "all" || availability !== "all";
  const availableTitles = books.filter((book) => Number(book.available_copies) > 0).length;
  const pageParam = Number.parseInt(searchParams.get("page") ?? "1", 10);
  const requestedPage = Number.isFinite(pageParam) && pageParam > 0 ? pageParam : 1;
  const totalPages = Math.max(1, Math.ceil(filtered.length / BOOKS_PER_PAGE));
  const currentPage = Math.min(requestedPage, totalPages);
  const pageStart = (currentPage - 1) * BOOKS_PER_PAGE;
  const visibleBooks = filtered.slice(pageStart, pageStart + BOOKS_PER_PAGE);

  function resetPage() {
    const next = new URLSearchParams(searchParams);
    next.delete("page");
    setSearchParams(next, { replace: true });
  }

  function updateQuery(value) {
    setQuery(value);
    const next = new URLSearchParams(searchParams);
    if (value.trim()) next.set("q", value);
    else next.delete("q");
    next.delete("page");
    setSearchParams(next, { replace: true });
  }

  function changePage(page) {
    const next = new URLSearchParams(searchParams);
    if (page === 1) next.delete("page");
    else next.set("page", String(page));
    setSearchParams(next);
    requestAnimationFrame(() => document.getElementById("library-results")?.scrollIntoView({ behavior: "smooth", block: "start" }));
  }

  function clearFilters() {
    setQuery("");
    setSearchParams({});
    setActiveCategory("all");
    setAvailability("all");
  }

  return (
    <div className="lh-root">
      <Header />

      <main className="lh-library-page">
        <section className="lh-library-hero">
          <div className="lh-container lh-library-hero__inner">
            <div>
              <p className="lh-eyebrow">{t("library.eyebrow")}</p>
              <h1 className="lh-h1">{t("library.title")}</h1>
              <p className="lh-lede">{t("library.description")}</p>
            </div>
            <div className="lh-library-stats" aria-label={t("library.statsLabel")}>
              <div><strong>{books.length}</strong><span>{t("library.titles")}</span></div>
              <div><strong>{availableTitles}</strong><span>{t("library.available")}</span></div>
            </div>
          </div>
        </section>

        <section className="lh-container lh-library-content">
          <div className="lh-library-toolbar">
            <label className="lh-library-search">
              <Icon name="search" size={19} />
              <input
                value={query}
                onChange={(event) => updateQuery(event.target.value)}
                placeholder={t("library.searchPlaceholder")}
                aria-label={t("nav.search")}
              />
              {query && (
                <button type="button" onClick={() => updateQuery("")} aria-label={t("library.clearKeyword")}>
                  <Icon name="x" size={16} />
                </button>
              )}
            </label>

            <div className="lh-library-controls">
              <select value={availability} onChange={(event) => { setAvailability(event.target.value); resetPage(); }} aria-label="Lọc tình trạng sách">
                <option value="all">{t("library.allStatuses")}</option>
                <option value="available">{t("library.inStock")}</option>
              </select>
              <select value={sortBy} onChange={(event) => { setSortBy(event.target.value); resetPage(); }} aria-label="Sắp xếp sách">
                <option value="title">{t("library.sortTitle")}</option>
                <option value="newest">{t("library.sortNewest")}</option>
                <option value="available">{t("library.sortAvailable")}</option>
              </select>
            </div>
          </div>

          <div className="lh-library-filters" aria-label="Lọc theo thể loại">
            <button
              type="button"
              className={`lh-library-filter ${activeCategory === "all" ? "is-active" : ""}`}
              onClick={() => { setActiveCategory("all"); resetPage(); }}
            >
              {t("library.all")} <span>{books.length}</span>
            </button>
            {categories.map((category) => {
              const count = books.filter((book) => book.category_id === category.category_id).length;
              return (
                <button
                  type="button"
                  key={category.category_id}
                  className={`lh-library-filter ${Number(activeCategory) === category.category_id ? "is-active" : ""}`}
                  onClick={() => { setActiveCategory(category.category_id); resetPage(); }}
                >
                  {category.category_name} <span>{count}</span>
                </button>
              );
            })}
          </div>

          <div className="lh-library-results-head" id="library-results">
            <p><strong>{filtered.length}</strong> {t("library.results")}{filtered.length > 0 && <span> · {t("library.showing", { from: pageStart + 1, to: Math.min(pageStart + BOOKS_PER_PAGE, filtered.length) })}</span>}</p>
            {hasFilters && <button type="button" onClick={clearFilters}>{t("library.clearFilters")}</button>}
          </div>

          {loading ? (
            <div className="lh-library-empty"><span className="lh-spinner" /><p>{t("library.loading")}</p></div>
          ) : error ? (
            <div className="lh-library-empty is-error"><Icon name="alert-circle" size={28} /><p>{error}</p></div>
          ) : filtered.length > 0 ? (
            <>
              <div className="lh-books-grid lh-library-grid">
                {visibleBooks.map((book) => <BookCard key={book.book_id} book={book} />)}
              </div>
              <Pagination currentPage={currentPage} totalPages={totalPages} onPageChange={changePage} />
            </>
          ) : (
            <div className="lh-library-empty">
              <Icon name="search" size={30} />
              <h2>{t("library.emptyTitle")}</h2>
              <p>{t("library.emptyText")}</p>
              <button type="button" className="lh-btn lh-btn--ghost" onClick={clearFilters}>{t("library.clearFilters")}</button>
            </div>
          )}
        </section>
      </main>

      <Footer />
    </div>
  );
}
