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
    GO

    -- ============================================
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

        -- Mỗi phiếu được gia hạn tối đa 2 lần; ứng dụng giới hạn 1-14 ngày/lần.
        renewal_count INT NOT NULL DEFAULT 0,

        last_renewed_at DATETIME2 NULL,

        CONSTRAINT CK_BorrowTickets_RenewalCount
            CHECK (renewal_count BETWEEN 0 AND 2),

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

    -- ================================================================
    -- DU LIEU DANH MUC BO SUNG VA 210 DAU SACH
    -- Thu tu: danh muc -> mot INSERT Books -> du lieu muon/tra va ban sao.
    -- ================================================================

    USE LibHub;
    GO


    -- ============================================
    -- THEM CATEGORIES MOI (bo sung the loai con thieu)
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
    -- THEM PUBLISHERS MOI
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
    -- THEM AUTHORS MOI
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

    -- ================================================================
    -- BOOKS: DU LIEU CUOI CUNG, KHONG CON BANG TAM HAY LENH VA DU LIEU
    -- ================================================================
    INSERT INTO Authors(author_name, biography)
    SELECT seed.author_name, NULL
    FROM (VALUES
        (N'1064723'),
        (N'Agatha Christie'),
        (N'Aldous Huxley'),
        (N'Alex Michaelides'),
        (N'Alexandre Dumas'),
        (N'Amir Levine'),
        (N'Antoine de Saint-Exupéry'),
        (N'Arthur Conan Doyle'),
        (N'Bảo Đạt'),
        (N'Bảo Ninh'),
        (N'Ben Horowitz'),
        (N'Brené Brown'),
        (N'Bùi Văn Trực'),
        (N'Cal Newport'),
        (N'Carol S. Dweck'),
        (N'Charles Duhigg'),
        (N'Cong Ngo Van'),
        (N'Dale Carnegie'),
        (N'Dan Brown'),
        (N'Đặng Thai Mai'),
        (N'Đặng Thành Trung'),
        (N'Daniel Kahneman'),
        (N'Đỗ Hải Ninh'),
        (N'Đỗ Quang Dương'),
        (N'Đỗ Thị Huyền'),
        (N'Đỗ Văn Uy'),
        (N'Đoàn Đắc Chinh'),
        (N'Đoàn Giỏi'),
        (N'Donella H. Meadows'),
        (N'Dương Thị Mộng Thùy'),
        (N'Dương Thị Thùy Vân'),
        (N'Eckhart Tolle'),
        (N'Eric Ries'),
        (N'Ernest Hemingway'),
        (N'F. Scott Fitzgerald'),
        (N'Farrow, Dave'),
        (N'Fredrik Backman'),
        (N'Friedrich Nietzsche'),
        (N'Fyodor Dostoevsky'),
        (N'Gabriel García Márquez'),
        (N'Gardner, Tracy'),
        (N'Gillian Flynn'),
        (N'Hà Minh Đức'),
        (N'Hanamaru Gakushukai'),
        (N'Harper Lee'),
        (N'Haruki Murakami'),
        (N'Héctor García'),
        (N'Hiểu Linh Đinh Đang'),
        (N'Hồ Chí Minh'),
        (N'Hoàng Đức Khoa'),
        (N'Hoàng Hữu Việt'),
        (N'Hoàng Thị Giang'),
        (N'Hoàng Thị Hường'),
        (N'Hoàng Trang'),
        (N'Huỳnh Tuấn Anh'),
        (N'Ichiro Kishimi'),
        (N'J.D. Salinger'),
        (N'J.K. Rowling'),
        (N'J.R.R. Tolkien'),
        (N'James Clear'),
        (N'Jane Austen'),
        (N'Jared Diamond'),
        (N'Jason Fried'),
        (N'Jim Collins'),
        (N'John Green'),
        (N'Jojo Moyes'),
        (N'Jules Verne'),
        (N'Khaled Hosseini'),
        (N'Kim Lân'),
        (N'Lại Minh Tâm'),
        (N'Lê Đức Dũng'),
        (N'Lê Hoàng Thái'),
        (N'Leo Tolstoy'),
        (N'Lộc Bích Kiệm'),
        (N'Lý Hoài Thu'),
        (N'Mai Diệu Huyền'),
        (N'Mai Mỹ Hạnh'),
        (N'Malcolm Gladwell'),
        (N'Marcus Aurelius'),
        (N'Mark Manson'),
        (N'Markus Zusak'),
        (N'Mary Shelley'),
        (N'Michelle Obama'),
        (N'Minh Đức'),
        (N'Morgan Housel'),
        (N'Nam Cao'),
        (N'Napoleon Hill'),
        (N'Neil deGrasse Tyson'),
        (N'Ngô Tất Tố'),
        (N'Ngọc Linh'),
        (N'Nguyễn Công Lý'),
        (N'Nguyễn Đăng Điệp'),
        (N'Nguyễn Danh Khoa'),
        (N'Nguyễn Đình Công'),
        (N'Nguyễn Đình Hiển'),
        (N'Nguyên Hồng'),
        (N'Nguyễn Hữu Trung'),
        (N'Nguyễn Ngọc Giang'),
        (N'Nguyễn Ngọc Tân'),
        (N'Nguyễn Ngọc Thuần'),
        (N'Nguyễn Nhật Ánh'),
        (N'Nguyên Phong'),
        (N'Nguyễn Quang Đạt'),
        (N'Nguyễn Quang Trung'),
        (N'Nguyễn Thị Khánh Tiên'),
        (N'Nguyễn Thị Nga'),
        (N'Nguyễn Văn Khanh'),
        (N'Nguyễn Văn Long'),
        (N'Nguyễn Xuân Hậu'),
        (N'Oscar Wilde'),
        (N'Paulo Coelho'),
        (N'Peter Thiel'),
        (N'Phạm Văn Ất'),
        (N'Phan Tuấn Anh'),
        (N'Phan Vũ Quỳnh Nga'),
        (N'Phong Lê'),
        (N'Phùng Kiên'),
        (N'Plato'),
        (N'Rachel Carson'),
        (N'Ray Bradbury'),
        (N'Rebecca Skloot'),
        (N'Richard Dawkins'),
        (N'Robert Louis Stevenson'),
        (N'Robert T. Kiyosaki'),
        (N'Rosie Nguyễn'),
        (N'Simon Sinek'),
        (N'Stephen Hawking'),
        (N'Stephen King'),
        (N'Stieg Larsson'),
        (N'Suzanne Collins'),
        (N'Tạ Ngọc Hùng'),
        (N'Tara Westover'),
        (N'Thạch Lam'),
        (N'Thái An'),
        (N'Tô Hoài'),
        (N'Tony Buổi Sáng'),
        (N'Trần Đình Sử'),
        (N'Trần Ngọc Vương'),
        (N'Trần Quang Huy'),
        (N'Trần Thị An'),
        (N'Trần Thị Mai Nhân'),
        (N'Trần Thông Quế'),
        (N'Trung Kiên'),
        (N'Trương Quang Nghĩa'),
        (N'Văn Tân'),
        (N'Victor Hugo'),
        (N'Viktor E. Frankl'),
        (N'Võ Thị Thu Hà'),
        (N'Vũ Thanh'),
        (N'Vũ Trọng Phụng'),
        (N'Walter Isaacson'),
        (N'Yann Martel'),
        (N'Yuval Noah Harari')
    ) seed(author_name)
    WHERE NOT EXISTS (SELECT 1 FROM Authors a WHERE a.author_name = seed.author_name);

    INSERT INTO Publishers(publisher_name, address, phone)
    SELECT seed.publisher_name, N'Việt Nam', NULL
    FROM (VALUES
        (N'Bách khoa Hà Nội'),
        (N'Chính trị quốc gia Sự thật'),
        (N'Chưa xác định'),
        (N'Công an nhân dân'),
        (N'Công Thương'),
        (N'Công Thương ; Công ty Sách Thái Hà'),
        (N'Đại học Cần Thơ'),
        (N'Đại học Huế'),
        (N'Đại học Quốc gia Hà Nội'),
        (N'Đại học Quốc gia Tp. Hồ Chí Minh'),
        (N'Đại học Sư phạm'),
        (N'Đại học Sư phạm Tp. Hồ chí Minh'),
        (N'Đại học Vinh'),
        (N'Dân trí'),
        (N'Giáo dục Việt Nam'),
        (N'Giao thông vận tải'),
        (N'Hồng Đức'),
        (N'Khoa học - Công nghệ - Truyền thông'),
        (N'Khoa học Tự nhiên và Công nghệ'),
        (N'Khoa học xã hội'),
        (N'Kim Đồng'),
        (N'Kinh tế - Tài chính'),
        (N'Lao động'),
        (N'Lao động ; Công ty Sách Alpha'),
        (N'Lao động ; Công ty Sách Bách Việt'),
        (N'Lao động ; Công ty Sách Thái Hà'),
        (N'Lao động ; Công ty Văn hoá và Truyền thông Nhã Nam'),
        (N'Lao động Xã hội'),
        (N'Mỹ thuật'),
        (N'Nxb. Hà Nội'),
        (N'Nxb. Hội Nhà văn'),
        (N'Nxb. Hội Nhà văn ; Công ty Văn hoá và Truyền thông Nhã Nam'),
        (N'Nxb. Tổng hợp Tp. Hồ Chí Minh'),
        (N'Nxb. Tp. Hồ Chí Minh'),
        (N'Nxb. Tp. Hồ Chí Minh ; Công ty Văn hoá Sáng tạo Trí Việt'),
        (N'Nxb. Trẻ'),
        (N'Nxb. Trẻ ; Công ty Sách Dân trí'),
        (N'Phụ nữ'),
        (N'Phụ nữ ; Công ty Văn hoá và Truyền thông Nhã Nam'),
        (N'Phụ nữ Việt Nam'),
        (N'Thanh niên ; Công ty Văn hoá Đinh Tị'),
        (N'Thế giới'),
        (N'Thế giới ; Công ty Sách Alpha'),
        (N'Thế giới ; Công ty Sách Phương Nam'),
        (N'Thế giới ; Công ty Văn hoá Đinh Tị'),
        (N'Thế giới ; Công ty Văn hoá Sáng tạo Trí Việt'),
        (N'Thế giới ; Công ty Văn hoá và Truyền thông Nhã Nam'),
        (N'Thông tin và Truyền thông'),
        (N'Tri thức'),
        (N'Văn hoá dân tộc'),
        (N'Văn hoá Văn nghệ Tp. Hồ Chí Minh'),
        (N'Văn học'),
        (N'Văn học ; Công ty Sách Phương Nam'),
        (N'Văn học ; Công ty Sách và Thiết bị giáo dục Trí Tuệ'),
        (N'Văn học ; Công ty Văn hoá Đinh Tị'),
        (N'Văn học ; Công ty Văn hoá Huy Hoàng'),
        (N'Văn học ; Công ty Văn hoá Sáng tạo Trí Việt'),
        (N'Văn học ; Công ty Văn hóa Truyền thông Sống'),
        (N'Văn học ; Công ty Văn hoá và Giáo dục Tân Việt'),
        (N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam')
    ) seed(publisher_name)
    WHERE NOT EXISTS (SELECT 1 FROM Publishers p WHERE p.publisher_name = seed.publisher_name);
    GO

    INSERT INTO Books
    (title, isbn, publish_year, description, cover_image, language, pages,
     category_id, author_id, publisher_id, is_featured, is_hidden,
     edition_name, legal_publisher, publishing_partner, catalog_source_url)
    VALUES
        (N'7 thói quen của người thành đạt', '9786040000064', 2006, N'7 thói quen của người thành đạt là tác phẩm của Stephen R. Covey, thuộc nhóm Kỹ năng sống; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', '7-thoi-quen-cua-nguoi-thanh-dat.jpg', N'Tiếng Việt', 402, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Stephen R. Covey'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Cha giàu, cha nghèo', N'9786046534556', 2018, N'Robert T. Kiyosaki đối chiếu hai cách nhìn về tiền bạc, tài sản và giáo dục tài chính để khuyến khích người đọc chủ động xây dựng tư duy quản lý tiền và đầu tư dài hạn.', N'cha-giau-cha-ngheo.jpg', N'Tiếng Việt', 375, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Robert T. Kiyosaki'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Lao động Xã hội'), 0, 0, N'Cha giàu, cha nghèo', N'Lao động Xã hội', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/cha-giau-cha-ngheo-20267935400813185625'),
        (N'Essentialism', '9786040000149', 2014, N'Essentialism là tác phẩm của Greg McKeown, thuộc nhóm Kỹ năng sống; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'essentialism.jpg', N'Tiếng Anh', 278, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Greg McKeown'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Muôn kiếp nhân sinh', N'9786044833545', 2024, N'Muôn kiếp nhân sinh trình bày các câu chuyện và suy ngẫm của Nguyên Phong về nhân quả, lựa chọn cá nhân và trách nhiệm của con người trong đời sống.', N'Muon-kiep-nhan-sinh.jpg', N'Tiếng Việt', 408, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyên Phong'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Tổng hợp Tp. Hồ Chí Minh'), 0, 0, N'Muôn kiếp nhân sinh', N'Nxb. Tổng hợp Tp. Hồ Chí Minh', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/muon-kiep-nhan-sinh-202610316100813194505'),
        (N'Nhà giả kim', N'9786045372043', 2019, N'Qua hành trình rời quê nhà của chàng chăn cừu Santiago để đi tìm kho báu bên Kim Tự Tháp, tiểu thuyết kể về lòng can đảm theo đuổi ước mơ, khả năng lắng nghe trực giác và cách mỗi trải nghiệm trên đường đời góp phần tạo nên ý nghĩa của đích đến. Lối kể cô đọng, giàu tính ngụ ngôn khiến tác phẩm phù hợp với độc giả trẻ lẫn người trưởng thành đang đứng trước một lựa chọn lớn.', N'nha-gia-kim.jpg', N'Tiếng Việt', 225, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Paulo Coelho'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Hội Nhà văn ; Công ty Văn hoá và Truyền thông Nhã Nam'), 0, 0, N'Nhà giả kim', N'Nxb. Hội Nhà văn ; Công ty Văn hoá và Truyền thông Nhã Nam', N'Công ty Cổ phần Văn hóa và Truyền thông Nhã Nam', N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nha-gia-kim-20268661500813190609'),
        (N'Đắc nhân tâm', N'9786044043982', 2025, N'Tác phẩm hệ thống hóa những nguyên tắc giao tiếp bền vững: tôn trọng người đối diện, ghi nhận chân thành, nhìn vấn đề từ góc độ của họ và góp ý mà không làm tổn thương lòng tự trọng. Thay vì đưa ra mẹo ứng xử ngắn hạn, sách dùng nhiều tình huống thực tế để chỉ ra cách xây dựng thiện cảm, giải quyết bất đồng và tạo ảnh hưởng tích cực trong công việc cũng như đời sống.', N'dac-nhan-tam.jpg', N'Tiếng Việt', 263, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Dale Carnegie'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Dân trí'), 0, 0, N'Đắc nhân tâm', N'Dân trí', N'Công ty TNHH Văn hóa và Truyền thông Trí Việt (First News)', N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/dac-nhan-tam-202611056840813200415'),
        (N'Tuổi trẻ đáng giá bao nhiêu?', N'9786045360002', 2020, N'Rosie Nguyễn viết từ trải nghiệm học tập, làm việc và đi nhiều nơi để trò chuyện thẳng thắn với người trẻ về ba nền tảng: học chủ động, làm việc có kỷ luật và dấn thân để hiểu chính mình. Những chương ngắn về đọc sách, rèn kỹ năng, đi để trưởng thành và lựa chọn con đường riêng tạo nên một cuốn cẩm nang gần gũi, khuyến khích độc giả biến quãng tuổi trẻ thành quá trình tích lũy có mục tiêu.', N'tuoi-tre-dang-gia-bao-nhieu.jpg', N'Tiếng Việt', 285, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Rosie Nguyễn'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Hội Nhà văn ; Công ty Văn hoá và Truyền thông Nhã Nam'), 0, 0, N'Tuổi trẻ đáng giá bao nhiêu?', N'Nxb. Hội Nhà văn ; Công ty Văn hoá và Truyền thông Nhã Nam', N'Công ty Cổ phần Văn hóa và Truyền thông Nhã Nam', N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/tuoi-tre-dang-gia-bao-nhieu-20268628890813190526'),
        (N'Cà phê cùng Tony', N'9786041129825', 2018, N'Tập sách tuyển chọn những bài viết dí dỏm của Tony Buổi Sáng về học tập, nghề nghiệp, văn hóa ứng xử và tinh thần tự lập. Giọng kể hài hước nhưng thực tế dẫn người đọc từ các thói quen nhỏ như đọc, học ngoại ngữ và quản lý thời gian đến thái độ dám đi, dám làm và chịu trách nhiệm với lựa chọn của mình; đặc biệt phù hợp với sinh viên và người mới bước vào môi trường làm việc.', N'ca-phe-cung-tony.jpg', N'Tiếng Việt', 266, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Tony Buổi Sáng'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Cà phê cùng Tony', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ca-phe-cung-tony-20268129060813185922'),
        (N'Đi tìm lẽ sống', N'9786045890165', 2019, N'Từ trải nghiệm sống sót trong trại tập trung, Viktor Frankl lý giải vì sao con người vẫn có thể lựa chọn thái độ và tìm thấy ý nghĩa ngay giữa đau khổ cùng cực. Tác phẩm do Viktor E. Frankl viết; ấn bản 2005 có 365 trang, trình bày bằng tiếng việt và do NXB Trẻ phát hành.', N'd-tim-le-song.jpg', N'Tiếng Việt', 220, (SELECT category_id FROM Categories WHERE category_name = N'Hồi ký'), (SELECT author_id FROM Authors WHERE author_name = N'Viktor E. Frankl'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Tp. Hồ Chí Minh ; Công ty Văn hoá Sáng tạo Trí Việt'), 0, 0, N'Đi tìm lẽ sống', N'Nxb. Tp. Hồ Chí Minh ; Công ty Văn hoá Sáng tạo Trí Việt', N'Công ty TNHH Công nghệ WEWE', N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/di-tim-le-song-20268364430813190450'),
        (N'The 5 AM Club', '9786040000187', 2018, N'The 5 AM Club là tác phẩm của Robin Sharma, thuộc nhóm Kỹ năng sống; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'the-5-am-club.jpg', N'Tiếng Anh', 426, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Robin Sharma'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Tư duy nhanh và chậm', N'9786047744169', 2018, N'Daniel Kahneman khám phá hai hệ thống chi phối tư duy, qua đó giải thích những thiên kiến khiến con người phán đoán nhanh, sai lệch và thường quá tự tin. Tác phẩm do Daniel Kahneman viết; ấn bản 2007 có 439 trang, trình bày bằng tiếng anh và do Thái Hà Books phát hành.', N'tu-duy-nhanh-va-cham.jpg', N'Tiếng Việt', 611, (SELECT category_id FROM Categories WHERE category_name = N'Tâm lý học'), (SELECT author_id FROM Authors WHERE author_name = N'Daniel Kahneman'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thế giới ; Công ty Sách Alpha'), 0, 0, N'Tư duy nhanh và chậm', N'Thế giới ; Công ty Sách Alpha', N'Công ty Cổ phần Fonos', N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/tu-duy-nhanh-va-cham-20268270980813190014'),
        (N'Make Time', '9786040000194', 2019, N'Make Time là tác phẩm của Jake Knapp, thuộc nhóm Kỹ năng sống; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'make-time.jpg', N'Tiếng Anh', 463, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Jake Knapp'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Thay đổi tí hon - Hiệu quả bất ngờ', N'9786047796120', 2021, N'James Clear chứng minh thay đổi nhỏ nhưng đều đặn có thể tạo kết quả lớn, đồng thời đưa ra hệ thống thiết kế môi trường và bản sắc để duy trì thói quen tốt. Tác phẩm do James Clear viết; ấn bản 2009 có 513 trang, trình bày bằng tiếng anh và do First News phát hành.', N'atomic-habits-en.jpg', N'Tiếng Việt', 385, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'James Clear'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thế giới'), 0, 0, N'Thay đổi tí hon - Hiệu quả bất ngờ', N'Thế giới', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/thay-doi-ti-hon---hieu-qua-bat-ngo-20269224700813192541'),
        (N'Làm ra làm, chơi ra chơi', N'9786043010145', 2020, N'Cal Newport bảo vệ năng lực tập trung sâu giữa thời đại xao nhãng và hướng dẫn cách tổ chức công việc để tạo ra giá trị cao trong thời gian hữu hạn. Tác phẩm do Cal Newport viết; ấn bản 2010 có 550 trang, trình bày bằng tiếng anh và do First News phát hành.', N'deep-work.jpg', N'Tiếng Việt', 353, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Cal Newport'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Lao động'), 0, 0, N'Làm ra làm, chơi ra chơi', N'Lao động', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lam-ra-lam-choi-ra-choi-20268790710813191555'),
        (N'Tâm lý học thành công', N'9786043250701', 2021, N'Carol Dweck phân biệt tư duy cố định với tư duy phát triển, cho thấy cách niềm tin về năng lực ảnh hưởng đến việc học, thành tích và khả năng đứng dậy sau thất bại. Tác phẩm do Carol S. Dweck viết; ấn bản 2011 có 587 trang, trình bày bằng tiếng anh và do Thái Hà Books phát hành.', N'mindset.jpg', N'Tiếng Việt', 479, (SELECT category_id FROM Categories WHERE category_name = N'Tâm lý học'), (SELECT author_id FROM Authors WHERE author_name = N'Carol S. Dweck'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Lao động'), 0, 0, N'Tâm lý học thành công', N'Lao động', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/tam-ly-hoc-thanh-cong-20269077810813191831'),
        (N'Tâm lý học về tiền', N'9786044015804', 2026, N'Morgan Housel kể những câu chuyện ngắn về lòng tham, rủi ro và sự đủ đầy, nhấn mạnh rằng thành công tài chính phụ thuộc vào hành vi hơn là kiến thức tính toán. Tác phẩm do Morgan Housel viết; ấn bản 2012 có 204 trang, trình bày bằng tiếng anh và do Alphabooks phát hành.', N'the-psychology-of-money.jpg', N'Tiếng Việt', 382, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Morgan Housel'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Dân trí'), 0, 0, N'Tâm lý học về tiền', N'Dân trí', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/tam-ly-hoc-ve-tien-202611202110813201119'),
        (N'Ikigai - Đi tìm lý do thức dậy mỗi sáng', N'9786043114218', 2021, N'Cuốn sách tìm hiểu ikigai của người Nhật—lý do khiến ta muốn thức dậy mỗi sáng—qua sự giao thoa giữa đam mê, năng lực, cộng đồng và nhịp sống bền vững. Tác phẩm do Héctor García viết; ấn bản 2013 có 241 trang, trình bày bằng tiếng anh và do First News phát hành.', N'ikigai.jpg', N'Tiếng Việt', 202, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Héctor García'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Công Thương'), 0, 0, N'Ikigai - Đi tìm lý do thức dậy mỗi sáng', N'Công Thương', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ikigai---di-tim-ly-do-thuc-day-moi-sang-20269084200813191818'),
        (N'Clean Code', '9786040000262', 2001, N'Clean Code là tác phẩm của Robert C. Martin, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'clean-code.jpg', N'Tiếng Anh', 302, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Robert C. Martin'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Addison Wesley'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Sức mạnh của hiện tại', N'9786045882528', 2018, N'Eckhart Tolle dẫn người đọc trở về hiện tại, quan sát cái tôi và dòng suy nghĩ để thoát khỏi lo âu do quá khứ cùng tương lai tạo nên. Tác phẩm do Eckhart Tolle viết; ấn bản 2015 có 315 trang, trình bày bằng tiếng anh và do First News phát hành.', N'the-power-of-now.jpg', N'Tiếng Việt', 399, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Eckhart Tolle'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Tp. Hồ Chí Minh ; Công ty Văn hoá Sáng tạo Trí Việt'), 0, 0, N'Sức mạnh của hiện tại', N'Nxb. Tp. Hồ Chí Minh ; Công ty Văn hoá Sáng tạo Trí Việt', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/suc-manh-cua-hien-tai-20268081590813185718'),
        (N'Nghĩ giàu làm giàu', N'9786044968698', 2025, N'Napoleon Hill tổng hợp những nguyên tắc về mục tiêu, niềm tin, quyết tâm và sức mạnh cộng tác nhằm biến khát vọng thành một kế hoạch hành động rõ ràng. Tác phẩm do Napoleon Hill viết; ấn bản 2016 có 352 trang, trình bày bằng tiếng anh và do Alphabooks phát hành.', N'think-and-grow-rich.jpg', N'Tiếng Việt', 391, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Napoleon Hill'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học'), 0, 0, N'Nghĩ giàu làm giàu', N'Văn học', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nghi-giau-lam-giau-202610676950813195745'),
        (N'Clean Architecture', '9786040000279', 2002, N'Clean Architecture là tác phẩm của Robert C. Martin, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'clean-architecture.jpg', N'Tiếng Anh', 339, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Robert C. Martin'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Pearson'), 0, 0, NULL, NULL, NULL, NULL),
        (N'The Pragmatic Programmer', '9786040000286', 2003, N'The Pragmatic Programmer là tác phẩm của Andrew Hunt, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'the-pragmatic-programmer.jpg', N'Tiếng Anh', 376, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Andrew Hunt'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Addison Wesley'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Design Patterns', '9786040000293', 2004, N'Design Patterns là tác phẩm của Erich Gamma, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'design-patterns.jpg', N'Tiếng Anh', 413, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Erich Gamma'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Addison Wesley'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Bắt đầu với câu hỏi tại sao', N'9786049317446', 2019, N'Simon Sinek cho rằng tổ chức truyền cảm hứng luôn bắt đầu từ lý do tồn tại, trước khi nói đến cách làm hay sản phẩm họ bán. Tác phẩm do Simon Sinek viết; ấn bản 2020 có 500 trang, trình bày bằng tiếng anh và do Alphabooks phát hành.', N'start-with-why.jpg', N'Tiếng Việt', 346, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Simon Sinek'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Công Thương ; Công ty Sách Thái Hà'), 0, 0, N'Bắt đầu với câu hỏi tại sao', N'Công Thương ; Công ty Sách Thái Hà', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/bat-dau-voi-cau-hoi-tai-sao-20268335980813190451'),
        (N'Không đến một', N'9786041092624', 2018, N'Peter Thiel bàn về những doanh nghiệp tạo bước nhảy từ không đến một bằng công nghệ độc quyền, tư duy khác biệt và khả năng xây dựng tương lai chưa từng có. Tác phẩm do Peter Thiel viết; ấn bản 2021 có 537 trang, trình bày bằng tiếng anh và do Alphabooks phát hành.', N'zero-to-one.jpg', N'Tiếng Việt', 273, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Peter Thiel'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Không đến một', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/khong-den-mot-20267959710813185538'),
        (N'Từ tốt đến vĩ đại', N'9786041157156', 2020, N'Jim Collins phân tích vì sao một số công ty vượt từ tốt đến xuất sắc nhờ lãnh đạo khiêm nhường, đúng người và kỷ luật nhất quán. Tác phẩm do Jim Collins viết; ấn bản 2022 có 574 trang, trình bày bằng tiếng anh và do Alphabooks phát hành.', N'good-to-great.jpg', N'Tiếng Việt', 441, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Jim Collins'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Từ tốt đến vĩ đại', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/tu-tot-den-vi-dai-20268626890813190549'),
        (N'Khởi nghiệp tinh gọn', N'9786045854761', 2020, N'Eric Ries giới thiệu vòng lặp xây dựng–đo lường–học hỏi, giúp startup kiểm chứng giả định nhanh và tránh lãng phí nguồn lực vào sản phẩm không ai cần. Tác phẩm do Eric Ries viết; ấn bản 2023 có 191 trang, trình bày bằng tiếng anh và do Alphabooks phát hành.', N'the-lean-startup.jpg', N'Tiếng Việt', 335, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Eric Ries'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Tp. Hồ Chí Minh'), 0, 0, N'Khởi nghiệp tinh gọn', N'Nxb. Tp. Hồ Chí Minh', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/khoi-nghiep-tinh-gon-20268848990813191119'),
        (N'Khác biệt để bứt phá', N'9786045839522', 2016, N'Jason Fried và David Heinemeier Hansson thách thức các giáo điều kinh doanh quen thuộc, cổ vũ đội ngũ nhỏ, làm ít hơn và đưa sản phẩm ra thị trường sớm. Tác phẩm do Jason Fried viết; ấn bản 2024 có 228 trang, trình bày bằng tiếng anh và do Alphabooks phát hành.', N'rework.jpg', N'Tiếng Việt', 317, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Jason Fried'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Tp. Hồ Chí Minh ; Công ty Văn hoá Sáng tạo Trí Việt'), 0, 0, N'Khác biệt để bứt phá', N'Nxb. Tp. Hồ Chí Minh ; Công ty Văn hoá Sáng tạo Trí Việt', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/khac-biet-de-but-pha-20267058100813183802'),
        (N'Gian nan chồng chất gian nan', N'9786049443985', 2016, N'Ben Horowitz kể thẳng về những quyết định cô độc của người điều hành khi công ty khủng hoảng, từ sa thải nhân sự đến giữ tổ chức sống sót. Tác phẩm do Ben Horowitz viết; ấn bản 2000 có 265 trang, trình bày bằng tiếng anh và do Alphabooks phát hành.', N'the-hard-thing-about-hard-things.jpg', N'Tiếng Việt', 463, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Ben Horowitz'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Khoa học xã hội'), 0, 0, N'Gian nan chồng chất gian nan', N'Khoa học xã hội', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/gian-nan-chong-chat-gian-nan-20266953750813183806'),
        (N'Refactoring', '9786040000309', 2005, N'Refactoring là tác phẩm của Martin Fowler, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'refactoring.jpg', N'Tiếng Anh', 450, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Martin Fowler'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Addison Wesley'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Effective Java', '9786040000316', 2006, N'Effective Java là tác phẩm của Joshua Bloch, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'effective-java.jpg', N'Tiếng Anh', 487, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Joshua Bloch'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Addison Wesley'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Head First Java', '9786040000323', 2007, N'Head First Java là tác phẩm của Kathy Sierra, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'head-first-java.jpg', N'Tiếng Anh', 524, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Kathy Sierra'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'O''Reilly Media'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Spring in Action', '9786040000347', 2009, N'Spring in Action là tác phẩm của Craig Walls, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'spring-in-action.jpg', N'Tiếng Anh', 598, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Craig Walls'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Manning Publications'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Spring Boot in Action', '9786040000354', 2010, N'Spring Boot in Action là tác phẩm của Craig Walls, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'spring-boot-in-action.jpg', N'Tiếng Anh', 215, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Craig Walls'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Manning Publications'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Learning React', '9786040000361', 2011, N'Learning React là tác phẩm của Alex Banks, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'learning-react.jpg', N'Tiếng Anh', 252, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Alex Banks'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'O''Reilly Media'), 0, 0, NULL, NULL, NULL, NULL),
        (N'React Quickly', '9786040000378', 2012, N'React Quickly là tác phẩm của Azat Mardan, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'react-quickly.jpg', N'Tiếng Anh', 289, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Azat Mardan'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Manning Publications'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Fullstack React', '9786040000385', 2013, N'Fullstack React là tác phẩm của Anthony Accomazzo, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'fullstack-react.jpg', N'Tiếng Anh', 326, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Anthony Accomazzo'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'O''Reilly Media'), 0, 0, NULL, NULL, NULL, NULL),
        (N'You Don''t Know JS', '9786040000392', 2014, N'You Don''t Know JS là tác phẩm của Kyle Simpson, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'You-Dont-know-js.jpg', N'Tiếng Anh', 363, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Kyle Simpson'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'O''Reilly Media'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Eloquent JavaScript', '9786040000408', 2015, N'Eloquent JavaScript là tác phẩm của Marijn Haverbeke, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'eloquent-javascript.jpg', N'Tiếng Anh', 400, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Marijn Haverbeke'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'No Starch Press'), 0, 0, NULL, NULL, NULL, NULL),
        (N'JavaScript: The Definitive Guide', '9786040000415', 2016, N'JavaScript: The Definitive Guide là tác phẩm của David Flanagan, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'javascript-the-definitive-guide.jpg', N'Tiếng Anh', 437, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'David Flanagan'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'O''Reilly Media'), 0, 0, NULL, NULL, NULL, NULL),
        (N'HTML and CSS', '9786040000422', 2017, N'HTML and CSS là tác phẩm của Jon Duckett, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'html-and-css.jpg', N'Tiếng Anh', 474, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Jon Duckett'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Pearson'), 0, 0, NULL, NULL, NULL, NULL),
        (N'CSS Secrets', '9786040000439', 2018, N'CSS Secrets là tác phẩm của Lea Verou, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'css-secrets.jpg', N'Tiếng Anh', 511, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Lea Verou'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'O''Reilly Media'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Don''t Make Me Think', '9786040000446', 2019, N'Don''t Make Me Think là tác phẩm của Steve Krug, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'dont-make-me-think.jpg', N'Tiếng Anh', 548, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Steve Krug'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Pearson'), 0, 0, NULL, NULL, NULL, NULL),
        (N'The UX Book', '9786040000453', 2020, N'The UX Book là tác phẩm của Rex Hartson, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'the-ux-book.jpg', N'Tiếng Anh', 585, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Rex Hartson'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Pearson'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Introduction to Algorithms', '9786040000460', 2021, N'Introduction to Algorithms là tác phẩm của Thomas H. Cormen, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'introduction-to-algorithms.jpg', N'Tiếng Anh', 202, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Thomas H. Cormen'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Pearson'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Database System Concepts', '9786040000484', 2023, N'Database System Concepts là tác phẩm của Abraham Silberschatz, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'database-system-concepts.jpg', N'Tiếng Anh', 276, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Abraham Silberschatz'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Pearson'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Designing Data-Intensive Applications', '9786040000491', 2024, N'Designing Data-Intensive Applications là tác phẩm của Martin Kleppmann, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'designing-data-intensive-applications.jpg', N'Tiếng Anh', 313, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Martin Kleppmann'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'O''Reilly Media'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Computer Networking', '9786040000507', 2000, N'Computer Networking là tác phẩm của James F. Kurose, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'computer-networking.jpg', N'Tiếng Anh', 350, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'James F. Kurose'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Pearson'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Operating System Concepts', '9786040000514', 2001, N'Operating System Concepts là tác phẩm của Abraham Silberschatz, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'operating-system-concepts.jpg', N'Tiếng Anh', 387, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Abraham Silberschatz'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Pearson'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Computer Systems: A Programmer''s Perspective', '9786040000521', 2002, N'Computer Systems: A Programmer''s Perspective là tác phẩm của Randal E. Bryant, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'computer-systems-a-programmers-perspective.jpg', N'Tiếng Anh', 424, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Randal E. Bryant'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Pearson'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Artificial Intelligence: A Modern Approach', '9786040000538', 2003, N'Artificial Intelligence: A Modern Approach là tác phẩm của Stuart Russell, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'artificial-intelligence-a-modern-approach.jpg', N'Tiếng Anh', 461, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Stuart Russell'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Pearson'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Deep Learning', '9786040000545', 2004, N'Deep Learning là tác phẩm của Ian Goodfellow, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'deep-learning.jpg', N'Tiếng Anh', 498, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Ian Goodfellow'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'MIT Press'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Hands-On Machine Learning', '9786040000552', 2005, N'Hands-On Machine Learning là tác phẩm của Aurélien Géron, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'hands-on-machine-learning.jpg', N'Tiếng Anh', 535, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Aurélien Géron'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'O''Reilly Media'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Python Crash Course', '9786040000569', 2006, N'Python Crash Course là tác phẩm của Eric Matthes, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'python-crash-course.jpg', N'Tiếng Anh', 572, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Eric Matthes'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'No Starch Press'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Fluent Python', '9786040000583', 2008, N'Fluent Python là tác phẩm của Luciano Ramalho, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'fluent-python.jpg', N'Tiếng Anh', 226, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Luciano Ramalho'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'O''Reilly Media'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Effective Python', '9786040000590', 2009, N'Effective Python là tác phẩm của Brett Slatkin, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'effective-python.jpg', N'Tiếng Anh', 263, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Brett Slatkin'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Addison Wesley'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Learning Python', '9786040000606', 2010, N'Learning Python là tác phẩm của Mark Lutz, thuộc nhóm Công nghệ; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'learning-python.jpg', N'Tiếng Anh', 300, (SELECT category_id FROM Categories WHERE category_name = N'Công nghệ'), (SELECT author_id FROM Authors WHERE author_name = N'Mark Lutz'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'O''Reilly Media'), 0, 0, NULL, NULL, NULL, NULL),
        (N'1984', '9786040000620', 2012, N'1984 là tác phẩm của George Orwell, thuộc nhóm Khoa học viễn tưởng; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', '1984.jpg', N'Tiếng Anh', 374, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'George Orwell'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Animal Farm', '9786040000637', 2013, N'Animal Farm là tác phẩm của George Orwell, thuộc nhóm Văn học kinh điển; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'animal-farm.jpg', N'Tiếng Anh', 411, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'George Orwell'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0, NULL, NULL, NULL, NULL),
        (N'The Catcher in the Rye', '9786040000668', 2016, N'The Catcher in the Rye là tác phẩm của J.D. Salinger, thuộc nhóm Văn học kinh điển; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'the-catcher-in-the-rye.jpg', N'Tiếng Anh', 522, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'J.D. Salinger'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0, NULL, NULL, NULL, NULL),
        (N'The Alchemist', '9786040000781', 2003, N'The Alchemist là tác phẩm của Paulo Coelho, thuộc nhóm Tiểu thuyết; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'the-alchemist.jpg', N'Tiếng Anh', 546, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Paulo Coelho'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Kitchen', '9786040000798', 2004, N'Kitchen là tác phẩm của Banana Yoshimoto, thuộc nhóm Tiểu thuyết; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'kitchen.jpg', N'Tiếng Anh', 583, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Banana Yoshimoto'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Love in the Time of Cholera', '9786040000828', 2007, N'Love in the Time of Cholera là tác phẩm của Gabriel García Márquez, thuộc nhóm Tiểu thuyết; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'love-in-the-time-of-cholera.jpg', N'Tiếng Anh', 274, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Gabriel García Márquez'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'The Road', '9786040000873', 2012, N'The Road là tác phẩm của Cormac McCarthy, thuộc nhóm Khoa học viễn tưởng; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'the-road.jpg', N'Tiếng Anh', 459, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Cormac McCarthy'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Giết con chim nhại', N'9786049542787', 2017, N'Qua phiên tòa của một người da đen bị vu oan, Harper Lee nhìn nạn phân biệt chủng tộc và lòng can đảm bằng đôi mắt trẻ thơ. Tác phẩm do Harper Lee viết; ấn bản 2011 có 337 trang, trình bày bằng tiếng anh và do NXB Văn Học phát hành.', N'to-kill-a-mockingbird.jpg', N'Tiếng Việt', 419, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Harper Lee'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam'), 0, 0, N'Giết con chim nhại', N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/giet-con-chim-nhai-20267672190813184923'),
        (N'The Martian', '9786040000880', 2013, N'The Martian là tác phẩm của Andy Weir, thuộc nhóm Khoa học viễn tưởng; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'the-martian.jpg', N'Tiếng Anh', 496, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Andy Weir'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Project Hail Mary', '9786040000897', 2014, N'Project Hail Mary là tác phẩm của Andy Weir, thuộc nhóm Khoa học viễn tưởng; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'project-hail-mary.jpg', N'Tiếng Anh', 533, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Andy Weir'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Đại gia Gatsby', N'9786049968426', 2020, N'Giấc mơ giàu sang của Jay Gatsby xoay quanh tình yêu đã mất, phản chiếu vẻ hào nhoáng và khoảng trống của nước Mỹ thời Jazz. Tác phẩm do F. Scott Fitzgerald viết; ấn bản 2014 có 448 trang, trình bày bằng tiếng anh và do NXB Văn Học phát hành.', N'the-great-gatsby.jpg', N'Tiếng Việt', 252, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'F. Scott Fitzgerald'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Hội Nhà văn'), 0, 0, N'Đại gia Gatsby', N'Nxb. Hội Nhà văn', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/dai-gia-gatsby-20269257350813192020'),
        (N'Kiêu hãnh và định kiến', N'9786046977421', 2016, N'Elizabeth Bennet và Mr. Darcy phải vượt qua thành kiến, kiêu hãnh cùng áp lực hôn nhân để nhận ra giá trị thật của nhau. Tác phẩm do Jane Austen viết; ấn bản 2015 có 485 trang, trình bày bằng tiếng anh và do NXB Văn Học phát hành.', N'pride-and-prejudice.jpg', N'Tiếng Việt', 523, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Jane Austen'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học'), 0, 0, N'Kiêu hãnh và định kiến', N'Văn học', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/kieu-hanh-va-dinh-kien-20267137960813183923'),
        (N'Anh chàng Hobbit', N'9786043065657', 2020, N'Bilbo Baggins rời căn nhà tiện nghi để cùng đoàn người lùn giành lại quê hương, đối mặt troll, goblin và rồng Smaug. Tác phẩm do J.R.R. Tolkien viết; ấn bản 2017 có 559 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'the-hobbit.jpg', N'Tiếng Việt', 459, (SELECT category_id FROM Categories WHERE category_name = N'Fantasy'), (SELECT author_id FROM Authors WHERE author_name = N'J.R.R. Tolkien'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Hội Nhà văn ; Công ty Văn hoá và Truyền thông Nhã Nam'), 0, 0, N'Anh chàng Hobbit', N'Nxb. Hội Nhà văn ; Công ty Văn hoá và Truyền thông Nhã Nam', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/anh-chang-hobbit-20269257650813192021'),
        (N'Chúa tể những chiếc nhẫn', N'9786043720365', 2023, N'Frodo mang Chiếc Nhẫn Quyền Lực đến Núi Doom trong thiên sử thi về tình bạn, cám dỗ và cuộc chiến chống bóng tối Trung Địa. Tác phẩm do J.R.R. Tolkien viết; ấn bản 2018 có 596 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'the-lord-of-the-rings.jpg', N'Tiếng Việt', 596, (SELECT category_id FROM Categories WHERE category_name = N'Fantasy'), (SELECT author_id FROM Authors WHERE author_name = N'J.R.R. Tolkien'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học'), 0, 0, N'Chúa tể những chiếc nhẫn', N'Văn học', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/chua-te-nhung-chiec-nhan-20269901330813193430'),
        (N'Harry Potter và hòn đá phù thủy', N'9786041084247', 2026, N'Harry bước vào Hogwarts, khám phá phép thuật và tình bạn, đồng thời chạm trán bí mật về cha mẹ cùng kẻ đã để lại vết sẹo trên trán mình. Tác phẩm do J.K. Rowling viết; ấn bản 2019 có 213 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'harry-potter-and-the-sorcerers-stone.jpg', N'Tiếng Việt', 365, (SELECT category_id FROM Categories WHERE category_name = N'Fantasy'), (SELECT author_id FROM Authors WHERE author_name = N'J.K. Rowling'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Harry Potter và hòn đá phù thủy', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/harry-potter-va-hon-da-phu-thuy-202611186100813200858'),
        (N'Harry Potter và phòng chứa bí mật', N'9786041185388', 2021, N'Một thế lực bí ẩn hóa đá học sinh Hogwarts, buộc Harry lần theo truyền thuyết Phòng chứa Bí mật và người thừa kế Slytherin. Tác phẩm do J.K. Rowling viết; ấn bản 2020 có 250 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'harry-potter-and-the-chamber of-secrets.jpg', N'Tiếng Việt', 429, (SELECT category_id FROM Categories WHERE category_name = N'Fantasy'), (SELECT author_id FROM Authors WHERE author_name = N'J.K. Rowling'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Harry Potter và phòng chứa bí mật', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/harry-potter-va-phong-chua-bi-mat-20269236620813192821'),
        (N'Harry Potter và tên tù nhân ngục Azkaban', N'9786041160026', 2021, N'Kẻ vượt ngục Sirius Black dường như đang săn Harry, nhưng sự thật về đêm cha mẹ cậu bị phản bội phức tạp hơn mọi lời đồn. Tác phẩm do J.K. Rowling viết; ấn bản 2021 có 287 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'harry-potter-and-the-prisoner-of-azkaban.jpg', N'Tiếng Việt', 921, (SELECT category_id FROM Categories WHERE category_name = N'Fantasy'), (SELECT author_id FROM Authors WHERE author_name = N'J.K. Rowling'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Harry Potter và tên tù nhân ngục Azkaban', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/harry-potter-va-ten-tu-nhan-nguc-azkaban-20268970180813191919'),
        (N'Harry Potter và chiếc cốc lửa', N'9786041185401', 2021, N'Harry bất ngờ bị chọn dự Tam Pháp Thuật, trải qua ba thử thách chết người trước khi chứng kiến Voldemort trở lại. Tác phẩm do J.K. Rowling viết; ấn bản 2022 có 324 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'harry-potter-and-the-goblet-of-fire.jpg', N'Tiếng Việt', 921, (SELECT category_id FROM Categories WHERE category_name = N'Fantasy'), (SELECT author_id FROM Authors WHERE author_name = N'J.K. Rowling'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Harry Potter và chiếc cốc lửa', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/harry-potter-va-chiec-coc-lua-20269084030813191818'),
        (N'Harry Potter và Hội Phượng Hoàng', N'9786041185418', 2021, N'Bị Bộ Pháp thuật phủ nhận và Dolores Umbridge đàn áp, Harry lập Đội quân Dumbledore để chuẩn bị cho cuộc chiến đang đến. Tác phẩm do J.K. Rowling viết; ấn bản 2023 có 361 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'harry-potter-and-the-order-of-the-phoenix.jpg', N'Tiếng Việt', 1309, (SELECT category_id FROM Categories WHERE category_name = N'Fantasy'), (SELECT author_id FROM Authors WHERE author_name = N'J.K. Rowling'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Harry Potter và Hội Phượng Hoàng', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/harry-potter-va-hoi-phuong-hoang-20269084040813191818'),
        (N'Harry Potter và hoàng tử lai', N'9786041185425', 2021, N'Khi chiến tranh lan tới Hogwarts, Harry khám phá quá khứ Voldemort và nhận được sự giúp đỡ bí ẩn từ cuốn sách của Hoàng tử Lai. Tác phẩm do J.K. Rowling viết; ấn bản 2024 có 398 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'harry-potter-and-the-half-blood-prince.jpg', N'Tiếng Việt', 715, (SELECT category_id FROM Categories WHERE category_name = N'Fantasy'), (SELECT author_id FROM Authors WHERE author_name = N'J.K. Rowling'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Harry Potter và hoàng tử lai', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/harry-potter-va-hoang-tu-lai-20269077300813191805'),
        (N'Harry Potter và Bảo bối tử thần', N'9786041185432', 2021, N'Harry, Ron và Hermione rời trường để săn Trường Sinh Linh Giá, tiến tới cuộc đối đầu cuối cùng quyết định số phận thế giới phù thủy. Tác phẩm do J.K. Rowling viết; ấn bản 2000 có 435 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'harry-potter-and-the-deathly-hallows.jpg', N'Tiếng Việt', 846, (SELECT category_id FROM Categories WHERE category_name = N'Fantasy'), (SELECT author_id FROM Authors WHERE author_name = N'J.K. Rowling'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Harry Potter và Bảo bối tử thần', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/harry-potter-va-bao-boi-tu-than-20269236840813192821'),
        (N'Hoàng tử bé', N'9786326246902', 2025, N'Hoàng tử bé rời tiểu hành tinh của mình, gặp những người lớn kỳ lạ và học từ cáo về tình bạn, trách nhiệm cùng điều mắt thường không thấy. Tác phẩm do Antoine de Saint-Exupéry viết; ấn bản 2001 có 472 trang, trình bày bằng tiếng anh và do NXB Văn Học phát hành.', N'the-little-prince.jpg', N'Tiếng Việt', 156, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Antoine de Saint-Exupéry'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học'), 0, 0, N'Hoàng tử bé', N'Văn học', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/hoang-tu-be-202611171620813201125'),
        (N'Ông già và biển cả', N'9786045893883', 2019, N'Ông lão Santiago một mình vật lộn với con cá kiếm khổng lồ giữa biển, giữ vững phẩm giá dù chiến thắng bị thiên nhiên lấy lại. Tác phẩm do Ernest Hemingway viết; ấn bản 2002 có 509 trang, trình bày bằng tiếng anh và do NXB Văn Học phát hành.', N'the-old-man-and-the-sea.jpg', N'Tiếng Việt', 247, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Ernest Hemingway'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Tp. Hồ Chí Minh'), 0, 0, N'Ông già và biển cả', N'Nxb. Tp. Hồ Chí Minh', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ong-gia-va-bien-ca-20268324460813190424'),
        (N'Dune', '9786040000903', 2015, N'Dune là tác phẩm của Frank Herbert, thuộc nhóm Khoa học viễn tưởng; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'dune.jpg', N'Tiếng Anh', 570, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Frank Herbert'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Kafka bên bờ biển', N'9786049924026', 2020, N'Cậu thiếu niên Kafka bỏ nhà đi trong khi ông lão Nakata trò chuyện với mèo; hai hành trình siêu thực dần giao nhau qua định mệnh. Tác phẩm do Haruki Murakami viết; ấn bản 2005 có 200 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'kafka-on-the-shore.jpg', N'Tiếng Việt', 531, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Haruki Murakami'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam'), 0, 0, N'Kafka bên bờ biển', N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/kafka-ben-bo-bien-20268659130813190531'),
        (N'Trăm năm cô đơn', N'9786049766695', 2019, N'Bảy thế hệ nhà Buendía sống giữa phép màu, chiến tranh và cô độc ở Macondo, lặp lại những khát vọng cùng sai lầm của tổ tiên. Tác phẩm do Gabriel García Márquez viết; ấn bản 2006 có 237 trang, trình bày bằng tiếng anh và do NXB Văn Học phát hành.', N'one-hundred-years-of-solitude.jpg', N'Tiếng Việt', 492, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Gabriel García Márquez'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam'), 0, 0, N'Trăm năm cô đơn', N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/tram-nam-co-don-20268309130813190440'),
        (N'The Handmaid''s Tale', '9786040000934', 2018, N'The Handmaid''s Tale là tác phẩm của Margaret Atwood, thuộc nhóm Khoa học viễn tưởng; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'the-handmaids-tale.jpg', N'Tiếng Anh', 261, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Margaret Atwood'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Người đua diều', N'9786045623282', 2016, N'Amir trở về Afghanistan để chuộc lỗi vì đã phản bội Hassan thuở nhỏ, đối diện tình bạn, chiến tranh và bí mật gia đình. Tác phẩm do Khaled Hosseini viết; ấn bản 2008 có 311 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'the-kite-runner.jpg', N'Tiếng Việt', 457, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Khaled Hosseini'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Phụ nữ ; Công ty Văn hoá và Truyền thông Nhã Nam'), 0, 0, N'Người đua diều', N'Phụ nữ ; Công ty Văn hoá và Truyền thông Nhã Nam', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nguoi-dua-dieu-20267287370813184349'),
        (N'Ngàn mặt trời rực rỡ', N'9786049574238', 2018, N'Mariam và Laila, hai phụ nữ khác thế hệ, nương tựa nhau để sống sót qua bạo lực gia đình và chiến tranh tại Afghanistan. Tác phẩm do Khaled Hosseini viết; ấn bản 2009 có 348 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'a-thousand-splendid-suns.jpg', N'Tiếng Việt', 456, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Khaled Hosseini'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam'), 0, 0, N'Ngàn mặt trời rực rỡ', N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ngan-mat-troi-ruc-ro-20267948120813185631'),
        (N'Kẻ trộm sách', N'9786041052079', 2016, N'Cô bé Liesel ăn cắp sách giữa nước Đức Quốc xã, tìm nơi trú ẩn trong ngôn từ khi Tử thần chứng kiến chiến tranh cướp đi mọi điều thân thuộc. Tác phẩm do Markus Zusak viết; ấn bản 2010 có 385 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'the-book-thief.jpg', N'Tiếng Việt', 571, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Markus Zusak'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ ; Công ty Sách Dân trí'), 0, 0, N'Kẻ trộm sách', N'Nxb. Trẻ ; Công ty Sách Dân trí', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ke-trom-sach-20267079520813183754'),
        (N'Cuộc đời của Pi', N'9786049767159', 2019, N'Pi Patel mắc kẹt trên xuồng cứu sinh với một con hổ Bengal, biến cuộc sinh tồn thành suy tưởng về đức tin và bản chất của sự thật. Tác phẩm do Yann Martel viết; ấn bản 2011 có 422 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'life-of-pi.jpg', N'Tiếng Việt', 447, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Yann Martel'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam'), 0, 0, N'Cuộc đời của Pi', N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/cuoc-doi-cua-pi-20268231960813185903'),
        (N'Catching Fire', '9786040000958', 2020, N'Catching Fire là tác phẩm của Suzanne Collins, thuộc nhóm Khoa học viễn tưởng; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'catching-fire.jpg', N'Tiếng Anh', 335, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Suzanne Collins'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Mockingjay', '9786040000965', 2021, N'Mockingjay là tác phẩm của Suzanne Collins, thuộc nhóm Khoa học viễn tưởng; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'mockingjay.jpg', N'Tiếng Anh', 372, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Suzanne Collins'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'The Notebook', '9786040000996', 2024, N'The Notebook là tác phẩm của Nicholas Sparks, thuộc nhóm Tiểu thuyết; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'the-notebook.jpg', N'Tiếng Anh', 483, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Nicholas Sparks'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Elon Musk', '9786040001047', 2004, N'Elon Musk là tác phẩm của Walter Isaacson, thuộc nhóm Hồi ký; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'elon-musk.jpg', N'Tiếng Anh', 248, (SELECT category_id FROM Categories WHERE category_name = N'Hồi ký'), (SELECT author_id FROM Authors WHERE author_name = N'Walter Isaacson'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Trẻ'), 0, 0, NULL, NULL, NULL, NULL),
        (N'451 độ F', N'9786049868030', 2020, N'Trong xã hội nơi lính cứu hỏa đốt sách, Guy Montag bắt đầu nghi ngờ công việc của mình và tìm lại tự do trong tri thức bị cấm. Tác phẩm do Ray Bradbury viết; ấn bản 2016 có 187 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'fahrenheit-451.jpg', N'Tiếng Việt', 229, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Ray Bradbury'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam'), 0, 0, N'451 độ F', N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/451-do-f-20268659610813190851'),
        (N'Thế giới mới tươi đẹp', N'9786049548246', 2017, N'Một thế giới được ổn định bằng sinh sản công nghiệp, điều kiện hóa và khoái lạc hóa học bị thách thức bởi một người lớn lên ngoài hệ thống. Tác phẩm do Aldous Huxley viết; ấn bản 2017 có 224 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'brave-new-world.jpg', N'Tiếng Việt', 331, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Aldous Huxley'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học ; Công ty Sách Phương Nam'), 0, 0, N'Thế giới mới tươi đẹp', N'Văn học ; Công ty Sách Phương Nam', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/the-gioi-moi-tuoi-dep-20267674670813184755'),
        (N'A Brief History of Time', '9786040001092', 2009, N'A Brief History of Time là tác phẩm của Stephen Hawking, thuộc nhóm Khoa học; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'a-brief-history-of-time.jpg', N'Tiếng Anh', 433, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Stephen Hawking'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Đấu trường sinh tử', N'9786049633812', 2018, N'Katniss Everdeen tình nguyện bước vào đấu trường sinh tử để cứu em gái và vô tình trở thành biểu tượng thách thức Capitol. Tác phẩm do Suzanne Collins viết; ấn bản 2019 có 298 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'the-hunger-games.jpg', N'Tiếng Việt', 400, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Suzanne Collins'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam'), 0, 0, N'Đấu trường sinh tử', N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/dau-truong-sinh-tu-20267863530813185630'),
        (N'Cosmos', '9786040001108', 2010, N'Cosmos là tác phẩm của Carl Sagan, thuộc nhóm Khoa học; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'cosmos.jpg', N'Tiếng Anh', 470, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Carl Sagan'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'The Gene', '9786040001139', 2013, N'The Gene là tác phẩm của Siddhartha Mukherjee, thuộc nhóm Khoa học; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'the-gene.jpg', N'Tiếng Anh', 581, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Siddhartha Mukherjee'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Khi lỗi thuộc về những vì sao', N'9786041054745', 2017, N'Hazel và Augustus gặp nhau trong nhóm hỗ trợ bệnh nhân ung thư, cùng trải nghiệm một tình yêu ngắn ngủi nhưng làm thay đổi cách họ nhìn sự sống. Tác phẩm do John Green viết; ấn bản 2022 có 409 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'the-fault-in-our-stars.jpg', N'Tiếng Việt', 360, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'John Green'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Khi lỗi thuộc về những vì sao', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/khi-loi-thuoc-ve-nhung-vi-sao-20267456980813184952'),
        (N'Trước ngày em đến', N'9786041064973', 2016, N'Louisa Clark chăm sóc Will Traynor sau tai nạn và dần yêu anh, nhưng phải tôn trọng lựa chọn khó khăn của một con người muốn tự quyết cuộc đời. Tác phẩm do Jojo Moyes viết; ấn bản 2023 có 446 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'me-before-you.jpg', N'Tiếng Việt', 599, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Jojo Moyes'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Trước ngày em đến', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/truoc-ngay-em-den-20267109340813183711'),
        (N'Why We Sleep', '9786040001160', 2016, N'Why We Sleep là tác phẩm của Matthew Walker, thuộc nhóm Khoa học; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'why-we-sleep.jpg', N'Tiếng Anh', 272, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Matthew Walker'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Người đàn ông mang tên Ove', N'9786041155831', 2020, N'Ông Ove cáu kỉnh liên tục bị hàng xóm mới phá hỏng kế hoạch tự sát, rồi bất ngờ tìm lại cộng đồng và lý do để sống. Tác phẩm do Fredrik Backman viết; ấn bản 2000 có 520 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'a-man-called-ove.jpg', N'Tiếng Việt', 447, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Fredrik Backman'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Người đàn ông mang tên Ove', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nguoi-dan-ong-mang-ten-ove-20268605230813191038'),
        (N'Được học', N'9786045680162', 2021, N'Tara Westover lớn lên trong gia đình biệt lập không trường học, tự mở đường vào đại học và trả giá cho quyền định nghĩa chính mình. Tác phẩm do Tara Westover viết; ấn bản 2001 có 557 trang, trình bày bằng tiếng anh và do NXB Trẻ phát hành.', N'educated.jpg', N'Tiếng Việt', 446, (SELECT category_id FROM Categories WHERE category_name = N'Hồi ký'), (SELECT author_id FROM Authors WHERE author_name = N'Tara Westover'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Phụ nữ Việt Nam'), 0, 0, N'Được học', N'Phụ nữ Việt Nam', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/duoc-hoc-20269099970813191838'),
        (N'Chất Michelle', N'9786045889862', 2019, N'Michelle Obama kể hành trình từ khu South Side đến Nhà Trắng, suy ngẫm về gia đình, nghề nghiệp, chủng tộc và đời sống công chúng. Tác phẩm do Michelle Obama viết; ấn bản 2002 có 594 trang, trình bày bằng tiếng anh và do NXB Trẻ phát hành.', N'becoming.jpg', N'Tiếng Việt', 502, (SELECT category_id FROM Categories WHERE category_name = N'Hồi ký'), (SELECT author_id FROM Authors WHERE author_name = N'Michelle Obama'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Tp. Hồ Chí Minh ; Công ty Văn hoá Sáng tạo Trí Việt'), 0, 0, N'Chất Michelle', N'Nxb. Tp. Hồ Chí Minh ; Công ty Văn hoá Sáng tạo Trí Việt', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/chat-michelle-20268334370813190340'),
        (N'Steve Jobs', N'9786047703739', 2011, N'Walter Isaacson dựng chân dung Steve Jobs từ hàng chục cuộc phỏng vấn, cho thấy sự giao thoa giữa tầm nhìn sản phẩm, ám ảnh hoàn hảo và tính cách gai góc. Tác phẩm do Walter Isaacson viết; ấn bản 2003 có 211 trang, trình bày bằng tiếng anh và do NXB Trẻ phát hành.', N'steve-jobs.jpg', N'Tiếng Việt', 693, (SELECT category_id FROM Categories WHERE category_name = N'Hồi ký'), (SELECT author_id FROM Authors WHERE author_name = N'Walter Isaacson'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thế giới ; Công ty Sách Alpha'), 0, 0, N'Steve Jobs', N'Thế giới ; Công ty Sách Alpha', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/steve-jobs-20264801380813180025'),
        (N'Factfulness', '9786040001184', 2018, N'Factfulness là tác phẩm của Hans Rosling, thuộc nhóm Khoa học; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'factfulness.jpg', N'Tiếng Anh', 346, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Hans Rosling'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Sapiens: Lược sử loài người', N'9786049903137', 2020, N'Yuval Noah Harari kể hành trình Homo sapiens từ loài động vật vô danh đến kẻ thống trị hành tinh nhờ ngôn ngữ, hợp tác và những trật tự tưởng tượng. Tác phẩm do Yuval Noah Harari viết; ấn bản 2005 có 285 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'sapiens.jpg', N'Tiếng Việt', 558, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Yuval Noah Harari'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Tri thức'), 0, 0, N'Sapiens: Lược sử loài người', N'Tri thức', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/sapiens-luoc-su-loai-nguoi-20268875790813191545'),
        (N'Homo Deus - Lược sử tương lai', N'9786047774166', 2020, N'Harari suy đoán tương lai khi con người dùng công nghệ để theo đuổi bất tử, hạnh phúc và quyền năng gần như thần thánh. Tác phẩm do Yuval Noah Harari viết; ấn bản 2006 có 322 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'homo-deus.jpg', N'Tiếng Việt', 508, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Yuval Noah Harari'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thế giới ; Công ty Văn hoá và Truyền thông Nhã Nam'), 0, 0, N'Homo Deus - Lược sử tương lai', N'Thế giới ; Công ty Văn hoá và Truyền thông Nhã Nam', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/homo-deus---luoc-su-tuong-lai-20268629010813191100'),
        (N'21 bài học cho thế kỷ 21', N'9786047774173', 2020, N'Hai mươi mốt bài luận xem xét các thách thức hiện tại như AI, chủ nghĩa dân tộc, tin giả, giáo dục và khả năng giữ bình tâm. Tác phẩm do Yuval Noah Harari viết; ấn bản 2007 có 359 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'21-lessons-for-the-21st-century.jpg', N'Tiếng Việt', 426, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Yuval Noah Harari'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thế giới ; Công ty Văn hoá và Truyền thông Nhã Nam'), 0, 0, N'21 bài học cho thế kỷ 21', N'Thế giới ; Công ty Văn hoá và Truyền thông Nhã Nam', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/21-bai-hoc-cho-the-ky-21-20268643320813190603'),
        (N'Súng, vi trùng và thép', N'9786047781881', 2020, N'Jared Diamond lý giải vì sao các xã hội phát triển khác nhau qua địa lý, cây trồng, vật nuôi, mầm bệnh và công nghệ thay vì khác biệt chủng tộc. Tác phẩm do Jared Diamond viết; ấn bản 2008 có 396 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'guns-germs-and-steel.jpg', N'Tiếng Việt', 690, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Jared Diamond'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thế giới'), 0, 0, N'Súng, vi trùng và thép', N'Thế giới', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/sung-vi-trung-va-thep-20268857810813191512'),
        (N'David and Goliath', '9786040001221', 2022, N'David and Goliath là tác phẩm của Malcolm Gladwell, thuộc nhóm Tâm lý học; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'david-and-goliath.jpg', N'Tiếng Anh', 494, (SELECT category_id FROM Categories WHERE category_name = N'Tâm lý học'), (SELECT author_id FROM Authors WHERE author_name = N'Malcolm Gladwell'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thái Hà Books'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Vật lý thiên văn cho người vội vã', N'9786047759170', 2019, N'Neil deGrasse Tyson cô đọng các ý niệm lớn của vật lý thiên văn—vật chất tối, năng lượng tối và vũ trụ giãn nở—thành những chương ngắn dễ tiếp cận. Tác phẩm do Neil deGrasse Tyson viết; ấn bản 2011 có 507 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'astrophysics-for-people-in-a-hurry.jpg', N'Tiếng Việt', 182, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Neil deGrasse Tyson'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thế giới ; Công ty Văn hoá và Truyền thông Nhã Nam'), 0, 0, N'Vật lý thiên văn cho người vội vã', N'Thế giới ; Công ty Văn hoá và Truyền thông Nhã Nam', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/vat-ly-thien-van-cho-nguoi-voi-va-20268413410813190404'),
        (N'Gen vị kỷ', N'9786049081170', 2011, N'Richard Dawkins nhìn tiến hóa từ cấp độ gene, giải thích chọn lọc tự nhiên, cạnh tranh, hợp tác và nguồn gốc của hành vi vị tha. Tác phẩm do Richard Dawkins viết; ấn bản 2012 có 544 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'the-selfish-gene.jpg', N'Tiếng Việt', 463, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Richard Dawkins'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Tri thức'), 0, 0, N'Gen vị kỷ', N'Tri thức', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/gen-vi-ky-20264692400813175848'),
        (N'Grit', '9786040001238', 2023, N'Grit là tác phẩm của Angela Duckworth, thuộc nhóm Tâm lý học; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'grit.jpg', N'Tiếng Anh', 531, (SELECT category_id FROM Categories WHERE category_name = N'Tâm lý học'), (SELECT author_id FROM Authors WHERE author_name = N'Angela Duckworth'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thái Hà Books'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Mùa xuân vắng lặng', N'9786047750122', 2018, N'Rachel Carson phơi bày tác hại của thuốc trừ sâu đối với hệ sinh thái, khởi nguồn cho ý thức môi trường hiện đại và yêu cầu quản lý hóa chất có trách nhiệm. Tác phẩm do Rachel Carson viết; ấn bản 2014 có 198 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'silent-spring.jpg', N'Tiếng Việt', 353, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Rachel Carson'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thế giới ; Công ty Sách Phương Nam'), 0, 0, N'Mùa xuân vắng lặng', N'Thế giới ; Công ty Sách Phương Nam', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/mua-xuan-vang-lang-20268021340813185419'),
        (N'Cuộc đời bất tử của Henrietta Lacks', N'9786049719943', 2018, N'Câu chuyện Henrietta Lacks nối những tế bào HeLa bất tử với đột phá y học, bất công chủng tộc và câu hỏi đạo đức về quyền sở hữu mô người. Tác phẩm do Rebecca Skloot viết; ấn bản 2015 có 235 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'the-immortal-life-of-henrietta-lacks.jpg', N'Tiếng Việt', 454, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Rebecca Skloot'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Lao động'), 0, 0, N'Cuộc đời bất tử của Henrietta Lacks', N'Lao động', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/cuoc-doi-bat-tu-cua-henrietta-lacks-20268108360813190022'),
        (N'Drive', '9786040001245', 2024, N'Drive là tác phẩm của Daniel H. Pink, thuộc nhóm Tâm lý học; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'drive.jpg', N'Tiếng Anh', 568, (SELECT category_id FROM Categories WHERE category_name = N'Tâm lý học'), (SELECT author_id FROM Authors WHERE author_name = N'Daniel H. Pink'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thái Hà Books'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Tư duy hệ thống', N'9786326303933', 2026, N'Donella Meadows dạy cách nhìn vòng phản hồi, độ trễ và điểm đòn bẩy để hiểu vì sao các hệ thống phức tạp thường chống lại giải pháp đơn giản. Tác phẩm do Donella H. Meadows viết; ấn bản 2017 có 309 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'thinking-in-systems.jpg', N'Tiếng Việt', 322, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Donella H. Meadows'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Công Thương'), 0, 0, N'Tư duy hệ thống', N'Công Thương', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/tu-duy-he-thong-202611219930813201114'),
        (N'Good Vibes, Good Life', '9786040001276', 2002, N'Good Vibes, Good Life là tác phẩm của Vex King, thuộc nhóm Kỹ năng sống; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'good-vibes-good-life.jpg', N'Tiếng Anh', 259, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Vex King'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Những kẻ xuất chúng', N'9786047704118', 2016, N'Malcolm Gladwell nhìn thành công qua cơ hội, văn hóa, thời điểm và quá trình luyện tập, thay vì chỉ xem đó là kết quả của tài năng cá nhân. Tác phẩm do Malcolm Gladwell viết; ấn bản 2019 có 383 trang, trình bày bằng tiếng anh và do Thái Hà Books phát hành.', N'outliers.jpg', N'Tiếng Việt', 359, (SELECT category_id FROM Categories WHERE category_name = N'Tâm lý học'), (SELECT author_id FROM Authors WHERE author_name = N'Malcolm Gladwell'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thế giới ; Công ty Sách Alpha'), 0, 0, N'Những kẻ xuất chúng', N'Thế giới ; Công ty Sách Alpha', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nhung-ke-xuat-chung-20267083520813183934'),
        (N'Trong chớp mắt', N'9786047712694', 2018, N'Gladwell khám phá sức mạnh và giới hạn của phán đoán chớp nhoáng, khi kinh nghiệm vô thức có thể tạo trực giác xuất sắc hoặc thiên kiến nguy hiểm. Tác phẩm do Malcolm Gladwell viết; ấn bản 2020 có 420 trang, trình bày bằng tiếng anh và do Thái Hà Books phát hành.', N'blink.jpg', N'Tiếng Việt', 375, (SELECT category_id FROM Categories WHERE category_name = N'Tâm lý học'), (SELECT author_id FROM Authors WHERE author_name = N'Malcolm Gladwell'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thế giới ; Công ty Sách Alpha'), 0, 0, N'Trong chớp mắt', N'Thế giới ; Công ty Sách Alpha', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/trong-chop-mat-20267760280813184846'),
        (N'Điểm bùng phát', N'9786047752379', 2018, N'Cuốn sách phân tích khoảnh khắc một ý tưởng hay hành vi lan truyền như dịch bệnh, nhờ người kết nối, thông điệp dễ nhớ và bối cảnh phù hợp. Tác phẩm do Malcolm Gladwell viết; ấn bản 2021 có 457 trang, trình bày bằng tiếng anh và do Thái Hà Books phát hành.', N'the-tipping-point.jpg', N'Tiếng Việt', 403, (SELECT category_id FROM Categories WHERE category_name = N'Tâm lý học'), (SELECT author_id FROM Authors WHERE author_name = N'Malcolm Gladwell'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thế giới'), 0, 0, N'Điểm bùng phát', N'Thế giới', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/diem-bung-phat-20268085040813185636'),
        (N'Everything Is Figureoutable', '9786040001290', 2004, N'Everything Is Figureoutable là tác phẩm của Marie Forleo, thuộc nhóm Kỹ năng sống; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'everything-is-figureoutable.jpg', N'Tiếng Anh', 333, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Marie Forleo'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0, NULL, NULL, NULL, NULL),
        (N'The Mountain Is You', '9786040001306', 2005, N'The Mountain Is You là tác phẩm của Brianna Wiest, thuộc nhóm Kỹ năng sống; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'the-mountain-is-you.jpg', N'Tiếng Anh', 370, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Brianna Wiest'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0, NULL, NULL, NULL, NULL),
        (N'The Gifts of Imperfection', '9786040001320', 2007, N'The Gifts of Imperfection là tác phẩm của Brené Brown, thuộc nhóm Kỹ năng sống; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'the-gifts-of-imperfection.jpg', N'Tiếng Anh', 444, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Brené Brown'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'First News'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Lãnh đạo luôn ăn sau cùng', N'9786045936030', 2015, N'Simon Sinek lý giải vì sao lãnh đạo biết bảo vệ và đặt đội ngũ lên trước sẽ tạo niềm tin, hợp tác cùng hiệu suất bền vững. Tác phẩm do Simon Sinek viết; ấn bản 2000 có 185 trang, trình bày bằng tiếng anh và do Alphabooks phát hành.', N'leaders-eat-last.jpg', N'Tiếng Việt', 314, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Simon Sinek'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Lao động ; Công ty Sách Thái Hà'), 0, 0, N'Lãnh đạo luôn ăn sau cùng', N'Lao động ; Công ty Sách Thái Hà', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lanh-dao-luon-an-sau-cung-20266746520813183452'),
        (N'Dám lãnh đạo', N'9786047767021', 2019, N'Brené Brown biến lòng can đảm thành các kỹ năng lãnh đạo cụ thể: đối diện sự dễ tổn thương, trò chuyện khó và xây dựng văn hóa tin cậy. Tác phẩm do Brené Brown viết; ấn bản 2001 có 222 trang, trình bày bằng tiếng anh và do Alphabooks phát hành.', N'dare-to-lead.jpg', N'Tiếng Việt', 471, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Brené Brown'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thế giới ; Công ty Sách Alpha'), 0, 0, N'Dám lãnh đạo', N'Thế giới ; Công ty Sách Alpha', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/dam-lanh-dao-20268460050813190427'),
        (N'Man''s Search for Meaning', '9786040001344', 2009, N'Man''s Search for Meaning là tác phẩm của Viktor E. Frankl, thuộc nhóm Hồi ký; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'mans-search-for-meaning.jpg', N'Tiếng Anh', 518, (SELECT category_id FROM Categories WHERE category_name = N'Hồi ký'), (SELECT author_id FROM Authors WHERE author_name = N'Viktor E. Frankl'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Trẻ'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Nghệ thuật tinh tế của việc "đếch" quan tâm', N'9786043070019', 2020, N'Mark Manson dùng giọng văn thẳng và hài hước để khuyên người đọc chọn điều đáng quan tâm, chấp nhận giới hạn và chịu trách nhiệm với lựa chọn. Tác phẩm do Mark Manson viết; ấn bản 2003 có 296 trang, trình bày bằng tiếng anh và do First News phát hành.', N'the-subtle-art-of-not-giving-a-Fck.jpg', N'Tiếng Việt', 282, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Mark Manson'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học ; Công ty Văn hoá Huy Hoàng'), 0, 0, N'Nghệ thuật tinh tế của việc "đếch" quan tâm', N'Văn học ; Công ty Văn hoá Huy Hoàng', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nghe-thuat-tinh-te-cua-viec-dech-quan-20268795210813191351'),
        (N'The Art of War', '9786040001368', 2011, N'The Art of War là tác phẩm của Sun Tzu, thuộc nhóm Triết học; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'the-art-of-war.jpg', N'Tiếng Anh', 592, (SELECT category_id FROM Categories WHERE category_name = N'Triết học'), (SELECT author_id FROM Authors WHERE author_name = N'Sun Tzu'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Hội Nhà Văn'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Letters from a Stoic', '9786040001375', 2012, N'Letters from a Stoic là tác phẩm của Seneca, thuộc nhóm Triết học; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'letters-from-a-stoic.jpg', N'Tiếng Anh', 209, (SELECT category_id FROM Categories WHERE category_name = N'Triết học'), (SELECT author_id FROM Authors WHERE author_name = N'Seneca'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Hội Nhà Văn'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Gắn bó yêu thương - Tại sao ta yêu, tại sao ta ghét?', N'9786043280968', 2021, N'Amir Levine và Rachel Heller giải thích các kiểu gắn bó an toàn, lo âu, né tránh cùng ảnh hưởng của chúng đến lựa chọn và xung đột tình cảm. Tác phẩm do Amir Levine viết; ấn bản 2006 có 407 trang, trình bày bằng tiếng anh và do Thái Hà Books phát hành.', N'attached.jpg', N'Tiếng Việt', 502, (SELECT category_id FROM Categories WHERE category_name = N'Tâm lý học'), (SELECT author_id FROM Authors WHERE author_name = N'Amir Levine'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Hồng Đức'), 0, 0, N'Gắn bó yêu thương - Tại sao ta yêu, tại sao ta ghét?', N'Hồng Đức', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/gan-bo-yeu-thuong---tai-sao-ta-yeu-tai-20269102300813191809'),
        (N'Beyond Good and Evil', '9786040001399', 2014, N'Beyond Good and Evil là tác phẩm của Friedrich Nietzsche, thuộc nhóm Triết học; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'beyond-good-and-evil.jpg', N'Tiếng Anh', 283, (SELECT category_id FROM Categories WHERE category_name = N'Triết học'), (SELECT author_id FROM Authors WHERE author_name = N'Friedrich Nietzsche'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Hội Nhà Văn'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Dám bị ghét', N'9786049714696', 2018, N'Qua đối thoại giữa một triết gia và chàng thanh niên, cuốn sách diễn giải tâm lý học Adler về tự do, trách nhiệm và can đảm không sống theo kỳ vọng. Tác phẩm do Ichiro Kishimi viết; ấn bản 2008 có 481 trang, trình bày bằng tiếng anh và do NXB Hội Nhà Văn phát hành.', N'the-courage-to-Be-disliked.jpg', N'Tiếng Việt', 333, (SELECT category_id FROM Categories WHERE category_name = N'Triết học'), (SELECT author_id FROM Authors WHERE author_name = N'Ichiro Kishimi'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Lao động ; Công ty Văn hoá và Truyền thông Nhã Nam'), 0, 0, N'Dám bị ghét', N'Lao động ; Công ty Văn hoá và Truyền thông Nhã Nam', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/dam-bi-ghet-20268035370813185442'),
        (N'Suy tưởng', N'9786049903205', 2020, N'Những ghi chép riêng của Marcus Aurelius về bổn phận, lý trí và sự vô thường trở thành cẩm nang thực hành chủ nghĩa Khắc kỷ. Tác phẩm do Marcus Aurelius viết; ấn bản 2010 có 555 trang, trình bày bằng tiếng anh và do NXB Hội Nhà Văn phát hành.', N'meditations.jpg', N'Tiếng Việt', 388, (SELECT category_id FROM Categories WHERE category_name = N'Triết học'), (SELECT author_id FROM Authors WHERE author_name = N'Marcus Aurelius'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Tri thức'), 0, 0, N'Suy tưởng', N'Tri thức', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/suy-tuong-20268624160813190747'),
        (N'The Brothers Karamazov', '9786040001429', 2017, N'The Brothers Karamazov là tác phẩm của Fyodor Dostoevsky, thuộc nhóm Văn học kinh điển; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'the-brothers-karamazov.jpg', N'Tiếng Anh', 394, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Fyodor Dostoevsky'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Anna Karenina', '9786040001436', 2018, N'Anna Karenina là tác phẩm của Leo Tolstoy, thuộc nhóm Văn học kinh điển; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'anna-karenina.jpg', N'Tiếng Anh', 431, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Leo Tolstoy'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Cộng hòa', N'9786047782307', 2026, N'Plato dùng cuộc đối thoại về công lý để xây dựng mô hình nhà nước lý tưởng, bàn về giáo dục, quyền lực và bản chất của tri thức. Tác phẩm do Plato viết; ấn bản 2013 có 246 trang, trình bày bằng tiếng anh và do NXB Hội Nhà Văn phát hành.', N'the-republic.jpg', N'Tiếng Việt', 722, (SELECT category_id FROM Categories WHERE category_name = N'Triết học'), (SELECT author_id FROM Authors WHERE author_name = N'Plato'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thế giới'), 0, 0, N'Cộng hòa', N'Thế giới', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/cong-hoa-202611234610813200926'),
        (N'Dracula', '9786040001481', 2023, N'Dracula là tác phẩm của Bram Stoker, thuộc nhóm Trinh thám - Kinh dị; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'dracula.jpg', N'Tiếng Anh', 196, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Bram Stoker'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Zarathustra đã nói như thế', N'9786046949084', 2016, N'Nhà tiên tri Zarathustra trở xuống núi để giảng về siêu nhân, ý chí quyền lực và hành trình vượt qua chính mình bằng văn phong thi ca. Tác phẩm do Friedrich Nietzsche viết; ấn bản 2015 có 320 trang, trình bày bằng tiếng anh và do NXB Hội Nhà Văn phát hành.', N'thus-spoke-zarathustra.jpg', N'Tiếng Việt', 544, (SELECT category_id FROM Categories WHERE category_name = N'Triết học'), (SELECT author_id FROM Authors WHERE author_name = N'Friedrich Nietzsche'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học'), 0, 0, N'Zarathustra đã nói như thế', N'Văn học', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/zarathustra-da-noi-nhu-the-202610753510813195703'),
        (N'Tội ác và hình phạt', N'9786044961682', 2025, N'Raskolnikov sát hại một bà cầm đồ để thử học thuyết của mình, rồi bị tội lỗi, tình thương và cuộc điều tra dồn tới ngưỡng sụp đổ. Tác phẩm do Fyodor Dostoevsky viết; ấn bản 2016 có 357 trang, trình bày bằng tiếng anh và do NXB Văn Học phát hành.', N'crime-and-punishment.jpg', N'Tiếng Việt', 725, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Fyodor Dostoevsky'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học'), 0, 0, N'Tội ác và hình phạt', N'Văn học', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/toi-ac-va-hinh-phat-202611097670813200926'),
        (N'The Hound of the Baskervilles', '9786040001559', 2005, N'The Hound of the Baskervilles là tác phẩm của Arthur Conan Doyle, thuộc nhóm Trinh thám - Kinh dị; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'the-hound-of-the-baskervilles.jpg', N'Tiếng Anh', 455, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Arthur Conan Doyle'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'The Da Vinci Code', '9786040001627', 2012, N'The Da Vinci Code là tác phẩm của Dan Brown, thuộc nhóm Trinh thám - Kinh dị; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'the-da-vinci-code.jpg', N'Tiếng Anh', 294, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Dan Brown'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Chiến tranh và hòa bình', N'9786326310481', 2026, N'Giữa cuộc chiến Nga–Napoléon, số phận nhiều gia đình quý tộc đan xen trong thiên sử thi về lịch sử, tình yêu và ý chí cá nhân. Tác phẩm do Leo Tolstoy viết; ấn bản 2019 có 468 trang, trình bày bằng tiếng anh và do NXB Văn Học phát hành.', N'war-and-peace.jpg', N'Tiếng Việt', 468, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Leo Tolstoy'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học'), 0, 0, N'Chiến tranh và hòa bình', N'Văn học', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/chien-tranh-va-hoa-binh-202611248120813201028'),
        (N'Những người khốn khổ', N'9786043235708', 2022, N'Jean Valjean tìm cách sống lương thiện nhưng luôn bị Javert truy đuổi, giữa bức tranh nước Pháp đầy nghèo đói, cách mạng và lòng bao dung. Tác phẩm do Victor Hugo viết; ấn bản 2020 có 505 trang, trình bày bằng tiếng anh và do NXB Văn Học phát hành.', N'les-miserables.jpg', N'Tiếng Việt', 505, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Victor Hugo'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học'), 0, 0, N'Những người khốn khổ', N'Văn học', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nhung-nguoi-khon-kho-20269516010813192556'),
        (N'Bá tước Monte-Cristo', N'9786043684582', 2022, N'Edmond Dantès bị vu oan và cầm tù, trở lại với thân phận Bá tước Monte Cristo để thực hiện kế hoạch báo thù tinh vi. Tác phẩm do Alexandre Dumas viết; ấn bản 2021 có 542 trang, trình bày bằng tiếng anh và do NXB Văn Học phát hành.', N'the-count-of-monte-cristo.jpg', N'Tiếng Việt', 542, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Alexandre Dumas'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Hội Nhà văn'), 0, 0, N'Bá tước Monte-Cristo', N'Nxb. Hội Nhà văn', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ba-tuoc-monte-cristo-202610059570813194019'),
        (N'Chân dung Dorian Gray', N'9786047765218', 2019, N'Dorian Gray giữ mãi vẻ trẻ trung trong khi bức chân dung gánh mọi dấu vết sa đọa, phơi bày cái giá của khoái lạc và phù phiếm. Tác phẩm do Oscar Wilde viết; ấn bản 2022 có 579 trang, trình bày bằng tiếng anh và do NXB Văn Học phát hành.', N'the-picture-of-dorian-gray.jpg', N'Tiếng Việt', 579, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Oscar Wilde'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thế giới'), 0, 0, N'Chân dung Dorian Gray', N'Thế giới', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/chan-dung-dorian-gray-20268430750813190246'),
        (N'Inferno', '9786040001641', 2014, N'Inferno là tác phẩm của Dan Brown, thuộc nhóm Trinh thám - Kinh dị; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'inferno.jpg', N'Tiếng Anh', 368, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Dan Brown'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Frankenstein - Hay Prometheus thời hiện đại', N'9786042402095', 2026, N'Victor Frankenstein tạo ra sự sống rồi ruồng bỏ sinh vật của mình, dẫn tới chuỗi bi kịch về cô độc, định kiến và trách nhiệm khoa học. Tác phẩm do Mary Shelley viết; ấn bản 2024 có 233 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'frankenstein.jpg', N'Tiếng Việt', 359, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Mary Shelley'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Kim Đồng'), 0, 0, N'Frankenstein - Hay Prometheus thời hiện đại', N'Kim Đồng', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/frankenstein---hay-prometheus-thoi-hien-202611186960813200835'),
        (N'Bác sĩ Jekyll và ông Hyde', N'9786042107747', 2018, N'Bác sĩ Jekyll tách phần bản năng thành nhân dạng Hyde, nhưng thí nghiệm dần giải phóng một cái ác không còn kiểm soát được. Tác phẩm do Robert Louis Stevenson viết; ấn bản 2000 có 270 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'the-strange-case-of-dr-jekyll-and-mr-hyde.jpg', N'Tiếng Việt', 53, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Robert Louis Stevenson'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Kim Đồng'), 0, 0, N'Bác sĩ Jekyll và ông Hyde', N'Kim Đồng', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/bac-si-jekyll-va-ong-hyde-20267944000813185309'),
        (N'Vòng quanh thế giới trong 80 ngày', N'9786049575808', 2017, N'Phileas Fogg đánh cược rằng có thể vòng quanh thế giới trong tám mươi ngày, lao vào cuộc đua đầy sự cố cùng người hầu Passepartout. Tác phẩm do Jules Verne viết; ấn bản 2001 có 307 trang, trình bày bằng tiếng anh và do NXB Văn Học phát hành.', N'around-the-world-in-eighty-days.jpg', N'Tiếng Việt', 346, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'Jules Verne'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học ; Công ty Sách và Thiết bị giáo dục Trí Tuệ'), 0, 0, N'Vòng quanh thế giới trong 80 ngày', N'Văn học ; Công ty Sách và Thiết bị giáo dục Trí Tuệ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/vong-quanh-the-gioi-trong-80-ngay-20267673560813184740'),
        (N'Hai vạn dặm dưới biển', N'9786049769269', 2019, N'Giáo sư Aronnax lên tàu ngầm Nautilus của thuyền trưởng Nemo, khám phá kỳ quan đại dương và bí mật của con người chối bỏ đất liền. Tác phẩm do Jules Verne viết; ấn bản 2002 có 344 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'twenty-thousand-leagues-under-the-sea.jpg', N'Tiếng Việt', 403, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Jules Verne'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học ; Công ty Văn hoá và Giáo dục Tân Việt'), 0, 0, N'Hai vạn dặm dưới biển', N'Văn học ; Công ty Văn hoá và Giáo dục Tân Việt', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/hai-van-dam-duoi-bien-20268548880813190628'),
        (N'Hành trình vào tâm trái đất', N'9786049639708', 2018, N'Giáo sư Lidenbrock giải mã bản thảo cổ rồi dẫn đoàn thám hiểm xuyên lòng đất, gặp biển ngầm, sinh vật tiền sử và hiểm họa địa chất. Tác phẩm do Jules Verne viết; ấn bản 2003 có 381 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'journey-to-the-center-of-the-earth.jpg', N'Tiếng Việt', 383, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học viễn tưởng'), (SELECT author_id FROM Authors WHERE author_name = N'Jules Verne'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học'), 0, 0, N'Hành trình vào tâm trái đất', N'Văn học', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/hanh-trinh-vao-tam-trai-dat-20268163030813185913'),
        (N'Những cuộc phiêu lưu của Sherlock Holmes', N'9786049635076', 2018, N'Mười hai vụ án giới thiệu tài quan sát của Sherlock Holmes và lối kể tỉnh táo của bác sĩ Watson tại London thời Victoria. Tác phẩm do Arthur Conan Doyle viết; ấn bản 2004 có 418 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'The-adventures-of-sherlock-holmes.jpg', N'Tiếng Việt', 306, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Arthur Conan Doyle'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học'), 0, 0, N'Những cuộc phiêu lưu của Sherlock Holmes', N'Văn học', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nhung-cuoc-phieu-luu-cua-sherlock-holmes-20268164160813185906'),
        (N'The Shining', '9786040001665', 2016, N'The Shining là tác phẩm của Stephen King, thuộc nhóm Trinh thám - Kinh dị; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'the-shining.jpg', N'Tiếng Anh', 442, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Stephen King'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Án mạng trên chuyến tàu tốc hành phương Đông', N'9786041111523', 2017, N'Hercule Poirot điều tra một vụ giết người trên chuyến tàu mắc kẹt trong tuyết, nơi mọi hành khách đều có bí mật và chứng cứ ngoại phạm. Tác phẩm do Agatha Christie viết; ấn bản 2006 có 492 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'murder-on-the-orient-express.jpg', N'Tiếng Việt', 297, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Agatha Christie'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Án mạng trên chuyến tàu tốc hành phương Đông', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/an-mang-tren-chuyen-tau-toc-hanh-phuong-20267685730813184937'),
        (N'Và rồi chẳng còn ai', N'9786041188396', 2021, N'Mười người lạ bị mời ra đảo rồi lần lượt chết theo một bài đồng dao, trong khi hung thủ dường như không thể là người ngoài. Tác phẩm do Agatha Christie viết; ấn bản 2007 có 529 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'and-then-there-were-none.jpg', N'Tiếng Việt', 295, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Agatha Christie'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Và rồi chẳng còn ai', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/va-roi-chang-con-ai-20269234600813192627'),
        (N'Vụ ám sát ông Roger Ackroyd', N'9786041065789', 2017, N'Poirot điều tra cái chết của Roger Ackroyd qua lời kể của bác sĩ Sheppard, dẫn tới một trong những cú lật nổi tiếng nhất trinh thám. Tác phẩm do Agatha Christie viết; ấn bản 2008 có 566 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'the-murder-of-roger-ackroyd.jpg', N'Tiếng Việt', 357, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Agatha Christie'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Vụ ám sát ông Roger Ackroyd', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/vu-am-sat-ong-roger-ackroyd-20267686040813184545'),
        (N'Cô gái có hình xăm rồng', N'9786045663837', 2019, N'Nhà báo Mikael Blomkvist và hacker Lisbeth Salander cùng điều tra vụ mất tích kéo dài nhiều thập kỷ trong một gia đình công nghiệp quyền lực. Tác phẩm do Stieg Larsson viết; ấn bản 2009 có 183 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'the-girl-with-the-dragon-tattoo.jpg', N'Tiếng Việt', 549, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Stieg Larsson'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Phụ nữ'), 0, 0, N'Cô gái có hình xăm rồng', N'Phụ nữ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/co-gai-co-hinh-xam-rong-20268481970813190344'),
        (N'Cô gái mất tích', N'9786045922439', 2014, N'Khi Amy biến mất đúng dịp kỷ niệm cưới, Nick trở thành nghi phạm và cuộc hôn nhân của họ lộ ra như một trò thao túng đầy độc hại. Tác phẩm do Gillian Flynn viết; ấn bản 2010 có 220 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'gone-girl.jpg', N'Tiếng Việt', 651, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Gillian Flynn'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Lao động ; Công ty Sách Alpha'), 0, 0, N'Cô gái mất tích', N'Lao động ; Công ty Sách Alpha', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/co-gai-mat-tich-20266482130813183046'),
        (N'Bệnh nhân câm lặng', N'9786049979903', 2020, N'Họa sĩ Alicia im lặng sau khi bắn chồng; nhà trị liệu Theo quyết giải mã sự câm lặng ấy và bước vào chiếc bẫy của chính mình. Tác phẩm do Alex Michaelides viết; ấn bản 2011 có 257 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'the-silent-patient.jpg', N'Tiếng Việt', 407, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Alex Michaelides'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thanh niên ; Công ty Văn hoá Đinh Tị'), 0, 0, N'Bệnh nhân câm lặng', N'Thanh niên ; Công ty Văn hoá Đinh Tị', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/benh-nhan-cam-lang-20268795890813191236'),
        (N'Thiên thần và ác quỷ', N'9786049898624', 2020, N'Một biểu tượng học chạy đua khắp Rome để ngăn âm mưu Illuminati, lần theo bốn bàn thờ khoa học trước khi Vatican bị hủy diệt. Tác phẩm do Dan Brown viết; ấn bản 2013 có 331 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'angels-vs-demons.jpg', N'Tiếng Việt', 726, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Dan Brown'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Lao động ; Công ty Sách Bách Việt'), 0, 0, N'Thiên thần và ác quỷ', N'Lao động ; Công ty Sách Bách Việt', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/thien-than-va-ac-quy-20268644580813190549'),
        (N'It', '9786040001672', 2017, N'It là tác phẩm của Stephen King, thuộc nhóm Trinh thám - Kinh dị; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'it.jpg', N'Tiếng Anh', 479, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Stephen King'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Pháo đài số', N'9786049815607', 2019, N'Nhà giải mã Susan Fletcher phát hiện siêu máy tính NSA bị một thuật toán bất khả phá đe dọa, kéo cô vào cuộc đấu về bí mật và quyền riêng tư. Tác phẩm do Dan Brown viết; ấn bản 2015 có 405 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'digital-fortress.jpg', N'Tiếng Việt', 585, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Dan Brown'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Lao động ; Công ty Sách Bách Việt'), 0, 0, N'Pháo đài số', N'Lao động ; Công ty Sách Bách Việt', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/phao-dai-so-20268339850813190447'),
        (N'Misery', '9786040001689', 2018, N'Misery là tác phẩm của Stephen King, thuộc nhóm Trinh thám - Kinh dị; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'misery.jpg', N'Tiếng Anh', 516, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Stephen King'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Pet Sematary', '9786040001696', 2019, N'Pet Sematary là tác phẩm của Stephen King, thuộc nhóm Trinh thám - Kinh dị; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'pet-sematary.jpg', N'Tiếng Anh', 553, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Stephen King'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Colorless Tsukuru Tazaki', '9786040001726', 2022, N'Colorless Tsukuru Tazaki là tác phẩm của Haruki Murakami, thuộc nhóm Tiểu thuyết; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'colorless-tsukuru-tazaki.jpg', N'Tiếng Anh', 244, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Haruki Murakami'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'The Wind-Up Bird Chronicle', '9786040001733', 2023, N'The Wind-Up Bird Chronicle là tác phẩm của Haruki Murakami, thuộc nhóm Tiểu thuyết; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'the-wind-up-bird-chronicle.jpg', N'Tiếng Anh', 281, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Haruki Murakami'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nhã Nam'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Dặm xanh', N'9786044482309', 2026, N'Quản giáo Paul Edgecombe nhớ lại tử tù John Coffey, người có năng lực chữa lành kỳ lạ giữa sự tàn nhẫn của hành lang tử hình. Tác phẩm do Stephen King viết; ấn bản 2020 có 590 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'the-green-mile.jpg', N'Tiếng Việt', 435, (SELECT category_id FROM Categories WHERE category_name = N'Trinh thám - Kinh dị'), (SELECT author_id FROM Authors WHERE author_name = N'Stephen King'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Hà Nội'), 0, 0, N'Dặm xanh', N'Nxb. Hà Nội', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/dam-xanh-202611227820813201018'),
        (N'Những người đàn ông không có đàn bà', N'9786045344064', 2015, N'Bảy truyện ngắn của Haruki Murakami khắc họa những người đàn ông cô độc sau chia lìa, trôi giữa ký ức, âm nhạc và khoảng trống khó gọi tên. Tác phẩm do Haruki Murakami viết; ấn bản 2021 có 207 trang, trình bày bằng tiếng anh và do Nhã Nam phát hành.', N'men-without-women.jpg', N'Tiếng Việt', 252, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Haruki Murakami'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Hội Nhà văn ; Công ty Văn hoá và Truyền thông Nhã Nam'), 0, 0, N'Những người đàn ông không có đàn bà', N'Nxb. Hội Nhà văn ; Công ty Văn hoá và Truyền thông Nhã Nam', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nhung-nguoi-dan-ong-khong-co-dan-ba-20266736870813183429'),
        (N'Thương Nhớ Mười Hai', '9786040001832', 2008, N'Thương Nhớ Mười Hai là tác phẩm của Vũ Bằng, thuộc nhóm Văn học Việt Nam; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'thuong-nho-muoi-hai.jpg', N'Tiếng Việt', 231, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Vũ Bằng'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Vang Bóng Một Thời', '9786040001849', 2009, N'Vang Bóng Một Thời là tác phẩm của Nguyễn Tuân, thuộc nhóm Văn học Việt Nam; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'vang-bong-mot-thoi.jpg', N'Tiếng Việt', 268, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyễn Tuân'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Dế Mèn phiêu lưu ký', N'9786042189606', 2020, N'Dế Mèn kiêu căng gây nên cái chết của Dế Choắt rồi lên đường phiêu lưu, trưởng thành qua tình bạn, hiểm nguy và khát vọng hòa bình. Tác phẩm do Tô Hoài viết; ấn bản 2024 có 318 trang, trình bày bằng tiếng việt và do NXB Kim Đồng phát hành.', N'De-men-phieu-luu-ky.jpg', N'Tiếng Việt', 120, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Tô Hoài'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Kim Đồng'), 0, 0, N'Dế Mèn phiêu lưu ký', N'Kim Đồng', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/de-men-phieu-luu-ky-20268884100813191535'),
        (N'Cho tôi xin một vé đi tuổi thơ', N'9786041157910', 2021, N'Nguyễn Nhật Ánh đưa người lớn trở lại thế giới trẻ thơ, nơi bốn đứa trẻ đặt lại tên cho vạn vật và nhìn cuộc sống bằng trí tưởng tượng trong veo. Tác phẩm do Nguyễn Nhật Ánh viết; ấn bản 2000 có 355 trang, trình bày bằng tiếng việt và do NXB Trẻ phát hành.', N'cho-toi-xin-mot-ve-di-ve-tuoi-tho.jpg', N'Tiếng Việt', 207, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyễn Nhật Ánh'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Cho tôi xin một vé đi tuổi thơ', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/cho-toi-xin-mot-ve-di-tuoi-tho-20269055690813191914'),
        (N'Mắt biếc', N'9786041005143', 2018, N'Tình yêu đơn phương của Ngạn dành cho Hà Lan kéo dài từ làng Đo Đo đến thành phố, đẹp đẽ nhưng nhuốm nỗi buồn của những lựa chọn lệch nhau. Tác phẩm do Nguyễn Nhật Ánh viết; ấn bản 2001 có 392 trang, trình bày bằng tiếng việt và do NXB Trẻ phát hành.', N'mat-biec.jpg', N'Tiếng Việt', 234, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyễn Nhật Ánh'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Mắt biếc', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/mat-biec-20267714320813184551'),
        (N'Tôi thấy hoa vàng trên cỏ xanh', N'9786041116313', 2019, N'Tuổi thơ của Thiều và Tường hiện lên giữa làng quê nghèo, với tình anh em, ghen tị, lỗi lầm và những rung động đầu đời. Tác phẩm do Nguyễn Nhật Ánh viết; ấn bản 2002 có 429 trang, trình bày bằng tiếng việt và do NXB Trẻ phát hành.', N'toi-thay-hoa-vang-tren-co-xanh.jpg', N'Tiếng Việt', 375, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyễn Nhật Ánh'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Tôi thấy hoa vàng trên cỏ xanh', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/toi-thay-hoa-vang-tren-co-xanh-20268291720813185822'),
        (N'Cô gái đến từ hôm qua', N'9786041004825', 2017, N'Anh chàng vụng về hồi tưởng mối tình học trò với cô bạn Tiểu Li, để rồi bất ngờ gặp lại “cô gái đến từ hôm qua” trong hiện tại. Tác phẩm do Nguyễn Nhật Ánh viết; ấn bản 2003 có 466 trang, trình bày bằng tiếng việt và do NXB Trẻ phát hành.', N'co-gai-den-tu-hom-qua.jpg', N'Tiếng Việt', 221, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyễn Nhật Ánh'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Cô gái đến từ hôm qua', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/co-gai-den-tu-hom-qua-20267505150813184451'),
        (N'Ngồi khóc trên cây', N'9786041157965', 2020, N'Đông gặp Rùa trong một miền quê yên bình; tình cảm non trẻ của họ bị thử thách bởi bí mật gia đình và những định kiến của người lớn. Tác phẩm do Nguyễn Nhật Ánh viết; ấn bản 2004 có 503 trang, trình bày bằng tiếng việt và do NXB Trẻ phát hành.', N'ngoi-khoc-tren-cay.jpg', N'Tiếng Việt', 341, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyễn Nhật Ánh'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Ngồi khóc trên cây', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/ngoi-khoc-tren-cay-20268625420813191033'),
        (N'Làm bạn với bầu trời', N'9786041153363', 2019, N'Tèo, một cậu bé chịu nhiều thiệt thòi nhưng luôn nhân hậu, khiến những người quanh mình học lại cách yêu thương và nhìn bầu trời bằng hy vọng. Tác phẩm do Nguyễn Nhật Ánh viết; ấn bản 2005 có 540 trang, trình bày bằng tiếng việt và do NXB Trẻ phát hành.', N'lam-ban-voi-bau-troi.jpg', N'Tiếng Việt', 249, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyễn Nhật Ánh'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Làm bạn với bầu trời', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lam-ban-voi-bau-troi-20268425100813190505'),
        (N'Bắt trẻ đồng xanh', N'9786046916758', 2016, N'Bản dịch Việt của The Catcher in the Rye theo chân Holden Caulfield chống lại sự giả tạo trong khi âm thầm vật lộn với mất mát và cô độc. Tác phẩm do J.D. Salinger viết; ấn bản 2006 có 577 trang, trình bày bằng tiếng anh và do NXB Văn Học phát hành.', N'bat-tre-dong-xanh.jpg', N'Tiếng Việt', 326, (SELECT category_id FROM Categories WHERE category_name = N'Văn học kinh điển'), (SELECT author_id FROM Authors WHERE author_name = N'J.D. Salinger'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam'), 0, 0, N'Bắt trẻ đồng xanh', N'Văn học ; Công ty Văn hoá và Truyền thông Nhã Nam', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/bat-tre-dong-xanh-20267184480813184907'),
        (N'Vừa nhắm mắt vừa mở cửa sổ', N'9786041141094', 2019, N'Một cậu bé học cách cảm nhận khu vườn bằng mùi hương, âm thanh và bàn tay, qua những bài học dịu dàng từ người cha cùng cô bé hàng xóm. Tác phẩm do Nguyễn Ngọc Thuần viết; ấn bản 2007 có 194 trang, trình bày bằng tiếng anh và do NXB Trẻ phát hành.', N'vua-nham-mat-vua-mo-cua-so.jpg', N'Tiếng Việt', 191, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyễn Ngọc Thuần'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Vừa nhắm mắt vừa mở cửa sổ', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/vua-nham-mat-vua-mo-cua-so-20268324050813190423'),
        (N'Rừng Xà Nu', '9786040001931', 2018, N'Rừng Xà Nu là tác phẩm của Nguyễn Trung Thành, thuộc nhóm Văn học Việt Nam; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'rung-xa-nu.jpg', N'Tiếng Việt', 181, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyễn Trung Thành'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Văn Học'), 0, 0, NULL, NULL, NULL, NULL),
        (N'O chuột', '9786040001962', 2021, N'O chuột là tác phẩm của Tô Hoài, thuộc nhóm Văn học Việt Nam; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', 'o-chuot.jpg', N'Tiếng Việt', 292, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Tô Hoài'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Kim Đồng'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Số đỏ', N'9786049692932', 2018, N'Xuân Tóc Đỏ tình cờ leo lên thượng lưu Hà Nội thuộc địa, qua đó Vũ Trọng Phụng châm biếm phong trào Âu hóa và xã hội trưởng giả lố lăng. Tác phẩm do Vũ Trọng Phụng viết; ấn bản 2010 có 305 trang, trình bày bằng tiếng việt và do NXB Văn Học phát hành.', N'so-do.jpg', N'Tiếng Việt', 267, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Vũ Trọng Phụng'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học ; Công ty Văn hóa Truyền thông Sống'), 0, 0, N'Số đỏ', N'Văn học ; Công ty Văn hóa Truyền thông Sống', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/so-do-20268161720813185702'),
        (N'Chí Phèo', N'9786046947004', 2017, N'Chí Phèo từ người nông dân lương thiện bị đẩy thành kẻ lưu manh, rồi khát khao làm người trở lại nhờ tình thương của Thị Nở. Tác phẩm do Nam Cao viết; ấn bản 2011 có 342 trang, trình bày bằng tiếng việt và do NXB Văn Học phát hành.', N'chi-pheo.jpg', N'Tiếng Việt', 207, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nam Cao'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học ; Công ty Văn hoá Huy Hoàng'), 0, 0, N'Chí Phèo', N'Văn học ; Công ty Văn hoá Huy Hoàng', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/chi-pheo-20267601990813184118'),
        (N'Tắt đèn', N'9786326242553', 2025, N'Chị Dậu chạy vạy cứu chồng giữa sưu thuế hà khắc, phơi bày cảnh bần cùng và sức phản kháng của người phụ nữ nông dân. Tác phẩm do Ngô Tất Tố viết; ấn bản 2012 có 379 trang, trình bày bằng tiếng việt và do NXB Văn Học phát hành.', N'tat-den.jpg', N'Tiếng Việt', 155, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Ngô Tất Tố'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học'), 0, 0, N'Tắt đèn', N'Văn học', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/tat-den-202611094160813200934'),
        (N'Lão Hạc', N'9786049541582', 2017, N'Lão Hạc bán cậu Vàng rồi chọn cái chết để giữ mảnh vườn cho con, trong câu chuyện đau xót về nghèo đói và lòng tự trọng. Tác phẩm do Nam Cao viết; ấn bản 2013 có 416 trang, trình bày bằng tiếng việt và do NXB Văn Học phát hành.', N'lao-hac.jpg', N'Tiếng Việt', 206, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nam Cao'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học ; Công ty Văn hoá Sáng tạo Trí Việt'), 0, 0, N'Lão Hạc', N'Văn học ; Công ty Văn hoá Sáng tạo Trí Việt', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/lao-hac-20267602910813184637'),
        (N'Những ngày thơ ấu', N'9786042138482', 2019, N'Nguyên Hồng kể tuổi thơ thiếu thốn tình cha, xa mẹ và chịu nhiều cay nghiệt, nhưng vẫn giữ một tình yêu mẹ mãnh liệt. Tác phẩm do Nguyên Hồng viết; ấn bản 2014 có 453 trang, trình bày bằng tiếng việt và do NXB Văn Học phát hành.', N'nhung-ngay-tho-au.jpg', N'Tiếng Việt', 118, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyên Hồng'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Kim Đồng'), 0, 0, N'Những ngày thơ ấu', N'Kim Đồng', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/nhung-ngay-tho-au-20268245900813185755'),
        (N'Gió lạnh đầu mùa', N'9786042198080', 2021, N'Những truyện ngắn Thạch Lam ghi lại rung động mong manh trước trẻ nghèo, người lao động và các khoảnh khắc giao mùa của đời sống bình dị. Tác phẩm do Thạch Lam viết; ấn bản 2015 có 490 trang, trình bày bằng tiếng việt và do NXB Văn Học phát hành.', N'gio-lanh-dau-mua.jpg', N'Tiếng Việt', 203, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Thạch Lam'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Kim Đồng'), 0, 0, N'Gió lạnh đầu mùa', N'Kim Đồng', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/gio-lanh-dau-mua-20269170340813192118'),
        (N'Hai đứa trẻ', N'9786043231526', 2021, N'Liên và An ngồi bên phố huyện nghèo chờ chuyến tàu đêm, mang theo ánh sáng thoáng qua giữa cuộc sống quẩn quanh, tĩnh lặng. Tác phẩm do Thạch Lam viết; ấn bản 2016 có 527 trang, trình bày bằng tiếng việt và do NXB Văn Học phát hành.', N'hai-dua-tre.jpg', N'Tiếng Việt', 191, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Thạch Lam'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học'), 0, 0, N'Hai đứa trẻ', N'Văn học', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/hai-dua-tre-20269102550813191810'),
        (N'Vợ nhặt', N'9786049828003', 2020, N'Giữa nạn đói, Tràng “nhặt” được vợ chỉ bằng vài bát bánh đúc; gia đình mới nhen lên hy vọng sống trong hoàn cảnh bi thảm. Tác phẩm do Kim Lân viết; ấn bản 2017 có 564 trang, trình bày bằng tiếng việt và do NXB Văn Học phát hành.', N'vo-nhat.jpg', N'Tiếng Việt', 207, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Kim Lân'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Văn học ; Công ty Văn hoá Đinh Tị'), 0, 0, N'Vợ nhặt', N'Văn học ; Công ty Văn hoá Đinh Tị', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/vo-nhat-20268875020813191513'),
        (N'7 Nguyên Tắc Bất Biến Để Thành Công', '9786040002006', 2000, N'7 Nguyên Tắc Bất Biến Để Thành Công là tác phẩm của Napoleon Hill, thuộc nhóm Kinh doanh; nội dung phù hợp để đọc, học tập và mở rộng kiến thức trong thư viện.', '7-nguyen-tac-bat-bien-de-thanh-cong.jpg', N'Tiếng Việt', 440, (SELECT category_id FROM Categories WHERE category_name = N'Kinh doanh'), (SELECT author_id FROM Authors WHERE author_name = N'Napoleon Hill'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Alphabooks'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Đất rừng phương Nam', N'9786042141444', 2019, N'Cậu bé An lưu lạc khắp miền Tây Nam Bộ thời kháng chiến, kết bạn với những con người hào sảng giữa thiên nhiên sông nước phong phú. Tác phẩm do Đoàn Giỏi viết; ấn bản 2019 có 218 trang, trình bày bằng tiếng việt và do NXB Văn Học phát hành.', N'dat-rung-phuong-nam.jpg', N'Tiếng Việt', 303, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Đoàn Giỏi'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Kim Đồng'), 0, 0, N'Đất rừng phương Nam', N'Kim Đồng', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/dat-rung-phuong-nam-20268246240813185723'),
        (N'Nỗi buồn chiến tranh', N'9786041142121', 2019, N'Kiên trở về sau chiến tranh nhưng bị ký ức đồng đội và tình yêu ám ảnh, viết để đối diện những mất mát không thể khép lại. Tác phẩm do Bảo Ninh viết; ấn bản 2020 có 255 trang, trình bày bằng tiếng việt và do NXB Trẻ phát hành.', N'noi-buon-chien-trang.jpg', N'Tiếng Việt', 347, (SELECT category_id FROM Categories WHERE category_name = N'Văn học Việt Nam'), (SELECT author_id FROM Authors WHERE author_name = N'Bảo Ninh'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Nỗi buồn chiến tranh', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/noi-buon-chien-tranh-20268566250813191059'),
        (N'Mưa đỏ', N'9786041237890', 2024, N'Tiểu thuyết của Chu Lai tái hiện cuộc chiến đấu khốc liệt và sự hy sinh của những người lính trẻ, qua đó làm nổi bật lòng yêu nước, tình đồng đội và ký ức chiến tranh.', N'mua-do-chu-lai.jpg', N'Tiếng Việt', 300, (SELECT category_id FROM Categories WHERE category_name = N'Tiểu thuyết'), (SELECT author_id FROM Authors WHERE author_name = N'Chu Lai'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Trẻ'), 0, 0, NULL, NULL, NULL, NULL),
        (N'Lược sử thời gian', N'9786041143920', 2019, N'Bản tiếng Việt tác phẩm của Stephen Hawking dẫn nhập Big Bang, hố đen và bản chất thời gian bằng những câu hỏi lớn nhưng dễ tiếp cận. Tác phẩm do Stephen Hawking viết; ấn bản 2022 có 329 trang, trình bày bằng tiếng việt và do Nhã Nam phát hành.', N'luoc-su-thoi-gian.jpg', N'Tiếng Việt', 284, (SELECT category_id FROM Categories WHERE category_name = N'Khoa học'), (SELECT author_id FROM Authors WHERE author_name = N'Stephen Hawking'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Nxb. Trẻ'), 0, 0, N'Lược sử thời gian', N'Nxb. Trẻ', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/luoc-su-thoi-gian-20268464420813190427'),
        (N'Hành trình về phương Đông', N'9786047789467', 2021, N'Qua ghi chép về các bậc đạo sư Ấn Độ, cuốn sách dẫn người đọc khảo sát đời sống tinh thần, nghiệp quả và sự hòa hợp giữa Đông với Tây. Tác phẩm do Nguyên Phong viết; ấn bản 2023 có 366 trang, trình bày bằng tiếng việt và do First News phát hành.', N'hanh-trinh-ve-phuong-dong.jpg', N'Tiếng Việt', 251, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Nguyên Phong'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Thế giới ; Công ty Văn hoá Sáng tạo Trí Việt'), 0, 0, N'Hành trình về phương Đông', N'Thế giới ; Công ty Văn hoá Sáng tạo Trí Việt', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/hanh-trinh-ve-phuong-dong-20269109120813191818'),
        (N'Sức mạnh của thói quen', N'9786045958643', 2016, N'Charles Duhigg phân tích vòng lặp tín hiệu–thói quen–phần thưởng và cho thấy cá nhân lẫn tổ chức có thể thay đổi hành vi bằng cách tác động đúng mắt xích. Tác phẩm do Charles Duhigg viết; ấn bản 2024 có 403 trang, trình bày bằng tiếng việt và do First News phát hành.', N'suc-manh-cua-thoi-quen.jpg', N'Tiếng Việt', 433, (SELECT category_id FROM Categories WHERE category_name = N'Kỹ năng sống'), (SELECT author_id FROM Authors WHERE author_name = N'Charles Duhigg'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'Lao động ; Công ty Sách Alpha'), 0, 0, N'Sức mạnh của thói quen', N'Lao động ; Công ty Sách Alpha', NULL, N'https://opac.nlv.gov.vn/chi-tiet-tai-lieu/suc-manh-cua-thoi-quen-20267259340813185223'),
        (N'Khi hơi thở hóa thinh không', N'9786045678901', 2020, N'Hồi ký của bác sĩ Paul Kalanithi kể về hành trình đối diện bệnh nan y, từ đó suy ngẫm sâu sắc về nghề y, ý nghĩa của sự sống và cách con người lựa chọn sống trong quỹ thời gian hữu hạn.', N'khi-hoi-tho-hoa-thinh-khong.jpg', N'Tiếng Việt', 240, (SELECT category_id FROM Categories WHERE category_name = N'Hồi ký'), (SELECT author_id FROM Authors WHERE author_name = N'Paul Kalanithi'), (SELECT publisher_id FROM Publishers WHERE publisher_name = N'NXB Trẻ'), 0, 0, NULL, NULL, NULL, NULL);
    GO

    -- ============================================
    -- BOOK COPIES
    -- ============================================
    INSERT INTO BookCopies
    (book_id,barcode,shelf_location,status,acquired_date)
    VALUES
        (5,'BC000001',N'A1','Available','2025-01-01'),
        (5,'BC000002',N'A1','Borrowed','2025-01-01'),
        (6,'BC000003',N'A2','Available','2025-01-05'),
        (6,'BC000004',N'A2','Available','2025-01-05'),
        (7,'BC000005',N'B1','Available','2025-02-01'),
        (8,'BC000006',N'B2','Available','2025-02-05'),
        (9,'BC000007',N'C1','Available','2025-03-01'),
        (1,'BC000008',N'C2','Available','2025-03-01'),
        (11,'BC000009',N'D1','Available','2025-03-10'),
        (2,'BC000010',N'D2','Available','2025-04-01'),
        (3,'BC000011',N'E1','Available','2025-04-05'),
        (5,'BC000012',N'A1','Available','2026-08-01'),
        (5,'BC000013',N'A1','Available','2026-08-01'),
        (6,'BC000014',N'A2','Available','2026-08-01'),
        (6,'BC000015',N'A2','Available','2026-08-01'),
        (7,'BC000016',N'B1','Available','2026-08-02'),
        (7,'BC000017',N'B1','Available','2026-08-02'),
        (8,'BC000018',N'B2','Available','2026-08-02'),
        (8,'BC000019',N'B2','Available','2026-08-02'),
        (9,'BC000020',N'C1','Available','2026-08-03'),
        (9,'BC000021',N'C1','Available','2026-08-03'),
        (1,'BC000022',N'C2','Available','2026-08-03'),
        (1,'BC000023',N'C2','Available','2026-08-03'),
        (11,'BC000024',N'D1','Available','2026-08-04'),
        (11,'BC000025',N'D1','Available','2026-08-04'),
        (2,'BC000026',N'D2','Available','2026-08-04'),
        (2,'BC000027',N'D2','Available','2026-08-04'),
        (3,'BC000028',N'E1','Available','2026-08-05'),
        (3,'BC000029',N'E1','Available','2026-08-05');
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


    -- ============================================
    -- UPDATE shelf_location cho 29 ban sao GOC
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
    -- INSERT 402 ban sao cho 201 sach bo sung
    -- ============================================
    INSERT INTO BookCopies (book_id, barcode, shelf_location, status, acquired_date)
    VALUES
        (4, 'BC000030', N'KNS-08', 'Available', '2026-08-07'),
        (4, 'BC000031', N'KNS-08', 'Available', '2026-08-07'),
        (5, 'BC000032', N'TTH-07', 'Available', '2026-08-07'),
        (5, 'BC000033', N'TTH-07', 'Available', '2026-08-07'),
        (6, 'BC000034', N'KNS-09', 'Available', '2026-08-07'),
        (6, 'BC000035', N'KNS-09', 'Available', '2026-08-07'),
        (7, 'BC000036', N'KNS-10', 'Available', '2026-08-07'),
        (7, 'BC000037', N'KNS-10', 'Available', '2026-08-07'),
        (8, 'BC000038', N'KNS-11', 'Available', '2026-08-07'),
        (8, 'BC000039', N'KNS-11', 'Available', '2026-08-07'),
        (9, 'BC000040', N'HK-04', 'Available', '2026-08-07'),
        (9, 'BC000041', N'HK-04', 'Available', '2026-08-07'),
        (10, 'BC000042', N'KNS-12', 'Available', '2026-08-07'),
        (10, 'BC000043', N'KNS-12', 'Available', '2026-08-07'),
        (11, 'BC000044', N'TL-01', 'Available', '2026-08-07'),
        (11, 'BC000045', N'TL-01', 'Available', '2026-08-07'),
        (12, 'BC000046', N'KD-05', 'Available', '2026-08-08'),
        (12, 'BC000047', N'KD-05', 'Available', '2026-08-08'),
        (13, 'BC000048', N'KNS-13', 'Available', '2026-08-08'),
        (13, 'BC000049', N'KNS-13', 'Available', '2026-08-08'),
        (14, 'BC000050', N'KNS-14', 'Available', '2026-08-08'),
        (14, 'BC000051', N'KNS-14', 'Available', '2026-08-08'),
        (15, 'BC000052', N'TL-02', 'Available', '2026-08-08'),
        (15, 'BC000053', N'TL-02', 'Available', '2026-08-08'),
        (16, 'BC000054', N'KD-06', 'Available', '2026-08-08'),
        (16, 'BC000055', N'KD-06', 'Available', '2026-08-08'),
        (17, 'BC000056', N'KNS-15', 'Available', '2026-08-08'),
        (17, 'BC000057', N'KNS-15', 'Available', '2026-08-08'),
        (18, 'BC000058', N'KNS-16', 'Available', '2026-08-08'),
        (18, 'BC000059', N'KNS-16', 'Available', '2026-08-08'),
        (19, 'BC000060', N'KNS-17', 'Available', '2026-08-08'),
        (19, 'BC000061', N'KNS-17', 'Available', '2026-08-08'),
        (20, 'BC000062', N'KD-07', 'Available', '2026-08-09'),
        (20, 'BC000063', N'KD-07', 'Available', '2026-08-09'),
        (21, 'BC000064', N'KNS-18', 'Available', '2026-08-09'),
        (21, 'BC000065', N'KNS-18', 'Available', '2026-08-09'),
        (22, 'BC000066', N'KNS-19', 'Available', '2026-08-09'),
        (22, 'BC000067', N'KNS-19', 'Available', '2026-08-09'),
        (23, 'BC000068', N'KNS-20', 'Available', '2026-08-09'),
        (23, 'BC000069', N'KNS-20', 'Available', '2026-08-09'),
        (24, 'BC000070', N'KD-08', 'Available', '2026-08-09'),
        (24, 'BC000071', N'KD-08', 'Available', '2026-08-09'),
        (25, 'BC000072', N'KD-09', 'Available', '2026-08-09'),
        (25, 'BC000073', N'KD-09', 'Available', '2026-08-09'),
        (26, 'BC000074', N'KD-10', 'Available', '2026-08-09'),
        (26, 'BC000075', N'KD-10', 'Available', '2026-08-09'),
        (27, 'BC000076', N'KD-11', 'Available', '2026-08-09'),
        (27, 'BC000077', N'KD-11', 'Available', '2026-08-09'),
        (28, 'BC000078', N'KD-12', 'Available', '2026-08-10'),
        (28, 'BC000079', N'KD-12', 'Available', '2026-08-10'),
        (29, 'BC000080', N'KD-13', 'Available', '2026-08-10'),
        (29, 'BC000081', N'KD-13', 'Available', '2026-08-10'),
        (30, 'BC000082', N'CN-04', 'Available', '2026-08-10'),
        (30, 'BC000083', N'CN-04', 'Available', '2026-08-10'),
        (31, 'BC000084', N'CN-05', 'Available', '2026-08-10'),
        (31, 'BC000085', N'CN-05', 'Available', '2026-08-10'),
        (32, 'BC000086', N'CN-06', 'Available', '2026-08-10'),
        (32, 'BC000087', N'CN-06', 'Available', '2026-08-10'),
        (33, 'BC000088', N'CN-07', 'Available', '2026-08-10'),
        (33, 'BC000089', N'CN-07', 'Available', '2026-08-10'),
        (34, 'BC000090', N'CN-08', 'Available', '2026-08-10'),
        (34, 'BC000091', N'CN-08', 'Available', '2026-08-10'),
        (35, 'BC000092', N'CN-09', 'Available', '2026-08-10'),
        (35, 'BC000093', N'CN-09', 'Available', '2026-08-10'),
        (36, 'BC000094', N'CN-10', 'Available', '2026-08-11'),
        (36, 'BC000095', N'CN-10', 'Available', '2026-08-11'),
        (37, 'BC000096', N'CN-11', 'Available', '2026-08-11'),
        (37, 'BC000097', N'CN-11', 'Available', '2026-08-11'),
        (38, 'BC000098', N'CN-12', 'Available', '2026-08-11'),
        (38, 'BC000099', N'CN-12', 'Available', '2026-08-11'),
        (39, 'BC000100', N'CN-13', 'Available', '2026-08-11'),
        (39, 'BC000101', N'CN-13', 'Available', '2026-08-11'),
        (40, 'BC000102', N'CN-14', 'Available', '2026-08-11'),
        (40, 'BC000103', N'CN-14', 'Available', '2026-08-11'),
        (41, 'BC000104', N'CN-15', 'Available', '2026-08-11'),
        (41, 'BC000105', N'CN-15', 'Available', '2026-08-11'),
        (42, 'BC000106', N'CN-16', 'Available', '2026-08-11'),
        (42, 'BC000107', N'CN-16', 'Available', '2026-08-11'),
        (43, 'BC000108', N'CN-17', 'Available', '2026-08-11'),
        (43, 'BC000109', N'CN-17', 'Available', '2026-08-11'),
        (44, 'BC000110', N'CN-18', 'Available', '2026-08-12'),
        (44, 'BC000111', N'CN-18', 'Available', '2026-08-12'),
        (45, 'BC000112', N'CN-19', 'Available', '2026-08-12'),
        (45, 'BC000113', N'CN-19', 'Available', '2026-08-12'),
        (46, 'BC000114', N'CN-20', 'Available', '2026-08-12'),
        (46, 'BC000115', N'CN-20', 'Available', '2026-08-12'),
        (47, 'BC000116', N'CN-21', 'Available', '2026-08-12'),
        (47, 'BC000117', N'CN-21', 'Available', '2026-08-12'),
        (48, 'BC000118', N'CN-22', 'Available', '2026-08-12'),
        (48, 'BC000119', N'CN-22', 'Available', '2026-08-12'),
        (49, 'BC000120', N'CN-23', 'Available', '2026-08-12'),
        (49, 'BC000121', N'CN-23', 'Available', '2026-08-12'),
        (50, 'BC000122', N'CN-24', 'Available', '2026-08-12'),
        (50, 'BC000123', N'CN-24', 'Available', '2026-08-12'),
        (51, 'BC000124', N'CN-25', 'Available', '2026-08-12'),
        (51, 'BC000125', N'CN-25', 'Available', '2026-08-12'),
        (52, 'BC000126', N'CN-26', 'Available', '2026-08-13'),
        (52, 'BC000127', N'CN-26', 'Available', '2026-08-13'),
        (53, 'BC000128', N'CN-27', 'Available', '2026-08-13'),
        (53, 'BC000129', N'CN-27', 'Available', '2026-08-13'),
        (54, 'BC000130', N'CN-28', 'Available', '2026-08-13'),
        (54, 'BC000131', N'CN-28', 'Available', '2026-08-13'),
        (55, 'BC000132', N'CN-29', 'Available', '2026-08-13'),
        (55, 'BC000133', N'CN-29', 'Available', '2026-08-13'),
        (56, 'BC000134', N'CN-30', 'Available', '2026-08-13'),
        (56, 'BC000135', N'CN-30', 'Available', '2026-08-13'),
        (57, 'BC000136', N'CN-31', 'Available', '2026-08-13'),
        (57, 'BC000137', N'CN-31', 'Available', '2026-08-13'),
        (58, 'BC000138', N'CN-32', 'Available', '2026-08-13'),
        (58, 'BC000139', N'CN-32', 'Available', '2026-08-13'),
        (59, 'BC000140', N'CN-33', 'Available', '2026-08-13'),
        (59, 'BC000141', N'CN-33', 'Available', '2026-08-13'),
        (60, 'BC000142', N'CN-34', 'Available', '2026-08-14'),
        (60, 'BC000143', N'CN-34', 'Available', '2026-08-14'),
        (61, 'BC000144', N'CN-35', 'Available', '2026-08-14'),
        (61, 'BC000145', N'CN-35', 'Available', '2026-08-14'),
        (62, 'BC000146', N'CN-36', 'Available', '2026-08-14'),
        (62, 'BC000147', N'CN-36', 'Available', '2026-08-14'),
        (63, 'BC000148', N'CN-37', 'Available', '2026-08-14'),
        (63, 'BC000149', N'CN-37', 'Available', '2026-08-14'),
        (64, 'BC000150', N'CN-38', 'Available', '2026-08-14'),
        (64, 'BC000151', N'CN-38', 'Available', '2026-08-14'),
        (65, 'BC000152', N'VHKD-01', 'Available', '2026-08-14'),
        (65, 'BC000153', N'VHKD-01', 'Available', '2026-08-14'),
        (66, 'BC000154', N'KHVT-01', 'Available', '2026-08-14'),
        (66, 'BC000155', N'KHVT-01', 'Available', '2026-08-14'),
        (67, 'BC000156', N'VHKD-02', 'Available', '2026-08-14'),
        (67, 'BC000157', N'VHKD-02', 'Available', '2026-08-14'),
        (68, 'BC000158', N'VHKD-03', 'Available', '2026-08-15'),
        (68, 'BC000159', N'VHKD-03', 'Available', '2026-08-15'),
        (69, 'BC000160', N'VHKD-04', 'Available', '2026-08-15'),
        (69, 'BC000161', N'VHKD-04', 'Available', '2026-08-15'),
        (180, 'BC000162', N'VHKD-05', 'Available', '2026-08-15'),
        (180, 'BC000163', N'VHKD-05', 'Available', '2026-08-15'),
        (70, 'BC000164', N'FT-04', 'Available', '2026-08-15'),
        (70, 'BC000165', N'FT-04', 'Available', '2026-08-15'),
        (71, 'BC000166', N'FT-05', 'Available', '2026-08-15'),
        (71, 'BC000167', N'FT-05', 'Available', '2026-08-15'),
        (72, 'BC000168', N'FT-06', 'Available', '2026-08-15'),
        (72, 'BC000169', N'FT-06', 'Available', '2026-08-15'),
        (73, 'BC000170', N'FT-07', 'Available', '2026-08-15'),
        (73, 'BC000171', N'FT-07', 'Available', '2026-08-15'),
        (74, 'BC000172', N'FT-08', 'Available', '2026-08-15'),
        (74, 'BC000173', N'FT-08', 'Available', '2026-08-15'),
        (75, 'BC000174', N'FT-09', 'Available', '2026-08-16'),
        (75, 'BC000175', N'FT-09', 'Available', '2026-08-16'),
        (76, 'BC000176', N'FT-10', 'Available', '2026-08-16'),
        (76, 'BC000177', N'FT-10', 'Available', '2026-08-16'),
        (77, 'BC000178', N'FT-11', 'Available', '2026-08-16'),
        (77, 'BC000179', N'FT-11', 'Available', '2026-08-16'),
        (78, 'BC000180', N'FT-12', 'Available', '2026-08-16'),
        (78, 'BC000181', N'FT-12', 'Available', '2026-08-16'),
        (79, 'BC000182', N'VHKD-06', 'Available', '2026-08-16'),
        (79, 'BC000183', N'VHKD-06', 'Available', '2026-08-16'),
        (80, 'BC000184', N'VHKD-07', 'Available', '2026-08-16'),
        (80, 'BC000185', N'VHKD-07', 'Available', '2026-08-16'),
        (5, 'BC000186', N'TTH-08', 'Available', '2026-08-16'),
        (5, 'BC000187', N'TTH-08', 'Available', '2026-08-16'),
        (81, 'BC000188', N'TTH-09', 'Available', '2026-08-16'),
        (81, 'BC000189', N'TTH-09', 'Available', '2026-08-16'),
        (82, 'BC000190', N'TTH-10', 'Available', '2026-08-17'),
        (82, 'BC000191', N'TTH-10', 'Available', '2026-08-17'),
        (83, 'BC000192', N'VHKD-08', 'Available', '2026-08-17'),
        (83, 'BC000193', N'VHKD-08', 'Available', '2026-08-17'),
        (84, 'BC000194', N'TTH-11', 'Available', '2026-08-17'),
        (84, 'BC000195', N'TTH-11', 'Available', '2026-08-17'),
        (85, 'BC000196', N'TTH-12', 'Available', '2026-08-17'),
        (85, 'BC000197', N'TTH-12', 'Available', '2026-08-17'),
        (86, 'BC000198', N'TTH-13', 'Available', '2026-08-17'),
        (86, 'BC000199', N'TTH-13', 'Available', '2026-08-17'),
        (87, 'BC000200', N'TTH-14', 'Available', '2026-08-17'),
        (87, 'BC000201', N'TTH-14', 'Available', '2026-08-17'),
        (88, 'BC000202', N'TTH-15', 'Available', '2026-08-17'),
        (88, 'BC000203', N'TTH-15', 'Available', '2026-08-17'),
        (89, 'BC000204', N'KHVT-02', 'Available', '2026-08-17'),
        (89, 'BC000205', N'KHVT-02', 'Available', '2026-08-17'),
        (90, 'BC000206', N'KHVT-03', 'Available', '2026-08-18'),
        (90, 'BC000207', N'KHVT-03', 'Available', '2026-08-18'),
        (91, 'BC000208', N'KHVT-04', 'Available', '2026-08-18'),
        (91, 'BC000209', N'KHVT-04', 'Available', '2026-08-18'),
        (92, 'BC000210', N'KHVT-05', 'Available', '2026-08-18'),
        (92, 'BC000211', N'KHVT-05', 'Available', '2026-08-18'),
        (93, 'BC000212', N'KHVT-06', 'Available', '2026-08-18'),
        (93, 'BC000213', N'KHVT-06', 'Available', '2026-08-18'),
        (94, 'BC000214', N'KHVT-07', 'Available', '2026-08-18'),
        (94, 'BC000215', N'KHVT-07', 'Available', '2026-08-18'),
        (95, 'BC000216', N'KHVT-08', 'Available', '2026-08-18'),
        (95, 'BC000217', N'KHVT-08', 'Available', '2026-08-18'),
        (96, 'BC000218', N'KHVT-09', 'Available', '2026-08-18'),
        (96, 'BC000219', N'KHVT-09', 'Available', '2026-08-18'),
        (97, 'BC000220', N'KHVT-10', 'Available', '2026-08-18'),
        (97, 'BC000221', N'KHVT-10', 'Available', '2026-08-18'),
        (98, 'BC000222', N'KHVT-11', 'Available', '2026-08-19'),
        (98, 'BC000223', N'KHVT-11', 'Available', '2026-08-19'),
        (99, 'BC000224', N'TTH-16', 'Available', '2026-08-19'),
        (99, 'BC000225', N'TTH-16', 'Available', '2026-08-19'),
        (100, 'BC000226', N'TTH-17', 'Available', '2026-08-19'),
        (100, 'BC000227', N'TTH-17', 'Available', '2026-08-19'),
        (101, 'BC000228', N'TTH-18', 'Available', '2026-08-19'),
        (101, 'BC000229', N'TTH-18', 'Available', '2026-08-19'),
        (102, 'BC000230', N'TTH-19', 'Available', '2026-08-19'),
        (102, 'BC000231', N'TTH-19', 'Available', '2026-08-19'),
        (103, 'BC000232', N'HK-05', 'Available', '2026-08-19'),
        (103, 'BC000233', N'HK-05', 'Available', '2026-08-19'),
        (104, 'BC000234', N'HK-06', 'Available', '2026-08-19'),
        (104, 'BC000235', N'HK-06', 'Available', '2026-08-19'),
        (105, 'BC000236', N'HK-07', 'Available', '2026-08-19'),
        (105, 'BC000237', N'HK-07', 'Available', '2026-08-19'),
        (106, 'BC000238', N'HK-08', 'Available', '2026-08-20'),
        (106, 'BC000239', N'HK-08', 'Available', '2026-08-20'),
        (107, 'BC000240', N'KH-01', 'Available', '2026-08-20'),
        (107, 'BC000241', N'KH-01', 'Available', '2026-08-20'),
        (108, 'BC000242', N'KH-02', 'Available', '2026-08-20'),
        (108, 'BC000243', N'KH-02', 'Available', '2026-08-20'),
        (109, 'BC000244', N'KH-03', 'Available', '2026-08-20'),
        (109, 'BC000245', N'KH-03', 'Available', '2026-08-20'),
        (110, 'BC000246', N'KH-04', 'Available', '2026-08-20'),
        (110, 'BC000247', N'KH-04', 'Available', '2026-08-20'),
        (196, 'BC000248', N'KH-05', 'Available', '2026-08-20'),
        (196, 'BC000249', N'KH-05', 'Available', '2026-08-20'),
        (111, 'BC000250', N'KH-06', 'Available', '2026-08-20'),
        (111, 'BC000251', N'KH-06', 'Available', '2026-08-20'),
        (112, 'BC000252', N'KH-07', 'Available', '2026-08-20'),
        (112, 'BC000253', N'KH-07', 'Available', '2026-08-20'),
        (113, 'BC000254', N'KH-08', 'Available', '2026-08-21'),
        (113, 'BC000255', N'KH-08', 'Available', '2026-08-21'),
        (114, 'BC000256', N'KH-09', 'Available', '2026-08-21'),
        (114, 'BC000257', N'KH-09', 'Available', '2026-08-21'),
        (115, 'BC000258', N'KH-10', 'Available', '2026-08-21'),
        (115, 'BC000259', N'KH-10', 'Available', '2026-08-21'),
        (116, 'BC000260', N'KH-11', 'Available', '2026-08-21'),
        (116, 'BC000261', N'KH-11', 'Available', '2026-08-21'),
        (117, 'BC000262', N'KH-12', 'Available', '2026-08-21'),
        (117, 'BC000263', N'KH-12', 'Available', '2026-08-21'),
        (118, 'BC000264', N'KH-13', 'Available', '2026-08-21'),
        (118, 'BC000265', N'KH-13', 'Available', '2026-08-21'),
        (119, 'BC000266', N'KH-14', 'Available', '2026-08-21'),
        (119, 'BC000267', N'KH-14', 'Available', '2026-08-21'),
        (120, 'BC000268', N'TL-03', 'Available', '2026-08-21'),
        (120, 'BC000269', N'TL-03', 'Available', '2026-08-21'),
        (121, 'BC000270', N'TL-04', 'Available', '2026-08-22'),
        (121, 'BC000271', N'TL-04', 'Available', '2026-08-22'),
        (122, 'BC000272', N'TL-05', 'Available', '2026-08-22'),
        (122, 'BC000273', N'TL-05', 'Available', '2026-08-22'),
        (123, 'BC000274', N'TL-06', 'Available', '2026-08-22'),
        (123, 'BC000275', N'TL-06', 'Available', '2026-08-22'),
        (124, 'BC000276', N'TL-07', 'Available', '2026-08-22'),
        (124, 'BC000277', N'TL-07', 'Available', '2026-08-22'),
        (125, 'BC000278', N'TL-08', 'Available', '2026-08-22'),
        (125, 'BC000279', N'TL-08', 'Available', '2026-08-22'),
        (126, 'BC000280', N'KD-14', 'Available', '2026-08-22'),
        (126, 'BC000281', N'KD-14', 'Available', '2026-08-22'),
        (127, 'BC000282', N'KD-15', 'Available', '2026-08-22'),
        (127, 'BC000283', N'KD-15', 'Available', '2026-08-22'),
        (128, 'BC000284', N'KNS-21', 'Available', '2026-08-22'),
        (128, 'BC000285', N'KNS-21', 'Available', '2026-08-22'),
        (129, 'BC000286', N'KNS-22', 'Available', '2026-08-23'),
        (129, 'BC000287', N'KNS-22', 'Available', '2026-08-23'),
        (130, 'BC000288', N'KNS-23', 'Available', '2026-08-23'),
        (130, 'BC000289', N'KNS-23', 'Available', '2026-08-23'),
        (131, 'BC000290', N'KNS-24', 'Available', '2026-08-23'),
        (131, 'BC000291', N'KNS-24', 'Available', '2026-08-23'),
        (132, 'BC000292', N'TL-09', 'Available', '2026-08-23'),
        (132, 'BC000293', N'TL-09', 'Available', '2026-08-23'),
        (133, 'BC000294', N'KNS-25', 'Available', '2026-08-23'),
        (133, 'BC000295', N'KNS-25', 'Available', '2026-08-23'),
        (134, 'BC000296', N'TRH-01', 'Available', '2026-08-23'),
        (134, 'BC000297', N'TRH-01', 'Available', '2026-08-23'),
        (9, 'BC000298', N'HK-09', 'Available', '2026-08-23'),
        (9, 'BC000299', N'HK-09', 'Available', '2026-08-23'),
        (135, 'BC000300', N'TRH-02', 'Available', '2026-08-23'),
        (135, 'BC000301', N'TRH-02', 'Available', '2026-08-23'),
        (136, 'BC000302', N'TRH-03', 'Available', '2026-08-24'),
        (136, 'BC000303', N'TRH-03', 'Available', '2026-08-24'),
        (137, 'BC000304', N'TRH-04', 'Available', '2026-08-24'),
        (137, 'BC000305', N'TRH-04', 'Available', '2026-08-24'),
        (138, 'BC000306', N'TRH-05', 'Available', '2026-08-24'),
        (138, 'BC000307', N'TRH-05', 'Available', '2026-08-24'),
        (139, 'BC000308', N'TRH-06', 'Available', '2026-08-24'),
        (139, 'BC000309', N'TRH-06', 'Available', '2026-08-24'),
        (140, 'BC000310', N'TRH-07', 'Available', '2026-08-24'),
        (140, 'BC000311', N'TRH-07', 'Available', '2026-08-24'),
        (141, 'BC000312', N'VHKD-09', 'Available', '2026-08-24'),
        (141, 'BC000313', N'VHKD-09', 'Available', '2026-08-24'),
        (142, 'BC000314', N'VHKD-10', 'Available', '2026-08-24'),
        (142, 'BC000315', N'VHKD-10', 'Available', '2026-08-24'),
        (143, 'BC000316', N'VHKD-11', 'Available', '2026-08-24'),
        (143, 'BC000317', N'VHKD-11', 'Available', '2026-08-24'),
        (144, 'BC000318', N'VHKD-12', 'Available', '2026-08-25'),
        (144, 'BC000319', N'VHKD-12', 'Available', '2026-08-25'),
        (145, 'BC000320', N'VHKD-13', 'Available', '2026-08-25'),
        (145, 'BC000321', N'VHKD-13', 'Available', '2026-08-25'),
        (146, 'BC000322', N'VHKD-14', 'Available', '2026-08-25'),
        (146, 'BC000323', N'VHKD-14', 'Available', '2026-08-25'),
        (147, 'BC000324', N'VHKD-15', 'Available', '2026-08-25'),
        (147, 'BC000325', N'VHKD-15', 'Available', '2026-08-25'),
        (148, 'BC000326', N'TTKD-01', 'Available', '2026-08-25'),
        (148, 'BC000327', N'TTKD-01', 'Available', '2026-08-25'),
        (149, 'BC000328', N'TTKD-02', 'Available', '2026-08-25'),
        (149, 'BC000329', N'TTKD-02', 'Available', '2026-08-25'),
        (150, 'BC000330', N'TTKD-03', 'Available', '2026-08-25'),
        (150, 'BC000331', N'TTKD-03', 'Available', '2026-08-25'),
        (151, 'BC000332', N'VHKD-16', 'Available', '2026-08-25'),
        (151, 'BC000333', N'VHKD-16', 'Available', '2026-08-25'),
        (152, 'BC000334', N'KHVT-12', 'Available', '2026-08-26'),
        (152, 'BC000335', N'KHVT-12', 'Available', '2026-08-26'),
        (153, 'BC000336', N'KHVT-13', 'Available', '2026-08-26'),
        (153, 'BC000337', N'KHVT-13', 'Available', '2026-08-26'),
        (154, 'BC000338', N'TTKD-04', 'Available', '2026-08-26'),
        (154, 'BC000339', N'TTKD-04', 'Available', '2026-08-26'),
        (155, 'BC000340', N'TTKD-05', 'Available', '2026-08-26'),
        (155, 'BC000341', N'TTKD-05', 'Available', '2026-08-26'),
        (156, 'BC000342', N'TTKD-06', 'Available', '2026-08-26'),
        (156, 'BC000343', N'TTKD-06', 'Available', '2026-08-26'),
        (157, 'BC000344', N'TTKD-07', 'Available', '2026-08-26'),
        (157, 'BC000345', N'TTKD-07', 'Available', '2026-08-26'),
        (158, 'BC000346', N'TTKD-08', 'Available', '2026-08-26'),
        (158, 'BC000347', N'TTKD-08', 'Available', '2026-08-26'),
        (159, 'BC000348', N'TTKD-09', 'Available', '2026-08-26'),
        (159, 'BC000349', N'TTKD-09', 'Available', '2026-08-26'),
        (160, 'BC000350', N'TTKD-10', 'Available', '2026-08-27'),
        (160, 'BC000351', N'TTKD-10', 'Available', '2026-08-27'),
        (161, 'BC000352', N'TTKD-11', 'Available', '2026-08-27'),
        (161, 'BC000353', N'TTKD-11', 'Available', '2026-08-27'),
        (142, 'BC000354', N'TTKD-12', 'Available', '2026-08-27'),
        (142, 'BC000355', N'TTKD-12', 'Available', '2026-08-27'),
        (162, 'BC000356', N'TTKD-13', 'Available', '2026-08-27'),
        (162, 'BC000357', N'TTKD-13', 'Available', '2026-08-27'),
        (163, 'BC000358', N'TTKD-14', 'Available', '2026-08-27'),
        (163, 'BC000359', N'TTKD-14', 'Available', '2026-08-27'),
        (164, 'BC000360', N'TTKD-15', 'Available', '2026-08-27'),
        (164, 'BC000361', N'TTKD-15', 'Available', '2026-08-27'),
        (165, 'BC000362', N'TTKD-16', 'Available', '2026-08-27'),
        (165, 'BC000363', N'TTKD-16', 'Available', '2026-08-27'),
        (166, 'BC000364', N'TTKD-17', 'Available', '2026-08-27'),
        (166, 'BC000365', N'TTKD-17', 'Available', '2026-08-27'),
        (167, 'BC000366', N'TTKD-18', 'Available', '2026-08-28'),
        (167, 'BC000367', N'TTKD-18', 'Available', '2026-08-28'),
        (168, 'BC000368', N'TTKD-19', 'Available', '2026-08-28'),
        (168, 'BC000369', N'TTKD-19', 'Available', '2026-08-28'),
        (169, 'BC000370', N'TTKD-20', 'Available', '2026-08-28'),
        (169, 'BC000371', N'TTKD-20', 'Available', '2026-08-28'),
        (170, 'BC000372', N'TTH-20', 'Available', '2026-08-28'),
        (170, 'BC000373', N'TTH-20', 'Available', '2026-08-28'),
        (171, 'BC000374', N'TTH-21', 'Available', '2026-08-28'),
        (171, 'BC000375', N'TTH-21', 'Available', '2026-08-28'),
        (172, 'BC000376', N'TTH-22', 'Available', '2026-08-28'),
        (172, 'BC000377', N'TTH-22', 'Available', '2026-08-28'),
        (173, 'BC000378', N'VHVN-01', 'Available', '2026-08-28'),
        (173, 'BC000379', N'VHVN-01', 'Available', '2026-08-28'),
        (174, 'BC000380', N'VHVN-02', 'Available', '2026-08-28'),
        (174, 'BC000381', N'VHVN-02', 'Available', '2026-08-28'),
        (175, 'BC000382', N'VHVN-03', 'Available', '2026-08-29'),
        (175, 'BC000383', N'VHVN-03', 'Available', '2026-08-29'),
        (176, 'BC000384', N'VHVN-04', 'Available', '2026-08-29'),
        (176, 'BC000385', N'VHVN-04', 'Available', '2026-08-29'),
        (177, 'BC000386', N'VHVN-05', 'Available', '2026-08-29'),
        (177, 'BC000387', N'VHVN-05', 'Available', '2026-08-29'),
        (178, 'BC000388', N'VHVN-06', 'Available', '2026-08-29'),
        (178, 'BC000389', N'VHVN-06', 'Available', '2026-08-29'),
        (179, 'BC000390', N'VHVN-07', 'Available', '2026-08-29'),
        (179, 'BC000391', N'VHVN-07', 'Available', '2026-08-29'),
        (180, 'BC000392', N'VHKD-17', 'Available', '2026-08-29'),
        (180, 'BC000393', N'VHKD-17', 'Available', '2026-08-29'),
        (181, 'BC000394', N'VHVN-08', 'Available', '2026-08-29'),
        (181, 'BC000395', N'VHVN-08', 'Available', '2026-08-29'),
        (182, 'BC000396', N'VHVN-09', 'Available', '2026-08-29'),
        (182, 'BC000397', N'VHVN-09', 'Available', '2026-08-29'),
        (183, 'BC000398', N'VHVN-10', 'Available', '2026-08-30'),
        (183, 'BC000399', N'VHVN-10', 'Available', '2026-08-30'),
        (184, 'BC000400', N'VHVN-11', 'Available', '2026-08-30'),
        (184, 'BC000401', N'VHVN-11', 'Available', '2026-08-30'),
        (185, 'BC000402', N'VHVN-12', 'Available', '2026-08-30'),
        (185, 'BC000403', N'VHVN-12', 'Available', '2026-08-30'),
        (186, 'BC000404', N'VHVN-13', 'Available', '2026-08-30'),
        (186, 'BC000405', N'VHVN-13', 'Available', '2026-08-30'),
        (187, 'BC000406', N'VHVN-14', 'Available', '2026-08-30'),
        (187, 'BC000407', N'VHVN-14', 'Available', '2026-08-30'),
        (188, 'BC000408', N'VHVN-15', 'Available', '2026-08-30'),
        (188, 'BC000409', N'VHVN-15', 'Available', '2026-08-30'),
        (189, 'BC000410', N'VHVN-16', 'Available', '2026-08-30'),
        (189, 'BC000411', N'VHVN-16', 'Available', '2026-08-30'),
        (190, 'BC000412', N'VHVN-17', 'Available', '2026-08-30'),
        (190, 'BC000413', N'VHVN-17', 'Available', '2026-08-30'),
        (191, 'BC000414', N'VHVN-18', 'Available', '2026-08-31'),
        (191, 'BC000415', N'VHVN-18', 'Available', '2026-08-31'),
        (192, 'BC000416', N'VHVN-19', 'Available', '2026-08-31'),
        (192, 'BC000417', N'VHVN-19', 'Available', '2026-08-31'),
        (193, 'BC000418', N'VHVN-20', 'Available', '2026-08-31'),
        (193, 'BC000419', N'VHVN-20', 'Available', '2026-08-31'),
        (194, 'BC000420', N'VHVN-21', 'Available', '2026-08-31'),
        (194, 'BC000421', N'VHVN-21', 'Available', '2026-08-31'),
        (195, 'BC000422', N'VHVN-22', 'Available', '2026-08-31'),
        (195, 'BC000423', N'VHVN-22', 'Available', '2026-08-31'),
        (196, 'BC000424', N'KH-15', 'Available', '2026-08-31'),
        (196, 'BC000425', N'KH-15', 'Available', '2026-08-31'),
        (197, 'BC000426', N'KNS-26', 'Available', '2026-08-31'),
        (197, 'BC000427', N'KNS-26', 'Available', '2026-08-31'),
        (198, 'BC000428', N'KNS-27', 'Available', '2026-08-31'),
        (198, 'BC000429', N'KNS-27', 'Available', '2026-08-31'),
        (199, 'BC000430', N'KD-16', 'Available', '2026-09-01'),
        (199, 'BC000431', N'KD-16', 'Available', '2026-09-01');
    GO
