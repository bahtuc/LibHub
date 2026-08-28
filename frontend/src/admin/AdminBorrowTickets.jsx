import AdminCrudPage from "./AdminCrudPage";
import Badge from "./Badge";
import { borrowTicketsStore, usersStore } from "../data/adminStore";
import { addDaysISO, formatDate, todayISO } from "../utils/format";

const STATUS = {
  Borrowed: { tone: "info", label: "Đang mượn" },
  Overdue: { tone: "danger", label: "Quá hạn" },
  Returned: { tone: "success", label: "Đã trả" },
  Cancelled: { tone: "neutral", label: "Đã hủy" },
  PendingPayment: { tone: "warning", label: "Chờ thanh toán VNPay" },
};

export default function AdminBorrowTickets() {
  const users = usersStore.useCollection();
  const userOptions = users.map((user) => ({
    value: user.user_id,
    label: `${user.full_name || user.username} (#${user.user_id})`,
  }));

  return (
    <AdminCrudPage
      title="Phiếu mượn"
      subtitle="Quản lý phiếu mượn và gán chính xác các bản sao bằng danh sách mã copy."
      store={borrowTicketsStore}
      idField="ticket_id"
      hideAdd
      emptyItem={{
        borrower_type: "member",
        user_id: userOptions[0]?.value ?? "",
        guest_name: "",
        guest_phone: "",
        borrow_date: todayISO(),
        due_date: addDaysISO(14),
        copy_ids: "",
        payment_confirmed: false,
        status: "Borrowed",
        note: "",
      }}
      columns={[
        { key: "ticket_id", label: "Mã phiếu", render: (item) => `#${item.ticket_id}` },
        {
          key: "user_id",
          label: "Người mượn",
          render: (item) => {
            const user = users.find((candidate) => Number(candidate.user_id) === Number(item.user_id));
            if (item.borrower_type === "guest") {
              return `${item.guest_name} (Khách)${item.guest_phone ? ` · ${item.guest_phone}` : ""}`;
            }
            return user ? `${user.full_name || user.username} (#${item.user_id})` : `#${item.user_id}`;
          },
        },
        { key: "borrow_date", label: "Ngày mượn", render: (item) => formatDate(item.borrow_date) },
        { key: "due_date", label: "Hạn trả", render: (item) => formatDate(item.due_date) },
        {
          key: "status",
          label: "Trạng thái",
          render: (item) => {
            const status = STATUS[item.status] ?? { tone: "neutral", label: item.status };
            return <Badge tone={status.tone}>{status.label}</Badge>;
          },
        },
        { key: "note", label: "Ghi chú", render: (item) => item.note || "—" },
      ]}
      fields={[
        {
          name: "borrower_type",
          label: "Loại bạn đọc",
          type: "select",
          options: [
            { value: "member", label: "Thành viên" },
            { value: "guest", label: "Khách vãng lai" },
          ],
          createOnly: true,
          required: true,
        },
        {
          name: "user_id",
          label: "Người mượn",
          type: "select",
          options: userOptions,
          numeric: true,
          when: (item) => item.borrower_type !== "guest",
          required: true,
        },
        {
          name: "guest_name",
          label: "Tên khách",
          when: (item) => item.borrower_type === "guest",
          required: true,
        },
        {
          name: "guest_phone",
          label: "Số điện thoại khách",
          type: "tel",
          when: (item) => item.borrower_type === "guest",
        },
        { name: "borrow_date", label: "Ngày mượn", type: "date", required: true },
        { name: "due_date", label: "Hạn trả", type: "date", required: true },
        {
          name: "copy_ids",
          label: "Mã vạch hoặc ID bản sao khi tạo mới (cách nhau bằng dấu phẩy)",
          createOnly: true,
          required: true,
        },
        { name: "payment_confirmed", label: "Đã thu đủ phí mượn", type: "checkbox", createOnly: true },
        {
          name: "status",
          label: "Trạng thái",
          type: "select",
          options: Object.entries(STATUS).map(([value, config]) => ({ value, label: config.label })),
          editOnly: true,
          required: true,
        },
        { name: "note", label: "Ghi chú", type: "textarea" },
      ]}
    />
  );
}
