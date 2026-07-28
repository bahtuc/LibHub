export function resolveCoverUrl(value) {
  if (!value) return null;

  const cover = String(value).trim();
  if (!cover) return null;

  if (
    cover.startsWith("http://") ||
    cover.startsWith("https://") ||
    cover.startsWith("data:") ||
    cover.startsWith("blob:") ||
    cover.startsWith("/")
  ) {
    return cover;
  }

  const filename = cover.replaceAll("\\", "/").split("/").pop();
  return `/covers/${encodeURIComponent(filename)}`;
}
