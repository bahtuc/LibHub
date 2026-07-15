// src/data/reviews.js
//
// Đánh giá/bình luận sách. Chưa có bảng Reviews trong DB gốc nên đây là mock,
// gợi ý shape: { review_id, book_id, user_id?, reviewer_name, rating (1-5),
// comment, created_at }. Đánh giá người dùng tự viết trên trang chi tiết sách
// được lưu vào localStorage (key "libhub_reviews"), cộng dồn với mock có sẵn.
//
// Khi có backend: thay 2 hàm getReviewsForBook()/addReview() bằng
// GET /api/books/:id/reviews và POST /api/books/:id/reviews.

const STORAGE_KEY = "libhub_reviews";

// Mock ban đầu cho vài cuốn sách nổi bật.
const seedReviews = [
  { review_id: 1, book_id: 101, reviewer_name: "Minh Thư", rating: 5, comment: "Đọc lại vẫn thấy ấm áp như lần đầu, rất hợp để thư giãn cuối tuần.", created_at: "2026-06-02" },
  { review_id: 2, book_id: 101, reviewer_name: "Quốc Bảo", rating: 4, comment: "Văn phong nhẹ nhàng, dí dỏm, gợi nhớ tuổi thơ rất nhiều.", created_at: "2026-05-18" },
  { review_id: 3, book_id: 102, reviewer_name: "Hải Đăng", rating: 5, comment: "Góc nhìn lịch sử loài người cực kỳ mới mẻ, đọc một mạch không dứt ra được.", created_at: "2026-06-10" },
  { review_id: 4, book_id: 102, reviewer_name: "Thanh Trúc", rating: 4, comment: "Hơi dài nhưng bù lại rất nhiều insight thú vị.", created_at: "2026-05-30" },
  { review_id: 5, book_id: 103, reviewer_name: "Anh Khoa", rating: 5, comment: "Áp dụng vài nguyên tắc trong sách là thấy hiệu quả ngay, rất thực tế.", created_at: "2026-06-15" },
  { review_id: 6, book_id: 103, reviewer_name: "Ngọc Hân", rating: 4, comment: "Sách hay nhưng thư viện có mỗi 1 bản, mượn hơi khó.", created_at: "2026-06-01" },
  { review_id: 7, book_id: 105, reviewer_name: "Duy Tân", rating: 5, comment: "Cách tiếp cận tiền bạc qua câu chuyện dễ hiểu hơn nhiều so với sách tài chính khô khan.", created_at: "2026-06-20" },
  { review_id: 8, book_id: 106, reviewer_name: "Bảo Trâm", rating: 4, comment: "Buồn nhưng đẹp, Murakami viết về tuổi trẻ rất chân thực.", created_at: "2026-05-25" },
];

function loadUserReviews() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw ? JSON.parse(raw) : {};
  } catch {
    return {};
  }
}

export function getReviewsForBook(book_id) {
  const id = Number(book_id);
  const userReviews = loadUserReviews()[id] || [];
  return [...seedReviews.filter((r) => r.book_id === id), ...userReviews].sort(
    (a, b) => new Date(b.created_at) - new Date(a.created_at)
  );
}

export function getAverageRating(book_id) {
  const reviews = getReviewsForBook(book_id);
  if (reviews.length === 0) return { average: 0, count: 0 };
  const total = reviews.reduce((sum, r) => sum + r.rating, 0);
  return { average: Math.round((total / reviews.length) * 10) / 10, count: reviews.length };
}

export function addReview(book_id, { reviewer_name, rating, comment }) {
  const id = Number(book_id);
  const all = loadUserReviews();
  const list = all[id] || [];
  const newReview = {
    review_id: Date.now(),
    book_id: id,
    reviewer_name: reviewer_name.trim() || "Độc giả ẩn danh",
    rating,
    comment: comment.trim(),
    created_at: new Date().toISOString().slice(0, 10),
  };
  all[id] = [...list, newReview];
  localStorage.setItem(STORAGE_KEY, JSON.stringify(all));
  return newReview;
}
