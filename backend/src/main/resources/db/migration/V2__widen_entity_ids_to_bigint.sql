SET XACT_ABORT ON;

/*
 * The original database used INT identifiers while the JPA model uses Long.
 * Widen the complete FK graph together so Hibernate validation and joins agree.
 * Roles.role_id deliberately remains INT because Roles.roleId is Integer.
 */
CREATE TABLE #ColumnsToWiden (
    table_name SYSNAME NOT NULL,
    column_name SYSNAME NOT NULL,
    PRIMARY KEY (table_name, column_name)
);

INSERT INTO #ColumnsToWiden (table_name, column_name)
VALUES
    (N'Authors', N'author_id'),
    (N'Categories', N'category_id'),
    (N'Publishers', N'publisher_id'),
    (N'Books', N'book_id'),
    (N'Books', N'category_id'),
    (N'Books', N'author_id'),
    (N'Books', N'publisher_id'),
    (N'BookCopies', N'copy_id'),
    (N'BookCopies', N'book_id'),
    (N'Users', N'user_id'),
    (N'BorrowTickets', N'ticket_id'),
    (N'BorrowTickets', N'user_id'),
    (N'BorrowDetails', N'detail_id'),
    (N'BorrowDetails', N'ticket_id'),
    (N'BorrowDetails', N'copy_id'),
    (N'Returns', N'return_id'),
    (N'Returns', N'ticket_id'),
    (N'Returns', N'received_by'),
    (N'ReturnDetails', N'return_detail_id'),
    (N'ReturnDetails', N'return_id'),
    (N'ReturnDetails', N'copy_id'),
    (N'Fines', N'fine_id'),
    (N'Fines', N'return_detail_id'),
    (N'Fines', N'user_id'),
    (N'PaymentTransactions', N'fine_id'),
    (N'PaymentTransactions', N'user_id');

-- Remove foreign keys that depend on any column being widened.
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql = STRING_AGG(
    CONVERT(NVARCHAR(MAX),
        N'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(fk.parent_object_id))
        + N'.' + QUOTENAME(OBJECT_NAME(fk.parent_object_id))
        + N' DROP CONSTRAINT ' + QUOTENAME(fk.name) + N';'),
    CHAR(10))
FROM sys.foreign_keys fk
WHERE EXISTS (
    SELECT 1
    FROM sys.foreign_key_columns fkc
    JOIN sys.columns pc
      ON pc.object_id = fkc.parent_object_id
     AND pc.column_id = fkc.parent_column_id
    JOIN sys.columns rc
      ON rc.object_id = fkc.referenced_object_id
     AND rc.column_id = fkc.referenced_column_id
    WHERE fkc.constraint_object_id = fk.object_id
      AND (
          EXISTS (
              SELECT 1 FROM #ColumnsToWiden w
              WHERE w.table_name = OBJECT_NAME(fkc.parent_object_id)
                AND w.column_name = pc.name)
          OR EXISTS (
              SELECT 1 FROM #ColumnsToWiden w
              WHERE w.table_name = OBJECT_NAME(fkc.referenced_object_id)
                AND w.column_name = rc.name)
      )
);

IF COALESCE(@sql, N'') <> N'' EXEC sys.sp_executesql @sql;

-- Remove primary keys backed by identifier columns being widened.
SET @sql = N'';

SELECT @sql = STRING_AGG(
    CONVERT(NVARCHAR(MAX),
        N'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(k.parent_object_id))
        + N'.' + QUOTENAME(OBJECT_NAME(k.parent_object_id))
        + N' DROP CONSTRAINT ' + QUOTENAME(k.name) + N';'),
    CHAR(10))
FROM sys.key_constraints k
WHERE k.type = N'PK'
  AND EXISTS (
      SELECT 1
      FROM sys.index_columns ic
      JOIN sys.columns c
        ON c.object_id = ic.object_id
       AND c.column_id = ic.column_id
      JOIN #ColumnsToWiden w
        ON w.table_name = OBJECT_NAME(ic.object_id)
       AND w.column_name = c.name
      WHERE ic.object_id = k.parent_object_id
        AND ic.index_id = k.unique_index_id
  );

