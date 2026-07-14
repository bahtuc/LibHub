import Icon from "./Icon";
import "../styles/Footer.css";

export default function Footer() {
  return (
    <footer className="lh-footer">
      <div className="lh-container lh-footer__top">
        <div className="lh-footer__brand">
          <a href="#top" className="lh-brand lh-brand--on-dark">
            <span className="lh-brand__mark lh-brand__mark--gold">
              <Icon name="book-open" size={20} />
            </span>
            <span className="lh-brand__text">
              Lib<strong>Hub</strong>
            </span>
          </a>
          <p>
            Hệ thống quản lý thư viện số — quản lý đầu sách, phiếu mượn và
            thành viên trong một nền tảng duy nhất.
          </p>
          <div className="lh-footer__social">
            <a href="#" aria-label="Facebook">
              <Icon name="facebook" size={17} />
            </a>
            <a href="#" aria-label="Instagram">
              <Icon name="instagram" size={17} />
            </a>
          </div>
        </div>

        <div className="lh-footer__col">
          <h4>Truy cập nhanh</h4>
          <a href="#featured-books">Sách nổi bật</a>
          <a href="#categories">Thể loại</a>
          <a href="#news">Tin tức</a>
          <a href="#">Sơ đồ trang</a>
        </div>

        <div className="lh-footer__col">
          <h4>Dịch vụ</h4>
          <a href="#">Mượn / trả sách</a>
          <a href="#">Gia hạn trực tuyến</a>
          <a href="#">Tra cứu phiếu phạt</a>
        </div>

        <div className="lh-footer__col">
          <h4>Liên hệ</h4>
          <a href="#contact" className="lh-footer__contact-line">
            <Icon name="map-pin" size={16} /> Nhà của Định:D
          </a>
          <a href="#contact" className="lh-footer__contact-line">
            <Icon name="phone" size={16} /> 033 6037 773
          </a>
          <a href="#contact" className="lh-footer__contact-line">
            <Icon name="mail" size={16} /> hotro@libhub.vn
          </a>
        </div>
      </div>

      <div className="lh-container lh-footer__bottom">
        <span>© 2026 LibHub. Bảo lưu mọi quyền.</span>
        <div className="lh-footer__legal">
          <a href="#">Điều khoản sử dụng</a>
          <a href="#">Chính sách bảo mật</a>
        </div>
      </div>
    </footer>
  );
}
