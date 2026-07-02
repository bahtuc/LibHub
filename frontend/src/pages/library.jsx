import { useEffect, useState } from "react";
import { getBooks } from "../services/BookService";

const PAGE_SIZE = 12;

export default function Library() {
    const [books, setBooks] = useState([]);
    const [page, setPage] = useState(0);
    const [totalPages, setTotalPages] = useState(0);
    const [keyword, setKeyword] = useState("");
    const [search, setSearch] = useState("");
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");

    useEffect(() => {
        let cancelled = false;
        setLoading(true);
        setError("");

        getBooks({ page, size: PAGE_SIZE, keyword: search || undefined })
            .then((data) => {
                if (cancelled) return;
                setBooks(data?.content ?? []);
                setTotalPages(data?.totalPages ?? 0);
            })
            .catch((err) => {
                if (cancelled) return;
                setError(err.message || "Không tải được danh sách sách.");
                setBooks([]);
            })
            .finally(() => {
                if (!cancelled) setLoading(false);
            });

        return () => {
            cancelled = true;
        };
    }, [page, search]);

    function handleSubmit(e) {
        e.preventDefault();
        setPage(0);
        setSearch(keyword.trim());
    }

    return (
        <div style={{ padding: "40px 24px", maxWidth: 1100, margin: "0 auto" }}>
            <h1 style={{ textAlign: "center" }}>Thư viện</h1>

            <form
                onSubmit={handleSubmit}
                style={{ display: "flex", gap: 8, justifyContent: "center", margin: "24px 0" }}
            >
                <input
                    type="text"
                    value={keyword}
                    onChange={(e) => setKeyword(e.target.value)}
                    placeholder="Tìm theo tên sách..."
                    style={{ padding: "8px 12px", minWidth: 280, borderRadius: 6, border: "1px solid #ccc" }}
                />
                <button type="submit" style={{ padding: "8px 16px", borderRadius: 6, cursor: "pointer" }}>
                    Tìm
                </button>
            </form>

            {loading && <p style={{ textAlign: "center" }}>Đang tải...</p>}

            {error && !loading && (
                <p style={{ textAlign: "center", color: "crimson" }}>
                    {error}
                    <br />
                    <small>Bạn cần đăng nhập để xem danh sách sách.</small>
                </p>
            )}

            {!loading && !error && books.length === 0 && (
                <p style={{ textAlign: "center" }}>Chưa có sách nào.</p>
            )}

            {!loading && !error && books.length > 0 && (
                <>
                    <div
                        style={{
                            display: "grid",
                            gridTemplateColumns: "repeat(auto-fill, minmax(200px, 1fr))",
                            gap: 16,
                        }}
                    >
                        {books.map((book) => (
                            <div
                                key={book.bookId}
                                style={{ border: "1px solid #e0e0e0", borderRadius: 8, padding: 16 }}
                            >
                                {book.coverImage && (
                                    <img
                                        src={book.coverImage}
                                        alt={book.title}
                                        style={{ width: "100%", height: 220, objectFit: "cover", borderRadius: 4 }}
                                    />
                                )}
                                <h3 style={{ fontSize: 16, margin: "12px 0 4px" }}>{book.title}</h3>
                                {book.publishYear && (
                                    <p style={{ fontSize: 13, color: "#666", margin: 0 }}>
                                        Năm: {book.publishYear}
                                    </p>
                                )}
                                {book.language && (
                                    <p style={{ fontSize: 13, color: "#666", margin: 0 }}>
                                        Ngôn ngữ: {book.language}
                                    </p>
                                )}
                            </div>
                        ))}
                    </div>

                    {totalPages > 1 && (
                        <div
                            style={{ display: "flex", gap: 12, justifyContent: "center", alignItems: "center", marginTop: 24 }}
                        >
                            <button
                                onClick={() => setPage((p) => Math.max(0, p - 1))}
                                disabled={page === 0}
                                style={{ padding: "6px 14px", cursor: page === 0 ? "default" : "pointer" }}
                            >
                                Trước
                            </button>
                            <span>
                                Trang {page + 1} / {totalPages}
                            </span>
                            <button
                                onClick={() => setPage((p) => Math.min(totalPages - 1, p + 1))}
                                disabled={page >= totalPages - 1}
                                style={{ padding: "6px 14px", cursor: page >= totalPages - 1 ? "default" : "pointer" }}
                            >
                                Sau
                            </button>
                        </div>
                    )}
                </>
            )}
        </div>
    );
}
