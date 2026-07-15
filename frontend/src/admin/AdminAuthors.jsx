// src/admin/AdminAuthors.jsx
import AdminCrudPage from "./AdminCrudPage";
import { authorsStore } from "../data/adminStore";

export default function AdminAuthors() {
  return (
    <AdminCrudPage
      title="Tác giả"
      subtitle="Quản lý danh sách tác giả gắn với các đầu sách."
      store={authorsStore}
      idField="author_id"
      emptyItem={{ author_name: "", biography: "" }}
      columns={[
        { key: "author_name", label: "Tên tác giả" },
        { key: "biography", label: "Tiểu sử", render: (i) => i.biography || "—" },
      ]}
      fields={[
        { name: "author_name", label: "Tên tác giả", required: true },
        { name: "biography", label: "Tiểu sử (tùy chọn)", type: "textarea" },
      ]}
    />
  );
}
