// src/data/librarianStore.js
//
// Nghiệp vụ mượn/trả/phạt của thủ thư — dựa theo BorrowTickets, BorrowDetails,
// Returns, ReturnDetails, Fines trong DB của nhóm.
//
// Đơn giản hoá cho bản demo: gộp BorrowDetails + Returns + ReturnDetails + Fines
// thành mảng `items` nằm ngay trong từng ticket (mỗi item = 1 bản sao được mượn
// trong phiếu đó), thay vì tách thành 4 bảng rời với khoá ngoại chồng chéo.
// Khi có backend thật, đây chính là chỗ nối 4 endpoint tương ứng; phần gọi từ
// UI (createTicket, returnItems, markFinePaid...) giữ nguyên chữ ký hàm.

import { useEffect, useState } from "react";
import { copiesStore } from "./adminStore";

const TICKETS_KEY = "libhub_borrow_tickets";

export const FINE_PER_DAY = 5000; // đ / ngày trễ hạn (demo)
export const FINE_DAMAGED = 50000; // đ, sách trả về hư hỏng (demo)
export const FINE_LOST = 150000; // đ, sách bị mất (demo)

export const CONDITION_OPTIONS = [
  { value: "tot", label: "Tốt" },
  { value: "hu_hong", label: "Hư hỏng" },
  { value: "mat", label: "Mất" },
];

function iso(d) {
  return d.toISOString().slice(0, 10);
}
function addDays(base, n) {
  const d = new Date(base);
  d.setDate(d.getDate() + n);
  return d;
}

function seedTickets() {
  const today = new Date();
  return [
    {
      ticket_id: 1,
      user_id: 2,
      borrow_date: iso(addDays(today, -10)),
      due_date: iso(addDays(today, -3)),
      status: "borrowing",
      note: "",
      items: [
        {
          copy_id: 5,
          book_id: 103,
          borrowed_at: iso(addDays(today, -10)),
          returned_at: null,
          condition_book: null,
          fine_amount: 0,
          fine_paid: false,
        },
      ],
    },
    {
      ticket_id: 2,
      user_id: 2,
      borrow_date: iso(addDays(today, -20)),
      due_date: iso(addDays(today, -6)),
      status: "returned",
      note: "",
      items: [
        {
          copy_id: 11,
          book_id: 106,
          borrowed_at: iso(addDays(today, -20)),
          returned_at: iso(addDays(today, -5)),
          condition_book: "tot",
          fine_amount: 5000,
          fine_paid: false,
        },
      ],
    },
  ];
}

function load() {
  try {
    const raw = localStorage.getItem(TICKETS_KEY);
    if (raw) return JSON.parse(raw);
  } catch {
    /* rơi xuống seed nếu dữ liệu hỏng */
  }
  const seed = seedTickets();
  localStorage.setItem(TICKETS_KEY, JSON.stringify(seed));
  return seed;
}

function save(list) {
  localStorage.setItem(TICKETS_KEY, JSON.stringify(list));
  window.dispatchEvent(new Event("libhub-tickets-updated"));
}

export function useTickets() {
  const [tickets, setTickets] = useState(load);
  useEffect(() => {
    const refresh = () => setTickets(load());
    window.addEventListener("libhub-tickets-updated", refresh);
    window.addEventListener("storage", refresh);
    return () => {
      window.removeEventListener("libhub-tickets-updated", refresh);
      window.removeEventListener("storage", refresh);
    };
  }, []);
  return tickets;
}

export function getTickets() {
  return load();
}

/** Trạng thái hiển thị: đang mượn / quá hạn / đã trả toàn bộ. */
export function getTicketStatus(ticket) {
  if (ticket.status === "returned") return "returned";
  if (new Date() > new Date(ticket.due_date)) return "overdue";
  return "borrowing";
}

export function createTicket({ user_id, due_date, copy_ids, note }) {
  const list = load();
  const nextId = list.length ? Math.max(...list.map((t) => t.ticket_id)) + 1 : 1;
  const today = iso(new Date());

  const items = copy_ids.map((copy_id) => {
    const copy = copiesStore.getById(Number(copy_id));
    return {
      copy_id: Number(copy_id),
      book_id: copy?.book_id,
      borrowed_at: today,
      returned_at: null,
      condition_book: null,
      fine_amount: 0,
      fine_paid: false,
    };
  });

  const newTicket = {
    ticket_id: nextId,
    user_id: Number(user_id),
    borrow_date: today,
    due_date,
    status: "borrowing",
    note: note || "",
    items,
  };

  save([...list, newTicket]);
  copy_ids.forEach((cid) => copiesStore.update(Number(cid), { status: "borrowed" }));
  return newTicket;
}

function computeFine(ticket, item) {
  if (item.condition_book === "mat") return FINE_LOST;
  if (item.condition_book === "hu_hong") return FINE_DAMAGED;
  const lateDays = Math.max(
    0,
    Math.round((new Date() - new Date(ticket.due_date)) / 86400000)
  );
  return lateDays * FINE_PER_DAY;
}

/** returns: [{ copy_id, condition_book }] — xử lý trả 1 hoặc nhiều bản sao cùng lúc. */
export function returnItems(ticket_id, returns) {
  const list = load();
  const today = iso(new Date());

  const updated = list.map((t) => {
    if (t.ticket_id !== ticket_id) return t;
    const items = t.items.map((it) => {
      const r = returns.find((x) => x.copy_id === it.copy_id);
      if (!r) return it;
      const patched = { ...it, returned_at: today, condition_book: r.condition_book };
      patched.fine_amount = computeFine(t, patched);
      return patched;
    });
    const allReturned = items.every((it) => it.returned_at);
    return { ...t, items, status: allReturned ? "returned" : "borrowing" };
  });

  save(updated);
  returns.forEach(({ copy_id, condition_book }) => {
    copiesStore.update(copy_id, { status: condition_book === "mat" ? "lost" : "available" });
  });
}

export function markFinePaid(ticket_id, copy_id, paid) {
  const list = load();
  const updated = list.map((t) =>
    t.ticket_id !== ticket_id
      ? t
      : {
          ...t,
          items: t.items.map((it) => (it.copy_id === copy_id ? { ...it, fine_paid: paid } : it)),
        }
  );
  save(updated);
}

/** Danh sách phẳng mọi khoản phạt (kèm ticket_id, user_id, book_id) để hiển thị bảng Phạt. */
export function getAllFines() {
  return load().flatMap((t) =>
    t.items
      .filter((it) => it.fine_amount > 0)
      .map((it) => ({ ...it, ticket_id: t.ticket_id, user_id: t.user_id }))
  );
}
