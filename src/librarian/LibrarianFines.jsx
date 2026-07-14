// src/librarian/LibrarianFines.jsx
import Badge from "../admin/Badge";
import { usersStore, booksStore } from "../data/adminStore";
import { useTickets, markFinePaid } from "../data/librarianStore";

export default function LibrarianFines() {
  const users = usersStore.useCollection();
  const books = booksStore.useCollection();
  const tickets = useTickets();

  // Tính trực tiếp từ tickets (thay vì gọi getAllFines() một lần) để component
  // tự re-render ngay khi markFinePaid() cập nhật dữ liệu.
  const fines = tickets
    .flatMap((t) =>
      t.items
        .filter((it) => it.fine_amount > 0)
        .map((it) => ({ ...it, ticket_id: t.ticket_id, user_id: t.user_id }))
    )
    .sort((a, b) => b.ticket_id - a.ticket_id);

  function userName(id) {
    return users.find((u) => u.user_id === id)?.full_name ?? "—";
  }
  function bookTitle(id) {
    return books.find((b) => b.book_id === id)?.title ?? "—";
  }
  function reasonLabel(condition_book) {
    if (condition_book === "mat") return "Làm mất sách";
    if (condition_book === "hu_hong") return "Trả sách hư hỏng";
    return "Trả trễ hạn";
  }

  return (
    <div className="lh-admin-page">
      <div className="lh-admin-page__head">
        <div>
          <h1 className="lh-admin-page__title">Phạt</h1>
          <p className="lh-admin-page__subtitle">
            Danh sách khoản phạt phát sinh từ trả trễ / hư hỏng / mất sách.
          </p>
        </div>
      </div>

      <div className="lh-admin-table-wrap">
        <div className="lh-admin-table-scroll">
          <table className="lh-admin-table">
            <thead>
              <tr>
                <th>Phiếu</th>
                <th>Bạn đọc</th>
                <th>Sách</th>
                <th>Lý do</th>
                <th>Số tiền</th>
                <th>Trạng thái</th>
                <th className="lh-admin-table__actions-head">Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {fines.map((f) => (
                <tr key={`${f.ticket_id}-${f.copy_id}`}>
                  <td>#{f.ticket_id}</td>
                  <td>{userName(f.user_id)}</td>
                  <td>{bookTitle(f.book_id)}</td>
                  <td>{reasonLabel(f.condition_book)}</td>
                  <td>{f.fine_amount.toLocaleString("vi-VN")}đ</td>
                  <td>
                    {f.fine_paid ? (
                      <Badge tone="success">Đã thu</Badge>
                    ) : (
                      <Badge tone="danger">Chưa thu</Badge>
                    )}
                  </td>
                  <td className="lh-admin-table__actions">
                    <button
                      className="lh-btn lh-btn--ghost"
                      onClick={() => markFinePaid(f.ticket_id, f.copy_id, !f.fine_paid)}
                    >
                      {f.fine_paid ? "Đánh dấu chưa thu" : "Đánh dấu đã thu"}
                    </button>
                  </td>
                </tr>
              ))}
              {fines.length === 0 && (
                <tr>
                  <td colSpan={7} className="lh-admin-table__empty">
                    Chưa có khoản phạt nào.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
