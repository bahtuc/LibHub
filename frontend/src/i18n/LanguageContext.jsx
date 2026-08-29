import { createContext, useContext, useEffect, useMemo, useState } from "react";

const STORAGE_KEY = "libhub-language";

const messages = {
  vi: {
    "brand.subtitle": "THƯ VIỆN SỐ",
    "language.label": "Ngôn ngữ",
    "language.vi": "Chuyển sang tiếng Việt", "language.en": "Chuyển sang tiếng Anh",
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
    "library.filterAvailability": "Lọc tình trạng sách", "library.sortLabel": "Sắp xếp sách", "library.filterGenre": "Lọc theo thể loại",
    "book.unknownAuthor": "Chưa rõ tác giả",
    "book.unclassified": "Chưa phân loại",
    "book.availableCopies": "{count} bản sẵn sàng",
    "book.borrowed": "Đang được mượn",
    "book.viewDetails": "Xem chi tiết {title}", "book.open": "Mở {title}",
    "pagination.label": "Phân trang",
    "pagination.previous": "Trước",
    "pagination.next": "Sau",
    "register.title": "Tạo tài khoản LibHub", "register.subtitle": "Đăng ký để mượn và theo dõi sách.", "register.fullName": "Họ và tên", "register.username": "Tên đăng nhập", "register.email": "Email", "register.phone": "Số điện thoại", "register.password": "Mật khẩu", "register.confirm": "Nhập lại mật khẩu", "register.mismatch": "Mật khẩu nhập lại không khớp.", "register.submit": "Đăng ký", "register.haveAccount": "Đã có tài khoản?", "register.signIn": "Đăng nhập",
    "forgot.requestTitle": "Quên mật khẩu", "forgot.requestSubtitle": "Nhập tên đăng nhập hoặc email để nhận mã OTP 6 số.", "forgot.otpTitle": "Nhập mã OTP", "forgot.otpSubtitle": "Mã OTP 6 số đã được gửi cho tài khoản {username}.", "forgot.resetTitle": "Đặt mật khẩu mới", "forgot.resetSubtitle": "Xác thực thành công. Hãy nhập mật khẩu mới cho tài khoản của bạn.", "forgot.identity": "Tên đăng nhập hoặc email", "forgot.identityPlaceholder": "ví dụ: admin hoặc admin@libhub.vn", "forgot.send": "Gửi mã OTP", "forgot.demoCode": "Mã OTP dùng thử của bạn là", "forgot.otp": "Mã OTP (6 số)", "forgot.verify": "Xác nhận mã OTP", "forgot.resend": "Gửi lại mã", "forgot.newPassword": "Mật khẩu mới", "forgot.confirmPassword": "Xác nhận mật khẩu mới", "forgot.change": "Đổi mật khẩu", "forgot.back": "Quay lại đăng nhập", "forgot.tooShort": "Mật khẩu cần tối thiểu 6 ký tự.",
    "genres.eyebrow": "Duyệt kệ sách", "genres.title": "Thể loại", "genres.loading": "Đang tải...", "genres.view": "Xem sách", "genres.all": "Tất cả thể loại", "genres.summary": "{count} đầu sách · {pages} trang", "genres.page": "Trang {current} / {total}", "genres.showing": "Hiển thị {from}–{to}", "genres.notFound": "Không tìm thấy thể loại.", "genres.empty": "Thể loại này chưa có sách.", "genres.pagination": "Các trang sách thuộc thể loại {name}",
    "detail.loading": "Đang tải thông tin sách...", "detail.notFound": "Không tìm thấy sách.", "detail.back": "Quay lại thư viện", "detail.pages": "{count} trang", "detail.available": "Còn sách", "detail.unavailable": "Đã mượn hết", "detail.copiesAvailable": "{available} / {total} bản đang có sẵn", "detail.allBorrowed": "{total} bản hiện đều đang được mượn", "detail.duration": "Thời hạn mượn", "detail.days": "ngày", "detail.fee": "Phí: {amount}", "detail.login": "Đăng nhập để mượn", "detail.redirecting": "Đang chuyển VNPay...", "detail.success": "Đã mượn thành công", "detail.borrowPay": "Mượn & thanh toán VNPay", "detail.outOfStock": "Hiện đã hết sách", "detail.related": "Sách cùng thể loại", "detail.paymentConfirm": "Bạn sẽ được chuyển sang VNPay để thanh toán {amount} cho {days} ngày mượn. Tiếp tục?", "detail.noPaymentUrl": "Không nhận được đường dẫn thanh toán VNPay.", "detail.borrowError": "Không thể mượn sách.",
    "notFound.eyebrow": "Trang không tồn tại", "notFound.title": "Chiếc kệ này đang trống.", "notFound.description": "Đường dẫn có thể đã thay đổi. Hãy quay về kho sách để tiếp tục khám phá.", "notFound.action": "Về kho sách",
    "admin.brand": "Quản trị", "admin.librarian": "Thủ thư", "admin.operations": "Nghiệp vụ", "admin.home": "Về trang chủ", "admin.add": "Thêm mới", "admin.edit": "Chỉnh sửa — {title}", "admin.addTitle": "Thêm mới — {title}", "admin.choose": "Chọn…", "admin.saving": "Đang lưu…", "admin.save": "Lưu thay đổi", "admin.cancel": "Hủy", "admin.actions": "Thao tác", "admin.editAction": "Sửa", "admin.deleteAction": "Xóa", "admin.deleteConfirm": "Xóa?", "admin.cannotDelete": "Không thể xóa mục này", "admin.empty": "Chưa có dữ liệu.", "admin.summary": "Hiển thị {from}–{to} trong tổng số {count} mục", "admin.saveError": "Không thể lưu dữ liệu.", "admin.deleteError": "Không thể xóa dữ liệu.", "admin.coverPreview": "Xem trước ảnh bìa", "admin.coverError": "Không tải được ảnh. Hãy kiểm tra lại đường dẫn URL.",
    "account.eyebrow": "Tài khoản", "account.hello": "Xin chào, {name}", "account.description": "Quản lý thông tin cá nhân, mật khẩu, bảo mật và lịch sử mượn sách.", "account.address": "Địa chỉ", "account.memberSince": "Thành viên từ", "account.activeLoans": "Đang mượn", "account.unpaidFines": "Phạt chưa thu", "account.profileSaved": "Đã lưu thông tin.", "account.profileError": "Không thể cập nhật hồ sơ.", "account.currentPassword": "Mật khẩu hiện tại", "account.newPassword": "Mật khẩu mới", "account.confirmPassword": "Nhập lại mật khẩu mới", "account.changePassword": "Đổi mật khẩu", "account.passwordSuccess": "Đổi mật khẩu thành công.", "account.passwordError": "Không thể đổi mật khẩu.", "account.twoFactor": "Xác minh hai bước", "account.twoFactorDescription": "Khi bật, LibHub sẽ gửi mã gồm 6 chữ số đến email của bạn sau khi mật khẩu được xác nhận.", "account.enabled": "Đang bật", "account.disabled": "Đang tắt", "account.noEmail": "Tài khoản chưa có email", "account.twoFactorLabel": "Xác minh hai bước qua email", "account.twoFactorNote": "Bạn vẫn đăng nhập bằng mật khẩu như bình thường khi tùy chọn này tắt.", "account.twoFactorOn": "Đã bật xác minh hai bước qua email.", "account.twoFactorOff": "Đã tắt xác minh hai bước.", "account.securityError": "Không thể cập nhật cài đặt bảo mật.", "account.loadingLoans": "Đang tải lịch sử mượn sách...", "account.noLoans": "Bạn chưa mượn cuốn sách nào.", "account.loadingFines": "Đang tải khoản phạt...", "account.noFines": "Bạn không có khoản phạt nào.", "account.totalDue": "Tổng còn nợ: {amount}", "account.libraryFee": "Phí thư viện", "account.paid": "Đã thanh toán", "account.unpaid": "Chưa thanh toán", "account.redirecting": "Đang chuyển...", "account.pay": "Thanh toán", "account.ticketId": "Mã phiếu", "account.book": "Sách", "account.borrowDate": "Ngày mượn", "account.dueDate": "Hạn trả", "account.status": "Trạng thái", "account.fineId": "Mã phạt", "account.reason": "Lý do", "account.createdAt": "Ngày tạo", "account.amount": "Số tiền",
    "payment.successTitle": "Thanh toán thành công", "payment.successDescription": "Giao dịch của bạn đã được ghi nhận.", "payment.failedTitle": "Thanh toán thất bại", "payment.failedDescription": "Giao dịch chưa hoàn tất hoặc đã bị hủy. Bạn có thể thử lại.", "payment.invalidTitle": "Không xác thực được giao dịch", "payment.invalidDescription": "Chữ ký VNPay không hợp lệ. Vui lòng thử lại hoặc liên hệ thủ thư.", "payment.borrowSuccess": "Phiếu mượn đã được kích hoạt và sách đã được giữ cho bạn.", "payment.responseCode": "Mã phản hồi VNPay: {code}", "payment.viewLoan": "Xem phiếu mượn", "payment.account": "Về tài khoản",
  },
  en: {
    "brand.subtitle": "DIGITAL LIBRARY",
    "language.label": "Language",
    "language.vi": "Switch to Vietnamese", "language.en": "Switch to English",
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
    "library.filterAvailability": "Filter availability", "library.sortLabel": "Sort books", "library.filterGenre": "Filter by genre",
    "book.unknownAuthor": "Unknown author", "book.unclassified": "Unclassified", "book.availableCopies": "{count} copies available", "book.borrowed": "On loan",
    "book.viewDetails": "View details for {title}", "book.open": "Open {title}",
    "pagination.label": "Pagination", "pagination.previous": "Previous", "pagination.next": "Next",
    "register.title": "Create your LibHub account", "register.subtitle": "Register to borrow and track books.", "register.fullName": "Full name", "register.username": "Username", "register.email": "Email", "register.phone": "Phone number", "register.password": "Password", "register.confirm": "Confirm password", "register.mismatch": "The passwords do not match.", "register.submit": "Register", "register.haveAccount": "Already have an account?", "register.signIn": "Sign in",
    "forgot.requestTitle": "Forgot password", "forgot.requestSubtitle": "Enter your username or email to receive a 6-digit OTP.", "forgot.otpTitle": "Enter the OTP", "forgot.otpSubtitle": "A 6-digit OTP was sent for account {username}.", "forgot.resetTitle": "Set a new password", "forgot.resetSubtitle": "Verification succeeded. Enter a new password for your account.", "forgot.identity": "Username or email", "forgot.identityPlaceholder": "e.g. admin or admin@libhub.vn", "forgot.send": "Send OTP", "forgot.demoCode": "Your demo OTP is", "forgot.otp": "OTP (6 digits)", "forgot.verify": "Verify OTP", "forgot.resend": "Resend code", "forgot.newPassword": "New password", "forgot.confirmPassword": "Confirm new password", "forgot.change": "Change password", "forgot.back": "Back to sign in", "forgot.tooShort": "Password must contain at least 6 characters.",
    "genres.eyebrow": "Browse the shelves", "genres.title": "Genres", "genres.loading": "Loading...", "genres.view": "View books", "genres.all": "All genres", "genres.summary": "{count} titles · {pages} pages", "genres.page": "Page {current} / {total}", "genres.showing": "Showing {from}–{to}", "genres.notFound": "Genre not found.", "genres.empty": "There are no books in this genre yet.", "genres.pagination": "Pages for books in {name}",
    "detail.loading": "Loading book details...", "detail.notFound": "Book not found.", "detail.back": "Back to the library", "detail.pages": "{count} pages", "detail.available": "Available", "detail.unavailable": "All copies on loan", "detail.copiesAvailable": "{available} / {total} copies available", "detail.allBorrowed": "All {total} copies are currently on loan", "detail.duration": "Loan period", "detail.days": "days", "detail.fee": "Fee: {amount}", "detail.login": "Sign in to borrow", "detail.redirecting": "Redirecting to VNPay...", "detail.success": "Borrowed successfully", "detail.borrowPay": "Borrow & pay with VNPay", "detail.outOfStock": "Currently unavailable", "detail.related": "Related books", "detail.paymentConfirm": "You will be redirected to VNPay to pay {amount} for a {days}-day loan. Continue?", "detail.noPaymentUrl": "VNPay did not return a payment URL.", "detail.borrowError": "Unable to borrow this book.",
    "notFound.eyebrow": "Page not found", "notFound.title": "This shelf is empty.", "notFound.description": "The address may have changed. Return to the library to keep exploring.", "notFound.action": "Go to the library",
    "admin.brand": "Admin", "admin.librarian": "Librarian", "admin.operations": "Operations", "admin.home": "Back to home", "admin.add": "Add new", "admin.edit": "Edit — {title}", "admin.addTitle": "Add — {title}", "admin.choose": "Choose…", "admin.saving": "Saving…", "admin.save": "Save changes", "admin.cancel": "Cancel", "admin.actions": "Actions", "admin.editAction": "Edit", "admin.deleteAction": "Delete", "admin.deleteConfirm": "Delete?", "admin.cannotDelete": "This item cannot be deleted", "admin.empty": "No data yet.", "admin.summary": "Showing {from}–{to} of {count} items", "admin.saveError": "Unable to save data.", "admin.deleteError": "Unable to delete data.", "admin.coverPreview": "Book cover preview", "admin.coverError": "Could not load the image. Check the URL and try again.",
    "account.eyebrow": "Account", "account.hello": "Hello, {name}", "account.description": "Manage your profile, password, security, and borrowing history.", "account.address": "Address", "account.memberSince": "Member since", "account.activeLoans": "Active loans", "account.unpaidFines": "Unpaid fines", "account.profileSaved": "Profile saved.", "account.profileError": "Unable to update your profile.", "account.currentPassword": "Current password", "account.newPassword": "New password", "account.confirmPassword": "Confirm new password", "account.changePassword": "Change password", "account.passwordSuccess": "Password changed successfully.", "account.passwordError": "Unable to change password.", "account.twoFactor": "Two-step verification", "account.twoFactorDescription": "When enabled, LibHub sends a 6-digit code to your email after your password is confirmed.", "account.enabled": "Enabled", "account.disabled": "Disabled", "account.noEmail": "This account has no email address", "account.twoFactorLabel": "Email two-step verification", "account.twoFactorNote": "You can continue signing in with your password normally while this option is disabled.", "account.twoFactorOn": "Email two-step verification enabled.", "account.twoFactorOff": "Two-step verification disabled.", "account.securityError": "Unable to update security settings.", "account.loadingLoans": "Loading borrowing history...", "account.noLoans": "You have not borrowed any books yet.", "account.loadingFines": "Loading fines...", "account.noFines": "You have no fines.", "account.totalDue": "Total due: {amount}", "account.libraryFee": "Library fee", "account.paid": "Paid", "account.unpaid": "Unpaid", "account.redirecting": "Redirecting...", "account.pay": "Pay", "account.ticketId": "Loan ID", "account.book": "Book", "account.borrowDate": "Borrowed", "account.dueDate": "Due date", "account.status": "Status", "account.fineId": "Fine ID", "account.reason": "Reason", "account.createdAt": "Created", "account.amount": "Amount",
    "payment.successTitle": "Payment successful", "payment.successDescription": "Your transaction has been recorded.", "payment.failedTitle": "Payment failed", "payment.failedDescription": "The transaction was not completed or was cancelled. You can try again.", "payment.invalidTitle": "Could not verify payment", "payment.invalidDescription": "The VNPay signature is invalid. Try again or contact a librarian.", "payment.borrowSuccess": "Your loan is active and the books have been reserved for you.", "payment.responseCode": "VNPay response code: {code}", "payment.viewLoan": "View loan", "payment.account": "Back to account",
  },
};

