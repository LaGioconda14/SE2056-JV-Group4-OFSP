-- Migration Script: Drop redundant sub_orders.delivery_slot column
-- delivery_date and delivery_slot_id are now the standard source of truth.

IF EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'[dbo].[sub_orders]') AND name = 'delivery_slot'
)
BEGIN
    ALTER TABLE [dbo].[sub_orders] DROP COLUMN [delivery_slot];
    PRINT 'Dropped column delivery_slot from dbo.sub_orders';
END
ELSE
BEGIN
    PRINT 'Column delivery_slot does not exist in dbo.sub_orders';
END
GO