IF COALESCE(@sql, N'') <> N'' EXEC sys.sp_executesql @sql;

-- Preserve each column's current nullability while widening INT to BIGINT.
SET @sql = N'';

SELECT @sql = STRING_AGG(
    CONVERT(NVARCHAR(MAX),
        N'ALTER TABLE ' + QUOTENAME(s.name) + N'.' + QUOTENAME(t.name)
        + N' ALTER COLUMN ' + QUOTENAME(c.name) + N' BIGINT '
        + CASE WHEN c.is_nullable = 1 THEN N'NULL' ELSE N'NOT NULL' END + N';'),
    CHAR(10))
FROM #ColumnsToWiden w
JOIN sys.tables t ON t.name = w.table_name
JOIN sys.schemas s ON s.schema_id = t.schema_id AND s.name = N'dbo'
JOIN sys.columns c ON c.object_id = t.object_id AND c.name = w.column_name
JOIN sys.types ty ON ty.user_type_id = c.user_type_id
WHERE ty.name = N'int';

IF COALESCE(@sql, N'') <> N'' EXEC sys.sp_executesql @sql;

-- Recreate stable primary-key names.
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.Authors') AND type = N'PK')
    ALTER TABLE dbo.Authors ADD CONSTRAINT PK_Authors PRIMARY KEY (author_id);
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.Categories') AND type = N'PK')
    ALTER TABLE dbo.Categories ADD CONSTRAINT PK_Categories PRIMARY KEY (category_id);
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.Publishers') AND type = N'PK')
    ALTER TABLE dbo.Publishers ADD CONSTRAINT PK_Publishers PRIMARY KEY (publisher_id);
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.Books') AND type = N'PK')
    ALTER TABLE dbo.Books ADD CONSTRAINT PK_Books PRIMARY KEY (book_id);
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.BookCopies') AND type = N'PK')
    ALTER TABLE dbo.BookCopies ADD CONSTRAINT PK_BookCopies PRIMARY KEY (copy_id);
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.Users') AND type = N'PK')
    ALTER TABLE dbo.Users ADD CONSTRAINT PK_Users PRIMARY KEY (user_id);
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.BorrowTickets') AND type = N'PK')
    ALTER TABLE dbo.BorrowTickets ADD CONSTRAINT PK_BorrowTickets PRIMARY KEY (ticket_id);
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.BorrowDetails') AND type = N'PK')
    ALTER TABLE dbo.BorrowDetails ADD CONSTRAINT PK_BorrowDetails PRIMARY KEY (detail_id);
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.Returns') AND type = N'PK')
    ALTER TABLE dbo.Returns ADD CONSTRAINT PK_Returns PRIMARY KEY (return_id);
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.ReturnDetails') AND type = N'PK')
    ALTER TABLE dbo.ReturnDetails ADD CONSTRAINT PK_ReturnDetails PRIMARY KEY (return_detail_id);
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.Fines') AND type = N'PK')
    ALTER TABLE dbo.Fines ADD CONSTRAINT PK_Fines PRIMARY KEY (fine_id);

-- Recreate the operational foreign-key graph.
IF OBJECT_ID(N'dbo.FK_Books_Categories', N'F') IS NULL
    ALTER TABLE dbo.Books ADD CONSTRAINT FK_Books_Categories FOREIGN KEY (category_id) REFERENCES dbo.Categories(category_id);
IF OBJECT_ID(N'dbo.FK_Books_Authors', N'F') IS NULL
    ALTER TABLE dbo.Books ADD CONSTRAINT FK_Books_Authors FOREIGN KEY (author_id) REFERENCES dbo.Authors(author_id);
