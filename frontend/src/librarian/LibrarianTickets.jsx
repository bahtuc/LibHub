import { Fragment, useEffect, useState } from "react";
import Icon from "../components/Icon";
import Pagination from "../components/Pagination";
import Badge from "../admin/Badge";
import { copiesStore } from "../data/adminStore";
import { getBorrowTicketViews, renewBorrowTicket } from "../services/BorrowTicketService";
import { createReturn } from "../services/ReturnService";
import useLoanViews from "../hooks/useLoanViews";
import { getTicketStatus } from "../utils/loanViews";
import { formatDate } from "../utils/format";

const STATUS_BADGE = {
  borrowing: { tone: "success", text: "Đang mượn" },
  overdue: { tone: "danger", text: "Quá hạn" },
  returned: { tone: "neutral", text: "Đã trả" },
  cancelled: { tone: "neutral", text: "Đã hủy" },
  payment_pending: { tone: "warning", text: "Chờ VNPay" },
};

const CONDITION_OPTIONS = [
  { value: "Good", label: "Tốt" },
  { value: "Damaged", label: "Hư hỏng" },
  { value: "Lost", label: "Mất" },
];

const PAGE_SIZE = 10;

function pendingItems(ticket) {
  if (["returned", "cancelled", "payment_pending"].includes(getTicketStatus(ticket))) return [];
  return (ticket.items ?? []).filter((item) => {
    const status = String(item.borrowStatus || "").toLowerCase();
    return !item.returnedDate && !["returned", "lost", "cancelled"].includes(status);
  });
}

