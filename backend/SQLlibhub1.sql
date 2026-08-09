-- ============================================
-- DROP DATABASE CŨ
-- ============================================
IF DB_ID('LibHub') IS NOT NULL
BEGIN
    ALTER DATABASE LibHub SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE LibHub;
END
GO

-- ============================================
-- CREATE DATABASE
-- ============================================
CREATE DATABASE LibHub;
GO

USE LibHub;
GO

-- ============================================
-- ROLES
-- ============================================
CREATE TABLE Roles
(
    role_id BIGINT IDENTITY(1,1) PRIMARY KEY,

    role_name NVARCHAR(50) NOT NULL UNIQUE,

    description NVARCHAR(255)
);
GO

-- ============================================
-- USERS
-- ============================================
CREATE TABLE Users
(
    user_id BIGINT IDENTITY(1,1) PRIMARY KEY,

    username VARCHAR(50) NOT NULL UNIQUE,

    password_hash VARCHAR(255) NOT NULL,

    full_name NVARCHAR(100) NOT NULL,

    email VARCHAR(100) UNIQUE,

    phone VARCHAR(20),

    address NVARCHAR(255),

    avatar NVARCHAR(255),

    status NVARCHAR(30)
        DEFAULT N'ACTIVE',

    role_id BIGINT NOT NULL,

    created_at DATETIME2
        DEFAULT GETDATE(),

    last_login DATETIME2,

    CONSTRAINT FK_Users_Roles
        FOREIGN KEY(role_id)
        REFERENCES Roles(role_id)
);
GO

-- ============================================
-- CATEGORIES
-- ============================================
CREATE TABLE Categories
(
    category_id BIGINT IDENTITY(1,1) PRIMARY KEY,

    category_name NVARCHAR(100)
        NOT NULL UNIQUE,

    description NVARCHAR(255)
);
GO

-- ============================================
-- AUTHORS
-- ============================================
CREATE TABLE Authors
(
    author_id BIGINT IDENTITY(1,1) PRIMARY KEY,

    author_name NVARCHAR(100)
        NOT NULL UNIQUE,

    biography NVARCHAR(MAX)
);
GO

-- ============================================
-- PUBLISHERS
-- ============================================
CREATE TABLE Publishers
(
    publisher_id BIGINT IDENTITY(1,1) PRIMARY KEY,

    publisher_name NVARCHAR(150)
        NOT NULL UNIQUE,

    address NVARCHAR(255),

    phone VARCHAR(20)
);
GO

-- ============================================
-- BOOKS
-- ============================================
CREATE TABLE Books
(
    book_id BIGINT IDENTITY(1,1) PRIMARY KEY,

    title NVARCHAR(255)
        NOT NULL,

    isbn VARCHAR(20)
        UNIQUE,

    publish_year INT
        CHECK
        (
            publish_year BETWEEN 1000
            AND YEAR(GETDATE())
        ),

    description NVARCHAR(MAX),

    cover_image NVARCHAR(255),

    language NVARCHAR(20),

    pages INT
        CHECK (pages > 0),

    category_id BIGINT NOT NULL,

    author_id BIGINT NOT NULL,

    publisher_id BIGINT NOT NULL,

    created_at DATETIME2
        DEFAULT GETDATE(),

	is_featured BIT NOT NULL DEFAULT 0,

	is_hidden BIT NOT NULL DEFAULT 0,

    CONSTRAINT FK_Books_Categories
        FOREIGN KEY(category_id)
        REFERENCES Categories(category_id),

    CONSTRAINT FK_Books_Authors
        FOREIGN KEY(author_id)
        REFERENCES Authors(author_id),

    CONSTRAINT FK_Books_Publishers
        FOREIGN KEY(publisher_id)
        REFERENCES Publishers(publisher_id)
);
GO-- ============================================
-- BOOK COPIES
-- ============================================
CREATE TABLE BookCopies
(
    copy_id BIGINT IDENTITY(1,1) PRIMARY KEY,

    book_id BIGINT NOT NULL,

    barcode VARCHAR(100) UNIQUE,

    shelf_location NVARCHAR(50),

    status VARCHAR(30)
        DEFAULT 'Available',

    acquired_date DATE,

    CONSTRAINT FK_BookCopies_Books
        FOREIGN KEY(book_id)
        REFERENCES Books(book_id)
);
GO