IF OBJECT_ID(N'dbo.FK_Books_Publishers', N'F') IS NULL
    ALTER TABLE dbo.Books ADD CONSTRAINT FK_Books_Publishers FOREIGN KEY (publisher_id) REFERENCES dbo.Publishers(publisher_id);
IF OBJECT_ID(N'dbo.FK_BookCopies_Books', N'F') IS NULL
    ALTER TABLE dbo.BookCopies ADD CONSTRAINT FK_BookCopies_Books FOREIGN KEY (book_id) REFERENCES dbo.Books(book_id);
IF OBJECT_ID(N'dbo.FK_BorrowTickets_Users', N'F') IS NULL
    ALTER TABLE dbo.BorrowTickets ADD CONSTRAINT FK_BorrowTickets_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id);
IF OBJECT_ID(N'dbo.FK_BorrowDetails_Tickets', N'F') IS NULL
    ALTER TABLE dbo.BorrowDetails ADD CONSTRAINT FK_BorrowDetails_Tickets FOREIGN KEY (ticket_id) REFERENCES dbo.BorrowTickets(ticket_id);
IF OBJECT_ID(N'dbo.FK_BorrowDetails_Copies', N'F') IS NULL
    ALTER TABLE dbo.BorrowDetails ADD CONSTRAINT FK_BorrowDetails_Copies FOREIGN KEY (copy_id) REFERENCES dbo.BookCopies(copy_id);
IF OBJECT_ID(N'dbo.FK_Returns_Tickets', N'F') IS NULL
    ALTER TABLE dbo.Returns ADD CONSTRAINT FK_Returns_Tickets FOREIGN KEY (ticket_id) REFERENCES dbo.BorrowTickets(ticket_id);
IF OBJECT_ID(N'dbo.FK_Returns_Users', N'F') IS NULL
    ALTER TABLE dbo.Returns ADD CONSTRAINT FK_Returns_Users FOREIGN KEY (received_by) REFERENCES dbo.Users(user_id);
IF OBJECT_ID(N'dbo.FK_ReturnDetails_Returns', N'F') IS NULL
    ALTER TABLE dbo.ReturnDetails ADD CONSTRAINT FK_ReturnDetails_Returns FOREIGN KEY (return_id) REFERENCES dbo.Returns(return_id);
IF OBJECT_ID(N'dbo.FK_ReturnDetails_Copies', N'F') IS NULL
    ALTER TABLE dbo.ReturnDetails ADD CONSTRAINT FK_ReturnDetails_Copies FOREIGN KEY (copy_id) REFERENCES dbo.BookCopies(copy_id);
IF OBJECT_ID(N'dbo.FK_Fines_ReturnDetails', N'F') IS NULL
    ALTER TABLE dbo.Fines ADD CONSTRAINT FK_Fines_ReturnDetails FOREIGN KEY (return_detail_id) REFERENCES dbo.ReturnDetails(return_detail_id);

IF OBJECT_ID(N'dbo.PaymentTransactions', N'U') IS NOT NULL
   AND COL_LENGTH(N'dbo.PaymentTransactions', N'fine_id') IS NOT NULL
   AND OBJECT_ID(N'dbo.FK_PaymentTransactions_Fines', N'F') IS NULL
    ALTER TABLE dbo.PaymentTransactions ADD CONSTRAINT FK_PaymentTransactions_Fines FOREIGN KEY (fine_id) REFERENCES dbo.Fines(fine_id);

IF OBJECT_ID(N'dbo.PaymentTransactions', N'U') IS NOT NULL
   AND COL_LENGTH(N'dbo.PaymentTransactions', N'user_id') IS NOT NULL
   AND OBJECT_ID(N'dbo.FK_PaymentTransactions_Users', N'F') IS NULL
    ALTER TABLE dbo.PaymentTransactions ADD CONSTRAINT FK_PaymentTransactions_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id);

DROP TABLE #ColumnsToWiden;
