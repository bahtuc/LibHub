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
}) {
  const items = store.useCollection();
  const [editing, setEditing] = useState(null);
  const [confirmId, setConfirmId] = useState(null);
  const isNew = editing && !items.some((i) => i[idField] === editing[idField]);

  function openAdd() {
    setEditing({ ...emptyItem });
    setConfirmId(null);
  }
  function openEdit(item) {
    setEditing({ ...item });
    setConfirmId(null);
  }
  function closeForm() {
    setEditing(null);
  }
  function handleChange(name, value) {
    setEditing((e) => ({ ...e, [name]: value }));
  }
  function handleSubmit(e) {
    e.preventDefault();
    if (isNew) {
      store.add(editing);
    } else {
      store.update(editing[idField], editing);
    }
    setEditing(null);
  }
  function handleDelete(id) {
    store.remove(id);
    setConfirmId(null);
  }

  return (
    <div className="lh-admin-page">
      <div className="lh-admin-page__head">
        <div>
          <h1 className="lh-admin-page__title">{title}</h1>
          {subtitle && <p className="lh-admin-page__subtitle">{subtitle}</p>}
        </div>
        <button className="lh-btn lh-btn--primary" onClick={openAdd}>
          <Icon name="plus" size={16} /> Thêm mới
        </button>
      </div>

      {editing && (
        <form className="lh-admin-form" onSubmit={handleSubmit}>
          <h2 className="lh-admin-form__heading">
            <Icon name={isNew ? "plus" : "edit"} size={18} />
            {isNew ? `Thêm mới — ${title}` : `Chỉnh sửa — ${title}`}
          </h2>

          <div className="lh-admin-form__grid">
            {fields.map((f) => (
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
                    onChange={(e) =>
                      handleChange(f.name, f.type === "number" ? Number(e.target.value) : e.target.value)
                    }
                    required={f.required}
                  />
                )}
              </label>
            ))}
          </div>

          <div className="lh-admin-form__actions">
            <button type="submit" className="lh-btn lh-btn--primary">
              {isNew ? "Thêm" : "Lưu thay đổi"}
            </button>
            <button type="button" className="lh-btn lh-btn--ghost" onClick={closeForm}>
              Hủy
            </button>
          </div>
        </form>
      )}

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
                    <button
                      className="lh-admin-icon-btn"
                      aria-label="Sửa"
                      onClick={() => openEdit(item)}
                    >
                      <Icon name="edit" size={16} />
                    </button>

                    {confirmId === item[idField] ? (
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
                    )}
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
