import { useState } from "react";
import { useNavigate } from "react-router-dom";
import Icon from "./Icon";
import "../styles/Hero.css";

export default function Hero() {
  const navigate = useNavigate();
  const [query, setQuery] = useState("");

  function handleSearch(event) {
    event.preventDefault();
    const keyword = query.trim();
    navigate(keyword ? `/library?q=${encodeURIComponent(keyword)}` : "/library");
  }

  return (
    <section className="lh-hero" id="top">
      <div className="lh-hero__bg" aria-hidden="true" />
      <div className="lh-hero__overlay" aria-hidden="true" />

      <div className="lh-container lh-hero__inner">
        <p className="lh-eyebrow">Thư viện số LibHub</p>
        <h1 className="lh-h1">
          Mượn đúng sách,
          <br />
          đúng lúc bạn cần.
        </h1>
        <p className="lh-lede">
          Tra cứu kho sách, theo dõi phiếu mượn và gia hạn chỉ trong vài giây —
          toàn bộ dữ liệu thư viện của bạn, gọn trong một nơi.
        </p>

        <form className="lh-catalog-search" onSubmit={handleSearch}>
          <Icon name="search" size={18} className="lh-catalog-search__icon" />
          <input
            type="text"
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            placeholder="Tìm theo tên sách, tác giả hoặc ISBN…"
            aria-label="Tìm kiếm sách"
          />
          <button type="submit" className="lh-btn lh-btn--primary">
            Tra cứu
          </button>
        </form>

        <div className="lh-hero__ctas">
          <a href="#featured-books" className="lh-btn lh-btn--ghost">
            Xem sách nổi bật
          </a>
          <a href="#categories" className="lh-btn lh-btn--ghost">
            Duyệt theo thể loại
          </a>
        </div>
      </div>
    </section>
  );
}
