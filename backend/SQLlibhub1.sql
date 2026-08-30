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

        two_factor_enabled BIT NOT NULL
            CONSTRAINT DF_Users_TwoFactorEnabled DEFAULT 0,

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

        edition_name NVARCHAR(500),

        legal_publisher NVARCHAR(255),

        publishing_partner NVARCHAR(500),

        catalog_source_url NVARCHAR(1000),

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
    /* Deferred until all seed Books and BookCopies have been inserted.
    -- VERIFIED VIETNAMESE EDITION SAMPLE DATA
    -- ISBN is stored without hyphens for consistent searching.
    -- edition_name preserves the title in the legal-deposit record.
    -- ============================================
    UPDATE Books
    SET title = N'Nhà giả kim', isbn = '9786045396391',
        edition_name = N'Nhà giả Kim',
        legal_publisher = N'Nhà xuất bản Hội Nhà văn',
        publishing_partner = N'Công ty Cổ phần Văn hóa và Truyền thông Nhã Nam',
        publish_year = 2026, pages = 225, language = N'Tiếng Việt',
        description = N'Qua hành trình rời quê nhà của chàng chăn cừu Santiago để đi tìm kho báu bên Kim Tự Tháp, tiểu thuyết kể về lòng can đảm theo đuổi ước mơ, khả năng lắng nghe trực giác và cách mỗi trải nghiệm trên đường đời góp phần tạo nên ý nghĩa của đích đến. Lối kể cô đọng, giàu tính ngụ ngôn khiến tác phẩm phù hợp với độc giả trẻ lẫn người trưởng thành đang đứng trước một lựa chọn lớn.',
        cover_image = N'https://covers.openlibrary.org/b/id/12634885-L.jpg',
        catalog_source_url = N'https://ppdvn.gov.vn/web/guest/tra-cuu-luu-chieu?query=978-604-53-9639-1'
    WHERE isbn = '9786040000019';

    UPDATE Books
    SET title = N'Đắc nhân tâm', isbn = '9786326176681',
        edition_name = N'How to Win Friends and Influence People - Đắc nhân tâm',
        legal_publisher = N'Nhà xuất bản Văn học',
        publishing_partner = N'Công ty TNHH Văn hóa và Truyền thông Trí Việt (First News)',
        publish_year = 2025, language = N'Tiếng Việt',
        description = N'Tác phẩm hệ thống hóa những nguyên tắc giao tiếp bền vững: tôn trọng người đối diện, ghi nhận chân thành, nhìn vấn đề từ góc độ của họ và góp ý mà không làm tổn thương lòng tự trọng. Thay vì đưa ra mẹo ứng xử ngắn hạn, sách dùng nhiều tình huống thực tế để chỉ ra cách xây dựng thiện cảm, giải quyết bất đồng và tạo ảnh hưởng tích cực trong công việc cũng như đời sống.',
        cover_image = N'https://upload.wikimedia.org/wikipedia/vi/0/0a/%C4%90%E1%BA%AFc_nh%C3%A2n_t%C3%A2m.jpg',
        catalog_source_url = N'https://ppdvn.gov.vn/web/guest/tra-cuu-luu-chieu?query=978-632-617-668-1'
    WHERE isbn = '9786040000026';

    UPDATE Books
    SET title = N'Tuổi trẻ đáng giá bao nhiêu', isbn = '9786045370193',
        edition_name = N'Tuổi trẻ đáng giá bao nhiêu',
        legal_publisher = N'Nhà xuất bản Hội Nhà văn',
        publishing_partner = N'Công ty Cổ phần Văn hóa và Truyền thông Nhã Nam',
        publish_year = 2026, pages = 285, language = N'Tiếng Việt',
        description = N'Rosie Nguyễn viết từ trải nghiệm học tập, làm việc và đi nhiều nơi để trò chuyện thẳng thắn với người trẻ về ba nền tảng: học chủ động, làm việc có kỷ luật và dấn thân để hiểu chính mình. Những chương ngắn về đọc sách, rèn kỹ năng, đi để trưởng thành và lựa chọn con đường riêng tạo nên một cuốn cẩm nang gần gũi, khuyến khích độc giả biến quãng tuổi trẻ thành quá trình tích lũy có mục tiêu.',
        cover_image = N'https://books.google.com/books/content?id=iCQytAEACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api',
        catalog_source_url = N'https://ppdvn.gov.vn/web/guest/tra-cuu-luu-chieu?query=978-604-53-7019-3'
    WHERE isbn = '9786040000033';

    UPDATE Books
    SET title = N'Cà phê cùng Tony', isbn = '9786041243781',
        edition_name = N'Cà phê cùng Tony - tập bài viết (TB)',
        legal_publisher = N'Nhà xuất bản Trẻ', publishing_partner = NULL,
        publish_year = 2024, pages = 268, language = N'Tiếng Việt',
        description = N'Tập sách tuyển chọn những bài viết dí dỏm của Tony Buổi Sáng về học tập, nghề nghiệp, văn hóa ứng xử và tinh thần tự lập. Giọng kể hài hước nhưng thực tế dẫn người đọc từ các thói quen nhỏ như đọc, học ngoại ngữ và quản lý thời gian đến thái độ dám đi, dám làm và chịu trách nhiệm với lựa chọn của mình; đặc biệt phù hợp với sinh viên và người mới bước vào môi trường làm việc.',
        cover_image = N'https://covers.openlibrary.org/b/id/9175811-L.jpg',
        catalog_source_url = N'https://ppdvn.gov.vn/web/guest/tra-cuu-luu-chieu?query=978-604-1-24378-1'
    WHERE isbn = '9786040000040';
    GO
    */

    -- ============================================
    -- BORROW TICKETS
    -- ============================================
    CREATE TABLE BorrowTickets
    (
        ticket_id BIGINT IDENTITY(1,1) PRIMARY KEY,

        -- Nullable để hỗ trợ khách vãng lai; thành viên vẫn được ràng buộc FK.
        user_id BIGINT NULL,

        guest_name NVARCHAR(100) NULL,

        guest_phone VARCHAR(20) NULL,

        borrow_date DATE
                                                 DEFAULT GETDATE(),

        due_date DATE NOT NULL,

        status VARCHAR(30)
                                                 DEFAULT 'Borrowed',

        note NVARCHAR(MAX),

        created_at DATETIME2
                                                 DEFAULT GETDATE(),

        -- Online: PendingPayment/Unpaid cho tới khi VNPay callback thành công.
        -- Tại quầy: chỉ thủ thư xác nhận tiền mặt và tạo phiếu Paid.
        -- Phí mượn: 5.000đ × số ngày mượn.
        deposit_amount DECIMAL(18,2) NOT NULL DEFAULT 0,

        deposit_paid_status VARCHAR(30) NOT NULL DEFAULT 'Unpaid',

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

        borrow_status VARCHAR(30)
            DEFAULT 'Borrowed',

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

        condition_book VARCHAR(50)
            DEFAULT 'Good',

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

        paid_status VARCHAR(30)
            DEFAULT 'Unpaid',

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
            N'Librarian',
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
        two_factor_enabled,
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
            0,
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
            0,
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
            0,
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
            0,
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
            0,
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
        (9,'BC000011',N'E1','Available','2025-04-05'),
        (1,'BC000012',N'A1','Available','2026-08-01'),
        (1,'BC000013',N'A1','Available','2026-08-01'),
        (2,'BC000014',N'A2','Available','2026-08-01'),
        (2,'BC000015',N'A2','Available','2026-08-01'),
        (3,'BC000016',N'B1','Available','2026-08-02'),
        (3,'BC000017',N'B1','Available','2026-08-02'),
        (4,'BC000018',N'B2','Available','2026-08-02'),
        (4,'BC000019',N'B2','Available','2026-08-02'),
        (5,'BC000020',N'C1','Available','2026-08-03'),
        (5,'BC000021',N'C1','Available','2026-08-03'),
        (6,'BC000022',N'C2','Available','2026-08-03'),
        (6,'BC000023',N'C2','Available','2026-08-03'),
        (7,'BC000024',N'D1','Available','2026-08-04'),
        (7,'BC000025',N'D1','Available','2026-08-04'),
        (8,'BC000026',N'D2','Available','2026-08-04'),
        (8,'BC000027',N'D2','Available','2026-08-04'),
        (9,'BC000028',N'E1','Available','2026-08-05'),
        (9,'BC000029',N'E1','Available','2026-08-05');
    GO

    -- ============================================
    -- BORROW TICKETS
    -- ============================================
    INSERT INTO BorrowTickets
    (user_id,borrow_date,due_date,status,note,deposit_amount,deposit_paid_status)
    VALUES
        (4,'2026-07-20','2026-08-03','Borrowed',NULL,70000,'Paid'),
        (5,'2026-07-10','2026-07-24','Returned',NULL,70000,'Paid');
    GO

    -- ============================================
    -- BORROW DETAILS
    -- ============================================
    INSERT INTO BorrowDetails
    (ticket_id,copy_id,borrow_status)
    VALUES
        (1,2,'Borrowed'),
        (2,3,'Returned');
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
    (1,3,'Good');
    GO

    -- ============================================
    -- FINES
    -- ============================================
    INSERT INTO Fines
    (return_detail_id,amount,reason,paid_status)
    VALUES
    (1,0,N'Không có','Paid');
    GO

    -- ================================================================
    -- BO SUNG DU LIEU: 201 SACH TU EXCEL + BAN SAO SACH
    -- Cac buoc tiep theo:
    --   7) Categories moi
    --   8) Publishers moi
    --   9) Authors moi
    --   10) INSERT 201 sach (Books)
    --   11) UPDATE shelf_location cho 29 ban sao GOC (dong bo quy uoc ke)
    --   12) INSERT 402 ban sao (BookCopies) cho 201 sach moi
    -- ================================================================

    USE LibHub;
    GO


    -- ============================================
    -- 7) THEM CATEGORIES MOI (bo sung the loai con thieu)
    -- ============================================
    INSERT INTO Categories(category_name, description) VALUES
                                                           (N'Khoa học', N'Khoa học phổ thông'),
                                                           (N'Khoa học viễn tưởng', N'Sci-fi'),
                                                           (N'Trinh thám - Kinh dị', N'Mystery, Thriller, Horror'),
                                                           (N'Triết học', N'Triết học - Tư tưởng'),
                                                           (N'Tâm lý học', N'Tâm lý học ứng dụng'),
                                                           (N'Văn học Việt Nam', N'Văn học trong nước'),
                                                           (N'Văn học kinh điển', N'Classic literature');
    GO

    -- ============================================
    -- 8) THEM PUBLISHERS MOI
    -- ============================================
    INSERT INTO Publishers(publisher_name, address, phone) VALUES
                                                               (N'Alphabooks', N'Hà Nội', '0246666666'),
                                                               (N'MIT Press', N'USA', '666666666'),
                                                               (N'Manning Publications', N'USA', '444444444'),
                                                               (N'NXB Hội Nhà Văn', N'Hà Nội', '0249999999'),
                                                               (N'NXB Kim Đồng', N'Hà Nội', '0248888888'),
                                                               (N'Nhã Nam', N'Hà Nội', '0245555555'),
                                                               (N'No Starch Press', N'USA', '555555555'),
                                                               (N'O''Reilly Media', N'USA', '333333333'),
                                                               (N'Thái Hà Books', N'Hà Nội', '0247777777');
    GO

    -- ============================================
    -- 9) THEM AUTHORS MOI
    -- ============================================
    INSERT INTO Authors(author_name, biography) VALUES
                                                    (N'Abraham Silberschatz', NULL),
                                                    (N'Agatha Christie', NULL),
                                                    (N'Al Sweigart', NULL),
                                                    (N'Aldous Huxley', NULL),
                                                    (N'Alex Banks', NULL),
                                                    (N'Alex Michaelides', NULL),
                                                    (N'Alexandre Dumas', NULL),
                                                    (N'Amir Levine', NULL),
                                                    (N'Andrew Hunt', NULL),
                                                    (N'Andy Weir', NULL),
                                                    (N'Angela Duckworth', NULL),
                                                    (N'Anthony Accomazzo', NULL),
                                                    (N'Antoine de Saint-Exupéry', NULL),
                                                    (N'Arthur Conan Doyle', NULL),
                                                    (N'Aurélien Géron', NULL),
                                                    (N'Azat Mardan', NULL),
                                                    (N'Banana Yoshimoto', NULL),
                                                    (N'Ben Horowitz', NULL),
                                                    (N'Bram Stoker', NULL),
                                                    (N'Brené Brown', NULL),
                                                    (N'Brett Slatkin', NULL),
                                                    (N'Brianna Wiest', NULL),
                                                    (N'Bảo Ninh', NULL),
                                                    (N'Cal Newport', NULL),
                                                    (N'Carl Sagan', NULL),
                                                    (N'Carol S. Dweck', NULL),
                                                    (N'Charles Duhigg', NULL),
                                                    (N'Cormac McCarthy', NULL),
                                                    (N'Craig Walls', NULL),
                                                    (N'Dan Brown', NULL),
                                                    (N'Daniel H. Pink', NULL),
                                                    (N'Daniel Kahneman', NULL),
                                                    (N'David Flanagan', NULL),
                                                    (N'Donella H. Meadows', NULL),
                                                    (N'Eckhart Tolle', NULL),
                                                    (N'Eric Matthes', NULL),
                                                    (N'Eric Ries', NULL),
                                                    (N'Erich Gamma', NULL),
                                                    (N'Ernest Hemingway', NULL),
                                                    (N'F. Scott Fitzgerald', NULL),
                                                    (N'Frank Herbert', NULL),
                                                    (N'Fredrik Backman', NULL),
                                                    (N'Friedrich Nietzsche', NULL),
                                                    (N'Fyodor Dostoevsky', NULL),
                                                    (N'Gabriel García Márquez', NULL),
                                                    (N'George Orwell', NULL),
                                                    (N'Gillian Flynn', NULL),
                                                    (N'Greg McKeown', NULL),
                                                    (N'Hans Rosling', NULL),
                                                    (N'Harper Lee', NULL),
                                                    (N'Haruki Murakami', NULL),
                                                    (N'Herbert Schildt', NULL),
                                                    (N'Héctor García', NULL),
                                                    (N'Ian Goodfellow', NULL),
                                                    (N'Ichiro Kishimi', NULL),
                                                    (N'J.D. Salinger', NULL),
                                                    (N'J.K. Rowling', NULL),
                                                    (N'Jake Knapp', NULL),
                                                    (N'James F. Kurose', NULL),
                                                    (N'Jane Austen', NULL),
                                                    (N'Jared Diamond', NULL),
                                                    (N'Jason Fried', NULL),
                                                    (N'Jim Collins', NULL),
                                                    (N'John Green', NULL),
                                                    (N'Jojo Moyes', NULL),
                                                    (N'Jon Duckett', NULL),
                                                    (N'Joshua Bloch', NULL),
                                                    (N'Jules Verne', NULL),
                                                    (N'Kathy Sierra', NULL),
                                                    (N'Khaled Hosseini', NULL),
                                                    (N'Kim Lân', NULL),
                                                    (N'Kyle Simpson', NULL),
                                                    (N'Lea Verou', NULL),
                                                    (N'Leo Tolstoy', NULL),
                                                    (N'Luciano Ramalho', NULL),
                                                    (N'Malcolm Gladwell', NULL),
                                                    (N'Marcus Aurelius', NULL),
                                                    (N'Margaret Atwood', NULL),
                                                    (N'Marie Forleo', NULL),
                                                    (N'Marijn Haverbeke', NULL),
                                                    (N'Mark Lutz', NULL),
                                                    (N'Mark Manson', NULL),
                                                    (N'Markus Zusak', NULL),
                                                    (N'Martin Fowler', NULL),
                                                    (N'Martin Kleppmann', NULL),
                                                    (N'Mary Shelley', NULL),
                                                    (N'Matthew Walker', NULL),
                                                    (N'Michelle Obama', NULL),
                                                    (N'Morgan Housel', NULL),
                                                    (N'Nam Cao', NULL),
                                                    (N'Neil deGrasse Tyson', NULL),
                                                    (N'Nguyên Hồng', NULL),
                                                    (N'Nguyên Phong', NULL),
                                                    (N'Nguyễn Ngọc Thuần', NULL),
                                                    (N'Nguyễn Nhật Ánh', NULL),
                                                    (N'Nguyễn Trung Thành', NULL),
                                                    (N'Nguyễn Tuân', NULL),
                                                    (N'Ngô Tất Tố', NULL),
                                                    (N'Nicholas Sparks', NULL),
                                                    (N'Oscar Wilde', NULL),
                                                    (N'Paulo Coelho', NULL),
                                                    (N'Peter Thiel', NULL),
                                                    (N'Plato', NULL),
                                                    (N'Rachel Carson', NULL),
                                                    (N'Randal E. Bryant', NULL),
                                                    (N'Ray Bradbury', NULL),
                                                    (N'Rebecca Skloot', NULL),
                                                    (N'Rex Hartson', NULL),
                                                    (N'Richard Dawkins', NULL),
                                                    (N'Robert Louis Stevenson', NULL),
                                                    (N'Robert Sedgewick', NULL),
                                                    (N'Robert T. Kiyosaki', NULL),
                                                    (N'Robin Sharma', NULL),
                                                    (N'Rosie Nguyễn', NULL),
                                                    (N'Seneca', NULL),
                                                    (N'Siddhartha Mukherjee', NULL),
                                                    (N'Simon Sinek', NULL),
                                                    (N'Stephen Hawking', NULL),
                                                    (N'Stephen King', NULL),
                                                    (N'Stephen R. Covey', NULL),
                                                    (N'Steve Krug', NULL),
                                                    (N'Stieg Larsson', NULL),
                                                    (N'Stuart Russell', NULL),
                                                    (N'Sun Tzu', NULL),
                                                    (N'Suzanne Collins', NULL),
                                                    (N'Tara Westover', NULL),
                                                    (N'Thomas H. Cormen', NULL),
                                                    (N'Thạch Lam', NULL),
                                                    (N'Tony Buổi Sáng', NULL),
                                                    (N'Tác giả mẫu', NULL),
                                                    (N'Tô Hoài', NULL),
                                                    (N'Vex King', NULL),
                                                    (N'Victor Hugo', NULL),
                                                    (N'Viktor E. Frankl', NULL),
                                                    (N'Vũ Bằng', NULL),
                                                    (N'Vũ Trọng Phụng', NULL),
                                                    (N'Walter Isaacson', NULL),
                                                    (N'Yann Martel', NULL),
                                                    (N'Yuval Noah Harari', NULL),
                                                    (N'Đoàn Giỏi', NULL);
    GO

    -- ============================================
    -- 10) INSERT 201 SACH TU FILE EXCEL, category_id/author_id/publisher_id
    --    duoc tra dung qua subquery theo ten (khong phu thuoc thu tu ID)
    -- ============================================
        INSERT INTO Books
    (title,isbn,publish_year,description,cover_image,language,pages,category_id,author_id,publisher_id,is_featured,is_hidden)
    VALUES
        (N'Muôn kiếp nhân sinh', '9786040000001', 2020, N'Tác phẩm của Nguyên Phong về nhân quả, lựa chọn và trách nhiệm của con người trong đời sống.', 'Muon_kiep_nhan_sinh.jpg', N'Tiếng Việt', 408, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyên Phong'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0),
        (N'Nhà giả kim', '9786040000019', 2001, N'Nhà giả kim là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 217 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'nha-gia-kim.jpg', N'Tiếng Việt', 217, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Paulo Coelho'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Đắc nhân tâm', '9786040000026', 2002, N'Đắc nhân tâm là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 254 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'dac-nhan-tam.jpg', N'Tiếng Việt', 254, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Dale Carnegie'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0),
        (N'Tuổi trẻ đáng giá bao nhiêu?', '9786040000033', 2003, N'Tuổi trẻ đáng giá bao nhiêu? là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 291 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'tuoi-tre-dang-gia-bao-nhieu.jbg', N'Tiếng Việt', 291, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Rosie Nguyễn'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0),
        (N'Cà phê cùng Tony', '9786040000040', 2004, N'Cà phê cùng Tony là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 328 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'ca-phe-cung-tony.jpg', N'Tiếng Việt', 328, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Tony Buổi Sáng'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0),
        (N'Đi tìm lẽ sống', '9786040000057', 2005, N'Đi tìm lẽ sống là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 365 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'di-tim-le-song.jpg', N'Tiếng Việt', 365, (SELECT category_id FROM Categories WHERE category_name = N'Hồi ký'), (SELECT author_id FROM Authors WHERE author_name = N'Viktor E. Frankl'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Trẻ'), 0, 0),
        (N'7 thói quen của người thành đạt', '9786040000064', 2006, N'7 thói quen của người thành đạt là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 402 trang và được bổ sung vào dữ liệu mẫu của LibHub.', '7-thoi-quen-cua-nguoi-thanh-dat.jpg', N'Tiếng Việt', 402, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Stephen R. Covey'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0),
        (N'Tư duy nhanh và chậm', '9786040000071', 2007, N'Tư duy nhanh và chậm là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 439 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'tu-duy-nhanh-va-cham.jpg', N'Tiếng Anh', 439, (SELECT category_id FROM Categories WHERE category_name = N'Tâm lý học'), (SELECT author_id FROM Authors WHERE author_name = N'Daniel Kahneman'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thái Hà Books'), 0, 0),
        (N'Cha giàu cha nghèo', '9786040000088', 2008, N'Cha giàu cha nghèo là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 476 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'cha-giau-cha-ngheo.jpg', N'Tiếng Việt', 476, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Robert T. Kiyosaki'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Alphabooks'), 0, 0),
        (N'Atomic Habits', '9786040000095', 2009, N'Atomic Habits là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 513 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'atomic-habits.jpg', N'Tiếng Anh', 513, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'James Clear'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0),
        (N'Deep Work', '9786040000101', 2010, N'Deep Work là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 550 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'deep-work.jpg', N'Tiếng Anh', 550, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Cal Newport'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0),
        (N'Mindset', '9786040000118', 2011, N'Mindset là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 587 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'mindset.jpg', N'Tiếng Anh', 587, (SELECT category_id FROM Categories WHERE category_name = N'Tâm lý học'), (SELECT author_id FROM Authors WHERE author_name = N'Carol S. Dweck'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thái Hà Books'), 0, 0),
        (N'The Psychology of Money', '9786040000125', 2012, N'The Psychology of Money là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 204 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-psychology-of-money.jpg', N'Tiếng Anh', 204, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Morgan Housel'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Alphabooks'), 0, 0),
        (N'Ikigai', '9786040000132', 2013, N'Ikigai là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 241 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'ikigai.jpg', N'Tiếng Anh', 241, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Héctor García'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0),
        (N'Essentialism', '9786040000149', 2014, N'Essentialism là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 278 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'essentialism.jpg', N'Tiếng Anh', 278, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Greg McKeown'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0),
        (N'The Power of Now', '9786040000156', 2015, N'The Power of Now là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 315 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-power-of-now.jpg', N'Tiếng Anh', 315, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Eckhart Tolle'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0),
        (N'Think and Grow Rich', '9786040000163', 2016, N'Think and Grow Rich là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 352 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'think-and-grow-rich.jpg', N'Tiếng Anh', 352, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Napoleon Hill'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Alphabooks'), 0, 0),
        (N'How to Win Friends and Influence People', '9786040000170', 2017, N'How to Win Friends and Influence People là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 389 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'how-to-win-friends-and-influence-people.jpg', N'Tiếng Anh', 389, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Dale Carnegie'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0),
        (N'The 5 AM Club', '9786040000187', 2018, N'The 5 AM Club là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 426 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-5-am-club.jpg', N'Tiếng Anh', 426, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Robin Sharma'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0),
        (N'Make Time', '9786040000194', 2019, N'Make Time là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 463 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'make-time.jpg', N'Tiếng Anh', 463, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Jake Knapp'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0),
        (N'Start With Why', '9786040000200', 2020, N'Start With Why là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 500 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'start-with-why.jpg', N'Tiếng Anh', 500, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Simon Sinek'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Alphabooks'), 0, 0),
        (N'Zero to One', '9786040000217', 2021, N'Zero to One là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 537 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'zero-to-one.jpg', N'Tiếng Anh', 537, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Peter Thiel'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Alphabooks'), 0, 0),
        (N'Good to Great', '9786040000224', 2022, N'Good to Great là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 574 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'good-to-great.jpg', N'Tiếng Anh', 574, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Jim Collins'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Alphabooks'), 0, 0),
        (N'The Lean Startup', '9786040000231', 2023, N'The Lean Startup là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 191 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-lean-startup.jpg', N'Tiếng Anh', 191, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Eric Ries'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Alphabooks'), 0, 0),
        (N'Rework', '9786040000248', 2024, N'Rework là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 228 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'rework.jpg', N'Tiếng Anh', 228, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Jason Fried'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Alphabooks'), 0, 0),
        (N'The Hard Thing About Hard Things', '9786040000255', 2000, N'The Hard Thing About Hard Things là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 265 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-hard-thing-about-hard-things.jpg', N'Tiếng Anh', 265, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Ben Horowitz'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Alphabooks'), 0, 0),
        (N'Clean Code', '9786040000262', 2001, N'Clean Code là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 302 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'clean-code.jpg', N'Tiếng Anh', 302, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Robert C. Martin'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Addison Wesley'), 0, 0),
        (N'Clean Architecture', '9786040000279', 2002, N'Clean Architecture là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 339 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'clean-architecture.jpg', N'Tiếng Anh', 339, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Robert C. Martin'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Pearson'), 0, 0),
        (N'The Pragmatic Programmer', '9786040000286', 2003, N'The Pragmatic Programmer là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 376 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-pragmatic-programmer.jpg', N'Tiếng Anh', 376, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Andrew Hunt'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Addison Wesley'), 0, 0),
        (N'Design Patterns', '9786040000293', 2004, N'Design Patterns là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 413 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'design-patterns.jpg', N'Tiếng Anh', 413, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Erich Gamma'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Addison Wesley'), 0, 0),
        (N'Refactoring', '9786040000309', 2005, N'Refactoring là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 450 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'refactoring.jpg', N'Tiếng Anh', 450, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Martin Fowler'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Addison Wesley'), 0, 0),
        (N'Effective Java', '9786040000316', 2006, N'Effective Java là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 487 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'effective-java.jpg', N'Tiếng Anh', 487, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Joshua Bloch'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Addison Wesley'), 0, 0),
        (N'Head First Java', '9786040000323', 2007, N'Head First Java là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 524 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'head-first-java.jpg', N'Tiếng Anh', 524, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Kathy Sierra'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'O''Reilly Media'), 0, 0),
        (N'Java: The Complete Reference', '9786040000330', 2008, N'Java: The Complete Reference là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 561 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'java-The-complete-reference', N'Tiếng Anh', 561, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Herbert Schildt'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Pearson'), 0, 0),
        (N'Spring in Action', '9786040000347', 2009, N'Spring in Action là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 598 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'spring-in-action.jpg', N'Tiếng Anh', 598, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Craig Walls'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Manning Publications'), 0, 0),
        (N'Spring Boot in Action', '9786040000354', 2010, N'Spring Boot in Action là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 215 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'spring-boot-in-action.jpg', N'Tiếng Anh', 215, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Craig Walls'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Manning Publications'), 0, 0),
        (N'Learning React', '9786040000361', 2011, N'Learning React là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 252 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'learning-react.jpg', N'Tiếng Anh', 252, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Alex Banks'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'O''Reilly Media'), 0, 0),
        (N'React Quickly', '9786040000378', 2012, N'React Quickly là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 289 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'react-quickly.jpg', N'Tiếng Anh', 289, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Azat Mardan'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Manning Publications'), 0, 0),
        (N'Fullstack React', '9786040000385', 2013, N'Fullstack React là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 326 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'fullstack-react.jpg', N'Tiếng Anh', 326, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Anthony Accomazzo'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'O''Reilly Media'), 0, 0),
        (N'You Don''t Know JS', '9786040000392', 2014, N'You Don''t Know JS là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 363 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'you-dont-know-js.jpg', N'Tiếng Anh', 363, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Kyle Simpson'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'O''Reilly Media'), 0, 0),
        (N'Eloquent JavaScript', '9786040000408', 2015, N'Eloquent JavaScript là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 400 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'Eloquent-javascript.jpg', N'Tiếng Anh', 400, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Marijn Haverbeke'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'No Starch Press'), 0, 0),
        (N'JavaScript: The Definitive Guide', '9786040000415', 2016, N'JavaScript: The Definitive Guide là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 437 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'javascript-the-definitive-guide.jpg', N'Tiếng Anh', 437, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'David Flanagan'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'O''Reilly Media'), 0, 0),
        (N'HTML and CSS', '9786040000422', 2017, N'HTML and CSS là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 474 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'html-and-css.jpg', N'Tiếng Anh', 474, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Jon Duckett'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Pearson'), 0, 0),
        (N'CSS Secrets', '9786040000439', 2018, N'CSS Secrets là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 511 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'css-secrets.jpg', N'Tiếng Anh', 511, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Lea Verou'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'O''Reilly Media'), 0, 0),
        (N'Don''t Make Me Think', '9786040000446', 2019, N'Don''t Make Me Think là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 548 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'dont-make-me-think.jpg', N'Tiếng Anh', 548, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Steve Krug'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Pearson'), 0, 0),
        (N'The UX Book', '9786040000453', 2020, N'The UX Book là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 585 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-ux-book.jpg', N'Tiếng Anh', 585, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Rex Hartson'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Pearson'), 0, 0),
        (N'Introduction to Algorithms', '9786040000460', 2021, N'Introduction to Algorithms là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 202 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'introduction-to-algorithms.jpg', N'Tiếng Anh', 202, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Thomas H. Cormen'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Pearson'), 0, 0),
        (N'Algorithms', '9786040000477', 2022, N'Algorithms là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 239 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'algorithms.jpg', N'Tiếng Anh', 239, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Robert Sedgewick'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Addison Wesley'), 0, 0),
        (N'Database System Concepts', '9786040000484', 2023, N'Database System Concepts là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 276 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'database-system-concepts.jpg', N'Tiếng Anh', 276, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Abraham Silberschatz'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Pearson'), 0, 0),
        (N'Designing Data-Intensive Applications', '9786040000491', 2024, N'Designing Data-Intensive Applications là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 313 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'designing-data-intensive-applications.jpg', N'Tiếng Anh', 313, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Martin Kleppmann'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'O''Reilly Media'), 0, 0),
        (N'Computer Networking', '9786040000507', 2000, N'Computer Networking là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 350 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'computer-networking.jpg', N'Tiếng Anh', 350, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'James F. Kurose'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Pearson'), 0, 0),
        (N'Operating System Concepts', '9786040000514', 2001, N'Operating System Concepts là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 387 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'operating-system-concepts.jpg', N'Tiếng Anh', 387, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Abraham Silberschatz'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Pearson'), 0, 0),
        (N'Computer Systems: A Programmer''s Perspective', '9786040000521', 2002, N'Computer Systems: A Programmer''s Perspective là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 424 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'computer-systems-a-programmers-perspective.jpg', N'Tiếng Anh', 424, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Randal E. Bryant'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Pearson'), 0, 0),
        (N'Artificial Intelligence: A Modern Approach', '9786040000538', 2003, N'Artificial Intelligence: A Modern Approach là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 461 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'artificial-intelligence-a-modern-approach.jpg', N'Tiếng Anh', 461, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Stuart Russell'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Pearson'), 0, 0),
        (N'Deep Learning', '9786040000545', 2004, N'Deep Learning là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 498 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'deep-learning.jpg', N'Tiếng Anh', 498, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Ian Goodfellow'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'MIT Press'), 0, 0),
        (N'Hands-On Machine Learning', '9786040000552', 2005, N'Hands-On Machine Learning là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 535 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'hands-on-machine-learning.jpg', N'Tiếng Anh', 535, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Aurélien Géron'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'O''Reilly Media'), 0, 0),
        (N'Python Crash Course', '9786040000569', 2006, N'Python Crash Course là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 572 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'python-crash-course.jpg', N'Tiếng Anh', 572, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Eric Matthes'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'No Starch Press'), 0, 0),
        (N'Automate the Boring Stuff with Python', '9786040000576', 2007, N'Automate the Boring Stuff with Python là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 189 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'automate-the-boring-stuff-with-python.jpg', N'Tiếng Anh', 189, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Al Sweigart'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'No Starch Press'), 0, 0),
        (N'Fluent Python', '9786040000583', 2008, N'Fluent Python là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 226 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'fluent-python.jpg', N'Tiếng Anh', 226, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Luciano Ramalho'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'O''Reilly Media'), 0, 0),
        (N'Effective Python', '9786040000590', 2009, N'Effective Python là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 263 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'effective-python.jpg', N'Tiếng Anh', 263, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Brett Slatkin'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Addison Wesley'), 0, 0),
        (N'Learning Python', '9786040000606', 2010, N'Learning Python là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 300 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'learning-python.jpg', N'Tiếng Anh', 300, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Mark Lutz'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'O''Reilly Media'), 0, 0),
        (N'To Kill a Mockingbird', '9786040000613', 2011, N'To Kill a Mockingbird là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 337 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'to-kill-a-mockingbird.jpg', N'Tiếng Anh', 337, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Harper Lee'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'1984', '9786040000620', 2012, N'1984 là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 374 trang và được bổ sung vào dữ liệu mẫu của LibHub.', '1984.jpg', N'Tiếng Anh', 374, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'George Orwell'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Animal Farm', '9786040000637', 2013, N'Animal Farm là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 411 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'animal-farm.jpg', N'Tiếng Anh', 411, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'George Orwell'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'The Great Gatsby', '9786040000644', 2014, N'The Great Gatsby là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 448 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-great-gatsby.jpg', N'Tiếng Anh', 448, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'F. Scott Fitzgerald'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'Pride and Prejudice', '9786040000651', 2015, N'Pride and Prejudice là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 485 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'pride-and-prejudice.jpg', N'Tiếng Anh', 485, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Jane Austen'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'The Catcher in the Rye', '9786040000668', 2016, N'The Catcher in the Rye là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 522 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-catcher-in-the-rye.jpg', N'Tiếng Anh', 522, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'J.D. Salinger'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'The Hobbit', '9786040000675', 2017, N'The Hobbit là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 559 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-hobbit.jpg', N'Tiếng Anh', 559, (SELECT category_id FROM Categories WHERE category_name = N'Fantasy'), (SELECT author_id FROM Authors WHERE author_name = N'J.R.R. Tolkien'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'The Lord of the Rings', '9786040000682', 2018, N'The Lord of the Rings là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 596 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-lord-of-the-rings.jpg', N'Tiếng Anh', 596, (SELECT category_id FROM Categories WHERE category_name = N'Fantasy'), (SELECT author_id FROM Authors WHERE author_name = N'J.R.R. Tolkien'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Harry Potter and the Sorcerer''s Stone', '9786040000699', 2019, N'Harry Potter and the Sorcerer''s Stone là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 213 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'harry-potter-and-the-sorcerers-stone.jpg', N'Tiếng Anh', 213, (SELECT category_id FROM Categories WHERE category_name = N'Fantasy'), (SELECT author_id FROM Authors WHERE author_name = N'J.K. Rowling'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Harry Potter and the Chamber of Secrets', '9786040000705', 2020, N'Harry Potter and the Chamber of Secrets là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 250 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'harry-potter-and-the-chamber of-secrets.jpg', N'Tiếng Anh', 250, (SELECT category_id FROM Categories WHERE category_name = N'Fantasy'), (SELECT author_id FROM Authors WHERE author_name = N'J.K. Rowling'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Harry Potter and the Prisoner of Azkaban', '9786040000712', 2021, N'Harry Potter and the Prisoner of Azkaban là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 287 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'harry-potter-and-the-prisoner-of-azkaban.jpg', N'Tiếng Anh', 287, (SELECT category_id FROM Categories WHERE category_name = N'Fantasy'), (SELECT author_id FROM Authors WHERE author_name = N'J.K. Rowling'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Harry Potter and the Goblet of Fire', '9786040000729', 2022, N'Harry Potter and the Goblet of Fire là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 324 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'harry-potter-and-the-goblet-of-fire.jpg', N'Tiếng Anh', 324, (SELECT category_id FROM Categories WHERE category_name = N'Fantasy'), (SELECT author_id FROM Authors WHERE author_name = N'J.K. Rowling'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Harry Potter and the Order of the Phoenix', '9786040000736', 2023, N'Harry Potter and the Order of the Phoenix là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 361 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'harry-potter-and-the-order-of-the-phoenix.jpg', N'Tiếng Anh', 361, (SELECT category_id FROM Categories WHERE category_name = N'Fantasy'), (SELECT author_id FROM Authors WHERE author_name = N'J.K. Rowling'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Harry Potter and the Half-Blood Prince', '9786040000743', 2024, N'Harry Potter and the Half-Blood Prince là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 398 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'harry-potter-and-the-half-blood-prince.jpg', N'Tiếng Anh', 398, (SELECT category_id FROM Categories WHERE category_name = N'Fantasy'), (SELECT author_id FROM Authors WHERE author_name = N'J.K. Rowling'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Harry Potter and the Deathly Hallows', '9786040000750', 2000, N'Harry Potter and the Deathly Hallows là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 435 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'harry-potter-and-the-deathly-hallows.jpg', N'Tiếng Anh', 435, (SELECT category_id FROM Categories WHERE category_name = N'Fantasy'), (SELECT author_id FROM Authors WHERE author_name = N'J.K. Rowling'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'The Little Prince', '9786040000767', 2001, N'The Little Prince là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 472 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-little-prince.jpg', N'Tiếng Anh', 472, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Antoine de Saint-Exupéry'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'The Old Man and the Sea', '9786040000774', 2002, N'The Old Man and the Sea là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 509 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-old-man-and-the-sea.jpg', N'Tiếng Anh', 509, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Ernest Hemingway'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'The Alchemist', '9786040000781', 2003, N'The Alchemist là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 546 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-alchemist.jpg', N'Tiếng Anh', 546, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Paulo Coelho'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Kitchen', '9786040000798', 2004, N'Kitchen là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 583 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'kitchen.jpg', N'Tiếng Anh', 583, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Banana Yoshimoto'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Kafka on the Shore', '9786040000804', 2005, N'Kafka on the Shore là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 200 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'kafka-on-the-shore.jpg', N'Tiếng Anh', 200, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Haruki Murakami'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'One Hundred Years of Solitude', '9786040000811', 2006, N'One Hundred Years of Solitude là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 237 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'one-hundred-years-of-solitude.jpg', N'Tiếng Anh', 237, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Gabriel García Márquez'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'Love in the Time of Cholera', '9786040000828', 2007, N'Love in the Time of Cholera là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 274 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'love-in-the-time-of-cholera.jpg', N'Tiếng Anh', 274, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Gabriel García Márquez'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'The Kite Runner', '9786040000835', 2008, N'The Kite Runner là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 311 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-kite-runner.jpg', N'Tiếng Anh', 311, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Khaled Hosseini'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'A Thousand Splendid Suns', '9786040000842', 2009, N'A Thousand Splendid Suns là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 348 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'a-thousand-splendid-suns.jpg', N'Tiếng Anh', 348, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Khaled Hosseini'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'The Book Thief', '9786040000859', 2010, N'The Book Thief là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 385 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-book-thief.jpg', N'Tiếng Anh', 385, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Markus Zusak'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Life of Pi', '9786040000866', 2011, N'Life of Pi là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 422 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'life-of-pi.jpg', N'Tiếng Anh', 422, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Yann Martel'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'The Road', '9786040000873', 2012, N'The Road là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 459 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-road.jpg', N'Tiếng Anh', 459, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Cormac McCarthy'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'The Martian', '9786040000880', 2013, N'The Martian là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 496 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-martian.jpg', N'Tiếng Anh', 496, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Andy Weir'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Project Hail Mary', '9786040000897', 2014, N'Project Hail Mary là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 533 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'project-hail-mary.jpg', N'Tiếng Anh', 533, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Andy Weir'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Dune', '9786040000903', 2015, N'Dune là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 570 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'dune.jpg', N'Tiếng Anh', 570, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Frank Herbert'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Fahrenheit 451', '9786040000910', 2016, N'Fahrenheit 451 là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 187 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'fahrenheit-451.jpg', N'Tiếng Anh', 187, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Ray Bradbury'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Brave New World', '9786040000927', 2017, N'Brave New World là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 224 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'brave-new-world.jpg', N'Tiếng Anh', 224, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Aldous Huxley'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'The Handmaid''s Tale', '9786040000934', 2018, N'The Handmaid''s Tale là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 261 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-handmaids-tale.jpg', N'Tiếng Anh', 261, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Margaret Atwood'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'The Hunger Games', '9786040000941', 2019, N'The Hunger Games là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 298 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-hunger-games.jpg', N'Tiếng Anh', 298, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Suzanne Collins'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Catching Fire', '9786040000958', 2020, N'Catching Fire là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 335 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'catching-fire.jpg', N'Tiếng Anh', 335, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Suzanne Collins'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Mockingjay', '9786040000965', 2021, N'Mockingjay là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 372 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'mockingjay.jpg', N'Tiếng Anh', 372, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Suzanne Collins'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'The Fault in Our Stars', '9786040000972', 2022, N'The Fault in Our Stars là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 409 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-fault-in-our-stars.jpg', N'Tiếng Anh', 409, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'John Green'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Me Before You', '9786040000989', 2023, N'Me Before You là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 446 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'me-before-you.jpg', N'Tiếng Anh', 446, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Jojo Moyes'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'The Notebook', '9786040000996', 2024, N'The Notebook là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 483 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-notebook.jpg', N'Tiếng Anh', 483, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Nicholas Sparks'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'A Man Called Ove', '9786040001009', 2000, N'A Man Called Ove là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 520 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'a-man-called-ove.jpg', N'Tiếng Anh', 520, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Fredrik Backman'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Educated', '9786040001016', 2001, N'Educated là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 557 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'educated.jpg', N'Tiếng Anh', 557, (SELECT category_id FROM Categories WHERE category_name = N'Hồi ký'), (SELECT author_id FROM Authors WHERE author_name = N'Tara Westover'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Trẻ'), 0, 0),
        (N'Becoming', '9786040001023', 2002, N'Becoming là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 594 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'becoming.jpg', N'Tiếng Anh', 594, (SELECT category_id FROM Categories WHERE category_name = N'Hồi ký'), (SELECT author_id FROM Authors WHERE author_name = N'Michelle Obama'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Trẻ'), 0, 0),
        (N'Steve Jobs', '9786040001030', 2003, N'Steve Jobs là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 211 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'steve-jobs.jpg', N'Tiếng Anh', 211, (SELECT category_id FROM Categories WHERE category_name = N'Hồi ký'), (SELECT author_id FROM Authors WHERE author_name = N'Walter Isaacson'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Trẻ'), 0, 0),
        (N'Elon Musk', '9786040001047', 2004, N'Elon Musk là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 248 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'elon-musk.jpg', N'Tiếng Anh', 248, (SELECT category_id FROM Categories WHERE category_name = N'Hồi ký'), (SELECT author_id FROM Authors WHERE author_name = N'Walter Isaacson'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Trẻ'), 0, 0),
        (N'Sapiens', '9786040001054', 2005, N'Sapiens là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 285 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'sapiens.jpg', N'Tiếng Anh', 285, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Yuval Noah Harari'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Homo Deus', '9786040001061', 2006, N'Homo Deus là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 322 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'homo-deus.jpg', N'Tiếng Anh', 322, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Yuval Noah Harari'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'21 Lessons for the 21st Century', '9786040001078', 2007, N'21 Lessons for the 21st Century là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 359 trang và được bổ sung vào dữ liệu mẫu của LibHub.', '21-lessons-for-the-21st-century.jpg', N'Tiếng Anh', 359, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Yuval Noah Harari'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Guns, Germs, and Steel', '9786040001085', 2008, N'Guns, Germs, and Steel là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 396 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'guns-germs-and-steel.jpg', N'Tiếng Anh', 396, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Jared Diamond'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'A Brief History of Time', '9786040001092', 2009, N'A Brief History of Time là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 433 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'a-brief-history-of-time.jpg', N'Tiếng Anh', 433, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Stephen Hawking'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Cosmos', '9786040001108', 2010, N'Cosmos là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 470 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'cosmos.jpg', N'Tiếng Anh', 470, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Carl Sagan'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Astrophysics for People in a Hurry', '9786040001115', 2011, N'Astrophysics for People in a Hurry là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 507 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'astrophysics-for-people-in-a-hurry.jpg', N'Tiếng Anh', 507, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Neil deGrasse Tyson'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'The Selfish Gene', '9786040001122', 2012, N'The Selfish Gene là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 544 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-selfish-gene.jpg', N'Tiếng Anh', 544, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Richard Dawkins'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'The Gene', '9786040001139', 2013, N'The Gene là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 581 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-gene.jpg', N'Tiếng Anh', 581, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Siddhartha Mukherjee'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Silent Spring', '9786040001146', 2014, N'Silent Spring là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 198 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'silent-spring.jpg', N'Tiếng Anh', 198, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Rachel Carson'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'The Immortal Life of Henrietta Lacks', '9786040001153', 2015, N'The Immortal Life of Henrietta Lacks là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 235 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-immortal-life-of-henrietta-lacks.jpg', N'Tiếng Anh', 235, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Rebecca Skloot'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Why We Sleep', '9786040001160', 2016, N'Why We Sleep là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 272 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'why-we-sleep.jpg', N'Tiếng Anh', 272, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Matthew Walker'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Thinking in Systems', '9786040001177', 2017, N'Thinking in Systems là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 309 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'thinking-in-systems.jpg', N'Tiếng Anh', 309, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Donella H. Meadows'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Factfulness', '9786040001184', 2018, N'Factfulness là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 346 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'factfulness.jpg', N'Tiếng Anh', 346, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Hans Rosling'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Outliers', '9786040001191', 2019, N'Outliers là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 383 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'outliers.jpg', N'Tiếng Anh', 383, (SELECT category_id FROM Categories WHERE category_name = N'Tâm lý học'), (SELECT author_id FROM Authors WHERE author_name = N'Malcolm Gladwell'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thái Hà Books'), 0, 0),
        (N'Blink', '9786040001207', 2020, N'Blink là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 420 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'blink.jpg', N'Tiếng Anh', 420, (SELECT category_id FROM Categories WHERE category_name = N'Tâm lý học'), (SELECT author_id FROM Authors WHERE author_name = N'Malcolm Gladwell'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thái Hà Books'), 0, 0),
        (N'The Tipping Point', '9786040001214', 2021, N'The Tipping Point là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 457 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-tipping-point.jpg', N'Tiếng Anh', 457, (SELECT category_id FROM Categories WHERE category_name = N'Tâm lý học'), (SELECT author_id FROM Authors WHERE author_name = N'Malcolm Gladwell'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thái Hà Books'), 0, 0),
        (N'David and Goliath', '9786040001221', 2022, N'David and Goliath là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 494 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'david-and-goliath.jpg', N'Tiếng Anh', 494, (SELECT category_id FROM Categories WHERE category_name = N'Tâm lý học'), (SELECT author_id FROM Authors WHERE author_name = N'Malcolm Gladwell'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thái Hà Books'), 0, 0),
        (N'Grit', '9786040001238', 2023, N'Grit là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 531 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'grit.jpg', N'Tiếng Anh', 531, (SELECT category_id FROM Categories WHERE category_name = N'Tâm lý học'), (SELECT author_id FROM Authors WHERE author_name = N'Angela Duckworth'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thái Hà Books'), 0, 0),
        (N'Drive', '9786040001245', 2024, N'Drive là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 568 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'drive.jpg', N'Tiếng Anh', 568, (SELECT category_id FROM Categories WHERE category_name = N'Tâm lý học'), (SELECT author_id FROM Authors WHERE author_name = N'Daniel H. Pink'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thái Hà Books'), 0, 0),
        (N'Leaders Eat Last', '9786040001252', 2000, N'Leaders Eat Last là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 185 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'leaders-eat-last.jpg', N'Tiếng Anh', 185, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Simon Sinek'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Alphabooks'), 0, 0),
        (N'Dare to Lead', '9786040001269', 2001, N'Dare to Lead là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 222 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'dare-to-lead.jpg', N'Tiếng Anh', 222, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Brené Brown'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Alphabooks'), 0, 0),
        (N'Good Vibes, Good Life', '9786040001276', 2002, N'Good Vibes, Good Life là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 259 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'good-vibes-good-life.jpg', N'Tiếng Anh', 259, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Vex King'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0),
        (N'The Subtle Art of Not Giving a F*ck', '9786040001283', 2003, N'The Subtle Art of Not Giving a F*ck là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 296 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-subtle-art-of-not-giving-a-Fck.jpg', N'Tiếng Anh', 296, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Mark Manson'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0),
        (N'Everything Is Figureoutable', '9786040001290', 2004, N'Everything Is Figureoutable là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 333 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'everything-is-figureoutable.jpg', N'Tiếng Anh', 333, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Marie Forleo'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0),
        (N'The Mountain Is You', '9786040001306', 2005, N'The Mountain Is You là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 370 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-mountain-is-you.jpg', N'Tiếng Anh', 370, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Brianna Wiest'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0),
        (N'Attached', '9786040001313', 2006, N'Attached là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 407 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'attached.jpg', N'Tiếng Anh', 407, (SELECT category_id FROM Categories WHERE category_name = N'Tâm lý học'), (SELECT author_id FROM Authors WHERE author_name = N'Amir Levine'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thái Hà Books'), 0, 0),
        (N'The Gifts of Imperfection', '9786040001320', 2007, N'The Gifts of Imperfection là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 444 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-gifts-of-imperfection.jpg', N'Tiếng Anh', 444, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Brené Brown'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0),
        (N'The Courage to Be Disliked', '9786040001337', 2008, N'The Courage to Be Disliked là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 481 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-courage-to-Be-disliked.jpg', N'Tiếng Anh', 481, (SELECT category_id FROM Categories WHERE category_name = N'Triết học'), (SELECT author_id FROM Authors WHERE author_name = N'Ichiro Kishimi'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Hội Nhà Văn'), 0, 0),
        (N'Man''s Search for Meaning', '9786040001344', 2009, N'Man''s Search for Meaning là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 518 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'mans-search-for-meaning.jpg', N'Tiếng Anh', 518, (SELECT category_id FROM Categories WHERE category_name = N'Hồi ký'), (SELECT author_id FROM Authors WHERE author_name = N'Viktor E. Frankl'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Trẻ'), 0, 0),
        (N'Meditations', '9786040001351', 2010, N'Meditations là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 555 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'meditations.jpg', N'Tiếng Anh', 555, (SELECT category_id FROM Categories WHERE category_name = N'Triết học'), (SELECT author_id FROM Authors WHERE author_name = N'Marcus Aurelius'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Hội Nhà Văn'), 0, 0),
        (N'The Art of War', '9786040001368', 2011, N'The Art of War là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 592 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-art-of-war.jpg', N'Tiếng Anh', 592, (SELECT category_id FROM Categories WHERE category_name = N'Triết học'), (SELECT author_id FROM Authors WHERE author_name = N'Sun Tzu'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Hội Nhà Văn'), 0, 0),
        (N'Letters from a Stoic', '9786040001375', 2012, N'Letters from a Stoic là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 209 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'letters-from-a-stoic.jpg', N'Tiếng Anh', 209, (SELECT category_id FROM Categories WHERE category_name = N'Triết học'), (SELECT author_id FROM Authors WHERE author_name = N'Seneca'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Hội Nhà Văn'), 0, 0),
        (N'The Republic', '9786040001382', 2013, N'The Republic là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 246 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-republic.jpg', N'Tiếng Anh', 246, (SELECT category_id FROM Categories WHERE category_name = N'Triết học'), (SELECT author_id FROM Authors WHERE author_name = N'Plato'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Hội Nhà Văn'), 0, 0),
        (N'Beyond Good and Evil', '9786040001399', 2014, N'Beyond Good and Evil là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 283 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'beyond-good-and-evil.jpg', N'Tiếng Anh', 283, (SELECT category_id FROM Categories WHERE category_name = N'Triết học'), (SELECT author_id FROM Authors WHERE author_name = N'Friedrich Nietzsche'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Hội Nhà Văn'), 0, 0),
        (N'Thus Spoke Zarathustra', '9786040001405', 2015, N'Thus Spoke Zarathustra là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 320 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'thus-spoke-zarathustra.jpg', N'Tiếng Anh', 320, (SELECT category_id FROM Categories WHERE category_name = N'Triết học'), (SELECT author_id FROM Authors WHERE author_name = N'Friedrich Nietzsche'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Hội Nhà Văn'), 0, 0),
        (N'Crime and Punishment', '9786040001412', 2016, N'Crime and Punishment là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 357 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'crime-and-punishment.jpg', N'Tiếng Anh', 357, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Fyodor Dostoevsky'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'The Brothers Karamazov', '9786040001429', 2017, N'The Brothers Karamazov là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 394 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-brothers-karamazov.jpg', N'Tiếng Anh', 394, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Fyodor Dostoevsky'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'Anna Karenina', '9786040001436', 2018, N'Anna Karenina là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 431 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'anna-karenina.jpg', N'Tiếng Anh', 431, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Leo Tolstoy'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'War and Peace', '9786040001443', 2019, N'War and Peace là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 468 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'war-and-peace.jpg', N'Tiếng Anh', 468, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Leo Tolstoy'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'Les Misérables', '9786040001450', 2020, N'Les Misérables là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 505 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'les-miserables.jpg', N'Tiếng Anh', 505, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Victor Hugo'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'The Count of Monte Cristo', '9786040001467', 2021, N'The Count of Monte Cristo là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 542 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-count-of-monte-cristo.jpg', N'Tiếng Anh', 542, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Alexandre Dumas'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'The Picture of Dorian Gray', '9786040001474', 2022, N'The Picture of Dorian Gray là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 579 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-picture-of-dorian-gray.jpg', N'Tiếng Anh', 579, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Oscar Wilde'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'Dracula', '9786040001481', 2023, N'Dracula là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 196 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'dracula.jpg', N'Tiếng Anh', 196, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Bram Stoker'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Frankenstein', '9786040001498', 2024, N'Frankenstein là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 233 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'frankenstein.jpg', N'Tiếng Anh', 233, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Mary Shelley'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'The Strange Case of Dr Jekyll and Mr Hyde', '9786040001504', 2000, N'The Strange Case of Dr Jekyll and Mr Hyde là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 270 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-strange-case-of-dr-jekyll-and-mr-hyde.jpg', N'Tiếng Anh', 270, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Robert Louis Stevenson'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Around the World in Eighty Days', '9786040001511', 2001, N'Around the World in Eighty Days là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 307 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'around-the-world-in-eighty-days.jpg', N'Tiếng Anh', 307, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Jules Verne'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'Twenty Thousand Leagues Under the Sea', '9786040001528', 2002, N'Twenty Thousand Leagues Under the Sea là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 344 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'twenty-thousand-leagues-under-the-sea.jpg', N'Tiếng Anh', 344, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Jules Verne'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Journey to the Center of the Earth', '9786040001535', 2003, N'Journey to the Center of the Earth là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 381 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'journey-to-the-center-of-the-earth.jpg', N'Tiếng Anh', 381, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Jules Verne'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'The Adventures of Sherlock Holmes', '9786040001542', 2004, N'The Adventures of Sherlock Holmes là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 418 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'The-adventures-of-sherlock-holmes.jpg', N'Tiếng Anh', 418, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Arthur Conan Doyle'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'The Hound of the Baskervilles', '9786040001559', 2005, N'The Hound of the Baskervilles là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 455 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-hound-of-the-baskervilles.jpg', N'Tiếng Anh', 455, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Arthur Conan Doyle'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Murder on the Orient Express', '9786040001566', 2006, N'Murder on the Orient Express là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 492 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'murder-on-the-orient-express.jpg', N'Tiếng Anh', 492, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Agatha Christie'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'And Then There Were None', '9786040001573', 2007, N'And Then There Were None là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 529 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'and-then-there-were-none.jpg', N'Tiếng Anh', 529, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Agatha Christie'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'The Murder of Roger Ackroyd', '9786040001580', 2008, N'The Murder of Roger Ackroyd là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 566 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-murder-of-roger-ackroyd.jpg', N'Tiếng Anh', 566, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Agatha Christie'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'The Girl with the Dragon Tattoo', '9786040001597', 2009, N'The Girl with the Dragon Tattoo là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 183 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-girl-with-the-dragon-tattoo.jpg', N'Tiếng Anh', 183, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Stieg Larsson'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Gone Girl', '9786040001603', 2010, N'Gone Girl là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 220 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'gone-girl.jpg', N'Tiếng Anh', 220, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Gillian Flynn'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'The Silent Patient', '9786040001610', 2011, N'The Silent Patient là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 257 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-silent-patient.jpg', N'Tiếng Anh', 257, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Alex Michaelides'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'The Da Vinci Code', '9786040001627', 2012, N'The Da Vinci Code là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 294 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-da-vinci-code.jpg', N'Tiếng Anh', 294, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Dan Brown'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Angels & Demons', '9786040001634', 2013, N'Angels & Demons là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 331 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'angels-vs-demons.jpg', N'Tiếng Anh', 331, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Dan Brown'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Inferno', '9786040001641', 2014, N'Inferno là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 368 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'inferno.jpg', N'Tiếng Anh', 368, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Dan Brown'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Digital Fortress', '9786040001658', 2015, N'Digital Fortress là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 405 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'digital-fortress.jpg', N'Tiếng Anh', 405, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Dan Brown'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'The Shining', '9786040001665', 2016, N'The Shining là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 442 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-shining.jpg', N'Tiếng Anh', 442, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Stephen King'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'It', '9786040001672', 2017, N'It là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 479 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'it.jpg', N'Tiếng Anh', 479, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Stephen King'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Misery', '9786040001689', 2018, N'Misery là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 516 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'misery.jpg', N'Tiếng Anh', 516, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Stephen King'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Pet Sematary', '9786040001696', 2019, N'Pet Sematary là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 553 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'pet-sematary.jpg', N'Tiếng Anh', 553, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Stephen King'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'The Green Mile', '9786040001702', 2020, N'The Green Mile là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 590 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-green-mile.jpg', N'Tiếng Anh', 590, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Stephen King'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Men Without Women', '9786040001719', 2021, N'Men Without Women là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 207 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'men-without-women.jpg', N'Tiếng Anh', 207, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Haruki Murakami'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Colorless Tsukuru Tazaki', '9786040001726', 2022, N'Colorless Tsukuru Tazaki là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 244 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'colorless-tsukuru-tazaki.jpg', N'Tiếng Anh', 244, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Haruki Murakami'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'The Wind-Up Bird Chronicle', '9786040001733', 2023, N'The Wind-Up Bird Chronicle là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 281 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'the-wind-up-bird-chronicle.jpg', N'Tiếng Anh', 281, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Haruki Murakami'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Dế Mèn Phiêu Lưu Ký', '9786040001740', 2024, N'Dế Mèn Phiêu Lưu Ký là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 318 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'De-men-phieu-luu-ky.jpg', N'Tiếng Việt', 318, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Tô Hoài'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Kim Đồng'), 0, 0),
        (N'Cho Tôi Xin Một Vé Đi Tuổi Thơ', '9786040001757', 2000, N'Cho Tôi Xin Một Vé Đi Tuổi Thơ là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 355 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'cho-toi-xin-mot-ve-di-ve-tuoi-tho.jpg', N'Tiếng Việt', 355, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyễn Nhật Ánh'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Trẻ'), 0, 0),
        (N'Mắt Biếc', '9786040001764', 2001, N'Mắt Biếc là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 392 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'mat-biec.jpg', N'Tiếng Việt', 392, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyễn Nhật Ánh'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Trẻ'), 0, 0),
        (N'Tôi Thấy Hoa Vàng Trên Cỏ Xanh', '9786040001771', 2002, N'Tôi Thấy Hoa Vàng Trên Cỏ Xanh là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 429 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'toi-thay-hoa-vang-tren-co-xanh.jpg', N'Tiếng Việt', 429, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyễn Nhật Ánh'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Trẻ'), 0, 0),
        (N'Cô Gái Đến Từ Hôm Qua', '9786040001788', 2003, N'Cô Gái Đến Từ Hôm Qua là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 466 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'co-gai-den-tu-hom-qua.jpg', N'Tiếng Việt', 466, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyễn Nhật Ánh'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Trẻ'), 0, 0),
        (N'Ngồi Khóc Trên Cây', '9786040001795', 2004, N'Ngồi Khóc Trên Cây là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 503 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'ngoi-khoc-tren-cay.jpg', N'Tiếng Việt', 503, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyễn Nhật Ánh'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Trẻ'), 0, 0),
        (N'Làm Bạn Với Bầu Trời', '9786040001801', 2005, N'Làm Bạn Với Bầu Trời là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 540 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'lam-ban-voi-bau-troi.jpg', N'Tiếng Việt', 540, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyễn Nhật Ánh'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Trẻ'), 0, 0),
        (N'Bắt Trẻ Đồng Xanh', '9786040001818', 2006, N'Bắt Trẻ Đồng Xanh là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 577 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'bat-tre-dong-xanh.jpg', N'Tiếng Anh', 577, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'J.D. Salinger'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'Vừa Nhắm Mắt Vừa Mở Cửa Sổ', '9786040001825', 2007, N'Vừa Nhắm Mắt Vừa Mở Cửa Sổ là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 194 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'vua-nham-mat-vua-mo-cua-so.jpg', N'Tiếng Anh', 194, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyễn Ngọc Thuần'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Trẻ'), 0, 0),
        (N'Thương Nhớ Mười Hai', '9786040001832', 2008, N'Thương Nhớ Mười Hai là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 231 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'thuong-nho-muoi-hai.jpg', N'Tiếng Việt', 231, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Vũ Bằng'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'Vang Bóng Một Thời', '9786040001849', 2009, N'Vang Bóng Một Thời là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 268 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'vang-bong-mot-thoi.jpg', N'Tiếng Việt', 268, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyễn Tuân'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'Số Đỏ', '9786040001856', 2010, N'Số Đỏ là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 305 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'so-do.jpg', N'Tiếng Việt', 305, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Vũ Trọng Phụng'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'Chí Phèo', '9786040001863', 2011, N'Chí Phèo là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 342 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'chi-pheo.jpg', N'Tiếng Việt', 342, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nam Cao'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'Tắt Đèn', '9786040001870', 2012, N'Tắt Đèn là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 379 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'tat-den.jpg', N'Tiếng Việt', 379, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Ngô Tất Tố'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'Lão Hạc', '9786040001887', 2013, N'Lão Hạc là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 416 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'lao-hac.jpg', N'Tiếng Việt', 416, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nam Cao'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'Những Ngày Thơ Ấu', '9786040001894', 2014, N'Những Ngày Thơ Ấu là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 453 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'nhung-ngay-tho-au.jpg', N'Tiếng Việt', 453, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyên Hồng'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'Gió Lạnh Đầu Mùa', '9786040001900', 2015, N'Gió Lạnh Đầu Mùa là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 490 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'gio-lanh-dau-mua.jpg', N'Tiếng Việt', 490, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Thạch Lam'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'Hai Đứa Trẻ', '9786040001917', 2016, N'Hai Đứa Trẻ là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 527 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'hai-dua-tre.jpg', N'Tiếng Việt', 527, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Thạch Lam'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'Vợ Nhặt', '9786040001924', 2017, N'Vợ Nhặt là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 564 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'vo-nhat.jpg', N'Tiếng Việt', 564, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Kim Lân'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'Rừng Xà Nu', '9786040001931', 2018, N'Rừng Xà Nu là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 181 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'rung-xa-nu.jpg', N'Tiếng Việt', 181, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyễn Trung Thành'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'Đất Rừng Phương Nam', '9786040001948', 2019, N'Đất Rừng Phương Nam là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 218 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'dat-rung-phuong-nam.jpg', N'Tiếng Việt', 218, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Đoàn Giỏi'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0),
        (N'Nỗi Buồn Chiến Tranh', '9786040001955', 2020, N'Nỗi Buồn Chiến Tranh là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 255 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'noi-buon-chien-trang.jpg', N'Tiếng Việt', 255, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Bảo Ninh'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Trẻ'), 0, 0),
        (N'O chuột', '9786040001962', 2021, N'Tập truyện của Tô Hoài khắc họa sinh động thế giới loài vật và đời sống thôn quê bằng giọng kể hóm hỉnh, giàu quan sát.', 'o-chuot.jpg', N'Tiếng Việt', 292, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Tô Hoài'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Kim Đồng'), 0, 0),
        (N'Lược Sử Thời Gian', '9786040001979', 2022, N'Lược Sử Thời Gian là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 329 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'luoc-su-thoi-gian.jpg', N'Tiếng Việt', 329, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Stephen Hawking'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0),
        (N'Hành Trình Về Phương Đông', '9786040001986', 2023, N'Hành Trình Về Phương Đông là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 366 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'Hành Trình Về Phương Đông.jpg', N'Tiếng Việt', 366, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyên Phong'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0),
        (N'Sức Mạnh Của Thói Quen', '9786040001993', 2024, N'Sức Mạnh Của Thói Quen là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 403 trang và được bổ sung vào dữ liệu mẫu của LibHub.', 'suc-manh-cua-thoi-quen.jpg', N'Tiếng Việt', 403, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Charles Duhigg'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0),
        (N'7 Nguyên Tắc Bất Biến Để Thành Công', '9786040002006', 2000, N'7 Nguyên Tắc Bất Biến Để Thành Công là một đầu sách phù hợp cho thư viện, tập trung vào kiến thức, phát triển bản thân, văn học hoặc công nghệ tùy theo chủ đề. Ấn phẩm có khoảng 440 trang và được bổ sung vào dữ liệu mẫu của LibHub.', '7-nguyen-tac-bat-bien-de-thanh-cong.jpg', N'Tiếng Việt', 440, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Napoleon Hill'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Alphabooks'), 0, 0);
    GO

    -- ============================================
    -- 10.1) VIET LAI TOAN BO MO TA SACH
    -- Mo ta duoc tao theo noi dung cua tung nhom sach, dong thoi dua vao
    -- ten sach, tac gia, nam xuat ban va so trang de moi ban ghi co thong tin rieng.
    -- ============================================
    UPDATE b
    SET b.description =
        CASE c.category_name
            WHEN N'Tiểu thuyết' THEN CONCAT(
                N'“', b.title, N'” của ', COALESCE(a.author_name, N'tác giả khuyết danh'),
                N' mở ra một thế giới hư cấu giàu hình ảnh, nơi số phận nhân vật, những lựa chọn khó khăn và các biến chuyển nội tâm cùng dẫn dắt câu chuyện. Tác phẩm phù hợp với độc giả muốn thưởng thức một hành trình dài, đồng thời suy ngẫm về con người và đời sống.'
            )
            WHEN N'Văn học Việt Nam' THEN CONCAT(
                N'“', b.title, N'” là tác phẩm của ', COALESCE(a.author_name, N'một tác giả Việt Nam'),
                N', tái hiện con người và đời sống Việt Nam qua giọng văn giàu cảm xúc. Những chi tiết gần gũi, bối cảnh đậm bản sắc và chiều sâu nhân văn giúp cuốn sách để lại dư âm về gia đình, quê hương và những đổi thay của thời đại.'
            )
            WHEN N'Văn học kinh điển' THEN CONCAT(
                N'“', b.title, N'” của ', COALESCE(a.author_name, N'tác giả khuyết danh'),
                N' là một tác phẩm đã vượt qua giới hạn của thời gian nhờ những nhân vật đáng nhớ và các vấn đề nhân sinh vẫn còn nguyên sức gợi. Cuốn sách mời người đọc bước vào bối cảnh văn hóa đặc trưng, đồng thời khám phá tình yêu, danh dự, tự do và phẩm giá con người.'
            )
            WHEN N'Fantasy' THEN CONCAT(
                N'“', b.title, N'” đưa người đọc vào một thế giới kỳ ảo được xây dựng công phu, nơi phép thuật, truyền thuyết và những hiểm nguy chưa biết đan xen. Qua hành trình của các nhân vật, ', COALESCE(a.author_name, N'tác giả'),
                N' kể một câu chuyện về lòng can đảm, tình bạn và cái giá của quyền lực.'
            )
            WHEN N'Trinh thám - Kinh dị' THEN CONCAT(
                N'“', b.title, N'” là một câu chuyện trinh thám cuốn hút của ', COALESCE(a.author_name, N'tác giả khuyết danh'),
                N'. Các dấu vết tưởng như rời rạc, động cơ bị che giấu và những cú chuyển hướng liên tục buộc người đọc phải quan sát kỹ, suy luận và đặt lại mọi giả thuyết cho đến trang cuối.'
            )
            WHEN N'Hồi ký' THEN CONCAT(
                N'Trong “', b.title, N'”, ', COALESCE(a.author_name, N'tác giả'),
                N' nhìn lại những trải nghiệm đã định hình cuộc đời mình bằng giọng kể chân thành và nhiều suy tư. Cuốn sách không chỉ ghi lại ký ức cá nhân mà còn mở ra một lát cắt về con người, hoàn cảnh lịch sử và sức mạnh giúp ta đi qua nghịch cảnh.'
            )
            WHEN N'Tâm lý học' THEN CONCAT(
                N'“', b.title, N'” của ', COALESCE(a.author_name, N'tác giả'),
                N' khám phá cách con người suy nghĩ, cảm nhận và đưa ra quyết định. Thông qua các khái niệm tâm lý cùng ví dụ gần gũi, cuốn sách giúp người đọc nhận diện những khuôn mẫu vô thức, hiểu rõ bản thân và xây dựng cách ứng xử tỉnh táo hơn.'
            )
            WHEN N'Kỹ năng sống' THEN CONCAT(
                N'“', b.title, N'” của ', COALESCE(a.author_name, N'tác giả'),
                N' cung cấp những góc nhìn và phương pháp có thể áp dụng vào học tập, công việc và đời sống hằng ngày. Nội dung hướng người đọc từ việc hiểu vấn đề đến hình thành thói quen hành động, quản lý thời gian và phát triển bản thân một cách bền vững.'
            )
            WHEN N'Kinh doanh' THEN CONCAT(
                N'“', b.title, N'” trình bày tư duy kinh doanh của ', COALESCE(a.author_name, N'tác giả'),
                N' qua các bài học về chiến lược, tài chính, lãnh đạo và xây dựng giá trị. Cuốn sách kết hợp nguyên tắc nền tảng với tình huống thực tế, phù hợp cho người khởi nghiệp, nhà quản lý và bất kỳ ai muốn hiểu cách một tổ chức phát triển.'
            )
            WHEN N'Công nghệ' THEN CONCAT(
                N'“', b.title, N'” của ', COALESCE(a.author_name, N'tác giả'),
                N' hệ thống hóa các nguyên lý và kỹ thuật quan trọng trong lĩnh vực công nghệ. Từ nền tảng lý thuyết đến cách giải quyết vấn đề thực tế, cuốn sách giúp người đọc xây dựng tư duy kỹ thuật, viết giải pháp rõ ràng và làm việc hiệu quả với các hệ thống hiện đại.'
            )
            WHEN N'Khoa học' THEN CONCAT(
                N'“', b.title, N'” dẫn dắt người đọc khám phá các quy luật của tự nhiên bằng lối giải thích mạch lạc và giàu liên tưởng. ', COALESCE(a.author_name, N'Tác giả'),
                N' kết nối những phát hiện khoa học với các câu hỏi lớn về sự sống, vũ trụ và vị trí của con người trong thế giới.'
            )
            WHEN N'Khoa học viễn tưởng' THEN CONCAT(
                N'“', b.title, N'” của ', COALESCE(a.author_name, N'tác giả'),
                N' dựng nên một tương lai nơi khoa học và công nghệ làm thay đổi sâu sắc xã hội loài người. Bên dưới những ý tưởng táo bạo là các câu hỏi về đạo đức, bản sắc, quyền lực và trách nhiệm của con người trước chính những thứ mình tạo ra.'
            )
            WHEN N'Triết học' THEN CONCAT(
                N'“', b.title, N'” giới thiệu những suy tưởng của ', COALESCE(a.author_name, N'tác giả'),
                N' về tri thức, đạo đức, tự do và ý nghĩa tồn tại. Cuốn sách khuyến khích người đọc chất vấn các giả định quen thuộc, nhìn một vấn đề từ nhiều phía và hình thành lập luận độc lập.'
            )
            WHEN N'Phật giáo' THEN CONCAT(
                N'“', b.title, N'” tiếp cận đời sống tinh thần qua các câu chuyện, tư tưởng và thực hành có chiều sâu. Với sự dẫn dắt của ', COALESCE(a.author_name, N'tác giả'),
                N', người đọc có dịp suy ngẫm về lòng từ bi, đức tin, sự bình an và cách sống có ý nghĩa giữa những biến động thường ngày.'
            )
            ELSE CONCAT(
                N'“', b.title, N'” của ', COALESCE(a.author_name, N'tác giả khuyết danh'),
                N' mang đến một góc nhìn có hệ thống về chủ đề mà tác phẩm theo đuổi. Nội dung được trình bày để người đọc vừa nắm được những ý chính, vừa có thêm chất liệu suy ngẫm và vận dụng trong học tập hoặc đời sống.'
            )
        END
        + CONCAT(
            N' Ấn bản ', COALESCE(CONVERT(NVARCHAR(4), b.publish_year), N'không ghi năm'),
            N' gồm ', COALESCE(CONVERT(NVARCHAR(10), b.pages), N'nhiều'), N' trang',
            CASE WHEN p.publisher_name IS NOT NULL THEN CONCAT(N', do ', p.publisher_name, N' phát hành.') ELSE N'.' END
        )
    FROM Books b
    LEFT JOIN Categories c ON c.category_id = b.category_id
    LEFT JOIN Authors a ON a.author_id = b.author_id
    LEFT JOIN Publishers p ON p.publisher_id = b.publisher_id;
    GO

    -- Mo ta bien tap rieng cho tung tac pham; co y bo qua ISBN cua "Sach mau".
    -- Moi mo ta gom tom tat noi dung rieng va thong tin an ban tu chinh ban ghi sach.
    DECLARE @BookDescriptions TABLE (isbn VARCHAR(20) PRIMARY KEY, description NVARCHAR(MAX));
    INSERT INTO @BookDescriptions (isbn, description) VALUES
    ('9786040000019', N'Chàng chăn cừu Santiago rời quê nhà để theo đuổi kho báu trong giấc mơ, rồi nhận ra hành trình lắng nghe trái tim mới là phần thưởng lớn nhất.'),
    ('9786040000026', N'Dale Carnegie chỉ ra nghệ thuật giao tiếp bằng sự chân thành: biết lắng nghe, tôn trọng người khác và khơi dậy thiện chí thay vì tranh thắng trong mọi cuộc đối thoại.'),
    ('9786040000033', N'Rosie Nguyễn trò chuyện thẳng thắn với người trẻ về học, đi, đọc và trải nghiệm, nhắc rằng tuổi xuân chỉ có giá trị khi ta chủ động sống và tự chịu trách nhiệm.'),
    ('9786040000040', N'Những tản văn dí dỏm của Tony Buổi Sáng khuyến khích người trẻ rèn kỷ luật, mở rộng tầm mắt và bước khỏi vùng an toàn để trưởng thành bằng hành động.'),
    ('9786040000057', N'Từ trải nghiệm sống sót trong trại tập trung, Viktor Frankl lý giải vì sao con người vẫn có thể lựa chọn thái độ và tìm thấy ý nghĩa ngay giữa đau khổ cùng cực.'),
    ('9786040000064', N'Stephen Covey xây dựng bảy nguyên tắc phát triển từ bên trong, giúp người đọc sống chủ động, ưu tiên điều quan trọng và tạo dựng những mối quan hệ cùng thắng.'),
    ('9786040000071', N'Daniel Kahneman khám phá hai hệ thống chi phối tư duy, qua đó giải thích những thiên kiến khiến con người phán đoán nhanh, sai lệch và thường quá tự tin.'),
    ('9786040000088', N'Qua câu chuyện về hai người cha với hai quan niệm tiền bạc đối lập, Robert Kiyosaki giới thiệu tư duy tài sản, dòng tiền và giáo dục tài chính cá nhân.'),
    ('9786040000095', N'James Clear chứng minh thay đổi nhỏ nhưng đều đặn có thể tạo kết quả lớn, đồng thời đưa ra hệ thống thiết kế môi trường và bản sắc để duy trì thói quen tốt.'),
    ('9786040000101', N'Cal Newport bảo vệ năng lực tập trung sâu giữa thời đại xao nhãng và hướng dẫn cách tổ chức công việc để tạo ra giá trị cao trong thời gian hữu hạn.'),
    ('9786040000118', N'Carol Dweck phân biệt tư duy cố định với tư duy phát triển, cho thấy cách niềm tin về năng lực ảnh hưởng đến việc học, thành tích và khả năng đứng dậy sau thất bại.'),
    ('9786040000125', N'Morgan Housel kể những câu chuyện ngắn về lòng tham, rủi ro và sự đủ đầy, nhấn mạnh rằng thành công tài chính phụ thuộc vào hành vi hơn là kiến thức tính toán.'),
    ('9786040000132', N'Cuốn sách tìm hiểu ikigai của người Nhật—lý do khiến ta muốn thức dậy mỗi sáng—qua sự giao thoa giữa đam mê, năng lực, cộng đồng và nhịp sống bền vững.'),
    ('9786040000149', N'Greg McKeown đề xuất lối sống ít nhưng tốt hơn: chủ động loại bỏ điều không thiết yếu để dành năng lượng cho những đóng góp thực sự quan trọng.'),
    ('9786040000156', N'Eckhart Tolle dẫn người đọc trở về hiện tại, quan sát cái tôi và dòng suy nghĩ để thoát khỏi lo âu do quá khứ cùng tương lai tạo nên.'),
    ('9786040000163', N'Napoleon Hill tổng hợp những nguyên tắc về mục tiêu, niềm tin, quyết tâm và sức mạnh cộng tác nhằm biến khát vọng thành một kế hoạch hành động rõ ràng.'),
    ('9786040000170', N'Bản tiếng Anh của Đắc nhân tâm trình bày các nguyên tắc gây thiện cảm, thuyết phục và lãnh đạo bằng sự quan tâm chân thành đến nhu cầu của người khác.'),
    ('9786040000187', N'Robin Sharma kể câu chuyện thay đổi đời sống nhờ thói quen dậy sớm, kết hợp vận động, suy ngẫm và học hỏi trong giờ đầu tiên của ngày mới.'),
    ('9786040000194', N'Jake Knapp và John Zeratsky đưa ra các chiến thuật thực tế để chọn một ưu tiên mỗi ngày, giảm xao nhãng và tạo thêm thời gian cho điều đáng nhớ.'),
    ('9786040000200', N'Simon Sinek cho rằng tổ chức truyền cảm hứng luôn bắt đầu từ lý do tồn tại, trước khi nói đến cách làm hay sản phẩm họ bán.'),
    ('9786040000217', N'Peter Thiel bàn về những doanh nghiệp tạo bước nhảy từ không đến một bằng công nghệ độc quyền, tư duy khác biệt và khả năng xây dựng tương lai chưa từng có.'),
    ('9786040000224', N'Jim Collins phân tích vì sao một số công ty vượt từ tốt đến xuất sắc nhờ lãnh đạo khiêm nhường, đúng người và kỷ luật nhất quán.'),
    ('9786040000231', N'Eric Ries giới thiệu vòng lặp xây dựng–đo lường–học hỏi, giúp startup kiểm chứng giả định nhanh và tránh lãng phí nguồn lực vào sản phẩm không ai cần.'),
    ('9786040000248', N'Jason Fried và David Heinemeier Hansson thách thức các giáo điều kinh doanh quen thuộc, cổ vũ đội ngũ nhỏ, làm ít hơn và đưa sản phẩm ra thị trường sớm.'),
    ('9786040000255', N'Ben Horowitz kể thẳng về những quyết định cô độc của người điều hành khi công ty khủng hoảng, từ sa thải nhân sự đến giữ tổ chức sống sót.'),
    ('9786040000262', N'Robert C. Martin trình bày các nguyên tắc viết mã dễ đọc, dễ kiểm thử và dễ bảo trì qua những ví dụ cải tiến cụ thể.'),
    ('9786040000279', N'Cuốn sách xác định ranh giới và quy tắc phụ thuộc giúp kiến trúc phần mềm bảo vệ nghiệp vụ khỏi framework, giao diện và cơ sở dữ liệu.'),
    ('9786040000286', N'Một cẩm nang nghề nghiệp vượt thời gian về tư duy lập trình thực dụng, tự động hóa, kiểm thử, giao tiếp và trách nhiệm với sản phẩm.'),
    ('9786040000293', N'Bộ Gang of Four hệ thống hóa 23 mẫu thiết kế hướng đối tượng, cung cấp ngôn ngữ chung để giải quyết những cấu trúc phần mềm thường gặp.'),
    ('9786040000309', N'Martin Fowler hướng dẫn cải thiện cấu trúc mã hiện có từng bước nhỏ mà không làm thay đổi hành vi quan sát được của chương trình.'),
    ('9786040000316', N'Joshua Bloch cô đọng những thực hành Java hiệu quả về tạo đối tượng, generic, lambda, concurrency và thiết kế API an toàn.'),
    ('9786040000323', N'Java được giảng giải bằng hình ảnh, câu đố và dự án sinh động, giúp người mới hiểu đối tượng, kế thừa, exception và luồng thực thi.'),
    ('9786040000330', N'Tài liệu tham khảo toàn diện về ngôn ngữ Java, từ cú pháp nền tảng và thư viện chuẩn đến lập trình đa luồng, collections và tính năng hiện đại.'),
    ('9786040000347', N'Craig Walls hướng dẫn xây dựng ứng dụng Java với Spring thông qua dependency injection, web MVC, dữ liệu, bảo mật và tích hợp hệ thống.'),
    ('9786040000354', N'Cuốn sách tập trung vào cách Spring Boot đơn giản hóa cấu hình, đóng gói và triển khai các ứng dụng Spring sẵn sàng cho môi trường thực tế.'),
    ('9786040000361', N'Hướng dẫn thực hành React từ component, state và props đến quản lý dữ liệu, routing và xây dựng giao diện có thể tái sử dụng.'),
    ('9786040000378', N'React Quickly đưa người đọc đi nhanh từ JSX và component đến forms, lifecycle và kiến trúc ứng dụng phía khách qua các ví dụ trực tiếp.'),
    ('9786040000385', N'Một lộ trình xây dựng ứng dụng React hoàn chỉnh, kết nối các kỹ thuật component, state, dữ liệu bất đồng bộ và tổ chức dự án thực tế.'),
    ('9786040000392', N'Kyle Simpson đào sâu những cơ chế thường bị hiểu sai của JavaScript như scope, closure, this, prototype, kiểu dữ liệu và bất đồng bộ.'),
    ('9786040000408', N'Marijn Haverbeke dạy JavaScript thông qua tư duy giải bài toán và các dự án, từ ngôn ngữ cốt lõi đến trình duyệt cùng Node.js.'),
    ('9786040000415', N'Cẩm nang chuyên sâu bao quát JavaScript và nền tảng web, phù hợp để học có hệ thống lẫn tra cứu các API và đặc tính ngôn ngữ.'),
    ('9786040000422', N'Jon Duckett dùng bố cục trực quan để giải thích cấu trúc HTML và cách CSS kiểm soát màu sắc, chữ, hộp, bố cục cùng responsive.'),
    ('9786040000439', N'Lea Verou trình bày hàng chục kỹ thuật CSS thanh lịch cho nền, viền, hình dạng, typography và trải nghiệm người dùng mà không phụ thuộc plugin.'),
    ('9786040000446', N'Steve Krug giải thích nguyên tắc khả dụng cốt lõi: giao diện tốt phải tự nhiên, giảm suy nghĩ không cần thiết và được kiểm thử sớm với người dùng.'),
    ('9786040000453', N'The UX Book cung cấp quy trình thiết kế trải nghiệm từ nghiên cứu bối cảnh, mô hình hóa yêu cầu đến prototype, đánh giá và cải tiến sản phẩm.'),
    ('9786040000460', N'Giáo trình kinh điển phân tích thuật toán bằng chứng minh và độ phức tạp, bao quát sắp xếp, đồ thị, quy hoạch động cùng nhiều cấu trúc dữ liệu.'),
    ('9786040000477', N'Robert Sedgewick kết hợp lý thuyết với cài đặt thực tế để giải thích sắp xếp, tìm kiếm, cây, đồ thị và phân tích hiệu năng thuật toán.'),
    ('9786040000484', N'Cuốn sách trình bày nền tảng hệ quản trị cơ sở dữ liệu: mô hình quan hệ, SQL, thiết kế lược đồ, giao dịch, chỉ mục và xử lý truy vấn.'),
    ('9786040000491', N'Martin Kleppmann kết nối cơ sở dữ liệu, hệ phân tán và xử lý luồng để giải thích cách thiết kế hệ thống dữ liệu tin cậy, mở rộng được.'),
    ('9786040000507', N'Mạng máy tính được tiếp cận theo hướng từ ứng dụng xuống, làm rõ HTTP, vận chuyển, định tuyến, liên kết và bảo mật Internet.'),
    ('9786040000514', N'Giáo trình giải thích cách hệ điều hành quản lý tiến trình, bộ nhớ, lưu trữ, đồng bộ và bảo vệ tài nguyên phần cứng.'),
    ('9786040000521', N'Cuốn sách nối mã nguồn với phần cứng, giúp lập trình viên hiểu biểu diễn dữ liệu, assembly, bộ nhớ, linking và hiệu năng chương trình.'),
    ('9786040000538', N'Giáo trình AI toàn diện về tác tử thông minh, tìm kiếm, biểu diễn tri thức, xác suất, học máy, thị giác và xử lý ngôn ngữ.'),
    ('9786040000545', N'Ian Goodfellow cùng cộng sự hệ thống hóa nền tảng toán học, mạng sâu, tối ưu và các hướng nghiên cứu quan trọng của deep learning.'),
    ('9786040000552', N'Aurélien Géron hướng dẫn xây dựng mô hình học máy bằng Scikit-Learn, Keras và TensorFlow qua quy trình cùng dự án thực hành.'),
    ('9786040000569', N'Lộ trình nhập môn Python rõ ràng với bài tập và dự án về trò chơi, trực quan hóa dữ liệu cùng ứng dụng web.'),
    ('9786040000576', N'Al Sweigart dùng Python để tự động hóa các việc lặp lại như xử lý tệp, bảng tính, PDF, email và dữ liệu web.'),
    ('9786040000583', N'Luciano Ramalho khai thác sức mạnh riêng của Python qua data model, iterator, decorator, typing, concurrency và metaprogramming.'),
    ('9786040000590', N'Brett Slatkin trình bày các mục thực hành ngắn giúp viết Python rõ ràng, hiệu quả và đúng tinh thần của ngôn ngữ.'),
    ('9786040000606', N'Mark Lutz cung cấp nền tảng Python chi tiết, từ kiểu dữ liệu và hàm đến module, lớp, exception cùng các công cụ nâng cao.'),
    ('9786040000613', N'Qua phiên tòa của một người da đen bị vu oan, Harper Lee nhìn nạn phân biệt chủng tộc và lòng can đảm bằng đôi mắt trẻ thơ.'),
    ('9786040000620', N'Winston Smith sống dưới chế độ toàn trị kiểm soát lịch sử, ngôn ngữ và cả suy nghĩ; cuộc phản kháng riêng tư của anh dần trở thành bi kịch.'),
    ('9786040000637', N'Cuộc nổi dậy của đàn vật chống chủ trang trại biến thành một nền chuyên chế mới, phơi bày cách lý tưởng bị quyền lực bóp méo.'),
    ('9786040000644', N'Giấc mơ giàu sang của Jay Gatsby xoay quanh tình yêu đã mất, phản chiếu vẻ hào nhoáng và khoảng trống của nước Mỹ thời Jazz.'),
    ('9786040000651', N'Elizabeth Bennet và Mr. Darcy phải vượt qua thành kiến, kiêu hãnh cùng áp lực hôn nhân để nhận ra giá trị thật của nhau.'),
    ('9786040000668', N'Holden Caulfield lang thang qua New York sau khi bị đuổi học, vừa chống lại sự giả tạo vừa che giấu nỗi cô độc của tuổi trưởng thành.'),
    ('9786040000675', N'Bilbo Baggins rời căn nhà tiện nghi để cùng đoàn người lùn giành lại quê hương, đối mặt troll, goblin và rồng Smaug.'),
    ('9786040000682', N'Frodo mang Chiếc Nhẫn Quyền Lực đến Núi Doom trong thiên sử thi về tình bạn, cám dỗ và cuộc chiến chống bóng tối Trung Địa.'),
    ('9786040000699', N'Harry bước vào Hogwarts, khám phá phép thuật và tình bạn, đồng thời chạm trán bí mật về cha mẹ cùng kẻ đã để lại vết sẹo trên trán mình.'),
    ('9786040000705', N'Một thế lực bí ẩn hóa đá học sinh Hogwarts, buộc Harry lần theo truyền thuyết Phòng chứa Bí mật và người thừa kế Slytherin.'),
    ('9786040000712', N'Kẻ vượt ngục Sirius Black dường như đang săn Harry, nhưng sự thật về đêm cha mẹ cậu bị phản bội phức tạp hơn mọi lời đồn.'),
    ('9786040000729', N'Harry bất ngờ bị chọn dự Tam Pháp Thuật, trải qua ba thử thách chết người trước khi chứng kiến Voldemort trở lại.'),
    ('9786040000736', N'Bị Bộ Pháp thuật phủ nhận và Dolores Umbridge đàn áp, Harry lập Đội quân Dumbledore để chuẩn bị cho cuộc chiến đang đến.'),
    ('9786040000743', N'Khi chiến tranh lan tới Hogwarts, Harry khám phá quá khứ Voldemort và nhận được sự giúp đỡ bí ẩn từ cuốn sách của Hoàng tử Lai.'),
    ('9786040000750', N'Harry, Ron và Hermione rời trường để săn Trường Sinh Linh Giá, tiến tới cuộc đối đầu cuối cùng quyết định số phận thế giới phù thủy.'),
    ('9786040000767', N'Hoàng tử bé rời tiểu hành tinh của mình, gặp những người lớn kỳ lạ và học từ cáo về tình bạn, trách nhiệm cùng điều mắt thường không thấy.'),
    ('9786040000774', N'Ông lão Santiago một mình vật lộn với con cá kiếm khổng lồ giữa biển, giữ vững phẩm giá dù chiến thắng bị thiên nhiên lấy lại.'),
    ('9786040000781', N'Phiên bản tiếng Anh kể hành trình Santiago theo đuổi kho báu và học cách đọc những dấu hiệu dẫn mình tới vận mệnh riêng.'),
    ('9786040000798', N'Hai người phụ nữ trẻ gặp nhau sau mất mát, cùng tìm sự chữa lành trong căn bếp, tình bạn và những nhịp sống mong manh ở Tokyo.'),
    ('9786040000804', N'Cậu thiếu niên Kafka bỏ nhà đi trong khi ông lão Nakata trò chuyện với mèo; hai hành trình siêu thực dần giao nhau qua định mệnh.'),
    ('9786040000811', N'Bảy thế hệ nhà Buendía sống giữa phép màu, chiến tranh và cô độc ở Macondo, lặp lại những khát vọng cùng sai lầm của tổ tiên.'),
    ('9786040000828', N'Florentino chờ hơn nửa thế kỷ để trở lại với Fermina, trong thiên tình sử về tuổi già, ký ức và nhiều hình dạng của tình yêu.'),
    ('9786040000835', N'Amir trở về Afghanistan để chuộc lỗi vì đã phản bội Hassan thuở nhỏ, đối diện tình bạn, chiến tranh và bí mật gia đình.'),
    ('9786040000842', N'Mariam và Laila, hai phụ nữ khác thế hệ, nương tựa nhau để sống sót qua bạo lực gia đình và chiến tranh tại Afghanistan.'),
    ('9786040000859', N'Cô bé Liesel ăn cắp sách giữa nước Đức Quốc xã, tìm nơi trú ẩn trong ngôn từ khi Tử thần chứng kiến chiến tranh cướp đi mọi điều thân thuộc.'),
    ('9786040000866', N'Pi Patel mắc kẹt trên xuồng cứu sinh với một con hổ Bengal, biến cuộc sinh tồn thành suy tưởng về đức tin và bản chất của sự thật.'),
    ('9786040000873', N'Hai cha con đi qua nước Mỹ hậu tận thế, bảo vệ chút lòng nhân còn lại giữa đói rét, bạo lực và tro tàn.'),
    ('9786040000880', N'Bị bỏ lại trên Sao Hỏa, phi hành gia Mark Watney dùng khoa học, óc hài hước và ý chí để sống sót cho tới ngày được giải cứu.'),
    ('9786040000897', N'Ryland Grace tỉnh dậy một mình ngoài không gian và phải giải bài toán tuyệt chủng của Mặt Trời, với sự trợ giúp từ một người bạn ngoài hành tinh.'),
    ('9786040000903', N'Paul Atreides bước vào cuộc tranh giành hành tinh sa mạc Arrakis, nơi gia vị, tôn giáo, sinh thái và quyền lực gắn chặt với nhau.'),
    ('9786040000910', N'Trong xã hội nơi lính cứu hỏa đốt sách, Guy Montag bắt đầu nghi ngờ công việc của mình và tìm lại tự do trong tri thức bị cấm.'),
    ('9786040000927', N'Một thế giới được ổn định bằng sinh sản công nghiệp, điều kiện hóa và khoái lạc hóa học bị thách thức bởi một người lớn lên ngoài hệ thống.'),
    ('9786040000934', N'Offred bị biến thành công cụ sinh sản dưới chế độ Gilead, âm thầm giữ ký ức và ý chí sống trong một xã hội tước quyền phụ nữ.'),
    ('9786040000941', N'Katniss Everdeen tình nguyện bước vào đấu trường sinh tử để cứu em gái và vô tình trở thành biểu tượng thách thức Capitol.'),
    ('9786040000958', N'Sau chiến thắng, Katniss và Peeta bị kéo trở lại đấu trường trong khi các quận bắt đầu nổi dậy dưới biểu tượng Húng Nhại.'),
    ('9786040000965', N'Katniss trở thành gương mặt của cuộc cách mạng nhưng phải đối diện tuyên truyền, tổn thất và tham vọng quyền lực từ cả hai phía.'),
    ('9786040000972', N'Hazel và Augustus gặp nhau trong nhóm hỗ trợ bệnh nhân ung thư, cùng trải nghiệm một tình yêu ngắn ngủi nhưng làm thay đổi cách họ nhìn sự sống.'),
    ('9786040000989', N'Louisa Clark chăm sóc Will Traynor sau tai nạn và dần yêu anh, nhưng phải tôn trọng lựa chọn khó khăn của một con người muốn tự quyết cuộc đời.'),
    ('9786040000996', N'Noah và Allie yêu nhau bất chấp khác biệt giai cấp; nhiều thập kỷ sau, câu chuyện của họ được kể lại để chống chọi với sự phai mờ ký ức.'),
    ('9786040001009', N'Ông Ove cáu kỉnh liên tục bị hàng xóm mới phá hỏng kế hoạch tự sát, rồi bất ngờ tìm lại cộng đồng và lý do để sống.'),
    ('9786040001016', N'Tara Westover lớn lên trong gia đình biệt lập không trường học, tự mở đường vào đại học và trả giá cho quyền định nghĩa chính mình.'),
    ('9786040001023', N'Michelle Obama kể hành trình từ khu South Side đến Nhà Trắng, suy ngẫm về gia đình, nghề nghiệp, chủng tộc và đời sống công chúng.'),
    ('9786040001030', N'Walter Isaacson dựng chân dung Steve Jobs từ hàng chục cuộc phỏng vấn, cho thấy sự giao thoa giữa tầm nhìn sản phẩm, ám ảnh hoàn hảo và tính cách gai góc.'),
    ('9786040001047', N'Tiểu sử theo dấu Elon Musk từ tuổi thơ đến SpaceX và Tesla, khám phá tham vọng công nghệ, khả năng chấp nhận rủi ro cùng phong cách lãnh đạo gây tranh cãi.'),
    ('9786040001054', N'Yuval Noah Harari kể hành trình Homo sapiens từ loài động vật vô danh đến kẻ thống trị hành tinh nhờ ngôn ngữ, hợp tác và những trật tự tưởng tượng.'),
    ('9786040001061', N'Harari suy đoán tương lai khi con người dùng công nghệ để theo đuổi bất tử, hạnh phúc và quyền năng gần như thần thánh.'),
    ('9786040001078', N'Hai mươi mốt bài luận xem xét các thách thức hiện tại như AI, chủ nghĩa dân tộc, tin giả, giáo dục và khả năng giữ bình tâm.'),
    ('9786040001085', N'Jared Diamond lý giải vì sao các xã hội phát triển khác nhau qua địa lý, cây trồng, vật nuôi, mầm bệnh và công nghệ thay vì khác biệt chủng tộc.'),
    ('9786040001092', N'Stephen Hawking giải thích Big Bang, hố đen, thời gian và nỗ lực tìm một lý thuyết thống nhất bằng ngôn ngữ dành cho độc giả phổ thông.'),
    ('9786040001108', N'Carl Sagan đưa người đọc du hành từ thế giới vi mô đến các thiên hà, kết nối lịch sử khoa học với vị trí nhỏ bé của nhân loại trong vũ trụ.'),
    ('9786040001115', N'Neil deGrasse Tyson cô đọng các ý niệm lớn của vật lý thiên văn—vật chất tối, năng lượng tối và vũ trụ giãn nở—thành những chương ngắn dễ tiếp cận.'),
    ('9786040001122', N'Richard Dawkins nhìn tiến hóa từ cấp độ gene, giải thích chọn lọc tự nhiên, cạnh tranh, hợp tác và nguồn gốc của hành vi vị tha.'),
    ('9786040001139', N'Siddhartha Mukherjee kể lịch sử khoa học về gene từ Mendel đến kỹ thuật chỉnh sửa, đồng thời đặt câu hỏi về di truyền và bản sắc.'),
    ('9786040001146', N'Rachel Carson phơi bày tác hại của thuốc trừ sâu đối với hệ sinh thái, khởi nguồn cho ý thức môi trường hiện đại và yêu cầu quản lý hóa chất có trách nhiệm.'),
    ('9786040001153', N'Câu chuyện Henrietta Lacks nối những tế bào HeLa bất tử với đột phá y học, bất công chủng tộc và câu hỏi đạo đức về quyền sở hữu mô người.'),
    ('9786040001160', N'Matthew Walker tổng hợp khoa học giấc ngủ để giải thích tác động của ngủ đủ lên trí nhớ, cảm xúc, miễn dịch và sức khỏe lâu dài.'),
    ('9786040001177', N'Donella Meadows dạy cách nhìn vòng phản hồi, độ trễ và điểm đòn bẩy để hiểu vì sao các hệ thống phức tạp thường chống lại giải pháp đơn giản.'),
    ('9786040001184', N'Hans Rosling dùng dữ liệu để sửa những ngộ nhận bi quan về thế giới và chỉ ra các bản năng khiến con người đánh giá sai tiến bộ toàn cầu.'),
    ('9786040001191', N'Malcolm Gladwell nhìn thành công qua cơ hội, văn hóa, thời điểm và quá trình luyện tập, thay vì chỉ xem đó là kết quả của tài năng cá nhân.'),
    ('9786040001207', N'Gladwell khám phá sức mạnh và giới hạn của phán đoán chớp nhoáng, khi kinh nghiệm vô thức có thể tạo trực giác xuất sắc hoặc thiên kiến nguy hiểm.'),
    ('9786040001214', N'Cuốn sách phân tích khoảnh khắc một ý tưởng hay hành vi lan truyền như dịch bệnh, nhờ người kết nối, thông điệp dễ nhớ và bối cảnh phù hợp.'),
    ('9786040001221', N'Qua những kẻ yếu thế chiến thắng nghịch cảnh, Gladwell đặt lại câu hỏi liệu bất lợi luôn là điểm yếu và quyền lực luôn mang lại ưu thế.'),
    ('9786040001238', N'Angela Duckworth cho rằng thành tựu dài hạn đến từ sự kết hợp giữa đam mê bền bỉ và nỗ lực có định hướng, không chỉ từ năng khiếu.'),
    ('9786040001245', N'Daniel Pink chỉ ra động lực tốt cho công việc sáng tạo nằm ở quyền tự chủ, mong muốn tinh thông và cảm giác đóng góp cho mục đích lớn hơn.'),
    ('9786040001252', N'Simon Sinek lý giải vì sao lãnh đạo biết bảo vệ và đặt đội ngũ lên trước sẽ tạo niềm tin, hợp tác cùng hiệu suất bền vững.'),
    ('9786040001269', N'Brené Brown biến lòng can đảm thành các kỹ năng lãnh đạo cụ thể: đối diện sự dễ tổn thương, trò chuyện khó và xây dựng văn hóa tin cậy.'),
    ('9786040001276', N'Vex King kết hợp trải nghiệm cá nhân với thực hành yêu bản thân, đặt ranh giới và nuôi dưỡng suy nghĩ tích cực mà không phủ nhận khó khăn.'),
    ('9786040001283', N'Mark Manson dùng giọng văn thẳng và hài hước để khuyên người đọc chọn điều đáng quan tâm, chấp nhận giới hạn và chịu trách nhiệm với lựa chọn.'),
    ('9786040001290', N'Marie Forleo khuyến khích thay câu “tôi không biết” bằng tinh thần luôn tìm được cách, rồi chuyển nỗi sợ thành bước hành động cụ thể.'),
    ('9786040001306', N'Brianna Wiest xem hành vi tự phá hoại như tín hiệu của nhu cầu chưa được giải quyết và hướng dẫn biến trở lực nội tâm thành sự trưởng thành.'),
    ('9786040001313', N'Amir Levine và Rachel Heller giải thích các kiểu gắn bó an toàn, lo âu, né tránh cùng ảnh hưởng của chúng đến lựa chọn và xung đột tình cảm.'),
    ('9786040001320', N'Brené Brown mời người đọc từ bỏ áp lực hoàn hảo, chấp nhận sự dễ tổn thương và sống toàn tâm bằng lòng can đảm cùng sự tự cảm thông.'),
    ('9786040001337', N'Qua đối thoại giữa một triết gia và chàng thanh niên, cuốn sách diễn giải tâm lý học Adler về tự do, trách nhiệm và can đảm không sống theo kỳ vọng.'),
    ('9786040001344', N'Bản tiếng Anh hồi ký của Viktor Frankl kết hợp trải nghiệm trại tập trung với liệu pháp ý nghĩa, khẳng định con người vẫn tự do lựa chọn thái độ.'),
    ('9786040001351', N'Những ghi chép riêng của Marcus Aurelius về bổn phận, lý trí và sự vô thường trở thành cẩm nang thực hành chủ nghĩa Khắc kỷ.'),
    ('9786040001368', N'Tôn Tử trình bày nghệ thuật chiến thắng bằng hiểu mình, hiểu đối phương, tính toán thế trận và hạn chế tổn thất không cần thiết.'),
    ('9786040001375', N'Qua những bức thư gửi Lucilius, Seneca suy ngẫm về thời gian, cái chết, tình bạn, giàu nghèo và cách giữ tâm trí tự do.'),
    ('9786040001382', N'Plato dùng cuộc đối thoại về công lý để xây dựng mô hình nhà nước lý tưởng, bàn về giáo dục, quyền lực và bản chất của tri thức.'),
    ('9786040001399', N'Nietzsche chất vấn đạo đức truyền thống, tôn giáo và ảo tưởng về chân lý, mở đường cho một cách tự đánh giá giá trị táo bạo hơn.'),
    ('9786040001405', N'Nhà tiên tri Zarathustra trở xuống núi để giảng về siêu nhân, ý chí quyền lực và hành trình vượt qua chính mình bằng văn phong thi ca.'),
    ('9786040001412', N'Raskolnikov sát hại một bà cầm đồ để thử học thuyết của mình, rồi bị tội lỗi, tình thương và cuộc điều tra dồn tới ngưỡng sụp đổ.'),
    ('9786040001429', N'Ba anh em Karamazov bị cuốn vào vụ sát hại người cha, mở ra cuộc tranh luận lớn về đức tin, tự do, tội lỗi và trách nhiệm.'),
    ('9786040001436', N'Anna mắc kẹt giữa tình yêu với Vronsky và chuẩn mực quý tộc Nga, trong khi câu chuyện Levin tìm kiếm một đời sống có ý nghĩa song hành.'),
    ('9786040001443', N'Giữa cuộc chiến Nga–Napoléon, số phận nhiều gia đình quý tộc đan xen trong thiên sử thi về lịch sử, tình yêu và ý chí cá nhân.'),
    ('9786040001450', N'Jean Valjean tìm cách sống lương thiện nhưng luôn bị Javert truy đuổi, giữa bức tranh nước Pháp đầy nghèo đói, cách mạng và lòng bao dung.'),
    ('9786040001467', N'Edmond Dantès bị vu oan và cầm tù, trở lại với thân phận Bá tước Monte Cristo để thực hiện kế hoạch báo thù tinh vi.'),
    ('9786040001474', N'Dorian Gray giữ mãi vẻ trẻ trung trong khi bức chân dung gánh mọi dấu vết sa đọa, phơi bày cái giá của khoái lạc và phù phiếm.'),
    ('9786040001481', N'Những thư từ và nhật ký ghép lại cuộc săn Bá tước Dracula, sinh vật gieo kinh hoàng từ Transylvania đến nước Anh.'),
    ('9786040001498', N'Victor Frankenstein tạo ra sự sống rồi ruồng bỏ sinh vật của mình, dẫn tới chuỗi bi kịch về cô độc, định kiến và trách nhiệm khoa học.'),
    ('9786040001504', N'Bác sĩ Jekyll tách phần bản năng thành nhân dạng Hyde, nhưng thí nghiệm dần giải phóng một cái ác không còn kiểm soát được.'),
    ('9786040001511', N'Phileas Fogg đánh cược rằng có thể vòng quanh thế giới trong tám mươi ngày, lao vào cuộc đua đầy sự cố cùng người hầu Passepartout.'),
    ('9786040001528', N'Giáo sư Aronnax lên tàu ngầm Nautilus của thuyền trưởng Nemo, khám phá kỳ quan đại dương và bí mật của con người chối bỏ đất liền.'),
    ('9786040001535', N'Giáo sư Lidenbrock giải mã bản thảo cổ rồi dẫn đoàn thám hiểm xuyên lòng đất, gặp biển ngầm, sinh vật tiền sử và hiểm họa địa chất.'),
    ('9786040001542', N'Mười hai vụ án giới thiệu tài quan sát của Sherlock Holmes và lối kể tỉnh táo của bác sĩ Watson tại London thời Victoria.'),
    ('9786040001559', N'Một truyền thuyết chó săn ma ám gia tộc Baskerville, nhưng Holmes nghi ngờ phía sau nỗi sợ siêu nhiên là âm mưu của con người.'),
    ('9786040001566', N'Hercule Poirot điều tra một vụ giết người trên chuyến tàu mắc kẹt trong tuyết, nơi mọi hành khách đều có bí mật và chứng cứ ngoại phạm.'),
    ('9786040001573', N'Mười người lạ bị mời ra đảo rồi lần lượt chết theo một bài đồng dao, trong khi hung thủ dường như không thể là người ngoài.'),
    ('9786040001580', N'Poirot điều tra cái chết của Roger Ackroyd qua lời kể của bác sĩ Sheppard, dẫn tới một trong những cú lật nổi tiếng nhất trinh thám.'),
    ('9786040001597', N'Nhà báo Mikael Blomkvist và hacker Lisbeth Salander cùng điều tra vụ mất tích kéo dài nhiều thập kỷ trong một gia đình công nghiệp quyền lực.'),
    ('9786040001603', N'Khi Amy biến mất đúng dịp kỷ niệm cưới, Nick trở thành nghi phạm và cuộc hôn nhân của họ lộ ra như một trò thao túng đầy độc hại.'),
    ('9786040001610', N'Họa sĩ Alicia im lặng sau khi bắn chồng; nhà trị liệu Theo quyết giải mã sự câm lặng ấy và bước vào chiếc bẫy của chính mình.'),
    ('9786040001627', N'Robert Langdon lần theo mật mã trong tác phẩm Leonardo da Vinci để khám phá bí mật tôn giáo mà một hội kín bảo vệ suốt nhiều thế kỷ.'),
    ('9786040001634', N'Một biểu tượng học chạy đua khắp Rome để ngăn âm mưu Illuminati, lần theo bốn bàn thờ khoa học trước khi Vatican bị hủy diệt.'),
    ('9786040001641', N'Robert Langdon tỉnh dậy mất trí nhớ tại Florence và lao vào cuộc truy tìm liên quan Dante, dịch bệnh cùng một kế hoạch kiểm soát dân số.'),
    ('9786040001658', N'Nhà giải mã Susan Fletcher phát hiện siêu máy tính NSA bị một thuật toán bất khả phá đe dọa, kéo cô vào cuộc đấu về bí mật và quyền riêng tư.'),
    ('9786040001665', N'Jack Torrance đưa gia đình đến trông khách sạn Overlook mùa đông, nơi sự cô lập và thế lực tà ác khai thác cơn nghiện cùng bạo lực trong anh.'),
    ('9786040001672', N'Một nhóm bạn trở về Derry sau hai mươi bảy năm để đối mặt thực thể đội lốt chú hề và nỗi kinh hoàng từng ám tuổi thơ họ.'),
    ('9786040001689', N'Nhà văn Paul Sheldon bị người hâm mộ Annie Wilkes giam giữ và ép viết lại nhân vật yêu thích, biến sáng tác thành cuộc đấu sinh tồn.'),
    ('9786040001696', N'Louis Creed chôn con mèo rồi con trai tại nghĩa địa có quyền năng hồi sinh, để rồi nhận ra cái chết đôi khi là ranh giới không nên vượt qua.'),
    ('9786040001702', N'Quản giáo Paul Edgecombe nhớ lại tử tù John Coffey, người có năng lực chữa lành kỳ lạ giữa sự tàn nhẫn của hành lang tử hình.'),
    ('9786040001719', N'Bảy truyện ngắn của Haruki Murakami khắc họa những người đàn ông cô độc sau chia lìa, trôi giữa ký ức, âm nhạc và khoảng trống khó gọi tên.'),
    ('9786040001726', N'Tsukuru bị nhóm bạn thân đột ngột ruồng bỏ; nhiều năm sau anh trở lại tìm nguyên nhân để hàn gắn phần bản sắc đã mất.'),
    ('9786040001733', N'Toru Okada tìm con mèo rồi người vợ mất tích, bước qua giếng cạn, ký ức chiến tranh và những lớp hiện thực kỳ dị.'),
    ('9786040001740', N'Dế Mèn kiêu căng gây nên cái chết của Dế Choắt rồi lên đường phiêu lưu, trưởng thành qua tình bạn, hiểm nguy và khát vọng hòa bình.'),
    ('9786040001757', N'Nguyễn Nhật Ánh đưa người lớn trở lại thế giới trẻ thơ, nơi bốn đứa trẻ đặt lại tên cho vạn vật và nhìn cuộc sống bằng trí tưởng tượng trong veo.'),
    ('9786040001764', N'Tình yêu đơn phương của Ngạn dành cho Hà Lan kéo dài từ làng Đo Đo đến thành phố, đẹp đẽ nhưng nhuốm nỗi buồn của những lựa chọn lệch nhau.'),
    ('9786040001771', N'Tuổi thơ của Thiều và Tường hiện lên giữa làng quê nghèo, với tình anh em, ghen tị, lỗi lầm và những rung động đầu đời.'),
    ('9786040001788', N'Anh chàng vụng về hồi tưởng mối tình học trò với cô bạn Tiểu Li, để rồi bất ngờ gặp lại “cô gái đến từ hôm qua” trong hiện tại.'),
    ('9786040001795', N'Đông gặp Rùa trong một miền quê yên bình; tình cảm non trẻ của họ bị thử thách bởi bí mật gia đình và những định kiến của người lớn.'),
    ('9786040001801', N'Tèo, một cậu bé chịu nhiều thiệt thòi nhưng luôn nhân hậu, khiến những người quanh mình học lại cách yêu thương và nhìn bầu trời bằng hy vọng.'),
    ('9786040001818', N'Bản dịch Việt của The Catcher in the Rye theo chân Holden Caulfield chống lại sự giả tạo trong khi âm thầm vật lộn với mất mát và cô độc.'),
    ('9786040001825', N'Một cậu bé học cách cảm nhận khu vườn bằng mùi hương, âm thanh và bàn tay, qua những bài học dịu dàng từ người cha cùng cô bé hàng xóm.'),
    ('9786040001832', N'Vũ Bằng viết mười hai tháng Bắc Việt bằng nỗi nhớ của người xa xứ, gợi lại mùa màng, món ăn và phong vị Hà Nội cũ.'),
    ('9786040001849', N'Mười một truyện của Nguyễn Tuân phục dựng vẻ đẹp tài hoa của những con người cuối thời Nho học, khi một nền văn hóa đang lui vào dĩ vãng.'),
    ('9786040001856', N'Xuân Tóc Đỏ tình cờ leo lên thượng lưu Hà Nội thuộc địa, qua đó Vũ Trọng Phụng châm biếm phong trào Âu hóa và xã hội trưởng giả lố lăng.'),
    ('9786040001863', N'Chí Phèo từ người nông dân lương thiện bị đẩy thành kẻ lưu manh, rồi khát khao làm người trở lại nhờ tình thương của Thị Nở.'),
    ('9786040001870', N'Chị Dậu chạy vạy cứu chồng giữa sưu thuế hà khắc, phơi bày cảnh bần cùng và sức phản kháng của người phụ nữ nông dân.'),
    ('9786040001887', N'Lão Hạc bán cậu Vàng rồi chọn cái chết để giữ mảnh vườn cho con, trong câu chuyện đau xót về nghèo đói và lòng tự trọng.'),
    ('9786040001894', N'Nguyên Hồng kể tuổi thơ thiếu thốn tình cha, xa mẹ và chịu nhiều cay nghiệt, nhưng vẫn giữ một tình yêu mẹ mãnh liệt.'),
    ('9786040001900', N'Những truyện ngắn Thạch Lam ghi lại rung động mong manh trước trẻ nghèo, người lao động và các khoảnh khắc giao mùa của đời sống bình dị.'),
    ('9786040001917', N'Liên và An ngồi bên phố huyện nghèo chờ chuyến tàu đêm, mang theo ánh sáng thoáng qua giữa cuộc sống quẩn quanh, tĩnh lặng.'),
    ('9786040001924', N'Giữa nạn đói, Tràng “nhặt” được vợ chỉ bằng vài bát bánh đúc; gia đình mới nhen lên hy vọng sống trong hoàn cảnh bi thảm.'),
    ('9786040001931', N'Rừng xà nu và dân làng Xô Man chứng kiến hành trình Tnú từ đau thương riêng đến ý thức cầm vũ khí bảo vệ cộng đồng.'),
    ('9786040001948', N'Cậu bé An lưu lạc khắp miền Tây Nam Bộ thời kháng chiến, kết bạn với những con người hào sảng giữa thiên nhiên sông nước phong phú.'),
    ('9786040001955', N'Kiên trở về sau chiến tranh nhưng bị ký ức đồng đội và tình yêu ám ảnh, viết để đối diện những mất mát không thể khép lại.'),
    ('9786040001962', N'Phần tiếp nối mở rộng những chuyến đi của Dế Mèn, tiếp tục bài học về đoàn kết, trách nhiệm và khát vọng chung sống hòa bình.'),
    ('9786040001979', N'Bản tiếng Việt tác phẩm của Stephen Hawking dẫn nhập Big Bang, hố đen và bản chất thời gian bằng những câu hỏi lớn nhưng dễ tiếp cận.'),
    ('9786040001986', N'Qua ghi chép về các bậc đạo sư Ấn Độ, cuốn sách dẫn người đọc khảo sát đời sống tinh thần, nghiệp quả và sự hòa hợp giữa Đông với Tây.'),
    ('9786040001993', N'Charles Duhigg phân tích vòng lặp tín hiệu–thói quen–phần thưởng và cho thấy cá nhân lẫn tổ chức có thể thay đổi hành vi bằng cách tác động đúng mắt xích.'),
    ('9786040002006', N'Napoleon Hill trình bày bảy nguyên tắc về mục tiêu, kỷ luật, hợp tác và tư duy tích cực nhằm xây dựng nền tảng thành công lâu dài.');

    UPDATE b
    SET b.description = CONCAT(
        d.description,
        N' Tác phẩm do ', COALESCE(a.author_name, N'tác giả khuyết danh'),
        N' viết; ấn bản ', COALESCE(CONVERT(NVARCHAR(4), b.publish_year), N'không ghi năm'),
        N' có ', COALESCE(CONVERT(NVARCHAR(10), b.pages), N'nhiều'), N' trang',
        CASE WHEN NULLIF(b.language, N'') IS NOT NULL THEN CONCAT(N', trình bày bằng ', LOWER(b.language)) ELSE N'' END,
        CASE WHEN p.publisher_name IS NOT NULL THEN CONCAT(N' và do ', p.publisher_name, N' phát hành.') ELSE N'.' END
    )
    FROM Books b
    JOIN @BookDescriptions d ON d.isbn = b.isbn
    LEFT JOIN Authors a ON a.author_id = b.author_id
    LEFT JOIN Publishers p ON p.publisher_id = b.publisher_id;
    GO

    -- ============================================
    -- 11) UPDATE shelf_location cho 29 ban sao GOC
    -- ============================================
    -- ============================================
    UPDATE BookCopies SET shelf_location = N'KD-01' WHERE barcode = 'BC000001';
    UPDATE BookCopies SET shelf_location = N'KD-02' WHERE barcode = 'BC000002';
    UPDATE BookCopies SET shelf_location = N'KNS-01' WHERE barcode = 'BC000003';
    UPDATE BookCopies SET shelf_location = N'KNS-02' WHERE barcode = 'BC000004';
    UPDATE BookCopies SET shelf_location = N'KNS-03' WHERE barcode = 'BC000005';
    UPDATE BookCopies SET shelf_location = N'PG-01' WHERE barcode = 'BC000006';
    UPDATE BookCopies SET shelf_location = N'TTH-01' WHERE barcode = 'BC000007';
    UPDATE BookCopies SET shelf_location = N'HK-01' WHERE barcode = 'BC000008';
    UPDATE BookCopies SET shelf_location = N'TTH-02' WHERE barcode = 'BC000009';
    UPDATE BookCopies SET shelf_location = N'FT-01' WHERE barcode = 'BC000010';
    UPDATE BookCopies SET shelf_location = N'CN-01' WHERE barcode = 'BC000011';
    UPDATE BookCopies SET shelf_location = N'KD-03' WHERE barcode = 'BC000012';
    UPDATE BookCopies SET shelf_location = N'KD-04' WHERE barcode = 'BC000013';
    UPDATE BookCopies SET shelf_location = N'KNS-04' WHERE barcode = 'BC000014';
    UPDATE BookCopies SET shelf_location = N'KNS-05' WHERE barcode = 'BC000015';
    UPDATE BookCopies SET shelf_location = N'KNS-06' WHERE barcode = 'BC000016';
    UPDATE BookCopies SET shelf_location = N'KNS-07' WHERE barcode = 'BC000017';
    UPDATE BookCopies SET shelf_location = N'PG-02' WHERE barcode = 'BC000018';
    UPDATE BookCopies SET shelf_location = N'PG-03' WHERE barcode = 'BC000019';
    UPDATE BookCopies SET shelf_location = N'TTH-03' WHERE barcode = 'BC000020';
    UPDATE BookCopies SET shelf_location = N'TTH-04' WHERE barcode = 'BC000021';
    UPDATE BookCopies SET shelf_location = N'HK-02' WHERE barcode = 'BC000022';
    UPDATE BookCopies SET shelf_location = N'HK-03' WHERE barcode = 'BC000023';
    UPDATE BookCopies SET shelf_location = N'TTH-05' WHERE barcode = 'BC000024';
    UPDATE BookCopies SET shelf_location = N'TTH-06' WHERE barcode = 'BC000025';
    UPDATE BookCopies SET shelf_location = N'FT-02' WHERE barcode = 'BC000026';
    UPDATE BookCopies SET shelf_location = N'FT-03' WHERE barcode = 'BC000027';
    UPDATE BookCopies SET shelf_location = N'CN-02' WHERE barcode = 'BC000028';
    UPDATE BookCopies SET shelf_location = N'CN-03' WHERE barcode = 'BC000029';
    GO
    -- ============================================
    -- 12) INSERT 402 ban sao cho 201 sach moi
    -- ============================================
    INSERT INTO BookCopies (book_id, barcode, shelf_location, status, acquired_date)
    VALUES
        ((SELECT book_id FROM Books WHERE isbn = '9786040000001'), 'BC000030', N'KNS-08', 'Available', '2026-08-07'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000001'), 'BC000031', N'KNS-08', 'Available', '2026-08-07'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000019'), 'BC000032', N'TTH-07', 'Available', '2026-08-07'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000019'), 'BC000033', N'TTH-07', 'Available', '2026-08-07'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000026'), 'BC000034', N'KNS-09', 'Available', '2026-08-07'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000026'), 'BC000035', N'KNS-09', 'Available', '2026-08-07'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000033'), 'BC000036', N'KNS-10', 'Available', '2026-08-07'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000033'), 'BC000037', N'KNS-10', 'Available', '2026-08-07'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000040'), 'BC000038', N'KNS-11', 'Available', '2026-08-07'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000040'), 'BC000039', N'KNS-11', 'Available', '2026-08-07'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000057'), 'BC000040', N'HK-04', 'Available', '2026-08-07'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000057'), 'BC000041', N'HK-04', 'Available', '2026-08-07'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000064'), 'BC000042', N'KNS-12', 'Available', '2026-08-07'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000064'), 'BC000043', N'KNS-12', 'Available', '2026-08-07'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000071'), 'BC000044', N'TL-01', 'Available', '2026-08-07'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000071'), 'BC000045', N'TL-01', 'Available', '2026-08-07'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000088'), 'BC000046', N'KD-05', 'Available', '2026-08-08'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000088'), 'BC000047', N'KD-05', 'Available', '2026-08-08'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000095'), 'BC000048', N'KNS-13', 'Available', '2026-08-08'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000095'), 'BC000049', N'KNS-13', 'Available', '2026-08-08'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000101'), 'BC000050', N'KNS-14', 'Available', '2026-08-08'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000101'), 'BC000051', N'KNS-14', 'Available', '2026-08-08'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000118'), 'BC000052', N'TL-02', 'Available', '2026-08-08'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000118'), 'BC000053', N'TL-02', 'Available', '2026-08-08'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000125'), 'BC000054', N'KD-06', 'Available', '2026-08-08'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000125'), 'BC000055', N'KD-06', 'Available', '2026-08-08'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000132'), 'BC000056', N'KNS-15', 'Available', '2026-08-08'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000132'), 'BC000057', N'KNS-15', 'Available', '2026-08-08'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000149'), 'BC000058', N'KNS-16', 'Available', '2026-08-08'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000149'), 'BC000059', N'KNS-16', 'Available', '2026-08-08'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000156'), 'BC000060', N'KNS-17', 'Available', '2026-08-08'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000156'), 'BC000061', N'KNS-17', 'Available', '2026-08-08'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000163'), 'BC000062', N'KD-07', 'Available', '2026-08-09'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000163'), 'BC000063', N'KD-07', 'Available', '2026-08-09'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000170'), 'BC000064', N'KNS-18', 'Available', '2026-08-09'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000170'), 'BC000065', N'KNS-18', 'Available', '2026-08-09'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000187'), 'BC000066', N'KNS-19', 'Available', '2026-08-09'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000187'), 'BC000067', N'KNS-19', 'Available', '2026-08-09'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000194'), 'BC000068', N'KNS-20', 'Available', '2026-08-09'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000194'), 'BC000069', N'KNS-20', 'Available', '2026-08-09'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000200'), 'BC000070', N'KD-08', 'Available', '2026-08-09'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000200'), 'BC000071', N'KD-08', 'Available', '2026-08-09'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000217'), 'BC000072', N'KD-09', 'Available', '2026-08-09'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000217'), 'BC000073', N'KD-09', 'Available', '2026-08-09'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000224'), 'BC000074', N'KD-10', 'Available', '2026-08-09'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000224'), 'BC000075', N'KD-10', 'Available', '2026-08-09'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000231'), 'BC000076', N'KD-11', 'Available', '2026-08-09'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000231'), 'BC000077', N'KD-11', 'Available', '2026-08-09'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000248'), 'BC000078', N'KD-12', 'Available', '2026-08-10'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000248'), 'BC000079', N'KD-12', 'Available', '2026-08-10'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000255'), 'BC000080', N'KD-13', 'Available', '2026-08-10'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000255'), 'BC000081', N'KD-13', 'Available', '2026-08-10'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000262'), 'BC000082', N'CN-04', 'Available', '2026-08-10'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000262'), 'BC000083', N'CN-04', 'Available', '2026-08-10'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000279'), 'BC000084', N'CN-05', 'Available', '2026-08-10'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000279'), 'BC000085', N'CN-05', 'Available', '2026-08-10'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000286'), 'BC000086', N'CN-06', 'Available', '2026-08-10'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000286'), 'BC000087', N'CN-06', 'Available', '2026-08-10'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000293'), 'BC000088', N'CN-07', 'Available', '2026-08-10'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000293'), 'BC000089', N'CN-07', 'Available', '2026-08-10'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000309'), 'BC000090', N'CN-08', 'Available', '2026-08-10'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000309'), 'BC000091', N'CN-08', 'Available', '2026-08-10'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000316'), 'BC000092', N'CN-09', 'Available', '2026-08-10'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000316'), 'BC000093', N'CN-09', 'Available', '2026-08-10'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000323'), 'BC000094', N'CN-10', 'Available', '2026-08-11'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000323'), 'BC000095', N'CN-10', 'Available', '2026-08-11'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000330'), 'BC000096', N'CN-11', 'Available', '2026-08-11'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000330'), 'BC000097', N'CN-11', 'Available', '2026-08-11'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000347'), 'BC000098', N'CN-12', 'Available', '2026-08-11'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000347'), 'BC000099', N'CN-12', 'Available', '2026-08-11'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000354'), 'BC000100', N'CN-13', 'Available', '2026-08-11'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000354'), 'BC000101', N'CN-13', 'Available', '2026-08-11'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000361'), 'BC000102', N'CN-14', 'Available', '2026-08-11'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000361'), 'BC000103', N'CN-14', 'Available', '2026-08-11'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000378'), 'BC000104', N'CN-15', 'Available', '2026-08-11'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000378'), 'BC000105', N'CN-15', 'Available', '2026-08-11'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000385'), 'BC000106', N'CN-16', 'Available', '2026-08-11'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000385'), 'BC000107', N'CN-16', 'Available', '2026-08-11'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000392'), 'BC000108', N'CN-17', 'Available', '2026-08-11'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000392'), 'BC000109', N'CN-17', 'Available', '2026-08-11'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000408'), 'BC000110', N'CN-18', 'Available', '2026-08-12'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000408'), 'BC000111', N'CN-18', 'Available', '2026-08-12'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000415'), 'BC000112', N'CN-19', 'Available', '2026-08-12'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000415'), 'BC000113', N'CN-19', 'Available', '2026-08-12'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000422'), 'BC000114', N'CN-20', 'Available', '2026-08-12'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000422'), 'BC000115', N'CN-20', 'Available', '2026-08-12'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000439'), 'BC000116', N'CN-21', 'Available', '2026-08-12'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000439'), 'BC000117', N'CN-21', 'Available', '2026-08-12'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000446'), 'BC000118', N'CN-22', 'Available', '2026-08-12'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000446'), 'BC000119', N'CN-22', 'Available', '2026-08-12'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000453'), 'BC000120', N'CN-23', 'Available', '2026-08-12'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000453'), 'BC000121', N'CN-23', 'Available', '2026-08-12'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000460'), 'BC000122', N'CN-24', 'Available', '2026-08-12'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000460'), 'BC000123', N'CN-24', 'Available', '2026-08-12'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000477'), 'BC000124', N'CN-25', 'Available', '2026-08-12'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000477'), 'BC000125', N'CN-25', 'Available', '2026-08-12'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000484'), 'BC000126', N'CN-26', 'Available', '2026-08-13'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000484'), 'BC000127', N'CN-26', 'Available', '2026-08-13'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000491'), 'BC000128', N'CN-27', 'Available', '2026-08-13'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000491'), 'BC000129', N'CN-27', 'Available', '2026-08-13'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000507'), 'BC000130', N'CN-28', 'Available', '2026-08-13'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000507'), 'BC000131', N'CN-28', 'Available', '2026-08-13'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000514'), 'BC000132', N'CN-29', 'Available', '2026-08-13'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000514'), 'BC000133', N'CN-29', 'Available', '2026-08-13'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000521'), 'BC000134', N'CN-30', 'Available', '2026-08-13'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000521'), 'BC000135', N'CN-30', 'Available', '2026-08-13'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000538'), 'BC000136', N'CN-31', 'Available', '2026-08-13'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000538'), 'BC000137', N'CN-31', 'Available', '2026-08-13'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000545'), 'BC000138', N'CN-32', 'Available', '2026-08-13'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000545'), 'BC000139', N'CN-32', 'Available', '2026-08-13'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000552'), 'BC000140', N'CN-33', 'Available', '2026-08-13'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000552'), 'BC000141', N'CN-33', 'Available', '2026-08-13'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000569'), 'BC000142', N'CN-34', 'Available', '2026-08-14'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000569'), 'BC000143', N'CN-34', 'Available', '2026-08-14'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000576'), 'BC000144', N'CN-35', 'Available', '2026-08-14'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000576'), 'BC000145', N'CN-35', 'Available', '2026-08-14'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000583'), 'BC000146', N'CN-36', 'Available', '2026-08-14'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000583'), 'BC000147', N'CN-36', 'Available', '2026-08-14'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000590'), 'BC000148', N'CN-37', 'Available', '2026-08-14'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000590'), 'BC000149', N'CN-37', 'Available', '2026-08-14'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000606'), 'BC000150', N'CN-38', 'Available', '2026-08-14'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000606'), 'BC000151', N'CN-38', 'Available', '2026-08-14'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000613'), 'BC000152', N'VHKD-01', 'Available', '2026-08-14'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000613'), 'BC000153', N'VHKD-01', 'Available', '2026-08-14'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000620'), 'BC000154', N'KHVT-01', 'Available', '2026-08-14'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000620'), 'BC000155', N'KHVT-01', 'Available', '2026-08-14'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000637'), 'BC000156', N'VHKD-02', 'Available', '2026-08-14'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000637'), 'BC000157', N'VHKD-02', 'Available', '2026-08-14'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000644'), 'BC000158', N'VHKD-03', 'Available', '2026-08-15'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000644'), 'BC000159', N'VHKD-03', 'Available', '2026-08-15'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000651'), 'BC000160', N'VHKD-04', 'Available', '2026-08-15'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000651'), 'BC000161', N'VHKD-04', 'Available', '2026-08-15'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000668'), 'BC000162', N'VHKD-05', 'Available', '2026-08-15'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000668'), 'BC000163', N'VHKD-05', 'Available', '2026-08-15'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000675'), 'BC000164', N'FT-04', 'Available', '2026-08-15'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000675'), 'BC000165', N'FT-04', 'Available', '2026-08-15'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000682'), 'BC000166', N'FT-05', 'Available', '2026-08-15'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000682'), 'BC000167', N'FT-05', 'Available', '2026-08-15'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000699'), 'BC000168', N'FT-06', 'Available', '2026-08-15'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000699'), 'BC000169', N'FT-06', 'Available', '2026-08-15'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000705'), 'BC000170', N'FT-07', 'Available', '2026-08-15'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000705'), 'BC000171', N'FT-07', 'Available', '2026-08-15'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000712'), 'BC000172', N'FT-08', 'Available', '2026-08-15'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000712'), 'BC000173', N'FT-08', 'Available', '2026-08-15'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000729'), 'BC000174', N'FT-09', 'Available', '2026-08-16'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000729'), 'BC000175', N'FT-09', 'Available', '2026-08-16'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000736'), 'BC000176', N'FT-10', 'Available', '2026-08-16'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000736'), 'BC000177', N'FT-10', 'Available', '2026-08-16'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000743'), 'BC000178', N'FT-11', 'Available', '2026-08-16'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000743'), 'BC000179', N'FT-11', 'Available', '2026-08-16'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000750'), 'BC000180', N'FT-12', 'Available', '2026-08-16'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000750'), 'BC000181', N'FT-12', 'Available', '2026-08-16'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000767'), 'BC000182', N'VHKD-06', 'Available', '2026-08-16'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000767'), 'BC000183', N'VHKD-06', 'Available', '2026-08-16'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000774'), 'BC000184', N'VHKD-07', 'Available', '2026-08-16'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000774'), 'BC000185', N'VHKD-07', 'Available', '2026-08-16'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000781'), 'BC000186', N'TTH-08', 'Available', '2026-08-16'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000781'), 'BC000187', N'TTH-08', 'Available', '2026-08-16'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000798'), 'BC000188', N'TTH-09', 'Available', '2026-08-16'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000798'), 'BC000189', N'TTH-09', 'Available', '2026-08-16'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000804'), 'BC000190', N'TTH-10', 'Available', '2026-08-17'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000804'), 'BC000191', N'TTH-10', 'Available', '2026-08-17'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000811'), 'BC000192', N'VHKD-08', 'Available', '2026-08-17'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000811'), 'BC000193', N'VHKD-08', 'Available', '2026-08-17'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000828'), 'BC000194', N'TTH-11', 'Available', '2026-08-17'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000828'), 'BC000195', N'TTH-11', 'Available', '2026-08-17'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000835'), 'BC000196', N'TTH-12', 'Available', '2026-08-17'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000835'), 'BC000197', N'TTH-12', 'Available', '2026-08-17'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000842'), 'BC000198', N'TTH-13', 'Available', '2026-08-17'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000842'), 'BC000199', N'TTH-13', 'Available', '2026-08-17'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000859'), 'BC000200', N'TTH-14', 'Available', '2026-08-17'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000859'), 'BC000201', N'TTH-14', 'Available', '2026-08-17'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000866'), 'BC000202', N'TTH-15', 'Available', '2026-08-17'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000866'), 'BC000203', N'TTH-15', 'Available', '2026-08-17'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000873'), 'BC000204', N'KHVT-02', 'Available', '2026-08-17'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000873'), 'BC000205', N'KHVT-02', 'Available', '2026-08-17'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000880'), 'BC000206', N'KHVT-03', 'Available', '2026-08-18'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000880'), 'BC000207', N'KHVT-03', 'Available', '2026-08-18'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000897'), 'BC000208', N'KHVT-04', 'Available', '2026-08-18'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000897'), 'BC000209', N'KHVT-04', 'Available', '2026-08-18'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000903'), 'BC000210', N'KHVT-05', 'Available', '2026-08-18'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000903'), 'BC000211', N'KHVT-05', 'Available', '2026-08-18'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000910'), 'BC000212', N'KHVT-06', 'Available', '2026-08-18'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000910'), 'BC000213', N'KHVT-06', 'Available', '2026-08-18'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000927'), 'BC000214', N'KHVT-07', 'Available', '2026-08-18'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000927'), 'BC000215', N'KHVT-07', 'Available', '2026-08-18'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000934'), 'BC000216', N'KHVT-08', 'Available', '2026-08-18'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000934'), 'BC000217', N'KHVT-08', 'Available', '2026-08-18'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000941'), 'BC000218', N'KHVT-09', 'Available', '2026-08-18'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000941'), 'BC000219', N'KHVT-09', 'Available', '2026-08-18'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000958'), 'BC000220', N'KHVT-10', 'Available', '2026-08-18'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000958'), 'BC000221', N'KHVT-10', 'Available', '2026-08-18'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000965'), 'BC000222', N'KHVT-11', 'Available', '2026-08-19'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000965'), 'BC000223', N'KHVT-11', 'Available', '2026-08-19'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000972'), 'BC000224', N'TTH-16', 'Available', '2026-08-19'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000972'), 'BC000225', N'TTH-16', 'Available', '2026-08-19'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000989'), 'BC000226', N'TTH-17', 'Available', '2026-08-19'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000989'), 'BC000227', N'TTH-17', 'Available', '2026-08-19'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000996'), 'BC000228', N'TTH-18', 'Available', '2026-08-19'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040000996'), 'BC000229', N'TTH-18', 'Available', '2026-08-19'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001009'), 'BC000230', N'TTH-19', 'Available', '2026-08-19'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001009'), 'BC000231', N'TTH-19', 'Available', '2026-08-19'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001016'), 'BC000232', N'HK-05', 'Available', '2026-08-19'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001016'), 'BC000233', N'HK-05', 'Available', '2026-08-19'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001023'), 'BC000234', N'HK-06', 'Available', '2026-08-19'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001023'), 'BC000235', N'HK-06', 'Available', '2026-08-19'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001030'), 'BC000236', N'HK-07', 'Available', '2026-08-19'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001030'), 'BC000237', N'HK-07', 'Available', '2026-08-19'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001047'), 'BC000238', N'HK-08', 'Available', '2026-08-20'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001047'), 'BC000239', N'HK-08', 'Available', '2026-08-20'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001054'), 'BC000240', N'KH-01', 'Available', '2026-08-20'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001054'), 'BC000241', N'KH-01', 'Available', '2026-08-20'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001061'), 'BC000242', N'KH-02', 'Available', '2026-08-20'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001061'), 'BC000243', N'KH-02', 'Available', '2026-08-20'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001078'), 'BC000244', N'KH-03', 'Available', '2026-08-20'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001078'), 'BC000245', N'KH-03', 'Available', '2026-08-20'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001085'), 'BC000246', N'KH-04', 'Available', '2026-08-20'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001085'), 'BC000247', N'KH-04', 'Available', '2026-08-20'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001092'), 'BC000248', N'KH-05', 'Available', '2026-08-20'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001092'), 'BC000249', N'KH-05', 'Available', '2026-08-20'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001108'), 'BC000250', N'KH-06', 'Available', '2026-08-20'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001108'), 'BC000251', N'KH-06', 'Available', '2026-08-20'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001115'), 'BC000252', N'KH-07', 'Available', '2026-08-20'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001115'), 'BC000253', N'KH-07', 'Available', '2026-08-20'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001122'), 'BC000254', N'KH-08', 'Available', '2026-08-21'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001122'), 'BC000255', N'KH-08', 'Available', '2026-08-21'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001139'), 'BC000256', N'KH-09', 'Available', '2026-08-21'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001139'), 'BC000257', N'KH-09', 'Available', '2026-08-21'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001146'), 'BC000258', N'KH-10', 'Available', '2026-08-21'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001146'), 'BC000259', N'KH-10', 'Available', '2026-08-21'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001153'), 'BC000260', N'KH-11', 'Available', '2026-08-21'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001153'), 'BC000261', N'KH-11', 'Available', '2026-08-21'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001160'), 'BC000262', N'KH-12', 'Available', '2026-08-21'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001160'), 'BC000263', N'KH-12', 'Available', '2026-08-21'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001177'), 'BC000264', N'KH-13', 'Available', '2026-08-21'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001177'), 'BC000265', N'KH-13', 'Available', '2026-08-21'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001184'), 'BC000266', N'KH-14', 'Available', '2026-08-21'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001184'), 'BC000267', N'KH-14', 'Available', '2026-08-21'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001191'), 'BC000268', N'TL-03', 'Available', '2026-08-21'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001191'), 'BC000269', N'TL-03', 'Available', '2026-08-21'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001207'), 'BC000270', N'TL-04', 'Available', '2026-08-22'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001207'), 'BC000271', N'TL-04', 'Available', '2026-08-22'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001214'), 'BC000272', N'TL-05', 'Available', '2026-08-22'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001214'), 'BC000273', N'TL-05', 'Available', '2026-08-22'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001221'), 'BC000274', N'TL-06', 'Available', '2026-08-22'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001221'), 'BC000275', N'TL-06', 'Available', '2026-08-22'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001238'), 'BC000276', N'TL-07', 'Available', '2026-08-22'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001238'), 'BC000277', N'TL-07', 'Available', '2026-08-22'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001245'), 'BC000278', N'TL-08', 'Available', '2026-08-22'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001245'), 'BC000279', N'TL-08', 'Available', '2026-08-22'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001252'), 'BC000280', N'KD-14', 'Available', '2026-08-22'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001252'), 'BC000281', N'KD-14', 'Available', '2026-08-22'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001269'), 'BC000282', N'KD-15', 'Available', '2026-08-22'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001269'), 'BC000283', N'KD-15', 'Available', '2026-08-22'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001276'), 'BC000284', N'KNS-21', 'Available', '2026-08-22'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001276'), 'BC000285', N'KNS-21', 'Available', '2026-08-22'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001283'), 'BC000286', N'KNS-22', 'Available', '2026-08-23'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001283'), 'BC000287', N'KNS-22', 'Available', '2026-08-23'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001290'), 'BC000288', N'KNS-23', 'Available', '2026-08-23'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001290'), 'BC000289', N'KNS-23', 'Available', '2026-08-23'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001306'), 'BC000290', N'KNS-24', 'Available', '2026-08-23'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001306'), 'BC000291', N'KNS-24', 'Available', '2026-08-23'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001313'), 'BC000292', N'TL-09', 'Available', '2026-08-23'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001313'), 'BC000293', N'TL-09', 'Available', '2026-08-23'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001320'), 'BC000294', N'KNS-25', 'Available', '2026-08-23'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001320'), 'BC000295', N'KNS-25', 'Available', '2026-08-23'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001337'), 'BC000296', N'TRH-01', 'Available', '2026-08-23'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001337'), 'BC000297', N'TRH-01', 'Available', '2026-08-23'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001344'), 'BC000298', N'HK-09', 'Available', '2026-08-23'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001344'), 'BC000299', N'HK-09', 'Available', '2026-08-23'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001351'), 'BC000300', N'TRH-02', 'Available', '2026-08-23'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001351'), 'BC000301', N'TRH-02', 'Available', '2026-08-23'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001368'), 'BC000302', N'TRH-03', 'Available', '2026-08-24'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001368'), 'BC000303', N'TRH-03', 'Available', '2026-08-24'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001375'), 'BC000304', N'TRH-04', 'Available', '2026-08-24'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001375'), 'BC000305', N'TRH-04', 'Available', '2026-08-24'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001382'), 'BC000306', N'TRH-05', 'Available', '2026-08-24'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001382'), 'BC000307', N'TRH-05', 'Available', '2026-08-24'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001399'), 'BC000308', N'TRH-06', 'Available', '2026-08-24'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001399'), 'BC000309', N'TRH-06', 'Available', '2026-08-24'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001405'), 'BC000310', N'TRH-07', 'Available', '2026-08-24'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001405'), 'BC000311', N'TRH-07', 'Available', '2026-08-24'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001412'), 'BC000312', N'VHKD-09', 'Available', '2026-08-24'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001412'), 'BC000313', N'VHKD-09', 'Available', '2026-08-24'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001429'), 'BC000314', N'VHKD-10', 'Available', '2026-08-24'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001429'), 'BC000315', N'VHKD-10', 'Available', '2026-08-24'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001436'), 'BC000316', N'VHKD-11', 'Available', '2026-08-24'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001436'), 'BC000317', N'VHKD-11', 'Available', '2026-08-24'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001443'), 'BC000318', N'VHKD-12', 'Available', '2026-08-25'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001443'), 'BC000319', N'VHKD-12', 'Available', '2026-08-25'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001450'), 'BC000320', N'VHKD-13', 'Available', '2026-08-25'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001450'), 'BC000321', N'VHKD-13', 'Available', '2026-08-25'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001467'), 'BC000322', N'VHKD-14', 'Available', '2026-08-25'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001467'), 'BC000323', N'VHKD-14', 'Available', '2026-08-25'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001474'), 'BC000324', N'VHKD-15', 'Available', '2026-08-25'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001474'), 'BC000325', N'VHKD-15', 'Available', '2026-08-25'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001481'), 'BC000326', N'TTKD-01', 'Available', '2026-08-25'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001481'), 'BC000327', N'TTKD-01', 'Available', '2026-08-25'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001498'), 'BC000328', N'TTKD-02', 'Available', '2026-08-25'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001498'), 'BC000329', N'TTKD-02', 'Available', '2026-08-25'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001504'), 'BC000330', N'TTKD-03', 'Available', '2026-08-25'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001504'), 'BC000331', N'TTKD-03', 'Available', '2026-08-25'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001511'), 'BC000332', N'VHKD-16', 'Available', '2026-08-25'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001511'), 'BC000333', N'VHKD-16', 'Available', '2026-08-25'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001528'), 'BC000334', N'KHVT-12', 'Available', '2026-08-26'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001528'), 'BC000335', N'KHVT-12', 'Available', '2026-08-26'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001535'), 'BC000336', N'KHVT-13', 'Available', '2026-08-26'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001535'), 'BC000337', N'KHVT-13', 'Available', '2026-08-26'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001542'), 'BC000338', N'TTKD-04', 'Available', '2026-08-26'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001542'), 'BC000339', N'TTKD-04', 'Available', '2026-08-26'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001559'), 'BC000340', N'TTKD-05', 'Available', '2026-08-26'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001559'), 'BC000341', N'TTKD-05', 'Available', '2026-08-26'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001566'), 'BC000342', N'TTKD-06', 'Available', '2026-08-26'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001566'), 'BC000343', N'TTKD-06', 'Available', '2026-08-26'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001573'), 'BC000344', N'TTKD-07', 'Available', '2026-08-26'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001573'), 'BC000345', N'TTKD-07', 'Available', '2026-08-26'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001580'), 'BC000346', N'TTKD-08', 'Available', '2026-08-26'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001580'), 'BC000347', N'TTKD-08', 'Available', '2026-08-26'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001597'), 'BC000348', N'TTKD-09', 'Available', '2026-08-26'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001597'), 'BC000349', N'TTKD-09', 'Available', '2026-08-26'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001603'), 'BC000350', N'TTKD-10', 'Available', '2026-08-27'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001603'), 'BC000351', N'TTKD-10', 'Available', '2026-08-27'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001610'), 'BC000352', N'TTKD-11', 'Available', '2026-08-27'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001610'), 'BC000353', N'TTKD-11', 'Available', '2026-08-27'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001627'), 'BC000354', N'TTKD-12', 'Available', '2026-08-27'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001627'), 'BC000355', N'TTKD-12', 'Available', '2026-08-27'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001634'), 'BC000356', N'TTKD-13', 'Available', '2026-08-27'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001634'), 'BC000357', N'TTKD-13', 'Available', '2026-08-27'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001641'), 'BC000358', N'TTKD-14', 'Available', '2026-08-27'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001641'), 'BC000359', N'TTKD-14', 'Available', '2026-08-27'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001658'), 'BC000360', N'TTKD-15', 'Available', '2026-08-27'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001658'), 'BC000361', N'TTKD-15', 'Available', '2026-08-27'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001665'), 'BC000362', N'TTKD-16', 'Available', '2026-08-27'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001665'), 'BC000363', N'TTKD-16', 'Available', '2026-08-27'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001672'), 'BC000364', N'TTKD-17', 'Available', '2026-08-27'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001672'), 'BC000365', N'TTKD-17', 'Available', '2026-08-27'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001689'), 'BC000366', N'TTKD-18', 'Available', '2026-08-28'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001689'), 'BC000367', N'TTKD-18', 'Available', '2026-08-28'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001696'), 'BC000368', N'TTKD-19', 'Available', '2026-08-28'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001696'), 'BC000369', N'TTKD-19', 'Available', '2026-08-28'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001702'), 'BC000370', N'TTKD-20', 'Available', '2026-08-28'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001702'), 'BC000371', N'TTKD-20', 'Available', '2026-08-28'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001719'), 'BC000372', N'TTH-20', 'Available', '2026-08-28'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001719'), 'BC000373', N'TTH-20', 'Available', '2026-08-28'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001726'), 'BC000374', N'TTH-21', 'Available', '2026-08-28'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001726'), 'BC000375', N'TTH-21', 'Available', '2026-08-28'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001733'), 'BC000376', N'TTH-22', 'Available', '2026-08-28'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001733'), 'BC000377', N'TTH-22', 'Available', '2026-08-28'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001740'), 'BC000378', N'VHVN-01', 'Available', '2026-08-28'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001740'), 'BC000379', N'VHVN-01', 'Available', '2026-08-28'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001757'), 'BC000380', N'VHVN-02', 'Available', '2026-08-28'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001757'), 'BC000381', N'VHVN-02', 'Available', '2026-08-28'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001764'), 'BC000382', N'VHVN-03', 'Available', '2026-08-29'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001764'), 'BC000383', N'VHVN-03', 'Available', '2026-08-29'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001771'), 'BC000384', N'VHVN-04', 'Available', '2026-08-29'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001771'), 'BC000385', N'VHVN-04', 'Available', '2026-08-29'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001788'), 'BC000386', N'VHVN-05', 'Available', '2026-08-29'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001788'), 'BC000387', N'VHVN-05', 'Available', '2026-08-29'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001795'), 'BC000388', N'VHVN-06', 'Available', '2026-08-29'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001795'), 'BC000389', N'VHVN-06', 'Available', '2026-08-29'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001801'), 'BC000390', N'VHVN-07', 'Available', '2026-08-29'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001801'), 'BC000391', N'VHVN-07', 'Available', '2026-08-29'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001818'), 'BC000392', N'VHKD-17', 'Available', '2026-08-29'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001818'), 'BC000393', N'VHKD-17', 'Available', '2026-08-29'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001825'), 'BC000394', N'VHVN-08', 'Available', '2026-08-29'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001825'), 'BC000395', N'VHVN-08', 'Available', '2026-08-29'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001832'), 'BC000396', N'VHVN-09', 'Available', '2026-08-29'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001832'), 'BC000397', N'VHVN-09', 'Available', '2026-08-29'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001849'), 'BC000398', N'VHVN-10', 'Available', '2026-08-30'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001849'), 'BC000399', N'VHVN-10', 'Available', '2026-08-30'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001856'), 'BC000400', N'VHVN-11', 'Available', '2026-08-30'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001856'), 'BC000401', N'VHVN-11', 'Available', '2026-08-30'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001863'), 'BC000402', N'VHVN-12', 'Available', '2026-08-30'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001863'), 'BC000403', N'VHVN-12', 'Available', '2026-08-30'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001870'), 'BC000404', N'VHVN-13', 'Available', '2026-08-30'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001870'), 'BC000405', N'VHVN-13', 'Available', '2026-08-30'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001887'), 'BC000406', N'VHVN-14', 'Available', '2026-08-30'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001887'), 'BC000407', N'VHVN-14', 'Available', '2026-08-30'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001894'), 'BC000408', N'VHVN-15', 'Available', '2026-08-30'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001894'), 'BC000409', N'VHVN-15', 'Available', '2026-08-30'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001900'), 'BC000410', N'VHVN-16', 'Available', '2026-08-30'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001900'), 'BC000411', N'VHVN-16', 'Available', '2026-08-30'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001917'), 'BC000412', N'VHVN-17', 'Available', '2026-08-30'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001917'), 'BC000413', N'VHVN-17', 'Available', '2026-08-30'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001924'), 'BC000414', N'VHVN-18', 'Available', '2026-08-31'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001924'), 'BC000415', N'VHVN-18', 'Available', '2026-08-31'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001931'), 'BC000416', N'VHVN-19', 'Available', '2026-08-31'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001931'), 'BC000417', N'VHVN-19', 'Available', '2026-08-31'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001948'), 'BC000418', N'VHVN-20', 'Available', '2026-08-31'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001948'), 'BC000419', N'VHVN-20', 'Available', '2026-08-31'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001955'), 'BC000420', N'VHVN-21', 'Available', '2026-08-31'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001955'), 'BC000421', N'VHVN-21', 'Available', '2026-08-31'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001962'), 'BC000422', N'VHVN-22', 'Available', '2026-08-31'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001962'), 'BC000423', N'VHVN-22', 'Available', '2026-08-31'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001979'), 'BC000424', N'KH-15', 'Available', '2026-08-31'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001979'), 'BC000425', N'KH-15', 'Available', '2026-08-31'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001986'), 'BC000426', N'KNS-26', 'Available', '2026-08-31'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001986'), 'BC000427', N'KNS-26', 'Available', '2026-08-31'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001993'), 'BC000428', N'KNS-27', 'Available', '2026-08-31'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040001993'), 'BC000429', N'KNS-27', 'Available', '2026-08-31'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040002006'), 'BC000430', N'KD-16', 'Available', '2026-09-01'),
        ((SELECT book_id FROM Books WHERE isbn = '9786040002006'), 'BC000431', N'KD-16', 'Available', '2026-09-01');
    GO

    -- ============================================
    -- VERIFIED VIETNAMESE EDITION SAMPLE DATA
    -- ISBN is stored without hyphens for consistent searching.
    -- edition_name preserves the title in the legal-deposit record.
    -- ============================================
    UPDATE Books SET
        title=N'Nhà giả kim', isbn='9786045396391', edition_name=N'Nhà giả Kim',
        legal_publisher=N'Nhà xuất bản Hội Nhà văn', publishing_partner=N'Công ty Cổ phần Văn hóa và Truyền thông Nhã Nam',
        publish_year=2026, pages=225, language=N'Tiếng Việt', cover_image=N'https://covers.openlibrary.org/b/id/12634885-L.jpg',
        description=N'Qua hành trình rời quê nhà của chàng chăn cừu Santiago để đi tìm kho báu bên Kim Tự Tháp, tiểu thuyết kể về lòng can đảm theo đuổi ước mơ, khả năng lắng nghe trực giác và cách mỗi trải nghiệm trên đường đời góp phần tạo nên ý nghĩa của đích đến. Lối kể cô đọng, giàu tính ngụ ngôn khiến tác phẩm phù hợp với độc giả trẻ lẫn người trưởng thành đang đứng trước một lựa chọn lớn.',
        catalog_source_url=N'https://ppdvn.gov.vn/web/guest/tra-cuu-luu-chieu?query=978-604-53-9639-1'
    WHERE isbn='9786040000019';

    UPDATE Books SET
        title=N'Đắc nhân tâm', isbn='9786326176681', edition_name=N'How to Win Friends and Influence People - Đắc nhân tâm',
        legal_publisher=N'Nhà xuất bản Văn học', publishing_partner=N'Công ty TNHH Văn hóa và Truyền thông Trí Việt (First News)',
        publish_year=2025, language=N'Tiếng Việt', cover_image=N'https://upload.wikimedia.org/wikipedia/vi/0/0a/%C4%90%E1%BA%AFc_nh%C3%A2n_t%C3%A2m.jpg',
        description=N'Tác phẩm hệ thống hóa những nguyên tắc giao tiếp bền vững: tôn trọng người đối diện, ghi nhận chân thành, nhìn vấn đề từ góc độ của họ và góp ý mà không làm tổn thương lòng tự trọng. Thay vì đưa ra mẹo ứng xử ngắn hạn, sách dùng nhiều tình huống thực tế để chỉ ra cách xây dựng thiện cảm, giải quyết bất đồng và tạo ảnh hưởng tích cực trong công việc cũng như đời sống.',
        catalog_source_url=N'https://ppdvn.gov.vn/web/guest/tra-cuu-luu-chieu?query=978-632-617-668-1'
    WHERE isbn='9786040000026';

    UPDATE Books SET
        title=N'Tuổi trẻ đáng giá bao nhiêu', isbn='9786045370193', edition_name=N'Tuổi trẻ đáng giá bao nhiêu',
        legal_publisher=N'Nhà xuất bản Hội Nhà văn', publishing_partner=N'Công ty Cổ phần Văn hóa và Truyền thông Nhã Nam',
        publisher_id=(SELECT publisher_id FROM Publishers WHERE publisher_name=N'Nhã Nam'),
        publish_year=2026, pages=285, language=N'Tiếng Việt', cover_image=N'https://books.google.com/books/content?id=iCQytAEACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api',
        description=N'Rosie Nguyễn viết từ trải nghiệm học tập, làm việc và đi nhiều nơi để trò chuyện thẳng thắn với người trẻ về ba nền tảng: học chủ động, làm việc có kỷ luật và dấn thân để hiểu chính mình. Những chương ngắn về đọc sách, rèn kỹ năng, đi để trưởng thành và lựa chọn con đường riêng tạo nên một cuốn cẩm nang gần gũi, khuyến khích độc giả biến quãng tuổi trẻ thành quá trình tích lũy có mục tiêu.',
        catalog_source_url=N'https://ppdvn.gov.vn/web/guest/tra-cuu-luu-chieu?query=978-604-53-7019-3'
    WHERE isbn='9786040000033';

    UPDATE Books SET
        title=N'Cà phê cùng Tony', isbn='9786041243781', edition_name=N'Cà phê cùng Tony - tập bài viết (TB)',
        legal_publisher=N'Nhà xuất bản Trẻ', publishing_partner=NULL,
        publisher_id=(SELECT publisher_id FROM Publishers WHERE publisher_name=N'NXB Trẻ'),
        publish_year=2024, pages=268, language=N'Tiếng Việt', cover_image=N'https://covers.openlibrary.org/b/id/9175811-L.jpg',
        description=N'Tập sách tuyển chọn những bài viết dí dỏm của Tony Buổi Sáng về học tập, nghề nghiệp, văn hóa ứng xử và tinh thần tự lập. Giọng kể hài hước nhưng thực tế dẫn người đọc từ các thói quen nhỏ như đọc, học ngoại ngữ và quản lý thời gian đến thái độ dám đi, dám làm và chịu trách nhiệm với lựa chọn của mình; đặc biệt phù hợp với sinh viên và người mới bước vào môi trường làm việc.',
        catalog_source_url=N'https://ppdvn.gov.vn/web/guest/tra-cuu-luu-chieu?query=978-604-1-24378-1'
    WHERE isbn='9786040000040';

    -- Đi tìm lẽ sống: bản lưu chiểu gần nhất tìm được ngày 25/12/2024.
    UPDATE Books SET
        title=N'Đi tìm lẽ sống', isbn='9786044061726', edition_name=N'Đi Tìm Lẽ Sống',
        legal_publisher=N'Nhà xuất bản Dân trí',
        publishing_partner=N'Công ty TNHH Công nghệ WEWE',
        publish_year=2024, language=N'Tiếng Việt',
        catalog_source_url=N'https://ppdvn.gov.vn/web/guest/tra-cuu-luu-chieu?query=%C4%90i%20t%C3%ACm%20l%E1%BA%BD%20s%E1%BB%91ng'
    WHERE isbn='9786040000057';

    -- Tư duy nhanh và chậm: bản lưu chiểu gần nhất tìm được ngày 18/02/2022.
    UPDATE Books SET
        title=N'Tư duy nhanh và chậm', isbn='9786048060503', edition_name=N'Tư duy nhanh và chậm',
        legal_publisher=N'Nhà xuất bản Thông tin và Truyền thông',
        publishing_partner=N'Công ty Cổ phần Fonos',
        publish_year=2022, language=N'Tiếng Việt',
        catalog_source_url=N'https://ppdvn.gov.vn/web/guest/tra-cuu-luu-chieu?query=T%C6%B0%20duy%20nhanh%20v%C3%A0%20ch%E1%BA%ADm'
    WHERE isbn='9786040000071';

    -- Cha giàu cha nghèo: hồ sơ lưu chiểu ngày 15/04/2016.
    IF NOT EXISTS (SELECT 1 FROM Authors WHERE author_name=N'Sharon L. Lechter')
        INSERT INTO Authors (author_name, biography) VALUES (N'Sharon L. Lechter', NULL);

    UPDATE Books SET
        title=N'Cha giàu cha nghèo', isbn='9786046520481', edition_name=N'Cha giàu cha nghèo',
        author_id=(SELECT author_id FROM Authors WHERE author_name=N'Sharon L. Lechter'),
        legal_publisher=N'Nhà xuất bản Lao động - Xã hội',
        publishing_partner=N'Nhà sách Hà Phương',
        publish_year=2016, language=N'Tiếng Việt',
        catalog_source_url=N'https://ppdvn.gov.vn/web/guest/tra-cuu-luu-chieu?query=Cha%20gi%C3%A0u%20cha%20ngh%C3%A8o'
    WHERE isbn='9786040000088';

    -- ================================================================
    -- CHUẨN HÓA TÊN ẤN BẢN PHÁT HÀNH TẠI VIỆT NAM
    -- Tên gốc vẫn có thể tra cứu qua tác giả/ISBN; title và edition_name
    -- dùng tên tiếng Việt để hiển thị thống nhất trong toàn bộ ứng dụng.
    -- ================================================================
    DECLARE @VietnameseEditionTitles TABLE
    (
        source_title NVARCHAR(255) PRIMARY KEY,
        edition_title NVARCHAR(255) NOT NULL
    );

    INSERT INTO @VietnameseEditionTitles(source_title, edition_title)
    VALUES
        (N'Atomic Habits', N'Thay đổi tí hon, hiệu quả bất ngờ'),
        (N'Deep Work', N'Làm ra làm, chơi ra chơi'),
        (N'Mindset', N'Tâm lý học thành công'),
        (N'The Psychology of Money', N'Tâm lý học về tiền'),
        (N'Ikigai', N'Ikigai - Đi tìm lý do thức dậy mỗi sáng'),
        (N'Essentialism', N'Nghệ thuật theo đuổi sự tối giản'),
        (N'The Power of Now', N'Sức mạnh của hiện tại'),
        (N'Think and Grow Rich', N'Nghĩ giàu làm giàu'),
        (N'How to Win Friends and Influence People', N'Đắc nhân tâm'),
        (N'The 5 AM Club', N'Câu lạc bộ 5 giờ sáng'),
        (N'Make Time', N'Làm chủ thời gian'),
        (N'Start With Why', N'Bắt đầu với câu hỏi tại sao'),
        (N'Zero to One', N'Không đến một'),
        (N'Good to Great', N'Từ tốt đến vĩ đại'),
        (N'The Lean Startup', N'Khởi nghiệp tinh gọn'),
        (N'Rework', N'Khác biệt để bứt phá'),
        (N'The Hard Thing About Hard Things', N'Gian nan chồng chất gian nan'),
        (N'Clean Code', N'Mã sạch'),
        (N'Clean Architecture', N'Kiến trúc sạch'),
        (N'The Pragmatic Programmer', N'Lập trình viên thực dụng'),
        (N'Design Patterns', N'Các mẫu thiết kế hướng đối tượng'),
        (N'Refactoring', N'Tái cấu trúc mã nguồn'),
        (N'Effective Java', N'Java hiệu quả'),
        (N'Head First Java', N'Java nhập môn trực quan'),
        (N'Java: The Complete Reference', N'Java - Tài liệu tham khảo toàn diện'),
        (N'Spring in Action', N'Spring thực chiến'),
        (N'Spring Boot in Action', N'Spring Boot thực chiến'),
        (N'Learning React', N'Học React'),
        (N'React Quickly', N'React cấp tốc'),
        (N'Fullstack React', N'Phát triển ứng dụng React toàn diện'),
        (N'You Don''t Know JS', N'Bạn chưa biết JavaScript'),
        (N'Eloquent JavaScript', N'JavaScript hiện đại'),
        (N'JavaScript: The Definitive Guide', N'JavaScript - Hướng dẫn toàn diện'),
        (N'HTML and CSS', N'Thiết kế website với HTML và CSS'),
        (N'CSS Secrets', N'Bí quyết CSS'),
        (N'Don''t Make Me Think', N'Đừng bắt tôi phải suy nghĩ'),
        (N'The UX Book', N'Cẩm nang trải nghiệm người dùng'),
        (N'Introduction to Algorithms', N'Nhập môn thuật toán'),
        (N'Algorithms', N'Thuật toán'),
        (N'Database System Concepts', N'Các khái niệm hệ cơ sở dữ liệu'),
        (N'Designing Data-Intensive Applications', N'Thiết kế hệ thống dữ liệu chuyên sâu'),
        (N'Computer Networking', N'Mạng máy tính'),
        (N'Operating System Concepts', N'Các khái niệm hệ điều hành'),
        (N'Computer Systems: A Programmer''s Perspective', N'Hệ thống máy tính dưới góc nhìn lập trình viên'),
        (N'Artificial Intelligence: A Modern Approach', N'Trí tuệ nhân tạo - Cách tiếp cận hiện đại'),
        (N'Deep Learning', N'Học sâu'),
        (N'Hands-On Machine Learning', N'Học máy thực hành với Scikit-Learn, Keras và TensorFlow'),
        (N'Python Crash Course', N'Giáo trình Python cấp tốc'),
        (N'Automate the Boring Stuff with Python', N'Tự động hóa công việc nhàm chán với Python'),
        (N'Fluent Python', N'Python chuyên sâu'),
        (N'Effective Python', N'Python hiệu quả'),
        (N'Learning Python', N'Học Python'),
        (N'To Kill a Mockingbird', N'Giết con chim nhại'),
        (N'Animal Farm', N'Trại súc vật'),
        (N'The Great Gatsby', N'Đại gia Gatsby'),
        (N'Pride and Prejudice', N'Kiêu hãnh và định kiến'),
        (N'The Catcher in the Rye', N'Bắt trẻ đồng xanh'),
        (N'The Hobbit', N'Anh chàng Hobbit'),
        (N'The Fellowship of the Ring', N'Chúa tể những chiếc nhẫn - Đoàn hộ nhẫn'),
        (N'The Lord of the Rings', N'Chúa tể những chiếc nhẫn'),
        (N'Harry Potter and the Sorcerer''s Stone', N'Harry Potter và Hòn đá Phù thủy'),
        (N'Harry Potter and the Chamber of Secrets', N'Harry Potter và Phòng chứa Bí mật'),
        (N'Harry Potter and the Prisoner of Azkaban', N'Harry Potter và Tên tù nhân ngục Azkaban'),
        (N'Harry Potter and the Goblet of Fire', N'Harry Potter và Chiếc cốc lửa'),
        (N'Harry Potter and the Order of the Phoenix', N'Harry Potter và Hội Phượng Hoàng'),
        (N'Harry Potter and the Half-Blood Prince', N'Harry Potter và Hoàng tử lai'),
        (N'Harry Potter and the Deathly Hallows', N'Harry Potter và Bảo bối Tử thần'),
        (N'The Little Prince', N'Hoàng tử bé'),
        (N'The Old Man and the Sea', N'Ông già và biển cả'),
        (N'The Alchemist', N'Nhà giả kim'),
        (N'Kafka on the Shore', N'Kafka bên bờ biển'),
        (N'One Hundred Years of Solitude', N'Trăm năm cô đơn'),
        (N'Love in the Time of Cholera', N'Tình yêu thời thổ tả'),
        (N'The Kite Runner', N'Người đua diều'),
        (N'A Thousand Splendid Suns', N'Ngàn mặt trời rực rỡ'),
        (N'The Book Thief', N'Kẻ trộm sách'),
        (N'Life of Pi', N'Cuộc đời của Pi'),
        (N'The Road', N'Cha và con'),
        (N'The Martian', N'Người về từ Sao Hỏa'),
        (N'Project Hail Mary', N'Dự án Hail Mary'),
        (N'Dune', N'Xứ cát'),
        (N'Fahrenheit 451', N'451 độ F'),
        (N'Brave New World', N'Thế giới mới tươi đẹp'),
        (N'The Handmaid''s Tale', N'Chuyện người tùy nữ'),
        (N'The Hunger Games', N'Đấu trường sinh tử'),
        (N'Catching Fire', N'Bắt lửa'),
        (N'Mockingjay', N'Húng nhại'),
        (N'The Fault in Our Stars', N'Khi lỗi thuộc về những vì sao'),
        (N'Me Before You', N'Trước ngày em đến'),
        (N'The Notebook', N'Nhật ký tình yêu'),
        (N'A Man Called Ove', N'Người đàn ông mang tên Ove'),
        (N'Educated', N'Được học'),
        (N'Becoming', N'Chất Michelle'),
        (N'Sapiens', N'Sapiens - Lược sử loài người'),
        (N'Homo Deus', N'Homo Deus - Lược sử tương lai'),
        (N'21 Lessons for the 21st Century', N'21 bài học cho thế kỷ 21'),
        (N'Guns, Germs, and Steel', N'Súng, vi trùng và thép'),
        (N'A Brief History of Time', N'Lược sử thời gian'),
        (N'Cosmos', N'Vũ trụ'),
        (N'Astrophysics for People in a Hurry', N'Vật lý thiên văn cho người vội vã'),
        (N'The Selfish Gene', N'Gen vị kỷ'),
        (N'The Gene', N'Gen - Lịch sử và tương lai của nhân loại'),
        (N'Silent Spring', N'Mùa xuân vắng lặng'),
        (N'The Immortal Life of Henrietta Lacks', N'Cuộc đời bất tử của Henrietta Lacks'),
        (N'Why We Sleep', N'Tại sao chúng ta ngủ'),
        (N'Thinking in Systems', N'Tư duy hệ thống'),
        (N'Factfulness', N'Factfulness - Sự thật về thế giới'),
        (N'Outliers', N'Những kẻ xuất chúng'),
        (N'Blink', N'Trong chớp mắt'),
        (N'The Tipping Point', N'Điểm bùng phát'),
        (N'David and Goliath', N'David và Goliath'),
        (N'Grit', N'Bền bỉ'),
        (N'Drive', N'Động lực 3.0'),
        (N'Leaders Eat Last', N'Lãnh đạo luôn ăn sau'),
        (N'Dare to Lead', N'Dám lãnh đạo'),
        (N'Good Vibes, Good Life', N'Rung cảm tốt, đời sống tốt'),
        (N'The Subtle Art of Not Giving a F*ck', N'Nghệ thuật tinh tế của việc đếch quan tâm'),
        (N'Everything Is Figureoutable', N'Mọi chuyện đều có cách'),
        (N'The Mountain Is You', N'Bạn chính là ngọn núi'),
        (N'Attached', N'Gắn bó yêu thương'),
        (N'The Gifts of Imperfection', N'Những món quà của sự không hoàn hảo'),
        (N'The Courage to Be Disliked', N'Dám bị ghét'),
        (N'Man''s Search for Meaning', N'Đi tìm lẽ sống'),
        (N'Meditations', N'Suy tưởng'),
        (N'The Art of War', N'Binh pháp Tôn Tử'),
        (N'Letters from a Stoic', N'Những bức thư đạo đức'),
        (N'The Republic', N'Cộng hòa'),
        (N'Beyond Good and Evil', N'Bên kia thiện ác'),
        (N'Thus Spoke Zarathustra', N'Zarathustra đã nói như thế'),
        (N'Crime and Punishment', N'Tội ác và hình phạt'),
        (N'The Brothers Karamazov', N'Anh em nhà Karamazov'),
        (N'Anna Karenina', N'Anna Karenina'),
        (N'War and Peace', N'Chiến tranh và hòa bình'),
        (N'Les Misérables', N'Những người khốn khổ'),
        (N'The Count of Monte Cristo', N'Bá tước Monte Cristo'),
        (N'The Picture of Dorian Gray', N'Chân dung Dorian Gray'),
        (N'Dracula', N'Dracula'),
        (N'Frankenstein', N'Frankenstein'),
        (N'The Strange Case of Dr Jekyll and Mr Hyde', N'Bác sĩ Jekyll và ông Hyde'),
        (N'Around the World in Eighty Days', N'Vòng quanh thế giới trong 80 ngày'),
        (N'Twenty Thousand Leagues Under the Sea', N'Hai vạn dặm dưới biển'),
        (N'Journey to the Center of the Earth', N'Hành trình vào tâm Trái Đất'),
        (N'The Adventures of Sherlock Holmes', N'Những cuộc phiêu lưu của Sherlock Holmes'),
        (N'The Hound of the Baskervilles', N'Con chó săn của dòng họ Baskerville'),
        (N'Murder on the Orient Express', N'Án mạng trên chuyến tàu tốc hành Phương Đông'),
        (N'And Then There Were None', N'Và rồi chẳng còn ai'),
        (N'The Murder of Roger Ackroyd', N'Vụ ám sát ông Roger Ackroyd'),
        (N'The Girl with the Dragon Tattoo', N'Cô gái có hình xăm rồng'),
        (N'Gone Girl', N'Cô gái mất tích'),
        (N'The Silent Patient', N'Bệnh nhân câm lặng'),
        (N'The Da Vinci Code', N'Mật mã Da Vinci'),
        (N'Angels & Demons', N'Thiên thần và ác quỷ'),
        (N'Inferno', N'Hỏa ngục'),
        (N'Digital Fortress', N'Pháo đài số'),
        (N'The Shining', N'Ngôi nhà ma'),
        (N'It', N'Nó'),
        (N'Misery', N'Misery'),
        (N'Pet Sematary', N'Nghĩa địa thú cưng'),
        (N'The Green Mile', N'Dặm xanh'),
        (N'Men Without Women', N'Những người đàn ông không có đàn bà'),
        (N'Colorless Tsukuru Tazaki', N'Tsukuru Tazaki không màu và những năm tháng hành hương'),
        (N'The Wind-Up Bird Chronicle', N'Biên niên ký chim vặn dây cót'),
        (N'Dế Mèn Phiêu Lưu Ký', N'Dế Mèn phiêu lưu ký'),
        (N'Cho Tôi Xin Một Vé Đi Tuổi Thơ', N'Cho tôi xin một vé đi tuổi thơ'),
        (N'Mắt Biếc', N'Mắt biếc'),
        (N'Tôi Thấy Hoa Vàng Trên Cỏ Xanh', N'Tôi thấy hoa vàng trên cỏ xanh'),
        (N'Cô Gái Đến Từ Hôm Qua', N'Cô gái đến từ hôm qua'),
        (N'Ngồi Khóc Trên Cây', N'Ngồi khóc trên cây'),
        (N'Làm Bạn Với Bầu Trời', N'Làm bạn với bầu trời'),
        (N'Bắt Trẻ Đồng Xanh', N'Bắt trẻ đồng xanh'),
        (N'Vừa Nhắm Mắt Vừa Mở Cửa Sổ', N'Vừa nhắm mắt vừa mở cửa sổ'),
        (N'Thương Nhớ Mười Hai', N'Thương nhớ mười hai'),
        (N'Vang Bóng Một Thời', N'Vang bóng một thời'),
        (N'Số Đỏ', N'Số đỏ'),
        (N'Tắt Đèn', N'Tắt đèn'),
        (N'Những Ngày Thơ Ấu', N'Những ngày thơ ấu'),
        (N'Gió Lạnh Đầu Mùa', N'Gió lạnh đầu mùa'),
        (N'Hai Đứa Trẻ', N'Hai đứa trẻ'),
        (N'Vợ Nhặt', N'Vợ nhặt'),
        (N'Rừng Xà Nu', N'Rừng xà nu'),
        (N'Đất Rừng Phương Nam', N'Đất rừng phương Nam'),
        (N'Nỗi Buồn Chiến Tranh', N'Nỗi buồn chiến tranh'),
        (N'Lược Sử Thời Gian', N'Lược sử thời gian'),
        (N'Hành Trình Về Phương Đông', N'Hành trình về phương Đông'),
        (N'Sức Mạnh Của Thói Quen', N'Sức mạnh của thói quen'),
        (N'7 Nguyên Tắc Bất Biến Để Thành Công', N'7 nguyên tắc bất biến để thành công');

    UPDATE b
    SET b.title = titles.edition_title,
        b.edition_name = COALESCE(NULLIF(b.edition_name, N''), titles.edition_title),
        b.language = N'Tiếng Việt'
    FROM Books b
    JOIN @VietnameseEditionTitles titles ON titles.source_title = b.title;

    -- Các tựa vốn đã đúng tên phát hành (1984, Kitchen, Nhà giả kim,
    -- sách Việt Nam...) cũng phải có metadata ấn bản đồng nhất.
    UPDATE Books
    SET edition_name = COALESCE(NULLIF(edition_name, N''), title),
        language = N'Tiếng Việt';

    -- Thay hai bản ghi giả bằng tác phẩm thật của đúng tác giả Việt Nam.
    UPDATE b
    SET b.author_id = a.author_id,
        b.publish_year = 2020,
        b.description = N'Muôn kiếp nhân sinh trình bày các câu chuyện và suy ngẫm của Nguyên Phong về nhân quả, lựa chọn cá nhân và trách nhiệm của con người trong đời sống.'
    FROM Books b
    JOIN Authors a ON a.author_name = N'Nguyên Phong'
    WHERE b.title = N'Muôn kiếp nhân sinh';

    UPDATE Books
    SET description = N'O chuột là tập truyện đặc sắc của Tô Hoài, khắc họa sinh động thế giới loài vật và đời sống thôn quê bằng giọng kể hóm hỉnh, giàu quan sát.'
    WHERE title = N'O chuột';
    GO

    -- ================================================================
    -- DANH MỤC ẤN BẢN VIỆT NAM ĐÃ ĐỐI CHIẾU
    -- Nguồn: OPAC Thư viện Quốc gia Việt Nam (bản ghi MARC).
    -- Chỉ chấp nhận ISBN-13 thuộc nhóm Việt Nam 978-604 hoặc 978-632.
    -- Sách không có ấn bản Việt Nam được thay bằng đầu sách có thật
    -- cùng nhóm nội dung; is_replacement = 1 đánh dấu các dòng này.
    -- ================================================================
    DECLARE @VerifiedVietnameseEditions TABLE
    (
        book_id BIGINT PRIMARY KEY,
        title NVARCHAR(255) NOT NULL,
        isbn VARCHAR(13) NOT NULL UNIQUE,
        author_name NVARCHAR(100) NOT NULL,
        publisher_name NVARCHAR(150) NOT NULL,
        publish_year INT NULL,
        pages INT NULL,
        catalog_source_url NVARCHAR(1000) NOT NULL,
        is_replacement BIT NOT NULL
    );

    INSERT INTO @VerifiedVietnameseEditions
        (book_id, title, isbn, author_name, publisher_name, publish_year, pages, catalog_source_url, is_replacement)
    VALUES
        (1, N'Nhà giả kim', '9786046948506', N'Paulo Coelho', N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam', 2016, 225, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nha-gia-kim-20267184430813184907', 0),
        (2, N'Đắc nhân tâm', '9786044832159', N'Dale Carnegie', N'Nxb. Tổng hợp Tp. Hồ Chí Minh', 2025, 311, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/dac-nhan-tam-202611149540813201047', 0),
        (3, N'Tuổi trẻ đáng giá bao nhiêu?', '9786045370193', N'Rosie Nguyễn', N'Nxb. Hội Nhà văn', 2016, 285, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/tuoi-tre-dang-gia-bao-nhieu-20267220950813184907', 0),
        (4, N'Cà phê cùng Tony', '9786041097933', N'Tony Buổi Sáng', N'Nxb. Trẻ', 2018, 266, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ca-phe-cung-tony-20268020350813185517', 0),
        (5, N'Đi tìm lẽ sống', '9786045875223', N'Viktor E. Frankl', N'Nxb. Tp. Hồ Chí Minh ; Công ty Văn hoá Sáng tạo Trí Việt', 2019, 220, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/di-tim-le-song-20268157150813185813', 0),
        (6, N'Học Tiếng Việt qua văn học Việt Nam', '9786326024494', N'Trần Thị Mai Nhân', N'Đại học Sư phạm Tp. Hồ Chí Minh', 2026, 146, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/hoc-tieng-viet-qua-van-hoc-viet-nam-202611277910813200855', 1),
        (7, N'Tư duy nhanh và chậm', '9786047777167', N'Daniel Kahneman', N'Thế giới ; Công ty Sách Alpha', 2020, 611, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/tu-duy-nhanh-va-cham-20268643280813190603', 0),
        (8, N'Cha giàu, cha nghèo', '9786046534556', N'Robert T. Kiyosaki', N'Lao động Xã hội', 2018, 375, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/cha-giau-cha-ngheo-20267935400813185625', 0),
        (9, N'Giáo trình Lập trình Python', '9786047955749', N'Nguyễn Xuân Hậu', N'Kinh tế - Tài chính', 2026, 198, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/giao-trinh-lap-trinh-python-202611243650813200930', 1),
        (10, N'Muôn kiếp nhân sinh', '9786044833545', N'Nguyên Phong', N'Nxb. Tổng hợp Tp. Hồ Chí Minh', 2024, NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/muon-kiep-nhan-sinh-202610316100813194505', 0),
        (11, N'Nhà giả kim', '9786045372043', N'Paulo Coelho', N'Nxb. Hội Nhà văn ; Công ty Văn hoá và Truyền thông Nhã Nam', 2019, 225, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nha-gia-kim-20268661500813190609', 0),
        (12, N'Đắc nhân tâm', '9786044043982', N'Dale Carnegie', N'Dân trí', 2025, 263, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/dac-nhan-tam-202611056840813200415', 0),
        (13, N'Tuổi trẻ đáng giá bao nhiêu?', '9786045360002', N'Rosie Nguyễn', N'Nxb. Hội Nhà văn ; Công ty Văn hoá và Truyền thông Nhã Nam', 2020, 285, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/tuoi-tre-dang-gia-bao-nhieu-20268628890813190526', 0),
        (14, N'Cà phê cùng Tony', '9786041129825', N'Tony Buổi Sáng', N'Nxb. Trẻ', 2018, 266, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ca-phe-cung-tony-20268129060813185922', 0),
        (15, N'Đi tìm lẽ sống', '9786045890165', N'Viktor E. Frankl', N'Nxb. Tp. Hồ Chí Minh ; Công ty Văn hoá Sáng tạo Trí Việt', 2019, 220, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/di-tim-le-song-20268364430813190450', 0),
        (16, N'Kỹ năng sống cho học sinh - Tự bảo vệ bản thân', '9786044772059', N'Hiểu Linh Đinh Đang', N'Văn học', 2026, 191, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ky-nang-song-cho-hoc-sinh---tu-bao-ve-ba-202611252250813200917', 1),
        (17, N'Tư duy nhanh và chậm', '9786047744169', N'Daniel Kahneman', N'Thế giới ; Công ty Sách Alpha', 2018, 611, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/tu-duy-nhanh-va-cham-20268270980813190014', 0),
        (18, N'Rèn luyện kỹ năng sống về giao tiếp ứng xử', '9786320021468', N'Hanamaru Gakushukai', N'Dân trí', 2026, 171, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ren-luyen-ky-nang-song-ve-giao-tiep-ung-202611196920813201008', 1),
        (19, N'Thay đổi tí hon - Hiệu quả bất ngờ', '9786047796120', N'James Clear', N'Thế giới', 2021, 385, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/thay-doi-ti-hon---hieu-qua-bat-ngo-20269224700813192541', 0),
        (20, N'Làm ra làm, chơi ra chơi', '9786043010145', N'Cal Newport', N'Lao động', 2020, 353, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lam-ra-lam-choi-ra-choi-20268790710813191555', 0),
        (21, N'Tâm lý học thành công', '9786043250701', N'Carol S. Dweck', N'Lao động', 2021, 479, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/tam-ly-hoc-thanh-cong-20269077810813191831', 0),
        (22, N'Tâm lý học về tiền', '9786044015804', N'Morgan Housel', N'Dân trí', 2026, 382, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/tam-ly-hoc-ve-tien-202611202110813201119', 0),
        (23, N'Ikigai - Đi tìm lý do thức dậy mỗi sáng', '9786043114218', N'Héctor García', N'Công Thương', 2021, 202, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ikigai---di-tim-ly-do-thuc-day-moi-sang-20269084200813191818', 0),
        (24, N'Rèn luyện kỹ năng sống về học tập và phát triển tương lai', '9786320021451', N'Lại Minh Tâm', N'Dân trí', 2026, 179, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ren-luyen-ky-nang-song-ve-hoc-tap-va-pha-202611196910813201008', 1),
        (25, N'Sức mạnh của hiện tại', '9786045882528', N'Eckhart Tolle', N'Nxb. Tp. Hồ Chí Minh ; Công ty Văn hoá Sáng tạo Trí Việt', 2018, 399, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/suc-manh-cua-hien-tai-20268081590813185718', 0),
        (26, N'Nghĩ giàu làm giàu', '9786044968698', N'Napoleon Hill', N'Văn học', 2025, 391, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nghi-giau-lam-giau-202610676950813195745', 0),
        (27, N'Rèn luyện kỹ năng sống về kỷ luật bản thân', '9786320021765', N'Hanamaru Gakushukai', N'Dân trí', 2026, 187, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ren-luyen-ky-nang-song-ve-ky-luat-ban-th-202611196940813201009', 1),
        (28, N'Phương pháp giáo dục kỹ năng sống', '9786326024210', N'Mai Mỹ Hạnh', N'Đại học Sư phạm Tp. Hồ Chí Minh', 2026, 263, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/phuong-phap-giao-duc-ky-nang-song-202611271430813201127', 1),
        (29, N'Tập tô màu - Chủ đề: Kỹ năng sống', '9786044484471', N'Minh Đức', N'Nxb. Hà Nội', 2026, 15, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/tap-to-mau---chu-de-ky-nang-song-202611232940813200811', 1),
        (30, N'Bắt đầu với câu hỏi tại sao', '9786049317446', N'Simon Sinek', N'Công Thương ; Công ty Sách Thái Hà', 2019, 346, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/bat-dau-voi-cau-hoi-tai-sao-20268335980813190451', 0),
        (31, N'Không đến một', '9786041092624', N'Peter Thiel', N'Nxb. Trẻ', 2018, 273, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/khong-den-mot-20267959710813185538', 0),
        (32, N'Từ tốt đến vĩ đại', '9786041157156', N'Jim Collins', N'Nxb. Trẻ', 2020, 441, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/tu-tot-den-vi-dai-20268626890813190549', 0),
        (33, N'Khởi nghiệp tinh gọn', '9786045854761', N'Eric Ries', N'Nxb. Tp. Hồ Chí Minh', 2020, 335, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/khoi-nghiep-tinh-gon-20268848990813191119', 0),
        (34, N'Khác biệt để bứt phá', '9786045839522', N'Jason Fried', N'Nxb. Tp. Hồ Chí Minh ; Công ty Văn hoá Sáng tạo Trí Việt', 2016, 317, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/khac-biet-de-but-pha-20267058100813183802', 0),
        (35, N'Gian nan chồng chất gian nan', '9786049443985', N'Ben Horowitz', N'Khoa học xã hội', 2016, 463, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/gian-nan-chong-chat-gian-nan-20266953750813183806', 0),
        (36, N'Đường vào lập trình Python nâng cao', '9786320123575', N'Nguyễn Ngọc Giang', N'Hồng Đức', 2026, 599, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/duong-vao-lap-trinh-python-nang-cao-202611251660813200858', 1),
        (37, N'Các phương pháp lập trình hiện đại', '9786326087215', N'Huỳnh Tuấn Anh', N'Đại học Quốc gia Tp. Hồ Chí Minh', 2026, 196, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/cac-phuong-phap-lap-trinh-hien-dai-202611300910813200812', 1),
        (38, N'Lập trình não bộ', '9786320115211', N'Farrow, Dave', N'Hồng Đức', 2026, 362, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lap-trinh-nao-bo-202611154980813201053', 1),
        (39, N'Giáo trình Lập trình máy tính với ngôn ngữ C', '9786049239557', N'Hoàng Hữu Việt', N'Đại học Vinh', 2026, 301, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/giao-trinh-lap-trinh-may-tinh-voi-ngon-n-202611263540813201054', 1),
        (40, N'Giáo trình C++ & lập trình hướng đối tượng', '9786326098693', N'Phạm Văn Ất', N'Bách khoa Hà Nội', 2026, 487, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/giao-trinh-c--lap-trinh-huong-doi-tuo-202611313000813201149', 1),
        (41, N'Giáo trình Lập trình trực quan C#', '9786326341805', N'Đặng Thành Trung', N'Đại học Sư phạm', 2026, 223, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/giao-trinh-lap-trinh-truc-quan-c-202611353480828000005', 1),
        (42, N'Lập trình Python hỗ trợ học sinh THPT giải bài tập tin học', '9786044500096', N'Trần Thông Quế', N'Thông tin và Truyền Thông', 2025, 206, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lap-trinh-python-ho-tro-hoc-sinh-thpt-gi-202610678110813195858', 1),
        (43, N'Lập trình bằng ngôn ngữ LabVIEW', '9786326085532', N'Trương Quang Nghĩa', N'Đại học Quốc gia Tp. Hồ Chí Minh', 2025, NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lap-trinh-bang-ngon-ngu-labview-202611146460813201052', 1),
        (44, N'Bài tập lập trình với ngôn ngữ C++ - Từ cơ bản đến nâng cao. T.1', '9786048088798', N'Trần Thông Quế', N'Khoa học - Công nghệ - Truyền thông', 2025, 243, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/bai-tap-lap-trinh-voi-ngon-ngu-c---tu-202611210470813201135', 1),
        (45, N'Bài tập lập trình với ngôn ngữ C++ - Từ cơ bản đến nâng cao', '9786048069025', N'Trần Thông Quế', N'Thông tin và Truyền thông', 2025, NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/bai-tap-lap-trinh-voi-ngon-ngu-c---tu-202611007990813200547', 1),
        (46, N'Lập trình Python cho người mới bắt đầu', '9786044038179', N'Nguyễn Ngọc Tân', N'Dân trí', 2025, 196, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lap-trinh-python-cho-nguoi-moi-bat-dau-202611057930813200416', 1),
        (47, N'Bài tập lập trình với ngôn ngữ Python - Từ cơ bản đến nâng cao', '9786048092122', N'Trần Thông Quế', N'Thông tin và Truyền thông', 2025, NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/bai-tap-lap-trinh-voi-ngon-ngu-python---202611007980813200312', 1),
        (48, N'Lập trình vô thức', '9786326111132', N'Mai Diệu Huyền', N'Lao động', 2025, 242, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lap-trinh-vo-thuc-202610697360813195536', 1),
        (49, N'Tớ đến với lập trình ScratchJR - Tập thu âm và lồng tiếng', '9786043311686', N'Gardner, Tracy', N'Dân trí', 2025, 31, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/to-den-voi-lap-trinh-scratchjr---tap-thu-202611105730813201138', 1),
        (50, N'Thực hành lập trình PLC', '9786044889085', N'Lê Đức Dũng', N'Bách khoa Hà Nội', 2025, 145, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/thuc-hanh-lap-trinh-plc-202611086670813200828', 1),
        (51, N'Sổ tay kiến thức Tin học ôn thi tốt nghiệp THPT - Lập trình Web cơ bản', '9786326096897', N'Nguyễn Quang Đạt', N'Bách khoa Hà Nội', 2025, 207, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/so-tay-kien-thuc-tin-hoc-on-thi-tot-nghi-202611050140813200622', 1),
        (52, N'Giáo trình Lập trình symbolic trong trí tuệ nhân tạo', '9786326083316', N'Nguyễn Đình Hiển', N'Đại học Quốc gia Tp. Hồ Chí Minh', 2025, 136, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/giao-trinh-lap-trinh-symbolic-trong-tri-202611066470813200418', 1),
        (53, N'Giáo trình Lập trình Blockchain và hợp đồng thông minh', '9786047632510', N'Nguyễn Thị Khánh Tiên', N'Giao thông vận tải', 2025, 240, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/giao-trinh-lap-trinh-blockchain-va-hop-d-202611163880813201056', 1),
        (54, N'Lập trình Python', '9786044351933', N'Trần Quang Huy', N'Đại học Quốc gia Hà Nội', 2025, 278, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lap-trinh-python-202611053230813200625', 1),
        (55, N'Lập trình Java web nâng cao', '9786326084146', N'Nguyễn Hữu Trung', N'Đại học Quốc gia Tp. Hồ Chí Minh', 2025, 267, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lap-trinh-java-web-nang-cao-202611151760813201051', 1),
        (56, N'Giáo trình Lập trình hướng đối tượng với Java', '9786044519227', N'Nguyễn Đình Công', N'Khoa học - Công nghệ - Truyền thông', 2025, 299, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/giao-trinh-lap-trinh-huong-doi-tuong-voi-202611208260813201141', 1),
        (57, N'Lập trình nhúng và triển khai ứng dụng IoT', '9786326272154', N'Dương Thị Thùy Vân', N'Đại học Huế', 2025, 184, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lap-trinh-nhung-va-trien-khai-ung-dung-i-202611269720813200919', 1),
        (58, N'Lập trình Java web cơ bản', '9786326084481', N'Nguyễn Hữu Trung', N'Đại học Quốc gia Tp. Hồ Chí Minh', 2025, 383, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lap-trinh-java-web-co-ban-202611151820813201051', 1),
        (59, N'Giáo trình Nhập môn lập trình', '9786326084535', N'Dương Thị Mộng Thùy', N'Đại học Quốc gia Tp. Hồ Chí Minh', 2025, 357, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/giao-trinh-nhap-mon-lap-trinh-202611176330813200649', 1),
        (60, N'Lập trình hệ thống nhúng', '9786326085020', N'Hoàng Trang', N'Đại học Quốc gia Tp. Hồ Chí Minh', 2025, 489, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lap-trinh-he-thong-nhung-202611232200813201124', 1),
        (61, N'Thực tập lập trình điều khiển trên thiết bị di động', '9786049654664', N'Nguyễn Văn Khanh', N'Đại học Cần Thơ', 2024, 111, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/thuc-tap-lap-trinh-dieu-khien-tren-thiet-202610663770813195848', 1),
        (62, N'Lập trình báo cáo và giao việc giữa quản lý và lao động bằng Google Sheet', '9786044994468', N'Nguyễn Quang Trung', N'Lao động', 2024, 22, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lap-trinh-bao-cao-va-giao-viec-giua-quan-202610694470813195645', 1),
        (63, N'Bài giảng Lập trình C căn bản', '9786044710136', N'Đỗ Văn Uy', N'Bách khoa Hà Nội', 2023, 119, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/bai-giang-lap-trinh-c-can-ban-202610012120813193707', 1),
        (64, N'Bình luận tội phạm trong lĩnh vực công nghệ thông tin, mạng viễn thông: Những vấn đề lý luận và thực tiễn', '9786047287055', N'Đoàn Đắc Chinh', N'Công an nhân dân', 2026, 431, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/binh-luan-toi-pham-trong-linh-vuc-cong-n-202611235190813201019', 1),
        (65, N'Chuẩn kỹ năng sử dụng công nghệ thông tin cơ bản', '9786049655166', N'1064723', N'Đại học Cần Thơ', 2025, NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/chuan-ky-nang-su-dung-cong-nghe-thong-ti-202610647230813195300', 1),
        (66, N'Giáo trình Phương pháp nghiên cứu khoa học: Ứng dụng trong công nghệ thông tin', '9786326022575', N'Lê Hoàng Thái', N'Đại học Sư phạm Tp. Hồ chí Minh', 2025, 467, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/giao-trinh-phuong-phap-nghien-cuu-khoa-h-202611073160813200447', 1),
        (67, N'Tuyển tập Báo cáo Hội nghị khoa học về công nghệ thông tin, điện tử, tự động hoá, khoa học và công nghệ vũ trụ', '9786043573596', N'Cong Ngo Van', N'Khoa học Tự nhiên và Công nghệ', 2025, 449, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/tuyen-tap-bao-cao-hoi-nghi-khoa-hoc-ve-c-202610700030813195953', 1),
        (68, N'Giáo trình Công nghệ thông tin Dược', '9786326035605', N'Đỗ Quang Dương', N'Nxb. Tổng hợp Tp. Hồ Chí Minh', 2025, 159, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/giao-trinh-cong-nghe-thong-tin-duoc-202611092010813201051', 1),
        (69, N'Kỷ yếu Hội thảo khoa học quốc gia "Công nghệ thông tin trong bối cảnh chuyển đổi số: Nghiên cứu cơ bản và ứng dụng tại Việt Nam"', '9786043574425', N'Hoàng Thị Giang', N'Khoa học Tự nhiên và Công nghệ', 2025, 572, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ky-yeu-hoi-thao-khoa-hoc-quoc-gia-cong-202611035380813200607', 1),
        (70, N'Ứng dụng công nghệ thông tin và chuyển đổi số trong giáo dục mầm non', '9786040461575', N'Nguyễn Thị Nga', N'Giáo dục Việt Nam', 2025, 72, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ung-dung-cong-nghe-thong-tin-va-chuyen-d-202611114190813201053', 1),
        (71, N'Giết con chim nhại', '9786049542787', N'Harper Lee', N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam', 2017, 419, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/giet-con-chim-nhai-20267672190813184923', 0),
        (72, N'Văn học Việt Nam: Kì và thực, hài và bi', '9786326017908', N'Vũ Thanh', N'Đại học Sư phạm', 2026, 331, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/van-hoc-viet-nam-ki-va-thuc-hai-va-bi-202611269420813201021', 1),
        (73, N'Nghiên cứu văn học Việt Nam và thế giới', '9786044974675', N'Đặng Thai Mai', N'Nxb. Hội Nhà văn', 2025, NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nghien-cuu-van-hoc-viet-nam-va-the-gioi-202610973060813200503', 1),
        (74, N'Đại gia Gatsby', '9786049968426', N'F. Scott Fitzgerald', N'Nxb. Hội Nhà văn', 2020, 252, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/dai-gia-gatsby-20269257350813192020', 0),
        (75, N'Kiêu hãnh và định kiến', '9786046977421', N'Jane Austen', N'Văn học', 2016, 523, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/kieu-hanh-va-dinh-kien-20267137960813183923', 0),
        (76, N'Bắt trẻ đồng xanh', '9786045377031', N'J.D. Salinger', N'Nxb. Hội Nhà văn ; Công ty Văn hoá và Truyền thông Nhã Nam', 2016, 326, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/bat-tre-dong-xanh-20267350100813184849', 0),
        (77, N'Anh chàng Hobbit', '9786043065657', N'J.R.R. Tolkien', N'Nxb. Hội Nhà văn ; Công ty Văn hoá và Truyền thông Nhã Nam', 2020, 459, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/anh-chang-hobbit-20269257650813192021', 0),
        (78, N'Chúa tể những chiếc nhẫn', '9786043720365', N'J.R.R. Tolkien', N'Văn học', 2023, NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/chua-te-nhung-chiec-nhan-20269901330813193430', 0),
        (79, N'Harry Potter và hòn đá phù thủy', '9786041084247', N'J.K. Rowling', N'Nxb. Trẻ', 2026, 365, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/harry-potter-va-hon-da-phu-thuy-202611186100813200858', 0),
        (80, N'Harry Potter và phòng chứa bí mật', '9786041185388', N'J.K. Rowling', N'Nxb. Trẻ', 2021, 429, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/harry-potter-va-phong-chua-bi-mat-20269236620813192821', 0),
        (81, N'Harry Potter và tên tù nhân ngục Azkaban', '9786041160026', N'J.K. Rowling', N'Nxb. Trẻ', 2021, 921, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/harry-potter-va-ten-tu-nhan-nguc-azkaban-20268970180813191919', 0),
        (82, N'Harry Potter và chiếc cốc lửa', '9786041185401', N'J.K. Rowling', N'Nxb. Trẻ', 2021, 921, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/harry-potter-va-chiec-coc-lua-20269084030813191818', 0),
        (83, N'Harry Potter và Hội Phượng Hoàng', '9786041185418', N'J.K. Rowling', N'Nxb. Trẻ', 2021, 1309, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/harry-potter-va-hoi-phuong-hoang-20269084040813191818', 0),
        (84, N'Harry Potter và hoàng tử lai', '9786041185425', N'J.K. Rowling', N'Nxb. Trẻ', 2021, 715, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/harry-potter-va-hoang-tu-lai-20269077300813191805', 0),
        (85, N'Harry Potter và Bảo bối tử thần', '9786041185432', N'J.K. Rowling', N'Nxb. Trẻ', 2021, 846, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/harry-potter-va-bao-boi-tu-than-20269236840813192821', 0),
        (86, N'Hoàng tử bé', '9786326246902', N'Antoine de Saint-Exupéry', N'Văn học', 2025, 156, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/hoang-tu-be-202611171620813201125', 0),
        (87, N'Ông già và biển cả', '9786045893883', N'Ernest Hemingway', N'Nxb. Tp. Hồ Chí Minh', 2019, 247, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ong-gia-va-bien-ca-20268324460813190424', 0),
        (88, N'Nhà giả kim', '9786049900426', N'Paulo Coelho', N'Nxb. Hội Nhà văn ; Công ty Văn hoá và Truyền thông Nhã Nam', 2020, 225, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nha-gia-kim-20268628900813190526', 0),
        (89, N'Văn học Việt Nam hiện đại trình hiện và chuyển động', '9786044978154', N'Nguyễn Đăng Điệp', N'Nxb. Hội Nhà văn', 2025, 615, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/van-hoc-viet-nam-hien-dai-trinh-hien-va-202611201200813201038', 1),
        (90, N'Kafka bên bờ biển', '9786049924026', N'Haruki Murakami', N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam', 2020, 531, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/kafka-ben-bo-bien-20268659130813190531', 0),
        (91, N'Trăm năm cô đơn', '9786049766695', N'Gabriel García Márquez', N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam', 2019, 492, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/tram-nam-co-don-20268309130813190440', 0),
        (92, N'Kinh nghiệm thẩm mĩ trong văn học Việt Nam thời thuộc địa', '9786044979328', N'Phùng Kiên', N'Nxb. Hội Nhà văn', 2025, 559, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/kinh-nghiem-tham-mi-trong-van-hoc-viet-n-202611245270813200850', 1),
        (93, N'Người đua diều', '9786045623282', N'Khaled Hosseini', N'Phụ nữ ; Công ty Văn hoá và Truyền thông Nhã Nam', 2016, 457, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nguoi-dua-dieu-20267287370813184349', 0),
        (94, N'Ngàn mặt trời rực rỡ', '9786049574238', N'Khaled Hosseini', N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam', 2018, 456, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ngan-mat-troi-ruc-ro-20267948120813185631', 0),
        (95, N'Kẻ trộm sách', '9786041052079', N'Markus Zusak', N'Nxb. Trẻ ; Công ty Sách Dân trí', 2016, 571, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ke-trom-sach-20267079520813183754', 0),
        (96, N'Cuộc đời của Pi', '9786049767159', N'Yann Martel', N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam', 2019, 447, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/cuoc-doi-cua-pi-20268231960813185903', 0),
        (97, N'Sơ thảo lịch sử văn học Việt Nam. Q.3 - Thế kỷ XVIII', '9786044608099', N'Văn Tân', N'Chính trị quốc gia Sự thật', 2025, 319, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/so-thao-lich-su-van-hoc-viet-nam-q3---202611155380813200801', 1),
        (98, N'Sơ thảo lịch sử văn học Việt Nam. Q.2 - Từ thế kỷ X đến hết thế kỷ XVII', '9786044608082', N'Văn Tân', N'Chính trị quốc gia Sự thật', 2025, 362, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/so-thao-lich-su-van-hoc-viet-nam-q2---202611155360813201027', 1),
        (99, N'Sơ thảo lịch sử văn học Việt Nam. Q.1 - Phần ngữ ngôn văn tự và văn học truyền miệng', '9786044608075', N'Văn Tân', N'Chính trị quốc gia Sự thật', 2025, 314, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/so-thao-lich-su-van-hoc-viet-nam-q1---202611155340813200807', 1),
        (100, N'Sơ thảo lịch sử văn học Việt Nam. Q.5 - Giai đoạn nửa đầu thế kỷ XIX', '9786044608112', N'Văn Tân', N'Chính trị quốc gia Sự thật', 2025, 211, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/so-thao-lich-su-van-hoc-viet-nam-q5---202611155400813201120', 1),
        (101, N'451 độ F', '9786049868030', N'Ray Bradbury', N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam', 2020, 229, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/451-do-f-20268659610813190851', 0),
        (102, N'Thế giới mới tươi đẹp', '9786049548246', N'Aldous Huxley', N'Văn học ; Công ty Sách Phương Nam', 2017, 331, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/the-gioi-moi-tuoi-dep-20267674670813184755', 0),
        (103, N'Lịch sử văn học Việt Nam. T.1 - Văn học dân gian, Q.2', '9786044919485', N'Hà Minh Đức', N'Văn học', 2024, 350, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lich-su-van-hoc-viet-nam-t1---van-hoc-202610707890813195905', 1),
        (104, N'Đấu trường sinh tử', '9786049633812', N'Suzanne Collins', N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam', 2018, 400, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/dau-truong-sinh-tu-20267863530813185630', 0),
        (105, N'Lịch sử văn học Việt Nam. T.9 - Văn học Việt Nam (1945 - 1975), Q.1: 1945 - 1954', '9786044919515', N'Hà Minh Đức', N'Văn học', 2024, 299, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lich-su-van-hoc-viet-nam-t9---van-hoc-202610708010813195900', 1),
        (106, N'Lịch sử văn học Việt Nam. T.1 - Văn học dân gian, Q.3', '9786044919492', N'Hà Minh Đức', N'Văn học', 2024, 431, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lich-su-van-hoc-viet-nam-t1---van-hoc-202610707950813195900', 1),
        (107, N'Khi lỗi thuộc về những vì sao', '9786041054745', N'John Green', N'Nxb. Trẻ', 2017, 360, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/khi-loi-thuoc-ve-nhung-vi-sao-20267456980813184952', 0),
        (108, N'Trước ngày em đến', '9786041064973', N'Jojo Moyes', N'Nxb. Trẻ', 2016, 599, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/truoc-ngay-em-den-20267109340813183711', 0),
        (109, N'Lịch sử văn học Việt Nam. T.8 - Văn học Việt Nam (1930 - 1945), Q.2', '9786044919508', N'Hà Minh Đức', N'Văn học', 2024, 431, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lich-su-van-hoc-viet-nam-t8---van-hoc-202610707980813195905', 1),
        (110, N'Người đàn ông mang tên Ove', '9786041155831', N'Fredrik Backman', N'Nxb. Trẻ', 2020, 447, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nguoi-dan-ong-mang-ten-ove-20268605230813191038', 0),
        (111, N'Được học', '9786045680162', N'Tara Westover', N'Phụ nữ Việt Nam', 2021, 446, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/duoc-hoc-20269099970813191838', 0),
        (112, N'Chất Michelle', '9786045889862', N'Michelle Obama', N'Nxb. Tp. Hồ Chí Minh ; Công ty Văn hoá Sáng tạo Trí Việt', 2019, 502, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/chat-michelle-20268334370813190340', 0),
        (113, N'Steve Jobs', '9786047703739', N'Walter Isaacson', N'Thế giới ; Công ty Sách Alpha', 2011, 693, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/steve-jobs-20264801380813180025', 0),
        (114, N'Các hoạt động giáo dục kỹ năng sống cho trẻ mẫu giáo', '9786320008995', N'Đỗ Thị Huyền', N'Dân trí', 2025, 22, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/cac-hoat-dong-giao-duc-ky-nang-song-cho-202611050720813200358', 1),
        (115, N'Sapiens: Lược sử loài người', '9786049903137', N'Yuval Noah Harari', N'Tri thức', 2020, 558, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/sapiens-luoc-su-loai-nguoi-20268875790813191545', 0),
        (116, N'Homo Deus - Lược sử tương lai', '9786047774166', N'Yuval Noah Harari', N'Thế giới ; Công ty Văn hoá và Truyền thông Nhã Nam', 2020, 508, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/homo-deus---luoc-su-tuong-lai-20268629010813191100', 0),
        (117, N'21 bài học cho thế kỷ 21', '9786047774173', N'Yuval Noah Harari', N'Thế giới ; Công ty Văn hoá và Truyền thông Nhã Nam', 2020, 426, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/21-bai-hoc-cho-the-ky-21-20268643320813190603', 0),
        (118, N'Súng, vi trùng và thép', '9786047781881', N'Jared Diamond', N'Thế giới', 2020, 690, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/sung-vi-trung-va-thep-20268857810813191512', 0),
        (119, N'Lược sử thời gian', '9786041127630', N'Stephen Hawking', N'Nxb. Trẻ', 2019, 282, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/luoc-su-thoi-gian-20268281130813190036', 0),
        (120, N'100 kỹ năng sống dạy con trong gia đình. T.1', '9786044341170', N'Bùi Văn Trực', N'Đại học Quốc gia Hà Nội', 2025, 262, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/100-ky-nang-song-day-con-trong-gia-dinh-202610849920813195552', 1),
        (121, N'Vật lý thiên văn cho người vội vã', '9786047759170', N'Neil deGrasse Tyson', N'Thế giới ; Công ty Văn hoá và Truyền thông Nhã Nam', 2019, 182, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/vat-ly-thien-van-cho-nguoi-voi-va-20268413410813190404', 0),
        (122, N'Gen vị kỷ', '9786049081170', N'Richard Dawkins', N'Tri thức', 2011, 463, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/gen-vi-ky-20264692400813175848', 0),
        (123, N'Bộ tài liệu giáo dục kỹ năng sống dành cho trẻ mầm non - Bồi dưỡng và hoàn thiện nhân cách cho trẻ về phòng tránh tai nạn thương tích thường gặp', '9786048074586', N'Nguyễn Danh Khoa', N'Thông tin và Truyền thông', 2025, 367, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/bo-tai-lieu-giao-duc-ky-nang-song-danh-c-202611217730813200953', 1),
        (124, N'Mùa xuân vắng lặng', '9786047750122', N'Rachel Carson', N'Thế giới ; Công ty Sách Phương Nam', 2018, 353, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/mua-xuan-vang-lang-20268021340813185419', 0),
        (125, N'Cuộc đời bất tử của Henrietta Lacks', '9786049719943', N'Rebecca Skloot', N'Lao động', 2018, 454, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/cuoc-doi-bat-tu-cua-henrietta-lacks-20268108360813190022', 0),
        (126, N'Bộ tài liệu giáo dục kỹ năng sống dành cho học sinh, sinh viên', '9786048074630', N'Nguyễn Danh Khoa', N'Thông tin và Truyền thông', 2025, 447, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/bo-tai-lieu-giao-duc-ky-nang-song-danh-c-202611217760813200954', 1),
        (127, N'Tư duy hệ thống', '9786326303933', N'Donella H. Meadows', N'Công Thương', 2026, 322, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/tu-duy-he-thong-202611219930813201114', 0),
        (128, N'Bộ tài liệu Giáo dục kỹ năng sống dành cho học sinh tiểu học - Bồi dưỡng và hoàn thiện nhân cách cho học sinh tiểu học, những tình huống phòng tránh tai nạn thương tích thường gặp', '9786048074623', N'Nguyễn Danh Khoa', N'Thông tin và Truyền thông', 2025, 367, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/bo-tai-lieu-giao-duc-ky-nang-song-danh-c-202611217750813200953', 1),
        (129, N'Những kẻ xuất chúng', '9786047704118', N'Malcolm Gladwell', N'Thế giới ; Công ty Sách Alpha', 2016, 359, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nhung-ke-xuat-chung-20267083520813183934', 0),
        (130, N'Trong chớp mắt', '9786047712694', N'Malcolm Gladwell', N'Thế giới ; Công ty Sách Alpha', 2018, 375, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/trong-chop-mat-20267760280813184846', 0),
        (131, N'Điểm bùng phát', '9786047752379', N'Malcolm Gladwell', N'Thế giới', 2018, 403, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/diem-bung-phat-20268085040813185636', 0),
        (132, N'Giáo dục kỹ năng sống cho trẻ 24 - 36 tháng tuổi', '9786040420732', N'Phan Vũ Quỳnh Nga', N'Giáo dục Việt Nam', 2025, 16, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/giao-duc-ky-nang-song-cho-tre-24---36-th-202611114850813200922', 1),
        (133, N'Giáo dục kỹ năng sống cho trẻ 5 - 6 tuổi', '9786040133649', N'Phan Vũ Quỳnh Nga', N'Giáo dục Việt Nam', 2025, 28, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/giao-duc-ky-nang-song-cho-tre-5---6-tuoi-202611114870813200923', 1),
        (134, N'Kỹ năng sống an toàn cho trẻ em', '9786326234763', N'Thái An', N'Phụ nữ Việt Nam', 2025, 119, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ky-nang-song-an-toan-cho-tre-em-202611287890813201032', 1),
        (135, N'Lãnh đạo luôn ăn sau cùng', '9786045936030', N'Simon Sinek', N'Lao động ; Công ty Sách Thái Hà', 2015, 314, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lanh-dao-luon-an-sau-cung-20266746520813183452', 0),
        (136, N'Dám lãnh đạo', '9786047767021', N'Brené Brown', N'Thế giới ; Công ty Sách Alpha', 2019, 471, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/dam-lanh-dao-20268460050813190427', 0),
        (137, N'Lớn lên thông minh: Kỹ năng sống cho tuổi học trò', '9786326035124', N'Bảo Đạt', N'Nxb. Tổng hợp Tp. Hồ Chí Minh', 2025, 142, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lon-len-thong-minh-ky-nang-song-cho-tuo-202611134480813201003', 1),
        (138, N'Nghệ thuật tinh tế của việc "đếch" quan tâm', '9786043070019', N'Mark Manson', N'Văn học ; Công ty Văn hoá Huy Hoàng', 2020, 282, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nghe-thuat-tinh-te-cua-viec-dech-quan-20268795210813191351', 0),
        (139, N'Kỹ năng sống dành cho học sinh - Lòng biết ơn', '9786047790319', N'Ngọc Linh', N'Thế giới ; Công ty Văn hoá Đinh Tị', 2021, 147, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ky-nang-song-danh-cho-hoc-sinh---long-bi-20269109030813191818', 1),
        (140, N'Kỹ năng sống dành cho học sinh - Biết lựa chọn', '9786047790340', N'Ngọc Linh', N'Thế giới ; Công ty Văn hoá Đinh Tị', 2021, 148, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ky-nang-song-danh-cho-hoc-sinh---biet-lu-20269109050813191818', 1),
        (141, N'Gắn bó yêu thương - Tại sao ta yêu, tại sao ta ghét?', '9786043280968', N'Amir Levine', N'Hồng Đức', 2021, 502, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/gan-bo-yeu-thuong---tai-sao-ta-yeu-tai-20269102300813191809', 0),
        (142, N'Kỹ năng sống dành cho học sinh - Sự kiên cường', '9786047790326', N'Ngọc Linh', N'Thế giới ; Công ty Văn hoá Đinh Tị', 2021, 149, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ky-nang-song-danh-cho-hoc-sinh---su-kien-20269109000813191818', 1),
        (143, N'Dám bị ghét', '9786049714696', N'Ichiro Kishimi', N'Lao động ; Công ty Văn hoá và Truyền thông Nhã Nam', 2018, 333, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/dam-bi-ghet-20268035370813185442', 0),
        (144, N'Đi tìm lẽ sống', '9786045834275', N'Viktor E. Frankl', N'Nxb. Tp. Hồ Chí Minh ; Công ty Văn hoá Sáng tạo Trí Việt', 2020, 220, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/di-tim-le-song-20268664850813190947', 0),
        (145, N'Suy tưởng', '9786049903205', N'Marcus Aurelius', N'Tri thức', 2020, 388, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/suy-tuong-20268624160813190747', 0),
        (146, N'Kỹ năng sống dành cho học sinh - Học cách "cho & nhận"', '9786047790357', N'Ngọc Linh', N'Thế giới', 2021, 157, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ky-nang-song-danh-cho-hoc-sinh---hoc-cac-20269109220813191819', 1),
        (147, N'Tập tô màu mẫu giáo - Chủ đề kỹ năng sống', '9786043055085', N'Trung Kiên', N'Mỹ thuật', 2021, 16, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/tap-to-mau-mau-giao---chu-de-ky-nang-son-20269030360813191800', 1),
        (148, N'Cộng hòa', '9786047782307', N'Plato', N'Thế giới', 2026, 722, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/cong-hoa-202611234610813200926', 0),
        (149, N'Thị hiếu thẩm mỹ công chúng văn học Việt Nam đương đại', '9786043233759', N'Võ Thị Thu Hà', N'Văn học', 2021, 279, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/thi-hieu-tham-my-cong-chung-van-hoc-viet-20269121870813191836', 1),
        (150, N'Zarathustra đã nói như thế', '9786046949084', N'Friedrich Nietzsche', N'Văn học', 2016, 544, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/zarathustra-da-noi-nhu-the-202610753510813195703', 0),
        (151, N'Tội ác và hình phạt', '9786044961682', N'Fyodor Dostoevsky', N'Văn học', 2025, 725, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/toi-ac-va-hinh-phat-202611097670813200926', 0),
        (152, N'Lược sử văn học Việt Nam', '9786045479698', N'Trần Đình Sử', N'Đại học Sư phạm', 2021, 339, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/luoc-su-van-hoc-viet-nam-20268976740813191938', 1),
        (153, N'Văn học Việt Nam từ sau Cách mạng tháng Tám 1945', '9786045471302', N'Nguyễn Văn Long', N'Đại học Sư phạm', 2020, 544, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/van-hoc-viet-nam-tu-sau-cach-mang-thang-20268849770813191524', 1),
        (154, N'Chiến tranh và hòa bình', '9786326310481', N'Leo Tolstoy', N'Văn học', 2026, NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/chien-tranh-va-hoa-binh-202611248120813201028', 0),
        (155, N'Những người khốn khổ', '9786043235708', N'Victor Hugo', N'Văn học', 2022, NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nhung-nguoi-khon-kho-20269516010813192556', 0),
        (156, N'Bá tước Monte-Cristo', '9786043684582', N'Alexandre Dumas', N'Nxb. Hội Nhà văn', 2022, NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ba-tuoc-monte-cristo-202610059570813194019', 0),
        (157, N'Chân dung Dorian Gray', '9786047765218', N'Oscar Wilde', N'Thế giới', 2019, NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/chan-dung-dorian-gray-20268430750813190246', 0),
        (158, N'Văn học Việt Nam viết về biển đảo và duyên hải (Giai đoạn 1900 - 2000)', '9786045684658', N'Lý Hoài Thu', N'Phụ nữ Việt Nam', 2020, 248, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/van-hoc-viet-nam-viet-ve-bien-dao-va-duy-20268939910813191410', 1),
        (159, N'Frankenstein - Hay Prometheus thời hiện đại', '9786042402095', N'Mary Shelley', N'Kim Đồng', 2026, 359, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/frankenstein---hay-prometheus-thoi-hien-202611186960813200835', 0),
        (160, N'Bác sĩ Jekyll và ông Hyde', '9786042107747', N'Robert Louis Stevenson', N'Kim Đồng', 2018, 53, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/bac-si-jekyll-va-ong-hyde-20267944000813185309', 0),
        (161, N'Vòng quanh thế giới trong 80 ngày', '9786049575808', N'Jules Verne', N'Văn học ; Công ty Sách và Thiết bị giáo dục Trí Tuệ', 2017, 346, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/vong-quanh-the-gioi-trong-80-ngay-20267673560813184740', 0),
        (162, N'Hai vạn dặm dưới biển', '9786049769269', N'Jules Verne', N'Văn học ; Công ty Văn hoá và Giáo dục Tân Việt', 2019, 403, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/hai-van-dam-duoi-bien-20268548880813190628', 0),
        (163, N'Hành trình vào tâm trái đất', '9786049639708', N'Jules Verne', N'Văn học', 2018, 383, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/hanh-trinh-vao-tam-trai-dat-20268163030813185913', 0),
        (164, N'Những cuộc phiêu lưu của Sherlock Holmes', '9786049635076', N'Arthur Conan Doyle', N'Văn học', 2018, 306, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nhung-cuoc-phieu-luu-cua-sherlock-holmes-20268164160813185906', 0),
        (165, N'Phan Khôi với quá trình hiện đại hoá văn học Việt Nam nửa đầu thế kỷ XX', '9786049744457', N'Hoàng Thị Hường', N'Đại học Huế', 2020, 201, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/phan-khoi-voi-qua-trinh-hien-dai-hoa-van-20268797360813191525', 1),
        (166, N'Án mạng trên chuyến tàu tốc hành phương Đông', '9786041111523', N'Agatha Christie', N'Nxb. Trẻ', 2017, 297, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/an-mang-tren-chuyen-tau-toc-hanh-phuong-20267685730813184937', 0),
        (167, N'Và rồi chẳng còn ai', '9786041188396', N'Agatha Christie', N'Nxb. Trẻ', 2021, 295, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/va-roi-chang-con-ai-20269234600813192627', 0),
        (168, N'Vụ ám sát ông Roger Ackroyd', '9786041065789', N'Agatha Christie', N'Nxb. Trẻ', 2017, 357, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/vu-am-sat-ong-roger-ackroyd-20267686040813184545', 0),
        (169, N'Cô gái có hình xăm rồng', '9786045663837', N'Stieg Larsson', N'Phụ nữ', 2019, 549, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/co-gai-co-hinh-xam-rong-20268481970813190344', 0),
        (170, N'Cô gái mất tích', '9786045922439', N'Gillian Flynn', N'Lao động ; Công ty Sách Alpha', 2014, 651, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/co-gai-mat-tich-20266482130813183046', 0),
        (171, N'Bệnh nhân câm lặng', '9786049979903', N'Alex Michaelides', N'Thanh niên ; Công ty Văn hoá Đinh Tị', 2020, 407, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/benh-nhan-cam-lang-20268795890813191236', 0),
        (172, N'Lược sử văn học Việt Nam', '9786045470244', N'Trần Đình Sử', N'Đại học Sư phạm', 2020, 435, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/luoc-su-van-hoc-viet-nam-20268901380813191447', 1),
        (173, N'Thiên thần và ác quỷ', '9786049898624', N'Dan Brown', N'Lao động ; Công ty Sách Bách Việt', 2020, 726, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/thien-than-va-ac-quy-20268644580813190549', 0),
        (174, N'Văn học các dân tộc thiểu số - Một bộ phận đặc thù của văn học Việt Nam', '9786047025794', N'Lộc Bích Kiệm', N'Văn hoá dân tộc', 2019, 487, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/van-hoc-cac-dan-toc-thieu-so---mot-bo-ph-20268449510813190320', 1),
        (175, N'Pháo đài số', '9786049815607', N'Dan Brown', N'Lao động ; Công ty Sách Bách Việt', 2019, 585, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/phao-dai-so-20268339850813190447', 0),
        (176, N'Những vấn đề về lý luận, phê bình, nghiên cứu văn học Việt Nam thế kỷ XX', '9786049805363', N'Phong Lê', N'Đại học Quốc gia Hà Nội', 2019, 749, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nhung-van-de-ve-ly-luan-phe-binh-nghie-20268551820813191059', 1),
        (177, N'Nghiên cứu văn học Việt Nam - Những khả năng và thách thức', '9786049686313', N'Trần Đình Sử', N'Đại học Quốc gia Hà Nội', 2019, 527, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nghien-cuu-van-hoc-viet-nam---nhung-kha-20268185180813185639', 1),
        (178, N'Văn học Việt Nam đổi mới - Từ những điểm nhìn tham chiếu', '9786046853817', N'Phan Tuấn Anh', N'Văn hoá Văn nghệ Tp. Hồ Chí Minh', 2019, 283, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/van-hoc-viet-nam-doi-moi---tu-nhung-diem-20268221670813185723', 1),
        (179, N'Nhật ký trong tù', '9786047763801', N'Hồ Chí Minh', N'Thế giới', 2019, NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nhat-ky-trong-tu-20268373520813190427', 1),
        (180, N'Dặm xanh', '9786044482309', N'Stephen King', N'Nxb. Hà Nội', 2026, 435, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/dam-xanh-202611227820813201018', 0),
        (181, N'Những người đàn ông không có đàn bà', '9786045344064', N'Haruki Murakami', N'Nxb. Hội Nhà văn ; Công ty Văn hoá và Truyền thông Nhã Nam', 2015, 252, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nhung-nguoi-dan-ong-khong-co-dan-ba-20266736870813183429', 0),
        (182, N'Văn hoá và văn học Việt Nam từ những góc nhìn', '9786049567261', N'Trần Thị An', N'Khoa học xã hội', 2019, 329, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/van-hoa-va-van-hoc-viet-nam-tu-nhung-goc-20268688370813190643', 1),
        (183, N'Tự sự về chiến tranh trong văn học Việt Nam đương đại', '9786049715167', N'Đỗ Hải Ninh', N'Lao động', 2018, 551, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/tu-su-ve-chien-tranh-trong-van-hoc-viet-20268109950813190027', 1),
        (184, N'Dế Mèn phiêu lưu ký', '9786042189606', N'Tô Hoài', N'Kim Đồng', 2020, 120, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/de-men-phieu-luu-ky-20268884100813191535', 0),
        (185, N'Cho tôi xin một vé đi tuổi thơ', '9786041157910', N'Nguyễn Nhật Ánh', N'Nxb. Trẻ', 2021, 207, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/cho-toi-xin-mot-ve-di-tuoi-tho-20269055690813191914', 0),
        (186, N'Mắt biếc', '9786041005143', N'Nguyễn Nhật Ánh', N'Nxb. Trẻ', 2018, 234, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/mat-biec-20267714320813184551', 0),
        (187, N'Tôi thấy hoa vàng trên cỏ xanh', '9786041116313', N'Nguyễn Nhật Ánh', N'Nxb. Trẻ', 2019, 375, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/toi-thay-hoa-vang-tren-co-xanh-20268291720813185822', 0),
        (188, N'Cô gái đến từ hôm qua', '9786041004825', N'Nguyễn Nhật Ánh', N'Nxb. Trẻ', 2017, 221, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/co-gai-den-tu-hom-qua-20267505150813184451', 0),
        (189, N'Ngồi khóc trên cây', '9786041157965', N'Nguyễn Nhật Ánh', N'Nxb. Trẻ', 2020, 341, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ngoi-khoc-tren-cay-20268625420813191033', 0),
        (190, N'Làm bạn với bầu trời', '9786041153363', N'Nguyễn Nhật Ánh', N'Nxb. Trẻ', 2019, 249, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lam-ban-voi-bau-troi-20268425100813190505', 0),
        (191, N'Bắt trẻ đồng xanh', '9786046916758', N'J.D. Salinger', N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam', 2016, 326, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/bat-tre-dong-xanh-20267184480813184907', 0),
        (192, N'Vừa nhắm mắt vừa mở cửa sổ', '9786041141094', N'Nguyễn Ngọc Thuần', N'Nxb. Trẻ', 2019, 191, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/vua-nham-mat-vua-mo-cua-so-20268324050813190423', 0),
        (193, N'Văn học Việt Nam thời Lý - Trần (Thế kỷ X - Đầu thế kỷ XV)', '9786047358885', N'Nguyễn Công Lý', N'Đại học Quốc gia Tp. Hồ Chí Minh', 2018, 636, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/van-hoc-viet-nam-thoi-ly---tran-the-ky-20267887200813185401', 1),
        (194, N'Thành ngữ Hán Việt trong văn học Việt Nam hiện đại', '9786048862381', N'Tạ Ngọc Hùng', N'Dân trí', 2018, 177, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/thanh-ngu-han-viet-trong-van-hoc-viet-na-20268130420813185654', 1),
        (195, N'Số đỏ', '9786049692932', N'Vũ Trọng Phụng', N'Văn học ; Công ty Văn hóa Truyền thông Sống', 2018, 267, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/so-do-20268161720813185702', 0),
        (196, N'Chí Phèo', '9786046947004', N'Nam Cao', N'Văn học ; Công ty Văn hoá Huy Hoàng', 2017, 207, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/chi-pheo-20267601990813184118', 0),
        (197, N'Tắt đèn', '9786326242553', N'Ngô Tất Tố', N'Văn học', 2025, 155, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/tat-den-202611094160813200934', 0),
        (198, N'Lão Hạc', '9786049541582', N'Nam Cao', N'Văn học ; Công ty Văn hoá Sáng tạo Trí Việt', 2017, 206, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lao-hac-20267602910813184637', 0),
        (199, N'Những ngày thơ ấu', '9786042138482', N'Nguyên Hồng', N'Kim Đồng', 2019, 118, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nhung-ngay-tho-au-20268245900813185755', 0),
        (200, N'Gió lạnh đầu mùa', '9786042198080', N'Thạch Lam', N'Kim Đồng', 2021, 203, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/gio-lanh-dau-mua-20269170340813192118', 0),
        (201, N'Hai đứa trẻ', '9786043231526', N'Thạch Lam', N'Văn học', 2021, 191, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/hai-dua-tre-20269102550813191810', 0),
        (202, N'Vợ nhặt', '9786049828003', N'Kim Lân', N'Văn học ; Công ty Văn hoá Đinh Tị', 2020, 207, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/vo-nhat-20268875020813191513', 0),
        (203, N'Giáo trình văn học Việt Nam hiện đại giai đoạn từ đầu thế kỷ XX đến 1930', '9786049128899', N'Hoàng Đức Khoa', N'Đại học Huế', 2018, 174, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/giao-trinh-van-hoc-viet-nam-hien-dai-gia-20267818310813184439', 1),
        (204, N'Đất rừng phương Nam', '9786042141444', N'Đoàn Giỏi', N'Kim Đồng', 2019, 303, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/dat-rung-phuong-nam-20268246240813185723', 0),
        (205, N'Nỗi buồn chiến tranh', '9786041142121', N'Bảo Ninh', N'Nxb. Trẻ', 2019, 347, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/noi-buon-chien-tranh-20268566250813191059', 0),
        (206, N'Văn học Việt Nam dòng riêng giữa nguồn chung', '9786048024888', N'Trần Ngọc Vương', N'Chưa xác định', NULL, 478, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/van-hoc-viet-nam-dong-rieng-giua-nguon-c-20267817250813184638', 1),
        (207, N'Lược sử thời gian', '9786041143920', N'Stephen Hawking', N'Nxb. Trẻ', 2019, 284, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/luoc-su-thoi-gian-20268464420813190427', 0),
        (208, N'Hành trình về phương Đông', '9786047789467', N'Nguyên Phong', N'Thế giới ; Công ty Văn hoá Sáng tạo Trí Việt', 2021, 251, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/hanh-trinh-ve-phuong-dong-20269109120813191818', 0),
        (209, N'Sức mạnh của thói quen', '9786045958643', N'Charles Duhigg', N'Lao động ; Công ty Sách Alpha', 2016, 433, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/suc-manh-cua-thoi-quen-20267259340813185223', 0),
        (210, N'Kỹ năng sống dành cho học sinh - Biết trân trọng', '9786047772995', N'Ngọc Linh', N'Thế giới ; Công ty Văn hoá Đinh Tị', 2021, 152, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ky-nang-song-danh-cho-hoc-sinh---biet-tr-20269007940813191728', 1);

    IF (SELECT COUNT(*) FROM @VerifiedVietnameseEditions) <> 210
        THROW 51000, N'Danh mục ấn bản Việt Nam phải có đúng 210 bản ghi.', 1;

    IF EXISTS (SELECT 1 FROM @VerifiedVietnameseEditions
               WHERE isbn NOT LIKE '978604%' AND isbn NOT LIKE '978632%')
        THROW 51001, N'Phát hiện ISBN không thuộc nhóm ISBN Việt Nam.', 1;

    INSERT INTO Authors(author_name, biography)
    SELECT DISTINCT verified.author_name, NULL
    FROM @VerifiedVietnameseEditions verified
    WHERE NOT EXISTS (SELECT 1 FROM Authors existing
                      WHERE existing.author_name = verified.author_name);

    INSERT INTO Publishers(publisher_name, address, phone)
    SELECT DISTINCT verified.publisher_name, N'Việt Nam', NULL
    FROM @VerifiedVietnameseEditions verified
    WHERE NOT EXISTS (SELECT 1 FROM Publishers existing
                      WHERE existing.publisher_name = verified.publisher_name);

    -- Tránh va chạm UNIQUE khi hai dòng đổi chéo ISBN trong cùng lần seed.
    UPDATE Books SET isbn = CONCAT('VN-TMP-', book_id);

    UPDATE books
    SET books.title = verified.title,
        books.edition_name = verified.title,
        books.isbn = verified.isbn,
        books.author_id = authors.author_id,
        books.publisher_id = publishers.publisher_id,
        books.legal_publisher = verified.publisher_name,
        books.publish_year = COALESCE(verified.publish_year, books.publish_year),
        books.pages = COALESCE(verified.pages, books.pages),
        books.language = N'Tiếng Việt',
        books.catalog_source_url = verified.catalog_source_url,
        books.cover_image = CASE WHEN verified.is_replacement = 1 THEN NULL ELSE books.cover_image END,
        books.description = CASE WHEN verified.is_replacement = 1
            THEN CONCAT(N'Ấn bản tiếng Việt “', verified.title,
                        N'” đã được đối chiếu với bản ghi thư mục của Thư viện Quốc gia Việt Nam.')
            ELSE books.description END
    FROM Books books
    JOIN @VerifiedVietnameseEditions verified ON verified.book_id = books.book_id
    JOIN Authors authors ON authors.author_name = verified.author_name
    JOIN Publishers publishers ON publishers.publisher_name = verified.publisher_name;

    IF EXISTS (SELECT 1 FROM Books
               WHERE isbn LIKE 'VN-TMP-%'
                  OR (isbn NOT LIKE '978604%' AND isbn NOT LIKE '978632%'))
        THROW 51002, N'Không thể chuẩn hóa đầy đủ ISBN Việt Nam cho Books.', 1;
    GO
