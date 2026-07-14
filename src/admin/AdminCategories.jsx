// src/admin/AdminCategories.jsx
import AdminCrudPage from "./AdminCrudPage";
import { categoriesStore } from "../data/adminStore";

const ICON_OPTIONS = [
  "book-open", "flask", "compass", "briefcase", "star", "landmark", "layers", "users",
].map((v) => ({ value: v, label: v }));

export default function AdminCategories() {
  return (
    <AdminCrudPage
      title="Thể loại"
      subtitle="Quản lý danh mục thể loại sách, dùng để lọc ở trang Thư viện và Genres."
      store={categoriesStore}
      idField="category_id"
      emptyItem={{ category_name: "", color: "#3D6652", icon: "book-open" }}
      columns={[
        { key: "category_name", label: "Tên thể loại" },
        {
          key: "color",
          label: "Màu",
          render: (i) => (
            <span className="lh-admin-color-chip">
              <span style={{ background: i.color }} />
              {i.color}
            </span>
          ),
        },
        { key: "icon", label: "Icon" },
      ]}
      fields={[
        { name: "category_name", label: "Tên thể loại", required: true },
        { name: "color", label: "Màu", type: "color" },
        { name: "icon", label: "Icon", type: "select", options: ICON_OPTIONS },
      ]}
    />
  );
}
