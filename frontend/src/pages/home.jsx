import { Link } from 'react-router-dom';
import "../css/home.css";

const genres = ["Văn học", "Kỹ năng sống", "Khoa học", "Kinh tế", "Lịch sử", "Thiếu "];
const featuredCount =  5;

export default function Home() {
    return (
        <div className="home-hero">
            <section className="home-hero-inner">
                <h1 className="home-hero-title">
                    Mỗi cuốn sách <br/>
                    Một thế giới <span className="accent">mới</span>
                </h1>

                <p className="home-hero-desc">
                    Nhập một thế giới mới khi đọc cuốn sách của mình. Khám phá hàng nghìn đầu sách và bắt hành trình đọc sách của bạn ngay hôm nay.
                </p>

                <div className="home-hero-actions">
                    <Link to="/library" className="home-btn-primary">
                        Khám phá thư viện
                    </Link>
                </div>
            </section>

            <section className="home-section">
                <p className="home-section-eyebrow">Thư viện</p>
                <div className="home-section-head-row">
                    <h2 className="home-section-tittle">Thể loại</h2>
                </div>

                <div className="home-block-grid">
                    {genres.map((g) => (
                        <Link key={g} to="/genres" className="home-block" style={{ textDecoration: "none" }}>
                            <span className="home-block-top"/>
                            <span className="home-block-body"/>
                            <span className="home-block-label">{g}</span>
                        </Link>
                    ))}
                </div>
            </section>

            <section className="home-section">
                <p className="home-section-eyebrow">Nổi bật tuần này</p>
                <div className="home-section-head-row">
                    <h2 className="home-section-tittle">Sách nổi bật</h2>
                    <Link to="/featured" className="home-section-link">Xem tất cả →</Link>
                </div>

                <div className="home-empty-grid">
                    {Array.from({ length: featuredCount }).map((_, i) => (
                        <div key={i} className="home-empty-card"/>
                    ))}
                </div>
            </section>
        </div>
    )
}