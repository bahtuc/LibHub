import { updateBookCopyStatus } from "../services/BookCopyService";
import {
    borrowBook as requestBorrowBook,
    updateBorrowTicket,
} from "../services/BorrowTicketService";
import { assessOverdueFine } from "../services/FineService";
import { daysUntil } from "./format";

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

export function summarizeCopies(copies = []) {
    return {
        total: copies.length,
        available: copies.filter(isAvailable).length,
    };
}

export function parseLoanNote(note) {
    if (!note) return null;
    try {
        const value = JSON.parse(note);
        if (value && (value.b || value.c || value.t)) {
            return { bookId: value.b, copyId: value.c, title: value.t };
        }
    } catch {
        // Legacy free-text note.
    }
    return null;
}

export function loanTitle(ticket) {
    return parseLoanNote(ticket?.note)?.title || "Sách";
}

export function isReturned(ticket) {
    return (ticket?.status || "").toLowerCase() === "returned";
}

// Selection and locking of the physical copy happen atomically in the backend.
export function borrowBook(book) {
    return requestBorrowBook(book.bookId ?? book.book_id);
}

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

    let fine = null;
    if (ticket.dueDate && (daysUntil(ticket.dueDate) ?? 0) < 0) {
        try {
            const response = await assessOverdueFine({
                dueDate: String(ticket.dueDate).slice(0, 10),
                ticketId: ticket.ticketId,
                title: meta?.title,
            });
            if (response?.created) fine = response.fine;
        } catch {
            // Fine assessment is best-effort; returning has already succeeded.
        }
    }
    return { fine };
}
