// src/data/useBookCovers.js
//
// Cơ chế tạm để gắn ảnh bìa sách thật mà KHÔNG cần backend:
// lưu 1 object { [book_id]: "url ảnh" } vào localStorage, key "libhub_book_covers".
// BookCard sẽ tự soi localStorage này trước, có ảnh thì hiện ảnh, không có thì
// dùng khối gradient + chữ cái đầu như cũ.
//
// Cách gắn ảnh nhanh (console DevTools của trình duyệt), ví dụ:
//
//   localStorage.setItem("libhub_book_covers", JSON.stringify({
//     101: "https://.../cho-toi-xin-mot-ve-di-tuoi-tho.jpg",
//     103: "https://.../atomic-habits.jpg",
//   }));
//   // rồi reload lại trang (F5)
//
// Hoặc dùng 2 hàm setBookCover()/setBookCovers() export dưới đây trong code.
//
// Khi có backend thật: bỏ hẳn file này, để cover_image lấy trực tiếp từ API
// (field cover_image trong bảng Books) là xong.

import { useEffect, useState } from "react";

const STORAGE_KEY = "libhub_book_covers";

export function getStoredCovers() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw ? JSON.parse(raw) : {};
  } catch {
    return {};
  }
}

export function setBookCover(book_id, url) {
  const covers = getStoredCovers();
  covers[book_id] = url;
  localStorage.setItem(STORAGE_KEY, JSON.stringify(covers));
  window.dispatchEvent(new Event("libhub-covers-updated"));
}

export function setBookCovers(map) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(map));
  window.dispatchEvent(new Event("libhub-covers-updated"));
}

export function clearBookCovers() {
  localStorage.removeItem(STORAGE_KEY);
  window.dispatchEvent(new Event("libhub-covers-updated"));
}

/** Hook: trả về { [book_id]: url } hiện có, tự cập nhật khi có thay đổi. */
export function useBookCovers() {
  const [covers, setCovers] = useState(getStoredCovers);

  useEffect(() => {
    function refresh() {
      setCovers(getStoredCovers());
    }
    window.addEventListener("storage", refresh); // đổi từ tab khác
    window.addEventListener("libhub-covers-updated", refresh); // đổi từ cùng tab
    return () => {
      window.removeEventListener("storage", refresh);
      window.removeEventListener("libhub-covers-updated", refresh);
    };
  }, []);

  return covers;
}
