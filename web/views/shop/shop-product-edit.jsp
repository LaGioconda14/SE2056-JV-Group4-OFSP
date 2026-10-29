<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chỉnh Sửa Nông Sản: ${product.productName} - FreshFruit Kênh Người Bán</title>

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
        <jsp:param name="active" value="products" />
    </jsp:include>
    <jsp:include page="/views/shop/layout/header.jsp" />

    <!-- ========================================================
         3. MAIN CONTENT: EDIT PRODUCT SCREEN
         ======================================================== -->
    <main class="shop-main-wrapper">
        <div class="shop-content-container">

            <!-- Breadcrumb & Top Bar -->
            <div class="flex flex-col gap-2 mb-5">
                <nav class="flex items-center gap-2 text-xs text-slate-500 font-medium">
                    <span>Kênh Người Bán</span>
                    <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                    <a href="${pageContext.request.contextPath}/shop/products" class="hover:text-emerald-700">Sản phẩm & Kho</a>
                    <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                    <span class="text-emerald-700 font-semibold">Chỉnh sửa nông sản</span>
                </nav>

                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mt-1">
                    <div>
                        <div class="flex items-center flex-wrap gap-2.5">
                            <h1 class="text-2xl font-black text-slate-900 tracking-tight">Chỉnh Sửa Nông Sản</h1>
                            <span class="px-2.5 py-0.5 rounded-lg bg-slate-100 border border-slate-200 text-slate-700 font-mono text-xs font-bold">
                                ${product.sku}
                            </span>
                            <c:choose>
                                <c:when test="${product.active}">
                                    <span class="px-2.5 py-0.5 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200 font-bold text-[11px] flex items-center gap-1.5">
                                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span> Đang mở bán
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="px-2.5 py-0.5 rounded-full bg-slate-100 text-slate-600 border border-slate-200 font-bold text-[11px] flex items-center gap-1.5">
                                        <span class="w-1.5 h-1.5 rounded-full bg-slate-400"></span> Đã tạm ẩn
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <p class="text-xs text-slate-500 mt-0.5">Cập nhật thông tin quy cách, tồn kho thực tế và đơn giá niêm yết của nông sản.</p>
                    </div>

                    <!-- Top Action Buttons -->
                    <div class="flex items-center flex-wrap gap-3">
                        <a href="${pageContext.request.contextPath}/detail?id=${product.productId}" target="_blank"
                           class="px-3.5 py-2 bg-white border border-slate-300 text-slate-700 hover:bg-slate-50 rounded-lg text-xs font-bold transition shadow-sm flex items-center gap-1.5">
                            <i class="fa-solid fa-arrow-up-right-from-square text-xs text-slate-500"></i>
                            <span>Xem trang người mua</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/shop/products" class="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-lg text-xs font-bold transition">
                            Hủy bỏ
                        </a>
                        <button type="button" onclick="submitEditForm()" class="px-5 py-2 bg-emerald-700 hover:bg-emerald-800 text-white rounded-lg text-xs font-bold transition shadow-sm flex items-center gap-2">
                            <i class="fa-solid fa-floppy-disk text-xs"></i>
                            <span>Lưu thay đổi</span>
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
                 4. EDIT PRODUCT FORM (2 COLUMNS)
                 ======================================================== -->
            <form id="editProductForm" action="${pageContext.request.contextPath}/shop/product/edit" method="POST">
                <input type="hidden" name="variantId" value="${product.variantId}">
                <input type="hidden" name="productId" value="${product.productId}">
                <input type="hidden" name="storageTemp" id="inputStorageTemp" value="${not empty product.storageTemp ? product.storageTemp : 'Kho lạnh 2°C - 8°C'}">
                <input type="hidden" name="unit" id="inputUnit" value="${not empty product.unit ? product.unit : 'Hộp (500g - 1kg)'}">
                <input type="hidden" name="status" id="inputStatus" value="${product.active ? 'active' : 'hidden'}">

                <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">

                    <!-- ====================================================
                         LEFT COLUMN (8 COLS): EDIT DETAILS & PRICING
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
                                        <p class="text-xs text-slate-400 mt-0.5">Mã vùng trồng và định danh nông sản sạch chính hãng</p>
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
                                           value="${product.productName}"
                                           oninput="updateNameCounter(this)"
                                           class="form-input font-bold text-slate-900 text-sm">
                                </div>

                                <!-- SKU & Danh mục sản phẩm -->
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div>
                                        <div class="form-label">
                                            <span>Mã định danh SKU <span class="req">*</span></span>
                                        </div>
                                        <input type="text" name="sku" required value="${product.sku}" class="form-input font-mono font-bold text-slate-700">
                                    </div>
                                    <div>
                                        <div class="form-label">
                                            <span>Danh mục sản phẩm <span class="req">*</span></span>
                                        </div>
                                        <select name="categoryId" class="form-select font-medium text-slate-800">
                                            <c:forEach var="cat" items="${categories}">
                                                <option value="${cat.categoryId}" ${cat.categoryId == product.categoryId ? 'selected' : ''}>
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
                                           value="${not empty product.origin ? product.origin : 'Đà Lạt, Lâm Đồng'}"
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
                                        <button type="button" onclick="selectStorageTag(this, 'Kho lạnh 2°C - 8°C')"
                                                class="storage-tag-btn ${product.storageTemp == null || product.storageTemp.contains('2°C') ? 'active' : ''}">
                                            <i class="fa-solid fa-snowflake text-xs"></i>
                                            <span>Kho lạnh 2°C - 8°C</span>
                                        </button>
                                        <button type="button" onclick="selectStorageTag(this, 'Thoáng mát tự nhiên')"
                                                class="storage-tag-btn ${product.storageTemp != null && product.storageTemp.contains('Thoáng mát') ? 'active' : ''}">
                                            <i class="fa-solid fa-wind text-xs"></i>
                                            <span>Thoáng mát tự nhiên</span>
                                        </button>
                                        <button type="button" onclick="selectStorageTag(this, 'Tránh ánh nắng trực tiếp')"
                                                class="storage-tag-btn ${product.storageTemp != null && product.storageTemp.contains('Tránh ánh nắng') ? 'active' : ''}">
                                            <i class="fa-solid fa-sun text-xs"></i>
                                            <span>Tránh ánh nắng trực tiếp</span>
                                        </button>
                                        <button type="button" onclick="selectStorageTag(this, 'Độ ẩm tiêu chuẩn 85%')"
                                                class="storage-tag-btn ${product.storageTemp != null && product.storageTemp.contains('85%') ? 'active' : ''}">
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
                                        <label class="cert-checkbox-card ${product.certification != null && product.certification.contains('VietGAP') ? 'selected' : ''}" onclick="toggleCert(this)">
                                            <input type="checkbox" name="certifications" value="VietGAP"
                                                   ${product.certification != null && product.certification.contains('VietGAP') ? 'checked' : ''}
                                                   class="mt-0.5 rounded text-blue-600 focus:ring-0">
                                            <div>
                                                <div class="text-xs font-bold text-slate-800">VietGAP</div>
                                                <div class="text-[11px] text-slate-500">Chuẩn quốc gia</div>
                                            </div>
                                        </label>

                                        <!-- GlobalGAP -->
                                        <label class="cert-checkbox-card ${product.certification != null && product.certification.contains('GlobalGAP') ? 'selected' : ''}" onclick="toggleCert(this)">
                                            <input type="checkbox" name="certifications" value="GlobalGAP"
                                                   ${product.certification != null && product.certification.contains('GlobalGAP') ? 'checked' : ''}
                                                   class="mt-0.5 rounded text-blue-600 focus:ring-0">
                                            <div>
                                                <div class="text-xs font-bold text-slate-800">GlobalGAP</div>
                                                <div class="text-[11px] text-slate-500">Xuất khẩu</div>
                                            </div>
                                        </label>

                                        <!-- OCOP 4 Sao -->
                                        <label class="cert-checkbox-card ${product.certification != null && product.certification.contains('OCOP') ? 'selected' : ''}" onclick="toggleCert(this)">
                                            <input type="checkbox" name="certifications" value="OCOP 4 Sao"
                                                   ${product.certification != null && product.certification.contains('OCOP') ? 'checked' : ''}
                                                   class="mt-0.5 rounded text-blue-600 focus:ring-0">
                                            <div>
                                                <div class="text-xs font-bold text-slate-800">OCOP 4 Sao</div>
                                                <div class="text-[11px] text-slate-500">Đặc sản địa phương</div>
                                            </div>
                                        </label>

                                        <!-- Hữu cơ Organic -->
                                        <label class="cert-checkbox-card ${product.certification != null && product.certification.contains('Organic') ? 'selected' : ''}" onclick="toggleCert(this)">
                                            <input type="checkbox" name="certifications" value="Organic"
                                                   ${product.certification != null && product.certification.contains('Organic') ? 'checked' : ''}
                                                   class="mt-0.5 rounded text-blue-600 focus:ring-0">
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
                                                  placeholder="Nhập mô tả chi tiết vị ngọt đậm đà, kết cấu giòn tan và hướng dẫn bảo quản tủ lạnh giữ nguyên hương vị...">${product.description}</textarea>
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
                                        <div class="unit-radio-card ${product.unit != null && product.unit.contains('Hộp') ? 'active' : ''}" onclick="selectUnit(this, 'Hộp (500g - 1kg)')">
                                            <i class="fa-solid ${product.unit != null && product.unit.contains('Hộp') ? 'fa-circle-dot text-emerald-700' : 'fa-circle text-slate-400'} text-sm"></i>
                                            <span>Hộp (500g - 1kg)</span>
                                        </div>
                                        <div class="unit-radio-card ${product.unit != null && product.unit.contains('Kg') ? 'active' : ''}" onclick="selectUnit(this, 'Kg (Kilogram)')">
                                            <i class="fa-solid ${product.unit != null && product.unit.contains('Kg') ? 'fa-circle-dot text-emerald-700' : 'fa-circle text-slate-400'} text-sm"></i>
                                            <span>Kg (Kilogram)</span>
                                        </div>
                                        <div class="unit-radio-card ${product.unit != null && (product.unit.contains('Quả') || product.unit.contains('Trái')) ? 'active' : ''}" onclick="selectUnit(this, 'Quả / Trái đơn')">
                                            <i class="fa-solid ${product.unit != null && (product.unit.contains('Quả') || product.unit.contains('Trái')) ? 'fa-circle-dot text-emerald-700' : 'fa-circle text-slate-400'} text-sm"></i>
                                            <span>Quả / Trái đơn</span>
                                        </div>
                                        <div class="unit-radio-card ${product.unit != null && product.unit.contains('Giỏ') ? 'active' : ''}" onclick="selectUnit(this, 'Giỏ quà biếu')">
                                            <i class="fa-solid ${product.unit != null && product.unit.contains('Giỏ') ? 'fa-circle-dot text-emerald-700' : 'fa-circle text-slate-400'} text-sm"></i>
                                            <span>Giỏ quà biếu</span>
                                        </div>
                                    </div>
                                </div>

                                <!-- Row 3 Cols: Giá niêm yết, Giá bán, Tồn kho -->
                                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                                    <div>
                                        <div class="form-label">
                                            <span>Giá niêm yết (VNĐ) <span class="req">*</span></span>
                                        </div>
                                        <div class="relative">
                                            <input type="number" step="1000" name="originalPrice" id="inputOrigPrice" required
                                                   value="<fmt:formatNumber value='${product.originalPrice}' pattern='#' groupingUsed='false'/>"
                                                   class="form-input font-bold text-slate-800 pr-8">
                                            <span class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 font-bold text-xs">₫</span>
                                        </div>
                                    </div>

                                    <div>
                                        <div class="form-label">
                                            <span>Giá bán / khuyến mãi (VNĐ)</span>
                                        </div>
                                        <div class="relative">
                                            <input type="number" step="1000" name="price" id="inputSalePrice"
                                                   value="<fmt:formatNumber value='${product.price}' pattern='#' groupingUsed='false'/>"
                                                   class="form-input font-bold text-orange-600 pr-8">
                                            <span class="absolute right-3 top-1/2 -translate-y-1/2 text-orange-400 font-bold text-xs">₫</span>
                                        </div>
                                    </div>

                                    <div>
                                        <div class="form-label">
                                            <span>Số lượng tồn kho thực tế <span class="req">*</span></span>
                                        </div>
                                        <div class="relative">
                                            <input type="number" name="stockQuantity" id="inputStockQty" required
                                                   value="${product.stockQuantity}"
                                                   class="form-input font-bold text-slate-800 pr-14">
                                            <span id="unitStockSuffix" class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 font-medium text-xs">
                                                ${not empty product.unit ? product.unit : 'Hộp'}
                                            </span>
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
                                        <input type="number" name="lowStockThreshold"
                                               value="${product.lowStockThreshold > 0 ? product.lowStockThreshold : 15}"
                                               class="w-16 text-center font-bold py-1.5 px-2 text-xs border border-amber-300 rounded-lg bg-white">
                                        <span id="unitThresholdSuffix" class="text-xs font-semibold text-slate-600">
                                            ${not empty product.unit ? product.unit : 'Hộp'}
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- SECTION 3: TRẠNG THÁI HIỂN THỊ KINH DOANH -->
                        <div class="form-section-card">
                            <div class="form-section-header">
                                <div class="flex items-center gap-3">
                                    <div class="section-icon-box bg-emerald-50 text-emerald-700">
                                        <i class="fa-solid fa-toggle-on"></i>
                                    </div>
                                    <div>
                                        <h2 class="text-sm font-bold text-slate-900 leading-tight">Trạng thái kinh doanh & Phân phối</h2>
                                        <p class="text-xs text-slate-400 mt-0.5">Quyết định hiển thị sản phẩm trên sàn mua sắm</p>
                                    </div>
                                </div>
                                <span class="section-badge-pill">TRẠNG THÁI</span>
                            </div>

                            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                                <label class="border ${product.active ? 'border-emerald-600 bg-emerald-50/40' : 'border-slate-200 bg-white'} rounded-xl p-4 flex items-start gap-3 cursor-pointer transition"
                                       onclick="setStatus('active', this)">
                                    <input type="radio" name="statusOption" value="active" ${product.active ? 'checked' : ''} class="mt-1 text-emerald-600 focus:ring-0">
                                    <div>
                                        <div class="font-bold text-xs text-slate-900 flex items-center gap-1.5">
                                            <span class="w-2 h-2 rounded-full bg-emerald-500"></span>
                                            <span>Đang mở bán công khai</span>
                                        </div>
                                        <p class="text-[11px] text-slate-500 mt-1 leading-relaxed">
                                            Nông sản hiển thị trên toàn sàn giao dịch. Khách hàng có thể tìm kiếm và đặt mua ngay.
                                        </p>
                                    </div>
                                </label>

                                <label class="border ${!product.active ? 'border-amber-500 bg-amber-50/40' : 'border-slate-200 bg-white'} rounded-xl p-4 flex items-start gap-3 cursor-pointer transition"
                                       onclick="setStatus('hidden', this)">
                                    <input type="radio" name="statusOption" value="hidden" ${!product.active ? 'checked' : ''} class="mt-1 text-amber-600 focus:ring-0">
                                    <div>
                                        <div class="font-bold text-xs text-slate-900 flex items-center gap-1.5">
                                            <span class="w-2 h-2 rounded-full bg-slate-400"></span>
                                            <span>Tạm ẩn kinh doanh</span>
                                        </div>
                                        <p class="text-[11px] text-slate-500 mt-1 leading-relaxed">
                                            Tạm ẩn khỏi danh mục mua sắm, khách hàng không thấy sản phẩm. Dữ liệu kho vẫn được lưu trữ.
                                        </p>
                                    </div>
                                </label>
                            </div>
                        </div>

                    </div>

                    <!-- ====================================================
                         RIGHT COLUMN (4 COLS): IMAGES & ACTIONS
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
                                        <p class="text-xs text-slate-400 mt-0.5">Ảnh bìa và các góc chụp chi tiết</p>
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
                                        <img id="previewCoverImg" src="${not empty product.image ? product.image : 'https://images.unsplash.com/photo-1543528176-61b239494933?w=800'}" alt="Ảnh bìa">
                                        <div class="image-cover-overlay opacity-90 group-hover:opacity-100 transition">
                                            <div class="w-10 h-10 rounded-full bg-white/30 backdrop-blur flex items-center justify-center text-white mb-2">
                                                <i class="fa-solid fa-cloud-arrow-up text-lg"></i>
                                            </div>
                                            <p class="text-xs font-bold leading-tight">Kéo thả ảnh bìa hoặc dán liên kết CDN</p>
                                            <p class="text-[10px] text-slate-200 mt-1">Khuyến dùng ảnh vuông 1000 x 1000px</p>
                                        </div>
                                    </div>

                                    <!-- Link CDN Ảnh Cover -->
                                    <div class="mt-2.5">
                                        <label class="text-[11px] font-semibold text-slate-600 block mb-1">Liên kết CDN Ảnh bìa</label>
                                        <input type="text" name="coverImage" id="inputCoverUrl"
                                               value="${product.image}"
                                               onchange="document.getElementById('previewCoverImg').src = this.value"
                                               placeholder="https://images.unsplash.com/..."
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
                                        <c:set var="img1" value="${not empty product.galleryImages && product.galleryImages.size() > 0 ? product.galleryImages[0] : 'https://images.unsplash.com/photo-1588615419957-6627063d81b4?w=400'}"/>
                                        <div class="detail-thumb-slot group" onclick="promptImage(1)">
                                            <img id="thumb1" src="${img1}" alt="Cuống">
                                            <div class="detail-thumb-label">Cuống</div>
                                            <input type="hidden" name="imgDetail1" id="inputImgDetail1" value="${img1}">
                                        </div>

                                        <!-- Slot 2: Cắt lát -->
                                        <c:set var="img2" value="${not empty product.galleryImages && product.galleryImages.size() > 1 ? product.galleryImages[1] : 'https://images.unsplash.com/photo-1518635017498-87f514b751ba?w=400'}"/>
                                        <div class="detail-thumb-slot group" onclick="promptImage(2)">
                                            <img id="thumb2" src="${img2}" alt="Cắt lát">
                                            <div class="detail-thumb-label">Cắt lát</div>
                                            <input type="hidden" name="imgDetail2" id="inputImgDetail2" value="${img2}">
                                        </div>

                                        <!-- Slot 3: Tem QR -->
                                        <c:set var="img3" value="${not empty product.galleryImages && product.galleryImages.size() > 2 ? product.galleryImages[2] : 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=400'}"/>
                                        <div class="detail-thumb-slot group" onclick="promptImage(3)">
                                            <img id="thumb3" src="${img3}" alt="Tem QR">
                                            <div class="detail-thumb-label">Tem QR</div>
                                            <input type="hidden" name="imgDetail3" id="inputImgDetail3" value="${img3}">
                                        </div>

                                        <!-- Slot 4: 1 Hộp -->
                                        <c:set var="img4" value="${not empty product.galleryImages && product.galleryImages.size() > 3 ? product.galleryImages[3] : 'https://images.unsplash.com/photo-1596704017254-9b121068fb31?w=400'}"/>
                                        <div class="detail-thumb-slot group" onclick="promptImage(4)">
                                            <img id="thumb4" src="${img4}" alt="1 Hộp">
                                            <div class="detail-thumb-label">1 Hộp</div>
                                            <input type="hidden" name="imgDetail4" id="inputImgDetail4" value="${img4}">
                                        </div>
                                    </div>
                                    <p class="text-[10px] text-slate-400 mt-2 italic text-center">Bấm vào từng ảnh ô vuông để đổi liên kết ảnh chi tiết</p>
                                </div>
                            </div>
                        </div>

                        <!-- CARD: BUTTONS & METADATA -->
                        <div class="form-section-card bg-white">
                            <!-- Nút lưu thay đổi -->
                            <button type="button" onclick="submitEditForm()" class="btn-publish-main">
                                <i class="fa-solid fa-floppy-disk text-sm"></i>
                                <span>Lưu thay đổi sản phẩm</span>
                            </button>

                            <!-- Nút hủy -->
                            <a href="${pageContext.request.contextPath}/shop/products" class="btn-cancel-back">
                                <span>Hủy bỏ & Quay lại danh sách</span>
                            </a>

                            <!-- Nút xóa sản phẩm -->
                            <a href="${pageContext.request.contextPath}/shop/product/delete?id=${product.variantId}"
                               onclick="return confirm('Bạn có chắc chắn muốn xóa vĩnh viễn nông sản \'${product.productName}\'? Thao tác này không thể hoàn tác.');"
                               class="w-full text-red-600 hover:text-red-700 bg-red-50 hover:bg-red-100 font-semibold text-xs py-2.5 px-4 rounded-lg text-center mt-3 block transition border border-red-200">
                                <i class="fa-regular fa-trash-can mr-1"></i> Xóa nông sản này
                            </a>

                            <!-- Thông tin bảo chứng -->
                            <div class="verification-notice-card mt-4">
                                <i class="fa-solid fa-rotate text-emerald-600 text-sm mt-0.5 shrink-0"></i>
                                <span>Mọi thay đổi về giá bán, tồn kho hoặc mô tả sẽ được cập nhật đồng bộ tức thì trên sàn mua sắm FreshFruit.</span>
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
        function updateNameCounter(input) {
            const count = input.value.length;
            document.getElementById('nameCounter').innerText = count + '/120 ký tự';
        }

        function selectStorageTag(btn, val) {
            document.querySelectorAll('.storage-tag-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            document.getElementById('inputStorageTemp').value = val;
        }

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
            
            let shortUnit = "Đơn vị";
            if (unitName.includes("Hộp")) shortUnit = "Hộp";
            else if (unitName.includes("Kg")) shortUnit = "Kg";
            else if (unitName.includes("Quả")) shortUnit = "Quả";
            else if (unitName.includes("Giỏ")) shortUnit = "Giỏ";

            document.getElementById('unitStockSuffix').innerText = shortUnit;
            document.getElementById('unitThresholdSuffix').innerText = shortUnit;
        }

        function setStatus(statusVal, label) {
            document.getElementById('inputStatus').value = statusVal;
            const labels = label.parentElement.querySelectorAll('label');
            labels.forEach(l => {
                l.className = 'border border-slate-200 bg-white rounded-xl p-4 flex items-start gap-3 cursor-pointer transition';
            });
            if (statusVal === 'active') {
                label.className = 'border border-emerald-600 bg-emerald-50/40 rounded-xl p-4 flex items-start gap-3 cursor-pointer transition';
            } else {
                label.className = 'border border-amber-500 bg-amber-50/40 rounded-xl p-4 flex items-start gap-3 cursor-pointer transition';
            }
        }

        function autoFillDescSEO() {
            const name = document.getElementById('productNameInput').value;
            const desc = name + " chuẩn VietGAP thu hái từ sáng sớm tại vườn Đà Lạt. Vị thơm ngọt tự nhiên, thịt quả mọng nước, giàu Vitamin C & chất chống oxy hóa. Đóng gói đạt chuẩn chuỗi lạnh FreshCold 2H chuyển nhanh tới tận tay người tiêu dùng.";
            document.getElementById('productDescTextarea').value = desc;
        }

        function promptImage(index) {
            const input = document.getElementById('inputImgDetail' + index);
            const currentUrl = input.value;
            const newUrl = prompt("Nhập URL ảnh chi tiết góc chụp " + index + ":", currentUrl);
            if (newUrl && newUrl.trim() !== "") {
                input.value = newUrl.trim();
                document.getElementById('thumb' + index).src = newUrl.trim();
            }
        }

        function submitEditForm() {
            const form = document.getElementById('editProductForm');
            const name = document.getElementById('productNameInput').value;

            if (!name || name.trim() === "") {
                alert("Vui lòng nhập tên sản phẩm nông sản!");
                document.getElementById('productNameInput').focus();
                return;
            }

            form.submit();
        }

        document.addEventListener('DOMContentLoaded', () => {
            const nameInput = document.getElementById('productNameInput');
            if (nameInput) updateNameCounter(nameInput);
        });
    </script>
</body>
</html>