-- ============================================
-- BORROW TICKETS
-- ============================================
CREATE TABLE BorrowTickets
(
    ticket_id BIGINT IDENTITY(1,1) PRIMARY KEY,

    user_id BIGINT NOT NULL,

    borrow_date DATE
        DEFAULT GETDATE(),

    due_date DATE NOT NULL,

    status NVARCHAR(30)
        DEFAULT N'Đang mượn',

    note NVARCHAR(MAX),

    created_at DATETIME2
        DEFAULT GETDATE(),

    CONSTRAINT FK_BorrowTickets_Users
        FOREIGN KEY(user_id)
        REFERENCES Users(user_id)
);
GO

-- ============================================
-- BORROW DETAILS
-- ============================================
CREATE TABLE BorrowDetails
(
    detail_id BIGINT IDENTITY(1,1) PRIMARY KEY,

    ticket_id BIGINT NOT NULL,

    copy_id BIGINT NOT NULL,

    borrow_status NVARCHAR(30)
        DEFAULT N'Đang mượn',

    CONSTRAINT FK_BorrowDetails_Tickets
        FOREIGN KEY(ticket_id)
        REFERENCES BorrowTickets(ticket_id),

    CONSTRAINT FK_BorrowDetails_Copies
        FOREIGN KEY(copy_id)
        REFERENCES BookCopies(copy_id)
);
GO

-- ============================================
-- RETURNS
-- ============================================
CREATE TABLE Returns
(
    return_id BIGINT IDENTITY(1,1) PRIMARY KEY,

    ticket_id BIGINT NOT NULL,

    return_date DATE
        DEFAULT GETDATE(),

    received_by BIGINT NOT NULL,

    note NVARCHAR(MAX),

    CONSTRAINT FK_Returns_Tickets
        FOREIGN KEY(ticket_id)
        REFERENCES BorrowTickets(ticket_id),

    CONSTRAINT FK_Returns_Users
        FOREIGN KEY(received_by)
        REFERENCES Users(user_id)
);
GO

-- ============================================
-- RETURN DETAILS
-- ============================================
CREATE TABLE ReturnDetails
(
    return_detail_id BIGINT IDENTITY(1,1) PRIMARY KEY,

    return_id BIGINT NOT NULL,

    copy_id BIGINT NOT NULL,

    condition_book NVARCHAR(50)
        DEFAULT N'Tốt',

    CONSTRAINT FK_ReturnDetails_Returns
        FOREIGN KEY(return_id)
        REFERENCES Returns(return_id),

    CONSTRAINT FK_ReturnDetails_Copies
        FOREIGN KEY(copy_id)
        REFERENCES BookCopies(copy_id)
);
GO

-- ============================================
-- FINES
-- ============================================
CREATE TABLE Fines
(
    fine_id BIGINT IDENTITY(1,1) PRIMARY KEY,

    return_detail_id BIGINT NOT NULL,

    amount DECIMAL(18,2)
        DEFAULT 0
        CHECK (amount >= 0),

    reason NVARCHAR(255),

    paid_status NVARCHAR(30)
        DEFAULT N'Chưa thanh toán',

    created_at DATETIME2
        DEFAULT GETDATE(),

    CONSTRAINT FK_Fines_ReturnDetails
        FOREIGN KEY(return_detail_id)
        REFERENCES ReturnDetails(return_detail_id)
);

-- ============================================
-- PAYMENTTRANSACTIONS
-- ============================================

CREATE TABLE PaymentTransactions (
    payment_id BIGINT IDENTITY(1,1) PRIMARY KEY,

    fine_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,

    txn_ref NVARCHAR(100) NOT NULL,

    amount BIGINT NOT NULL,

    status NVARCHAR(30) NOT NULL,

    bank_transaction_no NVARCHAR(100) NULL,

    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),

    updated_at DATETIME2 NULL,

    CONSTRAINT uk_payment_txn_ref UNIQUE (txn_ref),

    CONSTRAINT FK_PaymentTransactions_Fines
        FOREIGN KEY (fine_id)
        REFERENCES Fines(fine_id),

    CONSTRAINT FK_PaymentTransactions_Users
        FOREIGN KEY (user_id)
        REFERENCES Users(user_id)
);

