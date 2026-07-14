// src/data/adminStore.js
//
// Kho dữ liệu CRUD cho trang Admin — chưa có backend nên toàn bộ thao tác
// thêm/sửa/xóa được lưu vào localStorage, seed lần đầu từ dữ liệu mock trong
// libraryData.js. Khi nhóm có API thật: thay các hàm getAll/add/update/remove
// bên trong makeStore() bằng fetch tương ứng (GET/POST/PUT/DELETE), phần gọi
// từ các trang Admin (store.useCollection(), store.add(), ...) giữ nguyên.

import { useEffect, useState } from "react";
import { books, categories, authors } from "./libraryData";

function makeStore(storageKey, seedData, idField) {
  function load() {
    try {
      const raw = localStorage.getItem(storageKey);
      if (raw) return JSON.parse(raw);
    } catch {
      /* rơi xuống seed nếu localStorage lỗi/hỏng dữ liệu */
    }
    localStorage.setItem(storageKey, JSON.stringify(seedData));
    return seedData;
  }

  function save(list) {
    localStorage.setItem(storageKey, JSON.stringify(list));
    window.dispatchEvent(new Event(`libhub-admin-${storageKey}`));
  }

  function getAll() {
    return load();
  }

  function getById(id) {
    return load().find((item) => item[idField] === id);
  }

  function add(item) {
    const list = load();
    const nextId = list.length ? Math.max(...list.map((i) => i[idField])) + 1 : 1;
    const newItem = { ...item, [idField]: nextId };
    save([...list, newItem]);
    return newItem;
  }

  function update(id, patch) {
    save(load().map((item) => (item[idField] === id ? { ...item, ...patch } : item)));
  }

  function remove(id) {
    save(load().filter((item) => item[idField] !== id));
  }

  function resetToSeed() {
    save(seedData);
  }

  function useCollection() {
    const [items, setItems] = useState(load);
    useEffect(() => {
      const eventName = `libhub-admin-${storageKey}`;
      const refresh = () => setItems(load());
      window.addEventListener(eventName, refresh);
      window.addEventListener("storage", refresh);
      return () => {
        window.removeEventListener(eventName, refresh);
        window.removeEventListener("storage", refresh);
      };
    }, []);
    return items;
  }

  return { getAll, getById, add, update, remove, resetToSeed, useCollection };
}

// --- Bản sao sách (BookCopies) — chưa có mock sẵn nên sinh seed ở đây,
// mỗi sách có 2 bản sao, bản đầu theo đúng status của sách, bản 2 luôn còn.
function buildCopiesSeed() {
  const copies = [];
  let copyId = 1;
  books.forEach((book) => {
    for (let i = 0; i < 2; i += 1) {
      copies.push({
        copy_id: copyId,
        book_id: book.book_id,
        barcode: `LH-${book.book_id}-${String(i + 1).padStart(2, "0")}`,
        shelf_location: `Kệ ${String.fromCharCode(65 + (book.category_id - 1))}-${book.book_id % 10}`,
        status: i === 0 ? book.status : "available",
        acquired_date: "2024-01-01",
      });
      copyId += 1;
    }
  });
  return copies;
}

// --- Người dùng — gộp danh sách mock trong auth/mockUsers.js làm seed ban đầu.
// Bảng này TÁCH RIÊNG khỏi cơ chế đăng nhập thật (useAuth) vì mock hiện chưa
// có 1 nguồn Users trung tâm; khi có backend, cả 2 nơi sẽ cùng gọi chung 1 API.
function buildUsersSeed() {
  return [
    { user_id: 1, username: "admin", full_name: "Quản trị viên", role_id: 1, status: "active" },
    { user_id: 2, username: "user", full_name: "Bạn đọc demo", role_id: 2, status: "active" },
    { user_id: 3, username: "librian", full_name: "Thủ thư demo", role_id: 3, status: "active" },
  ];
}

export const booksStore = makeStore("libhub_admin_books", books, "book_id");
export const categoriesStore = makeStore("libhub_admin_categories", categories, "category_id");
export const authorsStore = makeStore("libhub_admin_authors", authors, "author_id");
export const copiesStore = makeStore("libhub_admin_copies", buildCopiesSeed(), "copy_id");
export const usersStore = makeStore("libhub_admin_users", buildUsersSeed(), "user_id");

export const ROLE_OPTIONS = [
  { value: 1, label: "Admin" },
  { value: 2, label: "User" },
  { value: 3, label: "Librarian" },
];

export function getRoleLabel(role_id) {
  return ROLE_OPTIONS.find((r) => r.value === role_id)?.label ?? "—";
}
