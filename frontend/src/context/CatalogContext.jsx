import { createContext, useContext, useEffect, useState } from "react";
import { getBooks } from "../services/BookService";
import { getCategories } from "../services/CategoryService";
import { getAuthors } from "../services/AuthorService";
import { getBookCopies } from "../services/BookCopyService";

const CatalogContext = createContext(null);
const COLORS = ["#A63D26", "#3D6652", "#C08A28", "#2E4A6B", "#8A5A9E", "#6B5B3E"];
const ICONS = ["book-open", "flask", "compass", "briefcase", "star", "landmark"];

export function CatalogProvider({ children }) {
  const [state, setState] = useState({ books: [], categories: [], authors: [], loading: true, error: "" });
  async function refresh() {
    setState((current) => ({ ...current, loading: true, error: "" }));
    try {
      const [page, categories, authors, copies] = await Promise.all([getBooks({ size: 1000 }), getCategories(), getAuthors(), getBookCopies()]);
      setState({
        books: (page.content ?? []).map((book) => ({ ...book, book_id: book.bookId, author_id: book.authorId, category_id: book.categoryId, publish_year: book.publishYear, cover_image: book.coverImage, is_hidden: book.hidden ?? false, is_featured: book.featured ?? false, status: copies.some((copy) => copy.bookId === book.bookId && String(copy.status).toLowerCase() === "available") ? "available" : "borrowed" })),
        categories: categories.map((category, index) => ({ ...category, category_id: category.categoryId, category_name: category.categoryName, color: COLORS[index % COLORS.length], icon: ICONS[index % ICONS.length] })),
        authors: authors.map((author) => ({ ...author, author_id: author.authorId, author_name: author.authorName })),
        loading: false, error: "",
      });
    } catch (error) { setState({ books: [], categories: [], authors: [], loading: false, error: error.message }); }
  }
  useEffect(() => { refresh(); }, []);
  return <CatalogContext.Provider value={{ ...state, refresh }}>{children}</CatalogContext.Provider>;
}

export function useCatalog() {
  const catalog = useContext(CatalogContext);
  if (!catalog) throw new Error("useCatalog must be used inside CatalogProvider");
  return catalog;
}