-- ============================================
-- INITIAL DATA ROLES
-- ============================================
INSERT INTO Roles
(
    role_name,
    description
)
VALUES
(
    N'Admin',
    N'Quản trị hệ thống'
),
(
    N'Staff',
    N'Nhân viên thư viện'
),
(
    N'Member',
    N'Bạn đọc'
);
GO
-- ============================================
-- INITIAL DATA USERS
--Username	Password
--admin	    123456
--staff01	123456
--staff02	123456
--member01	123456
--member02	123456
-- ============================================
INSERT INTO Users
(
    username,
    password_hash,
    full_name,
    email,
    phone,
    address,
    avatar,
    status,
    role_id
)
VALUES

(
'admin',
'$2a$10$lj3NoLAdr7Ay/ZocmfxLOONR3kD/.xqqCTPduBaUTXHWA9y47laQS',
N'Quản trị viên',
'admin@libhub.com',
'0900000001',
N'TP. Hồ Chí Minh',
NULL,
N'ACTIVE',
1
),

(
'staff01',
'$2a$10$lj3NoLAdr7Ay/ZocmfxLOONR3kD/.xqqCTPduBaUTXHWA9y47laQS',
N'Nguyễn Văn An',
'staff01@libhub.com',
'0900000002',
N'TP. Hồ Chí Minh',
NULL,
N'ACTIVE',
2
),

(
'staff02',
'$2a$10$lj3NoLAdr7Ay/ZocmfxLOONR3kD/.xqqCTPduBaUTXHWA9y47laQS',
N'Trần Minh Khôi',
'staff02@libhub.com',
'0900000003',
N'Hà Nội',
NULL,
N'ACTIVE',
2
),

(
'member01',
'$2a$10$lj3NoLAdr7Ay/ZocmfxLOONR3kD/.xqqCTPduBaUTXHWA9y47laQS',
N'Lê Thị Mai',
'member01@gmail.com',
'0900000004',
N'Đà Nẵng',
NULL,
N'ACTIVE',
3
),

(
'member02',
'$2a$10$lj3NoLAdr7Ay/ZocmfxLOONR3kD/.xqqCTPduBaUTXHWA9y47laQS',
N'Phạm Quốc Bảo',
'member02@gmail.com',
'0900000005',
N'Cần Thơ',
NULL,
N'ACTIVE',
3
);

GO

-- ============================================
-- CATEGORIES
-- ============================================
INSERT INTO Categories(category_name, description)
VALUES
(N'Kỹ năng sống',N'Phát triển bản thân'),
(N'Tiểu thuyết',N'Văn học'),
(N'Hồi ký',N'Tự truyện'),
(N'Phật giáo',N'Thiền và chánh niệm'),
(N'Fantasy',N'Giả tưởng'),
(N'Công nghệ',N'Công nghệ thông tin'),
(N'Kinh doanh',N'Quản trị doanh nghiệp');
GO

-- ============================================
-- AUTHORS
-- ============================================
INSERT INTO Authors(author_name, biography)
VALUES
(N'Napoleon Hill',N'Tác giả Think and Grow Rich'),
(N'Dale Carnegie',N'Tác giả Đắc Nhân Tâm'),
(N'James Clear',N'Tác giả Atomic Habits'),
(N'Thích Nhất Hạnh',N'Thiền sư Việt Nam'),
(N'Chu Lai',N'Nhà văn Việt Nam'),
(N'Paul Kalanithi',N'Bác sĩ và nhà văn'),
(N'Shinkai Makoto',N'Tác giả Nhật Bản'),
(N'J.R.R. Tolkien',N'Tác giả Lord of the Rings'),
(N'Robert C. Martin',N'Uncle Bob');
GO

-- ============================================
-- PUBLISHERS
-- ============================================
INSERT INTO Publishers(publisher_name,address,phone)
VALUES
(N'First News',N'Việt Nam','0281111111'),
(N'NXB Trẻ',N'TP. Hồ Chí Minh','0282222222'),
(N'NXB Lao Động',N'Hà Nội','0243333333'),
(N'NXB Văn Học',N'Hà Nội','0244444444'),
(N'Pearson',N'USA','111111111'),
(N'Addison Wesley',N'USA','222222222');
GO

