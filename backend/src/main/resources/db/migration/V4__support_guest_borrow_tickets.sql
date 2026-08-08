SET XACT_ABORT ON;

IF COL_LENGTH(N'dbo.BorrowTickets', N'guest_name') IS NULL
    ALTER TABLE dbo.BorrowTickets ADD guest_name NVARCHAR(150) NULL;

IF COL_LENGTH(N'dbo.BorrowTickets', N'guest_phone') IS NULL
    ALTER TABLE dbo.BorrowTickets ADD guest_phone VARCHAR(30) NULL;

IF EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.BorrowTickets')
      AND name = N'user_id'
      AND is_nullable = 0
)
    ALTER TABLE dbo.BorrowTickets ALTER COLUMN user_id BIGINT NULL;

IF OBJECT_ID(N'dbo.CK_BorrowTickets_Borrower', N'C') IS NULL
    EXEC sys.sp_executesql N'
        ALTER TABLE dbo.BorrowTickets WITH CHECK
        ADD CONSTRAINT CK_BorrowTickets_Borrower CHECK (
            (user_id IS NOT NULL AND guest_name IS NULL)
            OR
            (user_id IS NULL AND guest_name IS NOT NULL AND LEN(LTRIM(RTRIM(guest_name))) > 0)
        );';
