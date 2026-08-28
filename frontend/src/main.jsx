import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import { AuthProvider } from "./auth/useAuth.jsx";
import { CatalogProvider } from "./context/CatalogContext.jsx";
import AppRouter from "./router/AppRouter.jsx";
import ScrollToTop from "./components/ScrollToTop.jsx";
import { LanguageProvider } from "./i18n/LanguageContext.jsx";
import "./styles/theme.css";
import "./styles/rebuild.css";
import "./styles/reading-room.css";

createRoot(document.getElementById("root")).render(
  <StrictMode>
    <BrowserRouter
      future={{
        v7_startTransition: true,
        v7_relativeSplatPath: true,
      }}
    >
      <LanguageProvider>
        <AuthProvider>
          <CatalogProvider>
            <ScrollToTop />
            <AppRouter />
          </CatalogProvider>
        </AuthProvider>
      </LanguageProvider>
    </BrowserRouter>
  </StrictMode>
);
