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
    
    <link rel="dns-prefetch" href="https://cdn.tailwindcss.com">
    <!-- FontAwesome 6 Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Tailwind CSS (Non-blocking) -->
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

                    <!-- 1. DANH MỤC SẢN PHẨM (DANH SÁCH PHẲNG) -->
                    <div>
                        <div class="flex items-center justify-between mb-3.5">
                            <h4 class="text-[11px] font-black uppercase tracking-wider text-slate-500">
                                Danh Mục Sản Phẩm
                            </h4>
                            <span class="text-[10px] font-bold text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded-full">Tất cả</span>
                        </div>
                        <div class="space-y-2.5 text-xs max-h-72 overflow-y-auto pr-1">
                            <c:forEach var="cat" items="${listCategories}">
                                <label class="flex items-center justify-between cursor-pointer group select-none py-0.5">
                                    <div class="flex items-center gap-2.5 min-w-0 pr-2">
                                        <input type="checkbox" name="category" value="${cat.categoryId}" 
                                               ${selectedCategoriesList != null and (selectedCategoriesList.contains(cat.categoryId.toString()) or selectedCategoriesList.contains(cat.slug)) ? 'checked' : ''} 
                                               class="custom-checkbox">
                                        <span class="text-xs font-medium text-slate-700 group-hover:text-emerald-700 transition truncate" title="${cat.categoryName}">
                                            ${cat.categoryName}
                                        </span>
                                    </div>
                                    <span class="text-xs font-bold ${cat.productCount > 0 ? 'text-emerald-700 bg-emerald-50' : 'text-slate-400 bg-slate-50'} font-mono shrink-0 px-2 py-0.5 rounded-full group-hover:bg-emerald-50 group-hover:text-emerald-700 transition">
                                        ${cat.productCount}
                                    </span>
                                </label>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- 2. KHOẢNG GIÁ (2 ô nhập giá: từ ở trên đến ở dưới) -->
                    <div class="border-t border-slate-100 pt-5">
                        <h4 class="text-[11px] font-black uppercase tracking-wider text-slate-500 mb-3">
                            Khoảng Giá (VNĐ)
                        </h4>

                        <!-- 2 ô nhập Từ (ở trên) - Đến (ở dưới) -->
                        <div class="space-y-2.5 text-xs">
                            <div class="flex items-center gap-2 bg-slate-50 border border-slate-200 rounded-xl px-3 py-2.5 focus-within:border-emerald-600 focus-within:bg-white transition">
                                <span class="text-slate-400 text-xs font-semibold shrink-0 w-8">Từ:</span>
                                <input type="number" id="inputMinPrice" name="minPrice" 
                                       placeholder="Từ 0đ"
                                       min="0"
                                       value="${paramMinPrice != null ? paramMinPrice : ''}" 
                                       class="w-full bg-transparent font-bold text-slate-800 focus:outline-none text-xs">
                                <span class="text-xs text-slate-400 font-bold shrink-0">đ</span>
                            </div>
                            <div class="flex items-center gap-2 bg-slate-50 border border-slate-200 rounded-xl px-3 py-2.5 focus-within:border-emerald-600 focus-within:bg-white transition">
                                <span class="text-slate-400 text-xs font-semibold shrink-0 w-8">Đến:</span>
                                <input type="number" id="inputMaxPrice" name="maxPrice" 
                                       placeholder="Đến mức tối đa"
                                       min="0"
                                       value="${paramMaxPrice != null ? paramMaxPrice : ''}" 
                                       class="w-full bg-transparent font-bold text-slate-800 focus:outline-none text-xs">
                                <span class="text-xs text-slate-400 font-bold shrink-0">đ</span>
                            </div>
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
                        </h2>
                        <p class="text-xs text-slate-500 mt-0.5">
                            Cam kết 100% tươi sạch, chuẩn VietGAP từ nông trại đến bàn ăn
                        </p>
                    </div>

                    <!-- Sắp xếp & Chuyển đổi Grid / List -->
                    <div class="flex items-center gap-3 sm:gap-4 self-end sm:self-center">
                        <div class="flex items-center gap-2 text-xs">
                            <span class="text-slate-600 font-medium">Sắp xếp theo:</span>
                            <select onchange="changeCatalogSort(this.value);" 
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
                                                            <c:when test="${p.onPromotion or p.tag.startsWith('-')}">badge-sale</c:when>
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
                                                    <fmt:formatNumber value="${p.price}" pattern="#,###" />₫
                                                </span>
                                                <c:if test="${p.oldPrice > p.price}">
                                                    <span class="text-[11px] text-slate-400 line-through">
                                                        <fmt:formatNumber value="${p.oldPrice}" pattern="#,###" />₫
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

            </div>
        </div>
    </main>

    <!-- FOOTER CHUẨN ĐỒNG BỘ THƯƠNG HIỆU GỐC VƯỜN -->
    <jsp:include page="/views/common/site-footer.jsp" />

</body>
</html>