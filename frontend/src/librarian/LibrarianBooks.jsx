// src/librarian/LibrarianBooks.jsx
// Dùng chung booksStore với Admin (1 nguồn dữ liệu Books duy nhất) — nhưng
// thủ thư chỉ được Thêm / Sửa / Ẩn-Hiện, KHÔNG được xóa hẳn khỏi hệ thống.
import AdminCrudPage from "../admin/AdminCrudPage";
import Icon from "../components/Icon";
import Badge from "../admin/Badge";
import BookDataTools from "../components/BookDataTools";
import { booksStore, categoriesStore, authorsStore, copiesStore } from "../data/adminStore";

export default function LibrarianBooks() {
  const categories = categoriesStore.useCollection();
  const authors = authorsStore.useCollection();
  const copies = copiesStore.useCollection();

  const categoryOptions = categories.map((c) => ({ value: c.category_id, label: c.category_name }));
  const authorOptions = authors.map((a) => ({ value: a.author_id, label: a.author_name }));

  return (
    <AdminCrudPage
      title="Kho sách"
      subtitle="Thêm đầu sách mới hoặc ẩn/hiện sách khỏi trang thư viện công khai."
      headerActions={<BookDataTools onImported={() => booksStore.refresh()} />}
      store={booksStore}
      idField="book_id"
      hideDelete
      emptyItem={{
        title: "",
        author_id: authorOptions[0]?.value ?? "",
        category_id: categoryOptions[0]?.value ?? "",
        publish_year: new Date().getFullYear(),
        pages: 200,
        description: "",
        is_featured: false,
        is_hidden: false,
        cover_image: null,
      }}
      rowActions={(item) => (
        <button
          className="lh-admin-icon-btn"
          aria-label={item.is_hidden ? "Hiện sách" : "Ẩn sách"}
          title={item.is_hidden ? "Đang ẩn — bấm để hiện lại" : "Bấm để ẩn khỏi thư viện công khai"}
          onClick={() => booksStore.update(item.book_id, { is_hidden: !item.is_hidden })}
        >
          <Icon name={item.is_hidden ? "eye" : "eye-off"} size={16} />
        </button>
      )}
      columns={[
        {
          key: "cover_image",
          label: "Bìa",
          render: (i) => i.cover_image ? (
            <img className="lh-admin-book-cover" src={i.cover_image} alt={`Bìa ${i.title}`} />
          ) : "—",
        },
        { key: "title", label: "Tên sách" },
        {
          key: "author_id",
          label: "Tác giả",
          render: (i) => authors.find((a) => a.author_id === i.author_id)?.author_name ?? "—",
        },
        {
          key: "category_id",
          label: "Thể loại",
          render: (i) => categories.find((c) => c.category_id === i.category_id)?.category_name ?? "—",
        },
        {
          key: "status",
          label: "Trạng thái",
          render: (i) => (copies.some((copy) => copy.book_id === i.book_id && copy.status === "available") ? <Badge tone="success">Còn sách</Badge> : <Badge tone="danger">Đã mượn hết</Badge>),
        },
        {
          key: "is_hidden",
          label: "Hiển thị",
          render: (i) => (i.is_hidden ? <Badge tone="neutral">Đang ẩn</Badge> : <Badge tone="success">Công khai</Badge>),
        },
      ]}
      fields={[
        { name: "title", label: "Tên sách", required: true },
        { name: "author_id", label: "Tác giả", type: "select", options: authorOptions, numeric: true, required: true },
        { name: "category_id", label: "Thể loại", type: "select", options: categoryOptions, numeric: true, required: true },
        { name: "publish_year", label: "Năm xuất bản", type: "number" },
        { name: "pages", label: "Số trang", type: "number" },
        {
          name: "cover_image",
          label: "Ảnh bìa (URL)",
          type: "url",
          placeholder: "https://example.com/anh-bia.jpg",
          maxLength: 255,
          previewImage: true,
        },
        { name: "description", label: "Mô tả", type: "textarea" },
      ]}
    />
  );
}
