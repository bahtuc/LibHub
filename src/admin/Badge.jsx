// src/admin/Badge.jsx
// Nhãn trạng thái nhỏ dạng "con dấu thẻ thư viện" — nối tiếp motif card-catalog
// đã dùng ở Hero/Stats/Auth, thay vì text thường khó quét mắt trong bảng.
export default function Badge({ tone = "neutral", children }) {
  return <span className={`lh-admin-badge lh-admin-badge--${tone}`}>{children}</span>;
}
