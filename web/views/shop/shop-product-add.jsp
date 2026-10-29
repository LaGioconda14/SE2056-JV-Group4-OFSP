<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Thêm Mới Sản Phẩm Nông Sản - FreshFruit Kênh Người Bán</title>

    <!-- Head chung: meta, font, Font Awesome, Tailwind, shop-layout.css/js -->
    <jsp:include page="/views/shop/layout/head.jsp" />

    <!-- CSS riêng của trang -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-product-add.css">
</head>
<body class="bg-[#f8fafc] text-[#0f172a]">

    <!-- ========================================================
         SIDEBAR + HEADER DÙNG CHUNG (views/shop/layout/)
         ======================================================== -->
    <jsp:include page="/views/shop/layout/sidebar.jsp">
        <jsp:param name="active" value="add" />
    </jsp:include>
    <jsp:include page="/views/shop/layout/header.jsp" />

    <!-- ========================================================
         3. MAIN CONTENT: ADD PRODUCT SCREEN
         ======================================================== -->
    <main class="shop-main-wrapper">
        <div class="shop-content-container">

            <!-- Breadcrumb & Top Bar -->
            <div class="flex flex-col gap-2 mb-5">
                <nav class="flex items-center gap-2 text-xs text-slate-500 font-medium">
                    <span>Kênh Người Bán</span>
                    <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                    <span>Sản phẩm & Kho</span>
                    <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                    <span class="text-emerald-700 font-semibold">Thêm mới nông sản</span>
                </nav>

                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mt-1">
                    <div>
                        <h1 class="text-2xl font-black text-slate-900 tracking-tight">Thêm Mới Sản Phẩm Nông Sản</h1>
                        <p class="text-xs text-slate-500 mt-0.5">Khai báo quy cách, nguồn gốc vườn hái và tiêu chuẩn kiểm định độ tươi ngon.</p>
                    </div>

                    <!-- Top Action Buttons -->
                    <div class="flex items-center flex-wrap gap-3">
                        <span class="px-3 py-1.5 rounded-full bg-indigo-50 border border-indigo-200 text-indigo-700 font-semibold text-xs flex items-center gap-1.5">
                            <i class="fa-solid fa-shield-check text-indigo-600"></i>
                            Mẫu chuẩn hóa VietGAP / OCOP
                        </span>
                        <button type="button" onclick="submitForm('draft')" class="px-4 py-2 bg-white border border-slate-300 text-slate-700 hover:bg-slate-50 rounded-lg text-xs font-bold transition shadow-sm">
                            Lưu nháp
                        </button>
                        <button type="button" onclick="submitForm('publish')" class="px-5 py-2 bg-emerald-700 hover:bg-emerald-800 text-white rounded-lg text-xs font-bold transition shadow-sm flex items-center gap-2">
                            <i class="fa-solid fa-paper-plane text-xs"></i>
                            <span>Phát hành ngay lên sàn</span>
                        </button>
                    </div>
                </div>
            </div>

            <!-- Error Notification if any -->
            <c:if test="${not empty errorMessage}">
                <div class="mb-5 bg-red-50 border border-red-200 text-red-800 px-4 py-3 rounded-xl flex items-center justify-between shadow-sm">
                    <div class="flex items-center gap-3">
                        <i class="fa-solid fa-circle-exclamation text-red-600 text-lg"></i>
                        <span class="text-sm font-semibold">${errorMessage}</span>
                    </div>
                    <button type="button" onclick="this.parentElement.remove()" class="text-red-500 hover:text-red-800">
                        <i class="fa-solid fa-xmark"></i>
                    </button>
                </div>
            </c:if>

            <!-- ========================================================
                 4. ADD PRODUCT FORM (2 COLUMNS)
                 ======================================================== -->
            <form id="addProductForm" action="${pageContext.request.contextPath}/shop/product/add" method="POST">
                <input type="hidden" name="action" id="formAction" value="publish">
                <input type="hidden" name="storageTemp" id="inputStorageTemp" value="Kho lạnh 2°C - 8°C">
                <input type="hidden" name="unit" id="inputUnit" value="Hộp (500g - 1kg)">

                <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">

                    <!-- ====================================================
                         LEFT COLUMN (8 COLS): PRODUCT DETAILS & PRICING
                         ==================================================== -->
                    <div class="lg:col-span-8 space-y-6">

                        <!-- SECTION 1: THÔNG TIN CHUNG & NGUỒN GỐC XUẤT XỨ -->
                        <div class="form-section-card">
                            <div class="form-section-header">
                                <div class="flex items-center gap-3">
                                    <div class="section-icon-box">
                                        <i class="fa-solid fa-seedling"></i>
                                    </div>
                                    <div>
                                        <h2 class="text-sm font-bold text-slate-900 leading-tight">Thông tin chung & Nguồn gốc xuất xứ</h2>
                                        <p class="text-xs text-slate-400 mt-0.5">Khai báo mã vùng trồng và định danh nông sản sạch chính hãng</p>
                                    </div>
                                </div>
                                <span class="section-badge-pill required">BẮT BUỘC</span>
                            </div>

                            <div class="space-y-4">
                                <!-- Tên sản phẩm nông sản -->
                                <div>
                                    <div class="form-label">
                                        <span>Tên sản phẩm nông sản <span class="req">*</span></span>
                                        <span id="nameCounter" class="text-slate-400 font-normal text-xs">0/120 ký tự</span>
                                    </div>
                                    <input type="text" name="name" id="productNameInput" required maxlength="120"
                                           placeholder="Ví dụ: Dâu Tây Hana Đà Lạt Nâng Vị Giác (Loại A1)"
                                           value="Dâu Tây Hana Đà Lạt Nâng Vị Giác (Loại A1)"
                                           oninput="updateNameCounter(this)"
                                           class="form-input font-medium text-slate-900">
                                </div>

                                <!-- SKU Tùy Chọn -->
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div>
                                        <div class="form-label">
                                            <span>Mã định danh SKU (Hệ thống tự tạo nếu trống)</span>
                                        </div>
                                        <input type="text" name="sku" placeholder="VD: SKU-HANA-500G" value="SKU-HANA-500G" class="form-input">
                                    </div>
                                    <div>
                                        <div class="form-label">
                                            <span>Danh mục sản phẩm <span class="req">*</span></span>
                                        </div>
                                        <select name="categoryId" class="form-select font-medium text-slate-800">
                                            <c:forEach var="cat" items="${categories}">
                                                <option value="${cat.categoryId}" ${cat.categoryId == 11 ? 'selected' : ''}>
                                                    ${cat.categoryName}
                                                </option>
                                            </c:forEach>
                                            <c:if test="${empty categories}">
                                                <option value="11" selected>Trái cây tươi ôn đới (Đà Lạt)</option>
                                                <option value="1">Trái Cây</option>
                                                <option value="4">Thực Phẩm Hữu Cơ</option>
                                                <option value="6">Trái Cây Việt Nam</option>
                                            </c:if>
                                        </select>
                                    </div>
                                </div>

                                <!-- Vùng trồng / Xuất xứ -->
                                <div>
                                    <div class="form-label">
                                        <span>Vùng trồng / Xuất xứ <span class="req">*</span></span>
                                    </div>
                                    <input type="text" name="origin" list="originList"
                                           placeholder="Nhập hoặc chọn: Đà Lạt, Mộc Châu, Tiền Giang, Bến Tre..."
                                           value="Đà Lạt, Lâm Đồng (Trại Mát Farm)"
                                           class="form-input font-medium">
                                    <datalist id="originList">
                                        <option value="Đà Lạt, Lâm Đồng (Trại Mát Farm)">
                                        <option value="Mộc Châu, Sơn La">
                                        <option value="Tiền Giang, Đồng Bằng Sông Cửu Long">
                                        <option value="Bến Tre (Xứ dừa Chợ Lách)">
                                        <option value="Gia Lai, Tây Nguyên">
                                        <option value="Bắc Giang (Lục Ngạn)">
                                    </datalist>
                                </div>

                                <!-- Điều kiện bảo quản khuyên dùng -->
                                <div>
                                    <label class="form-label">Điều kiện bảo quản khuyên dùng</label>
                                    <div class="flex flex-wrap gap-2.5 mt-1">
                                        <button type="button" onclick="selectStorageTag(this, 'Kho lạnh 2°C - 8°C')" class="storage-tag-btn active">
                                            <i class="fa-solid fa-snowflake text-xs"></i>
                                            <span>Kho lạnh 2°C - 8°C</span>
                                        </button>
                                        <button type="button" onclick="selectStorageTag(this, 'Thoáng mát tự nhiên')" class="storage-tag-btn">
                                            <i class="fa-solid fa-wind text-xs"></i>
                                            <span>Thoáng mát tự nhiên</span>
                                        </button>
                                        <button type="button" onclick="selectStorageTag(this, 'Tránh ánh nắng trực tiếp')" class="storage-tag-btn">
                                            <i class="fa-solid fa-sun text-xs"></i>
                                            <span>Tránh ánh nắng trực tiếp</span>
                                        </button>
                                        <button type="button" onclick="selectStorageTag(this, 'Độ ẩm tiêu chuẩn 85%')" class="storage-tag-btn">
                                            <i class="fa-solid fa-droplet text-xs"></i>
                                            <span>Độ ẩm tiêu chuẩn 85%</span>
                                        </button>
                                    </div>
                                </div>

                                <!-- Tiêu chuẩn chứng nhận chất lượng -->
                                <div>
                                    <label class="form-label">Tiêu chuẩn chứng nhận chất lượng</label>
                                    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-3 mt-1.5">
                                        <!-- VietGAP -->
                                        <label class="cert-checkbox-card selected" onclick="toggleCert(this)">
                                            <input type="checkbox" name="certifications" value="VietGAP" checked class="mt-0.5 rounded text-blue-600 focus:ring-0">
                                            <div>
                                                <div class="text-xs font-bold text-slate-800">VietGAP</div>
                                                <div class="text-[11px] text-slate-500">Chuẩn quốc gia</div>
                                            </div>
                                        </label>

                                        <!-- GlobalGAP -->
                                        <label class="cert-checkbox-card" onclick="toggleCert(this)">
                                            <input type="checkbox" name="certifications" value="GlobalGAP" class="mt-0.5 rounded text-blue-600 focus:ring-0">
                                            <div>
                                                <div class="text-xs font-bold text-slate-800">GlobalGAP</div>
                                                <div class="text-[11px] text-slate-500">Xuất khẩu</div>
                                            </div>
                                        </label>

                                        <!-- OCOP 4 Sao -->
                                        <label class="cert-checkbox-card selected" onclick="toggleCert(this)">
                                            <input type="checkbox" name="certifications" value="OCOP 4 Sao" checked class="mt-0.5 rounded text-blue-600 focus:ring-0">
                                            <div>
                                                <div class="text-xs font-bold text-slate-800">OCOP 4 Sao</div>
                                                <div class="text-[11px] text-slate-500">Đặc sản địa phương</div>
                                            </div>
                                        </label>

                                        <!-- Hữu cơ Organic -->
                                        <label class="cert-checkbox-card" onclick="toggleCert(this)">
                                            <input type="checkbox" name="certifications" value="Organic" class="mt-0.5 rounded text-blue-600 focus:ring-0">
                                            <div>
                                                <div class="text-xs font-bold text-slate-800">Hữu cơ Organic</div>
                                                <div class="text-[11px] text-slate-500">Không hóa chất</div>
                                            </div>
                                        </label>
                                    </div>
                                </div>

                                <!-- Mô tả chi tiết nông sản -->
                                <div>
                                    <div class="form-label">
                                        <span>Mô tả chi tiết nông sản</span>
                                        <a href="javascript:void(0)" onclick="autoFillDescSEO()" class="text-emerald-700 hover:text-emerald-800 font-semibold text-xs flex items-center gap-1">
                                            <i class="fa-regular fa-lightbulb"></i>
                                            <span>Gợi ý chuẩn SEO FreshFruit</span>
                                        </a>
                                    </div>

                                    <!-- Simple WYSIWYG Toolbar -->
                                    <div class="border border-slate-300 rounded-lg overflow-hidden focus-within:border-emerald-600 focus-within:ring-2 focus-within:ring-emerald-500/20">
                                        <div class="bg-slate-50 px-3 py-2 border-b border-slate-200 flex items-center justify-between flex-wrap gap-2 text-xs text-slate-600">
                                            <div class="flex items-center gap-1">
                                                <button type="button" class="w-7 h-7 rounded hover:bg-slate-200 flex items-center justify-center font-bold" title="In đậm">B</button>
                                                <button type="button" class="w-7 h-7 rounded hover:bg-slate-200 flex items-center justify-center italic font-serif" title="In nghiêng">I</button>
                                                <button type="button" class="w-7 h-7 rounded hover:bg-slate-200 flex items-center justify-center" title="Danh sách"><i class="fa-solid fa-list-ul"></i></button>
                                                <button type="button" class="w-7 h-7 rounded hover:bg-slate-200 flex items-center justify-center" title="Bảng biểu"><i class="fa-solid fa-table"></i></button>
                                            </div>
                                            <div class="text-[11px] text-slate-400">
                                                Mô tả hương vị, độ ngọt (brix), cách thưởng thức ngon nhất...
                                            </div>
                                        </div>
                                        <textarea name="description" id="productDescTextarea" rows="4" class="form-textarea border-0 rounded-none focus:ring-0 p-3 text-xs leading-relaxed"
                                                  placeholder="Nhập mô tả chi tiết vị ngọt đậm đà, kết cấu giòn tan và hướng dẫn bảo quản tủ lạnh giữ nguyên hương vị...">Dâu Tây giống Hana Nhật Bản trồng tại Trại Mát - Đà Lạt trên giá thể xơ dừa hữu cơ. Trái dâu đỏ mọng, ngọt đậm thanh vị, độ ngọt đạt 12 - 14 độ Brix, hương thơm quyến rũ đặc trưng. Được thu hoạch lúc 5h30 sáng khi sương còn đọng trên cuống lá, bảo quản nhiệt độ lạnh chuyên dụng giữ trọn độ tươi giòn 100%.</textarea>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- SECTION 2: BIẾN THỂ, ĐỊNH LƯỢNG & KHO HÀNG -->
                        <div class="form-section-card">
                            <div class="form-section-header">
                                <div class="flex items-center gap-3">
                                    <div class="section-icon-box bg-blue-50 text-blue-600">
                                        <i class="fa-solid fa-store"></i>
                                    </div>
                                    <div>
                                        <h2 class="text-sm font-bold text-slate-900 leading-tight">Biến thể, Định lượng & Kho hàng</h2>
                                        <p class="text-xs text-slate-400 mt-0.5">Thiết lập đơn vị tính giá bán và lượng tồn kho thực tế tại vườn</p>
                                    </div>
                                </div>
                                <span class="section-badge-pill price">GIÁ & KHO</span>
                            </div>

                            <div class="space-y-4">
                                <!-- Chọn đơn vị tính cơ sở -->
                                <div>
                                    <label class="form-label">Chọn đơn vị tính cơ sở <span class="req">*</span></label>
                                    <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 mt-1">
                                        <div class="unit-radio-card active" onclick="selectUnit(this, 'Hộp (500g - 1kg)')">
                                            <i class="fa-solid fa-circle-dot text-emerald-700 text-sm"></i>
                                            <span>Hộp (500g - 1kg)</span>
                                        </div>
                                        <div class="unit-radio-card" onclick="selectUnit(this, 'Kg (Kilogram)')">
                                            <i class="fa-regular fa-circle text-slate-400 text-sm"></i>
                                            <span>Kg (Kilogram)</span>
                                        </div>
                                        <div class="unit-radio-card" onclick="selectUnit(this, 'Quả / Trái đơn')">
                                            <i class="fa-regular fa-circle text-slate-400 text-sm"></i>
                                            <span>Quả / Trái đơn</span>
                                        </div>
                                        <div class="unit-radio-card" onclick="selectUnit(this, 'Giỏ quà biếu')">
                                            <i class="fa-regular fa-circle text-slate-400 text-sm"></i>
                                            <span>Giỏ quà biếu</span>
                                        </div>
                                    </div>
                                </div>

                                <!-- Row 3 Cols: Giá niêm yết, Giá khuyến mãi, Số lượng kho -->
                                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                                    <div>
                                        <div class="form-label">
                                            <span>Giá niêm yết (VNĐ) <span class="req">*</span></span>
                                        </div>
                                        <div class="relative">
                                            <input type="number" step="1000" name="originalPrice" id="inputOrigPrice" required
                                                   value="125000" class="form-input font-bold text-slate-800 pr-8">
                                            <span class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 font-bold text-xs">₫</span>
                                        </div>
                                    </div>

                                    <div>
                                        <div class="form-label">
                                            <span>Giá khuyến mãi (VNĐ)</span>
                                        </div>
                                        <div class="relative">
                                            <input type="number" step="1000" name="price" id="inputSalePrice"
                                                   value="98000" class="form-input font-bold text-orange-600 pr-8">
                                            <span class="absolute right-3 top-1/2 -translate-y-1/2 text-orange-400 font-bold text-xs">₫</span>
                                        </div>
                                    </div>

                                    <div>
                                        <div class="form-label">
                                            <span>Số lượng kho ban đầu <span class="req">*</span></span>
                                        </div>
                                        <div class="relative">
                                            <input type="number" name="stockQuantity" id="inputStockQty" required
                                                   value="150" class="form-input font-bold text-slate-800 pr-14">
                                            <span id="unitStockSuffix" class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 font-medium text-xs">Hộp</span>
                                        </div>
                                    </div>
                                </div>

                                <!-- Cảnh báo tồn kho tối thiểu -->
                                <div class="warning-threshold-box">
                                    <div class="flex items-center gap-3">
                                        <div class="w-8 h-8 rounded-full bg-amber-100 text-amber-700 flex items-center justify-center shrink-0">
                                            <i class="fa-solid fa-triangle-exclamation text-sm"></i>
                                        </div>
                                        <div>
                                            <div class="text-xs font-bold text-amber-900 leading-tight">Cảnh báo tồn kho tối thiểu</div>
                                            <p class="text-[11px] text-amber-700 mt-0.5">Hệ thống sẽ tự động bật trạng thái "Sắp hết hàng" khi kho chạm ngưỡng</p>
                                        </div>
                                    </div>
                                    <div class="flex items-center gap-2 shrink-0">
                                        <input type="number" name="lowStockThreshold" value="15" class="w-16 text-center font-bold py-1.5 px-2 text-xs border border-amber-300 rounded-lg bg-white">
                                        <span id="unitThresholdSuffix" class="text-xs font-semibold text-slate-600">Hộp</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- SECTION 3: TIÊU CHUẨN BẢO QUẢN & GIAO NHẬN CAM KẾT -->
                        <div class="form-section-card">
                            <div class="form-section-header">
                                <div class="flex items-center gap-3">
                                    <div class="section-icon-box bg-amber-50 text-amber-700">
                                        <i class="fa-solid fa-truck-ramp-box"></i>
                                    </div>
                                    <div>
                                        <h2 class="text-sm font-bold text-slate-900 leading-tight">Tiêu chuẩn bảo quản & Giao nhận cam kết</h2>
                                        <p class="text-xs text-slate-400 mt-0.5">Đảm bảo độ tươi ngon nguyên bản khi đến tay người tiêu dùng</p>
                                    </div>
                                </div>
                                <span class="section-badge-pill shipping">VẬN CHUYỂN</span>
                            </div>

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <!-- Cam kết 1: Chuỗi Lạnh FreshCold 2H -->
                                <label class="shipping-guarantee-card active">
                                    <input type="checkbox" name="shippingStandard" value="Chuỗi Lạnh FreshCold 2H" checked class="mt-1 rounded text-blue-600 focus:ring-0">
                                    <div>
                                        <div class="flex items-center gap-1.5 text-xs font-bold text-slate-900">
                                            <i class="fa-solid fa-snowflake text-blue-600"></i>
                                            <span>Chuỗi Lạnh FreshCold 2H</span>
                                        </div>
                                        <p class="text-[11px] text-slate-500 mt-1 leading-relaxed">
                                            Vận chuyển bằng xe tải lạnh chuyên dụng duy trì 4°C - 10°C liên tục từ vườn đến kho phân phối nội đô.
                                        </p>
                                    </div>
                                </label>

                                <!-- Cam kết 2: Hái tươi trong ngày -->
                                <label class="shipping-guarantee-card active">
                                    <input type="checkbox" name="shippingStandard" value="Hái tươi trong ngày" checked class="mt-1 rounded text-blue-600 focus:ring-0">
                                    <div>
                                        <div class="flex items-center gap-1.5 text-xs font-bold text-slate-900">
                                            <i class="fa-solid fa-leaf text-emerald-600"></i>
                                            <span>Hái tươi trong ngày (Same-Day Harvest)</span>
                                        </div>
                                        <p class="text-[11px] text-slate-500 mt-1 leading-relaxed">
                                            Nông sản chỉ được thu hoạch vào sáng sớm (trước 6h AM) ngay trong ngày giao đơn hàng cho khách.
                                        </p>
                                    </div>
                                </label>
                            </div>
                        </div>

                    </div>

                    <!-- ====================================================
                         RIGHT COLUMN (4 COLS): IMAGES & PUBLISH ACTIONS
                         ==================================================== -->
                    <div class="lg:col-span-4 space-y-6">

                        <!-- CARD: HÌNH ẢNH SẢN PHẨM (5 ẢNH) -->
                        <div class="form-section-card">
                            <div class="form-section-header">
                                <div class="flex items-center gap-3">
                                    <div class="section-icon-box bg-purple-50 text-purple-700">
                                        <i class="fa-solid fa-camera"></i>
                                    </div>
                                    <div>
                                        <h2 class="text-sm font-bold text-slate-900 leading-tight">Hình ảnh sản phẩm</h2>
                                        <p class="text-xs text-slate-400 mt-0.5">Tải lên bộ ảnh chụp thực tế</p>
                                    </div>
                                </div>
                                <span class="section-badge-pill required">5 ẢNH</span>
                            </div>

                            <div class="space-y-4">
                                <!-- Ảnh bìa chính (Cover) -->
                                <div>
                                    <label class="form-label">
                                        <span>Ảnh bìa chính (Cover) <span class="req">*</span></span>
                                    </label>

                                    <div class="image-cover-box group">
                                        <img id="previewCoverImg" src="https://images.unsplash.com/photo-1543528176-61b239494933?w=800&auto=format&fit=crop&q=80" alt="Ảnh bìa dâu tây tươi">
                                        <div class="image-cover-overlay opacity-90 group-hover:opacity-100 transition">
                                            <div class="w-10 h-10 rounded-full bg-white/30 backdrop-blur flex items-center justify-center text-white mb-2">
                                                <i class="fa-solid fa-cloud-arrow-up text-lg"></i>
                                            </div>
                                            <p class="text-xs font-bold leading-tight">Kéo thả ảnh bìa vào đây hoặc bấm để tải lên</p>
                                            <p class="text-[10px] text-slate-200 mt-1">Hỗ trợ PNG, JPG tối đa 10MB (Khuyến dùng 1000 x 1000px)</p>
                                        </div>
                                    </div>

                                    <!-- Link CDN Ảnh Cover -->
                                    <div class="mt-2.5">
                                        <label class="text-[11px] font-semibold text-slate-600 block mb-1">Hoặc dán liên kết CDN Ảnh</label>
                                        <input type="text" name="coverImage" id="inputCoverUrl"
                                               value="https://images.unsplash.com/photo-1543528176-61b239494933?w=800&auto=format&fit=crop&q=80"
                                               onchange="document.getElementById('previewCoverImg').src = this.value"
                                               placeholder="https://cdn.freshfruit.vn/dalat/strawberry-hana.jpg"
                                               class="form-input text-xs font-mono text-slate-600">
                                    </div>
                                </div>

                                <!-- 4 Ảnh chi tiết góc chụp bổ sung -->
                                <div>
                                    <label class="form-label">
                                        <span>4 Ảnh chi tiết góc chụp bổ sung</span>
                                    </label>
                                    <div class="grid grid-cols-4 gap-2 mt-1.5">
                                        <!-- Slot 1: Cuống -->
                                        <div class="detail-thumb-slot group" onclick="promptImage(1)">
                                            <img id="thumb1" src="https://images.unsplash.com/photo-1588615419957-6627063d81b4?w=400&auto=format&fit=crop&q=80" alt="Cuống">
                                            <div class="detail-thumb-label">Cuống</div>
                                            <input type="hidden" name="imgDetail1" id="inputImgDetail1" value="https://images.unsplash.com/photo-1588615419957-6627063d81b4?w=400&auto=format&fit=crop&q=80">
                                        </div>

                                        <!-- Slot 2: Cắt lát -->
                                        <div class="detail-thumb-slot group" onclick="promptImage(2)">
                                            <img id="thumb2" src="https://images.unsplash.com/photo-1518635017498-87f514b751ba?w=400&auto=format&fit=crop&q=80" alt="Cắt lát">
                                            <div class="detail-thumb-label">Cắt lát</div>
                                            <input type="hidden" name="imgDetail2" id="inputImgDetail2" value="https://images.unsplash.com/photo-1518635017498-87f514b751ba?w=400&auto=format&fit=crop&q=80">
                                        </div>

                                        <!-- Slot 3: Tem QR -->
                                        <div class="detail-thumb-slot group" onclick="promptImage(3)">
                                            <img id="thumb3" src="https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=400&auto=format&fit=crop&q=80" alt="Tem QR">
                                            <div class="detail-thumb-label">Tem QR</div>
                                            <input type="hidden" name="imgDetail3" id="inputImgDetail3" value="https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=400&auto=format&fit=crop&q=80">
                                        </div>

                                        <!-- Slot 4: 1 Hộp -->
                                        <div class="detail-thumb-slot group" onclick="promptImage(4)">
                                            <img id="thumb4" src="https://images.unsplash.com/photo-1596704017254-9b121068fb31?w=400&auto=format&fit=crop&q=80" alt="1 Hộp">
                                            <div class="detail-thumb-label">1 Hộp</div>
                                            <input type="hidden" name="imgDetail4" id="inputImgDetail4" value="https://images.unsplash.com/photo-1596704017254-9b121068fb31?w=400&auto=format&fit=crop&q=80">
                                        </div>
                                    </div>
                                    <p class="text-[10px] text-slate-400 mt-2 italic text-center">Bấm vào từng ảnh ô vuông để đổi liên kết ảnh chi tiết</p>
                                </div>
                            </div>
                        </div>

                        <!-- CARD: BUTTONS & VERIFICATION NOTICE -->
                        <div class="form-section-card bg-white">
                            <!-- Nút phát hành -->
                            <button type="button" onclick="submitForm('publish')" class="btn-publish-main">
                                <i class="fa-solid fa-rocket text-sm"></i>
                                <span>Phát hành ngay lên sàn</span>
                            </button>

                            <!-- Nút hủy -->
                            <a href="${pageContext.request.contextPath}/shop/products" class="btn-cancel-back">
                                <span>Hủy bỏ & Quay lại danh sách</span>
                            </a>

                            <!-- Thông tin kiểm duyệt -->
                            <div class="verification-notice-card">
                                <i class="fa-solid fa-shield-halved text-emerald-600 text-sm mt-0.5 shrink-0"></i>
                                <span>Sản phẩm mới sẽ được hệ thống kiểm duyệt thông tin mã số vùng trồng và tiêu chuẩn VietGAP tự động trong vòng <strong>15 phút</strong>.</span>
                            </div>
                        </div>

                    </div>

                </div>
            </form>

        </div>
    </main>

    <!-- ========================================================
         5. INTERACTION JAVASCRIPT
         ======================================================== -->
    <script>
        // Character counter
        function updateNameCounter(input) {
            const count = input.value.length;
            document.getElementById('nameCounter').innerText = count + '/120 ký tự';
        }

        // Storage temp pill selection
        function selectStorageTag(btn, val) {
            document.querySelectorAll('.storage-tag-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            document.getElementById('inputStorageTemp').value = val;
        }

        // Certification card selection toggle
        function toggleCert(label) {
            const cb = label.querySelector('input[type="checkbox"]');
            setTimeout(() => {
                if (cb.checked) {
                    label.classList.add('selected');
                } else {
                    label.classList.remove('selected');
                }
            }, 50);
        }

        // Unit selection
        function selectUnit(card, unitName) {
            document.querySelectorAll('.unit-radio-card').forEach(c => {
                c.classList.remove('active');
                const icon = c.querySelector('i');
                icon.className = 'fa-regular fa-circle text-slate-400 text-sm';
            });
            card.classList.add('active');
            const icon = card.querySelector('i');
            icon.className = 'fa-solid fa-circle-dot text-emerald-700 text-sm';

            document.getElementById('inputUnit').value = unitName;
            
            // Update suffix labels
            let shortUnit = "Đơn vị";
            if (unitName.includes("Hộp")) shortUnit = "Hộp";
            else if (unitName.includes("Kg")) shortUnit = "Kg";
            else if (unitName.includes("Quả")) shortUnit = "Quả";
            else if (unitName.includes("Giỏ")) shortUnit = "Giỏ";

            document.getElementById('unitStockSuffix').innerText = shortUnit;
            document.getElementById('unitThresholdSuffix').innerText = shortUnit;
        }

        // SEO Autofill suggestion
        function autoFillDescSEO() {
            const name = document.getElementById('productNameInput').value;
            const desc = name + " chuẩn VietGAP thu hái từ sáng sớm tại vườn Đà Lạt. Vị thơm ngọt tự nhiên, thịt quả mọng nước, giàu Vitamin C & chất chống oxy hóa. Đóng gói hộp đạt chuẩn chuỗi lạnh FreshCold 2H chuyển nhanh tới tận tay người tiêu dùng.";
            document.getElementById('productDescTextarea').value = desc;
        }

        // Change detail image url prompt
        function promptImage(index) {
            const input = document.getElementById('inputImgDetail' + index);
            const currentUrl = input.value;
            const newUrl = prompt("Nhập URL ảnh chi tiết góc chụp " + index + ":", currentUrl);
            if (newUrl && newUrl.trim() !== "") {
                input.value = newUrl.trim();
                document.getElementById('thumb' + index).src = newUrl.trim();
            }
        }

        // Submit form with action
        function submitForm(actionVal) {
            const form = document.getElementById('addProductForm');
            const name = document.getElementById('productNameInput').value;

            if (!name || name.trim() === "") {
                alert("Vui lòng nhập tên sản phẩm nông sản!");
                document.getElementById('productNameInput').focus();
                return;
            }

            document.getElementById('formAction').value = actionVal;
            form.submit();
        }

        // Initialize counters on load
        document.addEventListener('DOMContentLoaded', () => {
            const nameInput = document.getElementById('productNameInput');
            if (nameInput) updateNameCounter(nameInput);
        });
    </script>
</body>
</html>
