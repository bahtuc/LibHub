-- Add testable physical copies for the books already present in the catalog.
-- Resolve books by ISBN so this works even when identity values differ.

DECLARE @Copies TABLE
(
    isbn VARCHAR(50) NOT NULL,
    barcode VARCHAR(100) NOT NULL,
    shelf_location NVARCHAR(50) NULL,
    acquired_date DATE NULL
);

INSERT INTO @Copies (isbn, barcode, shelf_location, acquired_date)
VALUES
    ('9786049221234', 'BC000012', N'A1', '2026-08-01'),
    ('9786049221234', 'BC000013', N'A1', '2026-08-01'),
    ('9786041112233', 'BC000014', N'A2', '2026-08-01'),
    ('9786041112233', 'BC000015', N'A2', '2026-08-01'),
    ('9781524763138', 'BC000016', N'B1', '2026-08-02'),
    ('9781524763138', 'BC000017', N'B1', '2026-08-02'),
    ('9786043398765', 'BC000018', N'B2', '2026-08-02'),
    ('9786043398765', 'BC000019', N'B2', '2026-08-02'),
    ('9786041237890', 'BC000020', N'C1', '2026-08-03'),
    ('9786041237890', 'BC000021', N'C1', '2026-08-03'),
    ('9786045678901', 'BC000022', N'C2', '2026-08-03'),
    ('9786045678901', 'BC000023', N'C2', '2026-08-03'),
    ('9786044567890', 'BC000024', N'D1', '2026-08-04'),
    ('9786044567890', 'BC000025', N'D1', '2026-08-04'),
    ('9780261103573', 'BC000026', N'D2', '2026-08-04'),
    ('9780261103573', 'BC000027', N'D2', '2026-08-04'),
    ('9780132350884', 'BC000028', N'E1', '2026-08-05'),
    ('9780132350884', 'BC000029', N'E1', '2026-08-05');

INSERT INTO dbo.BookCopies (book_id, barcode, shelf_location, status, acquired_date)
SELECT
    b.book_id,
    c.barcode,
    c.shelf_location,
    'Available',
    c.acquired_date
FROM @Copies c
INNER JOIN dbo.Books b ON b.isbn = c.isbn
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.BookCopies existing
    WHERE existing.barcode = c.barcode
);
