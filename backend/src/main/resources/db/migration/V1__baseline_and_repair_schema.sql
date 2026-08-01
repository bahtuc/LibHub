SET XACT_ABORT ON;

-- Preserve old snake_case tables. They contain stale/test rows with IDs that
-- conflict with the canonical PascalCase tables, so merging them automatically
-- would be unsafe.
IF OBJECT_ID(N'dbo.book_copies', N'U') IS NOT NULL
   AND OBJECT_ID(N'dbo.Legacy_book_copies_20260731', N'U') IS NULL
    EXEC sys.sp_rename N'dbo.book_copies', N'Legacy_book_copies_20260731';

IF OBJECT_ID(N'dbo.borrow_tickets', N'U') IS NOT NULL
   AND OBJECT_ID(N'dbo.Legacy_borrow_tickets_20260731', N'U') IS NULL
    EXEC sys.sp_rename N'dbo.borrow_tickets', N'Legacy_borrow_tickets_20260731';

IF OBJECT_ID(N'dbo.borrow_details', N'U') IS NOT NULL
   AND OBJECT_ID(N'dbo.Legacy_borrow_details_20260731', N'U') IS NULL
    EXEC sys.sp_rename N'dbo.borrow_details', N'Legacy_borrow_details_20260731';

IF OBJECT_ID(N'dbo.return_details', N'U') IS NOT NULL
   AND OBJECT_ID(N'dbo.Legacy_return_details_20260731', N'U') IS NULL
    EXEC sys.sp_rename N'dbo.return_details', N'Legacy_return_details_20260731';