export default function LibrarianTickets() {
  const { tickets, loading, error, refresh } = useLoanViews(getBorrowTicketViews);
  const [openTicketId, setOpenTicketId] = useState(null);
  const [conditions, setConditions] = useState({});
  const [selectedCopyIds, setSelectedCopyIds] = useState([]);
  const [actionError, setActionError] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [renewingId, setRenewingId] = useState(null);
  const [actionNotice, setActionNotice] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const [searchQuery, setSearchQuery] = useState("");
  const normalizedQuery = searchQuery.trim().toLocaleLowerCase("vi");
  const filteredTickets = normalizedQuery
    ? tickets.filter((ticket) => {
        const status = getTicketStatus(ticket);
        const searchable = [
          ticket.ticketId,
          ticket.userId,
          ticket.userName,
          ticket.guestName,
          ticket.guestPhone,
          status,
          STATUS_BADGE[status]?.text,
          ticket.borrowDate,
          ticket.dueDate,
          ...(ticket.items ?? []).flatMap((item) => [item.bookTitle, item.barcode, item.copyId]),
        ].filter(Boolean).join(" ").toLocaleLowerCase("vi");
        return searchable.includes(normalizedQuery);
      })
    : tickets;
  const totalPages = Math.max(1, Math.ceil(filteredTickets.length / PAGE_SIZE));
  const pageStart = (currentPage - 1) * PAGE_SIZE;
  const paginatedTickets = filteredTickets.slice(pageStart, pageStart + PAGE_SIZE);

  useEffect(() => {
    setCurrentPage((page) => Math.min(page, totalPages));
  }, [totalPages]);

  useEffect(() => {
    setCurrentPage(1);
    setOpenTicketId(null);
    setSelectedCopyIds([]);
  }, [searchQuery]);

  function changePage(page) {
    setCurrentPage(page);
    setOpenTicketId(null);
    setSelectedCopyIds([]);
  }

  async function renew(ticket) {
    setRenewingId(ticket.ticketId);
    setActionError("");
    setActionNotice("");
    try {
      await renewBorrowTicket(ticket.ticketId, 7);
      await refresh();
      setActionNotice(`Đã gia hạn phiếu #${ticket.ticketId} thêm 7 ngày.`);
    } catch (requestError) {
      setActionError(requestError.message || "Không thể gia hạn phiếu mượn.");
    } finally {
      setRenewingId(null);
    }
  }

  function openReturn(ticket) {
    if (ticket.ticketId === openTicketId) {
      setOpenTicketId(null);
      setSelectedCopyIds([]);
      return;
    }
    const initial = {};
    pendingItems(ticket).forEach((item) => {
      initial[item.copyId] = "Good";
    });
    setConditions(initial);
    setSelectedCopyIds([]);
    setActionError("");
    setOpenTicketId(ticket.ticketId);
  }

  async function submitReturn(ticket) {
    const details = pendingItems(ticket)
      .filter((item) => selectedCopyIds.includes(item.copyId))
      .map((item) => ({
        copyId: item.copyId,
        conditionBook: conditions[item.copyId] || "Good",
      }));
    if (details.length === 0) return;
    setSubmitting(true);
    setActionError("");
    try {
      await createReturn({ ticketId: ticket.ticketId, details });
      setOpenTicketId(null);
      setSelectedCopyIds([]);
      await Promise.all([refresh(), copiesStore.refresh()]);
    } catch (requestError) {
      setActionError(requestError.message || "Không thể xử lý trả sách.");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="lh-admin-page">
      <div className="lh-admin-page__head">
        <div>
          <h1 className="lh-admin-page__title">Phiếu mượn</h1>
          <p className="lh-admin-page__subtitle">Theo dõi và xử lý trả sách từ dữ liệu hệ thống.</p>
        </div>
      </div>

      {(error || actionError) && <p className="lh-auth-form__error">{actionError || error}</p>}
      {actionNotice && <p className="lh-auth-form__success">{actionNotice}</p>}

      <div className="lh-admin-toolbar">
        <label className="lh-admin-search">
          <Icon name="search" size={17} />
          <input
            type="search"
            value={searchQuery}
            onChange={(event) => setSearchQuery(event.target.value)}
            placeholder="Tìm theo mã phiếu, bạn đọc, sách, mã vạch hoặc trạng thái..."
            aria-label="Tìm kiếm phiếu mượn và trả sách"
          />
        </label>
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
              {paginatedTickets.map((ticket) => {
                const status = getTicketStatus(ticket);
                const badge = STATUS_BADGE[status] ?? STATUS_BADGE.borrowing;
                const pending = pendingItems(ticket);
                const canRenew = status === "borrowing" && Number(ticket.renewalCount || 0) < 2;
                return (
                  <Fragment key={ticket.ticketId}>
                    <tr>
                      <td>#{ticket.ticketId}</td>
                      <td>{ticket.userName || `#${ticket.userId}`}</td>
                      <td className="lh-mono">{formatDate(ticket.borrowDate)}</td>
                      <td className="lh-mono">{formatDate(ticket.dueDate)}</td>
                      <td>{ticket.items?.length ?? 0}</td>
                      <td><Badge tone={badge.tone}>{badge.text}</Badge></td>
                      <td className="lh-admin-table__actions">
                        {canRenew && (
                          <button
                            className="lh-btn lh-btn--ghost"
                            disabled={renewingId === ticket.ticketId}
                            onClick={() => renew(ticket)}
                          >
                            {renewingId === ticket.ticketId ? "Đang gia hạn..." : "Gia hạn 7 ngày"}
                          </button>
                        )}
                        {pending.length > 0 ? (
                          <button className="lh-btn lh-btn--ghost" onClick={() => openReturn(ticket)}>
                            {openTicketId === ticket.ticketId ? "Đóng" : "Trả sách"}
                          </button>
                        ) : (
                          <span style={{ color: "var(--lh-text-muted)", fontSize: "0.82rem" }}>Đã xử lý</span>
                        )}
                      </td>
                    </tr>

                    {openTicketId === ticket.ticketId && (
                      <tr>
                        <td colSpan={7} style={{ background: "var(--lh-paper-soft)" }}>
                          <div style={{ padding: "14px 4px" }}>
                            <table className="lh-admin-table" style={{ background: "#fff" }}>
                              <thead>
                                <tr>
                                  <th style={{ width: 72 }}>Trả</th>
                                  <th>Sách</th>
                                  <th>Mã vạch</th>
                                  <th>Tình trạng khi trả</th>
                                </tr>
                              </thead>
                              <tbody>
                                {pending.map((item) => (
                                  <tr key={item.detailId ?? item.copyId}>
                                    <td>
                                      <input
                                        type="checkbox"
                                        checked={selectedCopyIds.includes(item.copyId)}
                                        aria-label={`Chọn trả ${item.bookTitle || item.barcode || item.copyId}`}
                                        onChange={(event) =>
                                          setSelectedCopyIds((current) =>
                                            event.target.checked
                                              ? [...current, item.copyId]
                                              : current.filter((copyId) => copyId !== item.copyId),
                                          )
                                        }
                                      />
                                    </td>
                                    <td>{item.bookTitle || "—"}</td>
                                    <td>{item.barcode || "—"}</td>
                                    <td>
                                      <select
                                        value={conditions[item.copyId] || "Good"}
                                        disabled={!selectedCopyIds.includes(item.copyId)}
                                        onChange={(event) =>
                                          setConditions((current) => ({
                                            ...current,
                                            [item.copyId]: event.target.value,
                                          }))
                                        }
                                      >
                                        {CONDITION_OPTIONS.map((option) => (
                                          <option key={option.value} value={option.value}>{option.label}</option>
                                        ))}
                                      </select>
                                    </td>
                                  </tr>
                                ))}
                              </tbody>
                            </table>
                            <div style={{ display: "flex", gap: 8, alignItems: "center", marginTop: 14, flexWrap: "wrap" }}>
                              <button
                                type="button"
                                className="lh-btn lh-btn--ghost"
                                onClick={() => setSelectedCopyIds(pending.map((item) => item.copyId))}
                              >
                                Chọn tất cả
                              </button>
                              {selectedCopyIds.length > 0 && (
                                <button
                                  type="button"
                                  className="lh-btn lh-btn--ghost"
                                  onClick={() => setSelectedCopyIds([])}
                                >
                                  Bỏ chọn
                                </button>
                              )}
                              <span style={{ color: "var(--lh-text-muted)", fontSize: "0.86rem" }}>
                                Đã chọn {selectedCopyIds.length} cuốn để trả
                              </span>
                            </div>
                            <button
                              className="lh-btn lh-btn--primary"
                              style={{ marginTop: 14 }}
                              disabled={submitting || selectedCopyIds.length === 0}
                              onClick={() => submitReturn(ticket)}
                            >
                              <Icon name="check-circle" size={15} />
                              {submitting ? "Đang xử lý..." : `Xác nhận trả ${selectedCopyIds.length} cuốn`}
                            </button>
                          </div>
                        </td>
                      </tr>
                    )}
                  </Fragment>
                );
              })}
              {!loading && filteredTickets.length === 0 && (
                <tr><td colSpan={7} className="lh-admin-table__empty">{tickets.length === 0 ? "Chưa có phiếu mượn nào." : "Không tìm thấy phiếu phù hợp."}</td></tr>
              )}
              {loading && (
                <tr><td colSpan={7} className="lh-admin-table__empty">Đang tải...</td></tr>
              )}
            </tbody>
          </table>
        </div>
        {!loading && filteredTickets.length > 0 && (
          <div className="lh-admin-table-pagination">
            <p className="lh-admin-table-pagination__summary">
              Hiển thị {pageStart + 1}–{Math.min(pageStart + PAGE_SIZE, filteredTickets.length)} trong {filteredTickets.length} phiếu mượn
            </p>
            <Pagination
              currentPage={currentPage}
              totalPages={totalPages}
              onPageChange={changePage}
              label="Phân trang phiếu mượn"
            />
          </div>
        )}
      </div>
    </div>
  );
}
