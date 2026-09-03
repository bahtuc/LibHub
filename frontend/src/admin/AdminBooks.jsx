// src/admin/AdminBooks.jsx
import AdminCrudPage from "./AdminCrudPage";
import Badge from "./Badge";
import BookDataTools from "../components/BookDataTools";
import {
  booksStore,
  categoriesStore,
  authorsStore,
  publishersStore,
  copiesStore,
} from "../data/adminStore";

export default function AdminBooks() {
  const categories = categoriesStore.useCollection();
  const authors = authorsStore.useCollection();
  const copies = copiesStore.useCollection();

  const categoryOptions = categories.map((c) => ({ value: c.category_id, label: c.category_name }));
  const authorOptions = authors.map((a) => ({ value: a.author_id, label: a.author_name }));
  const publishers = publishersStore.useCollection();

  const publisherOptions = publishers.map((p) => ({
    value: p.publisher_id,
    label: p.publisher_name,
  }));
  return (
    <AdminCrudPage
      title="Kho sách"
      subtitle="Quản lý toàn bộ đầu sách trong thư viện."
      headerActions={<BookDataTools onImported={() => booksStore.refresh()} />}
      store={booksStore}
      idField="book_id"
      searchPlaceholder="Tìm theo tên sách, ISBN, tác giả hoặc thể loại..."
      searchText={(book) => [
        book.title,
        book.isbn,
        authors.find((author) => author.author_id === book.author_id)?.author_name,
        categories.find((category) => category.category_id === book.category_id)?.category_name,
        publishers.find((publisher) => publisher.publisher_id === book.publisher_id)?.publisher_name,
      ].filter(Boolean).join(" ")}
      emptyItem={{
        title: "",
        isbn: "",
        author_id: authorOptions[0]?.value ?? null,
        publisher_id: publisherOptions[0]?.value ?? null,
        category_id: categoryOptions[0]?.value ?? null,
        publish_year: new Date().getFullYear(),
        pages: 200,
        description: "",
        is_featured: false,
        cover_image: null,
        cover_file: null,
      }}
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
        { key: "publish_year", label: "Năm XB" },
        {
          key: "status",
          label: "Trạng thái",
          render: (i) =>
            copies.some((copy) => copy.book_id === i.book_id && copy.status === "available") ? (
              <Badge tone="success">Còn sách</Badge>
            ) : (
              <Badge tone="danger">Đã mượn hết</Badge>
            ),
        },
        {
          key: "is_featured",
          label: "Nổi bật",
          render: (i) => (i.is_featured ? <Badge tone="warning">Nổi bật</Badge> : <Badge tone="neutral">—</Badge>),
        },
      ]}
      fields={[
        { name: "title", label: "Tên sách", required: true },
        { name: "isbn", label: "ISBN", required: false },
        { name: "author_id", label: "Tác giả", type: "select", options: authorOptions, numeric: true, required: true },
        { name: "publisher_id", label: "Nhà xuất bản", type: "select", options: publisherOptions, numeric: true, required: true },
        { name: "category_id", label: "Thể loại", type: "select", options: categoryOptions, numeric: true, required: true },
        { name: "publish_year", label: "Năm xuất bản", type: "number" },
        { name: "pages", label: "Số trang", type: "number" },
        {
          name: "cover_file",
          label: "Tải ảnh bìa",
          type: "file",
          accept: "image/jpeg,image/png,image/webp",
          existingImageField: "cover_image",
          previewImage: true,
        },
        { name: "is_featured", label: "Hiện ở mục nổi bật (trang chủ)", type: "checkbox" },
        { name: "description", label: "Mô tả", type: "textarea" },
      ]}
    />
  );
}
