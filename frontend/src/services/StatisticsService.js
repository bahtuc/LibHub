import { apiRequest } from "../JS/APi.js";

export function getMonthlySummary(month) {
  const query = month ? `?month=${encodeURIComponent(month)}` : "";
  return apiRequest(`/statistics/monthly-summary${query}`, { method: "GET" });
}
