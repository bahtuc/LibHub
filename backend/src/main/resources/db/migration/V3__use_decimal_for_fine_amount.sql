SET XACT_ABORT ON;

/* FLOAT is approximate and does not match the BigDecimal money model. */
IF EXISTS (
    SELECT 1
    FROM sys.columns c
    JOIN sys.types t ON t.user_type_id = c.user_type_id
    WHERE c.object_id = OBJECT_ID(N'dbo.Fines')
      AND c.name = N'amount'
      AND t.name <> N'decimal'
)
    ALTER TABLE dbo.Fines ALTER COLUMN amount DECIMAL(18,2) NULL;
