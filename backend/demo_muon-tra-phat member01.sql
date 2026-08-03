USE LibHub;
GO

-- ============================================
-- PHIẾU MƯỢN MEMBER01
-- user_id = 4
-- ============================================

INSERT INTO BorrowTickets
(
    user_id,
    borrow_date,
    due_date,
    status,
    note
)
VALUES
(
    4,
    '2026-08-01',
    '2026-08-05',
    N'Đã trả',
    N'Trả trễ hạn'
);

DECLARE @ticket_id BIGINT = SCOPE_IDENTITY();


-- ============================================
-- CHI TIẾT MƯỢN
-- mượn sách Đắc nhân tâm
-- copy_id = 3
-- ============================================

INSERT INTO BorrowDetails
(
    ticket_id,
    copy_id,
    borrow_status
)
VALUES
(
    @ticket_id,
    3,
    N'Đã trả'
);


-- ============================================
-- PHIẾU TRẢ
-- received_by = staff01 (user_id 2)
-- ============================================

INSERT INTO Returns
(
    ticket_id,
    return_date,
    received_by,
    note
)
VALUES
(
    @ticket_id,
    '2026-08-08',
    2,
    N'Trả sách quá hạn 3 ngày'
);

DECLARE @return_id BIGINT = SCOPE_IDENTITY();


-- ============================================
-- CHI TIẾT TRẢ
-- ============================================

INSERT INTO ReturnDetails
(
    return_id,
    copy_id,
    condition_book
)
VALUES
(
    @return_id,
    3,
    N'Tốt'
);

DECLARE @return_detail_id BIGINT = SCOPE_IDENTITY();


-- ============================================
-- PHIẾU PHẠT
-- ============================================

INSERT INTO Fines
(
    return_detail_id,
    amount,
    reason,
    paid_status
)
VALUES
(
    @return_detail_id,
    50000,
    N'Trả sách quá hạn 3 ngày',
    N'Chưa thanh toán'
);

GO