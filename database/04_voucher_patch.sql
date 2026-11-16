-- Migration script for Voucher feature (Seller Voucher & Per-user Limit)
-- Run on Database OnlineFruitShop

IF COL_LENGTH('dbo.coupons', 'per_user_limit') IS NULL
BEGIN
    ALTER TABLE [dbo].[coupons] ADD [per_user_limit] INT NOT NULL CONSTRAINT DF_coupons_per_user_limit DEFAULT 1;
END;

IF COL_LENGTH('dbo.coupons', 'applies_to') IS NULL
BEGIN
    ALTER TABLE [dbo].[coupons] ADD [applies_to] VARCHAR(30) NOT NULL CONSTRAINT DF_coupons_applies_to DEFAULT 'ALL';
END;

IF COL_LENGTH('dbo.coupons', 'description') IS NULL
BEGIN
    ALTER TABLE [dbo].[coupons] ADD [description] NVARCHAR(500) NULL;
END;

IF COL_LENGTH('dbo.coupons', 'terminated_at') IS NULL
BEGIN
    ALTER TABLE [dbo].[coupons] ADD [terminated_at] DATETIME NULL;
END;

IF OBJECT_ID('dbo.coupon_usages', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[coupon_usages] (
        [usage_id]        BIGINT IDENTITY(1,1) PRIMARY KEY,
        [coupon_id]       INT NOT NULL,
        [order_id]        BIGINT NULL,
        [customer_id]     BIGINT NOT NULL,
        [discount_amount] DECIMAL(18, 2) NOT NULL DEFAULT 0,
        [used_at]         DATETIME DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT FK_coupon_usages_coupon FOREIGN KEY ([coupon_id]) REFERENCES [dbo].[coupons]([coupon_id]) ON DELETE CASCADE,
        CONSTRAINT FK_coupon_usages_user FOREIGN KEY ([customer_id]) REFERENCES [dbo].[users]([user_id])
    );
END;

IF OBJECT_ID('dbo.coupon_products', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[coupon_products] (
        [coupon_id]   INT NOT NULL,
        [product_id]  BIGINT NOT NULL,
        PRIMARY KEY ([coupon_id], [product_id]),
        CONSTRAINT FK_coupon_products_coupon FOREIGN KEY ([coupon_id]) REFERENCES [dbo].[coupons]([coupon_id]) ON DELETE CASCADE,
        CONSTRAINT FK_coupon_products_product FOREIGN KEY ([product_id]) REFERENCES [dbo].[products]([product_id]) ON DELETE CASCADE
    );
END;
