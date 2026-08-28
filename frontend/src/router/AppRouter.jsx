import { Navigate, Routes, Route } from "react-router-dom";

import Home from "../Home.jsx";
import Login from "../pages/Login.jsx";
import Register from "../pages/register.jsx";
import ForgotPassword from "../pages/ForgotPassword.jsx";
import Library from "../pages/Library.jsx";
import Genres from "../pages/Genres.jsx";
import GenreDetail from "../pages/GenreDetail.jsx";
import BookDetail from "../pages/bookDetail.jsx";
import Account from "../pages/Account.jsx";
import PaymentResult from "../pages/paymentResult.jsx";
import NotFound from "../pages/NotFound.jsx";

import RequireAuth from "../auth/RequireAuth.jsx";

import RequireAdmin from "../admin/RequireAdmin.jsx";
import AdminLayout from "../admin/AdminLayout.jsx";
import AdminDashboard from "../admin/AdminDashboard.jsx";
import AdminBooks from "../admin/AdminBooks.jsx";
import AdminBookCopies from "../admin/AdminBookCopies.jsx";
import AdminCategories from "../admin/AdminCategories.jsx";
import AdminAuthors from "../admin/AdminAuthors.jsx";
import AdminUsers from "../admin/AdminUsers.jsx";
import AdminPublisher from "../admin/AdminPublishers.jsx";
import AdminBorrowTickets from "../admin/AdminBorrowTickets.jsx";
import AdminFines from "../admin/AdminFines.jsx";
import AdminStatistics from "../admin/AdminStatistics.jsx";

import RequireLibrarian from "../librarian/RequireLibrarian.jsx";
import LibrarianLayout from "../librarian/LibrarianLayout.jsx";
import LibrarianDashboard from "../librarian/LibrarianDashboard.jsx";
import LibrarianBooks from "../librarian/LibrarianBooks.jsx";
import LibrarianBorrow from "../librarian/LibrarianBorrow.jsx";
import LibrarianTickets from "../librarian/LibrarianTickets.jsx";
import LibrarianFines from "../librarian/LibrarianFines.jsx";

export default function AppRouter() {
  return (
    <Routes>

      {/* ================= PUBLIC ================= */}

      <Route path="/" element={<Home />} />

      <Route path="/login" element={<Login />} />

      <Route path="/register" element={<Register />} />

      <Route
        path="/forgot-password"
        element={<ForgotPassword />}
      />

      <Route
        path="/library"
        element={<Library />}
      />

      <Route
        path="/genres"
        element={<Genres />}
      />

      <Route
        path="/genres/:categoryId"
        element={<GenreDetail />}
      />

      <Route
        path="/books/:bookId"
        element={<BookDetail />}
      />

      <Route
        path="/payment/result"
        element={<PaymentResult />}
      />


      {/* ================= USER ================= */}

      <Route
        path="/account"
        element={
          <RequireAuth>
            <Account />
          </RequireAuth>
        }
      />

      <Route
        path="/fines"
        element={
          <RequireAuth>
            <Navigate to="/account?tab=fines" replace />
          </RequireAuth>
        }
      />

      <Route
        path="/borrowbook"
        element={<Navigate to="/library" replace />}
      />


      {/* ================= ADMIN ================= */}

      <Route
        path="/admin"
        element={
          <RequireAdmin>
            <AdminLayout />
          </RequireAdmin>
        }
      >
        <Route
          index
          element={<AdminDashboard />}
        />

        <Route
          path="books"
          element={<AdminBooks />}
        />
        <Route path="statistics" element={<AdminStatistics />} />
        <Route path="borrow" element={<LibrarianBorrow />} />
        <Route path="circulation" element={<LibrarianTickets />} />
        <Route path="fine-collection" element={<LibrarianFines />} />

        <Route
          path="copies"
          element={<AdminBookCopies />}
        />

        <Route
          path="categories"
          element={<AdminCategories />}
        />

        <Route
          path="authors"
          element={<AdminAuthors />}
        />

        <Route
          path="publishers"
          element={<AdminPublisher />}
        />

        <Route
          path="users"
          element={<AdminUsers />}
        />

        <Route
          path="borrow-tickets"
          element={<AdminBorrowTickets />}
        />

        <Route
          path="fines"
          element={<AdminFines />}
        />
      </Route>


      {/* ================= LIBRARIAN ================= */}

      <Route
        path="/librarian"
        element={
          <RequireLibrarian>
            <LibrarianLayout />
          </RequireLibrarian>
        }
      >
        <Route
          index
          element={<LibrarianDashboard />}
        />

        <Route
          path="books"
          element={<LibrarianBooks />}
        />

        <Route
          path="borrow"
          element={<LibrarianBorrow />}
        />

        <Route
          path="tickets"
          element={<LibrarianTickets />}
        />

        <Route
          path="fines"
          element={<LibrarianFines />}
        />
      </Route>

      <Route path="*" element={<NotFound />} />

    </Routes>
  );
}
