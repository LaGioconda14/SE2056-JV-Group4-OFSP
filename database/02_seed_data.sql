-- ============================================================
-- ONLINE FRUIT SHOPPING PLATFORM (OFSP) - DML SEED DATA SCRIPT
-- FILE 2: DỮ LIỆU KHỞI TẠO ĐỒNG BỘ VỚI HỆ THỐNG ĐANG CHẠY
-- Target DBMS: Microsoft SQL Server 2016+
-- Encoding: UTF-8 / Unicode (NVARCHAR)
-- ============================================================

USE [OnlineFruitShop];
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [roles] (5 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[roles] ON;
INSERT INTO [dbo].[roles] ([role_id], [role_name], [description]) VALUES
    (1, N'ADMIN', N'Quản trị viên cấp cao toàn sàn (Platform SuperAdmin)'),
    (2, N'STAFF', N'Nhân viên vận hành, hỗ trợ và kiểm duyệt sàn'),
    (3, N'SHOP_OWNER', N'Đối tác Nhà vườn / Chủ gian hàng bán hoa quả'),
    (4, N'DRIVER', N'Tài xế giao vận chuỗi lạnh (Cold-chain Courier)'),
    (5, N'CUSTOMER', N'Người tiêu dùng / Khách mua hoa quả');
SET IDENTITY_INSERT [dbo].[roles] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [users] (20 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[users] ON;
INSERT INTO [dbo].[users] ([user_id], [email], [phone], [password_hash], [full_name], [avatar_url], [gender], [birth_date], [status], [created_at], [updated_at]) VALUES
    (1, N'admin@freshfruit.com', N'0987654321', N'PBKDF2$65536$d800fb2b162f3b7fca8178c0d47b9ec4$2e690012626f1759050d71b9be6894d4dfaa7ea02d7fe820e4a11cd5f4074f82', N'Nguyễn Quản Trị', N'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop', N'MALE', '1992-05-15', N'ACTIVE', '2026-10-03 04:59:47.14', '2026-10-03 04:59:47.14'),
    (2, N'staff@freshfruit.com', N'0912345678', N'PBKDF2$65536$89a66dce380cdb8a956ccdb18e5cdbd6$1a0f09613910bd96655d74a6016785db4ee07a501b61c272929faadfba7b758b', N'Trần Thu Thảo', N'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop', N'FEMALE', '1998-08-20', N'ACTIVE', '2026-10-03 04:59:47.14', '2026-10-03 04:59:47.14'),
    (3, N'an.nguyen@dalatfarm.vn', N'0922334455', N'PBKDF2$65536$44146568c37aacd153e1f21bea2d05c4$0f2a7912f9a83b852a66f5ffebb028ce730afd6427e96f4ca75ba2ff47b14c6d', N'Nguyễn Văn An', N'assets/images/avatars/avatar_3_1792058738569.jpg', N'MALE', '1988-11-10', N'ACTIVE', '2026-10-03 04:59:47.14', '2026-10-15 17:05:38.6'),
    (4, N'mai.tran@mekongfruit.com', N'0933445566', N'PBKDF2$65536$3e3ec37fb988a4227b2d2974ff9f9616$5e52725be37420c70980b6f426b7725cf0126cb3fbb4c819af4dd78f9eafef12', N'Trần Thị Mai', N'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&h=100&fit=crop', N'FEMALE', '1985-04-12', N'ACTIVE', '2026-10-03 04:59:47.14', '2026-10-03 04:59:47.14'),
    (5, N'minh.le@sapafarm.vn', N'0944556677', N'123456', N'Lê Văn Minh', N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop', N'MALE', '1990-09-25', N'ACTIVE', '2026-10-03 04:59:47.14', '2026-10-03 04:59:47.14'),
    (6, N'hoang.le@longanfruit.vn', N'0955667788', N'123456', N'Lê Hoàng', N'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop', N'MALE', '1986-07-18', N'ACTIVE', '2026-10-03 04:59:47.14', '2026-10-03 04:59:47.14'),
    (7, N'minh.vo@daklakavocado.com', N'0966778899', N'123456', N'Võ Minh', N'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=100&h=100&fit=crop', N'MALE', '1993-02-05', N'ACTIVE', '2026-10-03 04:59:47.14', '2026-10-03 04:59:47.14'),
    (8, N'toan.pham@globallogistics.vn', N'0977889900', N'123456', N'Phạm Quang Toàn', N'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop', N'MALE', '1982-12-30', N'ACTIVE', '2026-10-03 04:59:47.14', '2026-10-03 04:59:47.14'),
    (9, N'shipper@freshfruit.com', N'0901234567', N'PBKDF2$65536$b2948d97eb0645028f84fcb0d05226d5$d418fb9c39692e4a41387a4ce32508fa81dcff2f5446c7eb4ed97575984dcb40', N'Lê Văn Tốc', N'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=100&h=100&fit=crop', N'MALE', '1997-06-14', N'ACTIVE', '2026-10-03 04:59:47.14', '2026-10-03 04:59:47.14'),
    (10, N'elena.rostova@gmail.com', N'0981112233', N'PBKDF2$65536$4dc05f627b1b7776d3f079a6f70f6a23$0d46f66c24532452054af08bf4b91c74192fb89015ad7382c2046e68a83c65c7', N'Elena Rostova', N'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop', N'FEMALE', '1996-01-20', N'ACTIVE', '2026-10-03 04:59:47.14', '2026-10-03 04:59:47.14'),
    (11, N'marcus.vance@gmail.com', N'0982223344', N'PBKDF2$65536$b6a4ed8c74f02b1bd54d7241592f3a53$8a26b58b06e35bbf3951bdb997dae7ac644497000d838c610b139615389dc314', N'Marcus Vance', N'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop', N'MALE', '1994-08-11', N'ACTIVE', '2026-10-03 04:59:47.14', '2026-10-03 04:59:47.14'),
    (12, N'chloe.bennett@gmail.com', N'0983334455', N'123456', N'Chloe Bennett', N'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop', N'FEMALE', '1999-10-15', N'ACTIVE', '2026-10-03 04:59:47.14', '2026-10-03 04:59:47.14'),
    (13, N'julian.thorne@gmail.com', N'0984445566', N'123456', N'Julian Thorne', N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop', N'MALE', '1991-03-09', N'ACTIVE', '2026-10-03 04:59:47.14', '2026-10-03 04:59:47.14'),
    (14, N'clara.sun@gmail.com', N'0985556677', N'123456', N'Clara Sun', N'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop', N'FEMALE', '2000-12-01', N'ACTIVE', '2026-10-03 04:59:47.14', '2026-10-03 04:59:47.14'),
    (15, N'thuha.nguyen@gmail.com', N'0986667788', N'123456', N'Nguyễn Thu Hà', N'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop', N'FEMALE', '1995-07-22', N'ACTIVE', '2026-10-03 04:59:47.14', '2026-10-03 04:59:47.14'),
    (16, N'nam.tran@gmail.com', N'0987778888', N'PBKDF2$65536$bc0f7ca73c8ad495403aea249b8f4fd3$c14eed1e318262a821b3e89f832ff24c2ab5ce89b6560d38b7b68c659b8e617e', N'Trần Hải Nam A', N'assets/images/avatars/avatar_16_1793792251982.jpg', N'MALE', '1993-11-30', N'ACTIVE', '2026-10-03 04:59:47.14', '2026-11-05 10:05:15.477'),
    (17, N'phuong.le@gmail.com', N'0988889900', N'123456', N'Lê Thảo Phương', N'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=100&h=100&fit=crop', N'FEMALE', '1997-04-18', N'ACTIVE', '2026-10-03 04:59:47.14', '2026-10-03 04:59:47.14'),
    (19, N'monalisa15102000@gmail.com', N'0354521655', N'f31f2003e46d3393382b50d1628c264b744be731c7d0db441e73b56579bec5e1', N'MonaLisa', N'https://lh3.googleusercontent.com/a/ACg8ocLuGwcqNd5PujD05S0H5ftzVXf70fz6H7GZQJ11qFBBg-0_Gpk=s96-c', N'MALE', '2026-10-08', N'ACTIVE', '2026-10-04 13:45:52.7', '2026-10-07 16:33:04.283'),
    (32, N'long.nguyen@dalatfarm.vn', N'0912334455', N'PBKDF2$65536$22282e3d7303e0ec34a74e02b2f66e0b$f1a386eabf7cb906b7f0f9b54f857ff9556b752e43de6addea305123184dfc68', N'Nguyễn Hoàng Long', N'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop', N'MALE', '1995-04-12', N'ACTIVE', '2026-10-21 14:12:15.187', '2026-10-21 14:12:15.187'),
    (33, N'hung.tran@dalatfarm.vn', N'0933221100', N'123456', N'Trần Văn Hùng', N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop', N'MALE', '1998-09-08', N'ACTIVE', '2026-10-21 14:12:15.193', '2026-10-21 14:12:15.193');
SET IDENTITY_INSERT [dbo].[users] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [user_roles] (20 dòng)
-- ------------------------------------------------------------
INSERT INTO [dbo].[user_roles] ([user_id], [role_id]) VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 3),
    (5, 3),
    (6, 3),
    (7, 3),
    (8, 3),
    (9, 4),
    (10, 5),
    (11, 5),
    (12, 5),
    (13, 5),
    (14, 5),
    (15, 5),
    (16, 5),
    (17, 5),
    (19, 3),
    (32, 4),
    (33, 4);
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [user_status_logs] (2 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[user_status_logs] ON;
INSERT INTO [dbo].[user_status_logs] ([log_id], [user_id], [old_status], [new_status], [decision_reason], [changed_by], [created_at]) VALUES
    (1, 3, N'PENDING', N'ACTIVE', N'Xác minh đầy đủ giấy chứng nhận VietGAP và hồ sơ nhà vườn Đà Lạt', N'admin@freshfruit.com', '2026-10-03 05:00:00'),
    (2, 4, N'PENDING', N'ACTIVE', N'Phê duyệt đối tác HTX Trái Cây Miền Tây sau khi kiểm tra GlobalGAP', N'admin@freshfruit.com', '2026-10-03 05:05:00');
SET IDENTITY_INSERT [dbo].[user_status_logs] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [customer_addresses] (9 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[customer_addresses] ON;
INSERT INTO [dbo].[customer_addresses] ([address_id], [user_id], [recipient_name], [recipient_phone], [street_address], [ward], [district], [city], [is_default], [created_at], [updated_at]) VALUES
    (1, 10, N'Elena Rostova', N'0981112233', N'Căn hộ 12.04 Tòa Park 7, Times City', N'Vĩnh Tuy', N'Hai Bà Trưng', N'Hà Nội', 1, '2026-10-03 04:59:47.157', '2026-10-03 04:59:47.157'),
    (2, 11, N'Marcus Vance', N'0982223344', N'Biệt thự 45 Thảo Điền', N'Thảo Điền', N'TP. Thủ Đức', N'TP. Hồ Chí Minh', 1, '2026-10-03 04:59:47.157', '2026-10-03 04:59:47.157'),
    (3, 12, N'Chloe Bennett', N'0983334455', N'Số 88 Đường Lê Lợi', N'Bến Nghé', N'Quận 1', N'TP. Hồ Chí Minh', 1, '2026-10-03 04:59:47.157', '2026-10-03 04:59:47.157'),
    (4, 13, N'Julian Thorne', N'0984445566', N'Số 15 Láng Hạ', N'Thành Công', N'Ba Đình', N'Hà Nội', 1, '2026-10-03 04:59:47.157', '2026-10-03 04:59:47.157'),
    (5, 14, N'Clara Sun', N'0985556677', N'Số 22 Bạch Đằng', N'Thạch Thang', N'Hải Châu', N'Đà Nẵng', 1, '2026-10-03 04:59:47.157', '2026-10-03 04:59:47.157'),
    (6, 15, N'Nguyễn Thu Hà', N'0986667788', N'Số 104 Cầu Giấy', N'Quan Hoa', N'Cầu Giấy', N'Hà Nội', 1, '2026-10-03 04:59:47.157', '2026-10-03 04:59:47.157'),
    (9, 16, N'nam', N'09999999999', N'ngo 34', N'Phường Định Trung', N'Thành phố Vĩnh Yên', N'Tỉnh Vĩnh Phúc', 0, '2026-10-11 04:38:19.12', '2026-10-20 11:36:01.26'),
    (10, 16, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang', 1, '2026-10-20 11:36:01.27', '2026-10-20 11:36:01.27'),
    (11, 17, N'Lê Thảo Phương', N'0988889900', N'17', N'Duy Tan', N'Cau Giay', N'Thành phố Hà Nội', 1, '2026-10-29 16:27:40.877', '2026-10-29 16:27:40.877');
SET IDENTITY_INSERT [dbo].[customer_addresses] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [shops] (6 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[shops] ON;
INSERT INTO [dbo].[shops] ([shop_id], [owner_id], [shop_name], [slug], [business_type], [description], [logo_url], [banner_url], [phone], [address], [province], [certification_name], [commission_rate], [rating], [total_sales_amount], [total_orders_count], [status], [created_at], [updated_at]) VALUES
    (1, 3, N'Nông Trại Dâu Đà Lạt', N'nong-trai-dau-da-lat', N'Nhà vườn trực tiếp', N'Chuyên cung cấp dâu tây New Zealand, dâu Bạch Tuyết, hồng giòn sấy gió công nghệ Nhật Bản.', N'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=100&h=100&fit=crop', N'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=800&fit=crop', N'0922334455', N'Thôn Đa Quý, Xuân Thọ, Đà Lạt', N'Lâm Đồng', N'VietGAP Certified', 8.00, 5.00, 348500000.00, 1420, N'ACTIVE', '2024-08-10 14:30:00', '2026-10-03 04:59:47.173'),
    (2, 4, N'HTX Trái Cây Miền Tây', N'htx-trai-cay-mien-tay', N'Hợp tác xã', N'Tổng kho trái cây nhiệt đới Tiền Giang: Sầu riêng Ri6 cơm vàng hạt lép, Xoài Cát Hòa Lộc, Bưởi Da Xanh Bến Tre.', N'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&h=100&fit=crop', N'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=800&fit=crop', N'0933445566', N'Quốc Lộ 1A, Tam Bình, Cai Lậy', N'Tiền Giang', N'GlobalGAP Certified', 7.50, 4.85, 462100000.00, 1850, N'ACTIVE', '2024-08-15 10:15:00', '2026-10-03 04:59:47.173'),
    (3, 5, N'Nông Sản Sapa Xanh', N'nong-san-sapa-xanh', N'Hộ gia đình', N'Đặc sản trái cây vùng núi cao Sapa: Mận tam hoa, Mận hậu, Lê tai nung ngọt mát, Đào mỏ quạ.', N'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop', N'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=800&fit=crop', N'0944556677', N'Tả Phìn, Thị xã Sapa', N'Lào Cai', N'Hữu cơ Organic', 8.00, 4.88, 186400000.00, 890, N'ACTIVE', '2024-09-01 11:00:00', '2026-10-03 04:59:47.173'),
    (4, 6, N'Long An Dragon Fruit Co.', N'long-an-dragon-fruit', N'Doanh nghiệp bao tiêu', N'Chuyên canh Thanh long ruột đỏ Lương Hòa, Dưa lưới Huỳnh Long trồng nhà màng tiêu chuẩn sạch.', N'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop', N'https://images.unsplash.com/photo-1528825871115-3581a5387919?w=800&fit=crop', N'0955667788', N'Châu Thành, Long An', N'Long An', N'VietGAP Certified', 8.00, 4.75, 142800000.00, 620, N'ACTIVE', '2024-09-10 16:45:00', '2026-10-03 04:59:47.173'),
    (5, 7, N'Vườn Bơ Đắk Lắk', N'vuon-bo-dak-lak', N'Nhà vườn trực tiếp', N'Bơ sáp 034, bơ Booth dẻo béo và chanh leo vàng ngọt ngào Tây Nguyên.', N'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=100&h=100&fit=crop', NULL, N'0966778899', N'Cư M''gar, Đắk Lắk', N'Đắk Lắk', N'VietGAP (Đang thẩm định)', 8.00, 5.00, 0.00, 0, N'PENDING_KYC', '2024-10-30 08:20:00', '2026-10-03 04:59:47.173'),
    (6, 8, N'Công Ty Nhập Khẩu Toàn Cầu', N'cong-ty-nhap-khau-toan-cau', N'Doanh nghiệp nhập khẩu', N'Nhập khẩu trái cây bay cao cấp: Táo Envy New Zealand, Cherry đỏ Mỹ size 9.0, Nho xanh Autumn Crisp.', N'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop', NULL, N'0977889900', N'Phường Tân Phong, Quận 7', N'TP. Hồ Chí Minh', N'Kiểm dịch hải quan', 8.50, 5.00, 0.00, 0, N'PENDING_KYC', '2024-10-30 11:45:00', '2026-10-03 04:59:47.173');
SET IDENTITY_INSERT [dbo].[shops] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [shop_requests] (6 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[shop_requests] ON;
INSERT INTO [dbo].[shop_requests] ([request_id], [user_id], [shop_name], [business_type], [province], [district], [ward], [street_address], [farm_address], [pickup_address], [return_address], [id_card_number], [tax_code], [id_card_front_url], [id_card_back_url], [shop_description], [shop_logo_url], [shop_banner_url], [produce_specialty], [certification_name], [bank_name], [bank_account_number], [bank_account_holder], [reason], [status], [reviewed_by], [reviewed_at], [created_at]) VALUES
    (1, 3, N'Nông Trại Dâu Đà Lạt', N'Nhà vườn trực tiếp', N'Lâm Đồng', NULL, NULL, NULL, N'Thôn Đa Quý, Xuân Thọ', NULL, NULL, N'068090001234', NULL, NULL, NULL, NULL, NULL, NULL, N'Dâu tây New Zealand, Hồng giòn, Phúc bồn tử', N'VietGAP Certified', NULL, NULL, NULL, N'Muốn phân phối dâu tươi hái trong ngày tới người tiêu dùng toàn quốc.', N'APPROVED', 1, '2024-08-10 14:30:00', '2024-08-09 09:00:00'),
    (2, 4, N'HTX Trái Cây Miền Tây', N'Hợp tác xã', N'Tiền Giang', NULL, NULL, NULL, N'Xã Tam Bình, Cai Lậy', NULL, NULL, N'082085005678', NULL, NULL, NULL, NULL, NULL, NULL, N'Sầu riêng Ri6, Xoài Cát Hòa Lộc, Bưởi Da Xanh', N'GlobalGAP Certified', NULL, NULL, NULL, N'Đại diện 45 hộ xã viên đưa trái cây miệt vườn lên sàn số.', N'APPROVED', 1, '2024-08-15 10:15:00', '2024-08-14 16:00:00'),
    (3, 5, N'Nông Sản Sapa Xanh', N'Hộ gia đình', N'Lào Cai', NULL, NULL, NULL, N'Tả Phìn, Sapa', NULL, NULL, N'010090007890', NULL, NULL, NULL, NULL, NULL, NULL, N'Mận tam hoa, Lê tai nung, Đào Sapa', N'Hữu cơ Organic', NULL, NULL, NULL, N'Cung cấp trái cây xứ lạnh trồng tự nhiên không hóa chất.', N'APPROVED', 1, '2024-09-01 11:00:00', '2024-08-31 08:30:00'),
    (4, 6, N'Long An Dragon Fruit Co.', N'Doanh nghiệp bao tiêu', N'Long An', NULL, NULL, NULL, N'Huyện Châu Thành', NULL, NULL, N'080086003456', NULL, NULL, NULL, NULL, NULL, NULL, N'Thanh long ruột đỏ, Dưa lưới Taki', N'VietGAP Certified', NULL, NULL, NULL, N'Vùng trồng xuất khẩu muốn mở rộng kênh bán lẻ nội địa.', N'APPROVED', 1, '2024-09-10 16:45:00', '2024-09-09 13:00:00'),
    (5, 7, N'Vườn Bơ Đắk Lắk', N'Nhà vườn trực tiếp', N'Đắk Lắk', NULL, NULL, NULL, N'Cư M''gar', NULL, NULL, N'066093009988', NULL, NULL, NULL, NULL, NULL, NULL, N'Bơ sáp 034, Chanh leo ngọt Columbia, Sầu riêng Dona', N'VietGAP (Đang bổ sung)', NULL, NULL, NULL, N'Nông sản vườn nhà mong muốn tiếp cận khách hàng cao cấp.', N'PENDING', NULL, NULL, '2024-10-30 08:20:00'),
    (6, 8, N'Công Ty Nhập Khẩu Toàn Cầu', N'Doanh nghiệp nhập khẩu', N'TP. Hồ Chí Minh', NULL, NULL, NULL, N'Phường Tân Phong, Quận 7', NULL, NULL, N'079082001122', NULL, NULL, NULL, NULL, NULL, NULL, N'Táo Envy New Zealand, Cherry Mỹ, Nho mẫu đơn Nhật', N'Chứng nhận Kiểm dịch thực vật', NULL, NULL, NULL, N'Nhà nhập khẩu chính ngạch cần chứng nhận phân phối sàn.', N'PENDING', NULL, NULL, '2024-10-30 11:45:00');
SET IDENTITY_INSERT [dbo].[shop_requests] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [categories] (26 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[categories] ON;
INSERT INTO [dbo].[categories] ([category_id], [parent_id], [category_name], [slug], [description], [icon_class], [is_active]) VALUES
    (1, NULL, N'Trái Cây', N'trai-cay', N'Trái cây tươi ngon tuyển chọn chuẩn sạch toàn sàn', N'bi-apple', 1),
    (2, NULL, N'Khuyến Mãi Hot', N'khuyen-mai-hot', N'Ưu đãi giờ vàng và deal sốc hoa quả', N'bi-fire', 1),
    (3, NULL, N'Quà Tặng Trái Cây', N'qua-tang-trai-cay', N'Giỏ trái cây cao cấp biếu tân gia, lễ tết, mừng sinh nhật', N'bi-gift-fill', 1),
    (4, NULL, N'Thực Phẩm Hữu Cơ', N'thuc-pham-huu-co', N'Nông sản hữu cơ Organic đạt chuẩn chất lượng', N'bi-flower2', 1),
    (5, 1, N'Trái Cây Nhập Khẩu', N'trai-cay-nhap-khau', N'Cherry, Nho sữa, Táo Envy, Kiwi nhập khẩu chính ngạch bay trong ngày', N'bi-globe2', 1),
    (6, 1, N'Trái Cây Việt Nam', N'trai-cay-viet-nam', N'Đặc sản miệt vườn Việt Nam: Sầu riêng, Xoài Cát, Bưởi da xanh', N'bi-pin-map-fill', 1),
    (7, 1, N'Trái Cây Cắt Sẵn', N'trai-cay-cat-san', N'Trái cây gọt sẵn đóng hộp ăn liền tươi mát tiện lợi', N'bi-scissors', 1),
    (8, 1, N'Trái Cây Thùng', N'trai-cay-thung', N'Thùng nguyên kiện tiết kiệm và giỏ quà biếu sang trọng', N'bi-box-seam', 1),
    (9, 1, N'Trái Cây Mùa Hè', N'trai-cay-mua-he', N'Các loại quả giải nhiệt mùa hè: Dưa lưới, Dưa hấu, Thanh long', N'bi-sun-fill', 1),
    (10, 5, N'Nho Nhập Khẩu', N'nho-nhap-khau', N'Nho mẫu đơn Nhật, Nho xanh Autumn Crisp không hạt', N'bi-circle-fill', 1),
    (11, 5, N'Dâu Tây & Các Loại Quả Mọng', N'dau-tay-cac-loai-qua-mong', N'Dâu tây New Zealand, Phúc bồn tử, Việt quất', N'bi-heart-fill', 1),
    (12, 5, N'Táo Envy', N'tao-envy', N'Táo Envy New Zealand giòn ngọt đậm đà size VIP', N'bi-apple', 1),
    (13, 5, N'Trái Cây Hữu Cơ', N'trai-cay-huu-co', N'Trái cây Organic canh tác tự nhiên không hóa chất', N'bi-patch-check', 1),
    (14, 5, N'Kiwi Nhập Khẩu', N'kiwi-nhap-khau', N'Kiwi vàng Zespri New Zealand giàu vitamin C', N'bi-circle', 1),
    (15, 5, N'Mận Nhập Khẩu', N'man-nhap-khau', N'Mận đỏ Mỹ, Mận giòn giòn ngọt', N'bi-dot', 1),
    (16, 5, N'Táo Nhập Khẩu', N'tao-nhap-khau', N'Táo Dazzle, Táo Fuji, Táo Gala giòn ngọt', N'bi-apple', 1),
    (17, 6, N'Trái Cây Theo Mùa', N'trai-cay-theo-mua', N'Sầu riêng Ri6, Mận hậu Sapa, Hồng giòn treo gió', N'bi-calendar3', 1),
    (18, 6, N'Xoài & Chuối', N'xoai-chuoi', N'Xoài Cát Hòa Lộc Tiền Giang, Chuối ngự tiến vua', N'bi-brightness-high', 1),
    (19, 6, N'Táo, Lê, Ổi', N'tao-le-oi', N'Lê tai nung Bắc Hà, Ổi nữ hoàng giòn xốp', N'bi-tree', 1),
    (20, 6, N'Bưởi, Cam, Quýt', N'buoi-cam-quyt', N'Bưởi da xanh Bến Tre, Cam sành Hàm Yên', N'bi-sun', 1),
    (21, 7, N'Đĩa Trái Cây Eat-Clean', N'dia-trai-cay-eat-clean', N'Đĩa hoa quả tươi cắt lát ăn liền', N'bi-cup-straw', 1),
    (22, 7, N'Hộp Trái Cây Văn Phòng', N'hop-trai-cay-van-phong', N'Hộp trái cây tiện lợi giao văn phòng', N'bi-bag', 1),
    (23, 8, N'Thùng Trái Cây Nguyên Kiện', N'thung-trai-cay-nguyen-kien', N'Thùng trái cây nguyên đai nguyên kiện giá sỉ', N'bi-box2', 1),
    (24, 8, N'Hộp Quà Biếu Tặng Cao Cấp', N'hop-qua-bieu-tang-cao-cap', N'Hộp quà trái cây ngoại nhập sang trọng', N'bi-gift', 1),
    (25, 9, N'Dưa Hấu & Dưa Lưới Giải Nhiệt', N'dua-hau-dua-luoi-giai-nhiet', N'Dưa lưới Taki Nhật, dưa hấu không hạt', N'bi-water', 1),
    (26, 9, N'Thanh Long & Trái Cây Mọng Nước', N'thanh-long-trai-cay-mong-nuoc', N'Thanh long ruột đỏ Lương Hòa, chanh leo ngọt', N'bi-droplet-half', 1);
SET IDENTITY_INSERT [dbo].[categories] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [products] (11 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[products] ON;
INSERT INTO [dbo].[products] ([product_id], [shop_id], [category_id], [name], [slug], [origin], [storage_temp], [certification], [description], [is_featured], [is_active], [created_at], [updated_at]) VALUES
    (1, 1, 11, N'Dâu Tây Giống New Zealand Đà Lạt', N'dau-tay-giong-new-zealand-da-lat', N'Đà Lạt, Lâm Đồng', N'2 - 4°C', N'VietGAP', N'Dâu tây New Zealand quả đỏ tươi mọng nước, ngọt dịu thơm nồng.', 1, 1, '2026-10-03 04:59:47.223', '2026-10-03 04:59:47.223'),
    (2, 1, 11, N'Dâu Bạch Tuyết Ngọc Trai Trắng', N'dau-bach-tuyet-ngoc-trai-trang', N'Đà Lạt, Lâm Đồng', N'1 - 3°C', N'Organic', N'Giống dâu bạch tuyết quý hiếm mùi vị ngọt thanh phảng phất hương dứa.', 1, 1, '2026-10-03 04:59:47.223', '2026-10-03 04:59:47.223'),
    (3, 1, 17, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'hong-gion-treo-gio-da-lat', N'Đà Lạt, Lâm Đồng', N'Nhiệt độ phòng (khô ráo)', N'VietGAP', N'Hồng treo gió mềm dẻo mật ngọt lịm tan chảy.', 1, 1, '2026-10-03 04:59:47.223', '2026-11-15 23:44:56.21'),
    (4, 2, 17, N'Sầu Riêng Ri6 Chín Cây Tự Nhiên', N'sau-rieng-ri6-chin-cay', N'Cai Lậy, Tiền Giang', N'18 - 22°C', N'GlobalGAP', N'Sầu riêng Ri6 cơm vàng hạt lép, béo ngậy đậm đà, bao ăn 1 đổi 1.', 1, 1, '2026-10-03 04:59:47.223', '2026-10-03 04:59:47.223'),
    (5, 2, 18, N'Xoài Cát Hòa Lộc Hạng Nhất', N'xoai-cat-hoa-loc-hang-nhat', N'Cái Bè, Tiền Giang', N'12 - 15°C', N'VietGAP', N'Xoài Cát Hòa Lộc quả thon dài, thịt mịn chắc không xơ, ngọt thơm ngây ngất.', 1, 1, '2026-10-03 04:59:47.223', '2026-10-03 04:59:47.223'),
    (6, 2, 20, N'Bưởi Da Xanh Bến Tre Ruột Hồng', N'buoi-da-xanh-ben-tre', N'Bến Tre', N'Nhiệt độ phòng', N'VietGAP', N'Tép bưởi mọng nước, vị ngọt thanh không chua chát, róc vỏ dễ bóc.', 0, 1, '2026-10-03 04:59:47.223', '2026-10-03 04:59:47.223'),
    (7, 3, 17, N'Mận Hậu VIP Sapa Căng Mọng', N'man-hau-vip-sapa', N'Sapa, Lào Cai', N'5 - 8°C', N'Hữu cơ Organic', N'Mận hậu hái tại vườn sương mù, vỏ phủ phấn trắng, giòn ngọt tan.', 1, 1, '2026-10-03 04:59:47.227', '2026-10-03 04:59:47.227'),
    (8, 3, 19, N'Lê Tai Nung Mát Lành Núi Cao', N'le-tai-nung-sapa', N'Bắc Hà, Lào Cai', N'4 - 6°C', N'VietGAP', N'Lê quả to mọng nước, vỏ mỏng ruột trắng tinh khiết thanh nhiệt.', 0, 1, '2026-10-03 04:59:47.227', '2026-10-03 04:59:47.227'),
    (9, 4, 26, N'Thanh Long Ruột Đỏ Lương Hòa', N'thanh-long-ruot-do-long-an', N'Châu Thành, Long An', N'8 - 12°C', N'VietGAP', N'Thanh long ruột đỏ thắm ngọt đậm, giàu chất chống oxy hóa anthocyanin.', 1, 1, '2026-10-03 04:59:47.227', '2026-10-03 04:59:47.227'),
    (10, 4, 25, N'Dưa Lưới Taki Trồng Nhà Màng', N'dua-luoi-taki-nha-mang', N'Long An', N'10 - 14°C', N'GlobalGAP', N'Dưa lưới ruột cam giòn ngọt độ brix đạt 14+, vân lưới dày đẹp.', 1, 1, '2026-10-03 04:59:47.227', '2026-10-03 04:59:47.227'),
    (11, 4, 24, N'Giỏ Quà Trái Cây Cao Cấp Phú Quý', N'gio-qua-trai-cay-phu-quy', N'Tổng Hợp', N'Mát', N'Tiêu chuẩn Sàn', N'Bộ giỏ quà phối hợp Nho, Lê, Táo và Dưa lưới thắt nơ lụa sang trọng.', 1, 1, '2026-10-03 04:59:47.227', '2026-10-03 04:59:47.227');
SET IDENTITY_INSERT [dbo].[products] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [product_variants] (13 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[product_variants] ON;
INSERT INTO [dbo].[product_variants] ([variant_id], [product_id], [sku], [variant_name], [unit], [weight_kg], [price], [original_price], [stock_quantity], [low_stock_threshold], [is_active], [created_at], [updated_at]) VALUES
    (1, 1, N'DL-DAU-NZ-500G', N'Hộp 500g (Loại 1)', N'hộp', 0.50, 160000.00, 180000.00, 45, 15, 1, '2026-10-03 04:59:47.237', '2026-11-15 19:48:51.25'),
    (2, 1, N'DL-DAU-NZ-1KG', N'Hộp 1kg (Loại 1)', N'hộp', 1.00, 310000.00, 350000.00, 2, 10, 1, '2026-10-03 04:59:47.237', '2026-11-15 19:17:20.45'),
    (3, 2, N'DL-DAU-BT-300G', N'Hộp Quà 300g VIP', N'hộp', 0.30, 240000.00, 260000.00, 19, 5, 1, '2026-10-03 04:59:47.237', '2026-11-15 20:29:16.093'),
    (4, 3, N'DL-HONG-TG-500G', N'Hộp 500g Hút Chân Không', N'hộp', 0.50, 195000.00, 220000.00, 10, 10, 1, '2026-10-03 04:59:47.237', '2026-11-15 22:11:53.443'),
    (5, 4, N'MT-SAU-RI6-QUA', N'Quả nguyên (2.5 - 3.5kg)', N'kg', 3.00, 125000.00, 140000.00, 100, 20, 1, '2026-10-03 04:59:47.237', '2026-10-03 04:59:47.237'),
    (6, 4, N'MT-SAU-RI6-BOX', N'Hộp tách múi sẵn 500g', N'hộp', 0.50, 210000.00, 230000.00, 75, 15, 1, '2026-10-03 04:59:47.237', '2026-10-03 04:59:47.237'),
    (7, 5, N'MT-XOAI-HL-1KG', N'Túi 1kg (2 quả/kg)', N'kg', 1.00, 85000.00, 95000.00, 138, 20, 1, '2026-10-03 04:59:47.237', '2026-10-03 04:59:47.237'),
    (8, 6, N'MT-BUOI-DX-QUA', N'Quả tuyển loại 1 (1.4 - 1.6kg)', N'quả', 1.50, 75000.00, 85000.00, 180, 25, 1, '2026-10-03 04:59:47.237', '2026-10-03 04:59:47.237'),
    (9, 7, N'SP-MAN-HAU-1KG', N'Hộp 1kg chọn quả to', N'hộp', 1.00, 95000.00, 110000.00, 87, 15, 1, '2026-10-03 04:59:47.237', '2026-10-03 04:59:47.237'),
    (10, 8, N'SP-LE-TN-1KG', N'Hộp 1kg (3 quả)', N'hộp', 1.00, 80000.00, 90000.00, 120, 20, 1, '2026-10-03 04:59:47.237', '2026-10-03 04:59:47.237'),
    (11, 9, N'LA-TL-DO-1KG', N'Túi 1kg (2 quả)', N'kg', 1.00, 45000.00, 50000.00, 198, 30, 1, '2026-10-03 04:59:47.237', '2026-10-20 11:40:21.593'),
    (12, 10, N'LA-DUA-TK-QUA', N'Quả 1.5 - 1.8kg', N'quả', 1.60, 95000.00, 105000.00, 79, 15, 1, '2026-10-03 04:59:47.237', '2026-10-03 04:59:47.237'),
    (13, 11, N'SAN-GIO-PHUQUY', N'Set Giỏ Quà VIP', N'giỏ', 4.50, 750000.00, 850000.00, 35, 5, 1, '2026-10-03 04:59:47.237', '2026-10-21 09:19:27.953');
SET IDENTITY_INSERT [dbo].[product_variants] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [product_batches] (14 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[product_batches] ON;
INSERT INTO [dbo].[product_batches] ([batch_id], [batch_code], [variant_id], [harvest_date], [expiry_date], [initial_quantity], [current_quantity], [status], [created_at], [updated_at]) VALUES
    (1, N'LOT-202611-01', 1, '2026-11-10 06:00:00', '2026-11-18 00:00:00', 60, 45, N'ACTIVE', '2026-11-10 06:30:00', '2026-11-15 19:48:51.247'),
    (2, N'LOT-202611-02', 2, '2026-11-09 06:00:00', '2026-11-14 00:00:00', 20, 2, N'ACTIVE', '2026-11-09 06:30:00', '2026-11-15 19:17:20.447'),
    (3, N'LOT-202611-03', 3, '2026-11-10 06:00:00', '2026-11-19 00:00:00', 30, 19, N'ACTIVE', '2026-11-10 07:00:00', '2026-11-15 20:29:16.087'),
    (4, N'LOT-202611-04', 4, '2026-11-01 08:00:00', '2026-12-20 00:00:00', 25, 11, N'ACTIVE', '2026-11-01 08:30:00', '2026-11-15 22:26:58.937'),
    (5, N'LOT-202611-05', 5, '2026-11-10 05:30:00', '2026-11-22 00:00:00', 120, 100, N'ACTIVE', '2026-11-10 06:00:00', '2026-11-10 06:00:00'),
    (6, N'LOT-202611-06', 6, '2026-11-10 07:00:00', '2026-11-16 00:00:00', 90, 75, N'ACTIVE', '2026-11-10 07:30:00', '2026-11-10 07:30:00'),
    (7, N'LOT-202611-07', 7, '2026-11-09 06:00:00', '2026-11-24 00:00:00', 150, 138, N'ACTIVE', '2026-11-09 06:30:00', '2026-11-09 06:30:00'),
    (8, N'LOT-202611-08', 8, '2026-11-08 06:00:00', '2026-12-05 00:00:00', 200, 180, N'ACTIVE', '2026-11-08 07:00:00', '2026-11-08 07:00:00'),
    (9, N'LOT-202611-09', 9, '2026-11-10 06:00:00', '2026-11-21 00:00:00', 100, 87, N'ACTIVE', '2026-11-10 06:30:00', '2026-11-10 06:30:00'),
    (10, N'LOT-202611-10', 10, '2026-11-09 07:00:00', '2026-11-30 00:00:00', 130, 120, N'ACTIVE', '2026-11-09 07:30:00', '2026-11-09 07:30:00'),
    (11, N'LOT-202611-11', 11, '2026-11-10 06:00:00', '2026-11-26 00:00:00', 220, 198, N'ACTIVE', '2026-11-10 06:30:00', '2026-11-10 06:30:00'),
    (12, N'LOT-202611-12', 12, '2026-11-10 06:00:00', '2026-11-25 00:00:00', 90, 79, N'ACTIVE', '2026-11-10 06:30:00', '2026-11-10 06:30:00'),
    (13, N'LOT-202611-13', 13, '2026-11-10 08:00:00', '2026-11-28 00:00:00', 40, 35, N'ACTIVE', '2026-11-10 08:30:00', '2026-11-10 08:30:00'),
    (14, N'LOT-202610-01', 1, '2026-10-28 06:00:00', '2026-11-05 00:00:00', 30, 0, N'INACTIVE', '2026-10-28 06:30:00', '2026-11-05 18:00:00');
SET IDENTITY_INSERT [dbo].[product_batches] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [inventory_transactions] (23 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[inventory_transactions] ON;
INSERT INTO [dbo].[inventory_transactions] ([transaction_id], [batch_id], [variant_id], [shop_id], [user_id], [transaction_type], [quantity_changed], [previous_stock], [new_stock], [reason], [created_at], [sub_order_id], [waste_stage], [cost_price], [estimated_loss]) VALUES
    (1, 14, 1, 1, 3, N'RESTOCK', 30, 0, 30, N'Nhập kho lô mới LOT-202610-01', '2026-10-28 06:30:00', NULL, NULL, NULL, NULL),
    (2, 14, 1, 1, 3, N'DISPOSAL', -4, 4, 0, N'Hàng hết hạn sử dụng (Hủy toàn bộ lô) - Xử lý cuối ngày', '2026-11-05 18:00:00', NULL, N'WAREHOUSE_EXPIRED', 160000.00, 640000.00),
    (3, 1, 1, 1, 3, N'RESTOCK', 60, 0, 60, N'Nhập kho lô dâu tây hái sáng LOT-202611-01', '2026-11-10 06:30:00', NULL, NULL, NULL, NULL),
    (4, 2, 2, 1, 3, N'RESTOCK', 20, 0, 20, N'Nhập kho lô hộp 1kg LOT-202611-02', '2026-11-09 06:30:00', NULL, NULL, NULL, NULL),
    (5, 2, 2, 1, 3, N'DAMAGED', -2, 20, 18, N'Loại bỏ 2 hộp bị dập cuống khi kiểm tra kho lạnh', '2026-11-09 15:00:00', NULL, N'WAREHOUSE_EXPIRED', 310000.00, 620000.00),
    (6, 4, 4, 1, 3, N'RESTOCK', 25, 0, 25, N'Nhập kho hồng treo gió LOT-202611-04', '2026-11-01 08:30:00', NULL, NULL, NULL, NULL),
    (7, 5, 5, 2, 4, N'RESTOCK', 120, 0, 120, N'Nhập kho sầu riêng Ri6 hái sáng LOT-202611-05', '2026-11-10 06:00:00', NULL, NULL, NULL, NULL),
    (8, 9, 9, 3, 5, N'RESTOCK', 100, 0, 100, N'Nhập kho mận hậu Sapa LOT-202611-09', '2026-11-10 06:30:00', NULL, NULL, NULL, NULL),
    (9, 3, 3, 1, 3, N'DAMAGED', -1, 21, 20, N'Trừ hao kho thủ công', '2026-11-15 18:26:56.847', NULL, N'WAREHOUSE_EXPIRED', 240000.00, 240000.00),
    (11, NULL, 4, 1, 3, N'QC_PACKING', -4, 0, 0, N'Nông sản không đạt chuẩn chất lượng (dập nát, thâm úng) - hong 4 hop', '2026-10-31 18:10:33.863', 23, N'QC_PACKING', 195000.00, 780000.00),
    (12, NULL, 1, 1, 3, N'WAREHOUSE_EXPIRED', -1, 0, 0, N'Nho bị thâm úng do nhiệt độ kho bảo ôn tăng đột ngột', '2026-10-31 18:40:13.033', NULL, N'WAREHOUSE_EXPIRED', 160000.00, 160000.00),
    (13, NULL, 1, 1, 3, N'WAREHOUSE_EXPIRED', -1, 0, 0, N'Nho bị thâm úng do nhiệt độ kho bảo ôn tăng đột ngột', '2026-10-31 18:42:49.553', NULL, N'WAREHOUSE_EXPIRED', 160000.00, 160000.00),
    (14, NULL, 1, 1, 3, N'WAREHOUSE_EXPIRED', -1, 0, 0, N'Nho bị thâm úng do nhiệt độ kho bảo ôn tăng đột ngột', '2026-11-01 06:19:09.207', NULL, N'WAREHOUSE_EXPIRED', 160000.00, 160000.00),
    (15, NULL, 1, 1, 3, N'TRANSIT_DAMAGE', -1, 0, 0, N'Đứt chuỗi lạnh/dập nát khi giao: hong do giao hang
', '2026-11-01 16:13:51.913', 34, N'TRANSIT_DAMAGE', 75000.00, 75000.00),
    (16, NULL, 4, 1, 3, N'TRANSIT_DAMAGE', -1, 0, 0, N'Đứt chuỗi lạnh/dập nát khi giao: hong 1/41 quả', '2026-11-01 16:49:34.703', 36, N'TRANSIT_DAMAGE', 195000.00, 195000.00),
    (17, NULL, 3, 1, 3, N'QC_PACKING', -1, 0, 0, N'Nông sản không đạt chuẩn chất lượng (dập nát, thâm úng) - Hong Gion hong', '2026-11-04 10:07:03.64', 62, N'QC_PACKING', 240000.00, 240000.00),
    (18, NULL, 4, 1, 3, N'QC_PACKING', -1, 0, 0, N'Nông sản không đạt chuẩn chất lượng (dập nát, thâm úng) - hong gion va dau tay hong 1 1', '2026-11-04 10:10:27.583', 64, N'QC_PACKING', 195000.00, 195000.00),
    (19, NULL, 1, 1, 3, N'QC_PACKING', -1, 0, 0, N'Nông sản không đạt chuẩn chất lượng (dập nát, thâm úng) - hong gion va dau tay hong 1 1', '2026-11-04 10:10:27.583', 64, N'QC_PACKING', 160000.00, 160000.00),
    (20, NULL, 3, 1, 3, N'TRANSIT_DAMAGE', -1, 0, 0, N'Đứt chuỗi lạnh/dập nát khi giao: hong Dau', '2026-11-04 10:43:02.73', 60, N'TRANSIT_DAMAGE', 240000.00, 240000.00),
    (21, NULL, 4, 1, 3, N'QC_PACKING', -1, 0, 0, N'Nông sản không đạt chuẩn chất lượng (dập nát, thâm úng) - asd', '2026-11-09 04:27:13.29', 71, N'QC_PACKING', 195000.00, 195000.00),
    (23, 3, 3, 1, 3, N'LOST', -1, 20, 19, N'[Lô LOT-202611-03] Trừ hao kho thủ công', '2026-11-15 20:29:16.103', NULL, N'WAREHOUSE_EXPIRED', 240000.00, 240000.00),
    (24, NULL, 4, 1, 3, N'QC_PACKING', -2, 0, 0, N'Nông sản không đạt chuẩn chất lượng (dập nát, thâm úng) - hong 2 hop', '2026-11-15 22:10:00.12', 78, N'QC_PACKING', 195000.00, 390000.00),
    (25, 4, 4, 1, 3, N'DAMAGED', -1, 14, 13, N'[Lô LOT-202611-04] Trừ hao kho thủ công', '2026-11-15 22:11:53.45', NULL, N'WAREHOUSE_EXPIRED', 195000.00, 195000.00);
SET IDENTITY_INSERT [dbo].[inventory_transactions] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [product_images] (15 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[product_images] ON;
INSERT INTO [dbo].[product_images] ([image_id], [product_id], [image_url], [is_thumbnail], [display_order], [created_at]) VALUES
    (1, 1, N'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=800&fit=crop', 1, 1, '2026-10-03 04:59:47.23'),
    (2, 1, N'https://images.unsplash.com/photo-1518635017498-87f514b751ba?w=800&fit=crop', 0, 2, '2026-10-03 04:59:47.23'),
    (3, 2, N'https://images.unsplash.com/photo-1587393855524-087f83d95bc9?w=800&fit=crop', 1, 1, '2026-10-03 04:59:47.23'),
    (4, 3, N'https://hongdalat.com/wp-content/uploads/2026/09/hong250gr.webp', 1, 1, '2026-10-03 04:59:47.23'),
    (5, 4, N'https://images.unsplash.com/photo-1588391548224-2f00178d431e?w=800&fit=crop', 1, 1, '2026-10-03 04:59:47.23'),
    (6, 4, N'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=800&fit=crop', 0, 2, '2026-10-03 04:59:47.23'),
    (7, 5, N'https://images.unsplash.com/photo-1553279768-865429fa0078?w=800&fit=crop', 1, 1, '2026-10-03 04:59:47.23'),
    (8, 5, N'https://images.unsplash.com/photo-1591073113125-e46713c829ed?w=800&fit=crop', 0, 2, '2026-10-03 04:59:47.23'),
    (9, 6, N'https://images.unsplash.com/photo-1557800636-894a64c1696f?w=800&fit=crop', 1, 1, '2026-10-03 04:59:47.23'),
    (10, 7, N'https://images.unsplash.com/photo-1596363505729-4190a9506133?w=800&fit=crop', 1, 1, '2026-10-03 04:59:47.23'),
    (11, 8, N'https://images.unsplash.com/photo-1514756331096-242fdeb70d4a?w=800&fit=crop', 1, 1, '2026-10-03 04:59:47.23'),
    (12, 9, N'https://images.unsplash.com/photo-1527325678964-54921661f888?w=800&fit=crop', 1, 1, '2026-10-03 04:59:47.23'),
    (13, 10, N'https://images.unsplash.com/photo-1571575173700-afb9492e6a50?w=800&fit=crop', 1, 1, '2026-10-03 04:59:47.23'),
    (14, 11, N'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=800&fit=crop', 1, 1, '2026-10-03 04:59:47.23'),
    (15, 11, N'https://images.unsplash.com/photo-1519996529931-28324d5a630e?w=800&fit=crop', 0, 2, '2026-10-03 04:59:47.23');
SET IDENTITY_INSERT [dbo].[product_images] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [promotions] (4 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[promotions] ON;
INSERT INTO [dbo].[promotions] ([promotion_id], [shop_id], [name], [description], [promotion_type], [discount_value], [max_discount_amount], [min_quantity], [quota], [sold_quantity], [active_days], [daily_start_time], [daily_end_time], [start_date], [end_date], [is_active], [terminated_at], [created_at], [updated_at]) VALUES
    (1, 1, N'Đồng Giá Dâu Tây Hái Sáng Đà Lạt', N'Áp dụng đồng giá ưu đãi cho hộp dâu tây hái trong ngày', N'FIXED_PRICE', 145000.00, NULL, NULL, 100, 18, N'1,2,3,4,5,6,7', NULL, NULL, '2026-10-01 00:00:00', '2027-12-31 23:59:59', 1, NULL, '2026-10-03 05:00:00', '2026-10-03 05:00:00'),
    (2, 2, N'Mua Nhiều Giảm Sâu Trái Cây Miền Tây', N'Giảm 12% khi mua từ 3 đơn vị sầu riêng hoặc xoài trở lên', N'VOLUME', 12.00, 80000.00, 3, 200, 34, NULL, NULL, NULL, '2026-10-01 00:00:00', '2027-12-31 23:59:59', 1, NULL, '2026-10-03 05:00:00', '2026-10-03 05:00:00'),
    (3, 3, N'Giờ Vàng Nông Sản Sapa Buổi Sáng', N'Giảm trực tiếp 10.000đ/kg khung giờ 08:00 - 12:00 mỗi ngày', N'TIME_WINDOW', 10000.00, NULL, NULL, 150, 22, N'1,2,3,4,5,6,7', '08:00:00', '12:00:00', '2026-10-01 00:00:00', '2027-12-31 23:59:59', 1, NULL, '2026-10-03 05:00:00', '2026-10-03 05:00:00'),
    (4, 4, N'Combo Nhà Màng Long An Giảm 10%', N'Mua từ 2 sản phẩm Thanh Long hoặc Dưa Lưới giảm ngay 10%', N'VOLUME', 10.00, 50000.00, 2, NULL, 12, NULL, NULL, NULL, '2026-10-01 00:00:00', '2027-12-31 23:59:59', 1, NULL, '2026-10-03 05:00:00', '2026-10-03 05:00:00');
SET IDENTITY_INSERT [dbo].[promotions] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [promotion_products] (7 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[promotion_products] ON;
INSERT INTO [dbo].[promotion_products] ([promotion_product_id], [promotion_id], [product_id], [variant_id]) VALUES
    (1, 1, 1, NULL),
    (2, 2, 4, NULL),
    (3, 2, 5, NULL),
    (4, 3, 7, NULL),
    (5, 3, 8, NULL),
    (6, 4, 9, NULL),
    (7, 4, 10, NULL);
SET IDENTITY_INSERT [dbo].[promotion_products] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [coupons] (6 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[coupons] ON;
INSERT INTO [dbo].[coupons] ([coupon_id], [shop_id], [code], [title], [discount_type], [discount_value], [min_order_value], [max_discount_amount], [usage_limit], [used_count], [sponsor_type], [start_date], [end_date], [is_active], [created_at], [per_user_limit], [applies_to], [description], [terminated_at], [updated_at]) VALUES
    (1, NULL, N'FREESHIP-HARVEST', N'Miễn Phí Vận Chuyển Mùa Thu Hoạch', N'FREESHIP', 35000.00, 200000.00, 35000.00, 2000, 482, N'PLATFORM', '2024-09-01 00:00:00', '2030-12-31 23:59:59', 1, '2026-10-03 04:59:47.243', 1, N'ALL', NULL, NULL, '2026-11-15 18:20:53.97'),
    (2, NULL, N'AUTUMN-FRUIT-15', N'Giảm 15% Đại Tiệc Trái Cây Mùa Thu', N'PERCENTAGE', 15.00, 300000.00, 60000.00, 1000, 321, N'PLATFORM', '2024-10-01 00:00:00', '2030-12-31 23:59:59', 1, '2026-10-03 04:59:47.243', 1, N'ALL', NULL, NULL, '2026-11-15 18:20:53.97'),
    (3, NULL, N'WELCOME-NEW-BUYER', N'Tặng Khách Hàng Mới Lần Đầu Mua Sắm', N'FIXED_AMOUNT', 20000.00, 100000.00, 20000.00, 5000, 1420, N'PLATFORM', '2024-01-01 00:00:00', '2030-12-31 23:59:59', 1, '2026-10-03 04:59:47.243', 1, N'ALL', NULL, NULL, '2026-11-15 18:20:53.97'),
    (4, 1, N'DALAT-10K', N'Voucher Nhà Vườn Đà Lạt', N'FIXED_AMOUNT', 10000.00, 150000.00, 10000.00, 500, 86, N'VENDOR', '2024-10-01 00:00:00', '2030-12-31 23:59:59', 1, '2026-10-03 04:59:47.243', 1, N'ALL', NULL, NULL, '2026-11-15 18:20:53.97'),
    (5, 2, N'MIENTAY-SAURIENG', N'Giảm 30K Khi Mua Sầu Riêng Ri6', N'FIXED_AMOUNT', 30000.00, 400000.00, 30000.00, 300, 65, N'VENDOR', '2024-10-01 00:00:00', '2030-12-31 23:59:59', 1, '2026-10-03 04:59:47.243', 1, N'ALL', NULL, NULL, '2026-11-15 18:20:53.97'),
    (6, 1, N'DALAT-DAU-20K', N'Giảm 20K Cho Dâu Tây Đà Lạt', N'FIXED_AMOUNT', 20000.00, 200000.00, 20000.00, 200, 12, N'VENDOR', '2026-10-01 00:00:00', '2030-12-31 23:59:59', 1, '2026-10-03 04:59:47.243', 1, N'PRODUCTS', N'Áp dụng riêng cho dòng sản phẩm Dâu Tây Đà Lạt', NULL, '2026-11-15 18:20:53.97');
SET IDENTITY_INSERT [dbo].[coupons] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [coupon_products] (2 dòng)
-- ------------------------------------------------------------
INSERT INTO [dbo].[coupon_products] ([coupon_id], [product_id]) VALUES
    (6, 1),
    (6, 2);
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [carts] (7 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[carts] ON;
INSERT INTO [dbo].[carts] ([cart_id], [customer_id], [created_at], [updated_at]) VALUES
    (2, 19, '2026-10-04 13:45:52.727', '2026-10-04 13:45:52.727'),
    (4, 11, '2026-10-13 07:27:59.563', '2026-10-13 07:27:59.563'),
    (5, 17, '2026-10-15 15:38:24.89', '2026-10-15 15:38:24.89'),
    (6, 3, '2026-10-15 16:27:01.62', '2026-10-15 16:27:01.62'),
    (10, 16, '2026-10-20 01:08:41.503', '2026-10-20 01:08:41.503'),
    (11, 6, '2026-10-20 01:42:57.057', '2026-10-20 01:42:57.057'),
    (12, 15, '2026-11-02 22:43:53.467', '2026-11-02 22:43:53.467');
SET IDENTITY_INSERT [dbo].[carts] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [cart_items] (3 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[cart_items] ON;
INSERT INTO [dbo].[cart_items] ([cart_item_id], [cart_id], [variant_id], [quantity], [note], [created_at], [updated_at]) VALUES
    (2, 2, 11, 1, NULL, '2026-10-20 11:31:10.63', '2026-10-20 11:31:10.63'),
    (3, 2, 9, 1, NULL, '2026-10-20 11:31:28.393', '2026-10-20 11:31:28.393'),
    (25, 12, 1, 1, NULL, '2026-11-02 22:43:53.493', '2026-11-02 22:43:53.493');
SET IDENTITY_INSERT [dbo].[cart_items] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [wishlists] (6 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[wishlists] ON;
INSERT INTO [dbo].[wishlists] ([wishlist_id], [user_id], [product_id], [created_at]) VALUES
    (1, 10, 1, '2026-10-20 09:00:00'),
    (2, 10, 4, '2026-10-20 09:05:00'),
    (3, 11, 2, '2026-10-21 10:00:00'),
    (4, 15, 7, '2026-10-22 14:30:00'),
    (5, 16, 1, '2026-10-25 18:15:00'),
    (6, 16, 5, '2026-10-25 18:20:00');
SET IDENTITY_INSERT [dbo].[wishlists] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [delivery_time_slots] (6 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[delivery_time_slots] ON;
INSERT INTO [dbo].[delivery_time_slots] ([slot_id], [slot_code], [period], [start_time], [end_time], [display_label], [is_active], [display_order]) VALUES
    (1, N'M1', N'MORNING', '08:00:00', '10:00:00', N'08:00 - 10:00', 1, 1),
    (2, N'M2', N'MORNING', '10:00:00', '12:00:00', N'10:00 - 12:00', 1, 2),
    (3, N'A1', N'AFTERNOON', '13:00:00', '15:00:00', N'13:00 - 15:00', 1, 3),
    (4, N'A2', N'AFTERNOON', '15:00:00', '17:00:00', N'15:00 - 17:00', 1, 4),
    (5, N'E1', N'EVENING', '17:00:00', '19:00:00', N'17:00 - 19:00', 1, 5),
    (6, N'E2', N'EVENING', '19:00:00', '21:00:00', N'19:00 - 21:00', 1, 6);
SET IDENTITY_INSERT [dbo].[delivery_time_slots] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [delivery_slot_capacity] (4 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[delivery_slot_capacity] ON;
INSERT INTO [dbo].[delivery_slot_capacity] ([capacity_id], [shop_id], [slot_id], [delivery_date], [max_orders], [booked_orders], [created_at], [updated_at]) VALUES
    (2, 1, 1, '2026-11-08', 10, 1, '2026-11-07 15:28:14.72', '2026-11-08 00:16:08.537'),
    (3, 1, 5, '2026-11-10', 10, 0, '2026-11-07 15:41:59.54', '2026-11-07 15:42:23.6'),
    (4, 1, 6, '2026-11-07', 10, 1, '2026-11-07 15:42:48.323', '2026-11-07 15:42:48.323'),
    (5, 1, 1, '2026-11-11', 10, 1, '2026-11-08 00:01:02.167', '2026-11-08 00:01:02.167');
SET IDENTITY_INSERT [dbo].[delivery_slot_capacity] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [orders] (44 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[orders] ON;
INSERT INTO [dbo].[orders] ([order_id], [order_code], [customer_id], [coupon_id], [total_goods_amount], [total_shipping_fee], [platform_discount], [final_amount], [payment_status], [payment_method], [order_status], [created_at], [updated_at], [delivery_date], [delivery_slot_id]) VALUES
    (1, N'ORD-2024-8821', 10, 1, 470000.00, 35000.00, 35000.00, 470000.00, N'PAID', N'VNPAY', N'SHIPPING', '2024-10-21 09:15:00', '2026-11-02 22:39:16.67', '2024-10-21', 1),
    (2, N'ORD-2024-8820', 11, 2, 630000.00, 40000.00, 60000.00, 610000.00, N'PAID', N'MOMO', N'COMPLETED', '2024-10-21 14:00:00', '2026-10-03 04:59:47.27', '2024-10-21', 4),
    (3, N'ORD-2024-8819', 15, NULL, 420000.00, 30000.00, 0.00, 450000.00, N'PAID', N'VNPAY', N'PROCESSING', '2024-10-28 10:20:00', '2026-10-03 04:59:47.27', '2024-10-28', 1),
    (4, N'ORD-2024-8818', 11, NULL, 310000.00, 30000.00, 0.00, 340000.00, N'PAID', N'COD', N'SHIPPING', '2024-10-29 11:15:00', '2026-10-26 13:40:00.293', '2024-10-29', 1),
    (5, N'ORD-2024-8817', 13, 2, 750000.00, 45000.00, 60000.00, 735000.00, N'PAID', N'VNPAY', N'COMPLETED', '2024-10-29 15:40:00', '2026-10-03 04:59:47.273', '2024-10-29', 1),
    (6, N'ORD-1792433445456-8024', 16, NULL, 90000.00, 0.00, 0.00, 90000.00, N'PENDING', N'COD', N'SHIPPING', '2026-10-20 01:10:45.47', '2026-10-20 03:35:53.843', '2026-10-20', 3),
    (7, N'ORD-1792470969065-5226', 16, NULL, 510000.00, 0.00, 0.00, 510000.00, N'PENDING', N'COD', N'PROCESSING', '2026-10-20 11:36:09.077', '2026-10-20 11:36:09.077', '2026-10-20', 3),
    (8, N'ORD-1792520186372-5579', 16, NULL, 1905000.00, 0.00, 0.00, 1905000.00, N'PENDING', N'COD', N'SHIPPING', '2026-10-21 01:16:26.38', '2026-10-21 15:22:09.41', '2026-10-21', 3),
    (9, N'ORD-1792997306816-2327', 16, NULL, 95000.00, 0.00, 0.00, 95000.00, N'PENDING', N'COD', N'PROCESSING', '2026-10-26 13:48:26.827', '2026-10-26 13:48:26.827', '2026-10-26', 3),
    (10, N'ORD-1792997354698-9099', 16, NULL, 240000.00, 0.00, 0.00, 240000.00, N'PENDING', N'COD', N'CANCELLED', '2026-10-26 13:49:14.7', '2026-10-27 02:58:56.457', '2026-10-26', 3),
    (11, N'ORD-1793044879653-6468', 16, NULL, 975000.00, 0.00, 0.00, 975000.00, N'PENDING', N'COD', N'SHIPPING', '2026-10-27 03:01:19.66', '2026-10-27 03:06:03.127', '2026-10-27', 3),
    (12, N'ORD-1793046055437-2385', 16, NULL, 195000.00, 0.00, 0.00, 195000.00, N'PAID', N'COD', N'COMPLETED', '2026-10-27 03:20:55.44', '2026-10-27 11:37:06.403', '2026-10-27', 3),
    (13, N'ORD-1793076490926-5286', 16, NULL, 320000.00, 0.00, 0.00, 320000.00, N'PAID', N'COD', N'SHIPPING', '2026-10-27 11:48:10.927', '2026-10-27 11:51:34.753', '2026-10-27', 3),
    (14, N'ORD-1793079249677-6833', 16, NULL, 195000.00, 0.00, 0.00, 195000.00, N'PAID', N'COD', N'COMPLETED', '2026-10-27 12:34:09.68', '2026-10-27 15:13:06.03', '2026-10-27', 3),
    (15, N'ORD-1793263522981-6689', 16, NULL, 195000.00, 0.00, 0.00, 195000.00, N'PENDING', N'COD', N'PROCESSING', '2026-10-29 15:45:22.993', '2026-10-29 15:45:22.993', '2026-10-29', 3),
    (16, N'ORD-1793264824276-1638', 16, NULL, 195000.00, 0.00, 0.00, 195000.00, N'PAID', N'COD', N'COMPLETED', '2026-10-29 16:07:04.283', '2026-10-29 16:18:23.707', '2026-10-29', 3),
    (17, N'ORD-1793265586509-6519', 16, NULL, 390000.00, 0.00, 0.00, 390000.00, N'PENDING', N'COD', N'SHIPPING', '2026-10-29 16:19:46.52', '2026-10-29 16:20:38.953', '2026-10-29', 3),
    (18, N'ORD-1793266079349-1767', 17, NULL, 195000.00, 0.00, 0.00, 195000.00, N'PENDING', N'COD', N'PROCESSING', '2026-10-29 16:27:59.35', '2026-10-29 16:27:59.35', '2026-10-29', 3),
    (19, N'ORD-1793442400517-1447', 16, NULL, 780000.00, 0.00, 0.00, 780000.00, N'PENDING', N'COD', N'CANCELLED', '2026-10-31 17:26:40.527', '2026-10-31 18:10:33.86', '2026-10-31', 3),
    (20, N'ORD-E2E-33643', 5, NULL, 225000.00, 25000.00, 0.00, 250000.00, N'PAID', N'COD', N'COMPLETED', '2026-11-01 06:23:53.77', '2026-11-01 06:23:54.14', '2026-11-01', 1),
    (21, N'ORD-W-4273', 5, NULL, 135000.00, 25000.00, 0.00, 160000.00, N'PENDING', N'COD', N'CANCELLED', '2026-11-01 06:23:54.29', '2026-11-01 06:23:54.33', '2026-11-01', 1),
    (22, N'ORD-F-4425', 5, NULL, 155000.00, 25000.00, 0.00, 180000.00, N'PENDING', N'COD', N'SHIPPING', '2026-11-01 06:23:54.443', '2026-11-01 06:23:54.513', '2026-11-01', 1),
    (23, N'ORD-S-4680', 5, NULL, 75000.00, 25000.00, 0.00, 100000.00, N'PENDING', N'COD', N'SHIPPING', '2026-11-01 06:23:54.693', '2026-11-01 16:12:02.163', '2026-11-01', 1),
    (24, N'ORD-1793525665861-5000', 16, NULL, 195000.00, 0.00, 0.00, 195000.00, N'PENDING', N'COD', N'SHIPPING', '2026-11-01 16:34:25.867', '2026-11-01 16:35:30.18', '2026-11-01', 3),
    (25, N'ORD-1793526455431-8463', 16, NULL, 7995000.00, 0.00, 0.00, 7995000.00, N'PENDING', N'COD', N'SHIPPING', '2026-11-01 16:47:35.433', '2026-11-01 16:48:40.987', '2026-11-01', 3),
    (35, N'ORD-1793733351686-3082', 16, NULL, 440000.00, 0.00, 0.00, 440000.00, N'PENDING', N'COD', N'SHIPPING', '2026-11-04 02:15:51.69', '2026-11-04 10:28:05.01', '2026-11-04', 3),
    (36, N'ORD-1793733514141-5105', 16, 2, 935000.00, 0.00, 60000.00, 835000.00, N'PENDING', N'VNPAY', N'SHIPPING', '2026-11-04 02:18:34.14', '2026-11-04 10:28:23.64', '2026-11-04', 3),
    (37, N'ORD-1793761302107-4524', 16, NULL, 935000.00, 0.00, 0.00, 935000.00, N'PENDING', N'COD', N'PROCESSING', '2026-11-04 10:01:42.123', '2026-11-04 10:01:42.123', '2026-11-04', 3),
    (38, N'ORD-1793761748165-2651', 16, NULL, 710000.00, 0.00, 0.00, 710000.00, N'PENDING', N'COD', N'CANCELLED', '2026-11-04 10:09:08.17', '2026-11-04 10:10:27.58', '2026-11-04', 3),
    (39, N'ORD-1793764593346-5975', 16, NULL, 975000.00, 0.00, 0.00, 975000.00, N'PENDING', N'COD', N'SHIPPING', '2026-11-04 10:56:33.35', '2026-11-16 00:25:41.36', '2026-11-04', 3),
    (40, N'ORD-1793799655217-3627', 16, NULL, 195000.00, 0.00, 0.00, 195000.00, N'PENDING', N'VNPAY', N'PROCESSING', '2026-11-04 20:40:55.23', '2026-11-04 20:40:55.23', '2026-11-04', 1),
    (41, N'ORD-1793818723344-6729', 16, NULL, 390000.00, 0.00, 0.00, 390000.00, N'PENDING', N'VNPAY', N'PROCESSING', '2026-11-05 01:58:43.357', '2026-11-05 01:58:43.357', '2026-11-05', 1),
    (42, N'ORD-1793849409725-8775', 16, NULL, 390000.00, 0.00, 0.00, 390000.00, N'PENDING', N'COD', N'SHIPPING', '2026-11-05 10:30:09.73', '2026-11-05 10:41:10.73', '2026-11-05', 1),
    (43, N'ORD-1793867067942-2312', 16, NULL, 390000.00, 0.00, 0.00, 390000.00, N'PENDING', N'VNPAY', N'PROCESSING', '2026-11-05 15:24:27.95', '2026-11-05 15:24:27.95', '2026-11-05', 1),
    (44, N'ORD-1793868729780-8505', 16, NULL, 390000.00, 0.00, 0.00, 390000.00, N'PENDING', N'COD', N'PROCESSING', '2026-11-05 15:52:09.787', '2026-11-05 15:52:09.787', '2026-11-05', 1),
    (45, N'ORD-1794032350606-7776', 16, NULL, 195000.00, 0.00, 0.00, 195000.00, N'PENDING', N'COD', N'CANCELLED', '2026-11-07 13:19:10.62', '2026-11-09 04:27:13.28', '2026-11-07', 1),
    (46, N'ORD-1794032458255-2874', 16, NULL, 195000.00, 0.00, 0.00, 195000.00, N'PENDING', N'COD', N'CANCELLED', '2026-11-07 13:20:58.26', '2026-11-09 04:27:31.36', '2026-11-07', 1),
    (47, N'ORD-1794040919510-6682', 16, NULL, 195000.00, 0.00, 0.00, 195000.00, N'PENDING', N'COD', N'CANCELLED', '2026-11-07 15:41:59.517', '2026-11-07 15:42:23.61', '2026-11-10', 5),
    (48, N'ORD-1794040968304-6352', 16, NULL, 195000.00, 0.00, 0.00, 195000.00, N'PENDING', N'COD', N'SHIPPING', '2026-11-07 15:42:48.307', '2026-11-09 04:23:56.353', '2026-11-07', 6),
    (49, N'ORD-1794070862132-4477', 16, NULL, 390000.00, 0.00, 0.00, 390000.00, N'PENDING', N'COD', N'SHIPPING', '2026-11-08 00:01:02.14', '2026-11-09 04:24:00.3', '2026-11-11', 1),
    (50, N'ORD-1794071768518-8775', 16, NULL, 975000.00, 0.00, 0.00, 975000.00, N'PENDING', N'VNPAY', N'PROCESSING', '2026-11-08 00:16:08.52', '2026-11-08 00:16:08.52', '2026-11-08', 1),
    (51, N'ORD-1794149552746-3390', 16, NULL, 595000.00, 0.00, 0.00, 595000.00, N'PAID', N'COD', N'COMPLETED', '2026-11-08 21:52:32.75', '2026-11-09 04:42:05.833', '2026-11-09', 3),
    (52, N'ORD-1794755352208-5305', 16, NULL, 585000.00, 30000.00, 0.00, 615000.00, N'PENDING', N'COD', N'CANCELLED', '2026-11-15 22:09:12.213', '2026-11-15 22:10:00.113', '2026-11-16', 1),
    (53, N'ORD-1794792448207-7657', 16, NULL, 195000.00, 30000.00, 0.00, 225000.00, N'PAID', N'COD', N'COMPLETED', '2026-11-16 08:27:28.213', '2026-11-16 08:34:15.24', '2026-11-16', 2);
SET IDENTITY_INSERT [dbo].[orders] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [coupon_usages] (3 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[coupon_usages] ON;
INSERT INTO [dbo].[coupon_usages] ([usage_id], [coupon_id], [order_id], [customer_id], [discount_amount], [used_at]) VALUES
    (1, 2, 36, 16, 60000.00, '2026-11-04 02:18:34.17'),
    (2, 4, 36, 16, 10000.00, '2026-11-04 02:18:34.17'),
    (3, 5, 36, 16, 30000.00, '2026-11-04 02:18:34.173');
SET IDENTITY_INSERT [dbo].[coupon_usages] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [order_shipping_addresses] (44 dòng)
-- ------------------------------------------------------------
INSERT INTO [dbo].[order_shipping_addresses] ([order_id], [recipient_name], [recipient_phone], [street_address], [ward], [district], [city]) VALUES
    (1, N'Elena Rostova', N'0981112233', N'Căn hộ 12.04 Tòa Park 7, Times City', N'Vĩnh Tuy', N'Hai Bà Trưng', N'Hà Nội'),
    (2, N'Marcus Vance', N'0982223344', N'Biệt thự 45 Thảo Điền', N'Thảo Điền', N'TP. Thủ Đức', N'TP. Hồ Chí Minh'),
    (3, N'Nguyễn Thu Hà', N'0986667788', N'Số 104 Cầu Giấy', N'Quan Hoa', N'Cầu Giấy', N'Hà Nội'),
    (4, N'Marcus Vance', N'0982223344', N'Biệt thự 45 Thảo Điền', N'Thảo Điền', N'TP. Thủ Đức', N'TP. Hồ Chí Minh'),
    (5, N'Julian Thorne', N'0984445566', N'Số 15 Láng Hạ', N'Thành Công', N'Ba Đình', N'Hà Nội'),
    (6, N'nam', N'09999999999', N'ngo 34', N'Phường Định Trung', N'Thành phố Vĩnh Yên', N'Tỉnh Vĩnh Phúc'),
    (7, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (8, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (9, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (10, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (11, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (12, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (13, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (14, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (15, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (16, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (17, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (18, N'Lê Thảo Phương', N'0988889900', N'17', N'Duy Tan', N'Cau Giay', N'Thành phố Hà Nội'),
    (19, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (20, N'Nguyễn Văn A', N'0912345678', N'123 Đường Cầu Giấy', N'Dịch Vọng', N'Cầu Giấy', N'Hà Nội'),
    (21, N'Nguyễn Văn A', N'0912345678', N'123 Đường Cầu Giấy', N'Dịch Vọng', N'Cầu Giấy', N'Hà Nội'),
    (22, N'Nguyễn Văn A', N'0912345678', N'123 Đường Cầu Giấy', N'Dịch Vọng', N'Cầu Giấy', N'Hà Nội'),
    (23, N'Nguyễn Văn A', N'0912345678', N'123 Đường Cầu Giấy', N'Dịch Vọng', N'Cầu Giấy', N'Hà Nội'),
    (24, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (25, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (35, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (36, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (37, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (38, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (39, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (40, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (41, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (42, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (43, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (44, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (45, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (46, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (47, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (48, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (49, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (50, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (51, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (52, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang'),
    (53, N'nam', N'09999999999', N'36', N'Xã Phương Độ', N'Thành phố Hà Giang', N'Tỉnh Hà Giang');
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [sub_orders] (59 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[sub_orders] ON;
INSERT INTO [dbo].[sub_orders] ([sub_order_id], [sub_order_code], [order_id], [shop_id], [note], [shop_subtotal], [shop_shipping_fee], [shop_discount], [shop_total], [commission_rate], [commission_amount], [status], [cancel_reason], [cancelled_by], [cancelled_at], [created_at], [updated_at], [delivery_date], [delivery_slot_id]) VALUES
    (1, N'SUB-8821-1', 1, 1, NULL, 470000.00, 35000.00, 0.00, 470000.00, 8.00, 37600.00, N'DELIVERED', NULL, NULL, NULL, '2024-10-21 09:15:00', '2026-11-01 06:20:51.733', '2024-10-21', 1),
    (2, N'SUB-8820-1', 2, 2, NULL, 630000.00, 40000.00, 0.00, 630000.00, 7.50, 47250.00, N'DELIVERED', NULL, NULL, NULL, '2024-10-21 14:00:00', '2026-10-03 04:59:47.27', '2024-10-21', 4),
    (3, N'SUB-8819-1', 3, 2, NULL, 420000.00, 30000.00, 0.00, 420000.00, 7.50, 31500.00, N'DELIVERED', NULL, NULL, NULL, '2024-10-28 10:20:00', '2026-10-03 04:59:47.273', '2024-10-28', 1),
    (4, N'SUB-8818-1', 4, 1, NULL, 310000.00, 30000.00, 0.00, 310000.00, 8.00, 24800.00, N'SHIPPING', NULL, NULL, NULL, '2024-10-29 11:15:00', '2026-10-26 13:40:00.287', '2024-10-29', 1),
    (5, N'SUB-8817-1', 5, 4, NULL, 750000.00, 45000.00, 0.00, 750000.00, 8.00, 60000.00, N'DELIVERED', NULL, NULL, NULL, '2024-10-29 15:40:00', '2026-10-03 04:59:47.273', '2024-10-29', 1),
    (6, N'SUB-1792433445481-4-608', 6, 4, NULL, 90000.00, 0.00, 0.00, 90000.00, 8.00, 7200.00, N'RETURNED', N'Khách hàng bận, không nghe máy 3 lần', NULL, NULL, '2026-10-20 01:10:45.49', '2026-11-01 06:20:17.657', '2026-10-20', 3),
    (7, N'SUB-1792470969086-3-415', 7, 3, NULL, 285000.00, 0.00, 0.00, 285000.00, 8.00, 22800.00, N'NEW', NULL, NULL, NULL, '2026-10-20 11:36:09.097', '2026-10-20 11:36:09.097', '2026-10-20', 3),
    (8, N'SUB-1792470969114-4-485', 7, 4, NULL, 225000.00, 0.00, 0.00, 225000.00, 8.00, 18000.00, N'CANCELLED', N'Muốn thay đổi địa chỉ hoặc số điện thoại nhận hàng', 16, '2026-10-20 11:40:21.6', '2026-10-20 11:36:09.113', '2026-10-20 11:40:21.6', '2026-10-20', 3),
    (9, N'SUB-1792520186381-1-246', 8, 1, NULL, 195000.00, 0.00, 0.00, 195000.00, 8.00, 15600.00, N'SHIPPING', NULL, NULL, NULL, '2026-10-21 01:16:26.39', '2026-10-21 15:22:09.41', '2026-10-21', 3),
    (10, N'SUB-1792520186398-2-837', 8, 2, NULL, 210000.00, 0.00, 0.00, 210000.00, 8.00, 16800.00, N'NEW', NULL, NULL, NULL, '2026-10-21 01:16:26.407', '2026-10-21 01:16:26.407', '2026-10-21', 3),
    (11, N'SUB-1792520186406-4-444', 8, 4, NULL, 1500000.00, 0.00, 0.00, 1500000.00, 8.00, 120000.00, N'CANCELLED', N'Tìm thấy giá rẻ hơn ở nơi khác', 16, '2026-10-21 09:19:27.957', '2026-10-21 01:16:26.41', '2026-10-21 09:19:27.957', '2026-10-21', 3),
    (12, N'SUB-1792997306833-4-840', 9, 4, NULL, 95000.00, 0.00, 0.00, 95000.00, 8.00, 7600.00, N'NEW', NULL, NULL, NULL, '2026-10-26 13:48:26.84', '2026-10-26 13:48:26.84', '2026-10-26', 3),
    (13, N'SUB-1792997354705-1-566', 10, 1, NULL, 240000.00, 0.00, 0.00, 240000.00, 8.00, 19200.00, N'CANCELLED', N'Lý do khác - kkk', NULL, '2026-10-27 02:58:56.44', '2026-10-26 13:49:14.707', '2026-10-27 02:58:56.44', '2026-10-26', 3),
    (14, N'SUB-1793044879667-1-823', 11, 1, NULL, 975000.00, 0.00, 0.00, 975000.00, 8.00, 78000.00, N'SHIPPING', NULL, NULL, NULL, '2026-10-27 03:01:19.673', '2026-10-27 03:06:03.12', '2026-10-27', 3),
    (15, N'SUB-1793046055445-1-113', 12, 1, NULL, 195000.00, 0.00, 0.00, 195000.00, 8.00, 15600.00, N'DELIVERED', NULL, NULL, NULL, '2026-10-27 03:20:55.447', '2026-10-27 11:37:06.387', '2026-10-27', 3),
    (16, N'SUB-1793076490933-1-989', 13, 1, NULL, 195000.00, 0.00, 0.00, 195000.00, 8.00, 15600.00, N'DELIVERED', NULL, NULL, NULL, '2026-10-27 11:48:10.933', '2026-10-27 11:53:11.85', '2026-10-27', 3),
    (17, N'SUB-1793076490942-2-530', 13, 2, NULL, 125000.00, 0.00, 0.00, 125000.00, 8.00, 10000.00, N'NEW', NULL, NULL, NULL, '2026-10-27 11:48:10.94', '2026-10-27 11:48:10.94', '2026-10-27', 3),
    (18, N'SUB-1793079249682-1-545', 14, 1, NULL, 195000.00, 0.00, 0.00, 195000.00, 8.00, 15600.00, N'DELIVERED', NULL, NULL, NULL, '2026-10-27 12:34:09.683', '2026-10-27 15:13:05.993', '2026-10-27', 3),
    (19, N'SUB-1793263523002-1-888', 15, 1, NULL, 195000.00, 0.00, 0.00, 195000.00, 8.00, 15600.00, N'PACKING', NULL, NULL, NULL, '2026-10-29 15:45:23.02', '2026-10-29 15:50:20.473', '2026-10-29', 3),
    (20, N'SUB-1793264824300-1-656', 16, 1, NULL, 195000.00, 0.00, 0.00, 195000.00, 8.00, 15600.00, N'DELIVERED', NULL, NULL, NULL, '2026-10-29 16:07:04.313', '2026-10-29 16:18:23.68', '2026-10-29', 3),
    (21, N'SUB-1793265586526-1-474', 17, 1, NULL, 390000.00, 0.00, 0.00, 390000.00, 8.00, 31200.00, N'RETURNED', N'Quả dập nát / úng hỏng khi đồng kiểm', NULL, NULL, '2026-10-29 16:19:46.537', '2026-11-01 16:12:31.963', '2026-10-29', 3),
    (22, N'SUB-1793266079365-1-734', 18, 1, NULL, 195000.00, 0.00, 0.00, 195000.00, 8.00, 15600.00, N'NEW', NULL, NULL, NULL, '2026-10-29 16:27:59.373', '2026-10-29 16:27:59.373', '2026-10-29', 3),
    (23, N'SUB-1793442400534-1-972', 19, 1, NULL, 780000.00, 0.00, 0.00, 780000.00, 8.00, 62400.00, N'CANCELLED', N'Nông sản không đạt chuẩn chất lượng (dập nát, thâm úng) - hong 4 hop', 3, '2026-10-31 18:10:33.857', '2026-10-31 17:26:40.543', '2026-10-31 18:10:33.857', '2026-10-31', 3),
    (24, N'SUB-IT-17700', 1, 1, NULL, 200000.00, 25000.00, 0.00, 225000.00, 8.00, 0.00, N'CANCELLED', N'Khách đổi địa chỉ giao hàng', 1, '2026-11-01 06:20:17.763', '2026-11-01 06:20:17.72', '2026-11-01 06:20:17.763', '2026-11-01', 1),
    (25, N'SUB-IT-17838', 1, 1, NULL, 200000.00, 25000.00, 0.00, 225000.00, 8.00, 0.00, N'CANCELLED', N'Dâu tây dập nát khi đóng gói tại shop', 1, '2026-11-01 06:20:17.903', '2026-11-01 06:20:17.853', '2026-11-01 06:20:17.903', '2026-11-01', 1),
    (26, N'SUB-IT-17928', 1, 1, NULL, 200000.00, 25000.00, 0.00, 225000.00, 8.00, 0.00, N'FAILED', N' [ĐÃ XỬ LÝ NHẬP KHO: Hoa quả còn tươi nguyên, đã kiểm định và nhập lại kho - Hàng hoàn trả còn tươi, nhập kho]', NULL, NULL, '2026-11-01 06:20:17.94', '2026-11-01 06:20:17.993', '2026-11-01', 1),
    (27, N'SUB-IT-51854', 1, 1, NULL, 200000.00, 25000.00, 0.00, 225000.00, 8.00, 0.00, N'RETURNED', N'Khách hàng bận, không nghe máy 3 lần', NULL, NULL, '2026-11-01 06:20:51.873', '2026-11-01 06:20:51.923', '2026-11-01', 1),
    (28, N'SUB-IT-51963', 1, 1, NULL, 200000.00, 25000.00, 0.00, 225000.00, 8.00, 0.00, N'CANCELLED', N'Khách đổi địa chỉ giao hàng', 1, '2026-11-01 06:20:52.02', '2026-11-01 06:20:51.98', '2026-11-01 06:20:52.02', '2026-11-01', 1),
    (29, N'SUB-IT-52084', 1, 1, NULL, 200000.00, 25000.00, 0.00, 225000.00, 8.00, 0.00, N'CANCELLED', N'Dâu tây dập nát khi đóng gói tại shop', 1, '2026-11-01 06:20:52.117', '2026-11-01 06:20:52.1', '2026-11-01 06:20:52.117', '2026-11-01', 1),
    (30, N'SUB-IT-52174', 1, 1, NULL, 200000.00, 25000.00, 0.00, 225000.00, 8.00, 0.00, N'FAILED', N' [ĐÃ XỬ LÝ NHẬP KHO: Hoa quả còn tươi nguyên, đã kiểm định và nhập lại kho - Hàng hoàn trả còn tươi, nhập kho]', NULL, NULL, '2026-11-01 06:20:52.187', '2026-11-01 06:20:52.24', '2026-11-01', 1),
    (31, N'SUB-E2E-33645', 20, 1, NULL, 225000.00, 25000.00, 0.00, 250000.00, 0.05, 0.00, N'DELIVERED', NULL, NULL, NULL, '2026-11-01 06:23:53.78', '2026-11-01 06:23:54.123', '2026-11-01', 1),
    (32, N'SUB-WASTE-34273', 21, 1, NULL, 135000.00, 25000.00, 0.00, 160000.00, 0.05, 0.00, N'CANCELLED', N'Dâu tây bị dập nát và úng nước khi đóng gói tại kho', 1, '2026-11-01 06:23:54.317', '2026-11-01 06:23:54.29', '2026-11-01 06:23:54.317', '2026-11-01', 1),
    (33, N'SUB-FAIL-34425', 22, 1, NULL, 155000.00, 25000.00, 0.00, 180000.00, 0.05, 0.00, N'FAILED', N'Khách thuê bao không liên lạc được sau 3 lần gọi [ĐÃ XỬ LÝ NHẬP KHO: Hoa quả còn tươi nguyên, đã kiểm định và nhập lại kho - Hàng hoàn trả nguyên đai nguyên kiện, nhập kho bán tiếp]', NULL, NULL, '2026-11-01 06:23:54.447', '2026-11-01 06:23:54.623', '2026-11-01', 1),
    (34, N'SUB-SEC-34680', 23, 1, NULL, 75000.00, 25000.00, 0.00, 100000.00, 0.05, 0.00, N'RETURNED', N'Quả dập nát / úng hỏng khi đồng kiểm [ĐÃ XỬ LÝ TIÊU HỦY: Ghi nhận hao hụt do vận chuyển - hong do giao hang]', NULL, NULL, '2026-11-01 06:23:54.697', '2026-11-01 16:13:51.91', '2026-11-01', 1),
    (35, N'SUB-1793525665871-1-887', 24, 1, NULL, 195000.00, 0.00, 0.00, 195000.00, 8.00, 15600.00, N'RETURNED', N'Quả dập nát / úng hỏng khi đồng kiểm', NULL, NULL, '2026-11-01 16:34:25.877', '2026-11-01 16:38:16.86', '2026-11-01', 3),
    (36, N'SUB-1793526455437-1-165', 25, 1, NULL, 7995000.00, 0.00, 0.00, 7995000.00, 8.00, 639600.00, N'RETURNED', N'Khách hàng đổi ý, từ chối nhận hoa quả [ĐÃ XỬ LÝ TIÊU HỦY: Ghi nhận hao hụt do vận chuyển - hong 1/41 quả]', NULL, NULL, '2026-11-01 16:47:35.44', '2026-11-01 16:49:34.7', '2026-11-01', 3),
    (41, N'ST-SO-RETURN-1793588624583', 1, 1, NULL, 120000.00, 20000.00, 0.00, 140000.00, 8.00, 0.00, N'RETURNED', N'Gọi 3 cuộc liên tiếp khách thuê bao không liên lạc được [ĐÃ XỬ LÝ NHẬP KHO: Hoa quả còn tươi nguyên, đã kiểm định và nhập lại kho - Đã nhận lại thùng bảo quản lạnh nguyên vẹn từ shipper]', NULL, NULL, '2026-11-02 10:03:44.6', '2026-11-02 10:03:44.763', '2026-11-02', 1),
    (58, N'SUB-1793733351696-1-676', 35, 1, NULL, 355000.00, 0.00, 0.00, 355000.00, 8.00, 28400.00, N'DELIVERED', NULL, NULL, NULL, '2026-11-04 02:15:51.697', '2026-11-04 10:28:18.053', '2026-11-04', 3),
    (59, N'SUB-1793733351707-2-303', 35, 2, NULL, 85000.00, 0.00, 0.00, 85000.00, 8.00, 6800.00, N'NEW', NULL, NULL, NULL, '2026-11-04 02:15:51.707', '2026-11-04 02:15:51.707', '2026-11-04', 3),
    (60, N'SUB-1793733514147-1-388', 36, 1, NULL, 435000.00, 0.00, 10000.00, 425000.00, 8.00, 34800.00, N'FAILED', N'Quả dập nát / úng hỏng khi đồng kiểm [ĐÃ XỬ LÝ TIÊU HỦY: Ghi nhận hao hụt do vận chuyển - hong Dau]', NULL, NULL, '2026-11-04 02:18:34.15', '2026-11-04 10:43:02.727', '2026-11-04', 3),
    (61, N'SUB-1793733514158-2-348', 36, 2, NULL, 500000.00, 0.00, 30000.00, 470000.00, 8.00, 40000.00, N'NEW', NULL, NULL, NULL, '2026-11-04 02:18:34.16', '2026-11-04 02:18:34.16', '2026-11-04', 3),
    (62, N'SUB-1793761302132-1-667', 37, 1, NULL, 435000.00, 0.00, 0.00, 435000.00, 8.00, 34800.00, N'CANCELLED', N'Nông sản không đạt chuẩn chất lượng (dập nát, thâm úng) - Hong Gion hong', 3, '2026-11-04 10:07:03.623', '2026-11-04 10:01:42.14', '2026-11-04 10:07:03.623', '2026-11-04', 3),
    (63, N'SUB-1793761302174-2-295', 37, 2, NULL, 500000.00, 0.00, 0.00, 500000.00, 8.00, 40000.00, N'NEW', NULL, NULL, NULL, '2026-11-04 10:01:42.173', '2026-11-04 10:01:42.173', '2026-11-04', 3),
    (64, N'SUB-1793761748178-1-614', 38, 1, NULL, 710000.00, 0.00, 0.00, 710000.00, 8.00, 56800.00, N'CANCELLED', N'Nông sản không đạt chuẩn chất lượng (dập nát, thâm úng) - hong gion va dau tay hong 1 1', 3, '2026-11-04 10:10:27.567', '2026-11-04 10:09:08.187', '2026-11-04 10:10:27.567', '2026-11-04', 3),
    (65, N'SUB-1793764593356-1-107', 39, 1, NULL, 975000.00, 0.00, 0.00, 975000.00, 8.00, 78000.00, N'SHIPPING', NULL, NULL, NULL, '2026-11-04 10:56:33.36', '2026-11-16 00:25:41.35', '2026-11-04', 3),
    (66, N'SUB-1793799655237-1-649', 40, 1, NULL, 195000.00, 0.00, 0.00, 195000.00, 8.00, 15600.00, N'NEW', NULL, NULL, NULL, '2026-11-04 20:40:55.243', '2026-11-04 20:40:55.243', '2026-11-04', 1),
    (67, N'SUB-1793818723366-1-787', 41, 1, NULL, 390000.00, 0.00, 0.00, 390000.00, 8.00, 31200.00, N'NEW', NULL, NULL, NULL, '2026-11-05 01:58:43.38', '2026-11-05 01:58:43.38', '2026-11-05', 1),
    (68, N'SUB-1793849409737-1-728', 42, 1, NULL, 390000.00, 0.00, 0.00, 390000.00, 8.00, 31200.00, N'SHIPPING', NULL, NULL, NULL, '2026-11-05 10:30:09.743', '2026-11-05 10:41:10.723', '2026-11-05', 1),
    (69, N'SUB-1793867067958-1-133', 43, 1, NULL, 390000.00, 0.00, 0.00, 390000.00, 8.00, 31200.00, N'NEW', NULL, NULL, NULL, '2026-11-05 15:24:27.963', '2026-11-05 15:24:27.963', '2026-11-05', 1),
    (70, N'SUB-1793868729796-1-580', 44, 1, NULL, 390000.00, 0.00, 0.00, 390000.00, 8.00, 31200.00, N'PACKING', NULL, NULL, NULL, '2026-11-05 15:52:09.803', '2026-11-07 13:03:05.467', '2026-11-05', 1),
    (71, N'SUB-1794032350628-1-313', 45, 1, NULL, 195000.00, 0.00, 0.00, 195000.00, 8.00, 15600.00, N'CANCELLED', N'Nông sản không đạt chuẩn chất lượng (dập nát, thâm úng) - asd', 3, '2026-11-09 04:27:13.273', '2026-11-07 13:19:10.64', '2026-11-09 04:27:13.273', '2026-11-07', 1),
    (72, N'SUB-1794032458266-1-973', 46, 1, NULL, 195000.00, 0.00, 0.00, 195000.00, 8.00, 15600.00, N'CANCELLED', N'Lý do khác - ádsd', 3, '2026-11-09 04:27:31.34', '2026-11-07 13:20:58.27', '2026-11-09 04:27:31.34', '2026-11-07', 1),
    (73, N'SUB-1794040919523-1-204', 47, 1, NULL, 195000.00, 0.00, 0.00, 195000.00, 8.00, 15600.00, N'CANCELLED', N'Thời gian giao hàng dự kiến không phù hợp', 16, '2026-11-07 15:42:23.603', '2026-11-07 15:41:59.53', '2026-11-07 15:42:23.603', '2026-11-10', 5),
    (74, N'SUB-1794040968312-1-151', 48, 1, NULL, 195000.00, 0.00, 0.00, 195000.00, 8.00, 15600.00, N'SHIPPING', NULL, NULL, NULL, '2026-11-07 15:42:48.313', '2026-11-09 04:23:56.35', '2026-11-07', 6),
    (75, N'SUB-1794070862147-1-562', 49, 1, NULL, 390000.00, 0.00, 0.00, 390000.00, 8.00, 31200.00, N'SHIPPING', NULL, NULL, NULL, '2026-11-08 00:01:02.153', '2026-11-09 04:24:00.3', '2026-11-11', 1),
    (76, N'SUB-1794071768527-1-145', 50, 1, NULL, 975000.00, 0.00, 0.00, 975000.00, 8.00, 78000.00, N'NEW', NULL, NULL, NULL, '2026-11-08 00:16:08.53', '2026-11-08 00:16:08.53', '2026-11-08', 1),
    (77, N'SUB-1794149552756-1-223', 51, 1, NULL, 595000.00, 0.00, 0.00, 595000.00, 8.00, 47600.00, N'DELIVERED', NULL, NULL, NULL, '2026-11-08 21:52:32.76', '2026-11-09 04:42:05.833', '2026-11-09', 3),
    (78, N'SUB-1794755352221-1-880', 52, 1, NULL, 585000.00, 30000.00, 0.00, 615000.00, 8.00, 46800.00, N'CANCELLED', N'Nông sản không đạt chuẩn chất lượng (dập nát, thâm úng) - hong 2 hop', 3, '2026-11-15 22:10:00.107', '2026-11-15 22:09:12.23', '2026-11-15 22:10:00.107', '2026-11-16', 1),
    (79, N'SUB-1794792448215-1-215', 53, 1, NULL, 195000.00, 30000.00, 0.00, 225000.00, 8.00, 15600.00, N'DELIVERED', NULL, NULL, NULL, '2026-11-16 08:27:28.227', '2026-11-16 08:34:15.223', '2026-11-16', 2);
SET IDENTITY_INSERT [dbo].[sub_orders] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [order_items] (66 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[order_items] ON;
INSERT INTO [dbo].[order_items] ([order_item_id], [sub_order_id], [variant_id], [product_name_snapshot], [variant_name_snapshot], [sku_snapshot], [unit], [unit_price], [quantity], [total_price], [promotion_id], [promotion_discount], [promotion_units]) VALUES
    (1, 1, 1, N'Dâu Tây Giống New Zealand Đà Lạt', N'Hộp 500g (Loại 1)', N'DL-DAU-NZ-500G', N'hộp', 160000.00, 2, 320000.00, NULL, 0.00, 0),
    (2, 1, 3, N'Dâu Bạch Tuyết Ngọc Trai Trắng', N'Hộp Quà 300g VIP', N'DL-DAU-BT-300G', N'hộp', 150000.00, 1, 150000.00, NULL, 0.00, 0),
    (3, 2, 6, N'Sầu Riêng Ri6 Chín Cây Tự Nhiên', N'Hộp tách múi sẵn 500g', N'MT-SAU-RI6-BOX', N'hộp', 210000.00, 3, 630000.00, NULL, 0.00, 0),
    (4, 3, 6, N'Sầu Riêng Ri6 Chín Cây Tự Nhiên', N'Hộp tách múi sẵn 500g', N'MT-SAU-RI6-BOX', N'hộp', 210000.00, 2, 420000.00, NULL, 0.00, 0),
    (5, 4, 2, N'Dâu Tây Giống New Zealand Đà Lạt', N'Hộp 1kg (Loại 1)', N'DL-DAU-NZ-1KG', N'hộp', 310000.00, 1, 310000.00, NULL, 0.00, 0),
    (6, 5, 13, N'Giỏ Quà Trái Cây Cao Cấp Phú Quý', N'Set Giỏ Quà VIP', N'SAN-GIO-PHUQUY', N'giỏ', 750000.00, 1, 750000.00, NULL, 0.00, 0),
    (7, 6, 11, N'Thanh Long Ruột Đỏ Lương Hòa', N'Túi 1kg (2 quả)', N'LA-TL-DO-1KG', N'kg', 45000.00, 2, 90000.00, NULL, 0.00, 0),
    (8, 7, 9, N'Mận Hậu VIP Sapa Căng Mọng', N'Hộp 1kg chọn quả to', N'SP-MAN-HAU-1KG', N'hộp', 95000.00, 3, 285000.00, NULL, 0.00, 0),
    (9, 8, 11, N'Thanh Long Ruột Đỏ Lương Hòa', N'Túi 1kg (2 quả)', N'LA-TL-DO-1KG', N'kg', 45000.00, 5, 225000.00, NULL, 0.00, 0),
    (10, 9, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 1, 195000.00, NULL, 0.00, 0),
    (11, 10, 7, N'Xoài Cát Hòa Lộc Hạng Nhất', N'Túi 1kg (2 quả/kg)', N'MT-XOAI-HL-1KG', N'kg', 85000.00, 1, 85000.00, NULL, 0.00, 0),
    (12, 10, 5, N'Sầu Riêng Ri6 Chín Cây Tự Nhiên', N'Quả nguyên (2.5 - 3.5kg)', N'MT-SAU-RI6-QUA', N'kg', 125000.00, 1, 125000.00, NULL, 0.00, 0),
    (13, 11, 13, N'Giỏ Quà Trái Cây Cao Cấp Phú Quý', N'Set Giỏ Quà VIP', N'SAN-GIO-PHUQUY', N'giỏ', 750000.00, 2, 1500000.00, NULL, 0.00, 0),
    (14, 12, 12, N'Dưa Lưới Taki Trồng Nhà Màng', N'Quả 1.5 - 1.8kg', N'LA-DUA-TK-QUA', N'quả', 95000.00, 1, 95000.00, NULL, 0.00, 0),
    (15, 13, 3, N'Dâu Bạch Tuyết Ngọc Trai Trắng', N'Hộp Quà 300g VIP', N'DL-DAU-BT-300G', N'hộp', 240000.00, 1, 240000.00, NULL, 0.00, 0),
    (16, 14, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 5, 975000.00, NULL, 0.00, 0),
    (17, 15, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 1, 195000.00, NULL, 0.00, 0),
    (18, 16, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 1, 195000.00, NULL, 0.00, 0),
    (19, 17, 5, N'Sầu Riêng Ri6 Chín Cây Tự Nhiên', N'Quả nguyên (2.5 - 3.5kg)', N'MT-SAU-RI6-QUA', N'kg', 125000.00, 1, 125000.00, NULL, 0.00, 0),
    (20, 18, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 1, 195000.00, NULL, 0.00, 0),
    (21, 19, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 1, 195000.00, NULL, 0.00, 0),
    (22, 20, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 1, 195000.00, NULL, 0.00, 0),
    (23, 21, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 2, 390000.00, NULL, 0.00, 0),
    (24, 22, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 1, 195000.00, NULL, 0.00, 0),
    (25, 23, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 4, 780000.00, NULL, 0.00, 0),
    (26, 24, 1, N'Nông s?n test', N'H?p tiêu chu?n', N'SKU-TEST', N'H?p', 100000.00, 2, 200000.00, NULL, 0.00, 0),
    (27, 25, 1, N'Nông s?n test', N'H?p tiêu chu?n', N'SKU-TEST', N'H?p', 100000.00, 3, 300000.00, NULL, 0.00, 0),
    (28, 26, 1, N'Nông s?n test', N'H?p tiêu chu?n', N'SKU-TEST', N'H?p', 100000.00, 1, 100000.00, NULL, 0.00, 0),
    (29, 27, 2, N'Nông s?n test', N'H?p tiêu chu?n', N'SKU-TEST', N'H?p', 100000.00, 1, 100000.00, NULL, 0.00, 0),
    (30, 28, 2, N'Nông s?n test', N'H?p tiêu chu?n', N'SKU-TEST', N'H?p', 100000.00, 2, 200000.00, NULL, 0.00, 0),
    (31, 29, 2, N'Nông s?n test', N'H?p tiêu chu?n', N'SKU-TEST', N'H?p', 100000.00, 3, 300000.00, NULL, 0.00, 0),
    (32, 30, 2, N'Nông s?n test', N'H?p tiêu chu?n', N'SKU-TEST', N'H?p', 100000.00, 1, 100000.00, NULL, 0.00, 0),
    (33, 31, 1, N'Nông sản test E2E', N'Hộp tiêu chuẩn 500g', N'SKU-E2E', N'Hộp', 112500.00, 2, 225000.00, NULL, 0.00, 0),
    (34, 32, 1, N'Nông sản test E2E', N'Hộp tiêu chuẩn 500g', N'SKU-E2E', N'Hộp', 135000.00, 1, 135000.00, NULL, 0.00, 0),
    (35, 33, 2, N'Nông sản test E2E', N'Hộp tiêu chuẩn 500g', N'SKU-E2E', N'Hộp', 155000.00, 1, 155000.00, NULL, 0.00, 0),
    (36, 34, 1, N'Nông sản test E2E', N'Hộp tiêu chuẩn 500g', N'SKU-E2E', N'Hộp', 75000.00, 1, 75000.00, NULL, 0.00, 0),
    (37, 35, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 1, 195000.00, NULL, 0.00, 0),
    (38, 36, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 41, 7995000.00, NULL, 0.00, 0),
    (57, 58, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 1, 195000.00, NULL, 0.00, 0),
    (58, 58, 1, N'Dâu Tây Giống New Zealand Đà Lạt', N'Hộp 500g (Loại 1)', N'DL-DAU-NZ-500G', N'hộp', 160000.00, 1, 160000.00, NULL, 0.00, 0),
    (59, 59, 7, N'Xoài Cát Hòa Lộc Hạng Nhất', N'Túi 1kg (2 quả/kg)', N'MT-XOAI-HL-1KG', N'kg', 85000.00, 1, 85000.00, NULL, 0.00, 0),
    (60, 60, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 1, 195000.00, NULL, 0.00, 0),
    (61, 60, 3, N'Dâu Bạch Tuyết Ngọc Trai Trắng', N'Hộp Quà 300g VIP', N'DL-DAU-BT-300G', N'hộp', 240000.00, 1, 240000.00, NULL, 0.00, 0),
    (62, 61, 5, N'Sầu Riêng Ri6 Chín Cây Tự Nhiên', N'Quả nguyên (2.5 - 3.5kg)', N'MT-SAU-RI6-QUA', N'kg', 125000.00, 4, 500000.00, NULL, 0.00, 0),
    (63, 62, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 1, 195000.00, NULL, 0.00, 0),
    (64, 62, 3, N'Dâu Bạch Tuyết Ngọc Trai Trắng', N'Hộp Quà 300g VIP', N'DL-DAU-BT-300G', N'hộp', 240000.00, 1, 240000.00, NULL, 0.00, 0),
    (65, 63, 5, N'Sầu Riêng Ri6 Chín Cây Tự Nhiên', N'Quả nguyên (2.5 - 3.5kg)', N'MT-SAU-RI6-QUA', N'kg', 125000.00, 4, 500000.00, NULL, 0.00, 0),
    (66, 64, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 2, 390000.00, NULL, 0.00, 0),
    (67, 64, 1, N'Dâu Tây Giống New Zealand Đà Lạt', N'Hộp 500g (Loại 1)', N'DL-DAU-NZ-500G', N'hộp', 160000.00, 2, 320000.00, NULL, 0.00, 0),
    (68, 65, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 5, 975000.00, NULL, 0.00, 0),
    (69, 66, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 1, 195000.00, NULL, 0.00, 0),
    (70, 67, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 2, 390000.00, NULL, 0.00, 0),
    (71, 68, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 2, 390000.00, NULL, 0.00, 0),
    (72, 69, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 2, 390000.00, NULL, 0.00, 0),
    (73, 70, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 2, 390000.00, NULL, 0.00, 0),
    (74, 71, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 1, 195000.00, NULL, 0.00, 0),
    (75, 72, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 1, 195000.00, NULL, 0.00, 0),
    (76, 73, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 1, 195000.00, NULL, 0.00, 0),
    (77, 74, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 1, 195000.00, NULL, 0.00, 0),
    (78, 75, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 2, 390000.00, NULL, 0.00, 0),
    (79, 76, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 5, 975000.00, NULL, 0.00, 0),
    (80, 77, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 1, 195000.00, NULL, 0.00, 0),
    (81, 77, 3, N'Dâu Bạch Tuyết Ngọc Trai Trắng', N'Hộp Quà 300g VIP', N'DL-DAU-BT-300G', N'hộp', 240000.00, 1, 240000.00, NULL, 0.00, 0),
    (82, 77, 1, N'Dâu Tây Giống New Zealand Đà Lạt', N'Hộp 500g (Loại 1)', N'DL-DAU-NZ-500G', N'hộp', 160000.00, 1, 160000.00, NULL, 0.00, 0),
    (83, 78, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 3, 585000.00, NULL, 0.00, 0),
    (84, 79, 4, N'Hồng Giòn Treo Gió Công Nghệ Nhật', N'Hộp 500g Hút Chân Không', N'DL-HONG-TG-500G', N'hộp', 195000.00, 1, 195000.00, NULL, 0.00, 0);
SET IDENTITY_INSERT [dbo].[order_items] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [payments] (35 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[payments] ON;
INSERT INTO [dbo].[payments] ([payment_id], [order_id], [payment_provider], [payment_type], [transaction_code], [amount], [payment_status], [failure_reason], [created_at], [paid_at]) VALUES
    (1, 6, N'COD', N'CASH', NULL, 90000.00, N'PENDING', NULL, '2026-10-20 01:10:45.52', NULL),
    (2, 7, N'COD', N'CASH', NULL, 510000.00, N'PENDING', NULL, '2026-10-20 11:36:09.14', NULL),
    (3, 8, N'COD', N'CASH', NULL, 1905000.00, N'PENDING', NULL, '2026-10-21 01:16:26.417', NULL),
    (4, 9, N'COD', N'CASH', NULL, 95000.00, N'PENDING', NULL, '2026-10-26 13:48:26.86', NULL),
    (5, 10, N'COD', N'CASH', NULL, 240000.00, N'PENDING', NULL, '2026-10-26 13:49:14.72', NULL),
    (6, 11, N'COD', N'CASH', NULL, 975000.00, N'PENDING', NULL, '2026-10-27 03:01:19.69', NULL),
    (7, 12, N'COD', N'CASH', NULL, 195000.00, N'PENDING', NULL, '2026-10-27 03:20:55.46', NULL),
    (8, 13, N'COD', N'CASH', NULL, 320000.00, N'PENDING', NULL, '2026-10-27 11:48:10.95', NULL),
    (9, 14, N'COD', N'CASH', NULL, 195000.00, N'PENDING', NULL, '2026-10-27 12:34:09.7', NULL),
    (10, 15, N'COD', N'CASH', NULL, 195000.00, N'PENDING', NULL, '2026-10-29 15:45:23.053', NULL),
    (11, 16, N'COD', N'CASH', NULL, 195000.00, N'PENDING', NULL, '2026-10-29 16:07:04.35', NULL),
    (12, 17, N'COD', N'CASH', NULL, 390000.00, N'PENDING', NULL, '2026-10-29 16:19:46.563', NULL),
    (13, 18, N'COD', N'CASH', NULL, 195000.00, N'PENDING', NULL, '2026-10-29 16:27:59.407', NULL),
    (14, 19, N'COD', N'CASH', NULL, 780000.00, N'PENDING', NULL, '2026-10-31 17:26:40.563', NULL),
    (15, 24, N'COD', N'CASH', NULL, 195000.00, N'PENDING', NULL, '2026-11-01 16:34:25.89', NULL),
    (16, 25, N'COD', N'CASH', NULL, 7995000.00, N'PENDING', NULL, '2026-11-01 16:47:35.45', NULL),
    (23, 35, N'COD', N'CASH', NULL, 440000.00, N'PENDING', NULL, '2026-11-04 02:15:51.747', NULL),
    (24, 36, N'VNPAY', N'ONLINE', NULL, 835000.00, N'PENDING', NULL, '2026-11-04 02:18:34.177', NULL),
    (25, 37, N'COD', N'CASH', NULL, 935000.00, N'PENDING', NULL, '2026-11-04 10:01:42.21', NULL),
    (26, 38, N'COD', N'CASH', NULL, 710000.00, N'PENDING', NULL, '2026-11-04 10:09:08.217', NULL),
    (27, 39, N'COD', N'CASH', NULL, 975000.00, N'PENDING', NULL, '2026-11-04 10:56:33.373', NULL),
    (28, 40, N'VNPAY', N'ONLINE', NULL, 195000.00, N'PENDING', NULL, '2026-11-04 20:40:55.273', NULL),
    (29, 41, N'VNPAY', N'ONLINE', NULL, 390000.00, N'PENDING', NULL, '2026-11-05 01:58:43.427', NULL),
    (30, 42, N'COD', N'CASH', NULL, 390000.00, N'PENDING', NULL, '2026-11-05 10:30:09.767', NULL),
    (31, 43, N'VNPAY', N'ONLINE', NULL, 390000.00, N'PENDING', NULL, '2026-11-05 15:24:27.987', NULL),
    (32, 44, N'COD', N'CASH', NULL, 390000.00, N'PENDING', NULL, '2026-11-05 15:52:09.837', NULL),
    (33, 45, N'COD', N'CASH', NULL, 195000.00, N'PENDING', NULL, '2026-11-07 13:19:10.677', NULL),
    (34, 46, N'COD', N'CASH', NULL, 195000.00, N'PENDING', NULL, '2026-11-07 13:20:58.29', NULL),
    (35, 47, N'COD', N'CASH', NULL, 195000.00, N'PENDING', NULL, '2026-11-07 15:41:59.56', NULL),
    (36, 48, N'COD', N'CASH', NULL, 195000.00, N'PENDING', NULL, '2026-11-07 15:42:48.34', NULL),
    (37, 49, N'COD', N'CASH', NULL, 390000.00, N'PENDING', NULL, '2026-11-08 00:01:02.187', NULL),
    (38, 50, N'VNPAY', N'ONLINE', NULL, 975000.00, N'PENDING', NULL, '2026-11-08 00:16:08.55', NULL),
    (39, 51, N'COD', N'CASH', NULL, 595000.00, N'SUCCESS', NULL, '2026-11-08 21:52:32.8', '2026-11-09 04:42:05.837'),
    (40, 52, N'COD', N'CASH', NULL, 615000.00, N'PENDING', NULL, '2026-11-15 22:09:12.263', NULL),
    (41, 53, N'COD', N'CASH', NULL, 225000.00, N'SUCCESS', NULL, '2026-11-16 08:27:28.253', '2026-11-16 08:34:15.273');
SET IDENTITY_INSERT [dbo].[payments] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [driver_profiles] (3 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[driver_profiles] ON;
INSERT INTO [dbo].[driver_profiles] ([driver_id], [user_id], [shop_id], [license_number], [vehicle_type], [vehicle_plate], [cold_storage_type], [operating_city], [operating_districts], [hub_name], [approval_status], [availability_status], [reviewed_by], [reviewed_at], [rejection_reason], [rating], [total_trips], [max_capacity_orders], [created_at], [updated_at]) VALUES
    (1, 9, 1, N'B2-998821', N'Xe máy chuyên dụng', N'59-P1 084.21', N'Thùng giữ nhiệt FreshBox chuỗi lạnh', N'TP. Hồ Chí Minh', NULL, NULL, N'APPROVED', N'AVAILABLE', NULL, NULL, NULL, 4.90, 340, 5, '2026-10-20 02:48:10.953', '2026-10-20 02:48:10.953'),
    (2, 32, 1, N'B2-887766', N'Xe tải bảo ôn 1.25 tấn', N'29C-765.43', N'Thùng lạnh âm sâu -2°C đến 5°C', N'Hà Nội', N'Cầu Giấy, Nam Từ Liêm, Ba Đình', NULL, N'APPROVED', N'OFFLINE', NULL, NULL, NULL, 4.95, 128, 8, '2026-10-21 14:12:15.19', '2026-10-27 03:23:57.01'),
    (3, 33, NULL, N'A1-445566', N'Xe máy chuyên dụng', N'29-H2 567.89', N'Thùng bảo ôn FreshBox giữ nhiệt 2-5°C', N'Hà Nội', N'Đống Đa, Thanh Xuân, Hai Bà Trưng', NULL, N'APPROVED', N'OFFLINE', NULL, NULL, NULL, 4.88, 215, 5, '2026-10-21 14:12:15.193', '2026-10-27 13:35:50.967');
SET IDENTITY_INSERT [dbo].[driver_profiles] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [deliveries] (24 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[deliveries] ON;
INSERT INTO [dbo].[deliveries] ([delivery_id], [sub_order_id], [driver_id], [tracking_number], [delivery_status], [proof_image_url], [failure_reason], [assigned_at], [delivered_at]) VALUES
    (1, 6, 9, N'FFX-COLD-1006-VN', N'FAILED', NULL, N'Khách hàng bận, không nghe máy 3 lần', '2026-10-20 02:48:16.353', '2026-11-01 06:20:17.653'),
    (2, 9, 32, N'FFX-COLD-1009-VN', N'ASSIGNED', NULL, NULL, '2026-10-21 15:22:09.407', NULL),
    (3, 4, 32, N'FFX-COLD-1004-VN', N'ASSIGNED', NULL, NULL, '2026-10-26 13:40:00.28', NULL),
    (4, 14, 32, N'FFX-COLD-1014-VN', N'ASSIGNED', NULL, NULL, '2026-10-27 03:06:03.12', NULL),
    (5, 15, 9, N'FFX-COLD-1015-VN', N'DELIVERED', N'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=600', NULL, '2026-10-27 11:06:02.073', '2026-10-27 11:37:06.38'),
    (6, 16, 9, N'FFX-COLD-1016-VN', N'DELIVERED', N'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=600', NULL, '2026-10-27 11:50:57.15', '2026-10-27 11:53:11.843'),
    (7, 18, 9, N'FFX-COLD-1018-VN', N'DELIVERED', N'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=600', NULL, '2026-10-27 15:11:50', '2026-10-27 15:13:05.983'),
    (8, 20, 9, N'FFX-COLD-1020-VN', N'DELIVERED', N'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=600', NULL, '2026-10-29 16:17:11.603', '2026-10-29 16:18:23.663'),
    (9, 21, 9, N'FFX-COLD-1021-VN', N'FAILED', NULL, N'Quả dập nát / úng hỏng khi đồng kiểm', '2026-10-29 16:20:23.343', '2026-11-01 16:12:31.96'),
    (10, 1, 9, N'TRK-7005', N'DELIVERED', N'https://res.cloudinary.com/demo/image/upload/sample_pod.jpg', NULL, '2026-11-01 06:20:17.03', '2026-11-01 06:20:51.727'),
    (12, 27, 9, N'TRK-1899', N'FAILED', NULL, N'Khách hàng bận, không nghe máy 3 lần', '2026-11-01 06:20:51.9', '2026-11-01 06:20:51.92'),
    (13, 31, 9, N'TRK-E2E-33950', N'DELIVERED', N'https://freshfruit.vn/uploads/pod-proof-success.jpg', NULL, '2026-11-01 06:23:53.953', '2026-11-01 06:23:54.12'),
    (14, 33, 9, N'TRK-E2E-34496', N'FAILED', NULL, N'Khách thuê bao không liên lạc được sau 3 lần gọi', '2026-11-01 06:23:54.497', '2026-11-01 06:23:54.53'),
    (15, 34, 9, N'TRK-E2E-34776', N'FAILED', NULL, N'Quả dập nát / úng hỏng khi đồng kiểm', '2026-11-01 16:10:07.147', '2026-11-01 16:12:16.763'),
    (16, 35, 9, N'FFX-COLD-1035-VN', N'FAILED', NULL, N'Quả dập nát / úng hỏng khi đồng kiểm', '2026-11-01 16:35:13.69', '2026-11-01 16:38:16.847'),
    (17, 36, 9, N'FFX-COLD-1036-VN', N'FAILED', NULL, N'Khách hàng đổi ý, từ chối nhận hoa quả', '2026-11-01 16:48:27.713', '2026-11-01 16:48:57.56'),
    (29, 60, 9, N'FFX-COLD-1060-VN', N'FAILED', NULL, N'Quả dập nát / úng hỏng khi đồng kiểm', '2026-11-04 10:17:06.007', '2026-11-04 10:28:38.02'),
    (30, 58, 9, N'FFX-COLD-1058-VN', N'DELIVERED', N'https://res.cloudinary.com/hiest36g/image/upload/v1793762897/deliveries/pod/ffqygxusyw0ksfi3t4t2.jpg', NULL, '2026-11-04 10:19:28.3', '2026-11-04 10:28:18.047'),
    (31, 68, 9, N'FFX-COLD-1068-VN', N'DELIVERING', NULL, NULL, '2026-11-05 10:37:43.66', NULL),
    (32, 75, 9, N'FFX-COLD-1075-VN', N'DELIVERING', NULL, NULL, '2026-11-08 00:12:46.497', NULL),
    (33, 74, 9, N'FFX-COLD-1074-VN', N'DELIVERING', NULL, NULL, '2026-11-08 21:46:13.573', NULL),
    (34, 77, 9, N'FFX-COLD-1077-VN', N'DELIVERED', N'https://res.cloudinary.com/hiest36g/image/upload/v1794174125/deliveries/pod/hvugb5ilebh4wd1krg2j.jpg', NULL, '2026-11-09 04:22:46.487', '2026-11-09 04:42:05.83'),
    (35, 65, 9, N'FFX-COLD-1065-VN', N'ASSIGNED', NULL, NULL, '2026-11-16 00:25:41.343', NULL),
    (36, 79, 9, N'FFX-COLD-1079-VN', N'DELIVERED', N'https://res.cloudinary.com/hiest36g/image/upload/v1794792854/deliveries/pod/z700e685vwic9p0jbypv.jpg', NULL, '2026-11-16 08:29:03.967', '2026-11-16 08:34:15.217');
SET IDENTITY_INSERT [dbo].[deliveries] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [disputes] (12 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[disputes] ON;
INSERT INTO [dbo].[disputes] ([dispute_id], [dispute_code], [sub_order_id], [customer_id], [shop_id], [reason_category], [complaint_text], [claim_amount], [evidence_image_url], [status], [resolution_decision], [resolution_note], [resolved_by], [resolved_at], [created_at]) VALUES
    (1, N'DIS-892', 3, 15, 2, N'Quả dập nát/úng hỏng', N'Tôi nhận 2 hộp sầu riêng Ri6 nhưng múi bên trong bị chua ủng, có mùi rượu lên men không thể ăn được. Yêu cầu bồi hoàn.', 420000.00, N'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400', N'OPEN', NULL, NULL, NULL, NULL, '2024-10-29 08:30:00'),
    (2, N'DIS-891', 4, 11, 1, N'Đứt gãy bảo quản lạnh', N'Shipper giao trễ hơn 6 tiếng so với cam kết, thùng xốp không còn đá gel dẫn đến dâu tây bị hấp hơi ủng nước.', 310000.00, N'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=400', N'MEDIATING', NULL, N'Đang yêu cầu đối tác giao vận trích xuất nhật ký nhiệt độ thùng lạnh.', NULL, NULL, '2024-10-29 16:00:00'),
    (3, N'DIS-890', 1, 10, 1, N'Giao thiếu số lượng', N'Đơn đặt 2 hộp dâu NZ nhưng bưu tá chỉ bàn giao 1 hộp.', 160000.00, NULL, N'REFUNDED_BUYER', N'REFUND_BUYER', N'Shop xác nhận đóng gói sót hàng, Admin phê duyệt hoàn tiền vào ví khách hàng.', 1, '2024-10-22 10:00:00', '2024-10-21 18:00:00'),
    (4, N'DIS-1-7429', 6, 16, 4, N'Từ chối nhận khi đồng kiểm với Shipper', N'Giao sai loại quả hoặc thiếu số lượng', 90000.00, NULL, N'OPEN', NULL, NULL, NULL, NULL, '2026-10-20 03:37:09.26'),
    (5, N'DIS-1-4017', 6, 16, 4, N'Từ chối nhận khi đồng kiểm với Shipper', N'Khách hàng bận, không nghe máy 3 lần', 90000.00, NULL, N'OPEN', NULL, NULL, NULL, NULL, '2026-11-01 06:20:17.663'),
    (6, N'DIS-12-4051', 27, 10, 1, N'Từ chối nhận khi đồng kiểm với Shipper', N'Khách hàng bận, không nghe máy 3 lần', 225000.00, NULL, N'OPEN', NULL, NULL, NULL, NULL, '2026-11-01 06:20:51.927'),
    (7, N'DIS-14-4234', 33, 5, 1, N'Từ chối nhận khi đồng kiểm với Shipper', N'Khách thuê bao không liên lạc được sau 3 lần gọi', 180000.00, NULL, N'OPEN', NULL, NULL, NULL, NULL, '2026-11-01 06:23:54.54'),
    (8, N'DIS-15-9536', 34, 5, 1, N'Từ chối nhận khi đồng kiểm với Shipper', N'Quả dập nát / úng hỏng khi đồng kiểm', 100000.00, NULL, N'OPEN', NULL, NULL, NULL, NULL, '2026-11-01 16:12:16.777'),
    (9, N'DIS-9-9551', 21, 16, 1, N'Từ chối nhận khi đồng kiểm với Shipper', N'Quả dập nát / úng hỏng khi đồng kiểm', 390000.00, NULL, N'OPEN', NULL, NULL, NULL, NULL, '2026-11-01 16:12:31.97'),
    (10, N'DIS-16-1096', 35, 16, 1, N'Từ chối nhận khi đồng kiểm với Shipper', N'Quả dập nát / úng hỏng khi đồng kiểm', 195000.00, NULL, N'OPEN', NULL, NULL, NULL, NULL, '2026-11-01 16:38:16.87'),
    (11, N'DIS-17-1737', 36, 16, 1, N'Từ chối nhận khi đồng kiểm với Shipper', N'Khách hàng đổi ý, từ chối nhận hoa quả', 7995000.00, NULL, N'OPEN', NULL, NULL, NULL, NULL, '2026-11-01 16:48:57.573'),
    (12, N'DIS-20-3824', 41, 10, 1, N'Từ chối nhận khi đồng kiểm với Shipper', N'Gọi 3 cuộc liên tiếp khách thuê bao không liên lạc được', 140000.00, NULL, N'OPEN', NULL, NULL, NULL, NULL, '2026-11-02 10:03:44.69');
SET IDENTITY_INSERT [dbo].[disputes] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [vendor_payouts] (4 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[vendor_payouts] ON;
INSERT INTO [dbo].[vendor_payouts] ([payout_id], [payout_code], [shop_id], [cycle_name], [period_start], [period_end], [gross_sales], [total_orders_count], [commission_rate], [commission_withheld], [dispute_deductions], [net_payout], [bank_account_number], [bank_name], [status], [processed_by], [paid_at], [created_at]) VALUES
    (1, N'PAY-2024-W39-01', 1, N'Kỳ Quyết Toán Tuần 39 (23/09 - 29/09)', '2024-09-23 00:00:00', '2024-09-29 00:00:00', 42500000.00, 145, 8.00, 3400000.00, 0.00, 39100000.00, N'190345678901', N'Techcombank', N'COMPLETED', 1, '2024-10-04 15:30:00', '2024-09-30 08:00:00'),
    (2, N'PAY-2024-W39-02', 2, N'Kỳ Quyết Toán Tuần 39 (23/09 - 29/09)', '2024-09-23 00:00:00', '2024-09-29 00:00:00', 58200000.00, 192, 7.50, 4365000.00, 0.00, 53835000.00, N'0123456789', N'Vietcombank', N'COMPLETED', 1, '2024-10-04 15:35:00', '2024-09-30 08:00:00'),
    (3, N'PAY-2024-W40-01', 1, N'Kỳ Quyết Toán Tuần 40 (30/09 - 06/10)', '2024-09-30 00:00:00', '2024-10-06 00:00:00', 46800000.00, 168, 8.00, 3744000.00, 160000.00, 42896000.00, N'190345678901', N'Techcombank', N'PROCESSING', NULL, NULL, '2024-10-01 08:00:00'),
    (4, N'PAY-2024-W40-02', 2, N'Kỳ Quyết Toán Tuần 40 (30/09 - 06/10)', '2024-09-30 00:00:00', '2024-10-06 00:00:00', 64500000.00, 215, 7.50, 4837500.00, 0.00, 59662500.00, N'0123456789', N'Vietcombank', N'PROCESSING', NULL, NULL, '2024-10-01 08:00:00');
SET IDENTITY_INSERT [dbo].[vendor_payouts] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [reviews] (4 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[reviews] ON;
INSERT INTO [dbo].[reviews] ([review_id], [order_item_id], [customer_id], [shop_id], [rating], [comment], [reply_comment], [status], [created_at], [updated_at]) VALUES
    (1, 1, 10, 1, 5, N'Dâu tây Đà Lạt nhận được rất tươi ngon, còn nguyên cuống xanh mọng, đóng gói hộp xốp có đá gel cực kỳ cẩn thận!', N'Cảm ơn bạn đã tin yêu và ủng hộ nông sản Đà Lạt Fresh Farm nhé!', N'APPROVED', '2026-10-03 04:59:47.317', '2026-10-03 04:59:47.317'),
    (2, 2, 11, 2, 5, N'Sầu riêng Ri6 thơm nức mũi, hạt lép chuẩn chỉnh, cơm sầu dẻo quánh béo ngậy. Tuyệt đối hài lòng!', N'Dạ HTX rất vui khi bạn thưởng thức trọn vẹn đặc sản Tiền Giang ạ!', N'APPROVED', '2026-10-03 04:59:47.317', '2026-10-03 04:59:47.317'),
    (3, 5, 13, 4, 5, N'Giỏ quà trái cây sang trọng, trang trí đẹp mắt làm quà tặng sếp rất ưng ý. Sẽ tiếp tục đặt lại!', NULL, N'APPROVED', '2026-10-03 04:59:47.317', '2026-10-03 04:59:47.317'),
    (4, 3, 15, 2, 2, N'Sầu riêng đợt này nhận bị lên men hơi chua, mong HTX kiểm tra lại khâu tuyển chọn trái.', N'HTX thành thật xin lỗi bạn, Admin sàn đã hỗ trợ xử lý hoàn tiền đền bù cho bạn rồi ạ.', N'APPROVED', '2026-10-03 04:59:47.317', '2026-10-03 04:59:47.317');
SET IDENTITY_INSERT [dbo].[reviews] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [review_images] (4 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[review_images] ON;
INSERT INTO [dbo].[review_images] ([image_id], [review_id], [image_url], [created_at]) VALUES
    (1, 1, N'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=500&fit=crop', '2026-10-03 05:05:00'),
    (2, 1, N'https://images.unsplash.com/photo-1518635017498-87f514b751ba?w=500&fit=crop', '2026-10-03 05:05:00'),
    (3, 2, N'https://images.unsplash.com/photo-1588391548224-2f00178d431e?w=500&fit=crop', '2026-10-03 05:05:00'),
    (4, 4, N'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=500&fit=crop', '2026-10-03 05:05:00');
SET IDENTITY_INSERT [dbo].[review_images] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [loyalty_accounts] (6 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[loyalty_accounts] ON;
INSERT INTO [dbo].[loyalty_accounts] ([account_id], [customer_id], [current_points], [membership_tier], [created_at], [updated_at]) VALUES
    (1, 10, 470, N'GOLD', '2026-10-03 04:59:47.323', '2026-10-03 04:59:47.323'),
    (2, 11, 610, N'GOLD', '2026-10-03 04:59:47.323', '2026-10-03 04:59:47.323'),
    (3, 12, 150, N'SILVER', '2026-10-03 04:59:47.323', '2026-10-03 04:59:47.323'),
    (4, 13, 735, N'PLATINUM', '2026-10-03 04:59:47.323', '2026-10-03 04:59:47.323'),
    (5, 14, 50, N'BRONZE', '2026-10-03 04:59:47.323', '2026-10-03 04:59:47.323'),
    (6, 15, 200, N'SILVER', '2026-10-03 04:59:47.323', '2026-10-03 04:59:47.323');
SET IDENTITY_INSERT [dbo].[loyalty_accounts] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [loyalty_transactions] (6 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[loyalty_transactions] ON;
INSERT INTO [dbo].[loyalty_transactions] ([transaction_id], [account_id], [order_id], [points_delta], [description], [created_at]) VALUES
    (1, 1, 1, 470, N'Tích điểm hoàn thành đơn hàng #ORD-2024-8821', '2024-10-21 15:00:00'),
    (2, 2, 2, 610, N'Tích điểm hoàn thành đơn hàng #ORD-2024-8820', '2024-10-21 18:00:00'),
    (3, 3, NULL, 150, N'Điểm thưởng chào mừng thành viên bạc FreshFruit', '2026-10-03 05:00:00'),
    (4, 4, 5, 735, N'Tích điểm hoàn thành đơn hàng #ORD-2024-8817', '2024-10-29 20:00:00'),
    (5, 5, NULL, 50, N'Điểm thưởng đăng ký tài khoản mới', '2026-10-03 05:00:00'),
    (6, 6, 3, 200, N'Tích điểm đơn hàng #ORD-2024-8819', '2024-10-28 16:00:00');
SET IDENTITY_INSERT [dbo].[loyalty_transactions] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [notifications] (45 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[notifications] ON;
INSERT INTO [dbo].[notifications] ([notification_id], [user_id], [title], [message], [type], [reference_type], [reference_id], [is_read], [created_at]) VALUES
    (1, 1, N'Hồ sơ đăng ký Shop mới', N'Nhà vườn "Vườn Bơ Đắk Lắk" vừa nộp hồ sơ xin mở gian hàng mới trên sàn.', N'KYC', NULL, NULL, 0, '2026-10-03 04:59:47.323'),
    (2, 1, N'Hồ sơ đăng ký Shop mới', N'Doanh nghiệp "Công Ty Nhập Khẩu Toàn Cầu" vừa nộp hồ sơ xin cấp phép.', N'KYC', NULL, NULL, 0, '2026-10-03 04:59:47.323'),
    (3, 1, N'Khiếu nại phát sinh', N'Khách hàng Nguyễn Thu Hà vừa gửi khiếu nại chất lượng sầu riêng #DIS-892.', N'DISPUTE', NULL, NULL, 0, '2026-10-03 04:59:47.323'),
    (4, 3, N'Đơn hàng mới hoàn tất', N'Đơn hàng #ORD-2024-8821 đã được giao thành công và cộng vào ví doanh thu.', N'ORDER', NULL, NULL, 1, '2026-10-03 04:59:47.323'),
    (6, 3, N'📦 Đơn hàng mới #SUB-1793442400534-1-972', N'Gian hàng của bạn vừa có một đơn hàng mới trị giá 780.000 ₫. Vui lòng kiểm tra và chuẩn bị nông sản đóng gói.', N'ORDER', N'SUB_ORDER', NULL, 1, '2026-10-31 17:26:40.623'),
    (11, 3, N'Đánh giá mới (5★) từ Nguyễn Thu Hà', N'Sản phẩm ''Dâu Tây Giống New Zealand Đà Lạt'' vừa nhận được đánh giá 5 sao. Hãy vào xem và phản hồi khách hàng nhé!', N'ORDER', N'REVIEW', 7, 1, '2026-11-03 02:40:20.773'),
    (12, 16, N'Đặt hàng thành công #35', N'Đơn hàng của bạn trị giá 0₫ đã được Gốc Vườn tiếp nhận và chuyển đến nhà vườn chuẩn bị.', N'ORDER', N'ORDER', 35, 1, '2026-11-04 02:15:51.767'),
    (13, 16, N'Đặt hàng thành công #36', N'Đơn hàng của bạn trị giá 0₫ đã được Gốc Vườn tiếp nhận và chuyển đến nhà vườn chuẩn bị.', N'ORDER', N'ORDER', 36, 1, '2026-11-04 02:18:34.197'),
    (14, 16, N'Đặt hàng thành công #37', N'Đơn hàng của bạn trị giá 0₫ đã được Gốc Vườn tiếp nhận và chuyển đến nhà vườn chuẩn bị.', N'ORDER', N'ORDER', 37, 1, '2026-11-04 10:01:42.237'),
    (15, 16, N'Đặt hàng thành công #38', N'Đơn hàng của bạn trị giá 0₫ đã được Gốc Vườn tiếp nhận và chuyển đến nhà vườn chuẩn bị.', N'ORDER', N'ORDER', 38, 1, '2026-11-04 10:09:08.243'),
    (16, 16, N'Đơn hàng #SUB-1793733351696-1-676 đã được giao thành công!', N'Hoa quả tươi đã được giao tận tay bạn. Hãy đánh giá chất lượng sản phẩm để chia sẻ trải nghiệm nhé!', N'ORDER', N'SUB_ORDER', 58, 1, '2026-11-04 10:28:18.213'),
    (17, 16, N'Đặt hàng thành công #39', N'Đơn hàng của bạn trị giá 0₫ đã được Gốc Vườn tiếp nhận và chuyển đến nhà vườn chuẩn bị.', N'ORDER', N'ORDER', 39, 1, '2026-11-04 10:56:33.39'),
    (18, 16, N'Đặt hàng thành công #40', N'Đơn hàng của bạn trị giá 0₫ đã được Gốc Vườn tiếp nhận và chuyển đến nhà vườn chuẩn bị.', N'ORDER', N'ORDER', 40, 1, '2026-11-04 20:40:55.293'),
    (19, 16, N'Đặt hàng thành công #41', N'Đơn hàng của bạn trị giá 0₫ đã được Gốc Vườn tiếp nhận và chuyển đến nhà vườn chuẩn bị.', N'ORDER', N'ORDER', 41, 1, '2026-11-05 01:58:43.457'),
    (20, 16, N'Đặt hàng thành công #42', N'Đơn hàng của bạn trị giá 0₫ đã được Gốc Vườn tiếp nhận và chuyển đến nhà vườn chuẩn bị.', N'ORDER', N'ORDER', 42, 1, '2026-11-05 10:30:09.783'),
    (21, 3, N'Đơn hàng mới cần đóng gói #SUB-1793849409737-1-728', N'Gian hàng Nông Trại Dâu Đà Lạt vừa nhận được đơn hàng mới #SUB-1793849409737-1-728. Vui lòng vào xác nhận và chuẩn bị đóng gói hoa quả tươi!', N'ORDER', N'SUB_ORDER', 68, 1, '2026-11-05 10:30:09.817'),
    (22, 16, N'Đặt hàng thành công #43', N'Đơn hàng của bạn trị giá 0₫ đã được Gốc Vườn tiếp nhận và chuyển đến nhà vườn chuẩn bị.', N'ORDER', N'ORDER', 43, 1, '2026-11-05 15:24:28.007'),
    (23, 3, N'Đơn hàng mới cần đóng gói #SUB-1793867067958-1-133', N'Gian hàng Nông Trại Dâu Đà Lạt vừa nhận được đơn hàng mới #SUB-1793867067958-1-133. Vui lòng vào xác nhận và chuẩn bị đóng gói hoa quả tươi!', N'ORDER', N'SUB_ORDER', 69, 1, '2026-11-05 15:24:28.04'),
    (24, 16, N'Đặt hàng thành công #44', N'Đơn hàng của bạn trị giá 0₫ đã được Gốc Vườn tiếp nhận và chuyển đến nhà vườn chuẩn bị.', N'ORDER', N'ORDER', 44, 1, '2026-11-05 15:52:09.857'),
    (25, 3, N'Đơn hàng mới cần đóng gói #SUB-1793868729796-1-580', N'Gian hàng Nông Trại Dâu Đà Lạt vừa nhận được đơn hàng mới #SUB-1793868729796-1-580. Vui lòng vào xác nhận và chuẩn bị đóng gói hoa quả tươi!', N'ORDER', N'SUB_ORDER', 70, 1, '2026-11-05 15:52:09.897'),
    (26, 16, N'Đặt hàng thành công #45', N'Đơn hàng của bạn trị giá 0₫ đã được Gốc Vườn tiếp nhận và chuyển đến nhà vườn chuẩn bị.', N'ORDER', N'ORDER', 45, 1, '2026-11-07 13:19:10.703'),
    (27, 3, N'Đơn hàng mới cần đóng gói #SUB-1794032350628-1-313', N'Gian hàng Nông Trại Dâu Đà Lạt vừa nhận được đơn hàng mới #SUB-1794032350628-1-313. Vui lòng vào xác nhận và chuẩn bị đóng gói hoa quả tươi!', N'ORDER', N'SUB_ORDER', 71, 1, '2026-11-07 13:19:10.747'),
    (28, 16, N'Đặt hàng thành công #46', N'Đơn hàng của bạn trị giá 0₫ đã được Gốc Vườn tiếp nhận và chuyển đến nhà vườn chuẩn bị.', N'ORDER', N'ORDER', 46, 1, '2026-11-07 13:20:58.313'),
    (29, 3, N'Đơn hàng mới cần đóng gói #SUB-1794032458266-1-973', N'Gian hàng Nông Trại Dâu Đà Lạt vừa nhận được đơn hàng mới #SUB-1794032458266-1-973. Vui lòng vào xác nhận và chuẩn bị đóng gói hoa quả tươi!', N'ORDER', N'SUB_ORDER', 72, 1, '2026-11-07 13:20:58.353'),
    (30, 16, N'Đặt hàng thành công #47', N'Đơn hàng của bạn trị giá 0₫ đã được Gốc Vườn tiếp nhận và chuyển đến nhà vườn chuẩn bị.', N'ORDER', N'ORDER', 47, 1, '2026-11-07 15:41:59.58'),
    (31, 3, N'Đơn hàng mới cần đóng gói #SUB-1794040919523-1-204', N'Gian hàng Nông Trại Dâu Đà Lạt vừa nhận được đơn hàng mới #SUB-1794040919523-1-204. Vui lòng vào xác nhận và chuẩn bị đóng gói hoa quả tươi!', N'ORDER', N'SUB_ORDER', 73, 1, '2026-11-07 15:41:59.623'),
    (32, 3, N'Đơn hàng #SUB-1794040919523-1-204 đã bị hủy', N'Khách hàng đã hủy đơn #SUB-1794040919523-1-204. Lý do: Thời gian giao hàng dự kiến không phù hợp. Số lượng sản phẩm đã được tự động hoàn lại kho.', N'ORDER', N'SUB_ORDER', 73, 1, '2026-11-07 15:42:23.65'),
    (33, 16, N'Đặt hàng thành công #48', N'Đơn hàng của bạn trị giá 0₫ đã được Gốc Vườn tiếp nhận và chuyển đến nhà vườn chuẩn bị.', N'ORDER', N'ORDER', 48, 1, '2026-11-07 15:42:48.363'),
    (34, 3, N'Đơn hàng mới cần đóng gói #SUB-1794040968312-1-151', N'Gian hàng Nông Trại Dâu Đà Lạt vừa nhận được đơn hàng mới #SUB-1794040968312-1-151. Vui lòng vào xác nhận và chuẩn bị đóng gói hoa quả tươi!', N'ORDER', N'SUB_ORDER', 74, 1, '2026-11-07 15:42:48.403'),
    (35, 16, N'Đặt hàng thành công #49', N'Đơn hàng của bạn trị giá 0₫ đã được Gốc Vườn tiếp nhận và chuyển đến nhà vườn chuẩn bị.', N'ORDER', N'ORDER', 49, 1, '2026-11-08 00:01:02.207'),
    (36, 3, N'Đơn hàng mới cần đóng gói #SUB-1794070862147-1-562', N'Gian hàng Nông Trại Dâu Đà Lạt vừa nhận được đơn hàng mới #SUB-1794070862147-1-562. Vui lòng vào xác nhận và chuẩn bị đóng gói hoa quả tươi!', N'ORDER', N'SUB_ORDER', 75, 1, '2026-11-08 00:01:02.237'),
    (37, 16, N'Đặt hàng thành công #50', N'Đơn hàng của bạn trị giá 0₫ đã được Gốc Vườn tiếp nhận và chuyển đến nhà vườn chuẩn bị.', N'ORDER', N'ORDER', 50, 1, '2026-11-08 00:16:08.567'),
    (38, 3, N'Đơn hàng mới cần đóng gói #SUB-1794071768527-1-145', N'Gian hàng Nông Trại Dâu Đà Lạt vừa nhận được đơn hàng mới #SUB-1794071768527-1-145. Vui lòng vào xác nhận và chuẩn bị đóng gói hoa quả tươi!', N'ORDER', N'SUB_ORDER', 76, 1, '2026-11-08 00:16:08.6'),
    (39, 16, N'Đặt hàng thành công #51', N'Đơn hàng của bạn trị giá 0₫ đã được Gốc Vườn tiếp nhận và chuyển đến nhà vườn chuẩn bị.', N'ORDER', N'ORDER', 51, 1, '2026-11-08 21:52:32.823'),
    (40, 3, N'Đơn hàng mới cần đóng gói #SUB-1794149552756-1-223', N'Gian hàng Nông Trại Dâu Đà Lạt vừa nhận được đơn hàng mới #SUB-1794149552756-1-223. Vui lòng vào xác nhận và chuẩn bị đóng gói hoa quả tươi!', N'ORDER', N'SUB_ORDER', 77, 1, '2026-11-08 21:52:32.86'),
    (41, 16, N'Đơn hàng #SUB-1794149552756-1-223 đã được giao thành công!', N'Hoa quả tươi đã được giao tận tay bạn. Hãy đánh giá chất lượng sản phẩm để chia sẻ trải nghiệm nhé!', N'ORDER', N'SUB_ORDER', 77, 1, '2026-11-09 04:42:04.463'),
    (42, 16, N'Đơn hàng #SUB-1794149552756-1-223 đã được giao thành công!', N'Hoa quả tươi đã được giao tận tay bạn. Hãy đánh giá chất lượng sản phẩm để chia sẻ trải nghiệm nhé!', N'ORDER', N'SUB_ORDER', 77, 1, '2026-11-09 04:42:05.897'),
    (43, 3, N'Cảnh báo hạn dùng: Lô LOT-202611-02', N'Sản phẩm ''Dâu Tây Giống New Zealand Đà Lạt'' (Lô LOT-202611-02, còn 2 sản phẩm) có hạn dùng đến 2026-11-14. Vui lòng kiểm tra và xử lý sớm!', N'SYSTEM', N'BATCH', NULL, 1, '2026-11-15 18:21:13.273'),
    (44, 16, N'Đặt hàng thành công #52', N'Đơn hàng của bạn trị giá 0₫ đã được Gốc Vườn tiếp nhận và chuyển đến nhà vườn chuẩn bị.', N'ORDER', N'ORDER', 52, 1, '2026-11-15 22:09:12.273'),
    (45, 3, N'Đơn hàng mới cần đóng gói #SUB-1794755352221-1-880', N'Gian hàng Nông Trại Dâu Đà Lạt vừa nhận được đơn hàng mới #SUB-1794755352221-1-880. Vui lòng vào xác nhận và chuẩn bị đóng gói hoa quả tươi!', N'ORDER', N'SUB_ORDER', 78, 0, '2026-11-15 22:09:12.28'),
    (46, 16, N'Đặt hàng thành công #53', N'Đơn hàng của bạn trị giá 0₫ đã được Gốc Vườn tiếp nhận và chuyển đến nhà vườn chuẩn bị.', N'ORDER', N'ORDER', 53, 1, '2026-11-16 08:27:28.26'),
    (47, 3, N'Đơn hàng mới cần đóng gói #SUB-1794792448215-1-215', N'Gian hàng Nông Trại Dâu Đà Lạt vừa nhận được đơn hàng mới #SUB-1794792448215-1-215. Vui lòng vào xác nhận và chuẩn bị đóng gói hoa quả tươi!', N'ORDER', N'SUB_ORDER', 79, 0, '2026-11-16 08:27:28.267'),
    (48, 3, N'Cảnh báo tồn kho thấp: Hồng Giòn Treo Gió Công Nghệ Nhật - Hộp 500g Hút Chân Không', N'Sản phẩm ''Hồng Giòn Treo Gió Công Nghệ Nhật - Hộp 500g Hút Chân Không'' sau đơn hàng vừa tạo chỉ còn lại 10 sản phẩm trong kho. Vui lòng bổ sung thêm hàng!', N'SYSTEM', N'PRODUCT', NULL, 0, '2026-11-16 08:27:28.277'),
    (49, 16, N'Đơn hàng #SUB-1794792448215-1-215 đã được giao thành công!', N'Hoa quả tươi đã được giao tận tay bạn. Hãy đánh giá chất lượng sản phẩm để chia sẻ trải nghiệm nhé!', N'ORDER', N'SUB_ORDER', 79, 1, '2026-11-16 08:34:15.32'),
    (50, 3, N'Cảnh báo hạn dùng: Lô LOT-202611-01', N'Sản phẩm ''Dâu Tây Giống New Zealand Đà Lạt'' (Lô LOT-202611-01, còn 45 sản phẩm) có hạn dùng đến 2026-11-18. Vui lòng kiểm tra và xử lý sớm!', N'SYSTEM', N'BATCH', NULL, 0, '2026-11-16 11:09:57.16');
SET IDENTITY_INSERT [dbo].[notifications] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [chat_conversations] (2 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[chat_conversations] ON;
INSERT INTO [dbo].[chat_conversations] ([conversation_id], [customer_id], [shop_id], [last_message], [last_message_at], [customer_unread_count], [shop_unread_count], [created_at]) VALUES
    (1, 10, 1, N'Chào bạn! Nông sản bên shop hái tươi mỗi sáng, bạn cần tư vấn loại nào ạ?', '2026-11-01 05:26:20.44', 1, 0, '2026-10-31 09:29:58.733'),
    (2, 16, 1, N'alo 1234', '2026-11-01 05:32:10.087', 0, 0, '2026-11-01 05:32:02.413');
SET IDENTITY_INSERT [dbo].[chat_conversations] OFF;
GO

-- ------------------------------------------------------------
-- DỮ LIỆU BẢNG: [chat_messages] (13 dòng)
-- ------------------------------------------------------------
SET IDENTITY_INSERT [dbo].[chat_messages] ON;
INSERT INTO [dbo].[chat_messages] ([message_id], [conversation_id], [sender_type], [sender_id], [message_text], [product_id], [order_id], [is_read], [created_at]) VALUES
    (1, 1, N'CUSTOMER', 10, N'Chào Shop, Dâu tây Đà Lạt đợt này quả có ngọt đậm và tươi không ạ?', 1, NULL, 1, '2026-10-31 09:14:58.74'),
    (2, 1, N'SHOP', 3, N'Dạ dâu tây bên mình vừa hái sáng nay, đóng hộp 500g đạt chuẩn VietGAP bạn nhé!', 1, NULL, 1, '2026-10-31 09:24:58.74'),
    (3, 1, N'CUSTOMER', 10, N'Chào shop! Nông sản hôm nay vừa hái còn tươi ngon không ạ? Shop có giao hỏa tốc xe lạnh không?', NULL, NULL, 1, '2026-11-01 04:23:09.347'),
    (4, 1, N'CUSTOMER', 10, N'Shop tư vấn giúp mình quả này với, mình muốn mua làm quà biếu.', 1, NULL, 1, '2026-11-01 04:23:09.41'),
    (5, 1, N'SHOP', 3, N'Chào bạn, nông sản sáng nay vừa thu hoạch tại vườn rất tươi mọng bạn nhé! Shop đóng thùng xốp đá gel giao liền ạ.', NULL, NULL, 1, '2026-11-01 04:23:09.587'),
    (6, 1, N'CUSTOMER', 10, N'Chào shop! Nông sản hôm nay vừa hái còn tươi ngon không ạ? Shop có giao hỏa tốc xe lạnh không?', NULL, NULL, 1, '2026-11-01 05:18:07.533'),
    (7, 1, N'CUSTOMER', 10, N'Shop tư vấn giúp mình quả này với, mình muốn mua làm quà biếu.', 1, NULL, 1, '2026-11-01 05:18:07.567'),
    (8, 1, N'SHOP', 3, N'Chào bạn, nông sản sáng nay vừa thu hoạch tại vườn rất tươi mọng bạn nhé! Shop đóng thùng xốp đá gel giao liền ạ.', NULL, NULL, 1, '2026-11-01 05:18:07.7'),
    (9, 1, N'CUSTOMER', 10, N'Chào shop! Nông sản hôm nay vừa hái còn tươi ngon không ạ? Shop có giao hỏa tốc xe lạnh không?', NULL, NULL, 1, '2026-11-01 05:23:20.043'),
    (10, 1, N'CUSTOMER', 10, N'Shop tư vấn giúp mình quả này với, mình muốn mua làm quà biếu.', 1, NULL, 1, '2026-11-01 05:23:20.083'),
    (11, 1, N'SHOP', 3, N'Chào bạn, nông sản sáng nay vừa thu hoạch tại vườn rất tươi mọng bạn nhé! Shop đóng thùng xốp đá gel giao liền ạ.', NULL, NULL, 1, '2026-11-01 05:23:20.243'),
    (12, 1, N'SHOP', 3, N'Chào bạn! Nông sản bên shop hái tươi mỗi sáng, bạn cần tư vấn loại nào ạ?', NULL, NULL, 0, '2026-11-01 05:26:20.44'),
    (13, 2, N'CUSTOMER', 16, N'alo 1234', 3, NULL, 1, '2026-11-01 05:32:10.087');
SET IDENTITY_INSERT [dbo].[chat_messages] OFF;
GO

