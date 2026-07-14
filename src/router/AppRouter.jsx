// src/router/AppRouter.jsx
//
// Toàn bộ route của app. Thêm trang mới: tạo file trong src/pages,
// rồi khai báo thêm 1 dòng <Route> ở đây.

import { Routes, Route } from "react-router-dom";
import Home from "../Home.jsx";
import Login from "../pages/Login.jsx";
import Register from "../pages/Register.jsx";
import ForgotPassword from "../pages/ForgotPassword.jsx";
import Library from "../pages/Library.jsx";
import Genres from "../pages/Genres.jsx";
import GenreDetail from "../pages/GenreDetail.jsx";
import BookDetail from "../pages/BookDetail.jsx";

import RequireAdmin from "../admin/RequireAdmin.jsx";
import AdminLayout from "../admin/AdminLayout.jsx";
import AdminDashboard from "../admin/AdminDashboard.jsx";
import AdminBooks from "../admin/AdminBooks.jsx";
import AdminBookCopies from "../admin/AdminBookCopies.jsx";
import AdminCategories from "../admin/AdminCategories.jsx";
import AdminAuthors from "../admin/AdminAuthors.jsx";
import AdminUsers from "../admin/AdminUsers.jsx";

export default function AppRouter() {
  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/login" element={<Login />} />
      <Route path="/register" element={<Register />} />
      <Route path="/forgot-password" element={<ForgotPassword />} />
      <Route path="/library" element={<Library />} />
      <Route path="/genres" element={<Genres />} />
      <Route path="/genres/:categoryId" element={<GenreDetail />} />
      <Route path="/books/:bookId" element={<BookDetail />} />

      <Route
        path="/admin"
        element={
          <RequireAdmin>
            <AdminLayout />
          </RequireAdmin>
        }
      >
        <Route index element={<AdminDashboard />} />
        <Route path="books" element={<AdminBooks />} />
        <Route path="copies" element={<AdminBookCopies />} />
        <Route path="categories" element={<AdminCategories />} />
        <Route path="authors" element={<AdminAuthors />} />
        <Route path="users" element={<AdminUsers />} />
      </Route>
    </Routes>
  );
}
