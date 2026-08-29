import { Link } from "react-router-dom";
import Header from "../components/Header";
import Footer from "../components/Footer";
import Icon from "../components/Icon";
import { useLanguage } from "../i18n/LanguageContext";

export default function NotFound() {
  const { t } = useLanguage();
  return (
    <div className="lh-root">
      <Header />
      <main className="lh-not-found">
        <div className="lh-not-found__number">404</div>
        <p className="lh-eyebrow">{t("notFound.eyebrow")}</p>
        <h1>{t("notFound.title")}</h1>
        <p>{t("notFound.description")}</p>
        <Link to="/library" className="lh-btn lh-btn--primary">{t("notFound.action")} <Icon name="arrow" size={16} /></Link>
      </main>
      <Footer />
    </div>
  );
}
