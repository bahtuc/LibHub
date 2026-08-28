export function getTicketStatus(ticket) {
  const status = String(ticket?.status || "").trim().toLowerCase();
  if (status === "returned") return "returned";
  if (status === "cancelled" || status === "canceled") return "cancelled";
  if (status === "pendingpayment") return "payment_pending";
  if (status === "overdue") return "overdue";

  const dueDate = ticket?.dueDate ? new Date(`${ticket.dueDate}T23:59:59`) : null;
  if (dueDate && !Number.isNaN(dueDate.getTime()) && dueDate < new Date()) return "overdue";
  return "borrowing";
}

export function isFinePaid(item) {
  return String(item?.finePaidStatus || "").trim().toLowerCase() === "paid";
}
