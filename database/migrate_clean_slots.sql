-- =====================================================================
-- Migration Script: Dọn dẹp dữ liệu lịch sử cho delivery_slot và note
-- =====================================================================

-- 1. Đảm bảo cột note đã tồn tại trong dbo.sub_orders
IF COL_LENGTH(N'dbo.sub_orders', N'note') IS NULL
BEGIN
    ALTER TABLE [dbo].[sub_orders] ADD [note] NVARCHAR(500) NULL;
    PRINT 'Da them cot note vao dbo.sub_orders';
END
GO

-- 2. Chuyển lời nhắn bị gộp sang cột note nếu cột note đang rỗng hoặc null
UPDATE dbo.sub_orders
SET note = LTRIM(RTRIM(SUBSTRING(delivery_slot, CHARINDEX(N'Lời nhắn:', delivery_slot) + LEN(N'Lời nhắn:'), LEN(delivery_slot)))),
    delivery_slot = LTRIM(RTRIM(REPLACE(SUBSTRING(delivery_slot, 1, CHARINDEX(N'Lời nhắn:', delivery_slot) - 1), N'•', '')))
WHERE delivery_slot LIKE N'%Lời nhắn:%' AND (note IS NULL OR note = '');
GO

-- 3. Xóa bỏ phần '• Lời nhắn: ...' còn sót lại trong delivery_slot (nếu note đã có dữ liệu)
UPDATE dbo.sub_orders
SET delivery_slot = LTRIM(RTRIM(REPLACE(SUBSTRING(delivery_slot, 1, CHARINDEX(N'Lời nhắn:', delivery_slot) - 1), N'•', '')))
WHERE delivery_slot LIKE N'%Lời nhắn:%';
GO

PRINT 'Hoan tat don dep du lieu delivery_slot va note!';
GO
