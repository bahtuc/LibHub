import { Link } from "react-router-dom";
import Icon from "./Icon";
import { useLanguage } from "../i18n/LanguageContext";
import "../styles/QuickAccess.css";

const ITEMS = [
  { index: "01", icon: "search", title: "quick.search.title", desc: "quick.search.desc", to: "/library" },
  { index: "02", icon: "compass", title: "quick.genres.title", desc: "quick.genres.desc", to: "/genres" },
  { index: "03", icon: "layers", title: "quick.loans.title", desc: "quick.loans.desc", to: "/account" },
  { index: "04", icon: "landmark", title: "quick.fines.title", desc: "quick.fines.desc", to: "/fines" },
];

export default function QuickAccess() {
  const { t } = useLanguage();
  return (
    <section className="lh-quick" aria-label={t("quick.label")}>
      <div className="lh-container lh-quick__grid">
        {ITEMS.map((item) => (
          <Link key={item.title} to={item.to} className="lh-quick__card">
            <span className="lh-quick__index">{item.index}</span>
            <span className="lh-quick__icon"><Icon name={item.icon} size={20} /></span>
            <span className="lh-quick__text"><strong>{t(item.title)}</strong><small>{t(item.desc)}</small></span>
            <Icon name="arrow" size={16} className="lh-quick__arrow" />
          </Link>
        ))}
      </div>
    </section>
  );
}
