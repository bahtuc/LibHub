// src/admin/AdminUsers.jsx
import AdminCrudPage from "./AdminCrudPage";
import Badge from "./Badge";
import { usersStore, ROLE_OPTIONS, getRoleLabel } from "../data/adminStore";
import { useAuth } from "../auth/useAuth";

const ROLE_TONE = { Admin: "warning", User: "success", Librarian: "info" };

export default function AdminUsers() {
  const { user: currentUser } = useAuth();

  return (
    <AdminCrudPage
      title="Người dùng"
      subtitle="Quản lý tài khoản và phân quyền (Admin / User / Librarian)."
      store={usersStore}
      idField="user_id"
      emptyItem={{ username: "", full_name: "", role_id: 2, status: "active" }}
      canDelete={(item) => item.user_id !== currentUser?.user_id}
      columns={[
        {
          key: "username",
          label: "Tên đăng nhập",
          render: (i) => (
            <span className="lh-admin-avatar-cell">
              <span className="lh-admin-avatar">{i.full_name?.charAt(0) ?? "?"}</span>
              <span className="lh-admin-username">{i.username}</span>
            </span>
          ),
        },
        { key: "full_name", label: "Họ tên" },
        {
          key: "role_id",
          label: "Vai trò",
          render: (i) => {
            const label = getRoleLabel(i.role_id);
            return <Badge tone={ROLE_TONE[label] ?? "neutral"}>{label}</Badge>;
          },
        },
        {
          key: "status",
          label: "Trạng thái",
          render: (i) =>
            i.status === "active" ? (
              <Badge tone="success">Đang hoạt động</Badge>
            ) : (
              <Badge tone="danger">Đã khóa</Badge>
            ),
        },
      ]}
      fields={[
        { name: "username", label: "Tên đăng nhập", required: true },
        { name: "full_name", label: "Họ và tên", required: true },
        { name: "role_id", label: "Vai trò", type: "select", options: ROLE_OPTIONS, numeric: true, required: true },
        {
          name: "status",
          label: "Trạng thái",
          type: "select",
          options: [
            { value: "active", label: "Đang hoạt động" },
            { value: "locked", label: "Đã khóa" },
          ],
        },
      ]}
    />
  );
}
