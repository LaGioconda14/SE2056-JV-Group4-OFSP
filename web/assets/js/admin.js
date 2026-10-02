
const i18nDict = {
    vi: {
        // Brand & Subtitle
        "brand_badge": "PLATFORM ADMIN",
        "brand_subtitle": "Platform Admin",
        
        // Sidebar Sections
        "nav_sec_core": "CORE",
        "nav_dashboard": "Overview Dashboard",
        "nav_users": "Users & Permissions",
        "nav_shops_apps": "Shops & Applications",
        "nav_categories": "Global Categories",
        "nav_products": "Products",
        
        "nav_sec_gov": "GOVERNANCE",
        "nav_orders": "Orders & Deliveries",
        "nav_moderation": "Product Moderation",
        "nav_disputes": "Disputes & Refunds",
        "nav_vouchers": "Platform Vouchers",
        
        "nav_sec_finance": "FINANCE & SETTINGS",
        "nav_payments": "Payments & Transactions",
        "nav_settlements": "Vendor Settlement & Fees",
        "nav_analytics": "Platform Analytics",
        "nav_settings": "System Settings",
        "user_role": "Platform Admin",
        "sign_out": "Sign Out",
        
        // Topbar
        "search_placeholder": "Tìm kiếm gian hàng, hồ sơ KYC, khách mua, khiếu nại...",
        "status_pill": "Trạng thái sàn: Hoạt động tốt (248 Gian hàng)",
        "create_campaign": "Tạo Chiến Dịch",
        "view_marketplace": "Xem Sàn Khách Hàng",
        
        // Dashboard Title & Actions
        "telemetry_title": "● TRUNG TÂM ĐIỀU HÀNH NỀN TẢNG",
        "telemetry_detail": "• Hệ thống thanh toán: 99.98% Ổn định • Phí hoa hồng sàn: 8.0%",
        "dash_title": "Báo Cáo Tổng Quan Nền Tảng",
        "dash_desc": "Giám sát toàn diện doanh thu sàn (GMV), mạng lưới đối tác nhà vườn, phí hoa hồng thu về và xử lý khiếu nại.",
        "btn_filter_time": "Tháng này (T10/2024)",
        "btn_refresh": "Làm Mới Số Liệu",
        "btn_export": "Xuất Báo Cáo Tài Chính",
        
        // 5 KPI Cards
        "kpi_gmv_label": "TỔNG GMV TOÀN SÀN",
        "kpi_gmv_sub": "Mục tiêu tháng: $1.8M",
        "kpi_gmv_grow": "+18.4% so với tháng trước",
        
        "kpi_comm_label": "HOA HỒNG THỰC THU (NET)",
        "kpi_comm_sub": "+14.2% so với tháng trước",
        "kpi_comm_rate": "(Tỷ lệ phí sàn 8.0%)",
        
        "kpi_vendor_label": "GIAN HÀNG & NHÀ VƯỜN",
        "kpi_vendor_verified": "240 Đã duyệt",
        "kpi_vendor_pending": "8 Chờ duyệt KYC",
        "kpi_vendor_avg": "Doanh thu TB / shop",
        
        "kpi_buyer_label": "NGƯỜI MUA TRÊN SÀN",
        "kpi_buyer_new": "khách mới tháng này",
        "kpi_buyer_repeat": "Tỷ lệ mua lại",
        
        "kpi_skew_label": "CẦN XỬ LÝ NGAY",
        "kpi_skew_kyc": "Hồ sơ mở shop chờ duyệt",
        "kpi_skew_dispute": "Khiếu nại chưa xử lý",
        
        // Direct Orchestration
        "orch_title": "Thao Tác Nhanh Quản Trị:",
        "orch_sub": "Các lệnh điều phối nền tảng trực tiếp",
        "orch_btn_shops": "Duyệt Hồ Sơ Shop (8)",
        "orch_btn_voucher": "Tạo Voucher Sàn",
        "orch_btn_payout": "Duyệt Quyết Toán Tuần",
        "orch_btn_notice": "Phát Thông Báo Toàn Sàn",
        
        // Charts
        "chart_gmv_title": "Biểu Đồ Tăng Trưởng GMV & Doanh Thu Phí Sàn",
        "chart_gmv_desc": "Tổng giá trị giao dịch và doanh thu hoa hồng sàn thu được (Tháng 10/2024)",
        "chart_callout_title": "ĐỈNH ĐIỂM LỄ HỘI MÙA THU",
        "chart_share_title": "Tỷ Trọng Doanh Số Ngành Hàng",
        "chart_share_desc": "Cơ cấu sức mua theo chủng loại trái cây",
        "chart_center_label": "NGÀNH HÀNG",
        "cat_1": "Cam, Bưởi & Táo Lê",
        "cat_2": "Nhiệt Đới & Đặc Sản",
        "cat_3": "Dâu Tây & Quả Mọng",
        "cat_4": "Dưa Lưới & Nho",
        "cat_5": "Hộp Quà Biếu Tặng",
        
        // Lower Grid: Shop KYC
        "sec_kyc_title": "Hồ Sơ Nhà Vườn Chờ Duyệt (KYC)",
        "sec_kyc_desc": "Các hợp tác xã và nhà vườn đang đợi cấp phép gian hàng",
        "view_all_shops": "Xem tất cả 248 shop",
        "th_shop": "TÊN SHOP / NHÀ VƯỜN",
        "th_type": "LOẠI HÌNH",
        "th_specialty": "NÔNG SẢN CHÍNH",
        "th_cert": "CHỨNG NHẬN",
        "th_actions": "THAO TÁC",
        "btn_approve": "Duyệt",
        "btn_inspect": "Xem hồ sơ",
        "btn_request_docs": "Bổ sung giấy tờ",
        
        // Lower Grid: Disputes
        "sec_dispute_title": "Trọng Tài Khiếu Nại Sàn",
        "sec_dispute_desc": "Các ca tranh chấp chất lượng cần Admin ra phán quyết",
        "badge_open_cases": "3 Ca đang mở",
        "btn_refund": "Hoàn tiền cho khách",
        "btn_mediate": "Hòa giải",
        "btn_inspect_logs": "Xem nhật ký",
        "payout_next": "Kỳ chuyển tiền cho Shop tiếp theo:",
        "payout_volume": "Khối lượng quyết toán:",
        "friday": "Thứ Sáu, 04/10",
        
        // Subpage Shops
        "shops_page_title": "Quản Trị Gian Hàng & Nhà Vườn",
        "shops_page_desc": "Quản lý danh sách nhà vườn, xét duyệt hồ sơ mở shop (KYC), cài đặt % hoa hồng và chế tài vi phạm.",
        "btn_invite": "Mời Đối Tác Mới",
        "btn_filter_status_all": "Lọc: Tất Cả Trạng Thái",
        "stat_total_shops": "TỔNG SỐ GIAN HÀNG",
        "stat_pending_kyc": "HỒ SƠ CHỜ DUYỆT",
        "stat_comm_rate": "HOA HỒNG TRUNG BÌNH",
        "stat_suspended": "SHOP ĐANG KHÓA",
        "directory_title": "Danh Sách Gian Hàng & Hợp Tác Xã",
        "directory_desc": "Toàn bộ mạng lưới nhà vườn và đối tác phân phối đã kết nối sàn",
        "th_shop_partner": "GIAN HÀNG / ĐỐI TÁC",
        "th_province": "TỈNH THÀNH",
        "th_product_specialty": "NÔNG SẢN ĐẶC TRƯNG",
        "th_commission_rate": "TỶ LỆ HOA HỒNG",
        "th_action": "THAO TÁC",

        // Subpage Users
        "users_page_title": "Tài Khoản & Phân Quyền Hệ Thống",
        "users_page_desc": "Quản lý và phân cấp tài khoản theo vai trò: Ban Quản Trị, Nhân Sự Sàn, Chủ Gian Hàng, Tài Xế Chuỗi Lạnh và Khách Hàng.",
        "btn_invite_member": "Thêm / Phân Quyền Thành Viên",
        "stat_role_admin_staff": "QUẢN TRỊ & NHÂN SỰ",
        "stat_role_admin_staff_sub": "Platform Admin & Điều hành sàn",
        "stat_role_shop_owner": "CHỦ GIAN HÀNG",
        "stat_role_shop_owner_sub": "Đối tác cung ứng & kho nông sản",
        "stat_role_driver": "TÀI XẾ CHUỖI LẠNH",
        "stat_role_driver_sub": "Đội vận chuyển FreshExpress",
        "stat_role_customer": "KHÁCH MUA HÀNG",
        "stat_role_customer_sub": "Người tiêu dùng & thành viên",
        "tab_role_all": "Tất Cả",
        "tab_role_admin_staff": "👑 Quản Trị & Nhân Sự",
        "tab_role_shop_owner": "🏪 Chủ Gian Hàng",
        "tab_role_driver": "🚚 Tài Xế Vận Chuyển",
        "tab_role_customer": "🛒 Khách Mua Sắm",
        "th_user": "NGƯỜI DÙNG & LIÊN HỆ",
        "th_role": "VAI TRÒ HỆ THỐNG",
        "th_business_info": "NGHIỆP VỤ LIÊN KẾT",
        "th_tier": "PHÂN CẤP / HẠNG",
        "th_status": "TRẠNG THÁI",
        "th_actions": "THAO TÁC",
        "filter_placeholder_user": "Tìm theo tên, email, số điện thoại...",
        "btn_assign_role": "Phân Quyền",
        "modal_role_title": "Phân Quyền & Cấp Vai Trò Tài Khoản",
        "modal_invite_title": "Thêm Mới / Mời Thành Viên Sàn",

        // Subpage Categories
        "categories_page_title": "Danh Mục Nông Sản & Trái Cây Toàn Sàn",
        "categories_page_desc": "Phân chia cây ăn trái theo vụ mùa, dải nhiệt độ bảo quản lạnh và phân luồng kho lưu trữ tiêu chuẩn.",
        "btn_add_category": "Thêm Danh Mục Mới",
        "th_cat_name": "TÊN DANH MỤC",
        "th_active_skus": "MẶT HÀNG ĐANG BÁN",
        "th_temp_range": "NHIỆT ĐỘ LẠNH",
        "th_storage": "KHO LƯU TRỮ ĐỀ XUẤT",

        // Subpage Products / Moderation
        "products_page_title": "Kiểm Duyệt Nông Sản & Tồn Kho Sàn",
        "products_page_desc": "Giám sát định danh SKU hoa quả, xuất xứ chứng nhận, giá bán niêm yết và mức độ tươi ngon.",
        "btn_add_sku": "Thêm Mã Nông Sản",
        "th_sku": "MÃ NÔNG SẢN",
        "th_category": "NGÀNH HÀNG",
        "th_price": "GIÁ BÁN / KG",
        "th_cold_storage": "KHO BẢO QUẢN",
        "th_stock": "TỒN KHO",

        // Subpage Orders
        "orders_page_title": "Luồng Đơn Hàng & Vận Hành Chuỗi Lạnh",
        "orders_page_desc": "Giám sát thời gian thực các đơn hàng mua hoa quả, chuẩn bị chuỗi lạnh và điều phối đối tác giao vận.",
        "btn_filter_status": "Lọc Trạng Thái",
        "btn_export_manifest": "Xuất Bảng Kê Vận Đơn",
        "th_order_id": "MÃ ĐƠN HÀNG",
        "th_client": "KHÁCH HÀNG",
        "th_items_spec": "MẶT HÀNG & TIÊU CHUẨN LẠNH",
        "th_total": "TỔNG TIỀN",
        "btn_track": "Hành trình",
        "btn_verify": "Kiểm định",

        // Subpage Vouchers
        "vouchers_page_title": "Chiến Dịch & Voucher Trợ Giá Toàn Sàn",
        "vouchers_page_desc": "Quản lý mã giảm giá toàn sàn, ngân sách trợ giá phí vận chuyển và lễ hội mùa vụ.",
        "btn_create_voucher": "Tạo Voucher Toàn Sàn",
        "th_voucher_code": "MÃ VOUCHER",
        "th_voucher_type": "LOẠI ƯU ĐÃI",
        "th_discount": "MỨC GIẢM",
        "th_min_spend": "ĐƠN TỐI THIỂU",
        "th_usage_limit": "ĐÃ DÙNG / GIỚI HẠN",
        "th_sponsor": "NGUỒN TÀI TRỢ",

        // Subpage Disputes
        "disputes_page_title": "Giải Quyết Khiếu Nại & Tranh Chấp Sàn",
        "disputes_page_desc": "Tòa trọng tài độc lập xử lý tranh chấp chất lượng hoa quả, đứt gãy bảo quản lạnh và hoàn tiền giữa người mua và nhà vườn.",
        "th_dispute_id": "MÃ KHIẾU NẠI",
        "th_buyer": "NGƯỜI MUA",
        "th_shop_involved": "SHOP LIÊN QUAN",
        "th_claim_reason": "LÝ DO KHIẾU NẠI",
        "th_amount": "SỐ TIỀN",
        "th_decision": "PHÁN QUYẾT",
        "btn_accept_refund": "Duyệt hoàn tiền",
        "btn_reject_claim": "Từ chối khiếu nại",
        "btn_review_evidence": "Xem bằng chứng",

        // Subpage Settlements
        "settlements_page_title": "Đối Soát & Quyết Toán Dòng Tiền",
        "settlements_page_desc": "Đối chiếu doanh thu bán hàng, khấu trừ phí hoa hồng sàn 8% và giải ngân về tài khoản ngân hàng của các shop.",
        "btn_release_payouts": "Duyệt Lệnh Giải Ngân Tuần (102.5 Tr ₫)",
        "th_cycle_id": "KỲ ĐỐI SOÁT",
        "th_period": "KỲ HẠN",
        "th_total_sales": "TỔNG DOANH SỐ SHOP",
        "th_commission_withheld": "HOA HỒNG KHẤU TRỪ",
        "th_net_payout": "THỰC CHUYỂN SHOP",
        "th_vendors_included": "SỐ SHOP THỤ HƯỞNG"
    },
    en: {
        // Brand & Subtitle
        "brand_badge": "PLATFORM",
        "brand_subtitle": "Multi-Vendor System Admin",
        
        // Sidebar Sections
        "nav_sec_core": "PLATFORM CORE",
        "nav_dashboard": "Overview Dashboard",
        "nav_users": "Users & Permissions",
        "nav_shops_apps": "Shops & Applications",
        "nav_categories": "Categories",
        "nav_products": "Products",
        
        "nav_sec_gov": "ORDER & GOVERNANCE",
        "nav_orders": "Orders",
        "nav_moderation": "Product Moderation",
        "nav_disputes": "Disputes & Refunds",
        "nav_vouchers": "Platform Vouchers",
        
        "nav_sec_finance": "FINANCE & REPORTING",
        "nav_payments": "Payments & Transactions",
        "nav_settlements": "Vendor Payouts & Fees",
        "nav_analytics": "Platform Analytics",
        "nav_settings": "Platform Settings",
        "user_role": "Platform Administrator",
        "sign_out": "Sign Out",
        
        // Topbar
        "search_placeholder": "Search shops, vendor KYC, buyers, disputes...",
        "status_pill": "Platform Status: Healthy (248 Active Vendors)",
        "create_campaign": "Create Campaign",
        "view_marketplace": "View Marketplace",
        
        // Dashboard Title & Actions
        "telemetry_title": "● PLATFORM CONTROL CENTER",
        "telemetry_detail": "• Marketplace Engine: 99.98% Uptime • Commission Take-Rate: 8.0%",
        "dash_title": "E-Commerce Platform Overview",
        "dash_desc": "High-level platform governance, gross merchandise volume (GMV), vendor network expansion, platform commission, and dispute moderation.",
        "btn_filter_time": "This Month (Oct 2024)",
        "btn_refresh": "Refresh Telemetry",
        "btn_export": "Export Financial Statement",
        
        // 5 KPI Cards
        "kpi_gmv_label": "TOTAL PLATFORM GMV",
        "kpi_gmv_sub": "Run-rate target: 1.5 Billion ₫",
        "kpi_gmv_grow": "+18.4% vs last month",
        
        "kpi_comm_label": "PLATFORM NET COMMISSION",
        "kpi_comm_sub": "+14.2% vs last month",
        "kpi_comm_rate": "(8% base take rate)",
        
        "kpi_vendor_label": "ACTIVE SHOPS & FARMS",
        "kpi_vendor_verified": "240 Verified",
        "kpi_vendor_pending": "8 Pending KYC",
        "kpi_vendor_avg": "Avg Monthly Revenue",
        
        "kpi_buyer_label": "PLATFORM BUYERS",
        "kpi_buyer_new": "new buyers this month",
        "kpi_buyer_repeat": "Repeat Buyer Rate",
        
        "kpi_skew_label": "ACTION REQUIRED",
        "kpi_skew_kyc": "Shop KYC Approval",
        "kpi_skew_dispute": "Open Disputes",
        
        // Direct Orchestration
        "orch_title": "Platform Admin Commands:",
        "orch_sub": "Rapid platform administration actions",
        "orch_btn_shops": "Review Shop Approvals (8)",
        "orch_btn_voucher": "Create Platform Voucher",
        "orch_btn_payout": "Release Weekly Payouts",
        "orch_btn_notice": "Broadcast System Notice",
        
        // Charts
        "chart_gmv_title": "Platform GMV & Net Commission Trajectory",
        "chart_gmv_desc": "Gross transaction volume and platform earnings velocity (Oct 2024)",
        "chart_callout_title": "AUTUMN FRUIT FESTIVAL PEAK",
        "chart_share_title": "Platform Category Share",
        "chart_share_desc": "Marketplace volume by fruit category",
        "chart_center_label": "SECTORS",
        "cat_1": "Citrus & Orchard",
        "cat_2": "Tropical & Exotic",
        "cat_3": "Organic Berries",
        "cat_4": "Melons & Grapes",
        "cat_5": "Organic Gift Boxes",
        
        // Lower Grid: Shop KYC
        "sec_kyc_title": "Pending Shop KYC & Onboarding Applications",
        "sec_kyc_desc": "Farms and fruit merchants awaiting platform credential verification",
        "view_all_shops": "View All Shops",
        "th_shop": "SHOP / FARM NAME",
        "th_type": "TYPE",
        "th_specialty": "PRODUCE SPECIALTY",
        "th_cert": "CERTIFICATION",
        "th_actions": "ACTIONS",
        "btn_approve": "Approve",
        "btn_inspect": "Inspect",
        "btn_request_docs": "Request Docs",
        
        // Lower Grid: Disputes
        "sec_dispute_title": "Escalated Platform Disputes",
        "sec_dispute_desc": "Refund claims requiring System Admin mediation",
        "badge_open_cases": "Open Cases",
        "btn_refund": "Refund Buyer",
        "btn_mediate": "Mediate",
        "btn_inspect_logs": "Inspect Logs",
        "payout_next": "Next Vendor Payout Cycle:",
        "payout_volume": "Settlement Volume:",
        "friday": "Friday, Oct 4",
        
        // Subpage Shops
        "shops_page_title": "Vendor & Shop Governance",
        "shops_page_desc": "Manage orchard suppliers, approve new merchant registrations (KYC), configure commission rates, and enforce platform standards.",
        "btn_invite": "Invite Orchard Partner",
        "btn_filter_status_all": "Filter: All Statuses",
        "stat_total_shops": "TOTAL MERCHANTS",
        "stat_pending_kyc": "PENDING KYC APPROVAL",
        "stat_comm_rate": "AVG COMMISSION RATE",
        "stat_suspended": "SUSPENDED SHOPS",
        "directory_title": "Merchant Directory",
        "directory_desc": "Complete list of verified fruit stores and farm co-ops on the platform",
        "th_shop_partner": "SHOP / PARTNER",
        "th_province": "PROVINCE",
        "th_product_specialty": "SPECIALTY PRODUCE",
        "th_commission_rate": "COMMISSION RATE",
        "th_action": "ACTION",

        // Subpage Users
        "users_page_title": "Accounts & Role Permissions",
        "users_page_desc": "Manage and govern accounts categorized by roles: Platform Admins, Staff, Shop Owners, Cold-Chain Drivers, and Customers.",
        "btn_invite_member": "Add / Assign Member",
        "stat_role_admin_staff": "ADMIN & STAFF",
        "stat_role_admin_staff_sub": "Platform Admin & Operations Staff",
        "stat_role_shop_owner": "SHOP OWNERS",
        "stat_role_shop_owner_sub": "Orchard suppliers & inventory co-ops",
        "stat_role_driver": "COLD-CHAIN DRIVERS",
        "stat_role_driver_sub": "FreshExpress logistics fleet",
        "stat_role_customer": "RETAIL BUYERS",
        "stat_role_customer_sub": "Loyalty buyers & consumers",
        "tab_role_all": "All Accounts",
        "tab_role_admin_staff": "👑 Admin & Staff",
        "tab_role_shop_owner": "🏪 Shop Owners",
        "tab_role_driver": "🚚 Drivers",
        "tab_role_customer": "🛒 Retail Buyers",
        "th_user": "USER & CONTACT",
        "th_role": "SYSTEM ROLE",
        "th_business_info": "BUSINESS CONTEXT",
        "th_tier": "TIER / LEVEL",
        "th_status": "STATUS",
        "th_actions": "ACTIONS",
        "filter_placeholder_user": "Search by name, email, phone...",
        "btn_assign_role": "Assign Role",
        "modal_role_title": "Account Role & Permissions",
        "modal_invite_title": "Add / Invite Platform Member",

        // Subpage Categories
        "categories_page_title": "Produce Categories",
        "categories_page_desc": "Organize orchard categories, cold storage specifications, and temperature threshold ranges.",
        "btn_add_category": "Add Category",
        "th_cat_name": "CATEGORY NAME",
        "th_active_skus": "ACTIVE SKUS",
        "th_temp_range": "TEMP RANGE",
        "th_storage": "RECOMMENDED STORAGE",

        // Subpage Products / Moderation
        "products_page_title": "Fruit Inventory & Product Catalog",
        "products_page_desc": "Manage perishable inventory stocks, SKU pricing, cold storage locations, and freshness ratings.",
        "btn_add_sku": "Add New Fruit SKU",
        "th_sku": "FRUIT SKU",
        "th_category": "CATEGORY",
        "th_price": "PRICE / KG",
        "th_cold_storage": "COLD STORAGE",
        "th_stock": "STOCK LEVEL",

        // Subpage Orders
        "orders_page_title": "Orders & Fulfillment Stream",
        "orders_page_desc": "Live stream of incoming buyer orders, cold-chain packaging status, and dispatch telemetry.",
        "btn_filter_status": "Filter Status",
        "btn_export_manifest": "Export Manifest",
        "th_order_id": "ORDER ID",
        "th_client": "CLIENT",
        "th_items_spec": "ITEMS & COLD SPEC",
        "th_total": "TOTAL",
        "btn_track": "Track",
        "btn_verify": "Verify",

        // Subpage Vouchers
        "vouchers_page_title": "Platform Campaigns & Subsidized Vouchers",
        "vouchers_page_desc": "Manage site-wide promotional discount codes, free shipping subsidies, and seasonal fruit festivals.",
        "btn_create_voucher": "Create Platform Voucher",
        "th_voucher_code": "VOUCHER CODE",
        "th_voucher_type": "TYPE",
        "th_discount": "DISCOUNT",
        "th_min_spend": "MIN SPEND",
        "th_usage_limit": "USAGE / LIMIT",
        "th_sponsor": "SPONSOR",

        // Subpage Disputes
        "disputes_page_title": "Dispute & Refund Moderation",
        "disputes_page_desc": "Independent platform arbitration for quality disputes, delivery breaches, and refund claims between buyers and merchants.",
        "th_dispute_id": "DISPUTE ID",
        "th_buyer": "BUYER",
        "th_shop_involved": "SHOP INVOLVED",
        "th_claim_reason": "CLAIM REASON",
        "th_amount": "AMOUNT",
        "th_decision": "DECISION",
        "btn_accept_refund": "Accept Refund",
        "btn_reject_claim": "Reject Claim",
        "btn_review_evidence": "Review Evidence",

        // Subpage Settlements
        "settlements_page_title": "Vendor Settlements & Payouts",
        "settlements_page_desc": "Reconcile platform sales, calculate commission deductions, and release payouts to vendor bank accounts.",
        "btn_release_payouts": "Process Cycle Payouts ($84.2k)",
        "th_cycle_id": "CYCLE ID",
        "th_period": "PERIOD",
        "th_total_sales": "TOTAL VENDOR SALES",
        "th_commission_withheld": "COMMISSION WITHHELD",
        "th_net_payout": "NET PAYOUT",
        "th_vendors_included": "VENDORS INCLUDED"
    }
};

