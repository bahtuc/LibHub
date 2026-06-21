import { Link } from "react-router-dom";
import "../css/home.css";

const genres = ["Văn học", "Kỹ năng sống", "Khoa học", "Lịch sử", "Thiếu nhi"];
const featuredCount = 5;

export default function Home() {
    return (
        <div className="home">
            <section className="home_hero">
                <div className="home_hero_inner">
                    <p className="home_hero_eyebrow">LibHub · Thư viện số</p>
                    <h1 className="home_hero_title">
                        Mỗi cuốn sách
                        <br />
                        Một thế giới <span className="accent">mới</span>
                    </h1>
                    <p className="home_hero_desc">
                        Nhập một thế giới mới khi đọc cuốn sách của mình. Khám phá hàng
                        nghìn đầu sách và bắt đầu hành trình đọc của bạn ngay hôm nay.
                    </p>
                    <div className="home_hero_actions">
                        <Link to="/library" className="home_btn_primary">
                            Khám phá thư viện
                        </Link>
                        <Link to="/register" className="home_btn_secondary">
                            Tạo thẻ thư viện
                        </Link>
                    </div>
                </div>
            </section>

            <section className="home_section">
                <p className="home_section_eyebrow">Thư viện</p>
                <div className="home_section_head_row">
                    <h2 className="home_section_title">Thể loại</h2>
                </div>
                <div className="home_block_grid">
                    {genres.map((g) => (
                        <Link key={g} to="/genres" className="home_block">
                            <span className="home_block_top" />
                            <span className="home_block_body" />
                            <span className="home_block_label">{g}</span>
                        </Link>
                    ))}
                </div>
            </section>

            <section className="home_section">
                <p className="home_section_eyebrow">Nổi bật tuần này</p>
                <div className="home_section_head_row">
                    <h2 className="home_section_title">Sách nổi bật</h2>
                    <Link to="/featured" className="home_section_link">Xem tất cả →</Link>
                </div>
                <div className="home_empty_grid">
                    {Array.from({ length: featuredCount }).map((_, i) => (
                        <div key={i} className="home_empty_card" />
                    ))}
                </div>
            </section>
        </div>
    );
}