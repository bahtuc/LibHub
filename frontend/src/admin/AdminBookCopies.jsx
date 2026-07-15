// src/admin/AdminBookCopies.jsx
// "Bản sao sách" = các bản in vật lý của cùng 1 đầu sách để user mượn (BookCopies).
import AdminCrudPage from "./AdminCrudPage";
import Badge from "./Badge";
import { copiesStore, booksStore } from "../data/adminStore";

export default function AdminBookCopies() {
  const books = booksStore.useCollection();
  const bookOptions = books.map((b) => ({ value: b.book_id, label: b.title }));

  return (
    <AdminCrudPage
      title="Bản sao sách"
      subtitle="Mỗi đầu sách có thể có nhiều bản in — quản lý từng bản để biết bản nào còn, bản nào đang được mượn."
      store={copiesStore}
      idField="copy_id"
      emptyItem={{
        book_id: bookOptions[0]?.value ?? "",
        barcode: "",
        shelf_location: "",
        status: "available",
        acquired_date: new Date().toISOString().slice(0, 10),
      }}
      columns={[
        {
          key: "book_id",
          label: "Sách",
          render: (i) => books.find((b) => b.book_id === i.book_id)?.title ?? "—",
        },
        { key: "barcode", label: "Mã vạch" },
        { key: "shelf_location", label: "Vị trí kệ" },
        {
          key: "status",
          label: "Trạng thái",
          render: (i) => {
            const map = {
              available: { tone: "success", text: "Còn sách" },
              borrowed: { tone: "warning", text: "Đang mượn" },
              lost: { tone: "danger", text: "Thất lạc" },
            };
            const s = map[i.status] ?? { tone: "neutral", text: i.status };
            return <Badge tone={s.tone}>{s.text}</Badge>;
          },
        },
        { key: "acquired_date", label: "Ngày nhập" },
      ]}
      fields={[
        { name: "book_id", label: "Thuộc sách", type: "select", options: bookOptions, numeric: true, required: true },
        { name: "barcode", label: "Mã vạch", required: true },
        { name: "shelf_location", label: "Vị trí kệ" },
        {
          name: "status",
          label: "Trạng thái",
          type: "select",
          options: [
            { value: "available", label: "Còn sách" },
            { value: "borrowed", label: "Đang mượn" },
            { value: "lost", label: "Thất lạc" },
          ],
        },
        { name: "acquired_date", label: "Ngày nhập", type: "date" },
      ]}
    />
  );
}
