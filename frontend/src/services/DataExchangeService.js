import { API_BASE_URL } from "../JS/APi.js";

async function parseError(response) {
  const type = response.headers.get("content-type") || "";
  if (type.includes("application/json")) {
    const data = await response.json().catch(() => null);
    return data?.message || data?.error || `Lỗi ${response.status}`;
  }
  return (await response.text().catch(() => "")) || `Lỗi ${response.status}`;
}

export async function importBooksFile(file) {
  const formData = new FormData();
  formData.append("file", file);
  const response = await fetch(`${API_BASE_URL}/books/import`, {
    method: "POST",
    body: formData,
    credentials: "include",
  });
  if (!response.ok) throw new Error(await parseError(response));
  return response.json();
}

export async function downloadDataFile(endpoint, fallbackName) {
  const response = await fetch(`${API_BASE_URL}${endpoint}`, { credentials: "include" });
  if (!response.ok) throw new Error(await parseError(response));
  const blob = await response.blob();
  const disposition = response.headers.get("content-disposition") || "";
  const match = disposition.match(/filename\*?=(?:UTF-8''|\")?([^\";]+)/i);
  const filename = match ? decodeURIComponent(match[1].trim()) : fallbackName;
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement("a");
  anchor.href = url;
  anchor.download = filename;
  document.body.appendChild(anchor);
  anchor.click();
  anchor.remove();
  URL.revokeObjectURL(url);
}
