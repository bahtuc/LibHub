# LibHub — Homepage (React)

Trang chủ cho hệ thống quản lý thư viện **LibHub**, dựng theo cấu trúc DB của
nhóm (Books, Categories, Authors, BorrowTickets…). Layout lấy cảm hứng từ
mẫu tham khảo (hero → quick links → nội dung nổi bật → khối thống kê →
liên hệ → footer), nhưng đổi màu/nội dung/hình ảnh cho đúng chủ đề thư viện.

## Chạy dự án (đã cấu hình sẵn Vite)

```bash
npm install
npm run dev
```

Mở địa chỉ hiện ra trong terminal (mặc định `http://localhost:5173`).

Build bản production:

```bash
npm run build   # xuất ra thư mục dist/
npm run preview # xem thử bản build
```

Đây là project đã dùng thật được ngay: `npm install` cài `react`,
`react-dom`, `vite`, `@vitejs/plugin-react`; `npm run dev` mở dev server
với hot reload. Đã kiểm tra chạy được `npm install && npm run build`
không lỗi trước khi gửi.

`standalone-preview.html` là bản demo cũ dùng React qua CDN (mở trực
tiếp bằng `npx serve .`, không cần `npm install`) — chỉ để xem nhanh giao
diện, **không dùng trong dự án thật**, project thật dùng `index.html` +
`src/main.jsx` ở trên.

## Tích hợp vào project React đã có sẵn của nhóm

Nếu nhóm đã có project React riêng (không dùng project Vite này), chỉ
cần copy thư mục `src/` (trừ `main.jsx`) sang, rồi:

```jsx
import Home from "./Home";

function App() {
  return <Home />;
}
```

`theme.css` đang `@import` font từ Google Fonts để tiện chạy ngay. Trong
production, nên chuyển các thẻ `<link>` font đó vào `index.html` (head)
để tránh chặn render:

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400;9..144,500;9..144,600;9..144,700&family=Inter:wght@400;500;600;700&family=IBM+Plex+Mono:wght@500;600&display=swap" rel="stylesheet">
```

## Cấu trúc

```
index.html                  # entry point Vite
vite.config.js
package.json
src/
  main.jsx                  # mount <Home /> vào #root
  Home.jsx                 # ghép các section lại thành trang chủ
  data/libraryData.js       # mock data — thay bằng API thật
  components/
    Header.jsx / Hero.jsx / QuickAccess.jsx
    FeaturedBooks.jsx / Categories.jsx / News.jsx
    StatsBand.jsx / Contact.jsx / Footer.jsx
    Icon.jsx                # bộ icon SVG inline, không phụ thuộc thư viện ngoài
  styles/
    theme.css                # design tokens (màu, font, spacing) dùng chung
    <TênComponent>.css       # CSS riêng cho từng section
```

Toàn bộ class đều có prefix `lh-` để tránh đụng CSS khi ghép vào app hiện có.

## Nối vào database thật

`src/data/libraryData.js` đang là mock data **đúng hình dạng** với schema
của nhóm (book_id, category_id, author_id…). Khi có backend, thay các
hằng số bằng gọi API tương ứng, ví dụ:

```js
// FeaturedBooks.jsx
const [books, setBooks] = useState([]);
useEffect(() => {
  fetch("/api/books?featured=true").then(r => r.json()).then(setBooks);
}, []);
```

Gợi ý endpoint tương ứng từng section:
- **Sách nổi bật** → `Books` JOIN `Categories`, `Authors` (lọc theo lượt mượn từ `BorrowDetails`)
- **Thể loại** → `Categories` (kèm COUNT sách từ `Books`)
- **Khối thống kê** → COUNT trên `Books`, `Users`, `Categories`, tỉ lệ `BookCopies.status = 'available'`
- **Tin tức** → nếu nhóm chưa có bảng tin tức, có thể thêm bảng `Announcements` sau

## Điểm thiết kế (design tokens)

- **Màu**: nền giấy ấm `#F7F2E6`, mực `#1C2620`, vàng ánh kim (gold-leaf)
  `#B9832A`, xanh rêu (nhãn kệ sách) `#3D6652`, đất nung `#A63D26`.
- **Font**: `Fraunces` (display, phong cách nhà in sách cũ), `Inter` (body),
  `IBM Plex Mono` (số liệu, nhãn, ngày tháng — như tem thư viện).
- **Signature**: dải "gáy sách" (book spines) lặp lại ở hero và khối thống
  kê, thay cho ảnh chụp stock; ảnh bìa sách dùng gradient màu theo thể loại
  thay vì ảnh giả cho tới khi có cover_image thật.

Responsive đầy đủ xuống mobile, focus-visible cho bàn phím, tôn trọng
`prefers-reduced-motion`.
