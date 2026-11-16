-- ============================================================
-- SCRIPT TẠO BẢNG CHAT (HỘI THOẠI & TIN NHẮN GIỮA KHÁCH VÀ SHOP)
-- ============================================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'chat_conversations')
BEGIN
    CREATE TABLE [dbo].[chat_conversations] (
        [conversation_id]       BIGINT IDENTITY(1,1) PRIMARY KEY,
        [customer_id]           BIGINT NOT NULL,
        [shop_id]               BIGINT NOT NULL,
        [last_message]          NVARCHAR(1000) NULL,
        [last_message_at]       DATETIME DEFAULT CURRENT_TIMESTAMP,
        [customer_unread_count] INT NOT NULL DEFAULT 0,
        [shop_unread_count]     INT NOT NULL DEFAULT 0,
        [created_at]            DATETIME DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT FK_chat_conv_customer FOREIGN KEY ([customer_id]) REFERENCES [dbo].[users]([user_id]),
        CONSTRAINT FK_chat_conv_shop FOREIGN KEY ([shop_id]) REFERENCES [dbo].[shops]([shop_id]),
        CONSTRAINT UQ_chat_customer_shop UNIQUE ([customer_id], [shop_id])
    );
    CREATE INDEX IX_chat_conv_customer ON [dbo].[chat_conversations]([customer_id]);
    CREATE INDEX IX_chat_conv_shop ON [dbo].[chat_conversations]([shop_id]);
    PRINT 'Đã tạo bảng chat_conversations thành công.';
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'chat_messages')
BEGIN
    CREATE TABLE [dbo].[chat_messages] (
        [message_id]        BIGINT IDENTITY(1,1) PRIMARY KEY,
        [conversation_id]   BIGINT NOT NULL,
        [sender_type]       VARCHAR(20) NOT NULL, -- 'CUSTOMER' hoặc 'SHOP'
        [sender_id]         BIGINT NOT NULL,
        [message_text]      NVARCHAR(MAX) NOT NULL,
        [product_id]        BIGINT NULL,
        [order_id]          BIGINT NULL,
        [is_read]           BIT NOT NULL DEFAULT 0,
        [created_at]        DATETIME DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT FK_chat_msg_conv FOREIGN KEY ([conversation_id]) REFERENCES [dbo].[chat_conversations]([conversation_id]) ON DELETE CASCADE,
        CONSTRAINT FK_chat_msg_sender FOREIGN KEY ([sender_id]) REFERENCES [dbo].[users]([user_id]),
        CONSTRAINT FK_chat_msg_product FOREIGN KEY ([product_id]) REFERENCES [dbo].[products]([product_id]),
        CONSTRAINT FK_chat_msg_order FOREIGN KEY ([order_id]) REFERENCES [dbo].[orders]([order_id])
    );
    CREATE INDEX IX_chat_msg_conv_created ON [dbo].[chat_messages]([conversation_id], [created_at] ASC);
    PRINT 'Đã tạo bảng chat_messages thành công.';
END;

