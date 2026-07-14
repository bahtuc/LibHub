// src/librarian/LibrarianTickets.jsx
// Danh sách phiếu mượn + xử lý trả sách ngay tại chỗ (mở rộng theo từng dòng).
import { Fragment, useState } from "react";
import Icon from "../components/Icon";
import Badge from "../admin/Badge";
import { usersStore, booksStore } from "../data/adminStore";
import { useTickets, getTicketStatus, returnItems, CONDITION_OPTIONS } from "../data/librarianStore";

const STATUS_BADGE = {
  borrowing: { tone: "success", text: "Đang mượn" },
  overdue: { tone: "danger", text: "Quá hạn" },
  returned: { tone: "neutral", text: "Đã trả" },
};

export default function LibrarianTickets() {
  const tickets = useTickets();
  const users = usersStore.useCollection();
  const books = booksStore.useCollection();
  const [openTicketId, setOpenTicketId] = useState(null);
  const [conditions, setConditions] = useState({});

  function userName(user_id) {
    return users.find((u) => u.user_id === user_id)?.full_name ?? "—";
  }
  function bookTitle(book_id) {
    return books.find((b) => b.book_id === book_id)?.title ?? "—";
  }

  function openReturn(ticket) {
    setOpenTicketId(ticket.ticket_id === openTicketId ? null : ticket.ticket_id);
    const initial = {};
    ticket.items
      .filter((it) => !it.returned_at)
      .forEach((it) => (initial[it.copy_id] = "tot"));
    setConditions(initial);
  }

  function submitReturn(ticket) {
    const pending = ticket.items.filter((it) => !it.returned_at);
    const payload = pending.map((it) => ({
      copy_id: it.copy_id,
      condition_book: conditions[it.copy_id] || "tot",
    }));
    returnItems(ticket.ticket_id, payload);
    setOpenTicketId(null);
  }

  const sorted = [...tickets].sort((a, b) => b.ticket_id - a.ticket_id);

  return (
    <div className="lh-admin-page">
      <div className="lh-admin-page__head">
        <div>
          <h1 className="lh-admin-page__title">Phiếu mượn</h1>
          <p className="lh-admin-page__subtitle">Theo dõi và xử lý trả sách cho từng phiếu.</p>
        </div>
      </div>

      <div className="lh-admin-table-wrap">
        <div className="lh-admin-table-scroll">
          <table className="lh-admin-table">
            <thead>
              <tr>
                <th>Mã phiếu</th>
                <th>Bạn đọc</th>
                <th>Ngày mượn</th>
                <th>Hạn trả</th>
                <th>Số sách</th>
                <th>Trạng thái</th>
                <th className="lh-admin-table__actions-head">Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {sorted.map((t) => {
                const s = STATUS_BADGE[getTicketStatus(t)];
                const pendingCount = t.items.filter((it) => !it.returned_at).length;
                return (
                  <Fragment key={t.ticket_id}>
                    <tr>
                      <td>#{t.ticket_id}</td>
                      <td>{userName(t.user_id)}</td>
                      <td>{t.borrow_date}</td>
                      <td>{t.due_date}</td>
                      <td>{t.items.length}</td>
                      <td>
                        <Badge tone={s.tone}>{s.text}</Badge>
                      </td>
                      <td className="lh-admin-table__actions">
                        {pendingCount > 0 ? (
                          <button className="lh-btn lh-btn--ghost" onClick={() => openReturn(t)}>
                            {openTicketId === t.ticket_id ? "Đóng" : "Trả sách"}
                          </button>
                        ) : (
                          <span style={{ color: "var(--lh-text-muted)", fontSize: "0.82rem" }}>
                            Đã trả đủ
                          </span>
                        )}
                      </td>
                    </tr>

                    {openTicketId === t.ticket_id && (
                      <tr>
                        <td colSpan={7} style={{ background: "var(--lh-paper-soft)" }}>
                          <div style={{ padding: "14px 4px" }}>
                            <table className="lh-admin-table" style={{ background: "#fff" }}>
                              <thead>
                                <tr>
                                  <th>Sách</th>
                                  <th>Ngày mượn</th>
                                  <th>Tình trạng khi trả</th>
                                </tr>
                              </thead>
                              <tbody>
                                {t.items
                                  .filter((it) => !it.returned_at)
                                  .map((it) => (
                                    <tr key={it.copy_id}>
                                      <td>{bookTitle(it.book_id)}</td>
                                      <td>{it.borrowed_at}</td>
                                      <td>
                                        <select
                                          value={conditions[it.copy_id] || "tot"}
                                          onChange={(e) =>
                                            setConditions((c) => ({ ...c, [it.copy_id]: e.target.value }))
                                          }
                                        >
                                          {CONDITION_OPTIONS.map((o) => (
                                            <option key={o.value} value={o.value}>
                                              {o.label}
                                            </option>
                                          ))}
                                        </select>
                                      </td>
                                    </tr>
                                  ))}
                              </tbody>
                            </table>
                            <button
                              className="lh-btn lh-btn--primary"
                              style={{ marginTop: 14 }}
                              onClick={() => submitReturn(t)}
                            >
                              <Icon name="check-circle" size={15} /> Xác nhận trả
                            </button>
                          </div>
                        </td>
                      </tr>
                    )}
                  </Fragment>
                );
              })}
              {sorted.length === 0 && (
                <tr>
                  <td colSpan={7} className="lh-admin-table__empty">
                    Chưa có phiếu mượn nào.
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
