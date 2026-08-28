import { Link } from "react-router-dom";
import Header from "../components/Header";
import Footer from "../components/Footer";
import Icon from "../components/Icon";

export default function NotFound() {
  return (
    <div className="lh-root">
      <Header />
      <main className="lh-not-found">
        <div className="lh-not-found__number">404</div>
        <p className="lh-eyebrow">Trang không tồn tại</p>
        <h1>Chiếc kệ này đang trống.</h1>
        <p>Đường dẫn có thể đã thay đổi. Hãy quay về kho sách để tiếp tục khám phá.</p>
        <Link to="/library" className="lh-btn lh-btn--primary">Về kho sách <Icon name="arrow" size={16} /></Link>
      </main>
      <Footer />
    </div>
  );
}
