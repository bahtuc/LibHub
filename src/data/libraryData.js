// src/data/libraryData.js
// Mock data shaped to match the LibHub schema (Books, Categories, Authors, BookCopies...).
// Replace the arrays below with real API calls to your backend
// e.g. GET /api/books, GET /api/books/:id, GET /api/categories, GET /api/stats

export const categories = [
  { category_id: 1, category_name: "Văn học", color: "#A63D26", icon: "book-open" },
  { category_id: 2, category_name: "Khoa học", color: "#3D6652", icon: "flask" },
  { category_id: 3, category_name: "Kỹ năng sống", color: "#C08A28", icon: "compass" },
  { category_id: 4, category_name: "Kinh doanh", color: "#2E4A6B", icon: "briefcase" },
  { category_id: 5, category_name: "Thiếu nhi", color: "#8A5A9E", icon: "star" },
  { category_id: 6, category_name: "Lịch sử", color: "#6B5B3E", icon: "landmark" },
];

export const authors = [
  { author_id: 1, author_name: "Nguyễn Nhật Ánh" },
  { author_id: 2, author_name: "Yuval Noah Harari" },
  { author_id: 3, author_name: "James Clear" },
  { author_id: 4, author_name: "Tô Hoài" },
  { author_id: 5, author_name: "Morgan Housel" },
  { author_id: 6, author_name: "Haruki Murakami" },
  { author_id: 7, author_name: "Nam Cao" },
  { author_id: 8, author_name: "Malcolm Gladwell" },
  { author_id: 9, author_name: "Dale Carnegie" },
  { author_id: 10, author_name: "Naval Ravikant" },
  { author_id: 11, author_name: "Rick Riordan" },
  { author_id: 12, author_name: "Trần Trọng Kim" },

  { author_id: 13, author_name: "J. K. Rowling" },
  { author_id: 14, author_name: "Paulo Coelho" },
  { author_id: 15, author_name: "Eric Ries" },
  { author_id: 16, author_name: "Robert T. Kiyosaki" },
  { author_id: 17, author_name: "George Orwell" },
  { author_id: 18, author_name: "Robert C. Martin" },
  { author_id: 19, author_name: "Erich Gamma, Richard Helm, Ralph Johnson & John Vlissides" },
  { author_id: 20, author_name: "Andrew Hunt & David Thomas" },
  { author_id: 21, author_name: "Cal Newport" },
  { author_id: 22, author_name: "David Goggins" },
  { author_id: 23, author_name: "J. R. R. Tolkien" },
  { author_id: 24, author_name: "Arthur Conan Doyle" },
  { author_id: 25, author_name: "Harper Lee" },
  { author_id: 26, author_name: "Daniel Kahneman" },
  { author_id: 27, author_name: "Peter Thiel" },
  { author_id: 28, author_name: "Stephen R. Covey" },
  { author_id: 29, author_name: "Héctor García & Francesc Miralles" },
  { author_id: 30, author_name: "Tôn Tử" },
];

