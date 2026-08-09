import AdminCrudPage from "./AdminCrudPage";
import Badge from "./Badge";
import { finesStore } from "../data/adminStore";

const STATUS = {
  Paid: { tone: "success", label: "Đã thanh toán" },
  Unpaid: { tone: "warning", label: "Chưa thanh toán" },
};

export default function AdminFines() {
  return (
    <AdminCrudPage
      title="Khoản phạt"
      subtitle="Tạo, cập nhật và theo dõi các khoản phạt phát sinh khi trả sách."
      store={finesStore}
      idField="fine_id"
      emptyItem={{ return_detail_id: "", amount: 0, reason: "", paid_status: "Unpaid" }}
      columns={[
        { key: "fine_id", label: "Mã phạt", render: (item) => `#${item.fine_id}` },
        { key: "return_detail_id", label: "Chi tiết trả", render: (item) => `#${item.return_detail_id}` },
        {
          key: "amount",
          label: "Số tiền",
          render: (item) => `${Number(item.amount || 0).toLocaleString("vi-VN")} ₫`,
        },
        { key: "reason", label: "Lý do", render: (item) => item.reason || "—" },
        {
          key: "paid_status",
          label: "Trạng thái",
          render: (item) => {
            const status = STATUS[item.paid_status] ?? { tone: "neutral", label: item.paid_status };
            return <Badge tone={status.tone}>{status.label}</Badge>;
          },
        },
      ]}
      fields={[
        { name: "return_detail_id", label: "Mã chi tiết trả", type: "number", required: true },
        { name: "amount", label: "Số tiền phạt", type: "number", required: true },
        { name: "reason", label: "Lý do", type: "textarea", required: true },
        {
          name: "paid_status",
          label: "Trạng thái thanh toán",
          type: "select",
          options: [
            { value: "Unpaid", label: "Chưa thanh toán" },
            { value: "Paid", label: "Đã thanh toán" },
          ],
          required: true,
        },
      ]}
    />
  );
}