const labelTranslations = {
  "Điều hành": "Operations", "Tổng quan": "Overview", "Thống kê": "Statistics",
  "Nghiệp vụ thủ thư": "Library operations", "Lập phiếu mượn": "Create loan",
  "Mượn · trả sách": "Borrow · return", "Thu khoản phạt": "Collect fines",
  "Kho sách": "Books", "Bản sao sách": "Book copies", "Quản trị hệ thống": "System administration",
  "Thể loại": "Genres", "Tác giả": "Authors", "Nhà xuất bản": "Publishers",
  "Người dùng": "Users", "Quản lý phiếu mượn": "Manage loans", "Quản lý khoản phạt": "Manage fines",
  "Mượn sách": "Borrow books", "Phiếu mượn": "Loans", "Phạt": "Fines",
  "Tên sách": "Title", "ISBN": "ISBN", "Năm xuất bản": "Publication year", "Ngôn ngữ": "Language",
  "Số trang": "Pages", "Mô tả": "Description", "Ảnh bìa": "Cover image", "Trạng thái": "Status",
  "Họ và tên": "Full name", "Tên đăng nhập": "Username", "Số điện thoại": "Phone number",
  "Vai trò": "Role", "Mật khẩu": "Password", "Địa chỉ": "Address", "Số lượng": "Quantity",
  "Hồ sơ": "Profile", "Đổi mật khẩu": "Change password", "Bảo mật": "Security",
  "Đang mượn": "Borrowing", "Quá hạn": "Overdue", "Đã trả": "Returned", "Đã hủy": "Cancelled",
  "Chờ thanh toán VNPay": "Awaiting VNPay payment", "Phạt chưa thu": "Unpaid fines",
  "Tên thể loại": "Genre name", "Tên tác giả": "Author name", "Tên nhà xuất bản": "Publisher name",
  "Đầu sách": "Titles", "Đang được mượn": "On loan", "Bản còn sẵn": "Available copies",
  "Sách mượn trong tháng": "Books borrowed this month", "Sách trả trong tháng": "Books returned this month",
  "Sách chưa có người mượn": "Never-borrowed books", "Phí mượn sách": "Loan fees", "Tiền phạt đã thu": "Collected fines",
  "Các phiếu đã thanh toán trong tháng": "Loans paid this month", "Các khoản phạt đã thanh toán trong tháng": "Fines paid this month",
  "Thống kê tài chính": "Financial statistics", "Doanh thu theo nguồn": "Revenue by source", "Nguồn thu": "Revenue source",
  "Ghi chú": "Notes", "Tổng doanh thu": "Total revenue", "Phí mượn và tiền phạt đã thu": "Loan fees and collected fines",
  "Tiền phạt theo loại": "Fines by type", "Loại phạt": "Fine type", "Số khoản": "Count", "Đã thu": "Collected",
  "Chưa thu": "Outstanding", "Tổng phát sinh": "Total", "Mức độ đọc sách": "Reading activity",
  "Được đọc nhiều nhất": "Most borrowed", "Được đọc ít nhất": "Least borrowed", "Lượt mượn": "Loans",
  "Xem thống kê": "View statistics", "Vận hành kho sách": "Manage collection", "Xử lý mượn · trả": "Process borrowing · returns",
  "Admin có đầy đủ quyền vận hành quầy mượn trả.": "Administrators have full access to circulation operations.",
  "Số liệu nhanh từ dữ liệu hiện có trong hệ thống (đã tính cả thay đổi bạn thêm/sửa).": "A live snapshot of current system data, including your latest changes.",
  "Dùng menu bên trái để truy cập nghiệp vụ thủ thư, quản trị dữ liệu và báo cáo thống kê.": "Use the sidebar to access circulation, data administration, and reports.",
  "Hiệu quả lưu thông sách và doanh thu trong tháng hiện tại.": "Circulation performance and revenue for the current month.",
  "Doanh thu và cơ cấu tiền phạt trong tháng hiện tại.": "Revenue and fine composition for the current month.",
  "Xếp theo tổng lượt mượn, bao gồm sách chưa từng được đọc.": "Ranked by total loans, including books that have never been borrowed.",
  "Chưa phát sinh tiền phạt trong tháng.": "No fines were issued this month.", "Đang tải dữ liệu…": "Loading data…",
};

