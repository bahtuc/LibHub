// src/admin/AdminCategories.jsx
import AdminCrudPage from "./AdminCrudPage";
import { categoriesStore } from "../data/adminStore";

export default function AdminCategories() {
  return (
    <AdminCrudPage
      title="Thể loại"
      subtitle="Quản lý danh mục thể loại sách, dùng để lọc ở trang Thư viện và Genres."
      store={categoriesStore}
      idField="category_id"
      emptyItem={{ category_name: "", description: "" }}
      columns={[
        { key: "category_name", label: "Tên thể loại" },
        { key: "description", label: "Mô tả", render: (i) => i.description || "—" },
      ]}
      fields={[
        { name: "category_name", label: "Tên thể loại", required: true },
        { name: "description", label: "Mô tả", type: "textarea" },
      ]}
    />
  );
}
