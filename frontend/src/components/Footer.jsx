import { Link } from "react-router-dom";
import Icon from "./Icon";
import { useLanguage } from "../i18n/LanguageContext";
import "../styles/Footer.css";

export default function Footer() {
  const { t } = useLanguage();
  return (
    <footer className="lh-footer">
      <div className="lh-container lh-footer__top">
        <div className="lh-footer__brand">
          <Link to="/" className="lh-brand lh-brand--on-dark"><span className="lh-brand__mark"><Icon name="book-open" size={19} /></span><span className="lh-brand__text">LIBHUB<small>{t("brand.subtitle")}</small></span></Link>
          <p>{t("footer.description")}</p>
        </div>
        <div className="lh-footer__col"><h4>{t("footer.explore")}</h4><Link to="/library">{t("nav.library")}</Link><Link to="/genres">{t("nav.genres")}</Link><Link to="/account">{t("nav.account")}</Link></div>
        <div className="lh-footer__col"><h4>{t("footer.services")}</h4><Link to="/account">{t("footer.loans")}</Link><Link to="/fines">{t("footer.fines")}</Link><a href="/#contact">{t("footer.contact")}</a></div>
        <div className="lh-footer__note"><span>LIBHUB</span><strong>READ<br />BEYOND<br />THE SHELF</strong></div>
      </div>
      <div className="lh-container lh-footer__bottom"><span>© 2026 LibHub</span><span>{t("footer.location")}</span></div>
    </footer>
  );
}
