-- Seed the physical copies declared in SQLlibhub1.sql.
-- ISBN is used instead of a fixed book_id so this migration also works when
-- identity values differ between databases.

DECLARE @Copies TABLE
(
    isbn VARCHAR(50) NOT NULL,
    barcode VARCHAR(100) NOT NULL,
    shelf_location NVARCHAR(255) NULL,
    status VARCHAR(30) NOT NULL,
    acquired_date DATE NULL
);

INSERT INTO @Copies (isbn, barcode, shelf_location, status, acquired_date)
VALUES
    ('9786049221234', 'BC000001', N'A1', 'Available', '2025-01-01'),
    ('9786049221234', 'BC000002', N'A1', 'Borrowed',  '2025-01-01'),
    ('9786041112233', 'BC000003', N'A2', 'Available', '2025-01-05'),
    ('9786041112233', 'BC000004', N'A2', 'Available', '2025-01-05'),
    ('9781524763138', 'BC000005', N'B1', 'Available', '2025-02-01'),
    ('9786043398765', 'BC000006', N'B2', 'Available', '2025-02-05'),
    ('9786041237890', 'BC000007', N'C1', 'Available', '2025-03-01'),
    ('9786045678901', 'BC000008', N'C2', 'Available', '2025-03-01'),
    ('9786044567890', 'BC000009', N'D1', 'Available', '2025-03-10'),
    ('9780261103573', 'BC000010', N'D2', 'Available', '2025-04-01'),
    ('9780132350884', 'BC000011', N'E1', 'Available', '2025-04-05');

INSERT INTO dbo.BookCopies (book_id, barcode, shelf_location, status, acquired_date)
SELECT
    b.book_id,
    c.barcode,
    c.shelf_location,
    c.status,
    c.acquired_date
FROM @Copies c
INNER JOIN dbo.Books b ON b.isbn = c.isbn
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.BookCopies existing
    WHERE existing.barcode = c.barcode
);

-- Normalize copies imported earlier from the original Vietnamese seed script.
UPDATE dbo.BookCopies
SET status = CASE status
    WHEN N'Có sẵn' THEN 'Available'
    WHEN N'Đang mượn' THEN 'Borrowed'
    WHEN N'Hư hỏng' THEN 'Damaged'
    WHEN N'Mất' THEN 'Lost'
    ELSE status
END
WHERE status IN (N'Có sẵn', N'Đang mượn', N'Hư hỏng', N'Mất');
