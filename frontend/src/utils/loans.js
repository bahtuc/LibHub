// Borrow / return workflow helpers.
//
// The backend BorrowTickets table has no column linking a ticket to the
// physical copy it lends, so we encode {b:bookId, c:copyId, t:title} as JSON
// in the ticket `note`. That lets "My Loans" show what was borrowed and lets a
// return flip the right copy back to Available — all persisted, no schema change.

import { findCopiesByBook, updateBookCopyStatus } from "../services/BookCopyService";
import { createBorrowTicket, updateBorrowTicket } from "../services/BorrowTicketService";
import { assessOverdueFine } from "../services/FineService";
import { todayISO, addDaysISO, daysUntil } from "./format";

export const LOAN_DAYS = 14;

export const COPY_STATUS = {
    AVAILABLE: "Available",
    BORROWED: "Borrowed",
    LOST: "Lost",
    MAINTENANCE: "Maintenance",
};

export const TICKET_STATUS = {
    BORROWED: "Borrowed",
    RETURNED: "Returned",
};

export function isAvailable(copy) {
    return (copy?.status || "").toLowerCase() === "available";
}

// { total, available } for a list of copies.
export function summarizeCopies(copies = []) {
    const total = copies.length;
    const available = copies.filter(isAvailable).length;
    return { total, available };
}

export function parseLoanNote(note) {
    if (!note) return null;
    try {
        const o = JSON.parse(note);
        if (o && (o.b || o.c || o.t)) return { bookId: o.b, copyId: o.c, title: o.t };
    } catch {
        /* legacy / free-text note */
    }
    return null;
}

export function loanTitle(ticket) {
    return parseLoanNote(ticket?.note)?.title || "Sách";
}

export function isReturned(ticket) {
    return (ticket?.status || "").toLowerCase() === "returned";
}

// Borrow the first available copy of `book` for `userId`.
// Returns the created ticket. Throws a friendly message if nothing is free.
export async function borrowBook(book, userId) {
    const bookId = book.bookId;
    const copies = await findCopiesByBook(bookId);
    const copy = (copies || []).find(isAvailable);
    if (!copy) {
        throw new Error("Hiện không còn bản sao nào sẵn sàng để mượn.");
    }

    await updateBookCopyStatus(copy.copyId, COPY_STATUS.BORROWED);

    const note = JSON.stringify({ b: bookId, c: copy.copyId, t: book.title });
    try {
        return await createBorrowTicket({
            userId,
            borrowDate: todayISO(),
            dueDate: addDaysISO(LOAN_DAYS),
            status: TICKET_STATUS.BORROWED,
            note,
        });
    } catch (err) {
        // Roll the copy back so it isn't stuck as Borrowed with no ticket.
        await updateBookCopyStatus(copy.copyId, COPY_STATUS.AVAILABLE).catch(() => {});
        throw err;
    }
}

// Mark a loan returned: free its copy, flip the ticket to Returned, and assess
// an overdue fine if it's past due. Returns { fine } when a fine was created.
export async function returnLoan(ticket) {
    const meta = parseLoanNote(ticket.note);
    if (meta?.copyId) {
        await updateBookCopyStatus(meta.copyId, COPY_STATUS.AVAILABLE);
    }
    await updateBorrowTicket(ticket.ticketId, {
        userId: ticket.userId,
        borrowDate: ticket.borrowDate,
        dueDate: ticket.dueDate,
        note: ticket.note,
        status: TICKET_STATUS.RETURNED,
    });

    // Late? Ask the backend to record an overdue fine (rate × days late).
    let fine = null;
    if (ticket.dueDate && (daysUntil(ticket.dueDate) ?? 0) < 0) {
        try {
            const res = await assessOverdueFine({
                dueDate: String(ticket.dueDate).slice(0, 10),
                ticketId: ticket.ticketId,
                title: meta?.title,
            });
            if (res?.created) fine = res.fine;
        } catch {
            /* fine assessment is best-effort; the return already succeeded */
        }
    }
    return { fine };
}
