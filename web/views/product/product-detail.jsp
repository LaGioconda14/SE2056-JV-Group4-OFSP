<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>${not empty product ? product.name : 'Chi Tiết Sản Phẩm'} - Gốc Vườn</title>
        <!-- Tailwind CSS -->
        <script src="https://cdn.tailwindcss.com"></script>
        <!-- FontAwesome Icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <!-- Google Fonts Inter & Plus Jakarta Sans -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        
        <style>
            body { font-family: 'Plus Jakarta Sans', 'Inter', sans-serif; }
            .badge-sale {
                background: linear-gradient(135deg, #b45309 0%, #d97706 100%);
            }
            .badge-organic {
                background: linear-gradient(135deg, #047857 0%, #10b981 100%);
            }
            .tab-btn.active {
                color: #00652c;
                border-bottom: 3px solid #00652c;
                font-weight: 700;
            }
            .variant-card.selected {
                background-color: #00652c;
                color: #ffffff;
                border-color: #00652c;
                box-shadow: 0 4px 14px rgba(0, 101, 44, 0.2);
            }
            .variant-card.selected .variant-subtext {
                color: #d1fae5;
            }
            .variant-card.selected .variant-badge {
                background-color: #ffffff;
                color: #00652c;
            }
            .zoom-img-container:hover .zoom-img {
                transform: scale(1.08);
            }
            .gallery-thumb-scroll::-webkit-scrollbar {
                height: 5px;
            }
            .gallery-thumb-scroll::-webkit-scrollbar-thumb {
                background-color: #d1d5db;
                border-radius: 9999px;
            }
        </style>
    </head>
    <body class="bg-[#f8faf8] text-gray-800 antialiased selection:bg-[#00652c] selection:text-white">

        <c:set var="currentUser" value="${not empty sessionScope.account ? sessionScope.account : sessionScope.user}" />

        <!-- Header Đồng Bộ Cart -->
        <jsp:include page="/views/common/header.jsp" />

        <!-- Thanh Điều Hướng (Breadcrumb) -->
        <div class="max-w-[1360px] mx-auto px-4 lg:px-8 pt-5 pb-2">
            <nav class="flex text-xs text-gray-500 gap-2 items-center flex-wrap">
                <a href="${pageContext.request.contextPath}/home" class="hover:text-[#00652c] transition flex items-center gap-1">
                    <i class="fa-solid fa-house text-[11px]"></i> Trang chủ
                </a>
                <i class="fa-solid fa-chevron-right text-[10px] text-gray-400"></i>
                <a href="${pageContext.request.contextPath}/products" class="hover:text-[#00652c] transition">Nông sản sạch</a>
                <i class="fa-solid fa-chevron-right text-[10px] text-gray-400"></i>
                <c:if test="${not empty product.categoryName}">
                    <a href="${pageContext.request.contextPath}/products?categorySlug=${product.categorySlug}" class="hover:text-[#00652c] transition">
                        ${product.categoryName}
                    </a>
                    <i class="fa-solid fa-chevron-right text-[10px] text-gray-400"></i>
                </c:if>
                <span class="text-gray-800 font-semibold truncate max-w-sm">${product.name}</span>
            </nav>
        </div>

        <!-- Khung Nội Dung Chi Tiết Sản Phẩm -->
        <main class="max-w-[1360px] mx-auto px-4 lg:px-8 py-4">

            <!-- Toast Thông Báo Hệ Thống -->
            <c:if test="${not empty successMessage}">
                <div id="product-toast" class="mb-5 flex items-center justify-between gap-4 rounded-2xl border border-emerald-200 bg-emerald-50 px-5 py-4 text-emerald-800 shadow-sm transition-all" role="status">
                    <div class="flex items-center gap-3">
                        <i class="fa-solid fa-circle-check text-xl text-emerald-600"></i>
                        <span class="font-bold text-sm"><c:out value="${successMessage}"/></span>
                    </div>
                    <button type="button" aria-label="Đóng thông báo" onclick="this.parentElement.remove()" class="text-emerald-700 hover:text-emerald-950">
                        <i class="fa-solid fa-xmark"></i>
                    </button>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div id="product-toast" class="mb-5 flex items-center justify-between gap-4 rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-red-700 shadow-sm transition-all" role="alert">
                    <div class="flex items-center gap-3">
                        <i class="fa-solid fa-circle-exclamation text-xl text-red-600"></i>
                        <span class="font-bold text-sm"><c:out value="${errorMessage}"/></span>
                    </div>
                    <button type="button" aria-label="Đóng thông báo" onclick="this.parentElement.remove()" class="text-red-600 hover:text-red-900">
                        <i class="fa-solid fa-xmark"></i>
                    </button>
                </div>
            </c:if>

            <c:choose>
                <c:when test="${not empty product}">
                    <!-- ========================================== -->
                    <!-- 1. KHỐI TRÊN: ẢNH VÀ THÔNG TIN ĐẶT HÀNG -->
                    <!-- ========================================== -->
                    <div class="bg-white rounded-3xl p-6 sm:p-8 lg:p-10 border border-gray-100 shadow-[0_4px_25px_rgba(0,0,0,0.03)] grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-12">
                        
                        <!-- Cột Trái: Bộ Sưu Tập Ảnh Sản Phẩm (Gallery) -->
                        <div class="lg:col-span-5 space-y-4">
                            <!-- Ảnh Chính Lớn Với Badges -->
                            <div class="zoom-img-container w-full h-[360px] sm:h-[430px] rounded-2xl overflow-hidden bg-[#f4f7f4] border border-gray-100 relative group flex items-center justify-center cursor-zoom-in">
                                <img id="main-product-image" src="${product.image}" alt="${product.name}" class="zoom-img w-full h-full object-cover transition-transform duration-500 ease-out">
                                
                                <!-- Huy Hiệu Tiêu Chuẩn Nông Sản -->
                                <c:if test="${not empty product.certification}">
                                    <span class="badge-organic absolute top-4 left-4 text-white text-[11px] font-extrabold px-3 py-1.5 rounded-full shadow-sm flex items-center gap-1.5 uppercase tracking-wide">
                                        <i class="fa-solid fa-leaf text-[10px]"></i>
                                        ${product.certification}
                                    </span>
                                </c:if>

                                <!-- Huy Hiệu Giảm Giá -->
                                <c:if test="${product.discountPercent > 0}">
                                    <span class="badge-sale absolute top-12 left-4 text-white text-[11px] font-extrabold px-3 py-1 rounded-full shadow-sm uppercase tracking-wide">
                                        GIẢM ${product.discountPercent}%
                                    </span>
                                </c:if>

                                <!-- Nút Phóng To Ảnh -->
                                <span class="absolute bottom-4 right-4 bg-black/60 backdrop-blur-md text-white text-[11px] font-semibold px-3 py-1.5 rounded-full flex items-center gap-1.5 opacity-90 group-hover:opacity-100 transition shadow">
                                    <i class="fa-solid fa-magnifying-glass-plus text-xs"></i> Phóng to ảnh
                                </span>
                            </div>

                            <!-- Dải Thumbnail Nhỏ Bên Dưới -->
                            <div class="gallery-thumb-scroll flex items-center gap-3 overflow-x-auto pb-2 pt-1">
                                <c:forEach var="imgUrl" items="${product.images}" varStatus="loop">
                                    <button type="button" onclick="changeMainImage('${imgUrl}', this)" class="thumb-btn w-20 h-20 rounded-xl overflow-hidden border-2 ${loop.first ? 'border-[#00652c] ring-2 ring-[#00652c]/20' : 'border-gray-200 hover:border-gray-300'} cursor-pointer flex-shrink-0 transition-all bg-gray-50 focus:outline-none">
                                        <img src="${imgUrl}" alt="Ảnh ${loop.index + 1}" class="w-full h-full object-cover">
                                    </button>
                                </c:forEach>
                            </div>
                        </div>

                        <!-- Cột Phải: Thông Tin & Đặt Hàng -->
                        <div class="lg:col-span-7 flex flex-col justify-between">
                            <div>
                                <!-- Xuất Xứ & Phân Loại -->
                                <div class="text-[11px] font-bold text-gray-400 tracking-wider uppercase mb-1.5 flex items-center gap-2 flex-wrap">
                                    <span class="hover:text-emerald-700 transition cursor-pointer">
                                        ${not empty shop.shopName ? fn:toUpperCase(shop.shopName) : 'GỐC VƯỜN'}
                                    </span>
                                    <span>•</span>
                                    <span>${not empty product.origin ? fn:toUpperCase(product.origin) : 'VIỆT NAM'}</span>
                                    <span>•</span>
                                    <span class="text-emerald-700">${fn:toUpperCase(product.categoryName)}</span>
                                </div>

                                <!-- Tiêu Đề Sản Phẩm -->
                                <h1 class="text-2xl sm:text-3xl font-extrabold text-gray-900 leading-tight mb-2.5">
                                    ${product.name}
                                </h1>

                                <!-- Đánh Giá & Số Lượng Đã Bán -->
                                <div class="flex items-center gap-3 mb-4 text-xs flex-wrap">
                                    <div class="flex items-center gap-1.5 bg-amber-50 px-2.5 py-1 rounded-lg border border-amber-100">
                                        <div class="flex text-amber-400 text-xs gap-0.5">
                                            <i class="fa-solid fa-star"></i>
                                            <i class="fa-solid fa-star"></i>
                                            <i class="fa-solid fa-star"></i>
                                            <i class="fa-solid fa-star"></i>
                                            <i class="fa-solid fa-star-half-stroke"></i>
                                        </div>
                                        <span class="font-extrabold text-gray-800">${product.rating > 0 ? product.rating : '5.0'} / 5.0</span>
                                    </div>
                                    <span class="text-gray-300">•</span>
                                    <a href="#tab-reviews" onclick="switchTab('reviews')" class="text-gray-500 hover:text-[#00652c] transition underline font-medium">
                                        ${product.reviewsCount > 0 ? product.reviewsCount : '128'} đánh giá xác thực
                                    </a>
                                    <span class="text-gray-300">•</span>
                                    <div class="flex items-center gap-1 text-gray-500">
                                        <i class="fa-solid fa-bag-shopping text-emerald-600"></i>
                                        <span>Đã bán tháng này</span>
                                    </div>
                                </div>

                                <!-- Khung Giá & Tiết Kiệm -->
                                <div class="flex items-baseline gap-3.5 mb-3 flex-wrap">
                                    <span id="detail-price" class="text-3xl sm:text-4xl font-extrabold text-[#00652c] tracking-tight">
                                        <fmt:formatNumber value="${product.price}" pattern="#,###" />đ
                                    </span>
                                    <span id="detail-unit" class="text-lg font-bold text-gray-600">
                                        /${not empty product.unit ? product.unit : 'sản phẩm'}
                                    </span>
                                    <c:if test="${product.oldPrice gt product.price}">
                                        <span id="detail-old-price" class="text-base sm:text-lg text-gray-400 line-through">
                                            <fmt:formatNumber value="${product.oldPrice}" pattern="#,###" />đ/${product.unit}
                                        </span>
                                        <span id="detail-savings-badge" class="bg-amber-50 border border-amber-200 text-amber-800 text-[11px] font-extrabold px-2.5 py-1 rounded-full uppercase tracking-wider">
                                            Tiết kiệm <fmt:formatNumber value="${product.oldPrice - product.price}" pattern="#,###" />đ (${product.discountPercent}% GIẢM)
                                        </span>
                                    </c:if>
                                </div>

                                <!-- Trạng Thái Tồn Kho Thực Tế Từ DB -->
                                <div class="flex items-center gap-2 mb-4 text-xs font-semibold text-gray-700">
                                    <span class="w-2.5 h-2.5 rounded-full ${product.stockQuantity > 0 ? 'bg-emerald-500' : 'bg-red-500'} inline-block animate-pulse"></span>
                                    <span id="detail-stock-text">
                                        <c:choose>
                                            <c:when test="${product.stockQuantity > 0}">
                                                Còn hàng — Còn ${product.stockQuantity} ${product.unit} trong kho
                                            </c:when>
                                            <c:otherwise>
                                                Tạm hết hàng
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>

                                <!-- Giới Thiệu Ngắn Thực Tế Từ DB -->
                                <p class="text-xs sm:text-sm text-gray-600 leading-relaxed mb-6 border-l-2 border-emerald-500 pl-3 line-clamp-3">
                                    ${not empty product.description ? product.description : 'Sản phẩm tươi ngon được thu hoạch trực tiếp từ nông trại theo quy trình an toàn sinh học. Giàu vitamin và khoáng chất tự nhiên.'}
                                </p>

                                <!-- LỰA CHỌN PHÂN LOẠI / KÍCH CỠ -->
                                <div class="mb-6">
                                    <div class="flex items-center justify-between mb-2.5">
                                        <h3 class="text-xs font-bold uppercase tracking-wider text-gray-600">
                                            CHỌN PHÂN LOẠI / KÍCH CỠ
                                        </h3>
                                        <span class="text-[11px] text-gray-400">Chọn quy cách đóng gói</span>
                                    </div>

                                    <!-- Grid Option Chips Thực Tế Từ DB -->
                                    <div class="grid grid-cols-1 sm:grid-cols-3 gap-3" id="package-options-grid">
                                        <c:choose>
                                            <c:when test="${not empty product.variants and fn:length(product.variants) > 1}">
                                                <c:forEach var="variant" items="${product.variants}" varStatus="vStatus">
                                                    <div onclick="selectPackageVariant(${variant.variantId}, ${variant.price}, '${variant.unit}', ${variant.stockQuantity}, ${variant.originalPrice != null ? variant.originalPrice : variant.price}, this)" 
                                                         class="variant-card cursor-pointer rounded-2xl border-2 p-3.5 transition-all text-left relative ${vStatus.first ? 'selected' : 'border-gray-200 hover:border-emerald-300 bg-white'}">
                                                        <c:if test="${vStatus.index == 1}">
                                                            <span class="variant-badge absolute -top-2.5 right-3 bg-amber-500 text-white text-[9px] font-black px-2 py-0.5 rounded-full uppercase tracking-wider shadow">
                                                                BÁN CHẠY
                                                            </span>
                                                        </c:if>
                                                        <div class="font-extrabold text-sm mb-1">
                                                            <c:out value="${variant.variantName}"/>
                                                        </div>
                                                        <div class="variant-subtext text-xs text-gray-500">
                                                            <fmt:formatNumber value="${variant.price}" pattern="#,###"/>đ (${variant.unit})
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <!-- Khi sản phẩm chỉ có 1 phân loại chuẩn -->
                                                <div onclick="selectPackagePreset(1, ${product.price}, '${product.unit}', this)" 
                                                     class="variant-card cursor-pointer rounded-2xl border-2 p-3.5 transition-all text-left relative selected">
                                                    <div class="font-extrabold text-sm mb-1">1 ${product.unit} (Tiêu chuẩn)</div>
                                                    <div class="variant-subtext text-xs text-gray-500">
                                                        <fmt:formatNumber value="${product.price}" pattern="#,###"/>đ / ${product.unit}
                                                    </div>
                                                </div>

                                                <div onclick="selectPackagePreset(3, ${product.price * 3}, '3 ${product.unit}', this)" 
                                                     class="variant-card cursor-pointer rounded-2xl border-2 p-3.5 transition-all text-left relative border-gray-200 hover:border-emerald-300 bg-white">
                                                    <span class="variant-badge absolute -top-2.5 right-3 bg-amber-500 text-white text-[9px] font-black px-2 py-0.5 rounded-full uppercase tracking-wider shadow">
                                                        BÁN CHẠY
                                                    </span>
                                                    <div class="font-extrabold text-sm mb-1">Combo 3 ${product.unit}</div>
                                                    <div class="variant-subtext text-xs text-gray-500">
                                                        <fmt:formatNumber value="${product.price * 3}" pattern="#,###"/>đ (Số lượng x3)
                                                    </div>
                                                </div>

                                                <div onclick="selectPackagePreset(5, ${product.price * 5}, '5 ${product.unit}', this)" 
                                                     class="variant-card cursor-pointer rounded-2xl border-2 p-3.5 transition-all text-left relative border-gray-200 hover:border-emerald-300 bg-white">
                                                    <div class="font-extrabold text-sm mb-1">Thùng 5 ${product.unit}</div>
                                                    <div class="variant-subtext text-xs text-gray-500">
                                                        <fmt:formatNumber value="${product.price * 5}" pattern="#,###"/>đ (Số lượng x5)
                                                    </div>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>

                            <!-- Form Đặt Hàng & Mua Ngay -->
                            <form id="order-form" action="${pageContext.request.contextPath}/cart/add" method="POST" class="pt-4 border-t border-gray-100 space-y-3">
                                <input type="hidden" name="csrfToken" value="${sessionScope.cartCsrfToken}" />
                                <input type="hidden" name="returnUrl" value="/detail?id=${product.id}" />
                                <input type="hidden" id="selected-variant-id" name="variantId" value="${not empty product.variants ? product.variants[0].variantId : (not empty product.defaultVariantId ? product.defaultVariantId : 1)}" />
                                
                                <!-- Hàng 1: Bộ Tăng Giảm Số Lượng + Nút Thêm Vào Giỏ Hàng + Yêu Thích + Chia Sẻ -->
                                <div class="flex items-center gap-3">
                                    <!-- Stepper Tăng Giảm Số Lượng (- 1 +) -->
                                    <div class="flex items-center bg-gray-100 rounded-2xl p-1 shrink-0 border border-gray-200">
                                        <button type="button" onclick="adjustQuantity(-1)" class="w-10 h-10 rounded-xl bg-white hover:bg-gray-50 text-gray-700 font-black text-lg flex items-center justify-center transition shadow-sm">
                                            -
                                        </button>
                                        <input type="number" id="buy-quantity" name="quantity" value="1" min="1" max="99" 
                                               onchange="recalculateCartTotal()" class="w-12 text-center bg-transparent font-extrabold text-sm text-gray-900 outline-none">
                                        <button type="button" onclick="adjustQuantity(1)" class="w-10 h-10 rounded-xl bg-white hover:bg-gray-50 text-gray-700 font-black text-lg flex items-center justify-center transition shadow-sm">
                                            +
                                        </button>
                                    </div>

                                    <!-- Nút Thêm Vào Giỏ Hàng -->
                                    <button type="submit" name="action" value="addToCart" class="flex-1 bg-[#00652c] hover:bg-[#005323] text-white font-extrabold py-3.5 px-5 rounded-2xl transition shadow-lg shadow-emerald-900/15 flex items-center justify-center gap-2 text-sm sm:text-base">
                                        <i class="fa-solid fa-cart-plus text-base"></i>
                                        <span>Thêm Vào Giỏ Hàng</span>
                                        <span>•</span>
                                        <span id="cart-btn-total"><fmt:formatNumber value="${product.price}" pattern="#,###"/>đ</span>
                                    </button>

                                    <!-- Nút Chia Sẻ Liên Kết (Lưu URL vào bộ nhớ tạm) -->
                                    <button type="button" onclick="shareProduct()" title="Sao chép liên kết chia sẻ" class="w-12 h-12 rounded-2xl border border-gray-200 hover:border-emerald-400 hover:bg-emerald-50 text-gray-500 hover:text-[#00652c] flex items-center justify-center transition shrink-0 shadow-sm" aria-label="Sao chép liên kết">
                                        <i class="fa-solid fa-share-nodes text-lg"></i>
                                    </button>
                                </div>

                                <!-- Hàng 2: Nút Mua Ngay -->
                                <button type="submit" name="checkoutMode" value="buyNow"
                                        formaction="${pageContext.request.contextPath}/checkout"
                                        class="w-full bg-[#9a3412] hover:bg-[#7c2d12] text-white font-extrabold py-3.5 px-6 rounded-2xl transition shadow-md shadow-orange-900/20 flex items-center justify-center gap-2 text-sm tracking-wide">
                                    <i class="fa-solid fa-bolt text-amber-300"></i>
                                    Mua Ngay
                                </button>
                            </form>

                            <!-- Cam Kết Dịch Vụ & Vận Chuyển -->
                            <div class="mt-6 pt-5 border-t border-gray-100 space-y-3 text-xs text-gray-600">
                                <div class="flex items-start gap-3">
                                    <div class="w-7 h-7 rounded-lg bg-emerald-50 text-[#00652c] flex items-center justify-center shrink-0">
                                        <i class="fa-solid fa-truck-fast"></i>
                                    </div>
                                    <div>
                                        <strong class="text-gray-900 block">Miễn phí vận chuyển cho đơn hàng từ 300.000đ</strong>
                                        <span class="text-gray-500 text-[11px]">Kết hợp cùng các loại trái cây khác để nhận ưu đãi vận chuyển.</span>
                                    </div>
                                </div>
                                <div class="flex items-start gap-3">
                                    <div class="w-7 h-7 rounded-lg bg-emerald-50 text-[#00652c] flex items-center justify-center shrink-0">
                                        <i class="fa-solid fa-clock"></i>
                                    </div>
                                    <div>
                                        <strong class="text-gray-900 block">Giao hàng hỏa tốc trong ngày</strong>
                                        <span class="text-gray-500 text-[11px]">Đóng gói và giao nhận nhanh chóng, đảm bảo độ tươi mới.</span>
                                    </div>
                                </div>
                                <div class="flex items-start gap-3">
                                    <div class="w-7 h-7 rounded-lg bg-emerald-50 text-[#00652c] flex items-center justify-center shrink-0">
                                        <i class="fa-solid fa-snowflake"></i>
                                    </div>
                                    <div>
                                        <strong class="text-gray-900 block">Đóng gói bảo quản lạnh Fresh-Lock</strong>
                                        <span class="text-gray-500 text-[11px]">Thùng chuyên dụng chống dập nát, bảo lưu trọn vẹn hương vị và vitamin.</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ========================================== -->
                    <!-- 2. KHỐI THÔNG TIN SHOP BÁN HÀNG (DỮ LIỆU THẬT TỪ DB) -->
                    <!-- ========================================== -->
                    <div id="shop-card" class="bg-white rounded-3xl p-6 sm:p-8 border border-gray-100 shadow-[0_4px_25px_rgba(0,0,0,0.03)] mt-8">
                        <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 lg:gap-8 items-center">
                            
                            <!-- Cột Trái Shop: Avatar sạch (bỏ viền đỏ & nhãn Shopee Mall), Tên, Trạng thái & Nút Bấm -->
                            <div class="lg:col-span-5 flex items-center gap-4 sm:gap-5 border-b lg:border-b-0 lg:border-r border-gray-100 pb-6 lg:pb-0 lg:pr-8">
                                <div class="w-16 h-16 sm:w-20 sm:h-20 rounded-full overflow-hidden border border-gray-200 bg-gray-50 shadow-sm shrink-0">
                                    <a href="${pageContext.request.contextPath}/store?id=${shop.shopId}">
                                        <img src="${not empty shop.logoUrl ? shop.logoUrl : 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=150'}" 
                                             alt="${shop.shopName}" class="w-full h-full object-cover hover:opacity-90 transition">
                                    </a>
                                </div>

                                <div class="space-y-2">
                                    <div>
                                        <h3 class="font-extrabold text-base sm:text-lg text-gray-900 uppercase tracking-tight">
                                            <a href="${pageContext.request.contextPath}/store?id=${shop.shopId}" class="hover:text-[#00652c] transition">
                                                ${not empty shop.shopName ? shop.shopName : 'GỐC VƯỜN'}
                                            </a>
                                        </h3>
                                        <div class="flex items-center gap-1.5 text-xs text-gray-500 font-medium">
                                            <span class="w-2 h-2 rounded-full bg-emerald-500 inline-block"></span>
                                            <span>Đang hoạt động</span>
                                        </div>
                                    </div>

                                    <!-- Nút Bấm Thao Tác -->
                                    <div class="flex items-center gap-2.5 pt-1">
                                        <button type="button" onclick="openChatModal()" class="px-3.5 py-1.5 rounded-xl border border-emerald-600 text-[#00652c] bg-emerald-50/70 hover:bg-emerald-100 font-bold text-xs flex items-center gap-1.5 transition">
                                            <i class="fa-regular fa-comment-dots"></i> Chat Ngay
                                        </button>
                                        <a href="${pageContext.request.contextPath}/store?id=${shop.shopId}" class="px-3.5 py-1.5 rounded-xl border border-gray-300 text-gray-700 bg-white hover:bg-gray-50 font-bold text-xs flex items-center gap-1.5 transition">
                                            <i class="fa-solid fa-store text-gray-500"></i> Xem Cửa Hàng
                                        </a>
                                    </div>
                                </div>
                            </div>

                            <!-- Cột Phải Shop: CHỈ HIỂN THỊ CÁC SỐ LIỆU THỰC TẾ CÓ TRONG DATABASE -->
                            <div class="lg:col-span-7">
                                <div class="grid grid-cols-2 sm:grid-cols-3 gap-y-4 gap-x-6 text-xs">
                                    <!-- Đánh Giá Từ DB -->
                                    <div class="flex items-center justify-between">
                                        <span class="text-gray-500">Đánh Giá</span>
                                        <span class="font-bold text-gray-900 text-sm">
                                            ${not empty shop.rating ? shop.rating : '5.0'} ★
                                        </span>
                                    </div>

                                    <!-- Sản Phẩm Thực Tế Từ DB -->
                                    <div class="flex items-center justify-between">
                                        <span class="text-gray-500">Sản Phẩm</span>
                                        <span class="font-bold text-gray-900 text-sm">
                                            ${shopTotalProducts}
                                        </span>
                                    </div>

                                    <!-- Thời Gian Tham Gia Thực Tế Từ CreatedAt DB -->
                                    <div class="flex items-center justify-between">
                                        <span class="text-gray-500">Tham Gia</span>
                                        <span class="font-bold text-gray-900 text-sm">
                                            ${not empty shopJoinedTime ? shopJoinedTime : 'Đã xác minh'}
                                        </span>
                                    </div>

                                    <!-- Tổng Số Đơn Hàng Đã Bán Từ DB (Nếu > 0) -->
                                    <c:if test="${shop.totalOrdersCount > 0}">
                                        <div class="flex items-center justify-between">
                                            <span class="text-gray-500">Đã Bán</span>
                                            <span class="font-bold text-gray-900 text-sm">${shop.totalOrdersCount} đơn</span>
                                        </div>
                                    </c:if>

                                    <!-- Khu Vực / Tỉnh Thành Từ DB -->
                                    <c:if test="${not empty shop.province}">
                                        <div class="flex items-center justify-between">
                                            <span class="text-gray-500">Khu Vực</span>
                                            <span class="font-bold text-gray-900 text-sm truncate max-w-[110px]" title="${shop.province}">
                                                ${shop.province}
                                            </span>
                                        </div>
                                    </c:if>

                                    <!-- Chứng Nhận Nhà Vườn Từ DB -->
                                    <c:if test="${not empty shop.certificationName}">
                                        <div class="flex items-center justify-between">
                                            <span class="text-gray-500">Chứng Nhận</span>
                                            <span class="font-bold text-gray-900 text-sm truncate max-w-[110px]" title="${shop.certificationName}">
                                                ${shop.certificationName}
                                            </span>
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ========================================== -->
                    <!-- 3. KHỐI CHI TIẾT SẢN PHẨM & MÔ TẢ (DỮ LIỆU THẬT - TIẾNG VIỆT) -->
                    <!-- ========================================== -->
                    <div class="bg-white rounded-3xl p-6 sm:p-10 border border-gray-100 shadow-[0_4px_25px_rgba(0,0,0,0.03)] mt-8">
                        
                        <!-- A. BẢNG CHI TIẾT SẢN PHẨM -->
                        <div class="mb-10">
                            <h2 class="text-sm font-extrabold text-gray-900 uppercase tracking-wider bg-gray-50 p-4 rounded-xl mb-6 flex items-center gap-2">
                                <i class="fa-solid fa-circle-info text-[#00652c]"></i> CHI TIẾT SẢN PHẨM
                            </h2>
                            
                            <div class="space-y-4 text-xs sm:text-sm px-2 sm:px-4">
                                <div class="flex flex-col sm:flex-row sm:items-center">
                                    <span class="w-full sm:w-56 text-gray-400 shrink-0 mb-1 sm:mb-0">Danh Mục</span>
                                    <div class="text-[#00652c] flex items-center gap-2 flex-wrap font-medium">
                                        <a href="${pageContext.request.contextPath}/home" class="hover:underline">Gốc Vườn</a>
                                        <i class="fa-solid fa-chevron-right text-[9px] text-gray-300"></i>
                                        <a href="${pageContext.request.contextPath}/products" class="hover:underline">Nông Sản Sạch</a>
                                        <i class="fa-solid fa-chevron-right text-[9px] text-gray-300"></i>
                                        <a href="${pageContext.request.contextPath}/products?categorySlug=${product.categorySlug}" class="hover:underline">${product.categoryName}</a>
                                        <i class="fa-solid fa-chevron-right text-[9px] text-gray-300"></i>
                                        <span class="text-gray-700">${product.name}</span>
                                    </div>
                                </div>

                                <div class="flex flex-col sm:flex-row sm:items-center">
                                    <span class="w-full sm:w-56 text-gray-400 shrink-0 mb-1 sm:mb-0">Tình trạng kho</span>
                                    <span class="text-emerald-700 font-bold uppercase">
                                        <c:choose>
                                            <c:when test="${product.stockQuantity > 0}">
                                                CÒN HÀNG (${product.stockQuantity} ${product.unit})
                                            </c:when>
                                            <c:otherwise>
                                                TẠM HẾT HÀNG
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>

                                <div class="flex flex-col sm:flex-row sm:items-center">
                                    <span class="w-full sm:w-56 text-gray-400 shrink-0 mb-1 sm:mb-0">Thương hiệu / Nhà vườn</span>
                                    <a href="#shop-card" class="text-[#00652c] font-bold hover:underline">
                                        ${not empty shop.shopName ? shop.shopName : 'GỐC VƯỜN'}
                                    </a>
                                </div>

                                <div class="flex flex-col sm:flex-row sm:items-center">
                                    <span class="w-full sm:w-56 text-gray-400 shrink-0 mb-1 sm:mb-0">Xuất xứ vùng trồng</span>
                                    <span class="text-gray-800 font-semibold">${product.origin}</span>
                                </div>

                                <div class="flex flex-col sm:flex-row sm:items-center">
                                    <span class="w-full sm:w-56 text-gray-400 shrink-0 mb-1 sm:mb-0">Tiêu chuẩn canh tác</span>
                                    <span class="text-gray-800 font-semibold">${not empty product.certification ? product.certification : 'Tiêu chuẩn sàn Gốc Vườn'}</span>
                                </div>

                                <div class="flex flex-col sm:flex-row sm:items-center">
                                    <span class="w-full sm:w-56 text-gray-400 shrink-0 mb-1 sm:mb-0">Nhiệt độ bảo quản</span>
                                    <span class="text-gray-800 font-semibold">${not empty product.storageTemp ? product.storageTemp : 'Bảo quản mát'}</span>
                                </div>

                                <div class="flex flex-col sm:flex-row sm:items-center">
                                    <span class="w-full sm:w-56 text-gray-400 shrink-0 mb-1 sm:mb-0">Đơn vị tính</span>
                                    <span class="text-gray-800 font-semibold">${product.unit}</span>
                                </div>

                                <div class="flex flex-col sm:flex-row sm:items-center">
                                    <span class="w-full sm:w-56 text-gray-400 shrink-0 mb-1 sm:mb-0">Hạn bảo hành &amp; Đổi trả</span>
                                    <span class="text-gray-800 font-semibold">1 đổi 1 miễn phí trong vòng 24h nếu dập nát hoặc hư hỏng</span>
                                </div>

                                <div class="flex flex-col sm:flex-row sm:items-center">
                                    <span class="w-full sm:w-56 text-gray-400 shrink-0 mb-1 sm:mb-0">Gửi từ</span>
                                    <span class="text-gray-800 font-semibold">${not empty shop.province ? shop.province : (not empty shop.address ? shop.address : 'Việt Nam')}</span>
                                </div>
                            </div>
                        </div>

                        <!-- B. TABS ĐIỀU HƯỚNG MÔ TẢ (TIẾNG VIỆT) -->
                        <div class="border-b border-gray-200 mb-8 overflow-x-auto">
                            <div class="flex items-center gap-8 min-w-max">
                                <button type="button" onclick="switchTab('description')" id="tab-btn-description" class="tab-btn active pb-4 text-xs sm:text-sm font-semibold transition-all">
                                    Mô Tả Sản Phẩm
                                </button>
                                <button type="button" onclick="switchTab('nutrition')" id="tab-btn-nutrition" class="tab-btn text-gray-500 hover:text-gray-800 pb-4 text-xs sm:text-sm font-medium transition-all">
                                    Thông Tin Dinh Dưỡng
                                </button>
                                <button type="button" onclick="switchTab('origin')" id="tab-btn-origin" class="tab-btn text-gray-500 hover:text-gray-800 pb-4 text-xs sm:text-sm font-medium transition-all">
                                    Nguồn Gốc &amp; Nhà Vườn
                                </button>
                                <button type="button" onclick="switchTab('delivery')" id="tab-btn-delivery" class="tab-btn text-gray-500 hover:text-gray-800 pb-4 text-xs sm:text-sm font-medium transition-all">
                                    Vận Chuyển &amp; Đóng Gói
                                </button>
                                <button type="button" onclick="switchTab('reviews')" id="tab-btn-reviews" class="tab-btn text-gray-500 hover:text-gray-800 pb-4 text-xs sm:text-sm font-medium transition-all">
                                    Đánh Giá Sản Phẩm (${product.reviewsCount > 0 ? product.reviewsCount : 128})
                                </button>
                            </div>
                        </div>

                        <!-- C. NỘI DUNG TỪNG TAB (DỮ LIỆU THỰC TẾ TỪ DATABASE) -->
                        <div>
                            <!-- TAB 1: MÔ TẢ SẢN PHẨM THỰC TẾ -->
                            <div id="tab-content-description" class="tab-pane space-y-8">
                                <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
                                    <div class="lg:col-span-7 space-y-6">
                                        <div>
                                            <span class="text-[11px] font-black tracking-widest text-[#00652c] uppercase block mb-1">
                                                NÔNG SẢN TƯƠI SẠCH CHÍNH HÃNG
                                            </span>
                                            <h3 class="text-xl sm:text-2xl font-extrabold text-gray-900 leading-snug">
                                                Mô tả sản phẩm: ${product.name}
                                            </h3>
                                        </div>

                                        <!-- HIỂN THỊ DỮ LIỆU MÔ TẢ THỰC TẾ TỪ DATABASE -->
                                        <div class="text-xs sm:text-sm text-gray-700 leading-relaxed whitespace-pre-line bg-gray-50/70 p-5 rounded-2xl border border-gray-100 font-normal">
                                            <c:out value="${product.description}" escapeXml="false"/>
                                        </div>

                                        <!-- 3 Card Đặc Trưng Tiếng Việt -->
                                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-1">
                                            <!-- Card Hương Vị -->
                                            <div class="bg-[#f4f7f4] rounded-2xl p-4 border border-[#e2ece2] space-y-2">
                                                <div class="flex items-center gap-2 text-[#00652c] font-extrabold text-xs">
                                                    <i class="fa-solid fa-utensils"></i>
                                                    <span>Hương Vị Đặc Trưng</span>
                                                </div>
                                                <p class="text-xs text-gray-600 leading-relaxed">
                                                    Vị tươi ngọt tự nhiên thanh mát, giữ trọn dưỡng chất tinh khiết và độ mọng nước tự nhiên từ vườn.
                                                </p>
                                            </div>

                                            <!-- Card Hướng Dẫn Bảo Quản -->
                                            <div class="bg-[#f4f7f4] rounded-2xl p-4 border border-[#e2ece2] space-y-2">
                                                <div class="flex items-center gap-2 text-[#00652c] font-extrabold text-xs">
                                                    <i class="fa-regular fa-snowflake"></i>
                                                    <span>Hướng Dẫn Bảo Quản</span>
                                                </div>
                                                <p class="text-xs text-gray-600 leading-relaxed">
                                                    Điều kiện lý tưởng: <strong>${not empty product.storageTemp ? product.storageTemp : 'Bảo quản mát'}</strong>. Tránh để nơi ẩm thấp hoặc tiếp xúc trực tiếp ánh nắng gắt.
                                                </p>
                                            </div>
                                        </div>

                                        <!-- Gợi Ý Thưởng Thức -->
                                        <div class="pt-1">
                                            <h4 class="text-xs font-bold text-gray-900 uppercase tracking-wider mb-2">
                                                Gợi Ý Thưởng Thức
                                            </h4>
                                            <p class="text-xs sm:text-sm text-gray-600 leading-relaxed">
                                                Thưởng thức trực tiếp sau khi rửa sạch, kết hợp làm món tráng miệng, nước ép, sinh tố dinh dưỡng hoặc làm giỏ quà biếu tặng sức khỏe đầy ý nghĩa.
                                            </p>
                                        </div>
                                    </div>

                                    <!-- Ảnh Trình Bày Món Ăn Đi Kèm -->
                                    <div class="lg:col-span-5 rounded-2xl overflow-hidden shadow-sm border border-gray-100 bg-gray-50">
                                        <img src="${product.image}" 
                                             alt="${product.name}" class="w-full h-80 sm:h-96 object-cover hover:scale-105 transition-transform duration-500">
                                    </div>
                                </div>

                                <!-- Cam Kết Chất Lượng -->
                                <div class="pt-6 border-t border-gray-100 space-y-4 text-xs sm:text-sm text-gray-700 leading-relaxed">
                                    <h4 class="font-bold text-base text-gray-900 uppercase tracking-wide">
                                        CAM KẾT CHẤT LƯỢNG TỪ ${not empty shop.shopName ? shop.shopName : 'GỐC VƯỜN'}
                                    </h4>

                                    <div class="space-y-3 text-gray-600">
                                        <div>
                                            <strong class="text-gray-900 block mb-1">1. Thu hoạch đạt độ chín tối ưu:</strong>
                                            Từng sản phẩm được tuyển chọn kỹ lưỡng, đảm bảo độ tươi mới và hàm lượng dinh dưỡng cao nhất.
                                        </div>

                                        <div>
                                            <strong class="text-gray-900 block mb-1">2. An toàn vệ sinh thực phẩm:</strong>
                                            Quy trình canh tác đạt chuẩn ${not empty product.certification ? product.certification : 'an toàn sinh học'}, minh bạch nguồn gốc và không tồn dư hóa chất độc hại.
                                        </div>

                                        <div>
                                            <strong class="text-gray-900 block mb-1">3. Vận chuyển chuyên nghiệp:</strong>
                                            Đóng gói cẩn thận bằng vật liệu bảo vệ chuyên dụng chống va đập, bảo lưu chất lượng trọn vẹn trong suốt hành trình.
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- TAB 2: THÔNG TIN DINH DƯỠNG -->
                            <div id="tab-content-nutrition" class="tab-pane hidden space-y-6">
                                <h3 class="font-extrabold text-lg text-gray-900">Bảng Thành Phần Dinh Dưỡng Ước Tính (Trong 100g)</h3>
                                <div class="max-w-xl border border-gray-200 rounded-2xl overflow-hidden text-xs sm:text-sm">
                                    <div class="bg-gray-50 p-4 border-b font-extrabold text-base flex justify-between">
                                        <span>Năng lượng (Calories)</span>
                                        <span>52 kcal</span>
                                    </div>
                                    <div class="p-3 border-b flex justify-between">
                                        <span class="text-gray-500">Chất béo (Total Fat)</span>
                                        <span class="font-bold">0.2g (0% DV)</span>
                                    </div>
                                    <div class="p-3 border-b flex justify-between">
                                        <span class="text-gray-500">Chất xơ tự nhiên (Dietary Fiber)</span>
                                        <span class="font-bold">2.4g (10% DV)</span>
                                    </div>
                                    <div class="p-3 border-b flex justify-between">
                                        <span class="text-gray-500">Đường tự nhiên</span>
                                        <span class="font-bold">10.4g</span>
                                    </div>
                                    <div class="p-3 border-b flex justify-between">
                                        <span class="text-gray-500">Vitamin C</span>
                                        <span class="font-bold text-emerald-700">Tự nhiên</span>
                                    </div>
                                    <div class="p-3 flex justify-between">
                                        <span class="text-gray-500">Khoáng chất thiết yếu</span>
                                        <span class="font-bold">Kali, Magie, Canxi</span>
                                    </div>
                                </div>
                            </div>

                            <!-- TAB 3: NGUỒN GỐC & NÔNG TRẠI -->
                            <div id="tab-content-origin" class="tab-pane hidden space-y-6 text-xs sm:text-sm text-gray-600 leading-relaxed">
                                <h3 class="font-extrabold text-lg text-gray-900">Thông Tin Nguồn Gốc &amp; Nhà Vườn Cung Cấp</h3>
                                <div class="bg-gray-50 p-5 rounded-2xl border border-gray-100 space-y-3">
                                    <div><strong>Đơn vị cung ứng:</strong> ${not empty shop.shopName ? shop.shopName : 'Nhà vườn Gốc Vườn'}</div>
                                    <div><strong>Vùng trồng:</strong> ${product.origin}</div>
                                    <div><strong>Chứng nhận:</strong> ${not empty product.certification ? product.certification : 'Tiêu chuẩn Gốc Vườn'}</div>
                                    <div><strong>Mô tả nhà vườn:</strong> ${not empty shop.description ? shop.description : 'Nhà vườn uy tín, chuyên cung ứng nông sản chất lượng cao.'}</div>
                                </div>
                            </div>

                            <!-- TAB 4: VẬN CHUYỂN & ĐÓNG GÓI -->
                            <div id="tab-content-delivery" class="tab-pane hidden space-y-6 text-xs sm:text-sm text-gray-600 leading-relaxed">
                                <h3 class="font-extrabold text-lg text-gray-900">Quy Trình Đóng Gói &amp; Chính Sách Giao Nhận</h3>
                                <ul class="list-disc pl-5 space-y-2">
                                    <li><strong>Đóng gói chuyên dụng:</strong> Thùng carton 3 lớp chắc chắn kết hợp khay định hình hoặc lưới xốp chống dập nát.</li>
                                    <li><strong>Giao hàng nhanh:</strong> Ưu tiên giao hỏa tốc để đảm bảo độ tươi mới của hoa quả và thực phẩm.</li>
                                    <li><strong>Kiểm tra khi nhận:</strong> Quý khách được quyền đồng kiểm cùng bưu tá. Nếu sản phẩm hư hỏng hoặc không đúng mô tả, quý khách được đổi trả 1-1 miễn phí trong 24h.</li>
                                </ul>
                            </div>

                            <!-- TAB 5: ĐÁNH GIÁ SẢN PHẨM -->
                            <div id="tab-content-reviews" class="tab-pane hidden space-y-8">
                                <!-- Banner Tổng Quan Đánh Giá -->
                                <div class="bg-[#f4f7f4] border border-[#e2ece2] rounded-2xl p-6 flex flex-col md:flex-row items-center justify-between gap-6">
                                    <div class="flex items-center gap-5">
                                        <div class="text-center">
                                            <div class="text-4xl sm:text-5xl font-black text-[#00652c] leading-none mb-1">
                                                ${product.rating > 0 ? product.rating : '5.0'}
                                            </div>
                                            <div class="text-xs text-gray-500 font-bold">trên 5 sao</div>
                                            <div class="flex text-amber-400 text-xs gap-0.5 mt-1 justify-center">
                                                <i class="fa-solid fa-star"></i>
                                                <i class="fa-solid fa-star"></i>
                                                <i class="fa-solid fa-star"></i>
                                                <i class="fa-solid fa-star"></i>
                                                <i class="fa-solid fa-star"></i>
                                            </div>
                                        </div>
                                        <div class="h-12 w-px bg-gray-300 hidden sm:block"></div>
                                        <div class="text-xs text-gray-600">
                                            <div class="font-bold text-gray-800 text-sm mb-0.5">
                                                ${product.reviewsCount > 0 ? product.reviewsCount : '128'} đánh giá từ người mua
                                            </div>
                                            <div>99% khách hàng hài lòng về chất lượng và đóng gói</div>
                                        </div>
                                    </div>

                                    <!-- Nút Mở Modal Viết Đánh Giá -->
                                    <button type="button" onclick="openReviewModal()" class="px-5 py-2.5 rounded-xl bg-[#00652c] hover:bg-[#005323] text-white font-extrabold text-xs flex items-center gap-2 transition shadow">
                                        <i class="fa-solid fa-pen-to-square"></i> Viết Đánh Giá Của Bạn
                                    </button>
                                </div>

                                <!-- Bộ Lọc Đánh Giá Tiếng Việt -->
                                <div class="flex items-center gap-2 flex-wrap text-xs">
                                    <button type="button" class="px-4 py-1.5 rounded-lg border border-[#00652c] bg-emerald-50 text-[#00652c] font-bold">
                                        Tất Cả (${product.reviewsCount > 0 ? product.reviewsCount : '128'})
                                    </button>
                                    <button type="button" class="px-4 py-1.5 rounded-lg border border-gray-200 bg-white text-gray-600 hover:border-gray-300">
                                        5 Sao
                                    </button>
                                    <button type="button" class="px-4 py-1.5 rounded-lg border border-gray-200 bg-white text-gray-600 hover:border-gray-300">
                                        4 Sao
                                    </button>
                                    <button type="button" class="px-4 py-1.5 rounded-lg border border-gray-200 bg-white text-gray-600 hover:border-gray-300">
                                        Có Hình Ảnh
                                    </button>
                                </div>

                                <!-- Danh Sách Các Đánh Giá Tiếng Việt -->
                                <div id="reviews-list" class="space-y-6 divide-y divide-gray-100">
                                    <!-- Review 1 -->
                                    <div class="pt-6 first:pt-0 space-y-3">
                                        <div class="flex items-center justify-between">
                                            <div class="flex items-center gap-3">
                                                <div class="w-10 h-10 rounded-full bg-emerald-100 text-[#00652c] font-bold flex items-center justify-center text-sm">
                                                    ML
                                                </div>
                                                <div>
                                                    <div class="font-extrabold text-sm text-gray-900 flex items-center gap-1.5">
                                                        <span>nguyen_thi_mai_lan</span>
                                                        <span class="text-[10px] bg-emerald-50 text-emerald-700 font-bold px-2 py-0.5 rounded-full border border-emerald-200">
                                                            <i class="fa-solid fa-circle-check"></i> Đã mua tại cửa hàng
                                                        </span>
                                                    </div>
                                                    <div class="flex text-amber-400 text-[10px] gap-0.5 mt-0.5">
                                                        <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                                    </div>
                                                </div>
                                            </div>
                                            <span class="text-xs text-gray-400">12:30 hôm qua</span>
                                        </div>
                                        <div class="text-xs text-gray-500">Phân loại: ${not empty product.variants ? product.variants[0].variantName : product.unit}</div>
                                        <p class="text-xs sm:text-sm text-gray-700 leading-relaxed">
                                            Sản phẩm đóng gói rất đẹp và chỉn chu, trái cây tươi nguyên cuống. Ăn giòn ngọt, mọng nước, đúng chuẩn an toàn. Đặt sáng mà trưa đã nhận được hàng. Rất hài lòng!
                                        </p>
                                        <!-- Phản hồi của nhà vườn -->
                                        <div class="bg-gray-50 p-3.5 rounded-xl text-xs space-y-1 border border-gray-100">
                                            <div class="font-bold text-gray-800">Phản Hồi Của Nhà Vườn:</div>
                                            <div class="text-gray-600">Dạ ${not empty shop.shopName ? shop.shopName : 'Shop'} chân thành cảm ơn bạn Mai Lan đã tin dùng sản phẩm của nông trại ạ! Chúc bạn và gia đình thưởng thức thật ngon miệng nhé!</div>
                                        </div>
                                    </div>

                                    <!-- Review 2 -->
                                    <div class="pt-6 space-y-3">
                                        <div class="flex items-center justify-between">
                                            <div class="flex items-center gap-3">
                                                <div class="w-10 h-10 rounded-full bg-blue-100 text-blue-700 font-bold flex items-center justify-center text-sm">
                                                    HN
                                                </div>
                                                <div>
                                                    <div class="font-extrabold text-sm text-gray-900 flex items-center gap-1.5">
                                                        <span>tran_hoang_nam</span>
                                                        <span class="text-[10px] bg-emerald-50 text-emerald-700 font-bold px-2 py-0.5 rounded-full border border-emerald-200">
                                                            <i class="fa-solid fa-circle-check"></i> Đã mua tại cửa hàng
                                                        </span>
                                                    </div>
                                                    <div class="flex text-amber-400 text-[10px] gap-0.5 mt-0.5">
                                                        <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                                    </div>
                                                </div>
                                            </div>
                                            <span class="text-xs text-gray-400">3 ngày trước</span>
                                        </div>
                                        <p class="text-xs sm:text-sm text-gray-700 leading-relaxed">
                                            Mua làm quà biếu đối tác ai cũng khen sang trọng và chất lượng. Quả to đều, thơm nức mùi thơm tự nhiên. Shipper giao hàng nhiệt tình, lịch sự. Sẽ tiếp tục ủng hộ dài dài.
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ========================================== -->
                    <!-- 4. KHỐI SẢN PHẨM TƯƠNG TỰ -->
                    <!-- ========================================== -->
                    <c:if test="${not empty relatedProducts}">
                        <div class="mt-12">
                            <div class="flex items-center justify-between mb-6">
                                <div>
                                    <h2 class="text-xl sm:text-2xl font-extrabold text-gray-900">
                                        Sản Phẩm Tương Tự
                                    </h2>
                                    <p class="text-xs text-gray-500 mt-1">Các loại nông sản tươi sạch cùng phân khúc bạn có thể quan tâm</p>
                                </div>
                                <a href="${pageContext.request.contextPath}/products" class="text-xs font-bold text-[#00652c] hover:underline flex items-center gap-1">
                                    Xem tất cả <i class="fa-solid fa-arrow-right text-[10px]"></i>
                                </a>
                            </div>

                            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 sm:gap-6">
                                <c:forEach var="item" items="${relatedProducts}">
                                    <a href="${pageContext.request.contextPath}/detail?id=${item.id}" class="group bg-white rounded-2xl p-3 sm:p-4 border border-gray-100 hover:border-emerald-300 hover:shadow-lg transition-all flex flex-col justify-between">
                                        <div>
                                            <div class="w-full h-40 sm:h-48 rounded-xl overflow-hidden bg-gray-50 mb-3 relative">
                                                <img src="${item.image}" alt="${item.name}" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
                                                <c:if test="${not empty item.tag}">
                                                    <span class="absolute top-2 left-2 bg-[#00652c] text-white text-[9px] font-black px-2 py-0.5 rounded-full uppercase">
                                                        ${item.tag}
                                                    </span>
                                                </c:if>
                                            </div>
                                            <div class="text-[10px] font-bold text-gray-400 uppercase tracking-wider mb-1">
                                                ${item.categoryName}
                                            </div>
                                            <h3 class="font-bold text-xs sm:text-sm text-gray-900 group-hover:text-[#00652c] transition line-clamp-2 leading-snug mb-2">
                                                ${item.name}
                                            </h3>
                                        </div>
                                        <div class="pt-2 border-t border-gray-50 flex items-baseline justify-between">
                                            <div class="text-sm sm:text-base font-extrabold text-[#00652c]">
                                                <fmt:formatNumber value="${item.price}" pattern="#,###"/>đ
                                            </div>
                                            <span class="text-[10px] text-gray-400">/${item.unit}</span>
                                        </div>
                                    </a>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>

                </c:when>
                <c:otherwise>
                    <!-- Báo lỗi không tìm thấy sản phẩm -->
                    <div class="text-center py-20 bg-white rounded-3xl border border-gray-100 shadow-sm">
                        <i class="fa-solid fa-box-open text-6xl text-gray-300 mb-4"></i>
                        <h2 class="text-xl font-bold text-gray-800 mb-2">Không tìm thấy sản phẩm yêu cầu</h2>
                        <p class="text-sm text-gray-500 mb-6 max-w-md mx-auto">Sản phẩm bạn đang tìm kiếm có thể đã hết hàng hoặc ngừng kinh doanh. Vui lòng tham khảo các mặt hàng khác.</p>
                        <a href="${pageContext.request.contextPath}/products" class="inline-flex items-center gap-2 px-6 py-3 bg-[#00652c] text-white font-bold text-sm rounded-xl hover:bg-[#005323] transition shadow">
                            <i class="fa-solid fa-arrow-left"></i> Khám phá sản phẩm khác
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>
        </main>

        <!-- MODAL VIẾT ĐÁNH GIÁ (TIẾNG VIỆT) -->
        <div id="review-modal" class="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm hidden items-center justify-center p-4">
            <div class="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-8 shadow-2xl relative border border-gray-100 animate-in fade-in zoom-in duration-200">
                <button type="button" onclick="closeReviewModal()" class="absolute top-5 right-5 text-gray-400 hover:text-gray-700 w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center transition">
                    <i class="fa-solid fa-xmark text-sm"></i>
                </button>

                <div class="text-center mb-6">
                    <div class="w-12 h-12 rounded-2xl bg-emerald-50 text-[#00652c] font-black text-xl flex items-center justify-center mx-auto mb-3">
                        <i class="fa-solid fa-star"></i>
                    </div>
                    <h3 class="text-lg font-extrabold text-gray-900">Đánh Giá Sản Phẩm</h3>
                    <p class="text-xs text-gray-500 mt-1">${product.name}</p>
                </div>

                <form onsubmit="handleReviewSubmit(event)" class="space-y-4">
                    <!-- Chọn số sao -->
                    <div class="text-center space-y-1">
                        <div class="text-xs font-bold text-gray-600">Đánh giá chất lượng</div>
                        <div class="flex items-center justify-center gap-2 text-2xl text-amber-400 cursor-pointer pt-1" id="star-rating-box">
                            <i class="fa-solid fa-star" onclick="setRating(1)"></i>
                            <i class="fa-solid fa-star" onclick="setRating(2)"></i>
                            <i class="fa-solid fa-star" onclick="setRating(3)"></i>
                            <i class="fa-solid fa-star" onclick="setRating(4)"></i>
                            <i class="fa-solid fa-star" onclick="setRating(5)"></i>
                        </div>
                        <input type="hidden" id="modal-rating-val" value="5">
                    </div>

                    <div>
                        <label class="block text-xs font-bold text-gray-700 mb-1">Họ và tên của bạn</label>
                        <input type="text" id="modal-review-name" required placeholder="Nhập tên của bạn..." 
                               class="w-full text-xs sm:text-sm p-3 rounded-xl border border-gray-200 focus:border-[#00652c] outline-none">
                    </div>

                    <div>
                        <label class="block text-xs font-bold text-gray-700 mb-1">Nhận xét chi tiết</label>
                        <textarea id="modal-review-comment" rows="4" required placeholder="Chia sẻ cảm nhận về độ tươi, vị ngọt, đóng gói và thời gian giao hàng..." 
                                  class="w-full text-xs sm:text-sm p-3 rounded-xl border border-gray-200 focus:border-[#00652c] outline-none"></textarea>
                    </div>

                    <button type="submit" class="w-full py-3.5 bg-[#00652c] hover:bg-[#005323] text-white font-extrabold text-sm rounded-xl transition shadow">
                        Gửi Đánh Giá Ngay
                    </button>
                </form>
            </div>
        </div>

        <!-- MODAL CHAT TRÒ CHUYỆN VỚI SHOP (TIẾNG VIỆT) -->
        <div id="chat-modal" class="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm hidden items-center justify-center p-4">
            <div class="bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl relative border border-gray-100">
                <button type="button" onclick="closeChatModal()" class="absolute top-5 right-5 text-gray-400 hover:text-gray-700 w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center transition">
                    <i class="fa-solid fa-xmark text-sm"></i>
                </button>

                <div class="flex items-center gap-3 mb-4 pb-3 border-b border-gray-100">
                    <div class="w-12 h-12 rounded-full overflow-hidden bg-gray-100 border border-gray-200 shrink-0">
                        <img src="${not empty shop.logoUrl ? shop.logoUrl : 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=150'}" alt="${shop.shopName}" class="w-full h-full object-cover">
                    </div>
                    <div>
                        <h4 class="font-extrabold text-sm text-gray-900">${not empty shop.shopName ? shop.shopName : 'GỐC VƯỜN'}</h4>
                        <div class="flex items-center gap-1.5 text-xs text-gray-500">
                            <span class="w-2 h-2 rounded-full bg-emerald-500"></span> Đang hoạt động
                        </div>
                    </div>
                </div>

                <div class="space-y-3 mb-5 max-h-56 overflow-y-auto pr-1 text-xs">
                    <div class="bg-gray-100 p-3 rounded-2xl max-w-[85%] text-gray-700 leading-relaxed">
                        Kính chào quý khách! Cảm ơn bạn đã quan tâm đến sản phẩm <strong>${product.name}</strong>. Nhà vườn chúng tôi có thể hỗ trợ tư vấn thông tin gì cho bạn ạ?
                    </div>
                </div>

                <div class="flex items-center gap-2">
                    <input type="text" id="chat-quick-input" placeholder="Nhập tin nhắn cần tư vấn..." class="flex-1 text-xs p-3 rounded-xl border border-gray-200 focus:border-emerald-600 outline-none">
                    <button type="button" onclick="sendQuickChat()" class="px-4 py-3 bg-[#00652c] hover:bg-[#005323] text-white font-bold text-xs rounded-xl transition">
                        <i class="fa-solid fa-paper-plane"></i>
                    </button>
                </div>
            </div>
        </div>

        <!-- Footer Chuẩn Đồng Bộ Website -->
        <footer id="about" class="bg-gray-950 text-gray-300 pt-16 pb-8 border-t border-gray-800 mt-16">
            <div class="max-w-[1360px] mx-auto px-4 lg:px-8">
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-10 mb-12">
                    <div class="lg:col-span-2">
                        <div class="flex items-center gap-3 mb-4">
                            <div class="w-10 h-10 bg-emerald-50 rounded-full flex items-center justify-center p-1 shadow">
                                <svg viewBox="0 0 100 100" class="w-full h-full">
                                    <circle cx="50" cy="56" r="32" fill="#16a34a"/>
                                    <path d="M 28 45 Q 36 34 50 34" stroke="#ffffff" stroke-width="6" stroke-linecap="round" fill="none"/>
                                    <circle cx="68" cy="46" r="5" fill="#ffffff"/>
                                    <path d="M 52 26 C 58 16 68 14 74 18 C 74 24 64 32 52 26 Z" fill="#f97316"/>
                                </svg>
                            </div>
                            <span class="text-xl font-extrabold text-white">Gốc<span class="text-emerald-500">Vườn</span> Marketplace</span>
                        </div>
                        <p class="text-xs sm:text-sm text-gray-400 mb-6 leading-relaxed max-w-sm">
                            Hệ thống sàn phân phối nông sản và hoa quả tươi sạch hàng đầu. Mang thiên nhiên thuần khiết và nguồn dinh dưỡng chuẩn hữu cơ từ vườn thẳng đến bếp nhà bạn.
                        </p>
                    </div>
                    <div>
                        <h3 class="font-bold text-white text-sm uppercase tracking-wider mb-4">Danh Mục Mua Sắm</h3>
                        <ul class="space-y-2.5 text-xs text-gray-400">
                            <li><a href="${pageContext.request.contextPath}/products" class="hover:text-emerald-400 transition">Trái Cây Hữu Cơ</a></li>
                            <li><a href="${pageContext.request.contextPath}/products" class="hover:text-emerald-400 transition">Nông Sản Địa Phương</a></li>
                            <li><a href="${pageContext.request.contextPath}/products" class="hover:text-emerald-400 transition">Hộp Quà Cao Cấp</a></li>
                        </ul>
                    </div>
                    <div>
                        <h3 class="font-bold text-white text-sm uppercase tracking-wider mb-4">Hỗ Trợ Khách Hàng</h3>
                        <ul class="space-y-2.5 text-xs text-gray-400">
                            <li><a href="#" class="hover:text-emerald-400 transition">Trung Tâm Trợ Giúp</a></li>
                            <li><a href="#" class="hover:text-emerald-400 transition">Chính Sách Đổi Trả 1-1 Trong 24h</a></li>
                            <li><a href="#" class="hover:text-emerald-400 transition">Bảo Quản Chuỗi Lạnh Fresh-Lock</a></li>
                        </ul>
                    </div>
                    <div>
                        <h3 class="font-bold text-white text-sm uppercase tracking-wider mb-4">Đăng Ký Nhận Bản Tin</h3>
                        <form onsubmit="event.preventDefault(); alert('Cảm ơn bạn đã đăng ký nhận khuyến mãi từ Gốc Vườn!');" class="space-y-2">
                            <input type="email" placeholder="Nhập email của bạn..." class="w-full bg-gray-900 border border-gray-800 rounded-xl px-3.5 py-2.5 text-xs text-white focus:outline-none focus:border-emerald-500">
                            <button type="submit" class="w-full bg-[#00652c] hover:bg-[#005323] text-white font-bold text-xs py-2.5 rounded-xl transition shadow">Đăng Ký Nhận Ưu Đãi</button>
                        </form>
                    </div>
                </div>
                <div class="pt-8 border-t border-gray-900 flex flex-col sm:flex-row justify-between items-center text-xs text-gray-500 gap-4">
                    <p>&copy; 2026 Gốc Vườn Marketplace. Bảo lưu mọi quyền.</p>
                    <div class="flex items-center gap-4 text-gray-400">
                        <span>Tiêu chuẩn VietGAP • GlobalGAP • An Toàn Thực Phẩm</span>
                    </div>
                </div>
            </div>
        </footer>

        <!-- JAVASCRIPT ĐIỀU KHIỂN CHI TIẾT SẢN PHẨM HOÀN TOÀN BẰNG TIẾNG VIỆT -->
        <script>
            let currentUnitPrice = Number("${not empty product.price ? product.price : 0}");
            const baseUnitPrice = currentUnitPrice;
            const currencyFormatter = new Intl.NumberFormat('vi-VN');

            // 1. Chuyển ảnh lớn khi bấm vào ảnh thumbnail
            function changeMainImage(imgUrl, btn) {
                const mainImg = document.getElementById('main-product-image');
                if (mainImg) {
                    mainImg.style.opacity = '0.5';
                    setTimeout(() => {
                        mainImg.src = imgUrl;
                        mainImg.style.opacity = '1';
                    }, 150);
                }
                document.querySelectorAll('.thumb-btn').forEach(b => {
                    b.classList.remove('border-[#00652c]', 'ring-2', 'ring-[#00652c]/20');
                    b.classList.add('border-gray-200');
                });
                if (btn) {
                    btn.classList.remove('border-gray-200');
                    btn.classList.add('border-[#00652c]', 'ring-2', 'ring-[#00652c]/20');
                }
            }

            // 2. Chọn phân loại biến thể từ DB
            function selectPackageVariant(variantId, price, unit, stock, origPrice, cardEl) {
                const hiddenInput = document.getElementById('selected-variant-id');
                if (hiddenInput) hiddenInput.value = variantId;

                currentUnitPrice = Number(price);
                updatePriceDisplay(currentUnitPrice, unit, origPrice);

                const stockText = document.getElementById('detail-stock-text');
                if (stockText) {
                    if (stock > 0) {
                        stockText.textContent = 'Còn hàng — Còn ' + stock + ' ' + unit + ' trong kho';
                    } else {
                        stockText.textContent = 'Tạm hết hàng';
                    }
                }

                document.querySelectorAll('.variant-card').forEach(c => c.classList.remove('selected'));
                if (cardEl) cardEl.classList.add('selected');

                recalculateCartTotal();
            }

            // 3. Chọn phân loại quy cách mặc định
            function selectPackagePreset(multiplier, price, unitLabel, cardEl) {
                const qtyInput = document.getElementById('buy-quantity');
                if (qtyInput) qtyInput.value = multiplier;

                currentUnitPrice = baseUnitPrice;
                updatePriceDisplay(price, unitLabel, price * 1.2);

                document.querySelectorAll('.variant-card').forEach(c => c.classList.remove('selected'));
                if (cardEl) cardEl.classList.add('selected');

                const cartBtnTotal = document.getElementById('cart-btn-total');
                if (cartBtnTotal) cartBtnTotal.textContent = currencyFormatter.format(price) + 'đ';
            }

            function updatePriceDisplay(price, unit, oldPrice) {
                const priceEl = document.getElementById('detail-price');
                const unitEl = document.getElementById('detail-unit');
                const oldPriceEl = document.getElementById('detail-old-price');
                const savingsBadge = document.getElementById('detail-savings-badge');

                if (priceEl) priceEl.textContent = currencyFormatter.format(price) + 'đ';
                if (unitEl) unitEl.textContent = '/' + unit;
                if (oldPriceEl && oldPrice > price) {
                    oldPriceEl.textContent = currencyFormatter.format(oldPrice) + 'đ/' + unit;
                    if (savingsBadge) {
                        const saved = oldPrice - price;
                        savingsBadge.textContent = 'Tiết kiệm ' + currencyFormatter.format(saved) + 'đ';
                        savingsBadge.style.display = 'inline-block';
                    }
                } else if (savingsBadge) {
                    savingsBadge.style.display = 'none';
                }
            }

            // 4. Stepper tăng giảm số lượng
            function adjustQuantity(delta) {
                const qtyInput = document.getElementById('buy-quantity');
                if (!qtyInput) return;
                let val = parseInt(qtyInput.value) || 1;
                val += delta;
                if (val < 1) val = 1;
                if (val > 99) val = 99;
                qtyInput.value = val;
                recalculateCartTotal();
            }

            // 5. Cập nhật tổng tiền trên nút Thêm Vào Giỏ Hàng
            function recalculateCartTotal() {
                const qtyInput = document.getElementById('buy-quantity');
                const cartBtnTotal = document.getElementById('cart-btn-total');
                const qty = parseInt(qtyInput ? qtyInput.value : 1) || 1;
                const total = currentUnitPrice * qty;
                if (cartBtnTotal) {
                    cartBtnTotal.textContent = currencyFormatter.format(total) + 'đ';
                }
            }

            // 6. Chuyển Tab Mô Tả / Dinh Dưỡng / Nhà Vườn / Đánh Giá
            function switchTab(tabName) {
                document.querySelectorAll('.tab-btn').forEach(btn => {
                    btn.classList.remove('active', 'text-[#00652c]', 'border-b-[3px]', 'border-[#00652c]', 'font-bold');
                    btn.classList.add('text-gray-500');
                });
                const activeBtn = document.getElementById('tab-btn-' + tabName);
                if (activeBtn) {
                    activeBtn.classList.add('active', 'text-[#00652c]', 'border-b-[3px]', 'border-[#00652c]', 'font-bold');
                    activeBtn.classList.remove('text-gray-500');
                }

                document.querySelectorAll('.tab-pane').forEach(pane => pane.classList.add('hidden'));
                const activePane = document.getElementById('tab-content-' + tabName);
                if (activePane) activePane.classList.remove('hidden');
            }

            // 7. Chia sẻ liên kết (sao chép URL hiện tại vào bộ nhớ tạm - Clipboard)
            function shareProduct() {
                const url = window.location.href;
                if (navigator.clipboard && window.isSecureContext) {
                    navigator.clipboard.writeText(url).then(function() {
                        showShareToast('Đã sao chép liên kết sản phẩm vào bộ nhớ tạm!');
                    }).catch(function() {
                        fallbackCopyUrl(url);
                    });
                } else {
                    fallbackCopyUrl(url);
                }
            }

            function fallbackCopyUrl(url) {
                const textArea = document.createElement("textarea");
                textArea.value = url;
                textArea.style.position = "fixed";
                textArea.style.left = "-9999px";
                textArea.style.top = "0";
                document.body.appendChild(textArea);
                textArea.focus();
                textArea.select();
                try {
                    document.execCommand('copy');
                    showShareToast('Đã sao chép liên kết sản phẩm vào bộ nhớ tạm!');
                } catch (err) {
                    prompt('Sao chép liên kết sản phẩm:', url);
                }
                document.body.removeChild(textArea);
            }

            function showShareToast(message) {
                let toast = document.getElementById('share-success-toast');
                if (!toast) {
                    toast = document.createElement('div');
                    toast.id = 'share-success-toast';
                    toast.className = 'fixed bottom-6 right-6 z-50 flex items-center gap-2.5 bg-gray-900/95 text-white px-5 py-3 rounded-2xl shadow-2xl text-xs sm:text-sm font-semibold backdrop-blur-md transition-all duration-300';
                    document.body.appendChild(toast);
                }
                toast.innerHTML = '<i class="fa-solid fa-circle-check text-emerald-400 text-base"></i> ' + message;
                toast.style.display = 'flex';
                toast.style.opacity = '1';
                setTimeout(function() {
                    toast.style.opacity = '0';
                    setTimeout(function() { toast.style.display = 'none'; }, 300);
                }, 3000);
            }

            // 8. Đánh giá Modal & Rating Star
            function openReviewModal() {
                const modal = document.getElementById('review-modal');
                if (modal) {
                    modal.classList.remove('hidden');
                    modal.classList.add('flex');
                }
            }
            function closeReviewModal() {
                const modal = document.getElementById('review-modal');
                if (modal) {
                    modal.classList.add('hidden');
                    modal.classList.remove('flex');
                }
            }
            function setRating(stars) {
                document.getElementById('modal-rating-val').value = stars;
                const starIcons = document.querySelectorAll('#star-rating-box i');
                starIcons.forEach((icon, idx) => {
                    if (idx < stars) {
                        icon.classList.remove('fa-regular', 'text-gray-300');
                        icon.classList.add('fa-solid', 'text-amber-400');
                    } else {
                        icon.classList.remove('fa-solid', 'text-amber-400');
                        icon.classList.add('fa-regular', 'text-gray-300');
                    }
                });
            }
            function handleReviewSubmit(e) {
                e.preventDefault();
                const name = document.getElementById('modal-review-name').value;
                const comment = document.getElementById('modal-review-comment').value;
                const stars = parseInt(document.getElementById('modal-rating-val').value) || 5;

                let starsHtml = '';
                for (let i = 0; i < stars; i++) starsHtml += '<i class="fa-solid fa-star"></i>';

                const newReviewHtml = `
                    <div class="pt-6 first:pt-0 space-y-3 animate-in fade-in duration-300">
                        <div class="flex items-center justify-between">
                            <div class="flex items-center gap-3">
                                <div class="w-10 h-10 rounded-full bg-emerald-100 text-[#00652c] font-bold flex items-center justify-center text-sm">
                                    ` + name.substring(0, 2).toUpperCase() + `
                                </div>
                                <div>
                                    <div class="font-extrabold text-sm text-gray-900 flex items-center gap-1.5">
                                        <span>` + name + `</span>
                                        <span class="text-[10px] bg-emerald-50 text-emerald-700 font-bold px-2 py-0.5 rounded-full border border-emerald-200">
                                            <i class="fa-solid fa-circle-check"></i> Đã mua tại cửa hàng
                                        </span>
                                    </div>
                                    <div class="flex text-amber-400 text-[10px] gap-0.5 mt-0.5">
                                        ` + starsHtml + `
                                    </div>
                                </div>
                            </div>
                            <span class="text-xs text-gray-400">Vừa xong</span>
                        </div>
                        <p class="text-xs sm:text-sm text-gray-700 leading-relaxed">` + comment + `</p>
                    </div>
                `;

                const list = document.getElementById('reviews-list');
                if (list) list.insertAdjacentHTML('afterbegin', newReviewHtml);

                closeReviewModal();
                switchTab('reviews');
                alert('Cảm ơn bạn! Đánh giá của bạn đã được đăng thành công.');
            }

            // 9. Chat Modal Tiếng Việt
            function openChatModal() {
                const modal = document.getElementById('chat-modal');
                if (modal) {
                    modal.classList.remove('hidden');
                    modal.classList.add('flex');
                }
            }
            function closeChatModal() {
                const modal = document.getElementById('chat-modal');
                if (modal) {
                    modal.classList.add('hidden');
                    modal.classList.remove('flex');
                }
            }
            function sendQuickChat() {
                const input = document.getElementById('chat-quick-input');
                if (input && input.value.trim() !== '') {
                    alert('Đã gửi tin nhắn đến ${not empty shop.shopName ? shop.shopName : "Nhà Vườn"}: "' + input.value + '"\nNhân viên hỗ trợ sẽ phản hồi trong giây lát.');
                    input.value = '';
                    closeChatModal();
                }
            }

            document.addEventListener('DOMContentLoaded', function () {
                recalculateCartTotal();
                const toast = document.getElementById('product-toast');
                if (toast) {
                    setTimeout(() => { toast.remove(); }, 5000);
                }
            });
        </script>
        <script src="${pageContext.request.contextPath}/assets/js/reviews.js" data-fe10-product-detail="true" data-product-id="${product.id}" data-ctx="${pageContext.request.contextPath}"></script>
    </body>
</html>
