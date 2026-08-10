import { useRef, useState } from "react";
import { downloadDataFile, importBooksFile } from "../services/DataExchangeService";

export default function BookDataTools({ onImported }) {
  const inputRef = useRef(null);
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState("");
  const [errors, setErrors] = useState([]);

  async function handleFile(event) {
    const file = event.target.files?.[0];
    event.target.value = "";
    if (!file) return;
    setBusy(true);
    setMessage("");
    setErrors([]);
    try {
      const result = await importBooksFile(file);
      setMessage(`Đã nhập ${result.importedRows}/${result.totalRows} dòng; bỏ qua ${result.skippedRows} dòng.`);
      setErrors(result.errors ?? []);
      await onImported?.();
    } catch (error) {
      setMessage(error.message || "Không thể nhập file.");
    } finally {
      setBusy(false);
    }
  }

  async function download(endpoint, name) {
    setBusy(true);
    setMessage("");
    try {
      await downloadDataFile(endpoint, name);
    } catch (error) {
      setMessage(error.message || "Không thể tải file.");
    } finally {
      setBusy(false);
    }
  }

  return (
    <div style={{ display: "flex", alignItems: "center", gap: 8, flexWrap: "wrap", justifyContent: "flex-end" }}>
      <input ref={inputRef} type="file" accept=".csv,.xls,.xlsx" hidden onChange={handleFile} />
      <button type="button" className="lh-btn lh-btn--ghost" disabled={busy} onClick={() => inputRef.current?.click()}>
        {busy ? "Đang xử lý..." : "Nhập CSV/Excel"}
      </button>
      <button type="button" className="lh-btn lh-btn--ghost" disabled={busy}
        onClick={() => download("/books/import/template.xlsx", "libhub-book-import-template.xlsx")}>
        Tải file mẫu
      </button>
      <button type="button" className="lh-btn lh-btn--ghost" disabled={busy}
        onClick={() => download("/reports/statistics.csv", "libhub-statistics.csv")}>
        Báo cáo CSV
      </button>
      <button type="button" className="lh-btn lh-btn--ghost" disabled={busy}
        onClick={() => download("/reports/statistics.xlsx", "libhub-statistics.xlsx")}>
        Báo cáo Excel
      </button>
      {message && (
        <div style={{ width: "100%", textAlign: "right", fontSize: "0.84rem", color: errors.length ? "var(--lh-rust)" : "var(--lh-forest)" }}>
          {message}
          {errors.slice(0, 5).map((error) => (
            <div key={`${error.row}-${error.message}`}>Dòng {error.row}: {error.message}</div>
          ))}
          {errors.length > 5 && <div>Và {errors.length - 5} lỗi khác.</div>}
        </div>
      )}
    </div>
  );
}
