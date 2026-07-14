import { useEffect, useState } from "react";
import { Link, useParams, useNavigate } from "react-router-dom";
import { getBookById } from "../services/BookService";
import { findCopiesByBook } from "../services/BookCopyService";
import { getAuthors } from "../services/AuthorService";
import { getCategories } from "../services/CategoryService";
import { getPublishers } from "../services/PublisherService";
import { useAuth } from "../context/AuthContext";
import { borrowBook, isAvailable, summarizeCopies } from "../utils/loans";
import { formatDate } from "../utils/format";
import "../css/detail.css";

function copyBadge(status) {
    const s = (status || "").toLowerCase();
    if (s === "available") return "lh-badge--green";
    if (s === "borrowed") return "lh-badge--amber";
    return "lh-badge--slate";
}

export default function BookDetail() {
    const { id } = useParams();
    const navigate = useNavigate();
    const { user } = useAuth();

    const [book, setBook] = useState(null);
    const [copies, setCopies] = useState([]);
    const [names, setNames] = useState({ author: null, category: null, publisher: null });
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [notice, setNotice] = useState("");
    const [busy, setBusy] = useState(false);

    async function load() {
        try {
            const raw = await getBookById(id);
            const b = raw && raw.present !== undefined ? (raw.value ?? null) : raw; // tolerate Optional shape
            if (!b || !b.bookId) throw new Error("Không tìm thấy sách.");
            setBook(b);

            const [cps, authors, cats, pubs] = await Promise.all([
                findCopiesByBook(id),
                getAuthors().catch(() => []),
                getCategories().catch(() => []),
                getPublishers().catch(() => []),
            ]);
            setCopies(Array.isArray(cps) ? cps : []);
            setNames({
                author: (authors || []).find((a) => a.authorId === b.authorId)?.authorName || null,
                category: (cats || []).find((c) => c.categoryId === b.categoryId)?.categoryName || null,
                publisher: (pubs || []).find((p) => p.publisherId === b.publisherId)?.publisherName || null,
            });
            setError("");
        } catch (err) {
            setError(err.message || "Không tải được thông tin sách.");
        } finally {
            setLoading(false);
        }
    }

    useEffect(() => { load(); /* eslint-disable-next-line */ }, [id]);

    async function handleBorrow() {
        setBusy(true);
        setNotice("");
        setError("");
        try {
            await borrowBook(book, user.userId);
            setNotice("Đã mượn thành công. Hạn trả sau 14 ngày.");
            await load();
        } catch (err) {
            setError(err.message || "Mượn sách thất bại.");
        } finally {
            setBusy(false);
        }
    }

    if (loading) return <div className="lh-page"><div className="lh-loading"><span className="lh-spinner" /> Đang tải…</div></div>;

    if (error && !book) {
        return (
            <div className="lh-page">
                <div className="lh-alert lh-alert--error">{error}</div>
                <Link to="/catalog" className="lh-btn">← Về danh mục</Link>
            </div>
        );
    }

    const { total, available } = summarizeCopies(copies);

    return (
        <div className="lh-page">
            <button className="lh-btn lh-btn--ghost lh-btn--sm" onClick={() => navigate(-1)} style={{ marginBottom: 14 }}>← Quay lại</button>

            {notice && <div className="lh-alert lh-alert--success">{notice}</div>}
            {error && <div className="lh-alert lh-alert--error">{error}</div>}

            <div className="det_head">
                <div className="det_cover">
                    {book.coverImage
                        ? <img src={book.coverImage} alt="" />
                        : <span className="det_cover_ph">{(book.title || "?").charAt(0)}</span>}
                </div>
                <div className="det_info">
                    <h1 className="det_title">{book.title}</h1>
                    {names.author && <p className="det_author">{names.author}</p>}

                    <div className="det_facts">
                        <Fact label="Thể loại" value={names.category} />
                        <Fact label="Nhà xuất bản" value={names.publisher} />
                        <Fact label="Năm xuất bản" value={book.publishYear} />
                        <Fact label="Ngôn ngữ" value={book.language} />
                        <Fact label="Số trang" value={book.pages} />
                        <Fact label="ISBN" value={book.isbn} mono />
                    </div>

                    <div className="det_borrow">
                        <span className={`lh-badge ${available > 0 ? "lh-badge--green" : total === 0 ? "lh-badge--slate" : "lh-badge--red"}`}>
                            {total === 0 ? "Chưa có bản sao" : available > 0 ? `Còn ${available}/${total} bản` : "Đã mượn hết"}
                        </span>
                        <button className="lh-btn lh-btn--primary" disabled={available === 0 || busy} onClick={handleBorrow}>
                            {busy ? "Đang mượn…" : "Mượn sách"}
                        </button>
                    </div>
                </div>
            </div>

            {book.description && (
                <div className="lh-panel det_desc">
                    <h2 className="lh-section-title">Giới thiệu</h2>
                    <p>{book.description}</p>
                </div>
            )}

            <h2 className="lh-section-title" style={{ marginTop: 26 }}>Các bản sao ({total})</h2>
            {total === 0 ? (
                <div className="lh-card lh-empty">Sách này chưa có bản sao vật lý trong kho.</div>
            ) : (
                <div className="lh-table--wrap">
                    <table className="lh-table">
                        <thead>
                            <tr><th>Mã vạch</th><th>Vị trí kệ</th><th>Trạng thái</th><th>Ngày nhập</th></tr>
                        </thead>
                        <tbody>
                            {copies.map((c) => (
                                <tr key={c.copyId}>
                                    <td className="lh-mono">{c.barcode || `#${c.copyId}`}</td>
                                    <td>{c.shelfLocation || "—"}</td>
                                    <td><span className={`lh-badge ${copyBadge(c.status)}`}>{isAvailable(c) ? "Sẵn sàng" : c.status || "—"}</span></td>
                                    <td>{formatDate(c.acquiredDate)}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            )}
        </div>
    );
}

function Fact({ label, value, mono }) {
    if (value === null || value === undefined || value === "") return null;
    return (
        <div className="det_fact">
            <span className="det_fact_label">{label}</span>
            <span className={`det_fact_value ${mono ? "lh-mono" : ""}`}>{value}</span>
        </div>
    );
}
