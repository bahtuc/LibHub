import AdminCrudPage from "./AdminCrudPage";
import { publishersStore } from "../data/adminStore";

export default function AdminPublishers() {
  return (
    <AdminCrudPage
      title="Nhà xuất bản"
      subtitle="Quản lý danh sách nhà xuất bản của thư viện."
      store={publishersStore}
      idField="publisher_id"
      emptyItem={{
        publisher_name: "",
        address: "",
        phone: "",
      }}
      columns={[
        { key: "publisher_name", label: "Tên nhà xuất bản" },
        { key: "address", label: "Địa chỉ", render: (i) => i.address || "—" },
        { key: "phone", label: "Số điện thoại", render: (i) => i.phone || "—" },
      ]}
      fields={[
        {
          name: "publisher_name",
          label: "Tên nhà xuất bản",
          required: true,
        },
        {
          name: "address",
          label: "Địa chỉ",
        },
        {
          name: "phone",
          label: "Số điện thoại",
        },
      ]}
    />
  );
}