// Shaped like the Books table (book_id, title, category_id, author_id, publish_year, pages,
// description, cover_image...). cover_image is left null on purpose. The UI (BookCard,
// BookDetail) checks localStorage first (key "libhub_book_covers", xem
// src/data/useBookCovers.js) rồi mới fallback về khối "gáy sách" màu theo thể loại.
export const books = [
  {
    book_id: 101,
    title: "Cho Tôi Xin Một Vé Đi Tuổi Thơ",
    author_id: 1,
    category_id: 1,
    publish_year: 2008,
    pages: 240,
    description:
      "Câu chuyện dí dỏm và đầy hoài niệm về tuổi thơ của một nhóm bạn nhỏ, nhìn thế giới người lớn bằng con mắt trẻ con đầy tưởng tượng.",
    cover_image: "https://www.nxbtre.com.vn/Images/Book/nxbtre_thumb_08142018_091438.jpg",
    status: "available",
    is_featured: true,
  },
  {
    book_id: 102,
    title: "Sapiens: Lược Sử Loài Người",
    author_id: 2,
    category_id: 6,
    publish_year: 2011,
    pages: 512,
    description:
      "Hành trình từ loài vượn người đến nền văn minh hiện đại, lý giải vì sao Sapiens trở thành loài thống trị hành tinh.",
    cover_image: "https://bizweb.dktcdn.net/100/197/269/products/sapiens-luoc-su-ve-loai-nguoi-outline-5-7-2017-02.jpg?v=1520935327270",
    status: "available",
    is_featured: true,
  },
  {
    book_id: 103,
    title: "Atomic Habits",
    author_id: 3,
    category_id: 3,
    publish_year: 2018,
    pages: 320,
    description:
      "Hướng dẫn xây dựng thói quen tốt và loại bỏ thói quen xấu bằng những thay đổi nhỏ nhưng bền vững mỗi ngày.",
    cover_image: "https://images-na.ssl-images-amazon.com/images/I/81kg51XRc1L.jpg",
    status: "borrowed",
    is_featured: true,
  },
  {
    book_id: 104,
    title: "Dế Mèn Phiêu Lưu Ký",
    author_id: 4,
    category_id: 5,
    publish_year: 1941,
    pages: 156,
    description:
      "Cuộc phiêu lưu của chú Dế Mèn qua nhiều vùng đất, học được những bài học quý giá về tình bạn và lòng dũng cảm.",
    cover_image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQrEnBODW73LEWKZisZlXET6rDsSrhsvzoZ3jaJcYgT5djgGzq-TY472rPp&s=10",
    status: "available",
    is_featured: true,
  },
  {
    book_id: 105,
    title: "Tâm Lý Học Về Tiền",
    author_id: 5,
    category_id: 4,
    publish_year: 2020,
    pages: 268,
    description:
      "Vì sao cách chúng ta cư xử với tiền quan trọng hơn kiến thức tài chính, qua những câu chuyện đời thường dễ hiểu.",
    cover_image: "https://cdn1.fahasa.com/media/flashmagazine/images/page_images/tam_ly_hoc_ve_tien/2023_03_23_16_24_40_1-390x510.jpg",
    status: "available",
    is_featured: true,
  },
  {
    book_id: 106,
    title: "Rừng Na Uy",
    author_id: 6,
    category_id: 1,
    publish_year: 1987,
    pages: 389,
    description:
      "Câu chuyện tình yêu và mất mát của tuổi trẻ Nhật Bản thập niên 1960, đượm buồn và đầy chất thơ.",
    cover_image: "https://bizweb.dktcdn.net/thumb/1024x1024/100/363/455/products/rungnauy004-f9a8f341-50e7-47b2-bccf-6923e33c998d.jpg?v=1723778526173",
    status: "borrowed",
    is_featured: true,
  },
  {
    book_id: 107,
    title: "Chí Phèo",
    author_id: 7,
    category_id: 1,
    publish_year: 1941,
    pages: 120,
    description:
      "Bi kịch của người nông dân bị tha hóa bởi xã hội cũ, một trong những tác phẩm hiện thực phê phán kinh điển.",
    cover_image: "https://product.hstatic.net/200000017360/product/chi-pheo_72e3f1370e484cf49b0fc94ee4ce0f80.jpg",
    status: "available",
    is_featured: false,
  },
  {
    book_id: 108,
    title: "Homo Deus: Lược Sử Tương Lai",
    author_id: 2,
    category_id: 6,
    publish_year: 2016,
    pages: 496,
    description:
      "Phần tiếp theo của Sapiens, bàn về tương lai loài người trong thời đại công nghệ và trí tuệ nhân tạo.",
    cover_image: "https://bizweb.dktcdn.net/thumb/1024x1024/100/363/455/products/homodeusluocsutuonglai01.jpg?v=1705552535243",
    status: "available",
    is_featured: false,
  },
  {
    book_id: 109,
    title: "Việt Nam Sử Lược",
    author_id: 12,
    category_id: 6,
    publish_year: 1920,
    pages: 456,
    description:
      "Bộ sử Việt Nam kinh điển, trình bày mạch lạc các giai đoạn lịch sử dân tộc từ khởi nguyên đến cận đại.",
    cover_image: "https://img.newshop.vn/uploads/products/59733/viet-nam-su-luoc-YWIo.jpg",
    status: "borrowed",
    is_featured: false,
  },
  {
    book_id: 110,
    title: "Outliers: Những Kẻ Xuất Chúng",
    author_id: 8,
    category_id: 3,
    publish_year: 2008,
    pages: 309,
    description:
      "Lý giải vì sao một số người thành công vượt trội — không chỉ nhờ tài năng mà còn nhờ cơ hội và bối cảnh.",
    cover_image: "https://bizweb.dktcdn.net/thumb/grande/100/197/269/products/nhung-ke-xuat-chung-outline-18-8-2022-01-2.jpg?v=1730357767780",
    status: "available",
    is_featured: false,
  },
  {
    book_id: 111,
    title: "Đắc Nhân Tâm",
    author_id: 9,
    category_id: 3,
    publish_year: 1936,
    pages: 320,
    description:
      "Cuốn cẩm nang kinh điển về nghệ thuật giao tiếp, ứng xử và chinh phục lòng người.",
    cover_image: "https://upload.wikimedia.org/wikipedia/vi/0/0a/%C4%90%E1%BA%AFc_nh%C3%A2n_t%C3%A2m.jpg",
    status: "available",
    is_featured: false,
  },
  {
    book_id: 112,
    title: "The Almanack Of Naval Ravikant",
    author_id: 10,
    category_id: 4,
    publish_year: 2020,
    pages: 242,
    description:
      "Tuyển tập triết lý về sự giàu có, hạnh phúc và tư duy độc lập từ nhà đầu tư - triết gia Naval Ravikant.",
    cover_image: "https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1598011736i/54898389.jpg",
    status: "borrowed",
    is_featured: false,
  },
  {
    book_id: 113,
    title: "Nghĩ Giàu Làm Giàu",
    author_id: 5,
    category_id: 4,
    publish_year: 1937,
    pages: 320,
    description:
      "Đúc kết từ hàng trăm người thành công, cuốn sách kinh doanh bán chạy nhất mọi thời đại về tư duy làm giàu.",
    cover_image: "https://cdn1.fahasa.com/media/catalog/product/n/g/nghigiaulamgiau_110k-01_bia_1.jpg",
    status: "available",
    is_featured: false,
  },
  {
    book_id: 114,
    title: "Percy Jackson: Kẻ Cắp Tia Chớp",
    author_id: 11,
    category_id: 5,
    publish_year: 2005,
    pages: 375,
    description:
      "Cậu bé Percy phát hiện mình là con trai thần Poseidon và bước vào hành trình phiêu lưu thần thoại Hy Lạp.",
    cover_image: "https://upload.wikimedia.org/wikipedia/vi/c/c1/Bia_Ke_cap_tia_chop.jpg",
    status: "available",
    is_featured: false,
  },
  {
    book_id: 115,
    title: "Percy Jackson: Biển Quái Vật",
    author_id: 11,
    category_id: 5,
    publish_year: 2006,
    pages: 279,
    description:
      "Percy và những người bạn lên đường đến Biển Quái Vật để cứu trại huấn luyện Con Lai khỏi hiểm họa.",
    cover_image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTcLUSmWdIfXhmc-gELII7Htt3noSkwLpGKOfnA0Zyh8SpyjiO7aslObKo&s=10",
    status: "borrowed",
    is_featured: false,
  },
  {
    book_id: 116,
    title: "Kafka Bên Bờ Biển",
    author_id: 6,
    category_id: 1,
    publish_year: 2002,
    pages: 505,
    description:
      "Hành trình kỳ ảo, đan xen thực và mộng của cậu bé Kafka Tamura trên con đường đi tìm chính mình.",
    cover_image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ-E8myqzQCM6xA4vFtqbxD2lkrSfVGha1zQA0Rde1DEw&s=10",
    status: "available",
    is_featured: false,
  },
  {
    book_id: 117,
    title: "21 Bài Học Cho Thế Kỷ 21",
    author_id: 2,
    category_id: 6,
    publish_year: 2018,
    pages: 448,
    description:
      "Những vấn đề cấp bách nhất của thời đại: công nghệ, chính trị, và ý nghĩa cuộc sống trong thế giới biến động.",
    cover_image: "https://upload.wikimedia.org/wikipedia/vi/5/5e/21_Lessons_for_the_21st_Century.jpg",
    status: "available",
    is_featured: false,
  },
  {
    book_id: 118,
    title: "Sống Tối Giản",
    author_id: 5,
    category_id: 3,
    publish_year: 2019,
    pages: 224,
    description:
      "Nghệ thuật buông bỏ những thứ dư thừa để sống nhẹ nhàng, tập trung vào điều thực sự quan trọng.",
    cover_image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTUgyeAulE16BY4wuHJfsARJMNqgN7ExUHlkCZ9NkS_xR2oLD-4Yke9Cfc&s=10",
    status: "available",
    is_featured: false,
  },
  {
    book_id: 119,
    title: "Harry Potter Và Hòn Đá Phù Thủy",
    author_id: 13,
    category_id: 5,
    publish_year: 1997,
    pages: 336,
    description:
      "Cậu bé Harry Potter khám phá mình là một phù thủy và bắt đầu cuộc sống tại Hogwarts.",
    cover_image: "https://images-na.ssl-images-amazon.com/images/I/81YOuOGFCJL.jpg",
    status: "available",
    is_featured: true,
  },
  {
    book_id: 120,
    title: "Harry Potter Và Phòng Chứa Bí Mật",
    author_id: 13,
    category_id: 5,
    publish_year: 1998,
    pages: 352,
    description:
      "Harry quay trở lại Hogwarts và đối mặt với bí ẩn Phòng Chứa Bí Mật.",
    cover_image: "https://images-na.ssl-images-amazon.com/images/I/91OINeHnJGL.jpg",
    status: "borrowed",
    is_featured: false,
  },
  {
    book_id: 121,
    title: "Nhà Giả Kim",
    author_id: 14,
    category_id: 1,
    publish_year: 1988,
    pages: 228,
    description:
      "Cuộc hành trình của chàng chăn cừu Santiago đi tìm kho báu và ý nghĩa cuộc sống.",
    cover_image: "https://images-na.ssl-images-amazon.com/images/I/71aFt4+OTOL.jpg",
    status: "available",
    is_featured: true,
  },
  {
    book_id: 122,
    title: "The Lean Startup",
    author_id: 15,
    category_id: 4,
    publish_year: 2011,
    pages: 336,
    description:
      "Phương pháp xây dựng startup tinh gọn giúp giảm rủi ro và tăng tốc phát triển sản phẩm.",
    cover_image: "https://images-na.ssl-images-amazon.com/images/I/81-QB7nDh4L.jpg",
    status: "available",
    is_featured: false,
  },
  {
    book_id: 123,
    title: "Rich Dad Poor Dad",
    author_id: 16,
    category_id: 4,
    publish_year: 1997,
    pages: 336,
    description:
      "Những bài học nổi tiếng về tư duy tài chính và đầu tư cá nhân.",
    cover_image: "https://images-na.ssl-images-amazon.com/images/I/81bsw6fnUiL.jpg",
    status: "borrowed",
    is_featured: false,
  },
  {
    book_id: 124,
    title: "1984",
    author_id: 17,
    category_id: 1,
    publish_year: 1949,
    pages: 328,
    description:
      "Tiểu thuyết phản địa đàng về xã hội bị kiểm soát bởi chế độ toàn trị.",
    cover_image: "https://images-na.ssl-images-amazon.com/images/I/71kxa1-0mfL.jpg",
    status: "available",
    is_featured: false,
  },
  {
    book_id: 125,
    title: "Animal Farm",
    author_id: 17,
    category_id: 1,
    publish_year: 1945,
    pages: 144,
    description:
      "Câu chuyện ngụ ngôn nổi tiếng phản ánh quyền lực và chính trị.",
    cover_image: "https://images-na.ssl-images-amazon.com/images/I/81OdwZG6UJL.jpg",
    status: "available",
    is_featured: false,
  },
  {
    book_id: 126,
    title: "Clean Code",
    author_id: 18,
    category_id: 2,
    publish_year: 2008,
    pages: 464,
    description:
      "Những nguyên tắc viết mã nguồn sạch, dễ đọc và dễ bảo trì.",
    cover_image: "https://images-na.ssl-images-amazon.com/images/I/41SH-SvWPxL.jpg",
    status: "borrowed",
    is_featured: true,
  },
  {
    book_id: 127,
    title: "Design Patterns",
    author_id: 19,
    category_id: 2,
    publish_year: 1994,
    pages: 416,
    description:
      "Cuốn sách kinh điển giới thiệu 23 mẫu thiết kế trong lập trình hướng đối tượng.",
    cover_image: "https://images-na.ssl-images-amazon.com/images/I/81gtKoapHFL.jpg",
    status: "available",
    is_featured: false,
  },
  {
    book_id: 128,
    title: "The Pragmatic Programmer",
    author_id: 20,
    category_id: 2,
    publish_year: 1999,
    pages: 352,
    description:
      "Những kinh nghiệm quý báu dành cho lập trình viên chuyên nghiệp.",
    cover_image: "https://images-na.ssl-images-amazon.com/images/I/518FqJvR9aL.jpg",
    status: "available",
    is_featured: false,
  },
  {
    book_id: 129,
    title: "Deep Work",
    author_id: 21,
    category_id: 3,
    publish_year: 2016,
    pages: 304,
    description:
      "Phương pháp tập trung cao độ để đạt hiệu suất làm việc vượt trội.",
    cover_image: "https://images-na.ssl-images-amazon.com/images/I/71QKQ9mwV7L.jpg",
    status: "available",
    is_featured: false,
  },
  {
    book_id: 130,
    title: "Can't Hurt Me",
    author_id: 22,
    category_id: 3,
    publish_year: 2018,
    pages: 364,
    description:
      "Hành trình vượt qua giới hạn bản thân của David Goggins.",
    cover_image: "https://images-na.ssl-images-amazon.com/images/I/81gTRv2HXrL.jpg",
    status: "borrowed",
    is_featured: false,
  },
  {
    book_id: 131,
    title: "The Psychology of Money",
    author_id: 5,
    category_id: 4,
    publish_year: 2020,
    pages: 256,
    description:
      "Phiên bản tiếng Anh của Tâm Lý Học Về Tiền với nhiều bài học tài chính thực tế.",
    cover_image: "https://images-na.ssl-images-amazon.com/images/I/71TRUbzcvaL.jpg",
    status: "available",
    is_featured: false,
  },
  {
    book_id: 132,
    title: "The Hobbit",
    author_id: 23,
    category_id: 5,
    publish_year: 1937,
    pages: 320,
    description:
      "Bilbo Baggins bước vào chuyến phiêu lưu cùng những người lùn để giành lại kho báu.",
    cover_image: "https://images-na.ssl-images-amazon.com/images/I/91b0C2YNSrL.jpg",
    status: "available",
    is_featured: true,
  },
  {
    book_id: 133,
    title: "The Lord of the Rings",
    author_id: 23,
    category_id: 5,
    publish_year: 1954,
    pages: 1178,
    description:
      "Bộ tiểu thuyết giả tưởng kinh điển về cuộc chiến chống Chúa tể Bóng tối Sauron.",
    cover_image: "https://images-na.ssl-images-amazon.com/images/I/91SZSW8qSsL.jpg",
    status: "borrowed",
    is_featured: false,
  },
  {
    book_id: 134,
    title: "Sherlock Holmes: A Study in Scarlet",
    author_id: 24,
    category_id: 1,
    publish_year: 1887,
    pages: 188,
    description:
      "Vụ án đầu tiên của thám tử Sherlock Holmes và bác sĩ Watson.",
    cover_image: "https://images-na.ssl-images-amazon.com/images/I/81dQwQlmAXL.jpg",
    status: "available",
    is_featured: false,
  },
  {
    book_id: 135,
    title: "To Kill a Mockingbird",
    author_id: 25,
    category_id: 1,
    publish_year: 1960,
    pages: 336,
    description:
      "Tác phẩm kinh điển về công lý, sự phân biệt chủng tộc và lòng nhân ái.",
    cover_image: "https://images-na.ssl-images-amazon.com/images/I/81gepf1eMqL.jpg",
    status: "available",
    is_featured: false,
  },
  {
    book_id: 136,
    title: "Thinking, Fast and Slow",
    author_id: 26,
    category_id: 3,
    publish_year: 2011,
    pages: 512,
    description:
      "Khám phá hai hệ thống tư duy chi phối mọi quyết định của con người.",
    cover_image: "https://images-na.ssl-images-amazon.com/images/I/71f6DceqZAL.jpg",
    status: "borrowed",
    is_featured: false,
  },
  {
    book_id: 137,
    title: "Zero to One",
    author_id: 27,
    category_id: 4,
    publish_year: 2014,
    pages: 224,
    description:
      "Peter Thiel chia sẻ cách tạo nên những công ty mang tính đột phá.",
    cover_image: "https://images-na.ssl-images-amazon.com/images/I/71m-MxdJ2WL.jpg",
    status: "available",
    is_featured: false,
  },
  {
    book_id: 138,
    title: "The 7 Habits of Highly Effective People",
    author_id: 28,
    category_id: 3,
    publish_year: 1989,
    pages: 432,
    description:
      "Bảy thói quen giúp phát triển bản thân và đạt hiệu quả cao trong cuộc sống.",
    cover_image: "https://images-na.ssl-images-amazon.com/images/I/71QKQ9mwV7L.jpg",
    status: "available",
    is_featured: true,
  },
  {
    book_id: 139,
    title: "Ikigai",
    author_id: 29,
    category_id: 3,
    publish_year: 2016,
    pages: 208,
    description:
      "Khám phá bí quyết sống lâu, hạnh phúc và có mục đích của người Nhật.",
    cover_image: "https://images-na.ssl-images-amazon.com/images/I/81l3rZK4lnL.jpg",
    status: "available",
    is_featured: false,
  },
  {
    book_id: 140,
    title: "The Art of War",
    author_id: 30,
    category_id: 6,
    publish_year: 1910,
    pages: 160,
    description:
      "Binh pháp Tôn Tử - tác phẩm quân sự nổi tiếng có ảnh hưởng sâu rộng đến chiến lược và quản trị.",
    cover_image: "https://st.perplexity.ai/estatic/0b226c450798410ac541646c86ec31afd840e5beab817a5d84fa821e7db61981ec84c3b4a3f072a7a2e1899c9fb06c6e8160361c41cdcfc9a9dea0bda03eb76635b36c57c93035b9f38b5bc646cd35761a71c608e4f13fb7b7d376dfa623c943205454a28b850fd34f5f485fa275a1df",
    status: "borrowed",
    is_featured: false,
  },

];