-- A clean database can be initialized by the same migration. Existing
-- databases keep their tables and data because every CREATE is conditional.
IF OBJECT_ID(N'dbo.Roles', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Roles (
        role_id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Roles PRIMARY KEY,
        role_name VARCHAR(50) NOT NULL,
        description NVARCHAR(255) NULL,
        CONSTRAINT UQ_Roles_RoleName UNIQUE (role_name)
    );
END;

IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Users (
        user_id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Users PRIMARY KEY,
        username VARCHAR(100) NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        full_name NVARCHAR(255) NULL,
        email VARCHAR(255) NULL,
        phone VARCHAR(50) NULL,
        address NVARCHAR(500) NULL,
        avatar NVARCHAR(1000) NULL,
        status VARCHAR(30) NULL CONSTRAINT DF_Users_Status DEFAULT ('ACTIVE'),
        role_id BIGINT NULL,
        created_at DATETIME2 NULL,
        last_login DATETIME2 NULL,
        CONSTRAINT UQ_Users_Username UNIQUE (username),
        CONSTRAINT FK_Users_Roles FOREIGN KEY (role_id) REFERENCES dbo.Roles(role_id)
    );
END;

IF OBJECT_ID(N'dbo.Categories', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Categories (
        category_id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Categories PRIMARY KEY,
        category_name NVARCHAR(255) NULL,
        description NVARCHAR(1000) NULL
    );
END;

IF OBJECT_ID(N'dbo.Authors', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Authors (
        author_id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Authors PRIMARY KEY,
        author_name NVARCHAR(255) NULL,
        biography NVARCHAR(2000) NULL
    );
END;

IF OBJECT_ID(N'dbo.Publishers', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Publishers (
        publisher_id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Publishers PRIMARY KEY,
        publisher_name NVARCHAR(255) NULL,
        address NVARCHAR(500) NULL,
        phone VARCHAR(50) NULL
    );
END;

IF OBJECT_ID(N'dbo.Books', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Books (
        book_id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Books PRIMARY KEY,
        title NVARCHAR(255) NOT NULL,
        isbn VARCHAR(50) NULL,
        publish_year BIGINT NULL,
        description NVARCHAR(1000) NULL,
        cover_image NVARCHAR(1000) NULL,
        language NVARCHAR(100) NULL,
        pages BIGINT NULL,
        category_id BIGINT NULL,
        author_id BIGINT NULL,
        publisher_id BIGINT NULL,
        is_hidden BIT NOT NULL CONSTRAINT DF_Books_IsHidden DEFAULT (0),
        is_featured BIT NOT NULL CONSTRAINT DF_Books_IsFeatured DEFAULT (0),
        created_at DATETIME2 NULL,
        CONSTRAINT UQ_Books_Isbn UNIQUE (isbn),
        CONSTRAINT FK_Books_Categories FOREIGN KEY (category_id) REFERENCES dbo.Categories(category_id),
        CONSTRAINT FK_Books_Authors FOREIGN KEY (author_id) REFERENCES dbo.Authors(author_id),
        CONSTRAINT FK_Books_Publishers FOREIGN KEY (publisher_id) REFERENCES dbo.Publishers(publisher_id)
    );
END;

IF OBJECT_ID(N'dbo.BookCopies', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.BookCopies (
        copy_id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_BookCopies PRIMARY KEY,
        book_id BIGINT NOT NULL,
        barcode VARCHAR(100) NULL,
        shelf_location NVARCHAR(255) NULL,
        status VARCHAR(30) NULL,
        acquired_date DATE NULL,
        CONSTRAINT FK_BookCopies_Books FOREIGN KEY (book_id) REFERENCES dbo.Books(book_id)
    );
END;

IF OBJECT_ID(N'dbo.BorrowTickets', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.BorrowTickets (
        ticket_id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_BorrowTickets PRIMARY KEY,
        user_id BIGINT NOT NULL,
        borrow_date DATE NULL,
        due_date DATE NULL,
        status VARCHAR(30) NULL,
        note NVARCHAR(1000) NULL,
        created_at DATETIME2 NULL,
        CONSTRAINT FK_BorrowTickets_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id)
    );
END;

IF OBJECT_ID(N'dbo.BorrowDetails', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.BorrowDetails (
        detail_id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_BorrowDetails PRIMARY KEY,
        ticket_id BIGINT NOT NULL,
        copy_id BIGINT NOT NULL,
        borrow_status VARCHAR(30) NULL,
        CONSTRAINT FK_BorrowDetails_Tickets FOREIGN KEY (ticket_id) REFERENCES dbo.BorrowTickets(ticket_id),
        CONSTRAINT FK_BorrowDetails_Copies FOREIGN KEY (copy_id) REFERENCES dbo.BookCopies(copy_id)
    );
END;

IF OBJECT_ID(N'dbo.Returns', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Returns (
        return_id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Returns PRIMARY KEY,
        ticket_id BIGINT NOT NULL,
        return_date DATE NULL,
        received_by BIGINT NULL,
        note NVARCHAR(1000) NULL,
        CONSTRAINT FK_Returns_Tickets FOREIGN KEY (ticket_id) REFERENCES dbo.BorrowTickets(ticket_id),
        CONSTRAINT FK_Returns_Users FOREIGN KEY (received_by) REFERENCES dbo.Users(user_id)
    );
END;

IF OBJECT_ID(N'dbo.ReturnDetails', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ReturnDetails (
        return_detail_id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ReturnDetails PRIMARY KEY,
        return_id BIGINT NOT NULL,
        copy_id BIGINT NOT NULL,
        condition_book VARCHAR(30) NULL,
        CONSTRAINT FK_ReturnDetails_Returns FOREIGN KEY (return_id) REFERENCES dbo.Returns(return_id),
        CONSTRAINT FK_ReturnDetails_Copies FOREIGN KEY (copy_id) REFERENCES dbo.BookCopies(copy_id)
    );
END;

IF OBJECT_ID(N'dbo.Fines', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Fines (
        fine_id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Fines PRIMARY KEY,
        return_detail_id BIGINT NULL,
        amount FLOAT NULL,
        reason NVARCHAR(500) NULL,
        paid_status VARCHAR(30) NULL,
        created_at DATETIME2 NULL,
        CONSTRAINT FK_Fines_ReturnDetails
            FOREIGN KEY (return_detail_id) REFERENCES dbo.ReturnDetails(return_detail_id)
    );
END;

IF OBJECT_ID(N'dbo.PaymentTransactions', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PaymentTransactions (
        payment_id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_PaymentTransactions PRIMARY KEY,
        fine_id BIGINT NOT NULL,
        user_id BIGINT NOT NULL,
        txn_ref VARCHAR(100) NOT NULL,
        amount BIGINT NOT NULL,
        status VARCHAR(30) NOT NULL,
        bank_transaction_no VARCHAR(100) NULL,
        created_at DATETIME2 NOT NULL,
        updated_at DATETIME2 NULL,
        CONSTRAINT uk_payment_txn_ref UNIQUE (txn_ref)
    );
END;

IF OBJECT_ID(N'dbo.SchemaRepairAudit', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SchemaRepairAudit (
        audit_id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_SchemaRepairAudit PRIMARY KEY,
        repaired_at DATETIME2 NOT NULL CONSTRAINT DF_SchemaRepairAudit_RepairedAt DEFAULT (SYSUTCDATETIME()),
        entity_name SYSNAME NOT NULL,
        entity_id BIGINT NOT NULL,
        column_name SYSNAME NOT NULL,
        old_value NVARCHAR(MAX) NULL,
        new_value NVARCHAR(MAX) NULL
    );
END;

-- Save damaged values before correcting them.
INSERT INTO dbo.SchemaRepairAudit (entity_name, entity_id, column_name, old_value, new_value)
SELECT N'Authors', author_id, N'author_name', CONVERT(NVARCHAR(MAX), author_name),
       CASE author_id
           WHEN 2 THEN N'Hoàng Nam Tiến'
           WHEN 3 THEN N'Thích Nhất Hạnh'
       END
FROM dbo.Authors
WHERE author_id IN (2, 3) AND author_name LIKE '%?%';

INSERT INTO dbo.SchemaRepairAudit (entity_name, entity_id, column_name, old_value, new_value)
SELECT N'Categories', category_id, N'category_name', CONVERT(NVARCHAR(MAX), category_name),
       CASE category_id
           WHEN 1 THEN N'Kỹ năng sống'
           WHEN 2 THEN N'Tiểu thuyết'
           WHEN 3 THEN N'Hồi ký'
           WHEN 4 THEN N'Phật giáo'
       END
FROM dbo.Categories
WHERE category_id IN (1, 2, 3, 4) AND category_name LIKE '%?%';

INSERT INTO dbo.SchemaRepairAudit (entity_name, entity_id, column_name, old_value, new_value)
SELECT N'Publishers', publisher_id, N'publisher_name', CONVERT(NVARCHAR(MAX), publisher_name),
       CASE publisher_id
           WHEN 2 THEN N'Nhà xuất bản Văn học'
           WHEN 3 THEN N'Nhà xuất bản Hồng Đức'
           WHEN 4 THEN N'Nhà xuất bản Lao Động'
           WHEN 5 THEN N'Nhà xuất bản Quân đội Nhân dân'
           WHEN 6 THEN N'Nhà xuất bản Trẻ'
           WHEN 8 THEN N'Nhà xuất bản Tổng hợp TP.HCM'
       END
FROM dbo.Publishers
WHERE publisher_id IN (2, 3, 4, 5, 6, 8) AND publisher_name LIKE '%?%';

INSERT INTO dbo.SchemaRepairAudit (entity_name, entity_id, column_name, old_value, new_value)
SELECT N'Roles', role_id, N'description', CONVERT(NVARCHAR(MAX), description),
       CASE role_id
           WHEN 1 THEN N'Quản trị hệ thống'
           WHEN 2 THEN N'Nhân viên thư viện'
           WHEN 3 THEN N'Độc giả / người mượn sách'
       END
FROM dbo.Roles
WHERE role_id IN (1, 2, 3) AND description LIKE '%?%';

INSERT INTO dbo.SchemaRepairAudit (entity_name, entity_id, column_name, old_value, new_value)
SELECT N'Users', user_id, N'full_name', CONVERT(NVARCHAR(MAX), full_name), N'Quản trị viên'
FROM dbo.Users
WHERE user_id = 1 AND full_name LIKE '%?%';

INSERT INTO dbo.SchemaRepairAudit (entity_name, entity_id, column_name, old_value, new_value)
SELECT N'Books', book_id, N'description', CONVERT(NVARCHAR(MAX), description),
       CASE book_id
           WHEN 1 THEN N'Sách kinh điển về tư duy làm giàu và thành công.'
           WHEN 2 THEN N'Cuốn sách về câu chuyện tình yêu và ký ức.'
           WHEN 3 THEN N'Tác phẩm về vô thường, sinh tử và sự an nhiên trong cuộc sống.'
           WHEN 4 THEN N'Tiểu thuyết Việt Nam về đề tài chiến tranh.'
           WHEN 5 THEN N'Hồi ký của bác sĩ Paul Kalanithi về sự sống và cái chết.'
           WHEN 6 THEN N'Tác phẩm của Shinkai Makoto.'
           WHEN 7 THEN N'Sách kinh điển về kỹ năng giao tiếp, ứng xử và tạo ảnh hưởng tích cực.'
           WHEN 8 THEN N'Sách về xây dựng thói quen tốt và thay đổi bản thân theo từng bước nhỏ.'
           WHEN 9 THEN N'Tập đầu tiên trong bộ sử thi giả tưởng nổi tiếng của J.R.R. Tolkien.'
       END
FROM dbo.Books
WHERE book_id BETWEEN 1 AND 9 AND description LIKE '%?%';

INSERT INTO dbo.SchemaRepairAudit (entity_name, entity_id, column_name, old_value, new_value)
SELECT N'BorrowTickets', ticket_id, N'note', CONVERT(NVARCHAR(MAX), note),
       N'{"b":7,"c":3,"t":"Đắc nhân tâm"}'
FROM dbo.BorrowTickets
WHERE ticket_id = 6 AND note LIKE '%?%';

INSERT INTO dbo.SchemaRepairAudit (entity_name, entity_id, column_name, old_value, new_value)
SELECT N'Books', book_id, N'is_hidden', NULL, N'0'
FROM dbo.Books
WHERE is_hidden IS NULL;

INSERT INTO dbo.SchemaRepairAudit (entity_name, entity_id, column_name, old_value, new_value)
SELECT N'Books', book_id, N'is_featured', NULL, N'0'
FROM dbo.Books
WHERE is_featured IS NULL;

-- Store all user-facing text as Unicode before writing corrected values.
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.Authors') AND name = N'author_name'
      AND system_type_id = TYPE_ID(N'varchar'))
    ALTER TABLE dbo.Authors ALTER COLUMN author_name NVARCHAR(255) NULL;

IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.Authors') AND name = N'biography'
      AND system_type_id = TYPE_ID(N'varchar'))
    ALTER TABLE dbo.Authors ALTER COLUMN biography NVARCHAR(2000) NULL;

IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.Books') AND name = N'description'
      AND system_type_id = TYPE_ID(N'varchar'))
    ALTER TABLE dbo.Books ALTER COLUMN description NVARCHAR(1000) NULL;

IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.Books') AND name = N'language'
      AND system_type_id = TYPE_ID(N'varchar'))
    ALTER TABLE dbo.Books ALTER COLUMN language NVARCHAR(100) NULL;

IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.Categories') AND name = N'category_name'
      AND system_type_id = TYPE_ID(N'varchar'))
    ALTER TABLE dbo.Categories ALTER COLUMN category_name NVARCHAR(255) NULL;

IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.Publishers') AND name = N'publisher_name'
      AND system_type_id = TYPE_ID(N'varchar'))
    ALTER TABLE dbo.Publishers ALTER COLUMN publisher_name NVARCHAR(255) NULL;

IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.Roles') AND name = N'description'
      AND system_type_id = TYPE_ID(N'varchar'))
    ALTER TABLE dbo.Roles ALTER COLUMN description NVARCHAR(255) NULL;

IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.Users') AND name = N'full_name'
      AND system_type_id = TYPE_ID(N'varchar'))
    ALTER TABLE dbo.Users ALTER COLUMN full_name NVARCHAR(255) NULL;

IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.BookCopies') AND name = N'shelf_location'
      AND system_type_id = TYPE_ID(N'varchar'))
    ALTER TABLE dbo.BookCopies ALTER COLUMN shelf_location NVARCHAR(255) NULL;

IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.BorrowTickets') AND name = N'note'
      AND system_type_id = TYPE_ID(N'varchar'))
    ALTER TABLE dbo.BorrowTickets ALTER COLUMN note NVARCHAR(1000) NULL;

IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.Returns') AND name = N'note'
      AND system_type_id = TYPE_ID(N'varchar'))
    ALTER TABLE dbo.Returns ALTER COLUMN note NVARCHAR(1000) NULL;

UPDATE dbo.Authors
SET author_name = CASE author_id
    WHEN 2 THEN N'Hoàng Nam Tiến'
    WHEN 3 THEN N'Thích Nhất Hạnh'
END
WHERE author_id IN (2, 3) AND author_name LIKE '%?%';

UPDATE dbo.Categories
SET category_name = CASE category_id
    WHEN 1 THEN N'Kỹ năng sống'
    WHEN 2 THEN N'Tiểu thuyết'
    WHEN 3 THEN N'Hồi ký'
    WHEN 4 THEN N'Phật giáo'
END
WHERE category_id IN (1, 2, 3, 4) AND category_name LIKE '%?%';

UPDATE dbo.Publishers
SET publisher_name = CASE publisher_id
    WHEN 2 THEN N'Nhà xuất bản Văn học'
    WHEN 3 THEN N'Nhà xuất bản Hồng Đức'
    WHEN 4 THEN N'Nhà xuất bản Lao Động'
    WHEN 5 THEN N'Nhà xuất bản Quân đội Nhân dân'
    WHEN 6 THEN N'Nhà xuất bản Trẻ'
    WHEN 8 THEN N'Nhà xuất bản Tổng hợp TP.HCM'
END
WHERE publisher_id IN (2, 3, 4, 5, 6, 8) AND publisher_name LIKE '%?%';

UPDATE dbo.Roles
SET description = CASE role_id
    WHEN 1 THEN N'Quản trị hệ thống'
    WHEN 2 THEN N'Nhân viên thư viện'
    WHEN 3 THEN N'Độc giả / người mượn sách'
END
WHERE role_id IN (1, 2, 3) AND description LIKE '%?%';

UPDATE dbo.Users
SET full_name = N'Quản trị viên'
WHERE user_id = 1 AND full_name LIKE '%?%';

UPDATE dbo.Books
SET description = CASE book_id
    WHEN 1 THEN N'Sách kinh điển về tư duy làm giàu và thành công.'
    WHEN 2 THEN N'Cuốn sách về câu chuyện tình yêu và ký ức.'
    WHEN 3 THEN N'Tác phẩm về vô thường, sinh tử và sự an nhiên trong cuộc sống.'
    WHEN 4 THEN N'Tiểu thuyết Việt Nam về đề tài chiến tranh.'
    WHEN 5 THEN N'Hồi ký của bác sĩ Paul Kalanithi về sự sống và cái chết.'
    WHEN 6 THEN N'Tác phẩm của Shinkai Makoto.'
    WHEN 7 THEN N'Sách kinh điển về kỹ năng giao tiếp, ứng xử và tạo ảnh hưởng tích cực.'
    WHEN 8 THEN N'Sách về xây dựng thói quen tốt và thay đổi bản thân theo từng bước nhỏ.'
    WHEN 9 THEN N'Tập đầu tiên trong bộ sử thi giả tưởng nổi tiếng của J.R.R. Tolkien.'
END
WHERE book_id BETWEEN 1 AND 9 AND description LIKE '%?%';

UPDATE dbo.BorrowTickets
SET note = N'{"b":7,"c":3,"t":"Đắc nhân tâm"}'
WHERE ticket_id = 6 AND note LIKE '%?%';

UPDATE dbo.Books SET is_hidden = 0 WHERE is_hidden IS NULL;
UPDATE dbo.Books SET is_featured = 0 WHERE is_featured IS NULL;

IF NOT EXISTS (
    SELECT 1
    FROM sys.default_constraints dc
    JOIN sys.columns c
      ON c.object_id = dc.parent_object_id
     AND c.column_id = dc.parent_column_id
    WHERE dc.parent_object_id = OBJECT_ID(N'dbo.Books')
      AND c.name = N'is_hidden')
    ALTER TABLE dbo.Books ADD CONSTRAINT DF_Books_IsHidden DEFAULT (0) FOR is_hidden;

IF NOT EXISTS (
    SELECT 1
    FROM sys.default_constraints dc
    JOIN sys.columns c
      ON c.object_id = dc.parent_object_id
     AND c.column_id = dc.parent_column_id
    WHERE dc.parent_object_id = OBJECT_ID(N'dbo.Books')
      AND c.name = N'is_featured')
    ALTER TABLE dbo.Books ADD CONSTRAINT DF_Books_IsFeatured DEFAULT (0) FOR is_featured;

IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.Books') AND name = N'is_hidden' AND is_nullable = 1)
    ALTER TABLE dbo.Books ALTER COLUMN is_hidden BIT NOT NULL;

IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.Books') AND name = N'is_featured' AND is_nullable = 1)
    ALTER TABLE dbo.Books ALTER COLUMN is_featured BIT NOT NULL;
