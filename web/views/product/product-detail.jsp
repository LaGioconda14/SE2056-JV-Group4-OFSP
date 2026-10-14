<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${product.name} - FreshFruit Marketplace Trái Cây Tươi</title>
    <!-- Google Fonts Inter & Plus Jakarta Sans -->
    <link href="https://fonts.googleapis.com" rel="preconnect">
    <link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <!-- FontAwesome 6 Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Custom Product Detail CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/product-detail.css">
    <!-- Custom Product Detail JS -->
    <script src="${pageContext.request.contextPath}/assets/js/product-detail.js" defer></script>
</head>
<body class="bg-gray-50/50 font-['Plus_Jakarta_Sans',sans-serif] text-gray-800 antialiased">



    <!-- MAIN NAVBAR -->
    <header class="bg-white border-b border-gray-100 sticky top-0 z-40 shadow-xs">
        <div class="max-w-7xl mx-auto px-4 py-3 flex items-center justify-between gap-4">
            <!-- Brand Logo -->
            <a href="${pageContext.request.contextPath}/home" class="flex items-center gap-2.5">
                <div class="w-10 h-10 rounded-full bg-emerald-50 flex items-center justify-center p-1 border border-emerald-100">
                    <svg viewBox="0 0 100 100" class="w-full h-full">
                        <circle cx="50" cy="56" r="32" fill="#16a34a"/>
                        <path d="M 28 45 Q 36 34 50 34" stroke="#ffffff" stroke-width="6" stroke-linecap="round" fill="none"/>
                        <circle cx="68" cy="46" r="5" fill="#ffffff"/>
                        <path d="M 52 26 C 58 16 68 14 74 18 C 74 24 64 32 52 26 Z" fill="#f97316"/>
                    </svg>
                </div>
                <div class="text-2xl font-black tracking-tight text-gray-900">
                    Fresh<span class="text-emerald-700">Fruit</span>
                </div>
            </a>

            <!-- Search Bar -->
            <div class="flex-1 max-w-xl mx-4 hidden md:block">
                <form action="${pageContext.request.contextPath}/products" method="GET" class="relative flex items-center rounded-2xl bg-gray-100 border border-transparent focus-within:border-emerald-500 focus-within:bg-white transition overflow-hidden">
                    <i class="fa-solid fa-magnifying-glass absolute left-3.5 text-gray-400 text-sm"></i>
                    <input type="text" name="keyword" placeholder="Tìm kiếm táo tươi, dâu tây, cam ngọt, trái cây hữu cơ..." class="w-full bg-transparent pl-10 pr-4 py-2.5 text-sm text-gray-800 placeholder-gray-400 focus:outline-none">
                </form>
            </div>

            <!-- Right Actions: Cart & Profile -->
            <div class="flex items-center gap-3">
                <a href="#" class="relative w-10 h-10 rounded-full flex items-center justify-center text-gray-600 hover:bg-gray-100 transition" title="Danh sách yêu thích">
                    <i class="fa-regular fa-heart text-lg"></i>
                    <c:if test="${not empty sessionScope.wishlistCount and sessionScope.wishlistCount > 0}">
                        <span class="absolute top-1.5 right-1.5 w-4 h-4 rounded-full bg-emerald-600 text-white text-[10px] font-bold flex items-center justify-center">${sessionScope.wishlistCount}</span>
                    </c:if>
                </a>
                
                <a href="${pageContext.request.contextPath}/cart" class="flex items-center gap-2.5 px-3 py-1.5 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200/60 hover:bg-emerald-100 transition">
                    <div class="relative">
                        <i class="fa-solid fa-basket-shopping text-base"></i>
                        <span class="absolute -top-1.5 -right-2 bg-emerald-700 text-white text-[9px] font-bold rounded-full w-4 h-4 flex items-center justify-center">${sessionScope.cartSize != null ? sessionScope.cartSize : 0}</span>
                    </div>
                    <div class="flex flex-col text-left text-xs leading-none">
                        <span class="text-[9px] text-emerald-600 font-bold uppercase">Giỏ hàng</span>
                        <span class="font-extrabold text-emerald-950"><c:choose><c:when test="${not empty sessionScope.cartTotal and sessionScope.cartTotal > 0}"><fmt:formatNumber value="${sessionScope.cartTotal}" pattern="#,###" />₫</c:when><c:otherwise>0₫</c:otherwise></c:choose></span>
                    </div>
                </a>

                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <div class="relative group">
                            <a href="${pageContext.request.contextPath}/profile" class="w-9 h-9 rounded-full overflow-hidden border border-emerald-400 shrink-0 block">
                                <img src="${not empty sessionScope.user.avatarUrl ? sessionScope.user.avatarUrl : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop'}" alt="User" class="w-full h-full object-cover">
                            </a>
                            <div class="absolute right-0 top-full pt-2 w-52 hidden group-hover:block z-50">
                                <div class="bg-white rounded-2xl shadow-xl border border-gray-100 p-2 space-y-1 text-xs">
                                    <div class="px-3 py-2 border-b border-gray-100">
                                        <p class="font-bold text-gray-900 truncate">${sessionScope.user.fullName}</p>
                                        <p class="text-[11px] text-gray-500 truncate">${sessionScope.user.email}</p>
                                    </div>
                                    <c:if test="${sessionScope.user.role eq 'SHOP_OWNER'}">
                                        <a href="${pageContext.request.contextPath}/shop/dashboard" class="flex items-center gap-2 px-3 py-2 font-bold text-emerald-700 bg-emerald-50 rounded-xl hover:bg-emerald-100 transition">
                                            <i class="fa-solid fa-store"></i> Kênh Quản Lý Shop
                                        </a>
                                    </c:if>
                                    <a href="${pageContext.request.contextPath}/profile" class="flex items-center gap-2 px-3 py-2 font-medium text-gray-700 rounded-xl hover:bg-gray-100 transition">
                                        <i class="fa-solid fa-user-gear text-gray-400"></i> Tài khoản của tôi
                                    </a>
                                    <div class="pt-1 border-t border-gray-100">
                                        <a href="${pageContext.request.contextPath}/logout" class="flex items-center gap-2 px-3 py-2 font-semibold text-red-600 rounded-xl hover:bg-red-50 transition">
                                            <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/login" class="text-sm font-semibold text-emerald-700 hover:text-emerald-800 ml-1">Đăng Nhập</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Navigation bar -->
        <div class="border-t border-gray-100 px-4">
            <div class="max-w-7xl mx-auto flex items-center justify-between text-sm py-2">
                <nav class="flex items-center space-x-7 font-medium text-gray-700">
                    <a href="${pageContext.request.contextPath}/home" class="hover:text-emerald-700 transition">Trang Chủ</a>
                    <a href="${pageContext.request.contextPath}/products" class="text-emerald-700 font-bold border-b-2 border-emerald-700 pb-0.5">Cửa Hàng</a>
                    <a href="${pageContext.request.contextPath}/categories" class="hover:text-emerald-700 transition">Danh Mục</a>
                    <a href="${pageContext.request.contextPath}/deals" class="hover:text-emerald-700 transition">Khuyến Mãi</a>
                    <a href="${pageContext.request.contextPath}/about" class="hover:text-emerald-700 transition">Về Chúng Tôi</a>
                    <a href="${pageContext.request.contextPath}/contact" class="hover:text-emerald-700 transition">Liên Hệ</a>
                </nav>
                <div class="flex items-center gap-1.5 text-xs font-bold text-amber-800 bg-amber-50 px-3 py-1 rounded-full border border-amber-200">
                    <i class="fa-solid fa-bolt text-amber-500"></i>
                    <span>Khuyến Mãi Mùa Vụ - Giảm tới 25%</span>
                </div>
            </div>
        </div>
    </header>

    <!-- BREADCRUMB & BACK TO ORCHARD -->
    <div class="max-w-7xl mx-auto px-4 pt-5 pb-3">
        <div class="flex items-center justify-between text-xs">
            <nav class="flex items-center gap-2 text-gray-500">
                <a href="${pageContext.request.contextPath}/home" class="hover:text-emerald-700">Trang chủ</a>
                <i class="fa-solid fa-chevron-right text-[9px] text-gray-400"></i>
                <a href="${pageContext.request.contextPath}/products" class="hover:text-emerald-700">Cửa hàng</a>
                <i class="fa-solid fa-chevron-right text-[9px] text-gray-400"></i>
                <a href="${pageContext.request.contextPath}/products?category=${product.categoryId}" class="hover:text-emerald-700">${not empty product.categoryName ? product.categoryName : 'Trái Cây Tươi Sạch'}</a>
                <i class="fa-solid fa-chevron-right text-[9px] text-gray-400"></i>
                <span class="text-gray-900 font-semibold">${product.name}</span>
            </nav>

            <a href="${pageContext.request.contextPath}/products" class="text-emerald-800 font-bold hover:underline flex items-center gap-1.5">
                <i class="fa-solid fa-arrow-left text-[11px]"></i> Quay lại Cửa Hàng Trái Cây
            </a>
        </div>
    </div>

    <!-- MAIN PRODUCT SECTION (GALLERY & BUY BOX) -->
    <main class="max-w-7xl mx-auto px-4 pb-12">
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-10">

            <!-- CỘT TRÁI: GALLERY ẢNH SẢN PHẨM (6 CỘT) -->
            <div class="lg:col-span-6 space-y-4">
                <!-- Ảnh chính to -->
                <div class="detail-main-img-wrap group">
                    <img id="mainProductImg" src="${product.image}" alt="${product.name}">
                    
                    <!-- Huy hiệu chứng nhận & giảm giá -->
                    <div class="absolute top-4 left-4 flex flex-col gap-2 z-10">
                        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/95 text-emerald-800 font-bold text-xs shadow-sm backdrop-blur-xs">
                            <i class="fa-solid fa-certificate text-emerald-600"></i> Hữu Cơ Chuẩn VietGAP / Organic
                        </span>
                        <c:if test="${product.discountPercent > 0}">
                            <span class="w-max px-2.5 py-0.5 rounded-full bg-red-600 text-white font-black text-[11px] shadow-sm uppercase tracking-wider">
                                -${product.discountPercent}% GIẢM GIÁ
                            </span>
                        </c:if>
                    </div>

                    <!-- Nút Hover to Zoom -->
                    <div class="absolute bottom-4 right-4 px-3 py-1.5 rounded-xl bg-black/60 text-white text-xs font-semibold flex items-center gap-1.5 backdrop-blur-xs pointer-events-none">
                        <i class="fa-solid fa-magnifying-glass-plus text-xs"></i> Rê chuột để phóng to
                    </div>
                </div>

                <!-- 4 Thumbnail ảnh bên dưới -->
                <div class="grid grid-cols-4 gap-3">
                    <c:forEach var="imgUrl" items="${product.images}" varStatus="status">
                        <button type="button" class="detail-thumb-btn ${status.first ? 'active' : ''}" data-img="${imgUrl}">
                            <img src="${imgUrl}" alt="Hình ảnh chi tiết ${status.index + 1}" class="w-full h-full object-cover">
                        </button>
                    </c:forEach>
                </div>
            </div>

            <!-- CỘT PHẢI: THÔNG TIN SẢN PHẨM & MUA HÀNG (6 CỘT) -->
            <div class="lg:col-span-6 space-y-5">
                
                <!-- Farm Origin Header -->
                <div class="text-[11px] font-extrabold uppercase tracking-widest text-emerald-800">
                    ${not empty product.origin ? product.origin : 'NÔNG TRẠI ĐÀ LẠT • LÂM ĐỒNG'} &bull; ${not empty product.categoryName ? product.categoryName : 'TRÁI CÂY TƯƠI SẠCH'}
                </div>

                <!-- Product Title -->
                <h1 class="text-3xl sm:text-4xl font-black text-gray-950 tracking-tight leading-tight">
                    ${product.name}
                </h1>

                <!-- Rating, Verified Reviews & Orders -->
                <div class="flex items-center flex-wrap gap-4 text-xs">
                    <div class="flex items-center gap-1.5">
                        <div class="flex text-amber-400 text-xs gap-0.5">
                            <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star-half-stroke"></i>
                        </div>
                        <span class="font-extrabold text-gray-900">${product.rating} / 5.0</span>
                    </div>
                    <span class="text-gray-300">|</span>
                    <a href="#tab-reviews" class="text-gray-600 hover:text-emerald-700 font-medium">${product.reviewsCount} Đánh giá xác thực</a>
                    <span class="text-gray-300">&bull;</span>
                    <span class="text-emerald-800 font-semibold flex items-center gap-1">
                        <i class="fa-solid fa-box text-emerald-600"></i> 1.450+ Đơn đã giao tháng này
                    </span>
                </div>

                <!-- Pricing Box -->
                <div class="flex items-baseline gap-3 pt-1">
                    <span id="mainPriceVal" class="text-4xl font-black text-emerald-800">
                        <c:choose>
                            <c:when test="${product.price >= 1000}">
                                <fmt:formatNumber value="${product.price}" pattern="#,###" /> ₫
                            </c:when>
                            <c:otherwise>
                                $<fmt:formatNumber value="${product.price}" pattern="#,##0.00" />
                            </c:otherwise>
                        </c:choose>
                    </span>
                    <span class="text-gray-400 font-bold text-sm">/${not empty product.unit ? product.unit : 'kg'}</span>
                    <c:if test="${product.oldPrice > product.price}">
                        <span id="mainOldPriceVal" class="text-lg text-gray-400 line-through">
                            <c:choose>
                                <c:when test="${product.oldPrice >= 1000}">
                                    <fmt:formatNumber value="${product.oldPrice}" pattern="#,###" /> ₫
                                </c:when>
                                <c:otherwise>
                                    $<fmt:formatNumber value="${product.oldPrice}" pattern="#,##0.00" />
                                </c:otherwise>
                            </c:choose>
                            /${not empty product.unit ? product.unit : 'kg'}
                        </span>
                        <span class="px-2 py-0.5 rounded-full bg-amber-100 text-amber-900 text-xs font-extrabold">
                            Tiết kiệm 
                            <c:choose>
                                <c:when test="${product.oldPrice - product.price >= 1000}">
                                    <fmt:formatNumber value="${product.oldPrice - product.price}" pattern="#,###" /> ₫
                                </c:when>
                                <c:otherwise>
                                    $<fmt:formatNumber value="${product.oldPrice - product.price}" pattern="#,##0.00" />
                                </c:otherwise>
                            </c:choose>
                            (${product.discountPercent}% GIẢM)
                        </span>
                    </c:if>
                </div>

                <!-- In Stock Alert -->
                <div class="flex items-center gap-2 text-xs font-semibold text-emerald-800">
                    <span class="w-2 h-2 rounded-full bg-emerald-600 animate-pulse"></span>
                    <c:choose>
                        <c:when test="${product.inStock}">
                            <span>Còn hàng</span>
                            <span class="text-gray-500 font-normal">&mdash; Còn ${product.stockQuantity > 0 ? product.stockQuantity : 45} ${not empty product.unit ? product.unit : 'kg'} thu hoạch sáng sớm hôm nay</span>
                        </c:when>
                        <c:otherwise>
                            <span class="text-red-600">Tạm hết hàng</span>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Product Summary Description -->
                <p class="text-xs sm:text-sm text-gray-600 leading-relaxed">
                    ${not empty product.description ? product.description : 'Trái cây tươi giòn, ngọt thanh và mọng nước tự nhiên. Được thu hoạch trực tiếp tại các nông trại đạt chuẩn VietGAP/Organic, giữ trọn độ tươi mới, hương thơm hoa quả và hàm lượng vitamin dồi dào cho sức khỏe cả gia đình.'}
                </p>

                <!-- Select Size / Package Option -->
                <div class="space-y-2 pt-2">
                    <span class="text-[11px] font-extrabold uppercase tracking-wider text-gray-500">Chọn Quy Cách Đóng Gói:</span>
                    <div class="grid grid-cols-3 gap-3">
                        <c:forEach var="v" items="${product.variants}" varStatus="vStatus">
                            <div class="variant-option-card ${vStatus.first ? 'active' : ''}" 
                                 data-price="${v.price}" 
                                 data-oldprice="${v.originalPrice}">
                                <c:if test="${vStatus.index == 1}">
                                    <span class="absolute -top-2 right-2 px-1.5 py-0.5 rounded-full bg-amber-200 text-amber-900 text-[9px] font-extrabold uppercase">Bán Chạy</span>
                                </c:if>
                                <span class="font-extrabold text-sm">${v.variantName}</span>
                                <span class="text-xs text-gray-400 variant-subprice">
                                    <c:choose>
                                        <c:when test="${v.price >= 1000}">
                                            <fmt:formatNumber value="${v.price}" pattern="#,###" /> ₫
                                        </c:when>
                                        <c:otherwise>
                                            $<fmt:formatNumber value="${v.price}" pattern="#,##0.00" />
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <!-- Quantity Selector & Add to Cart -->
                <div class="flex items-center gap-3 pt-3">
                    <!-- Quantity Input Box -->
                    <div class="flex items-center border border-gray-200 rounded-2xl bg-white px-2 py-1 shadow-xs">
                        <button type="button" id="btnMinus" class="w-8 h-8 rounded-xl hover:bg-gray-100 flex items-center justify-center text-gray-600 font-bold text-base">&minus;</button>
                        <input type="number" id="qtyInput" value="1" min="1" max="99" class="w-12 text-center font-extrabold text-sm text-gray-900 focus:outline-none">
                        <button type="button" id="btnPlus" class="w-8 h-8 rounded-xl hover:bg-gray-100 flex items-center justify-center text-gray-600 font-bold text-base">&plus;</button>
                    </div>

                    <!-- Add to Cart Button with Dynamic Total Price -->
                    <form action="${pageContext.request.contextPath}/add-to-cart" method="GET" class="flex-1">
                        <input type="hidden" name="productId" value="${product.id}">
                        <input type="hidden" id="activeVariantPrice" value="${product.price}">
                        <button type="submit" class="w-full py-3.5 px-6 rounded-2xl bg-emerald-800 hover:bg-emerald-900 text-white font-extrabold text-sm shadow-md hover:shadow-lg transition flex items-center justify-center gap-2">
                            <i class="fa-solid fa-cart-shopping text-sm"></i>
                            <span>Thêm Vào Giỏ &bull; <span id="totalPriceDisplay">
                                <c:choose>
                                    <c:when test="${product.price >= 1000}">
                                        <fmt:formatNumber value="${product.price}" pattern="#,###" /> ₫
                                    </c:when>
                                    <c:otherwise>
                                        $<fmt:formatNumber value="${product.price}" pattern="#,##0.00" />
                                    </c:otherwise>
                                </c:choose>
                            </span></span>
                        </button>
                    </form>

                    <!-- Wishlist & Share Buttons -->
                    <button type="button" class="w-11 h-11 rounded-2xl border border-gray-200 bg-white hover:bg-gray-50 text-gray-600 flex items-center justify-center shadow-xs transition" title="Lưu vào danh sách yêu thích">
                        <i class="fa-regular fa-heart text-base"></i>
                    </button>
                    <button type="button" class="w-11 h-11 rounded-2xl border border-gray-200 bg-white hover:bg-gray-50 text-gray-600 flex items-center justify-center shadow-xs transition" title="Chia sẻ sản phẩm">
                        <i class="fa-solid fa-share-nodes text-base"></i>
                    </button>
                </div>

                <!-- 1-Click Express Checkout Button -->
                <a href="${pageContext.request.contextPath}/checkout" class="block w-full py-3.5 rounded-2xl bg-amber-800 hover:bg-amber-900 text-white font-extrabold text-sm text-center shadow-md transition">
                    <i class="fa-solid fa-bolt mr-1"></i> Mua Ngay (Thanh Toán Siêu Tốc)
                </a>

                <!-- 3 Core Service Value Props (Free delivery, same-day, cold chain) -->
                <div class="space-y-2 pt-2">
                    <div class="benefit-card">
                        <i class="fa-solid fa-truck text-emerald-700 text-base mt-0.5"></i>
                        <div class="text-xs">
                            <strong class="text-gray-900 block font-bold">Miễn Phí Giao Hàng Cho Đơn Từ 300.000₫</strong>
                            <span class="text-gray-500">Kết hợp cùng rau củ và trái cây khác để được miễn hoàn toàn phí ship.</span>
                        </div>
                    </div>

                    <div class="benefit-card">
                        <i class="fa-solid fa-clock-rotate-left text-amber-700 text-base mt-0.5"></i>
                        <div class="text-xs">
                            <strong class="text-gray-900 block font-bold">Hỗ Trợ Giao Nhanh Trong Ngày</strong>
                            <span class="text-gray-500">Đặt hàng trước <span class="text-red-600 font-bold">15:00</span> để nhận hàng tươi ngon ngay trong buổi chiều hôm nay.</span>
                        </div>
                    </div>

                    <div class="benefit-card">
                        <i class="fa-solid fa-snowflake text-sky-700 text-base mt-0.5"></i>
                        <div class="text-xs">
                            <strong class="text-gray-900 block font-bold">Bảo Quản Chuỗi Lạnh Khép Kín</strong>
                            <span class="text-gray-500">Đóng gói bằng thùng cách nhiệt lót túi đá gel sinh học, giữ trọn độ tươi giòn.</span>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </main>

    <!-- SHOP / FARM PROFILE BOX (CHUẨN SHOPEE) -->
    <section class="max-w-7xl mx-auto px-4 pb-8">
        <div class="bg-white rounded-3xl p-6 sm:p-7 border border-gray-100 shadow-sm flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
            <!-- Cột trái: Logo Shop, Tên Shop, Tích xác thực & Nút Xem Shop -->
            <div class="flex items-center gap-4 flex-1">
                <div class="relative flex-shrink-0">
                    <img src="${not empty shop.logoUrl ? shop.logoUrl : 'https://images.unsplash.com/photo-1595246140625-573b715d11dc?w=150&h=150&fit=crop'}" 
                         alt="Shop Avatar" 
                         class="w-16 h-16 sm:w-20 sm:h-20 rounded-2xl object-cover border-2 border-emerald-500 shadow-sm">
                    <div class="absolute -bottom-1 -right-1 w-5 h-5 bg-emerald-600 text-white rounded-full flex items-center justify-center text-[10px] shadow border border-white" title="Nông trại đạt chứng nhận VietGAP">
                        <i class="fa-solid fa-check"></i>
                    </div>
                </div>
                <div class="space-y-1">
                    <div class="flex items-center gap-2">
                        <h3 class="text-base sm:text-lg font-black text-gray-900">${not empty shop.shopName ? shop.shopName : 'Nông Trại Hữu Cơ Mộc Châu'}</h3>
                        <span class="text-[10px] bg-emerald-50 text-emerald-800 font-bold px-2 py-0.5 rounded-full border border-emerald-200">
                            Chính Hãng
                        </span>
                    </div>
                    <p class="text-xs text-gray-400">Online 5 phút trước &bull; ${not empty shop.province ? shop.province : 'Mộc Châu, Sơn La'}</p>
                    <div class="flex items-center gap-2.5 pt-1.5">
                        <button type="button" onclick="alert('Đang kết nối khung trò chuyện trực tiếp với chủ nông trại!')" 
                                class="px-3.5 py-1.5 rounded-xl border border-emerald-600 text-emerald-700 hover:bg-emerald-50 font-bold text-xs transition flex items-center gap-1.5">
                            <i class="fa-regular fa-comment-dots"></i> Chat Ngay
                        </button>
                        <a href="${pageContext.request.contextPath}/store?id=${not empty shop.shopId ? shop.shopId : 1}" 
                           class="px-4 py-1.5 rounded-xl bg-emerald-800 hover:bg-emerald-900 text-white font-bold text-xs shadow-xs transition flex items-center gap-1.5">
                            <i class="fa-solid fa-store text-xs"></i> Xem Shop
                        </a>
                    </div>
                </div>
            </div>

            <!-- Vách ngăn đứng -->
            <div class="hidden md:block w-px h-16 bg-gray-100"></div>

            <!-- Cột phải: Chỉ số thống kê của Shop (Shopee style) -->
            <div class="grid grid-cols-3 gap-6 sm:gap-10 w-full md:w-auto text-left text-xs">
                <div>
                    <span class="text-gray-400 block text-[11px] mb-0.5">Đánh Giá</span>
                    <span class="font-black text-emerald-800 text-sm sm:text-base">${shop.rating != null ? shop.rating : '4.9'} <i class="fa-solid fa-star text-amber-400 text-xs"></i></span>
                </div>
                <div>
                    <span class="text-gray-400 block text-[11px] mb-0.5">Sản Phẩm</span>
                    <span class="font-black text-emerald-800 text-sm sm:text-base">${shopTotalProducts > 0 ? shopTotalProducts : '10'}</span>
                </div>
                <div>
                    <span class="text-gray-400 block text-[11px] mb-0.5">Tỉ Lệ Phản Hồi</span>
                    <span class="font-black text-emerald-800 text-sm sm:text-base">100%</span>
                </div>
            </div>
        </div>
    </section>

    <!-- PRODUCT DESCRIPTION SECTION -->
    <section class="max-w-7xl mx-auto px-4 pb-16">
        <div class="bg-white rounded-3xl p-8 sm:p-10 border border-gray-100 shadow-sm">
            <div class="border-b border-gray-100 pb-5 mb-6 flex items-center gap-2.5">
                <span class="w-2 h-6 bg-emerald-600 rounded-full"></span>
                <h3 class="text-xl sm:text-2xl font-black text-gray-900 tracking-tight">Mô Tả Sản Phẩm</h3>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
                <div class="lg:col-span-7 space-y-4">
                    <span class="text-[11px] font-extrabold uppercase tracking-widest text-emerald-800">ĐỘ TƯƠI GIÒN THƯỢNG HẠNG TỪ NÔNG TRẠI</span>
                    <h2 class="text-2xl sm:text-3xl font-black text-gray-900 tracking-tight">${not empty product.name ? product.name : 'Vị Ngọt Tự Nhiên & Độ Giòn Tan Đặc Trưng'}</h2>
                    <p class="text-xs sm:text-sm text-gray-600 leading-relaxed">
                        <c:choose>
                            <c:when test="${not empty product.description}">
                                ${product.description}
                            </c:when>
                            <c:otherwise>
                                Được canh tác tại các vùng đất màu mỡ với khí hậu ôn đới lý tưởng, sản phẩm đạt chứng nhận nông sản an toàn. Cây được nuôi dưỡng dưới ánh nắng tự nhiên và nguồn nước suối mát lành, giúp tích tụ lượng đường tự nhiên cao, cắn vào cảm nhận ngay độ giòn xốp mọng nước khó quên.
                            </c:otherwise>
                        </c:choose>
                    </p>

                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-3">
                        <div class="bg-emerald-50/50 border border-emerald-100 rounded-2xl p-4">
                            <div class="flex items-center gap-2 font-bold text-xs text-emerald-900 mb-1">
                                <i class="fa-solid fa-utensils text-emerald-700"></i> Hồ Sơ Vị Giác (Tasting Profile)
                            </div>
                            <p class="text-xs text-gray-600">Vị ngọt thanh tự nhiên, hương thơm hoa quả dịu nhẹ và thớ thịt giòn tan sảng khoái.</p>
                        </div>

                        <div class="bg-amber-50/50 border border-amber-100 rounded-2xl p-4">
                            <div class="flex items-center gap-2 font-bold text-xs text-amber-900 mb-1">
                                <i class="fa-solid fa-box-archive text-amber-700"></i> Hướng Dẫn Bảo Quản
                            </div>
                            <p class="text-xs text-gray-600">Bảo quản trong ngăn mát tủ lạnh ở nhiệt độ từ 2°C - 5°C để giữ trọn độ giòn đến 3-4 tuần.</p>
                        </div>
                    </div>

                    <div class="pt-3">
                        <h4 class="font-extrabold text-xs uppercase tracking-wider text-gray-900 mb-1">Gợi Ý Thưởng Thức</h4>
                        <p class="text-xs text-gray-500 leading-relaxed">
                            Rất thích hợp để ăn trực tiếp giải nhiệt, làm salad hoa quả trộn sốt sữa chua, ép nước detox thanh lọc cơ thể hoặc làm nhân các món bánh nướng tráng miệng thơm ngon.
                        </p>
                    </div>
                </div>

                <!-- Right Feature Image -->
                <div class="lg:col-span-5 rounded-2xl overflow-hidden shadow-sm aspect-4/3 bg-gray-50">
                    <img src="${not empty product.image ? product.image : 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=800'}" 
                         alt="${product.name}" 
                         onerror="this.src='https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=800'"
                         class="w-full h-full object-cover">
                </div>
            </div>
        </div>
    </section>

    <!-- SECTION: YOU MAY ALSO SAVOR (RECOMMENDED PRODUCTS) -->
    <section class="max-w-7xl mx-auto px-4 pb-20">
        <div class="flex items-center justify-between mb-6">
            <div>
                <span class="text-[11px] font-extrabold uppercase tracking-widest text-gray-400">TỪ CÁC NHÀ VƯỜN THÂN THIẾT</span>
                <h2 class="text-2xl font-black text-gray-900 tracking-tight">Có Thể Bạn Cũng Thích</h2>
            </div>
            <a href="${pageContext.request.contextPath}/products" class="text-xs font-bold text-emerald-800 hover:underline flex items-center gap-1">
                Khám phá tất cả trái cây <i class="fa-solid fa-arrow-right text-[10px]"></i>
            </a>
        </div>

        <!-- 4 Recommended Product Cards -->
        <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-6">
            <c:forEach var="rp" items="${relatedProducts}">
                <div class="bg-white rounded-2xl p-4 border border-gray-100 shadow-xs hover:shadow-md transition flex flex-col justify-between group">
                    <div>
                        <div class="relative aspect-square rounded-xl overflow-hidden bg-gray-50 mb-3">
                            <a href="${pageContext.request.contextPath}/detail?id=${rp.id}">
                                <img src="${rp.image}" alt="${rp.name}" class="w-full h-full object-cover group-hover:scale-105 transition duration-300">
                            </a>
                            <span class="absolute top-2 left-2 px-2 py-0.5 rounded text-[9px] font-extrabold uppercase bg-white/90 text-gray-800 shadow-xs">
                                ${rp.tag}
                            </span>
                            <button type="button" class="absolute top-2 right-2 w-7 h-7 rounded-full bg-white/90 text-gray-500 hover:text-red-500 flex items-center justify-center shadow-xs" title="Yêu thích">
                                <i class="fa-regular fa-heart text-[10px]"></i>
                            </button>
                        </div>
                        <span class="text-[10px] font-bold text-gray-400 uppercase tracking-wider block">${rp.origin}</span>
                        <h4 class="font-bold text-xs text-gray-900 mt-0.5 line-clamp-1 group-hover:text-emerald-700">
                            <a href="${pageContext.request.contextPath}/detail?id=${rp.id}">${rp.name}</a>
                        </h4>
                        <p class="text-[11px] text-gray-400 truncate mt-0.5 mb-3">Tươi ngon, giòn ngọt mọng nước tự nhiên.</p>
                    </div>

                    <div class="pt-2 border-t border-gray-100 flex items-center justify-between">
                        <div>
                            <span class="font-black text-gray-900 text-sm">
                                <c:choose>
                                    <c:when test="${rp.price >= 1000}">
                                        <fmt:formatNumber value="${rp.price}" pattern="#,###" /> ₫
                                    </c:when>
                                    <c:otherwise>
                                        $<fmt:formatNumber value="${rp.price}" pattern="#,##0.00" />
                                    </c:otherwise>
                                </c:choose>
                            </span>
                            <span class="text-[10px] text-gray-400">/${not empty rp.unit ? rp.unit : 'kg'}</span>
                        </div>
                        <form action="${pageContext.request.contextPath}/add-to-cart" method="GET">
                            <input type="hidden" name="productId" value="${rp.id}">
                            <button type="submit" class="px-3 py-1 rounded-full bg-emerald-50 hover:bg-emerald-700 text-emerald-800 hover:text-white font-bold text-xs transition">
                                &plus; Thêm
                            </button>
                        </form>
                    </div>
                </div>
            </c:forEach>
        </div>
    </section>

    <!-- FOOTER SECTION (FRESHFRUIT MARKETPLACE) -->
    <footer class="bg-white border-t border-gray-200/80 pt-14 pb-8 text-gray-600 text-xs">
        <div class="max-w-7xl mx-auto px-4">
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-10 pb-12 border-b border-gray-100">
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
                        <span class="text-xl font-black text-gray-900">Fresh<span class="text-emerald-700">Fruit</span></span>
                    </div>
                    <p class="text-gray-500 max-w-sm leading-relaxed">
                        Nền tảng cung cấp trái cây và nông sản tươi sạch chuẩn VietGAP, kết nối trực tiếp từ nông trại tới bàn ăn của gia đình bạn.
                    </p>
                    <div class="flex items-center gap-3 pt-2 text-gray-400">
                        <a href="#" class="w-8 h-8 rounded-full bg-gray-100 hover:bg-emerald-50 hover:text-emerald-700 flex items-center justify-center transition"><i class="fa-solid fa-globe"></i></a>
                        <a href="#" class="w-8 h-8 rounded-full bg-gray-100 hover:bg-emerald-50 hover:text-emerald-700 flex items-center justify-center transition"><i class="fa-brands fa-facebook-f"></i></a>
                        <a href="#" class="w-8 h-8 rounded-full bg-gray-100 hover:bg-emerald-50 hover:text-emerald-700 flex items-center justify-center transition"><i class="fa-brands fa-instagram"></i></a>
                        <a href="#" class="w-8 h-8 rounded-full bg-gray-100 hover:bg-emerald-50 hover:text-emerald-700 flex items-center justify-center transition"><i class="fa-brands fa-tiktok"></i></a>
                    </div>
                </div>

                <!-- Col 2: Quick Links -->
                <div>
                    <h4 class="font-extrabold text-gray-900 text-sm mb-3">Liên Kết Nhanh</h4>
                    <ul class="space-y-2 text-gray-500">
                        <li><a href="${pageContext.request.contextPath}/home" class="hover:text-emerald-700 transition">Trang Chủ</a></li>
                        <li><a href="${pageContext.request.contextPath}/products" class="hover:text-emerald-700 transition">Tất Cả Trái Cây</a></li>
                        <li><a href="${pageContext.request.contextPath}/deals" class="hover:text-emerald-700 transition">Khuyến Mãi Mùa Vụ</a></li>
                        <li><a href="${pageContext.request.contextPath}/products?tag=organic" class="hover:text-emerald-700 transition">Nông Sản Hữu Cơ</a></li>
                        <li><a href="${pageContext.request.contextPath}/products" class="hover:text-emerald-700 transition">Giỏ Quà Biếu Tặng</a></li>
                        <li><a href="${pageContext.request.contextPath}/wholesale" class="hover:text-emerald-700 transition">Bán Sỉ Doanh Nghiệp</a></li>
                    </ul>
                </div>

                <!-- Col 3: Customer Service -->
                <div>
                    <h4 class="font-extrabold text-gray-900 text-sm mb-3">Chăm Sóc Khách Hàng</h4>
                    <ul class="space-y-2 text-gray-500">
                        <li><a href="#" class="hover:text-emerald-700 transition">Hỏi Đáp & Trợ Giúp</a></li>
                        <li><a href="${pageContext.request.contextPath}/orders" class="hover:text-emerald-700 transition">Tra Cứu Đơn Hàng</a></li>
                        <li><a href="#" class="hover:text-emerald-700 transition">Chính Sách Vận Chuyển</a></li>
                        <li><a href="#" class="hover:text-emerald-700 transition">Chính Sách Đổi Trả</a></li>
                        <li><a href="#" class="hover:text-emerald-700 transition">Liên Hệ Khiếu Nại</a></li>
                    </ul>
                </div>

                <!-- Col 4: Contact & Payment -->
                <div>
                    <h4 class="font-extrabold text-gray-900 text-sm mb-3">Liên Hệ & Thanh Toán</h4>
                    <ul class="space-y-2 text-gray-500 mb-4">
                        <li class="flex items-center gap-2"><i class="fa-solid fa-phone text-emerald-700"></i> 1900 6868</li>
                        <li class="flex items-center gap-2"><i class="fa-solid fa-envelope text-emerald-700"></i> support@freshfruit.vn</li>
                        <li class="flex items-center gap-2"><i class="fa-solid fa-location-dot text-emerald-700"></i> Lâm Đồng & TP. Hồ Chí Minh</li>
                    </ul>
                    <div class="text-[10px] font-extrabold uppercase text-gray-400 mb-2">Phương thức thanh toán</div>
                    <div class="flex items-center gap-2 text-xs font-bold text-gray-700">
                        <span class="px-2 py-1 bg-gray-100 rounded">VNPAY</span>
                        <span class="px-2 py-1 bg-gray-100 rounded">MOMO</span>
                        <span class="px-2 py-1 bg-gray-100 rounded">VISA</span>
                        <span class="px-2 py-1 bg-gray-100 rounded">COD</span>
                    </div>
                </div>
            </div>

            <div class="pt-8 flex flex-col sm:flex-row items-center justify-between gap-4 text-gray-400 text-[11px]">
                <p>&copy; 2026 FreshFruit Marketplace. Đã đăng ký toàn bộ bản quyền.</p>
                <div class="flex items-center gap-5">
                    <a href="#" class="hover:underline">Chính Sách Bảo Mật</a>
                    <a href="#" class="hover:underline">Điều Khoản Dịch Vụ</a>
                    <a href="#" class="hover:underline">Sơ Đồ Trang Web</a>
                </div>
            </div>
        </div>
    </footer>

</body>
</html>
