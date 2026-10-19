<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh Mục Nông Sản Tươi Sạch - Gốc Vườn Marketplace</title>
    
    <!-- Google Fonts: Inter & Plus Jakarta Sans -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- FontAwesome 6 Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        brand: {
                            DEFAULT: '#00652c',
                            dark: '#005323',
                            light: '#059669',
                            surface: '#f4f7f4'
                        }
                    },
                    fontFamily: {
                        sans: ['Plus Jakarta Sans', 'Inter', 'sans-serif']
                    }
                }
            }
        }
    </script>

    <!-- Custom Catalog CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/product-catalog.css">
    
    <!-- Custom Catalog JS -->
    <script src="${pageContext.request.contextPath}/assets/js/product-catalog.js" defer></script>
</head>
<body class="bg-[#f8fafc] text-slate-800 antialiased font-sans selection:bg-emerald-600 selection:text-white min-h-screen flex flex-col justify-between">

    <!-- Header Đồng Bộ Toàn Hệ Thống -->
    <jsp:include page="/views/common/header.jsp" />

    <!-- Breadcrumb điều hướng -->
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-5 pb-2 w-full">
        <nav class="flex items-center gap-2 text-xs text-slate-500">
            <a href="${pageContext.request.contextPath}/home" class="hover:text-emerald-700 transition">Trang chủ</a>
            <i class="fa-solid fa-chevron-right text-[9px] text-slate-400"></i>
            <a href="${pageContext.request.contextPath}/products" class="hover:text-emerald-700 transition">Cửa hàng</a>
            <i class="fa-solid fa-chevron-right text-[9px] text-slate-400"></i>
            <span class="text-slate-900 font-bold">Nông Sản Tươi Sạch</span>
        </nav>
    </div>

    <!-- MAIN BODY: 2 CỘT CHUẨN (BỘ LỌC BÊN TRÁI & LƯỚI SẢN PHẨM BÊN PHẢI) -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-5 w-full flex-1">
        <div class="grid grid-cols-1 lg:grid-cols-4 gap-6 xl:gap-8 items-start">

            <!-- ===============================================================
                 CỘT TRÁI: BỘ LỌC TÌM KIẾM (FILTERS SIDEBAR - 100% TIẾNG VIỆT)
                 =============================================================== -->
            <aside class="lg:col-span-1">
                <form action="${pageContext.request.contextPath}/products" method="GET" id="catalogFilterForm" 
                      class="bg-white rounded-3xl p-5 sm:p-6 border border-slate-200/90 shadow-[0_4px_20px_rgba(0,0,0,0.03)] space-y-6">
                    
                    <!-- Giữ lại keyword và sort nếu có -->
                    <c:if test="${not empty paramKeyword}">
                        <input type="hidden" name="keyword" value="${paramKeyword}">
                    </c:if>
                    <input type="hidden" name="sortBy" value="${paramSortBy}">

                    <!-- Filter Header -->
                    <div class="flex items-center justify-between pb-4 border-b border-slate-100">
                        <div class="flex items-center gap-2.5">
                            <i class="fa-solid fa-sliders text-[#00652c] text-sm"></i>
                            <span class="font-extrabold text-base text-slate-900 tracking-tight">Bộ Lọc Tìm Kiếm</span>
                        </div>
                        <a href="${pageContext.request.contextPath}/products" class="text-xs font-bold text-emerald-700 hover:text-emerald-800 hover:underline transition">
                            Thiết lập lại
                        </a>
                    </div>

                    <!-- 1. DANH MỤC SẢN PHẨM (Hiển thị các danh mục rõ ràng, không bị thanh cuộn đè số) -->
                    <div>
                        <h4 class="text-[11px] font-black uppercase tracking-wider text-slate-500 mb-3.5">
                            Danh Mục Sản Phẩm
                        </h4>
                        <div class="space-y-2.5 text-xs">
                            <c:forEach var="cat" items="${listCategories}">
                                <%-- Chỉ hiển thị các danh mục cha chính để sidebar gọn gàng, thoáng mát --%>
                                <c:if test="${empty cat.parentId}">
                                    <label class="flex items-center justify-between cursor-pointer group select-none py-0.5">
                                        <div class="flex items-center gap-2.5 min-w-0 pr-2">
                                            <input type="checkbox" name="category" value="${cat.categoryId}" 
                                                   ${selectedCategoriesList != null and (selectedCategoriesList.contains(String.valueOf(cat.categoryId)) or selectedCategoriesList.contains(cat.slug)) ? 'checked' : ''} 
                                                   class="custom-checkbox">
                                            <span class="text-xs font-medium text-slate-700 group-hover:text-emerald-700 transition truncate">
                                                ${cat.categoryName}
                                            </span>
                                        </div>
                                        <span class="text-xs font-bold text-slate-400 font-mono shrink-0 px-2 py-0.5 rounded-full bg-slate-50 group-hover:bg-emerald-50 group-hover:text-emerald-700 transition">
                                            ${cat.productCount}
                                        </span>
                                    </label>
                                </c:if>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- 2. KHOẢNG GIÁ (Đã bỏ hoàn toàn 2 thanh kéo, thay bằng 2 ô nhập + chọn nhanh tiện lợi) -->
                    <div class="border-t border-slate-100 pt-5">
                        <h4 class="text-[11px] font-black uppercase tracking-wider text-slate-500 mb-3">
                            Khoảng Giá (VNĐ)
                        </h4>

                        <!-- 2 ô nhập Từ - Đến -->
                        <div class="flex items-center gap-2 text-xs mb-3">
                            <div class="flex items-center gap-1.5 bg-slate-50 border border-slate-200 rounded-xl px-2.5 py-2 flex-1 focus-within:border-emerald-600 focus-within:bg-white transition">
                                <span class="text-slate-400 text-[11px] font-medium shrink-0">Từ:</span>
                                <input type="number" id="inputMinPrice" name="minPrice" 
                                       placeholder="45.000"
                                       value="${paramMinPrice != null ? paramMinPrice : ''}" 
                                       class="w-full bg-transparent font-bold text-slate-800 focus:outline-none text-xs">
                                <span class="text-[10px] text-slate-400 font-bold shrink-0">đ</span>
                            </div>
                            <span class="text-slate-400 text-xs font-bold">-</span>
                            <div class="flex items-center gap-1.5 bg-slate-50 border border-slate-200 rounded-xl px-2.5 py-2 flex-1 focus-within:border-emerald-600 focus-within:bg-white transition">
                                <span class="text-slate-400 text-[11px] font-medium shrink-0">Đến:</span>
                                <input type="number" id="inputMaxPrice" name="maxPrice" 
                                       placeholder="750.000"
                                       value="${paramMaxPrice != null ? paramMaxPrice : ''}" 
                                       class="w-full bg-transparent font-bold text-slate-800 focus:outline-none text-xs">
                                <span class="text-[10px] text-slate-400 font-bold shrink-0">đ</span>
                            </div>
                        </div>

                        <!-- 4 nút chọn nhanh khoảng giá chuẩn e-commerce -->
                        <div class="grid grid-cols-2 gap-1.5">
                            <button type="button" class="quick-price-btn" data-min="0" data-max="100000">
                                Dưới 100k
                            </button>
                            <button type="button" class="quick-price-btn" data-min="100000" data-max="300000">
                                100k - 300k
                            </button>
                            <button type="button" class="quick-price-btn" data-min="300000" data-max="500000">
                                300k - 500k
                            </button>
                            <button type="button" class="quick-price-btn" data-min="500000" data-max="2000000">
                                Trên 500k
                            </button>
                        </div>
                    </div>

                    <!-- 3. ĐÁNH GIÁ CỦA KHÁCH -->
                    <div class="border-t border-slate-100 pt-5">
                        <h4 class="text-[11px] font-black uppercase tracking-wider text-slate-500 mb-3.5">
                            Đánh Giá Của Khách
                        </h4>
                        <div class="space-y-2.5 text-xs">
                            <!-- 5 Sao -->
                            <label class="flex items-center justify-between cursor-pointer group select-none">
                                <div class="flex items-center gap-2">
                                    <input type="radio" name="rating" value="5" ${paramRating == 5 ? 'checked' : ''} class="custom-radio">
                                    <div class="flex text-amber-400 text-xs gap-0.5">
                                        <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                    </div>
                                </div>
                                <span class="text-slate-500 group-hover:text-slate-800 transition font-medium">5 Sao</span>
                            </label>

                            <!-- Từ 4 sao trở lên -->
                            <label class="flex items-center justify-between cursor-pointer group select-none">
                                <div class="flex items-center gap-2">
                                    <input type="radio" name="rating" value="4" ${paramRating == 4 ? 'checked' : ''} class="custom-radio">
                                    <div class="flex text-amber-400 text-xs gap-0.5">
                                        <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-regular fa-star text-slate-300"></i>
                                    </div>
                                </div>
                                <span class="text-slate-500 group-hover:text-slate-800 transition font-medium">Từ 4 sao trở lên</span>
                            </label>

                            <!-- Từ 3 sao trở lên -->
                            <label class="flex items-center justify-between cursor-pointer group select-none">
                                <div class="flex items-center gap-2">
                                    <input type="radio" name="rating" value="3" ${paramRating == 3 ? 'checked' : ''} class="custom-radio">
                                    <div class="flex text-amber-400 text-xs gap-0.5">
                                        <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-regular fa-star text-slate-300"></i><i class="fa-regular fa-star text-slate-300"></i>
                                    </div>
                                </div>
                                <span class="text-slate-500 group-hover:text-slate-800 transition font-medium">Từ 3 sao trở lên</span>
                            </label>

                            <!-- Tất cả -->
                            <label class="flex items-center justify-between cursor-pointer group select-none pt-0.5">
                                <div class="flex items-center gap-2">
                                    <input type="radio" name="rating" value="" ${empty paramRating ? 'checked' : ''} class="custom-radio">
                                    <span class="text-xs text-slate-600 font-medium group-hover:text-slate-900">Tất cả đánh giá</span>
                                </div>
                            </label>
                        </div>
                    </div>

                    <!-- 4. TÌNH TRẠNG HÀNG -->
                    <div class="border-t border-slate-100 pt-5">
                        <h4 class="text-[11px] font-black uppercase tracking-wider text-slate-500 mb-3.5">
                            Tình Trạng Hàng
                        </h4>
                        <div class="space-y-2.5 text-xs">
                            <label class="flex items-center justify-between cursor-pointer group select-none">
                                <div class="flex items-center gap-2.5">
                                    <input type="checkbox" name="availability" value="in_stock" 
                                           ${paramAvailability eq 'in_stock' ? 'checked' : ''} 
                                           class="custom-checkbox">
                                    <span class="font-medium text-slate-700 group-hover:text-emerald-700 transition">Còn Hàng</span>
                                </div>
                                <span class="text-xs font-bold text-slate-400 font-mono px-2 py-0.5 rounded-full bg-slate-50">
                                    ${inStockCount > 0 ? inStockCount : totalProducts}
                                </span>
                            </label>
                            <label class="flex items-center justify-between cursor-pointer group select-none">
                                <div class="flex items-center gap-2.5">
                                    <input type="checkbox" name="seasonal" value="pre_order" class="custom-checkbox">
                                    <span class="font-medium text-slate-700 group-hover:text-emerald-700 transition">Hàng Đặt Trước</span>
                                </div>
                                <span class="text-xs font-bold text-slate-400 font-mono px-2 py-0.5 rounded-full bg-slate-50">
                                    3
                                </span>
                            </label>
                        </div>
                    </div>

                    <!-- 5. VÙNG TRỒNG / XUẤT XỨ -->
                    <div class="border-t border-slate-100 pt-5">
                        <h4 class="text-[11px] font-black uppercase tracking-wider text-slate-500 mb-3.5">
                            Vùng Trồng / Xuất Xứ
                        </h4>
                        <div class="space-y-2.5 text-xs">
                            <c:choose>
                                <c:when test="${not empty listOrigins}">
                                    <c:forEach var="entry" items="${listOrigins}">
                                        <label class="flex items-center justify-between cursor-pointer group select-none py-0.5">
                                            <div class="flex items-center gap-2.5 min-w-0 pr-2">
                                                <input type="checkbox" name="origin" value="${entry.key}" 
                                                       ${selectedOriginsList != null and selectedOriginsList.contains(entry.key) ? 'checked' : ''} 
                                                       class="custom-checkbox">
                                                <span class="font-medium text-slate-700 group-hover:text-emerald-700 transition truncate">
                                                    ${entry.key}
                                                </span>
                                            </div>
                                            <span class="text-xs font-bold text-slate-400 font-mono shrink-0 px-2 py-0.5 rounded-full bg-slate-50">
                                                ${entry.value}
                                            </span>
                                        </label>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <label class="flex items-center justify-between cursor-pointer group select-none">
                                        <div class="flex items-center gap-2.5">
                                            <input type="checkbox" name="origin" value="Đà Lạt" class="custom-checkbox">
                                            <span class="font-medium text-slate-700">Đà Lạt - Lâm Đồng</span>
                                        </div>
                                        <span class="text-xs font-bold text-slate-400 font-mono px-2 py-0.5 rounded-full bg-slate-50">3</span>
                                    </label>
                                    <label class="flex items-center justify-between cursor-pointer group select-none">
                                        <div class="flex items-center gap-2.5">
                                            <input type="checkbox" name="origin" value="Tiền Giang" class="custom-checkbox">
                                            <span class="font-medium text-slate-700">Miền Tây Nam Bộ</span>
                                        </div>
                                        <span class="text-xs font-bold text-slate-400 font-mono px-2 py-0.5 rounded-full bg-slate-50">3</span>
                                    </label>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <!-- NÚT ÁP DỤNG BỘ LỌC (MÀU XANH LÁ ĐẬM CHỦ ĐẠO #00652C) -->
                    <div class="pt-2">
                        <button type="submit" class="w-full py-3.5 bg-[#00652c] hover:bg-[#005323] text-white font-bold text-xs uppercase tracking-wider rounded-2xl shadow-md shadow-emerald-900/10 hover:shadow-lg transition-all duration-200 cursor-pointer flex items-center justify-center gap-2">
                            <i class="fa-solid fa-sliders text-xs"></i>
                            <span>Áp Dụng Bộ Lọc</span>
                        </button>
                    </div>
                </form>
            </aside>

            <!-- ===============================================================
                 CỘT PHẢI: KẾT QUẢ & LƯỚI SẢN PHẨM 4 CỘT CÂN ĐỐI
                 =============================================================== -->
            <div class="lg:col-span-3 space-y-6" id="catalogContainer">

                <!-- TOP BAR: KẾT QUẢ TÌM THẤY & SẮP XẾP & VIEW SWITCHER (100% TIẾNG VIỆT) -->
                <div class="bg-white rounded-2xl sm:rounded-3xl p-4 sm:p-5 border border-slate-200/90 shadow-[0_2px_12px_rgba(0,0,0,0.02)] flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                    
                    <!-- Tiêu đề kết quả tiếng Việt -->
                    <div>
                        <h2 class="text-base sm:text-lg font-black text-slate-900 tracking-tight flex items-center gap-2">
                            <span>Tìm thấy ${totalProducts} sản phẩm tươi sạch</span>
                            <c:if test="${not empty paramKeyword}">
                                <span class="text-xs font-normal text-slate-500">(từ khóa: "<strong class="text-emerald-700">${paramKeyword}</strong>")</span>
                            </c:if>
                        </h2>
                        <p class="text-xs text-slate-500 mt-0.5">
                            Cam kết 100% tươi sạch, chuẩn VietGAP từ nông trại đến bàn ăn
                        </p>
                    </div>

                    <!-- Sắp xếp & Chuyển đổi Grid / List -->
                    <div class="flex items-center gap-3 sm:gap-4 self-end sm:self-center">
                        <div class="flex items-center gap-2 text-xs">
                            <span class="text-slate-600 font-medium">Sắp xếp theo:</span>
                            <select onchange="location.href='${pageContext.request.contextPath}/products?sortBy=' + this.value + '&keyword=${paramKeyword}&minPrice=${paramMinPrice}&maxPrice=${paramMaxPrice}&rating=${paramRating}&availability=${paramAvailability}';" 
                                    class="bg-slate-50 hover:bg-slate-100 border border-slate-200 rounded-xl px-3 py-1.5 text-xs font-bold text-slate-800 focus:outline-none focus:border-emerald-600 transition cursor-pointer">
                                <option value="featured" ${paramSortBy eq 'featured' ? 'selected' : ''}>Nổi Bật Nhất</option>
                                <option value="price_asc" ${paramSortBy eq 'price_asc' ? 'selected' : ''}>Giá: Thấp đến Cao</option>
                                <option value="price_desc" ${paramSortBy eq 'price_desc' ? 'selected' : ''}>Giá: Cao đến Thấp</option>
                                <option value="rating" ${paramSortBy eq 'rating' ? 'selected' : ''}>Đánh Giá Cao Nhất</option>
                                <option value="newest" ${paramSortBy eq 'newest' ? 'selected' : ''}>Mới Nhất</option>
                            </select>
                        </div>

                        <!-- Chế độ xem Lưới / Danh sách -->
                        <div class="flex items-center gap-1 border-l border-slate-200 pl-3">
                            <button type="button" id="gridViewBtn" class="w-8 h-8 rounded-lg flex items-center justify-center text-emerald-700 hover:bg-slate-100 transition cursor-pointer" title="Xem dạng lưới 4 cột">
                                <i class="fa-solid fa-table-cells-large text-sm"></i>
                            </button>
                            <button type="button" id="listViewBtn" class="w-8 h-8 rounded-lg flex items-center justify-center text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition cursor-pointer" title="Xem dạng danh sách">
                                <i class="fa-solid fa-list text-sm"></i>
                            </button>
                        </div>
                    </div>
                </div>

                <!-- LƯỚI SẢN PHẨM: 4 CỘT CHUẨN XÁC, CÂN ĐỐI, NÚT + THÊM NGAY NGẮN -->
                <div id="productGrid" class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-4 sm:gap-5">
                    <c:choose>
                        <c:when test="${not empty listProducts}">
                            <c:forEach var="p" items="${listProducts}">
                                <div class="catalog-product-card group">
                                    <div class="flex flex-col">
                                        <!-- Khung ảnh với Badges & Nút Trái Tim -->
                                        <div class="catalog-img-wrap">
                                            <a href="${pageContext.request.contextPath}/detail?id=${p.id}" class="block w-full h-full">
                                                <img src="${p.image}" alt="${p.name}" loading="lazy">
                                            </a>

                                            <!-- Badges góc trên bên trái -->
                                            <div class="badge-stack">
                                                <c:if test="${not empty p.tag}">
                                                    <span class="card-badge-pill 
                                                        <c:choose>
                                                            <c:when test="${p.tag eq 'HỮU CƠ'}">badge-organic</c:when>
                                                            <c:when test="${p.tag eq 'ĐẶC SẢN'}">badge-local</c:when>
                                                            <c:when test="${p.tag.startsWith('-')}">badge-sale</c:when>
                                                            <c:otherwise>badge-fresh</c:otherwise>
                                                        </c:choose>">
                                                        ${p.tag}
                                                    </span>
                                                </c:if>
                                                <c:if test="${not empty p.secondaryTag}">
                                                    <span class="card-badge-pill badge-sale">
                                                        ${p.secondaryTag}
                                                    </span>
                                                </c:if>
                                            </div>
                                        </div>

                                        <!-- Nội dung thẻ sản phẩm -->
                                        <div class="card-body-content">
                                            <!-- Đánh giá sao: ★ 5,0 (87) -->
                                            <div class="flex items-center gap-1.5 text-xs text-slate-700 font-semibold mb-1">
                                                <i class="fa-solid fa-star text-amber-400 text-[11px]"></i>
                                                <span class="font-extrabold text-slate-800"><fmt:formatNumber value="${p.rating}" pattern="#0.0" /></span>
                                                <span class="text-slate-400 font-normal text-[11px]">(${p.reviewsCount})</span>
                                            </div>

                                            <!-- Tên sản phẩm hiển thị vừa vặn 2 dòng, không bị cắt xấu -->
                                            <h3 class="font-bold text-sm text-slate-900 group-hover:text-emerald-700 transition line-clamp-2 min-h-[2.5rem] leading-snug" title="${p.name}">
                                                <a href="${pageContext.request.contextPath}/detail?id=${p.id}">${p.name}</a>
                                            </h3>

                                            <!-- Vùng trồng / Xuất xứ -->
                                            <p class="text-[11px] text-slate-500 truncate mt-1 mb-2">
                                                ${p.origin}
                                            </p>
                                        </div>
                                    </div>

                                    <!-- CHÂN THẺ: GIÁ BÁN & NÚT + THÊM CĂN CHỈNH HOÀN HẢO -->
                                    <div class="card-footer-action pt-2.5 border-t border-slate-100 flex items-center justify-between mt-auto">
                                        <div class="flex flex-col min-w-0 pr-1">
                                            <div class="flex items-baseline gap-1.5 flex-wrap">
                                                <span class="font-black text-slate-900 text-sm sm:text-base">
                                                    <c:choose>
                                                        <c:when test="${p.price >= 1000}">
                                                            <fmt:formatNumber value="${p.price}" pattern="#,###" />₫
                                                        </c:when>
                                                        <c:otherwise>
                                                            $<fmt:formatNumber value="${p.price}" pattern="#,##0.00" />
                                                        </c:otherwise>
                                                    </c:choose>
                                                </span>
                                                <c:if test="${p.oldPrice > p.price}">
                                                    <span class="text-[11px] text-slate-400 line-through">
                                                        <c:choose>
                                                            <c:when test="${p.oldPrice >= 1000}">
                                                                <fmt:formatNumber value="${p.oldPrice}" pattern="#,###" />₫
                                                            </c:when>
                                                            <c:otherwise>
                                                                $<fmt:formatNumber value="${p.oldPrice}" pattern="#,##0.00" />
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </c:if>
                                            </div>
                                            <span class="text-[10px] font-bold text-slate-400">
                                                / ${p.unit}
                                            </span>
                                        </div>

                                        <!-- Nút + Thêm bo tròn màu xanh lá chủ đạo, thẳng hàng, gọn gàng -->
                                        <form action="${pageContext.request.contextPath}/cart/add" method="POST" class="form-add-cart shrink-0 m-0">
                                            <input type="hidden" name="csrfToken" value="${sessionScope.cartCsrfToken}">
                                            <input type="hidden" name="variantId" value="${p.defaultVariantId}">
                                            <input type="hidden" name="quantity" value="1">
                                            <button type="submit" ${p.defaultVariantId le 0 ? 'disabled' : ''} 
                                                    class="btn-card-add disabled:opacity-40 disabled:cursor-not-allowed" 
                                                    title="${p.defaultVariantId gt 0 ? 'Thêm vào giỏ hàng' : 'Hết hàng'}">
                                                <i class="fa-solid fa-plus text-[10px]"></i>
                                                <span>Thêm</span>
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <!-- Empty State khi không tìm thấy sản phẩm -->
                            <div class="col-span-full py-16 px-6 text-center bg-white rounded-3xl border border-slate-200/90 shadow-xs">
                                <div class="w-16 h-16 rounded-full bg-emerald-50 text-emerald-700 flex items-center justify-center mx-auto mb-4 text-2xl shadow-inner">
                                    <i class="fa-solid fa-leaf"></i>
                                </div>
                                <h3 class="text-base font-extrabold text-slate-900 mb-1">Không tìm thấy sản phẩm phù hợp</h3>
                                <p class="text-xs text-slate-500 max-w-sm mx-auto mb-5 leading-relaxed">
                                    Không có sản phẩm nào thỏa mãn toàn bộ tiêu chí lọc hiện tại. Vui lòng điều chỉnh lại khoảng giá hoặc bỏ bớt các tiêu chí lọc.
                                </p>
                                <a href="${pageContext.request.contextPath}/products" class="inline-flex items-center gap-2 px-5 py-2.5 bg-[#00652c] hover:bg-[#005323] text-white rounded-xl text-xs font-bold transition shadow-xs">
                                    <i class="fa-solid fa-rotate-left text-xs"></i>
                                    <span>Xóa tất cả bộ lọc</span>
                                </a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- ===============================================================
                     THANH PHÂN TRANG (PAGINATION BAR) 100% TIẾNG VIỆT
                     =============================================================== -->
                <div class="bg-white rounded-2xl sm:rounded-3xl p-4 sm:p-5 border border-slate-200/90 shadow-[0_2px_12px_rgba(0,0,0,0.02)] flex flex-col sm:flex-row items-center justify-between gap-4">
                    
                    <!-- Hiển thị số lượng -->
                    <span class="text-xs text-slate-600 font-medium">
                        Hiển thị <strong>${totalProducts > 0 ? ((currentPage - 1) * pageSize + 1) : 0}-${currentPage * pageSize > totalProducts ? totalProducts : currentPage * pageSize}</strong> trên tổng <strong>${totalProducts}</strong> sản phẩm
                    </span>

                    <!-- Các nút trang -->
                    <c:if test="${totalPages > 1}">
                        <div class="flex items-center gap-1.5 flex-wrap justify-center">
                            <!-- Nút Trang trước -->
                            <c:if test="${currentPage > 1}">
                                <a href="${pageContext.request.contextPath}/products?page=${currentPage - 1}&keyword=${paramKeyword}&minPrice=${paramMinPrice}&maxPrice=${paramMaxPrice}&rating=${paramRating}&availability=${paramAvailability}&sortBy=${paramSortBy}" 
                                   class="catalog-page-btn text-xs">
                                    &larr; Trang trước
                                </a>
                            </c:if>

                            <!-- Số trang -->
                            <c:forEach var="pageNum" begin="1" end="${totalPages}">
                                <c:choose>
                                    <c:when test="${pageNum == currentPage}">
                                        <span class="catalog-page-btn active text-xs">${pageNum}</span>
                                    </c:when>
                                    <c:when test="${pageNum <= 3 or pageNum == totalPages or (pageNum >= currentPage - 1 and pageNum <= currentPage + 1)}">
                                        <a href="${pageContext.request.contextPath}/products?page=${pageNum}&keyword=${paramKeyword}&minPrice=${paramMinPrice}&maxPrice=${paramMaxPrice}&rating=${paramRating}&availability=${paramAvailability}&sortBy=${paramSortBy}" 
                                           class="catalog-page-btn text-xs">
                                            ${pageNum}
                                        </a>
                                    </c:when>
                                    <c:when test="${pageNum == 4 and totalPages > 5 and currentPage > 3}">
                                        <span class="px-1 text-slate-400 text-xs">...</span>
                                    </c:when>
                                </c:choose>
                            </c:forEach>

                            <!-- Nút Trang sau -->
                            <c:if test="${currentPage < totalPages}">
                                <a href="${pageContext.request.contextPath}/products?page=${currentPage + 1}&keyword=${paramKeyword}&minPrice=${paramMinPrice}&maxPrice=${paramMaxPrice}&rating=${paramRating}&availability=${paramAvailability}&sortBy=${paramSortBy}" 
                                   class="catalog-page-btn text-xs">
                                    Trang sau &rarr;
                                </a>
                            </c:if>
                        </div>
                    </c:if>
                </div>

            </div>
        </div>
    </main>

    <!-- FOOTER CHUẨN ĐỒNG BỘ THƯƠNG HIỆU GỐC VƯỜN -->
    <footer class="bg-white border-t border-slate-200/90 pt-12 pb-8 text-slate-600 text-xs mt-12">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-8 pb-10 border-b border-slate-100">
                
                <!-- Col 1: Brand Info -->
                <div class="lg:col-span-2 space-y-3">
                    <div class="flex items-center gap-2">
                        <div class="w-8 h-8 rounded-full bg-emerald-50 flex items-center justify-center p-1 border border-emerald-100">
                            <svg viewBox="0 0 100 100" class="w-full h-full">
                                <circle cx="50" cy="56" r="32" fill="#16a34a"/>
                                <path d="M 28 45 Q 36 34 50 34" stroke="#ffffff" stroke-width="6" stroke-linecap="round" fill="none"/>
                                <circle cx="68" cy="46" r="5" fill="#ffffff"/>
                                <path d="M 52 26 C 58 16 68 14 74 18 C 74 24 64 32 52 26 Z" fill="#f97316"/>
                            </svg>
                        </div>
                        <span class="text-xl font-black text-slate-900 tracking-tight">Gốc<span class="text-[#00652c]">Vườn</span></span>
                    </div>
                    <p class="text-slate-500 max-w-sm leading-relaxed text-xs">
                        Hệ thống kết nối nông trại trái cây tươi sạch chuẩn VietGAP &amp; GlobalGAP trực tiếp tới gia đình bạn.
                    </p>
                    <div class="flex items-center gap-3 pt-1 text-slate-400">
                        <span class="text-xs font-semibold text-slate-500"><i class="fa-solid fa-shield-halved text-emerald-600 mr-1"></i> Cam kết đổi trả 100% nếu trái cây không đạt độ tươi ngon.</span>
                    </div>
                </div>

                <!-- Col 2: Quick Links -->
                <div>
                    <h4 class="font-extrabold text-slate-900 text-xs uppercase tracking-wider mb-3">Danh Mục Mua Sắm</h4>
                    <ul class="space-y-2 text-slate-500">
                        <li><a href="${pageContext.request.contextPath}/products" class="hover:text-emerald-700 transition">Tất Cả Trái Cây</a></li>
                        <c:forEach var="c" items="${listCategories}" end="3">
                            <c:if test="${empty c.parentId}">
                                <li><a href="${pageContext.request.contextPath}/products?category=${c.slug}" class="hover:text-emerald-700 transition">${c.categoryName}</a></li>
                            </c:if>
                        </c:forEach>
                    </ul>
                </div>

                <!-- Col 3: Customer Service -->
                <div>
                    <h4 class="font-extrabold text-slate-900 text-xs uppercase tracking-wider mb-3">Hỗ Trợ Khách Hàng</h4>
                    <ul class="space-y-2 text-slate-500">
                        <li><a href="#" class="hover:text-emerald-700 transition">Hướng Dẫn Mua Hàng</a></li>
                        <li><a href="#" class="hover:text-emerald-700 transition">Chính Sách Giao Hàng Siêu Tốc</a></li>
                        <li><a href="#" class="hover:text-emerald-700 transition">Chính Sách Đổi Trả 1-1</a></li>
                        <li><a href="#" class="hover:text-emerald-700 transition">Điều Khoản Dịch Vụ</a></li>
                    </ul>
                </div>

                <!-- Col 4: Contact & Payment -->
                <div>
                    <h4 class="font-extrabold text-slate-900 text-xs uppercase tracking-wider mb-3">Hotline &amp; Hỗ Trợ</h4>
                    <ul class="space-y-2 text-slate-500 mb-4">
                        <li class="flex items-center gap-2"><i class="fa-solid fa-phone text-emerald-700"></i> <strong>1900 6868</strong> (8:00 - 21:00)</li>
                        <li class="flex items-center gap-2"><i class="fa-solid fa-envelope text-emerald-700"></i> support@gocvuon.vn</li>
                        <li class="flex items-center gap-2"><i class="fa-solid fa-location-dot text-emerald-700"></i> Lâm Đồng &amp; TP.HCM</li>
                    </ul>
                </div>
            </div>

            <div class="pt-6 flex flex-col sm:flex-row items-center justify-between gap-4 text-slate-400 text-[11px]">
                <p>&copy; 2026 Gốc Vườn Marketplace. Bảo lưu toàn bộ quyền.</p>
                <div class="flex items-center gap-4">
                    <span>100% Nông sản kiểm định chuẩn VietGAP</span>
                </div>
            </div>
        </div>
    </footer>

</body>
</html>
