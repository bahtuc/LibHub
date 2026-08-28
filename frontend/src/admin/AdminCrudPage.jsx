// src/admin/AdminCrudPage.jsx
//
// Trang CRUD generic dùng chung cho Sách / Bản sao sách / Thể loại / Tác giả /
// Người dùng — mỗi trang cụ thể chỉ cần khai báo columns + fields, không phải
// viết lại bảng/form từ đầu.

import { useState } from "react";
import Icon from "../components/Icon";
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
}) {
  const items = store.useCollection();
  const [editing, setEditing] = useState(null);
  const [confirmId, setConfirmId] = useState(null);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const isNew = editing && !items.some((i) => i[idField] === editing[idField]);
  const visibleFields = fields.filter((field) =>
    (!field.createOnly || isNew)
    && (!field.editOnly || !isNew)
    && (!field.when || editing == null || field.when(editing, isNew)));

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
      setError(err.message || "Không thể lưu dữ liệu.");
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
      setError(err.message || "Không thể xóa dữ liệu.");
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="lh-admin-page">
      <div className="lh-admin-page__head">
        <div>
          <h1 className="lh-admin-page__title">{title}</h1>
          {subtitle && <p className="lh-admin-page__subtitle">{subtitle}</p>}
        </div>
        <div style={{ display: "flex", gap: 10, alignItems: "flex-start", flexWrap: "wrap", justifyContent: "flex-end" }}>
          {headerActions}
          {!hideAdd && (
            <button className="lh-btn lh-btn--primary" onClick={openAdd}>
              <Icon name="plus" size={16} /> Thêm mới
            </button>
          )}
        </div>
      </div>

      {editing && (
        <form className="lh-admin-form" onSubmit={handleSubmit}>
          <h2 className="lh-admin-form__heading">
            <Icon name={isNew ? "plus" : "edit"} size={18} />
            {isNew ? `Thêm mới — ${title}` : `Chỉnh sửa — ${title}`}
          </h2>

          <div className="lh-admin-form__grid">
            {visibleFields.map((f) => (
              <label key={f.name} className="lh-field lh-admin-form__field">
                {f.label}

                {f.type === "select" ? (
                  <select
                    value={editing[f.name] ?? ""}
                    onChange={(e) =>
                      handleChange(f.name, f.numeric ? Number(e.target.value) : e.target.value)
                    }
                    required={f.required}
                  >
                    <option value="" disabled>
                      Chọn…
                    </option>
                    {f.options.map((o) => (
                      <option key={o.value} value={o.value}>
                        {o.label}
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

                {f.previewImage && editing[f.name] && (
                  <span className="lh-admin-form__image-preview">
                    <img
                      src={editing[f.name]}
                      alt="Xem trước ảnh bìa"
                      onLoad={(event) => {
                        event.currentTarget.style.display = "block";
                        event.currentTarget.nextElementSibling.style.display = "none";
                      }}
                      onError={(event) => {
                        event.currentTarget.style.display = "none";
                        event.currentTarget.nextElementSibling.style.display = "block";
                      }}
                    />
                    <small>Không tải được ảnh. Hãy kiểm tra lại đường dẫn URL.</small>
                  </span>
                )}
              </label>
            ))}
          </div>

          <div className="lh-admin-form__actions">
            <button type="submit" className="lh-btn lh-btn--primary" disabled={saving}>
              {saving ? "Đang lưu…" : isNew ? "Thêm" : "Lưu thay đổi"}
            </button>
            <button type="button" className="lh-btn lh-btn--ghost" onClick={closeForm}>
              Hủy
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
                <th key={c.key}>{c.label}</th>
              ))}
              <th className="lh-admin-table__actions-head">Thao tác</th>
            </tr>
          </thead>
          <tbody>
            {items.map((item) => {
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
                      aria-label="Sửa"
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
                            Xóa?
                          </button>
                          <button className="lh-admin-confirm__no" onClick={() => setConfirmId(null)}>
                            <Icon name="x" size={14} />
                          </button>
                        </span>
                      ) : (
                        <button
                          className="lh-admin-icon-btn lh-admin-icon-btn--danger"
                          aria-label="Xóa"
                          disabled={!deletable}
                          title={!deletable ? "Không thể xóa mục này" : undefined}
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
                  Chưa có dữ liệu.
                </td>
              </tr>
            )}
          </tbody>
        </table>
        </div>
      </div>
    </div>
  );
}
