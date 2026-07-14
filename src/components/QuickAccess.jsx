import Icon from "./Icon";
import "../styles/QuickAccess.css";

const ITEMS = [
  {
    icon: "book-open",
    title: "Sách nổi bật",
    desc: "Được mượn nhiều nhất tháng này",
    href: "#featured-books",
  },
  {
    icon: "layers",
    title: "Thể loại",
    desc: "24 danh mục để khám phá",
    href: "#categories",
  },
  {
    icon: "users",
    title: "Tác giả",
    desc: "Tra theo tên tác giả yêu thích",
    href: "#",
  },
  {
    icon: "check-circle",
    title: "Phiếu mượn của tôi",
    desc: "Theo dõi hạn trả & gia hạn",
    href: "#",
  },
];

export default function QuickAccess() {
  return (
    <section className="lh-quick lh-section--tight">
      <div className="lh-container lh-quick__grid">
        {ITEMS.map((item) => (
          <a key={item.title} href={item.href} className="lh-quick__card">
            <span className="lh-quick__icon">
              <Icon name={item.icon} size={20} />
            </span>
            <span>
              <span className="lh-quick__title">{item.title}</span>
              <span className="lh-quick__desc">{item.desc}</span>
            </span>
          </a>
        ))}
      </div>
    </section>
  );
}
