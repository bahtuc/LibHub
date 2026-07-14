import Icon from "./Icon";
import "../styles/Contact.css";

export default function Contact() {
  return (
    <section className="lh-section lh-section--soft" id="contact">
      <div className="lh-container lh-contact">
        <div className="lh-contact__copy">
          <p className="lh-eyebrow">Liên hệ</p>
          <h2 className="lh-h2">Cần hỗ trợ về mượn/trả sách?</h2>
          <p className="lh-lede">
            Đội ngũ thủ thư LibHub phản hồi trong vòng 1 ngày làm việc. Bạn
            cũng có thể ghé trực tiếp quầy thủ thư trong giờ mở cửa.
          </p>

          <ul className="lh-contact__list">
            <li>
              <Icon name="map-pin" size={18} />
              Nhà của Định:D
            </li>
            <li>
              <Icon name="phone" size={18} />
              033 6037 773
            </li>
            <li>
              <Icon name="mail" size={18} />
              hotro@libhub.vn
            </li>
          </ul>
        </div>

        <form className="lh-contact__form" onSubmit={(e) => e.preventDefault()}>
          <label>
            Họ và tên
            <input type="text" placeholder="Nguyễn Văn A" required />
          </label>
          <label>
            Email
            <input type="email" placeholder="ban@email.com" required />
          </label>
          <label>
            Nội dung
            <textarea rows={4} placeholder="Tôi cần hỗ trợ về…" required />
          </label>
          <button type="submit" className="lh-btn lh-btn--primary">
            Gửi yêu cầu
          </button>
        </form>
      </div>
    </section>
  );
}
