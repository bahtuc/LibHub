import { useEffect, useMemo, useState } from "react";
import { getBooks, createBook, updateBook, deleteBook } from "../services/BookService";
import {
    findCopiesByBook, createBookCopy, updateBookCopyStatus, deleteBookCopy,
} from "../services/BookCopyService";
import { getBorrowTickets } from "../services/BorrowTicketService";
import { getCategories } from "../services/CategoryService";
import { getAuthors } from "../services/AuthorService";
import { getPublishers } from "../services/PublisherService";
import { getUsers } from "../services/UserService";
import { isReturned, loanTitle, returnLoan, isAvailable, COPY_STATUS } from "../utils/loans";
import { formatDate, todayISO } from "../utils/format";
import "../css/admin.css";

const TABS = [
    { key: "books", label: "Sách" },
    { key: "copies", label: "Bản sao" },
    { key: "loans", label: "Phiếu mượn" },
];

export default function Admin() {
    const [tab, setTab] = useState("books");
    return (
        <div className="lh-page">
            <div className="lh-page-head">
                <div>
                    <h1 className="lh-page-title">Quản trị thư viện</h1>
                    <p className="lh-page-sub">Quản lý đầu sách, bản sao vật lý và phiếu mượn.</p>
                </div>
            </div>

            <div className="adm_tabs">
                {TABS.map((t) => (
                    <button key={t.key} className={`adm_tab ${tab === t.key ? "is-active" : ""}`} onClick={() => setTab(t.key)}>
                        {t.label}
                    </button>
                ))}
            </div>

            {tab === "books" && <BooksTab />}
            {tab === "copies" && <CopiesTab />}
            {tab === "loans" && <LoansTab />}
        </div>
    );
}

/* ------------------------------------------------------------------ Books */

const EMPTY_BOOK = {
    title: "", isbn: "", publishYear: "", language: "", pages: "",
    coverImage: "", description: "", categoryId: "", authorId: "", publisherId: "",
};

