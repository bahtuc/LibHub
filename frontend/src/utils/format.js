// Small formatting / date helpers shared across pages.

export function todayISO() {
    return new Date().toISOString().slice(0, 10); // yyyy-mm-dd
}

export function addDaysISO(days, from = new Date()) {
    const d = new Date(from);
    d.setDate(d.getDate() + days);
    return d.toISOString().slice(0, 10);
}

// Accepts "2026-07-07" or "2026-07-07T00:00:00.000Z" and renders dd/mm/yyyy.
export function formatDate(value) {
    if (!value) return "—";
    const d = new Date(value);
    if (Number.isNaN(d.getTime())) return String(value);
    const dd = String(d.getDate()).padStart(2, "0");
    const mm = String(d.getMonth() + 1).padStart(2, "0");
    return `${dd}/${mm}/${d.getFullYear()}`;
}

// Whole days until `dueDate` (negative => overdue). null if no date.
export function daysUntil(dueDate) {
    if (!dueDate) return null;
    const due = new Date(dueDate);
    if (Number.isNaN(due.getTime())) return null;
    const today = new Date();
    due.setHours(0, 0, 0, 0);
    today.setHours(0, 0, 0, 0);
    return Math.round((due - today) / 86400000);
}
