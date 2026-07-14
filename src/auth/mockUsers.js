// src/auth/mockUsers.js
//
// Dữ liệu mẫu khớp với bảng Roles / Users trong DB của nhóm.
// ⚠️ Đây là demo phía client thôi — mật khẩu để dạng thường (plain text)
// và toàn bộ nằm trong bundle JS, KHÔNG được dùng cách này khi có backend
// thật. Khi có API, xoá file này và gọi POST /api/auth/login,
// POST /api/auth/register thay thế.

export const roles = [
  { role_id: 1, role_name: "Admin", description: "Toàn quyền quản trị hệ thống" },
  { role_id: 2, role_name: "User", description: "Bạn đọc / thành viên thư viện" },
  { role_id: 3, role_name: "Librarian", description: "Thủ thư quản lý mượn trả" },
];

export const mockUsers = [
  {
    user_id: 1,
    username: "admin",
    password: "admin123",
    full_name: "Quản trị viên",
    email: "admin@libhub.vn",
    phone: "0900000001",
    address: "",
    member_since: "2022-01-10",
    role_id: 1,
  },
  {
    user_id: 2,
    username: "user",
    password: "user123",
    full_name: "Bạn đọc demo",
    email: "user@libhub.vn",
    phone: "0900000002",
    address: "",
    member_since: "2024-03-02",
    role_id: 2,
  },
  {
    user_id: 3,
    username: "librian",
    password: "librian123",
    full_name: "Thủ thư demo",
    email: "librarian@libhub.vn",
    phone: "0900000003",
    address: "",
    member_since: "2023-06-20",
    role_id: 3,
  },
];

export function getRole(role_id) {
  return roles.find((r) => r.role_id === role_id);
}
