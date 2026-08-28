import Icon from "./Icon";
import { useLanguage } from "../i18n/LanguageContext";
import "../styles/Contact.css";

export default function Contact() {
  const { t } = useLanguage();
  return (
    <section className="lh-section lh-section--soft" id="contact">
      <div className="lh-container lh-contact">
        <div className="lh-contact__copy">
          <p className="lh-eyebrow">{t("contact.eyebrow")}</p>
          <h2 className="lh-h2">{t("contact.title")}</h2>
          <p className="lh-lede">{t("contact.description")}</p>
        </div>
        <div className="lh-contact__options">
          <a href="mailto:hotro@libhub.vn"><span><Icon name="mail" size={20} /></span><small>Email</small><strong>hotro@libhub.vn</strong><Icon name="arrow" size={16} /></a>
          <a href="tel:0336037773"><span><Icon name="phone" size={20} /></span><small>{t("contact.phone")}</small><strong>033 6037 773</strong><Icon name="arrow" size={16} /></a>
          <div><span><Icon name="map-pin" size={20} /></span><small>{t("contact.hours")}</small><strong>08:00 — 20:00</strong></div>
        </div>
      </div>
    </section>
  );
}