// Giữ export cũ để không phải sửa những chỗ đã import featuredBooks.
export const featuredBooks = books.filter((b) => b.is_featured);

// Aggregate numbers you'd normally get from COUNT() queries against
// Books / BookCopies / Users / Categories.
export const libraryStats = [
  { label: "Đầu sách", value: "12.480", icon: "book-open" },
  { label: "Thành viên", value: "3.260", icon: "users" },
  { label: "Thể loại", value: "24", icon: "layers" },
  { label: "Sách sẵn có", value: "91%", icon: "check-circle" },
];

export const news = [
  {
    id: 1,
    tag: "Sự kiện",
    tagColor: "#A63D26",
    title: "Tuần lễ đọc sách mùa hè 2026",
    excerpt: "Mượn 3 cuốn bất kỳ, được cộng thêm 7 ngày mượn miễn phí cho lượt sau.",
    date: "28 THÁNG 6, 2026",
  },
  {
    id: 2,
    tag: "Bổ sung",
    tagColor: "#3D6652",
    title: "150 đầu sách khoa học mới về kệ",
    excerpt: "Danh mục Khoa học vừa được bổ sung thêm các tựa sách phổ biến năm 2026.",
    date: "20 THÁNG 6, 2026",
  },
  {
    id: 3,
    tag: "Hướng dẫn",
    tagColor: "#C08A28",
    title: "Cách gia hạn phiếu mượn trực tuyến",
    excerpt: "Chỉ 3 bước để gia hạn ticket mượn sách ngay trên tài khoản LibHub của bạn.",
    date: "15 THÁNG 6, 2026",
  },
];

export function getAuthorName(author_id) {
  return authors.find((a) => a.author_id === author_id)?.author_name ?? "Chưa rõ tác giả";
}

export function getCategory(category_id) {
  return categories.find((c) => c.category_id === category_id);
}

export function getBookById(book_id) {
  return books.find((b) => b.book_id === Number(book_id));
}

export function getBooksByCategory(category_id) {
  return books.filter((b) => b.category_id === Number(category_id));
}

export function getBookCountByCategory(category_id) {
  return books.filter((b) => b.category_id === category_id).length;
}

export function getRelatedBooks(book_id, limit = 4) {
  const book = getBookById(book_id);
  if (!book) return [];
  return books
    .filter((b) => b.category_id === book.category_id && b.book_id !== book.book_id)
    .slice(0, limit);
}
