// src/admin/AdminCrudPage.jsx
//
// Trang CRUD generic dùng chung cho Sách / Bản sao sách / Thể loại / Tác giả /
// Người dùng — mỗi trang cụ thể chỉ cần khai báo columns + fields, không phải
// viết lại bảng/form từ đầu.

import { useEffect, useState } from "react";
import Icon from "../components/Icon";
import Pagination from "../components/Pagination";
import { useLanguage } from "../i18n/LanguageContext";
import "./admin.css";

export default function AdminCrudPage({
  title,
  subtitle,
  store,
  idField,
  columns,
  fields,
  emptyItem,
  canDelete, // (item) => boolean, mặc định luôn cho xóa
  hideDelete = false, // ẩn hẳn nút xóa (vd: trang Thủ thư chỉ được Ẩn/Hiện, không được xóa)
  rowActions, // (item) => JSX, render thêm nút riêng trước nút Sửa/Xóa
  headerActions,
  hideAdd = false,
  pageSize = 10,
}) {
  const { t, translateLabel } = useLanguage();
  const items = store.useCollection();
  const [currentPage, setCurrentPage] = useState(1);
  const [editing, setEditing] = useState(null);
  const [confirmId, setConfirmId] = useState(null);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const isNew = editing && !items.some((i) => i[idField] === editing[idField]);
  const visibleFields = fields.filter((field) =>
    (!field.createOnly || isNew)
    && (!field.editOnly || !isNew)
    && (!field.when || editing == null || field.when(editing, isNew)));
  const totalPages = Math.max(1, Math.ceil(items.length / pageSize));
  const pageStart = (currentPage - 1) * pageSize;
  const paginatedItems = items.slice(pageStart, pageStart + pageSize);

  useEffect(() => {
    setCurrentPage((page) => Math.min(page, totalPages));
  }, [totalPages]);

  function openAdd() {
    setEditing({ ...emptyItem });
    setConfirmId(null);
    setError("");
  }
  function openEdit(item) {
    setEditing({ ...item });
    setConfirmId(null);
    setError("");
  }
  function closeForm() {
    setEditing(null);
  }
  function handleChange(name, value) {
    setEditing((e) => ({ ...e, [name]: value }));
  }
  async function handleSubmit(e) {
    e.preventDefault();
    setSaving(true);
    setError("");
    try {
      if (isNew) {
        await store.add(editing);
      } else {
        await store.update(editing[idField], editing);
      }
      setEditing(null);
    } catch (err) {
      setError(err.message || t("admin.saveError"));
    } finally {
      setSaving(false);
    }
  }
  async function handleDelete(id) {
    setSaving(true);
    setError("");
    try {
      await store.remove(id);
      setConfirmId(null);
    } catch (err) {
      setError(err.message || t("admin.deleteError"));
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="lh-admin-page">
      <div className="lh-admin-page__head">
        <div>
          <h1 className="lh-admin-page__title">{translateLabel(title)}</h1>
          {subtitle && <p className="lh-admin-page__subtitle">{translateLabel(subtitle)}</p>}
        </div>
        <div style={{ display: "flex", gap: 10, alignItems: "flex-start", flexWrap: "wrap", justifyContent: "flex-end" }}>
          {headerActions}
          {!hideAdd && (
            <button className="lh-btn lh-btn--primary" onClick={openAdd}>
              <Icon name="plus" size={16} /> {t("admin.add")}
            </button>
          )}
        </div>
      </div>

      {editing && (
        <form className="lh-admin-form" onSubmit={handleSubmit}>
          <h2 className="lh-admin-form__heading">
            <Icon name={isNew ? "plus" : "edit"} size={18} />
            {isNew ? t("admin.addTitle", { title: translateLabel(title) }) : t("admin.edit", { title: translateLabel(title) })}
          </h2>

          <div className="lh-admin-form__grid">
            {visibleFields.map((f) => (
              <label key={f.name} className="lh-field lh-admin-form__field">
                {translateLabel(f.label)}

                {f.type === "select" ? (
                  <select
                    value={editing[f.name] ?? ""}
                    onChange={(e) =>
                      handleChange(f.name, f.numeric ? Number(e.target.value) : e.target.value)
                    }
                    required={f.required}
                  >
                    <option value="" disabled>
                      {t("admin.choose")}
                    </option>
                    {f.options.map((o) => (
                      <option key={o.value} value={o.value}>
                        {translateLabel(o.label)}
                      </option>
                    ))}
                  </select>
                ) : f.type === "textarea" ? (
                  <textarea
                    rows={3}
                    value={editing[f.name] ?? ""}
                    onChange={(e) => handleChange(f.name, e.target.value)}
                    required={f.required}
                  />
                ) : f.type === "checkbox" ? (
                  <input
                    type="checkbox"
                    checked={!!editing[f.name]}
                    onChange={(e) => handleChange(f.name, e.target.checked)}
                    style={{ width: 18, height: 18, alignSelf: "flex-start" }}
                  />
                ) : f.type === "file" ? (
                  <input
                    type="file"
                    accept={f.accept}
                    onChange={(e) => handleChange(f.name, e.target.files?.[0] ?? null)}
                    required={f.required && !editing[f.existingImageField]}
                  />
                ) : (
                  <input
                    type={f.type || "text"}
                    value={editing[f.name] ?? ""}
                    placeholder={f.placeholder}
                    maxLength={f.maxLength}
                    onChange={(e) =>
                      handleChange(f.name, f.type === "number" ? Number(e.target.value) : e.target.value)
                    }
                    required={f.required}
                  />
                )}

                {f.previewImage && (
                  <ImagePreview
                    file={editing[f.name]}
                    fallback={editing[f.existingImageField]}
                    alt={t("admin.coverPreview")}
                    errorText={t("admin.coverError")}
                  />
                )}
              </label>
            ))}
          </div>

          <div className="lh-admin-form__actions">
            <button type="submit" className="lh-btn lh-btn--primary" disabled={saving}>
              {saving ? t("admin.saving") : isNew ? t("admin.add") : t("admin.save")}
            </button>
            <button type="button" className="lh-btn lh-btn--ghost" onClick={closeForm}>
              {t("admin.cancel")}
            </button>
          </div>
        </form>
      )}

      {error && <p className="lh-auth-form__error">{error}</p>}

      <div className="lh-admin-table-wrap">
        <div className="lh-admin-table-scroll">
        <table className="lh-admin-table">
          <thead>
            <tr>
              {columns.map((c) => (
                <th key={c.key}>{translateLabel(c.label)}</th>
              ))}
              <th className="lh-admin-table__actions-head">{t("admin.actions")}</th>
            </tr>
          </thead>
          <tbody>
            {paginatedItems.map((item) => {
              const deletable = canDelete ? canDelete(item) : true;
              return (
                <tr key={item[idField]}>
                  {columns.map((c) => (
                    <td key={c.key}>{c.render ? c.render(item) : item[c.key]}</td>
                  ))}
                  <td className="lh-admin-table__actions">
                    {rowActions && rowActions(item)}
                    <button
                      className="lh-admin-icon-btn"
                      aria-label={t("admin.editAction")}
                      onClick={() => openEdit(item)}
                    >
                      <Icon name="edit" size={16} />
                    </button>

                    {!hideDelete &&
                      (confirmId === item[idField] ? (
                        <span className="lh-admin-confirm">
                          <button
                            className="lh-admin-confirm__yes"
                            onClick={() => handleDelete(item[idField])}
                          >
                            {t("admin.deleteConfirm")}
                          </button>
                          <button className="lh-admin-confirm__no" onClick={() => setConfirmId(null)}>
                            <Icon name="x" size={14} />
                          </button>
                        </span>
                      ) : (
                        <button
                          className="lh-admin-icon-btn lh-admin-icon-btn--danger"
                          aria-label={t("admin.deleteAction")}
                          disabled={!deletable}
                          title={!deletable ? t("admin.cannotDelete") : undefined}
                          onClick={() => setConfirmId(item[idField])}
                        >
                          <Icon name="trash" size={16} />
                        </button>
                      ))}
                  </td>
                </tr>
              );
            })}
            {items.length === 0 && (
              <tr>
                <td colSpan={columns.length + 1} className="lh-admin-table__empty">
                  {t("admin.empty")}
                </td>
              </tr>
            )}
          </tbody>
        </table>
        </div>
        {items.length > 0 && (
          <div className="lh-admin-table-pagination">
            <p className="lh-admin-table-pagination__summary">
              {t("admin.summary", { from: pageStart + 1, to: Math.min(pageStart + pageSize, items.length), count: items.length })}
            </p>
            <Pagination
              currentPage={currentPage}
              totalPages={totalPages}
              onPageChange={setCurrentPage}
              label={`${t("pagination.label")} ${translateLabel(title)}`}
            />
          </div>
        )}
      </div>
    </div>
  );
}

function ImagePreview({ file, fallback, alt, errorText }) {
  const [source, setSource] = useState(fallback || "");

  useEffect(() => {
    if (!(file instanceof File)) {
      setSource(fallback || "");
      return undefined;
    }
    const objectUrl = URL.createObjectURL(file);
    setSource(objectUrl);
    return () => URL.revokeObjectURL(objectUrl);
  }, [file, fallback]);

  if (!source) return null;
  return (
    <span className="lh-admin-form__image-preview">
      <img
        src={source}
        alt={alt}
        onLoad={(event) => {
          event.currentTarget.style.display = "block";
          event.currentTarget.nextElementSibling.style.display = "none";
        }}
        onError={(event) => {
          event.currentTarget.style.display = "none";
          event.currentTarget.nextElementSibling.style.display = "block";
        }}
      />
      <small>{errorText}</small>
    </span>
  );
}
