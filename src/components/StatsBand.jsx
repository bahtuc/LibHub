import Icon from "./Icon";
import { libraryStats } from "../data/libraryData";
import "../styles/StatsBand.css";

export default function StatsBand() {
  return (
    <section className="lh-section">
      <div className="lh-container">
        <div className="lh-stats">
          <div className="lh-stats__shelf" aria-hidden="true">
            {Array.from({ length: 10 }).map((_, i) => (
              <span key={i} />
            ))}
          </div>

          <div className="lh-stats__copy">
            <p className="lh-eyebrow lh-eyebrow--light">Vì sao chọn LibHub</p>
            <h2 className="lh-h2" style={{ color: "var(--lh-paper)" }}>
              Một thư viện, mọi phiếu mượn được theo dõi trọn vẹn
            </h2>
            <p className="lh-lede" style={{ color: "rgba(247,242,230,0.72)" }}>
              Từ lúc quét mã sách đến lúc trả về đúng kệ — LibHub ghi lại toàn
              bộ vòng đời của từng cuốn sách trong thư viện của bạn.
            </p>
            <a href="#" className="lh-btn lh-btn--on-dark">
              Tìm hiểu về LibHub <Icon name="arrow" size={16} />
            </a>
          </div>

          <div className="lh-stats__grid">
            {libraryStats.map((s) => (
              <div className="lh-stats__item" key={s.label}>
                <Icon name={s.icon} size={22} />
                <span className="lh-stats__value">{s.value}</span>
                <span className="lh-stats__label">{s.label}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
