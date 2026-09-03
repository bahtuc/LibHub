import { useEffect, useState } from "react";
import Badge from "../admin/Badge";
import Pagination from "../components/Pagination";
import { getBorrowTicketViews } from "../services/BorrowTicketService";
import { updateFinePaidStatus } from "../services/FineService";
import useLoanViews from "../hooks/useLoanViews";
import { isFinePaid } from "../utils/loanViews";
import Icon from "../components/Icon";

const PAGE_SIZE = 10;

export default function LibrarianFines() {
  const { tickets, loading, error, refresh } = useLoanViews(getBorrowTicketViews);
  const [actionError, setActionError] = useState("");
  const [updatingId, setUpdatingId] = useState(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [searchQuery, setSearchQuery] = useState("");

  const fines = tickets
    .flatMap((ticket) =>
      (ticket.items ?? [])
        .filter((item) => item.fineId != null)
        .map((item) => ({
          ...item,
          ticketId: ticket.ticketId,
          userId: ticket.userId,
          userName: ticket.userName,
        })),
    )
    .sort((left, right) => Number(right.fineId) - Number(left.fineId));
  const normalizedQuery = searchQuery.trim().toLocaleLowerCase("vi");
  const filteredFines = normalizedQuery
    ? fines.filter((fine) => [
        fine.fineId,
        fine.ticketId,
        fine.userId,
        fine.userName,
        fine.bookTitle,
        fine.barcode,
        fine.fineReason,
        fine.fineAmount,
        isFinePaid(fine) ? "đã thu paid" : "chưa thu unpaid",
      ].filter(Boolean).join(" ").toLocaleLowerCase("vi").includes(normalizedQuery))
    : fines;
  const totalPages = Math.max(1, Math.ceil(filteredFines.length / PAGE_SIZE));
  const pageStart = (currentPage - 1) * PAGE_SIZE;
  const paginatedFines = filteredFines.slice(pageStart, pageStart + PAGE_SIZE);

  useEffect(() => {
    setCurrentPage((page) => Math.min(page, totalPages));
  }, [totalPages]);

  useEffect(() => {
    setCurrentPage(1);
  }, [searchQuery]);

  async function togglePaid(fine) {
    setUpdatingId(fine.fineId);
    setActionError("");
    try {
      await updateFinePaidStatus(fine.fineId, isFinePaid(fine) ? "Unpaid" : "Paid");
      await refresh();
    } catch (requestError) {
      setActionError(requestError.message || "Không thể cập nhật trạng thái khoản phạt.");
    } finally {
      setUpdatingId(null);
    }
  }

  return (
    <div className="lh-admin-page">
      <div className="lh-admin-page__head">
        <div>
          <h1 className="lh-admin-page__title">Phạt</h1>
          <p className="lh-admin-page__subtitle">Các khoản phạt phát sinh từ dữ liệu trả sách.</p>
        </div>
      </div>

      {(error || actionError) && <p className="lh-auth-form__error">{actionError || error}</p>}

      <div className="lh-admin-toolbar">
        <label className="lh-admin-search">
          <Icon name="search" size={17} />
          <input
            type="search"
            value={searchQuery}
            onChange={(event) => setSearchQuery(event.target.value)}
            placeholder="Tìm theo mã phạt, phiếu, bạn đọc, sách hoặc lý do..."
            aria-label="Tìm kiếm khoản phạt"
          />
        </label>
      </div>

      <div className="lh-admin-table-wrap">
        <div className="lh-admin-table-scroll">
          <table className="lh-admin-table">
            <thead>
              <tr>
                <th>Mã phạt</th>
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
              {paginatedFines.map((fine) => {
                const paid = isFinePaid(fine);
                return (
                  <tr key={fine.fineId}>
                    <td>#{fine.fineId}</td>
                    <td>#{fine.ticketId}</td>
                    <td>{fine.userName || `#${fine.userId}`}</td>
                    <td>{fine.bookTitle || "—"}</td>
                    <td>{fine.fineReason || "Phí thư viện"}</td>
                    <td>{Number(fine.fineAmount || 0).toLocaleString("vi-VN")}đ</td>
                    <td>
                      <Badge tone={paid ? "success" : "danger"}>
                        {paid ? "Đã thu" : "Chưa thu"}
                      </Badge>
                    </td>
                    <td className="lh-admin-table__actions">
                      <button
                        className="lh-btn lh-btn--ghost"
                        disabled={updatingId === fine.fineId}
                        onClick={() => togglePaid(fine)}
                      >
                        {paid ? "Đánh dấu chưa thu" : "Đánh dấu đã thu"}
                      </button>
                    </td>
                  </tr>
                );
              })}
              {!loading && filteredFines.length === 0 && (
                <tr><td colSpan={8} className="lh-admin-table__empty">{fines.length === 0 ? "Chưa có khoản phạt nào." : "Không tìm thấy khoản phạt phù hợp."}</td></tr>
              )}
              {loading && (
                <tr><td colSpan={8} className="lh-admin-table__empty">Đang tải...</td></tr>
              )}
            </tbody>
          </table>
        </div>
        {!loading && filteredFines.length > 0 && (
          <div className="lh-admin-table-pagination">
            <p className="lh-admin-table-pagination__summary">
              Hiển thị {pageStart + 1}–{Math.min(pageStart + PAGE_SIZE, filteredFines.length)} trong {filteredFines.length} khoản phạt
            </p>
            <Pagination
              currentPage={currentPage}
              totalPages={totalPages}
              onPageChange={setCurrentPage}
              label="Phân trang khoản phạt"
            />
          </div>
        )}
      </div>
    </div>
  );
}
