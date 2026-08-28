import Icon from "./Icon";
import { useLanguage } from "../i18n/LanguageContext";

function pageItems(currentPage, totalPages) {
  if (totalPages <= 7) return Array.from({ length: totalPages }, (_, index) => index + 1);

  const visible = new Set([1, totalPages, currentPage - 1, currentPage, currentPage + 1]);
  const pages = [...visible]
    .filter((page) => page >= 1 && page <= totalPages)
    .sort((left, right) => left - right);
  const result = [];

  pages.forEach((page, index) => {
    const previous = pages[index - 1];
    if (previous && page - previous > 1) result.push(`gap-${previous}`);
    result.push(page);
  });
  return result;
}

export default function Pagination({ currentPage, totalPages, onPageChange, label }) {
  const { t } = useLanguage();
  if (totalPages <= 1) return null;

  const goTo = (page) => {
    if (page >= 1 && page <= totalPages && page !== currentPage) onPageChange(page);
  };

  return (
    <nav className="lh-pagination" aria-label={label || t("pagination.label")}>
      <button type="button" className="lh-pagination__direction" disabled={currentPage === 1} onClick={() => goTo(currentPage - 1)} aria-label={t("pagination.previous")}>
        <Icon name="arrow" size={16} />
        <span>{t("pagination.previous")}</span>
      </button>

      <div className="lh-pagination__pages">
        {pageItems(currentPage, totalPages).map((item) => typeof item === "number" ? (
          <button type="button" key={item} className={item === currentPage ? "is-active" : ""} aria-current={item === currentPage ? "page" : undefined} onClick={() => goTo(item)}>
            {item}
          </button>
        ) : <span key={item} aria-hidden="true">…</span>)}
      </div>

      <button type="button" className="lh-pagination__direction" disabled={currentPage === totalPages} onClick={() => goTo(currentPage + 1)} aria-label={t("pagination.next")}>
        <span>{t("pagination.next")}</span>
        <Icon name="arrow" size={16} />
      </button>
    </nav>
  );
}
