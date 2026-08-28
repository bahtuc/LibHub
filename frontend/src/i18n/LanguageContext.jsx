import { createContext, useContext, useEffect, useMemo, useState } from "react";

const STORAGE_KEY = "libhub-language";

const messages = {
  vi: {
    "brand.subtitle": "THƯ VIỆN SỐ",
    "language.label": "Ngôn ngữ",
    "nav.home": "Trang chủ",
    "nav.library": "Kho sách",
    "nav.genres": "Thể loại",
    "nav.admin": "Quản trị",
    "nav.librarian": "Nghiệp vụ",
    "nav.account": "Tài khoản của tôi",
    "nav.login": "Đăng nhập",
    "nav.logout": "Đăng xuất",
    "nav.search": "Tìm kiếm sách",
    "nav.openMenu": "Mở menu",
    "nav.closeMenu": "Đóng menu",
    "hero.eyebrow": "Thư viện của những người tự học",
    "hero.title1": "Đọc chậm.",
    "hero.title2": "Nghĩ sâu.",
    "hero.description": "Tìm sách, đặt mượn và theo dõi hạn trả trong một trải nghiệm liền mạch — để thời gian của bạn dành cho việc đọc.",
    "hero.searchPlaceholder": "Tên sách, tác giả hoặc ISBN",
    "hero.explore": "Khám phá",
    "hero.viewAll": "Xem toàn bộ kho sách",
    "hero.available": "đầu sách đang sẵn sàng",
    "hero.books": "đầu sách",
    "hero.genres": "thể loại",
    "quick.label": "Truy cập nhanh",
    "quick.search.title": "Tra cứu nhanh",
    "quick.search.desc": "Tìm theo tên, tác giả hoặc ISBN",
    "quick.genres.title": "Khám phá thể loại",
    "quick.genres.desc": "Đi theo mạch đọc của riêng bạn",
    "quick.loans.title": "Phiếu mượn",
    "quick.loans.desc": "Theo dõi sách và hạn trả",
    "quick.fines.title": "Khoản phạt",
    "quick.fines.desc": "Tra cứu và thanh toán trực tuyến",
    "featured.eyebrow": "Tuyển chọn từ kho sách",
    "featured.title": "Đáng đọc tuần này",
    "common.viewAll": "Xem tất cả",
    "common.loadingBooks": "Đang tải sách",
    "categories.eyebrow": "Bản đồ tri thức",
    "categories.title": "Chọn một hướng để bắt đầu",
    "categories.all": "Mọi thể loại",
    "categories.bookCount": "{count} đầu sách",
    "stats.eyebrow": "Một hệ thống, trọn vòng đời",
    "stats.title1": "Từ kệ sách",
    "stats.title2": "đến tay người đọc.",
    "stats.description": "LibHub kết nối từng bản sách, phiếu mượn, lượt trả và thanh toán để mọi thông tin luôn rõ ràng.",
    "stats.start": "Bắt đầu tìm sách",
    "stats.titles": "đầu sách",
    "stats.copies": "bản có sẵn",
    "stats.authors": "tác giả",
    "stats.genres": "thể loại",
    "contact.eyebrow": "Cần một thủ thư?",
    "contact.title": "Chúng tôi ở đây để giúp bạn đọc tiếp.",
    "contact.description": "Hỏi về tài khoản, phiếu mượn, hạn trả hoặc một cuốn sách bạn chưa tìm thấy.",
    "contact.phone": "Điện thoại",
    "contact.hours": "Giờ phục vụ",
    "footer.description": "Không gian số giúp thư viện vận hành gọn hơn và người đọc tìm được cuốn sách tiếp theo nhanh hơn.",
    "footer.explore": "Khám phá",
    "footer.services": "Dịch vụ",
    "footer.loans": "Phiếu mượn",
    "footer.fines": "Khoản phạt",
    "footer.contact": "Liên hệ thủ thư",
    "footer.location": "Thư viện số · Hồ Chí Minh, Việt Nam",
    "auth.backHome": "Về trang chủ",
    "auth.switchLabel": "Chuyển đăng nhập / đăng ký",
    "auth.login": "Đăng nhập",
    "auth.register": "Đăng ký",
    "auth.bullet1": "Theo dõi phiếu mượn thời gian thực",
    "auth.bullet2": "Hàng nghìn đầu sách",
    "auth.bullet3": "Gia hạn trong vài giây",
    "login.welcome": "Chào mừng trở lại",
    "login.subtitle": "Đăng nhập để tiếp tục sử dụng LibHub.",
    "login.identity": "Tên đăng nhập hoặc email",
    "login.password": "Mật khẩu",
    "login.submit": "Đăng nhập",
    "login.submitting": "Đang kiểm tra...",
    "login.noAccount": "Chưa có tài khoản?",
    "login.registerNow": "Đăng ký ngay",
    "login.otpTitle": "Xác thực tài khoản",
    "login.otpSubtitle": "Nhập mã 6 chữ số đã được gửi đến {email}.",
    "login.otpLabel": "Mã xác thực",
    "login.otpHint": "Mã chỉ có hiệu lực trong 5 phút.",
    "login.verify": "Xác nhận và đăng nhập",
    "login.verifying": "Đang xác nhận...",
    "login.back": "Quay lại nhập mật khẩu",
    "library.eyebrow": "Khám phá thư viện",
    "library.title": "Tìm cuốn sách tiếp theo của bạn",
    "library.description": "Tìm theo tên, tác giả hoặc ISBN. Mở trang chi tiết để xem thông tin và đăng ký mượn.",
    "library.statsLabel": "Thống kê kho sách",
    "library.titles": "Đầu sách",
    "library.available": "Đang còn sách",
    "library.searchPlaceholder": "Tìm tên sách, tác giả hoặc ISBN...",
    "library.clearKeyword": "Xóa từ khóa",
    "library.allStatuses": "Tất cả tình trạng",
    "library.inStock": "Còn sách",
    "library.sortTitle": "Tên A–Z",
    "library.sortNewest": "Mới xuất bản",
    "library.sortAvailable": "Nhiều bản có sẵn",
    "library.all": "Tất cả",
    "library.results": "kết quả",
    "library.showing": "Hiển thị {from}–{to}",
    "library.clearFilters": "Xóa bộ lọc",
    "library.loading": "Đang tải kho sách...",
    "library.emptyTitle": "Không tìm thấy sách phù hợp",
    "library.emptyText": "Thử từ khóa khác hoặc xóa bớt bộ lọc.",
    "book.unknownAuthor": "Chưa rõ tác giả",
    "book.unclassified": "Chưa phân loại",
    "book.availableCopies": "{count} bản sẵn sàng",
    "book.borrowed": "Đang được mượn",
    "pagination.label": "Phân trang",
    "pagination.previous": "Trước",
    "pagination.next": "Sau",
  },
  en: {
    "brand.subtitle": "DIGITAL LIBRARY",
    "language.label": "Language",
    "nav.home": "Home", "nav.library": "Library", "nav.genres": "Genres", "nav.admin": "Admin", "nav.librarian": "Operations", "nav.account": "My account", "nav.login": "Sign in", "nav.logout": "Sign out", "nav.search": "Search books", "nav.openMenu": "Open menu", "nav.closeMenu": "Close menu",
    "hero.eyebrow": "A library for lifelong learners", "hero.title1": "Read slowly.", "hero.title2": "Think deeply.", "hero.description": "Find books, place requests, and track due dates in one seamless experience — so your time stays focused on reading.", "hero.searchPlaceholder": "Title, author, or ISBN", "hero.explore": "Explore", "hero.viewAll": "Browse the full collection", "hero.available": "titles ready to borrow", "hero.books": "titles", "hero.genres": "genres",
    "quick.label": "Quick access", "quick.search.title": "Quick search", "quick.search.desc": "Search by title, author, or ISBN", "quick.genres.title": "Explore genres", "quick.genres.desc": "Follow your own reading path", "quick.loans.title": "My loans", "quick.loans.desc": "Track books and due dates", "quick.fines.title": "Fines", "quick.fines.desc": "Review and pay online",
    "featured.eyebrow": "Selected from the collection", "featured.title": "Worth reading this week", "common.viewAll": "View all", "common.loadingBooks": "Loading books",
    "categories.eyebrow": "Knowledge map", "categories.title": "Choose a direction to begin", "categories.all": "All genres", "categories.bookCount": "{count} titles",
    "stats.eyebrow": "One system, the full lifecycle", "stats.title1": "From the shelf", "stats.title2": "to the reader.", "stats.description": "LibHub connects every copy, loan, return, and payment so the full picture always stays clear.", "stats.start": "Start finding books", "stats.titles": "titles", "stats.copies": "available copies", "stats.authors": "authors", "stats.genres": "genres",
    "contact.eyebrow": "Need a librarian?", "contact.title": "We are here to keep you reading.", "contact.description": "Ask about your account, loans, due dates, or a book you cannot find.", "contact.phone": "Phone", "contact.hours": "Service hours",
    "footer.description": "A digital space that helps libraries run smoothly and readers find their next book faster.", "footer.explore": "Explore", "footer.services": "Services", "footer.loans": "Loans", "footer.fines": "Fines", "footer.contact": "Contact a librarian", "footer.location": "Digital library · Ho Chi Minh City, Vietnam",
    "auth.backHome": "Back to home", "auth.switchLabel": "Switch sign in / register", "auth.login": "Sign in", "auth.register": "Register", "auth.bullet1": "Track loans in real time", "auth.bullet2": "Thousands of titles", "auth.bullet3": "Renew in seconds",
    "login.welcome": "Welcome back", "login.subtitle": "Sign in to continue using LibHub.", "login.identity": "Username or email", "login.password": "Password", "login.submit": "Sign in", "login.submitting": "Checking...", "login.noAccount": "New to LibHub?", "login.registerNow": "Create an account", "login.otpTitle": "Verify your account", "login.otpSubtitle": "Enter the 6-digit code sent to {email}.", "login.otpLabel": "Verification code", "login.otpHint": "The code is valid for 5 minutes.", "login.verify": "Verify and sign in", "login.verifying": "Verifying...", "login.back": "Back to password",
    "library.eyebrow": "Explore the library", "library.title": "Find your next book", "library.description": "Search by title, author, or ISBN. Open a book page for details and borrowing options.", "library.statsLabel": "Collection statistics", "library.titles": "Titles", "library.available": "In stock", "library.searchPlaceholder": "Search title, author, or ISBN...", "library.clearKeyword": "Clear search", "library.allStatuses": "All availability", "library.inStock": "Available", "library.sortTitle": "Title A–Z", "library.sortNewest": "Newest", "library.sortAvailable": "Most copies available", "library.all": "All", "library.results": "results", "library.showing": "Showing {from}–{to}", "library.clearFilters": "Clear filters", "library.loading": "Loading the collection...", "library.emptyTitle": "No matching books found", "library.emptyText": "Try another search or remove some filters.",
    "book.unknownAuthor": "Unknown author", "book.unclassified": "Unclassified", "book.availableCopies": "{count} copies available", "book.borrowed": "On loan",
    "pagination.label": "Pagination", "pagination.previous": "Previous", "pagination.next": "Next",
  },
};

const LanguageContext = createContext(null);

export function LanguageProvider({ children }) {
  const [language, setLanguage] = useState(() => {
    const saved = localStorage.getItem(STORAGE_KEY);
    return saved === "en" ? "en" : "vi";
  });

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, language);
    document.documentElement.lang = language;
  }, [language]);

  const value = useMemo(() => ({
    language,
    setLanguage,
    t(key, values = {}) {
      const template = messages[language][key] ?? messages.vi[key] ?? key;
      return Object.entries(values).reduce(
        (text, [name, replacement]) => text.replaceAll(`{${name}}`, replacement),
        template,
      );
    },
  }), [language]);

  return <LanguageContext.Provider value={value}>{children}</LanguageContext.Provider>;
}

export function useLanguage() {
  const context = useContext(LanguageContext);
  if (!context) throw new Error("useLanguage must be used inside LanguageProvider");
  return context;
}
