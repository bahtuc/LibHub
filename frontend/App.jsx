import { BrowserRouter, Routes, Route } from "react-router-dom";
import { AuthProvider } from "./context/AuthContext";
import Header from "./layouts/header.jsx";
import Home from "./pages/home.jsx";
import Library from "./pages/library.jsx";
import Genres from "./pages/genres.jsx";
import Featured from "./pages/featured.jsx";
import Contact from "./pages/contact.jsx";
import Login from "./pages/login.jsx";
import Register from "./pages/register.jsx";

function App() {
    return (
        <BrowserRouter>
            <AuthProvider>
                <Header />
                <Routes>
                    <Route path="/" element={<Home />} />
                    <Route path="/library" element={<Library />} />
                    <Route path="/genres" element={<Genres />} />
                    <Route path="/featured" element={<Featured />} />
                    <Route path="/contact" element={<Contact />} />
                    <Route path="/login" element={<Login />} />
                    <Route path="/register" element={<Register />} />
                </Routes>
            </AuthProvider>
        </BrowserRouter>
    );
}

export default App;