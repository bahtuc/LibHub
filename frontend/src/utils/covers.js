import { API_BASE_URL } from "../JS/APi";

export function resolveCoverUrl(value) {
  if (!value) return null;

  const cover = String(value).trim();
  if (!cover) return null;

  if (
    cover.startsWith("http://") ||
    cover.startsWith("https://") ||
    cover.startsWith("data:") ||
    cover.startsWith("blob:")
  ) {
    return cover;
  }

  if (cover.startsWith("/uploads/")) {
    return `${new URL(API_BASE_URL).origin}${cover}`;
  }
  if (cover.startsWith("/")) return cover;

  const filename = cover.replaceAll("\\", "/").split("/").pop();
  return `/covers/${encodeURIComponent(filename)}`;
}
