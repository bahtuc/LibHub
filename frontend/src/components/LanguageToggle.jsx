import { useLanguage } from "../i18n/LanguageContext";

export default function LanguageToggle({ className = "" }) {
  const { language, setLanguage, t } = useLanguage();
  return (
    <div className={`lh-language ${className}`.trim()} role="group" aria-label={t("language.label")}>
      {[
        ["vi", "VI"],
        ["en", "EN"],
      ].map(([value, label]) => (
        <button
          type="button"
          key={value}
          className={language === value ? "is-active" : ""}
          aria-pressed={language === value}
          onClick={() => setLanguage(value)}
        >
          {label}
        </button>
      ))}
    </div>
  );
}