-- ============================================
-- BOOKS
-- ============================================
INSERT INTO Books
(title,isbn,publish_year,description,cover_image,language,pages,category_id,author_id,publisher_id)
VALUES

(N'Nghĩ giàu làm giàu',
'9786049221234',
2018,
N'Sách tư duy thành công',
'nghigiaulamgiau.jpg',
'vi',
320,
7,
1,
1),

(N'Đắc nhân tâm',
'9786041112233',
2019,
N'Kỹ năng giao tiếp',
'dacnhantam.jpg',
'vi',
320,
1,
2,
1),

(N'Atomic Habits',
'9781524763138',
2018,
N'Thói quen nguyên tử',
'atomichabits.jpg',
'en',
320,
1,
3,
5),

(N'Không diệt không sinh đừng sợ hãi',
'9786043398765',
2021,
N'Triết lý Phật giáo',
'khongdiet.jpg',
'vi',
180,
4,
4,
2),

(N'Mưa đỏ',
'9786041237890',
2024,
N'Tiểu thuyết chiến tranh',
'muado.jpg',
'vi',
300,
2,
5,
4),

(N'Khi hơi thở hóa thinh không',
'9786045678901',
2020,
N'Hồi ký nổi tiếng',
'breath.jpg',
'vi',
240,
3,
6,
3),

(N'Đứa con của thời tiết',
'9786044567890',
2020,
N'Tiểu thuyết chuyển thể anime',
'weathering.jpg',
'vi',
250,
2,
7,
2),

(N'The Fellowship of the Ring',
'9780261103573',
2022,
N'Lord of the Rings',
'lotr1.jpg',
'en',
480,
5,
8,
5),

(N'Clean Code',
'9780132350884',
2008,
N'Best practices lập trình',
'cleancode.jpg',
'en',
464,
6,
9,
6);
GO

-- ============================================
-- BOOK COPIES
-- ============================================
INSERT INTO BookCopies
(book_id,barcode,shelf_location,status,acquired_date)
VALUES
(1,'BC000001',N'A1','Available','2025-01-01'),
(1,'BC000002',N'A1','Borrowed','2025-01-01'),
(2,'BC000003',N'A2','Available','2025-01-05'),
(2,'BC000004',N'A2','Available','2025-01-05'),
(3,'BC000005',N'B1','Available','2025-02-01'),
(4,'BC000006',N'B2','Available','2025-02-05'),
(5,'BC000007',N'C1','Available','2025-03-01'),
(6,'BC000008',N'C2','Available','2025-03-01'),
(7,'BC000009',N'D1','Available','2025-03-10'),
(8,'BC000010',N'D2','Available','2025-04-01'),
(9,'BC000011',N'E1','Available','2025-04-05');
GO

-- ============================================
-- BORROW TICKETS
-- ============================================
INSERT INTO BorrowTickets
(user_id,borrow_date,due_date,status,note)
VALUES
(4,'2026-07-20','2026-08-03',N'Đang mượn',NULL),
(5,'2026-07-10','2026-07-24',N'Đã trả',NULL);
GO

-- ============================================
-- BORROW DETAILS
-- ============================================
INSERT INTO BorrowDetails
(ticket_id,copy_id,borrow_status)
VALUES
(1,2,N'Đang mượn'),
(2,3,N'Đã trả');
GO

-- ============================================
-- RETURNS
-- ============================================
INSERT INTO Returns
(ticket_id,return_date,received_by,note)
VALUES
(2,'2026-07-23',2,N'Trả đúng hạn');
GO

-- ============================================
-- RETURN DETAILS
-- ============================================
INSERT INTO ReturnDetails
(return_id,copy_id,condition_book)
VALUES
(1,3,N'Tốt');
GO

-- ============================================
-- FINES
-- ============================================
INSERT INTO Fines
(return_detail_id,amount,reason,paid_status)
VALUES
(1,0,N'Không có',N'Đã thanh toán');
GO