window.setLanguage = function(lang) {
    if (!i18nDict[lang]) lang = 'vi';
    localStorage.setItem('admin_lang', lang);
    
    // Update button display
    const labelEl = document.getElementById('currentLangLabel');
    const flagEl = document.getElementById('currentLangFlag');
    if (labelEl) labelEl.textContent = (lang === 'vi') ? 'VIE' : 'ENG';
    if (flagEl) flagEl.textContent = (lang === 'vi') ? '🇻🇳' : '🇬🇧';
    
    // Mark active in dropdown
    document.querySelectorAll('.lang-option').forEach(opt => {
        if (opt.getAttribute('data-lang') === lang) {
            opt.classList.add('active');
        } else {
            opt.classList.remove('active');
        }
    });

    const dict = i18nDict[lang];
    
    // Translate textContent
    document.querySelectorAll('[data-i18n]').forEach(el => {
        const key = el.getAttribute('data-i18n');
        if (dict[key]) {
            el.textContent = dict[key];
        }
    });

    // Translate placeholder
    document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
        const key = el.getAttribute('data-i18n-placeholder');
        if (dict[key]) {
            el.setAttribute('placeholder', dict[key]);
        }
    });
};

document.addEventListener('DOMContentLoaded', function () {
    // 1. Initialize language (Default: vi)
    const currentLang = localStorage.getItem('admin_lang') || 'vi';
    window.setLanguage(currentLang);

    // 2. Initialize Charts
    const revenueCtx = document.getElementById('revenueVelocityChart');
    if (revenueCtx && typeof Chart !== 'undefined') {
        const gradient = revenueCtx.getContext('2d').createLinearGradient(0, 0, 0, 220);
        gradient.addColorStop(0, 'rgba(21, 128, 61, 0.35)');
        gradient.addColorStop(1, 'rgba(21, 128, 61, 0.01)');

        const gmvLabels = window.platformChartLabels || ['01 May', '05 May', '10 May', '15 May', '20 May', '24 May', '30 May'];
        const gmvValues = window.platformGmvData || [8, 18, 28, 42, 48, 55, 47];
        const commValues = window.platformCommData || [2, 3.5, 5, 7, 8, 9.5, 9.2];

        new Chart(revenueCtx, {
            type: 'line',
            data: {
                labels: gmvLabels,
                datasets: [
                    {
                        label: 'GMV Sàn',
                        data: gmvValues,
                        borderColor: '#15803d',
                        backgroundColor: gradient,
                        borderWidth: 2.5,
                        fill: true,
                        tension: 0.4,
                        pointRadius: [0, 0, 0, 0, 0, 5, 0],
                        pointBackgroundColor: '#15803d',
                        pointBorderColor: '#ffffff',
                        pointBorderWidth: 2
                    },
                    {
                        label: 'Hoa Hồng 5%',
                        data: commValues,
                        borderColor: '#ea580c',
                        borderWidth: 2,
                        borderDash: [4, 4],
                        fill: false,
                        tension: 0.4,
                        pointRadius: 0
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    x: {
                        grid: { display: false },
                        ticks: { color: '#94a3b8', font: { size: 11, family: "'Plus Jakarta Sans', sans-serif" } }
                    },
                    y: {
                        min: 0,
                        max: 60,
                        grid: { color: '#f8fafc' },
                        ticks: {
                            stepSize: 10,
                            color: '#94a3b8',
                            font: { size: 10, family: "'Plus Jakarta Sans', sans-serif" },
                            callback: function(val) { return '₫' + val + 'M'; }
                        }
                    }
                }
            }
        });
    }

    const categoryCtx = document.getElementById('categoryYieldChart');
    if (categoryCtx && typeof Chart !== 'undefined') {
        const catLabels = window.platformCatLabels || ['Trái Cây Nhập Khẩu', 'Nông Sản & Nội Địa', 'Giỏ Quà Tặng & Hộp Biếu', 'Trái Cây Sấy & Snack Mộc'];
        const catData = window.platformCatData || [38, 32, 20, 10];

        new Chart(categoryCtx, {
            type: 'doughnut',
            data: {
                labels: catLabels,
                datasets: [{
                    data: catData,
                    backgroundColor: ['#15803d', '#22c55e', '#ea580c', '#fb923c'],
                    borderWidth: 3,
                    borderColor: '#ffffff'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '75%',
                plugins: {
                    legend: { display: false }
                }
            }
        });
    }

    // Client-side quick filter for users table
    const searchInput = document.getElementById('userSearchInput');
    if (searchInput) {
        searchInput.addEventListener('input', function() {
            const query = this.value.toLowerCase().trim();
            const rows = document.querySelectorAll('#usersTableBody tr');
            rows.forEach(row => {
                const text = row.textContent.toLowerCase();
                row.style.display = text.includes(query) ? '' : 'none';
            });
        });
    }

    // Client-side quick filter for shops table
    const shopSearchInput = document.getElementById('shopSearchInput');
    if (shopSearchInput) {
        shopSearchInput.addEventListener('input', function() {
            const query = this.value.toLowerCase().trim();
            const rows = document.querySelectorAll('#shopsTableBody tr');
            rows.forEach(row => {
                const text = row.textContent.toLowerCase();
                row.style.display = text.includes(query) ? '' : 'none';
            });
        });
    }

    // Check all shops checkbox
    const checkAllShops = document.getElementById('checkAllShops');
    if (checkAllShops) {
        checkAllShops.addEventListener('change', function() {
            const checkboxes = document.querySelectorAll('#shopsTableBody input[type="checkbox"]');
            checkboxes.forEach(cb => cb.checked = checkAllShops.checked);
        });
    }

    // Client-side quick filter for orders table
    const orderSearchInput = document.getElementById('orderSearchInput');
    if (orderSearchInput) {
        orderSearchInput.addEventListener('input', function() {
            const query = this.value.toLowerCase().trim();
            const rows = document.querySelectorAll('#ordersTableBody tr');
            rows.forEach(row => {
                const text = row.textContent.toLowerCase();
                row.style.display = text.includes(query) ? '' : 'none';
            });
        });
    }
});

// Modal helper for role assignment
function openAssignRoleModal(userId, userName, currentRole) {
    const idInput = document.getElementById('modalUserId');
    const nameDisplay = document.getElementById('modalUserNameDisplay');
    const roleSelect = document.getElementById('modalUserRoleSelect');
    if (idInput) idInput.value = userId;
    if (nameDisplay) nameDisplay.textContent = userName + ' (ID: #' + userId + ')';
    if (roleSelect) roleSelect.value = currentRole;
    
    const modalEl = document.getElementById('assignRoleModal');
    if (modalEl && typeof bootstrap !== 'undefined') {
        const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
        modal.show();
    }
}

