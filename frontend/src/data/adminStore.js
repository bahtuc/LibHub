// Shared API-backed stores for the Admin and Librarian screens.
// The in-memory cache only keeps React views in sync; SQL Server remains the
// single source of truth and every mutation is sent to the Spring API.

import { useEffect, useState } from "react";
import * as bookApi from "../services/BookService";
import * as categoryApi from "../services/CategoryService";
import * as authorApi from "../services/AuthorService";
import * as copyApi from "../services/BookCopyService";
import * as userApi from "../services/UserService";
import * as roleApi from "../services/RoleService";

function makeApiStore({ idField, loadAll, create, update, remove, fromApi, toApi }) {
  let cache = [];
  let pendingLoad = null;
  const listeners = new Set();

  function notify() {
    listeners.forEach((listener) => listener(cache));
  }

  async function refresh() {
    if (!pendingLoad) {
      pendingLoad = Promise.resolve(loadAll())
        .then((items) => {
          cache = items.map(fromApi);
          notify();
          return cache;
        })
        .finally(() => {
          pendingLoad = null;
        });
    }
    return pendingLoad;
  }

  function useCollection() {
    const [items, setItems] = useState(cache);
    useEffect(() => {
      const listener = (next) => setItems([...next]);
      listeners.add(listener);
      refresh().catch((error) => console.error(`Không tải được ${idField}`, error));
      return () => listeners.delete(listener);
    }, []);
    return items;
  }

  function getAll() {
    return cache;
  }

  function getById(id) {
    return cache.find((item) => Number(item[idField]) === Number(id));
  }

  async function add(item) {
    const saved = fromApi(await create(toApi(item, true)));
    cache = [...cache, saved];
    notify();
    return saved;
  }

  async function updateItem(id, patch) {
    const current = getById(id) ?? {};
    const saved = fromApi(await update(id, toApi({ ...current, ...patch }, false)));
    cache = cache.map((item) => Number(item[idField]) === Number(id) ? saved : item);
    notify();
    return saved;
  }

  async function removeItem(id) {
    await remove(id);
    cache = cache.filter((item) => Number(item[idField]) !== Number(id));
    notify();
  }

  return { useCollection, getAll, getById, refresh, add, update: updateItem, remove: removeItem };
}

const fromBook = (book) => ({
  ...book,
  book_id: book.bookId,
  publish_year: book.publishYear,
  cover_image: book.coverImage,
  category_id: book.categoryId,
  author_id: book.authorId,
  publisher_id: book.publisherId,
  is_hidden: book.hidden ?? false,
  is_featured: book.featured ?? false,
});

const toBook = (book) => ({
  title: book.title,
  isbn: book.isbn || null,
  publishYear: book.publish_year || null,
  description: book.description || null,
  coverImage: book.cover_image || null,
  language: book.language || null,
  pages: book.pages || null,
  categoryId: book.category_id || null,
  authorId: book.author_id || null,
  publisherId: book.publisher_id || null,
  hidden: book.is_hidden ?? false,
  featured: book.is_featured ?? false,
});

const fromCategory = (category) => ({
  ...category,
  category_id: category.categoryId,
  category_name: category.categoryName,
});

const toCategory = (category) => ({
  categoryName: category.category_name,
  description: category.description || null,
});

const fromAuthor = (author) => ({
  ...author,
  author_id: author.authorId,
  author_name: author.authorName,
});

const toAuthor = (author) => ({
  authorName: author.author_name,
  biography: author.biography || null,
});

const fromCopy = (copy) => ({
  ...copy,
  copy_id: copy.copyId,
  book_id: copy.bookId,
  shelf_location: copy.shelfLocation,
  acquired_date: copy.acquiredDate,
  status: String(copy.status || "available").toLowerCase(),
});

const toCopy = (copy) => ({
  bookId: copy.book_id,
  barcode: copy.barcode,
  shelfLocation: copy.shelf_location || null,
  status: copy.status,
  acquiredDate: copy.acquired_date || null,
});

const fromUser = (user) => ({
  ...user,
  user_id: user.userId,
  full_name: user.fullName,
  role_id: user.role?.roleId,
  role_name: user.role?.roleName,
  status: String(user.status || "active").toLowerCase(),
});

const toUser = (user, creating) => ({
  username: user.username,
  passwordHash: creating ? user.password_hash : undefined,
  fullName: user.full_name,
  email: user.email || null,
  status: String(user.status || "active").toUpperCase(),
  role: user.role_id ? { roleId: user.role_id } : null,
});

export const booksStore = makeApiStore({
  idField: "book_id",
  // loadAll: async () => (await bookApi.getBooks({ size: 1000, includeHidden: true })).content ?? [],
  loadAll: async () => {
    const res = await bookApi.getBooks({
      size: 1000,
      includeHidden: true,
    });

    console.log("Books API Response:", res);

    return res.content ?? [];
  },
  create: bookApi.createBook,
  update: bookApi.updateBook,
  remove: bookApi.deleteBook,
  fromApi: fromBook,
  toApi: toBook,
});

export const categoriesStore = makeApiStore({
  idField: "category_id",
  loadAll: categoryApi.getCategories,
  create: categoryApi.createCategory,
  update: categoryApi.updateCategory,
  remove: categoryApi.deleteCategory,
  fromApi: fromCategory,
  toApi: toCategory,
});

export const authorsStore = makeApiStore({
  idField: "author_id",
  loadAll: authorApi.getAuthors,
  create: authorApi.createAuthor,
  update: authorApi.updateAuthor,
  remove: authorApi.deleteAuthor,
  fromApi: fromAuthor,
  toApi: toAuthor,
});

export const copiesStore = makeApiStore({
  idField: "copy_id",
  loadAll: copyApi.getBookCopies,
  create: copyApi.createBookCopy,
  update: copyApi.updateBookCopy,
  remove: copyApi.deleteBookCopy,
  fromApi: fromCopy,
  toApi: toCopy,
});

export const usersStore = makeApiStore({
  idField: "user_id",
  loadAll: userApi.getUsers,
  create: userApi.createUser,
  update: userApi.updateUser,
  remove: userApi.deleteUser,
  fromApi: fromUser,
  toApi: toUser,
});

export const rolesStore = makeApiStore({
  idField: "role_id",
  loadAll: roleApi.getRoles,
  create: roleApi.createRole,
  update: roleApi.updateRole,
  remove: roleApi.deleteRole,
  fromApi: (role) => ({ ...role, role_id: role.roleId, role_name: role.roleName }),
  toApi: (role) => ({ roleName: role.role_name, description: role.description || null }),
});