function BooksTab() {
    const [books, setBooks] = useState([]);
    const [cats, setCats] = useState([]);
    const [authors, setAuthors] = useState([]);
    const [pubs, setPubs] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [notice, setNotice] = useState("");
    const [editing, setEditing] = useState(null); // null | {}(new) | book
    const [form, setForm] = useState(EMPTY_BOOK);
    const [saving, setSaving] = useState(false);

    async function load() {
        try {
            const [b, c, a, p] = await Promise.all([
                getBooks({ page: 0, size: 200 }),
                getCategories().catch(() => []),
                getAuthors().catch(() => []),
                getPublishers().catch(() => []),
            ]);
            setBooks(b?.content ?? []);
            setCats(c || []); setAuthors(a || []); setPubs(p || []);
        } catch (err) {
            setError(err.message || "Không tải được dữ liệu.");
        } finally {
            setLoading(false);
        }
    }
    useEffect(() => { load(); }, []);

    const nameOf = (list, idKey, nameKey, id) => list.find((x) => x[idKey] === id)?.[nameKey] || "—";

    function openNew() { setForm(EMPTY_BOOK); setEditing({}); setNotice(""); setError(""); }
    function openEdit(b) {
        setForm({
            title: b.title || "", isbn: b.isbn || "", publishYear: b.publishYear ?? "",
            language: b.language || "", pages: b.pages ?? "", coverImage: b.coverImage || "",
            description: b.description || "", categoryId: b.categoryId ?? "",
            authorId: b.authorId ?? "", publisherId: b.publisherId ?? "",
        });
        setEditing(b); setNotice(""); setError("");
    }

    const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }));
    const num = (v) => (v === "" || v === null ? null : Number(v));

    async function save(e) {
        e.preventDefault();
        if (!form.title.trim()) { setError("Tên sách là bắt buộc."); return; }
        setSaving(true); setError("");
        const payload = {
            title: form.title.trim(),
            isbn: form.isbn.trim() || null,
            publishYear: num(form.publishYear),
            language: form.language.trim() || null,
            pages: num(form.pages),
            coverImage: form.coverImage.trim() || null,
            description: form.description.trim() || null,
            categoryId: num(form.categoryId),
            authorId: num(form.authorId),
            publisherId: num(form.publisherId),
        };
        try {
            if (editing && editing.bookId) await updateBook(editing.bookId, payload);
            else await createBook(payload);
            setEditing(null);
            setNotice("Đã lưu sách.");
            await load();
        } catch (err) {
            setError(err.message || "Lưu thất bại.");
        } finally {
            setSaving(false);
        }
    }

    async function remove(b) {
        if (!window.confirm(`Xóa sách "${b.title}"?`)) return;
        try { await deleteBook(b.bookId); setNotice("Đã xóa sách."); await load(); }
        catch (err) { setError(err.message || "Xóa thất bại."); }
    }

    return (
        <div>
            <div className="adm_bar">
                <h2 className="lh-section-title" style={{ margin: 0 }}>Đầu sách ({books.length})</h2>
                <button className="lh-btn lh-btn--primary lh-btn--sm" onClick={openNew}>+ Thêm sách</button>
            </div>

            {notice && <div className="lh-alert lh-alert--success">{notice}</div>}
            {error && <div className="lh-alert lh-alert--error">{error}</div>}

            {editing && (
                <form className="lh-panel adm_form" onSubmit={save}>
                    <h3 className="adm_form_title">{editing.bookId ? "Sửa sách" : "Thêm sách mới"}</h3>
                    <div className="adm_form_grid">
                        <Field label="Tên sách *"><input className="lh-input" value={form.title} onChange={set("title")} /></Field>
                        <Field label="ISBN"><input className="lh-input" value={form.isbn} onChange={set("isbn")} /></Field>
                        <Field label="Năm xuất bản"><input className="lh-input" type="number" value={form.publishYear} onChange={set("publishYear")} /></Field>
                        <Field label="Số trang"><input className="lh-input" type="number" value={form.pages} onChange={set("pages")} /></Field>
                        <Field label="Ngôn ngữ"><input className="lh-input" value={form.language} onChange={set("language")} /></Field>
                        <Field label="Ảnh bìa (URL)"><input className="lh-input" value={form.coverImage} onChange={set("coverImage")} /></Field>
                        <Field label="Thể loại">
                            <select className="lh-select" value={form.categoryId} onChange={set("categoryId")}>
                                <option value="">— Chọn —</option>
                                {cats.map((c) => <option key={c.categoryId} value={c.categoryId}>{c.categoryName}</option>)}
                            </select>
                        </Field>
                        <Field label="Tác giả">
                            <select className="lh-select" value={form.authorId} onChange={set("authorId")}>
                                <option value="">— Chọn —</option>
                                {authors.map((a) => <option key={a.authorId} value={a.authorId}>{a.authorName}</option>)}
                            </select>
                        </Field>
                        <Field label="Nhà xuất bản">
                            <select className="lh-select" value={form.publisherId} onChange={set("publisherId")}>
                                <option value="">— Chọn —</option>
                                {pubs.map((p) => <option key={p.publisherId} value={p.publisherId}>{p.publisherName}</option>)}
                            </select>
                        </Field>
                    </div>
                    <Field label="Mô tả"><textarea className="lh-textarea" value={form.description} onChange={set("description")} /></Field>
                    <div className="adm_form_actions">
                        <button type="button" className="lh-btn" onClick={() => setEditing(null)}>Hủy</button>
                        <button type="submit" className="lh-btn lh-btn--primary" disabled={saving}>{saving ? "Đang lưu…" : "Lưu"}</button>
                    </div>
                </form>
            )}

            {loading ? (
                <div className="lh-loading"><span className="lh-spinner" /> Đang tải…</div>
            ) : books.length === 0 ? (
                <div className="lh-card lh-empty">Chưa có sách nào. Bấm “Thêm sách”.</div>
            ) : (
                <div className="lh-table--wrap">
                    <table className="lh-table">
                        <thead><tr><th>Tên sách</th><th>Thể loại</th><th>Tác giả</th><th>Năm</th><th>ISBN</th><th></th></tr></thead>
                        <tbody>
                            {books.map((b) => (
                                <tr key={b.bookId}>
                                    <td style={{ fontWeight: 600 }}>{b.title}</td>
                                    <td>{nameOf(cats, "categoryId", "categoryName", b.categoryId)}</td>
                                    <td>{nameOf(authors, "authorId", "authorName", b.authorId)}</td>
                                    <td className="lh-mono">{b.publishYear || "—"}</td>
                                    <td className="lh-mono lh-muted">{b.isbn || "—"}</td>
                                    <td style={{ textAlign: "right", whiteSpace: "nowrap" }}>
                                        <button className="lh-btn lh-btn--sm" onClick={() => openEdit(b)}>Sửa</button>{" "}
                                        <button className="lh-btn lh-btn--sm lh-btn--danger" onClick={() => remove(b)}>Xóa</button>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            )}
        </div>
    );
}

/* ----------------------------------------------------------------- Copies */

const COPY_OPTIONS = [COPY_STATUS.AVAILABLE, COPY_STATUS.BORROWED, COPY_STATUS.LOST, COPY_STATUS.MAINTENANCE];
const EMPTY_COPY = { barcode: "", shelfLocation: "", status: COPY_STATUS.AVAILABLE, acquiredDate: todayISO() };

function CopiesTab() {
    const [books, setBooks] = useState([]);
    const [bookId, setBookId] = useState("");
    const [copies, setCopies] = useState([]);
    const [form, setForm] = useState(EMPTY_COPY);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");
    const [notice, setNotice] = useState("");
    const [saving, setSaving] = useState(false);

    useEffect(() => {
        getBooks({ page: 0, size: 200 }).then((b) => setBooks(b?.content ?? [])).catch(() => {});
    }, []);

    async function loadCopies(id) {
        if (!id) { setCopies([]); return; }
        setLoading(true); setError("");
        try { setCopies(await findCopiesByBook(id) || []); }
        catch (err) { setError(err.message || "Không tải được bản sao."); }
        finally { setLoading(false); }
    }

    function pickBook(e) { const id = e.target.value; setBookId(id); setNotice(""); loadCopies(id); }
    const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }));

    async function addCopy(e) {
        e.preventDefault();
        if (!bookId) { setError("Hãy chọn một đầu sách trước."); return; }
        setSaving(true); setError("");
        try {
            await createBookCopy({
                bookId: Number(bookId),
                barcode: form.barcode.trim() || null,
                shelfLocation: form.shelfLocation.trim() || null,
                status: form.status,
                acquiredDate: form.acquiredDate || null,
            });
            setForm(EMPTY_COPY);
            setNotice("Đã thêm bản sao.");
            await loadCopies(bookId);
        } catch (err) {
            setError(err.message || "Thêm bản sao thất bại.");
        } finally {
            setSaving(false);
        }
    }

    async function changeStatus(copy, status) {
        try { await updateBookCopyStatus(copy.copyId, status); await loadCopies(bookId); }
        catch (err) { setError(err.message || "Đổi trạng thái thất bại."); }
    }
    async function remove(copy) {
        if (!window.confirm("Xóa bản sao này?")) return;
        try { await deleteBookCopy(copy.copyId); await loadCopies(bookId); }
        catch (err) { setError(err.message || "Xóa thất bại."); }
    }

    return (
        <div>
            <div className="adm_bar">
                <div className="lh-field" style={{ maxWidth: 380, flex: 1 }}>
                    <label className="lh-label">Chọn đầu sách</label>
                    <select className="lh-select" value={bookId} onChange={pickBook}>
                        <option value="">— Chọn sách để quản lý bản sao —</option>
                        {books.map((b) => <option key={b.bookId} value={b.bookId}>{b.title}</option>)}
                    </select>
                </div>
            </div>

            {notice && <div className="lh-alert lh-alert--success">{notice}</div>}
            {error && <div className="lh-alert lh-alert--error">{error}</div>}

            {bookId && (
                <form className="lh-panel adm_copyform" onSubmit={addCopy}>
                    <Field label="Mã vạch"><input className="lh-input" value={form.barcode} onChange={set("barcode")} placeholder="VD: LIB-0001" /></Field>
                    <Field label="Vị trí kệ"><input className="lh-input" value={form.shelfLocation} onChange={set("shelfLocation")} placeholder="VD: A-12" /></Field>
                    <Field label="Trạng thái">
                        <select className="lh-select" value={form.status} onChange={set("status")}>
                            {COPY_OPTIONS.map((s) => <option key={s} value={s}>{s}</option>)}
                        </select>
                    </Field>
                    <Field label="Ngày nhập"><input className="lh-input" type="date" value={form.acquiredDate} onChange={set("acquiredDate")} /></Field>
                    <button type="submit" className="lh-btn lh-btn--primary" disabled={saving}>{saving ? "Đang thêm…" : "+ Thêm bản sao"}</button>
                </form>
            )}

            {loading ? (
                <div className="lh-loading"><span className="lh-spinner" /> Đang tải…</div>
            ) : bookId && copies.length === 0 ? (
                <div className="lh-card lh-empty">Đầu sách này chưa có bản sao. Thêm bản sao ở trên để cho phép mượn.</div>
            ) : bookId ? (
                <div className="lh-table--wrap">
                    <table className="lh-table">
                        <thead><tr><th>Mã vạch</th><th>Vị trí</th><th>Trạng thái</th><th>Ngày nhập</th><th></th></tr></thead>
                        <tbody>
                            {copies.map((c) => (
                                <tr key={c.copyId}>
                                    <td className="lh-mono">{c.barcode || `#${c.copyId}`}</td>
                                    <td>{c.shelfLocation || "—"}</td>
                                    <td>
                                        <select
                                            className="lh-select adm_status_sel"
                                            value={COPY_OPTIONS.includes(c.status) ? c.status : (isAvailable(c) ? COPY_STATUS.AVAILABLE : c.status || COPY_STATUS.AVAILABLE)}
                                            onChange={(e) => changeStatus(c, e.target.value)}
                                        >
                                            {COPY_OPTIONS.map((s) => <option key={s} value={s}>{s}</option>)}
                                        </select>
                                    </td>
                                    <td>{formatDate(c.acquiredDate)}</td>
                                    <td style={{ textAlign: "right" }}>
                                        <button className="lh-btn lh-btn--sm lh-btn--danger" onClick={() => remove(c)}>Xóa</button>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            ) : (
                <div className="lh-card lh-empty">Chọn một đầu sách để xem và quản lý bản sao.</div>
            )}
        </div>
    );
}

/* ------------------------------------------------------------------ Loans */

function LoansTab() {
    const [tickets, setTickets] = useState([]);
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [notice, setNotice] = useState("");
    const [busyId, setBusyId] = useState(null);
    const [showReturned, setShowReturned] = useState(false);

    async function load() {
        try {
            const [t, u] = await Promise.all([getBorrowTickets(), getUsers().catch(() => [])]);
            const list = Array.isArray(t) ? t : [];
            list.sort((a, b) => (b.ticketId || 0) - (a.ticketId || 0));
            setTickets(list);
            setUsers(u || []);
            setError("");
        } catch (err) {
            setError(err.message || "Không tải được phiếu mượn.");
        } finally {
            setLoading(false);
        }
    }
    useEffect(() => { load(); }, []);

    const userName = (id) => {
        const u = users.find((x) => x.userId === id);
        return u ? (u.fullName || u.username) : `#${id}`;
    };

    const visible = useMemo(
        () => (showReturned ? tickets : tickets.filter((t) => !isReturned(t))),
        [tickets, showReturned]
    );

    async function markReturned(ticket) {
        setBusyId(ticket.ticketId); setNotice(""); setError("");
        try { await returnLoan(ticket); setNotice("Đã ghi nhận trả sách."); await load(); }
        catch (err) { setError(err.message || "Thao tác thất bại."); }
        finally { setBusyId(null); }
    }

    return (
        <div>
            <div className="adm_bar">
                <h2 className="lh-section-title" style={{ margin: 0 }}>Phiếu mượn ({visible.length})</h2>
                <label className="lh-row" style={{ fontSize: 13.5, cursor: "pointer" }}>
                    <input type="checkbox" checked={showReturned} onChange={(e) => setShowReturned(e.target.checked)} /> Hiện cả phiếu đã trả
                </label>
            </div>

            {notice && <div className="lh-alert lh-alert--success">{notice}</div>}
            {error && <div className="lh-alert lh-alert--error">{error}</div>}

            {loading ? (
                <div className="lh-loading"><span className="lh-spinner" /> Đang tải…</div>
            ) : visible.length === 0 ? (
                <div className="lh-card lh-empty">Không có phiếu mượn nào.</div>
            ) : (
                <div className="lh-table--wrap">
                    <table className="lh-table">
                        <thead><tr><th>Mã</th><th>Thành viên</th><th>Sách</th><th>Ngày mượn</th><th>Hạn trả</th><th>Trạng thái</th><th></th></tr></thead>
                        <tbody>
                            {visible.map((t) => {
                                const returned = isReturned(t);
                                return (
                                    <tr key={t.ticketId}>
                                        <td className="lh-mono lh-muted">#{t.ticketId}</td>
                                        <td>{userName(t.userId)}</td>
                                        <td style={{ fontWeight: 600 }}>{loanTitle(t)}</td>
                                        <td className="lh-mono">{formatDate(t.borrowDate)}</td>
                                        <td className="lh-mono">{formatDate(t.dueDate)}</td>
                                        <td>
                                            <span className={`lh-badge ${returned ? "lh-badge--slate" : "lh-badge--amber"}`}>
                                                {returned ? "Đã trả" : t.status || "Đang mượn"}
                                            </span>
                                        </td>
                                        <td style={{ textAlign: "right" }}>
                                            {!returned && (
                                                <button className="lh-btn lh-btn--sm" disabled={busyId === t.ticketId} onClick={() => markReturned(t)}>
                                                    {busyId === t.ticketId ? "…" : "Ghi nhận trả"}
                                                </button>
                                            )}
                                        </td>
                                    </tr>
                                );
                            })}
                        </tbody>
                    </table>
                </div>
            )}
        </div>
    );
}

/* ---------------------------------------------------------------- helpers */

function Field({ label, children }) {
    return (
        <label className="lh-field">
            <span className="lh-label">{label}</span>
            {children}
        </label>
    );
}