const categoryTranslations = {
  "Văn học": "Literature", "Kỹ năng sống": "Life skills", "Kinh tế": "Economics",
  "Công nghệ": "Technology", "Khoa học": "Science", "Lịch sử": "History",
  "Thiếu nhi": "Children", "Tâm lý": "Psychology", "Giáo dục": "Education",
  "Tiểu thuyết": "Novels", "Hồi ký": "Memoir", "Phật giáo": "Buddhism",
  "Kinh doanh": "Business", "Công nghệ thông tin": "Information technology",
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

  useEffect(() => {
    const syncLanguage = (event) => {
      if (event.key === STORAGE_KEY && (event.newValue === "vi" || event.newValue === "en")) {
        setLanguage(event.newValue);
      }
    };
    window.addEventListener("storage", syncLanguage);
    return () => window.removeEventListener("storage", syncLanguage);
  }, []);

  const locale = language === "en" ? "en-US" : "vi-VN";

  const value = useMemo(() => ({
    language,
    locale,
    setLanguage(nextLanguage) {
      setLanguage(nextLanguage === "en" ? "en" : "vi");
    },
    t(key, values = {}) {
      const template = messages[language][key] ?? messages.vi[key] ?? key;
      return Object.entries(values).reduce(
        (text, [name, replacement]) => text.replaceAll(`{${name}}`, replacement),
        template,
      );
    },
    translateLabel(label) {
      return language === "en" ? (labelTranslations[label] ?? label) : label;
    },
    translateCategory(name) {
      return language === "en" ? (categoryTranslations[name] ?? name) : name;
    },
    formatNumber(value, options) {
      return new Intl.NumberFormat(locale, options).format(Number(value ?? 0));
    },
    formatCurrency(value) {
      return new Intl.NumberFormat(locale, { style: "currency", currency: "VND", maximumFractionDigits: 0 }).format(Number(value ?? 0));
    },
    formatDate(value, options = { dateStyle: "medium" }) {
      if (!value) return "—";
      const date = new Date(value);
      return Number.isNaN(date.getTime()) ? String(value) : new Intl.DateTimeFormat(locale, options).format(date);
    },
  }), [language]);

  return <LanguageContext.Provider value={value}>{children}</LanguageContext.Provider>;
}

export function useLanguage() {
  const context = useContext(LanguageContext);
  if (!context) throw new Error("useLanguage must be used inside LanguageProvider");
  return context;
}
