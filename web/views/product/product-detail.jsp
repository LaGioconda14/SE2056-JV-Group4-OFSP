<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- ==================== MOCK DATA DỰ PHÒNG ==================== --%>
<c:if test="${empty product}">
    <%
        java.util.Map<String, Object> p = new java.util.HashMap<>();
        p.put("id", 1L);
        p.put("name", "Bưởi Da Xanh Bến Tre Ruột Hồng");
        p.put("categoryName", "Bưởi, Cam, Quýt");
        p.put("price", 75000.0);
        p.put("oldPrice", 85000.0);
        p.put("discountPercent", 12);
        p.put("rating", 4.9);
        p.put("reviewsCount", 128);
        p.put("certification", "VietGAP");
        p.put("inStock", true);
        p.put("origin", "Bến Tre");
        p.put("unit", "quả");
        p.put("image", "https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=600&fit=crop");
        p.put("description", "Bưởi Da Xanh Bến Tre ruột hồng nổi tiếng với tép bưởi căng mọng, vị ngọt thanh tự nhiên xen lẫn chút vị chua nhẹ rất hài hòa mà không hề bị đắng. Vỏ bưởi mỏng màu xanh tươi tự nhiên.");
        pageContext.setAttribute("product", p);
    %>
</c:if>

<c:if test="${empty variants}">
    <%
        java.util.List<java.util.Map<String, Object>> vars = new java.util.ArrayList<>();
        java.util.Map<String, Object> v1 = new java.util.HashMap<>();
        v1.put("variantId", 101); v1.put("variantName", "Quả tuyển loại 1 (1.4 - 1.6kg)"); v1.put("price", 75000.0); v1.put("original_price", 85000.0); v1.put("unit", "quả"); v1.put("stockQuantity", 50);
        
        java.util.Map<String, Object> v2 = new java.util.HashMap<>();
        v2.put("variantId", 102); v2.put("variantName", "Combo 5 quả (7 - 8kg)"); v2.put("price", 350000.0); v2.put("original_price", 400000.0); v2.put("unit", "combo"); v2.put("stockQuantity", 20);
        
        java.util.Map<String, Object> v3 = new java.util.HashMap<>();
        v3.put("variantId", 103); v3.put("variantName", "Thùng 10 quả"); v3.put("price", 690000.0); v3.put("original_price", 780000.0); v3.put("unit", "thùng"); v3.put("stockQuantity", 0);
        
        vars.add(v1); vars.add(v2); vars.add(v3);
        pageContext.setAttribute("variants", vars);
    %>
</c:if>

<c:if test="${empty imageList}">
    <%
        java.util.List<java.util.Map<String, String>> imgs = new java.util.ArrayList<>();
        for(int i=1; i<=4; i++) {
            java.util.Map<String, String> img = new java.util.HashMap<>();
            img.put("imageUrl", "https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=600&fit=crop");
            imgs.add(img);
        }
        pageContext.setAttribute("imageList", imgs);
    %>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <meta content="width=device-width, initial-scale=1.0" name="viewport">
    <title>${product.name} - FreshFruit</title>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: { sans: ['Inter', 'sans-serif'] },
                    colors: {
                        primary: '#059669',
                        'primary-hover': '#047857',
                        'primary-light': '#ecfdf5',
                        accent: '#FBBF24',
                        'brand-bg': '#FAFAFA',
                        'text-main': '#1F2937',
                        'text-muted': '#6B7280',
                    }
                }
            }
        };
    </script>
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #FAFAFA; color: #1F2937; -webkit-font-smoothing: antialiased; }
    </style>
</head>
<body class="bg-brand-bg text-text-main min-h-screen flex flex-col justify-between">
    <c:set var="currentUser" value="${not empty sessionScope.account ? sessionScope.account : sessionScope.user}" />

    <!-- Header dùng chung với trang chủ và trang danh mục -->
    <header class="sticky top-0 z-40 bg-white shadow-md transition-all">
        <div class="max-w-7xl mx-auto px-4 py-3 sm:py-4">
            <div class="flex items-center justify-between gap-4">
                <a href="${pageContext.request.contextPath}/home" class="flex items-center gap-3 group shrink-0">
                    <div class="w-11 h-11 sm:w-12 sm:h-12 bg-emerald-50 rounded-full flex items-center justify-center p-1.5 shadow-sm border border-emerald-100">
                        <svg viewBox="0 0 100 100" class="w-full h-full">
                            <circle cx="50" cy="56" r="32" fill="#16a34a"/>
                            <path d="M 28 45 Q 36 34 50 34" stroke="#ffffff" stroke-width="6" stroke-linecap="round" fill="none"/>
                            <circle cx="68" cy="46" r="5" fill="#ffffff"/>
                            <path d="M 52 26 C 58 16 68 14 74 18 C 74 24 64 32 52 26 Z" fill="#f97316"/>
                        </svg>
                    </div>
                    <span class="flex items-baseline text-xl sm:text-2xl font-extrabold tracking-tight"><span class="text-gray-900">Fresh</span><span class="text-emerald-600">Fruit</span></span>
                </a>

                <form action="${pageContext.request.contextPath}/search" method="GET" class="relative flex-1 max-w-lg mx-4 hidden md:block">
                    <input type="search" name="query" placeholder="Tìm kiếm hoa quả tươi sạch, táo, cam..." class="w-full bg-gray-100 border border-transparent rounded-xl px-4 py-2.5 pr-11 text-sm outline-none focus:bg-white focus:border-emerald-500 transition">
                    <button type="submit" aria-label="Tìm kiếm" class="absolute right-2 top-1/2 -translate-y-1/2 w-8 h-8 rounded-lg bg-emerald-600 text-white hover:bg-emerald-700"><i class="fa-solid fa-magnifying-glass text-xs"></i></button>
                </form>

                <div class="flex items-center gap-3 sm:gap-4">
                    <c:if test="${currentUser.role eq 'SHOP_OWNER'}">
                        <a href="${pageContext.request.contextPath}/shop/products" class="hidden lg:inline-flex items-center gap-1.5 px-3 py-2 bg-emerald-50 text-emerald-800 rounded-xl text-xs font-bold"><i class="fa-solid fa-sliders"></i> Kênh người bán</a>
                    </c:if>
                    <c:choose>
                        <c:when test="${empty currentUser}">
                            <div class="flex items-center gap-2 text-sm font-semibold">
                                <a href="${pageContext.request.contextPath}/login" class="text-gray-700 hover:text-emerald-600">Đăng nhập</a>
                                <span class="text-gray-300">/</span>
                                <a href="${pageContext.request.contextPath}/register" class="text-emerald-700 hover:text-emerald-800">Đăng ký</a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <span class="hidden sm:block text-sm font-bold text-gray-800">${not empty currentUser.fullName ? currentUser.fullName : currentUser.username}</span>
                        </c:otherwise>
                    </c:choose>
                    <a href="${pageContext.request.contextPath}/cart" class="relative p-2.5 bg-emerald-50 hover:bg-emerald-100 text-emerald-700 rounded-xl transition flex items-center gap-2">
                        <i class="fa-solid fa-bag-shopping text-lg"></i><span class="hidden sm:inline font-bold text-sm">Giỏ hàng</span>
                        <span id="cartBadge" class="absolute -top-1.5 -right-1.5 bg-amber-500 text-white text-xs w-5 h-5 rounded-full flex items-center justify-center font-bold border-2 border-white">${sessionScope.cartSize != null ? sessionScope.cartSize : 0}</span>
                    </a>
                </div>
            </div>
        </div>
        <div class="md:hidden px-4 pb-3">
            <form action="${pageContext.request.contextPath}/search" method="GET" class="relative">
                <input type="search" name="query" placeholder="Tìm kiếm sản phẩm..." class="w-full bg-gray-100 border border-transparent rounded-xl px-4 py-2.5 pr-11 text-sm outline-none focus:bg-white focus:border-emerald-500 transition">
                <button type="submit" aria-label="Tìm kiếm" class="absolute right-2 top-1/2 -translate-y-1/2 w-8 h-8 rounded-lg bg-emerald-600 text-white"><i class="fa-solid fa-magnifying-glass text-xs"></i></button>
            </form>
        </div>
        <nav class="bg-emerald-900 text-white hidden md:block">
            <div class="max-w-7xl mx-auto px-4 flex items-center text-sm font-medium">
                <a href="${pageContext.request.contextPath}/home" class="px-4 py-3 inline-flex items-center gap-2 hover:text-white text-gray-200"><i class="fa-solid fa-house"></i> Trang chủ</a>
                <a href="${pageContext.request.contextPath}/store" class="px-4 py-3 inline-flex items-center gap-2 hover:text-white text-gray-200"><i class="fa-solid fa-store text-xs"></i> Gian hàng nông trại</a>
                <a href="${pageContext.request.contextPath}/products" class="px-4 py-3 inline-flex items-center gap-2 text-white font-semibold"><i class="fa-solid fa-layer-group text-xs"></i> Tất cả sản phẩm</a>
                <a href="${pageContext.request.contextPath}/home#featured" class="px-4 py-3 inline-flex items-center gap-2 text-amber-300"><i class="fa-solid fa-fire"></i> Sản phẩm nổi bật</a>
            </div>
        </nav>
    </header>

    <!-- MAIN CONTAINER -->
    <main class="max-w-7xl w-full mx-auto px-4 py-6 sm:py-8 flex-1">
        
        <!-- BREADCRUMB -->
        <nav class="flex items-center text-xs text-text-muted mb-4">
            <a href="${pageContext.request.contextPath}/home" class="hover:text-text-main transition-colors">Trang chủ</a>
            <span class="mx-2 text-gray-300">/</span>
            <a href="${pageContext.request.contextPath}/products" class="hover:text-text-main transition-colors">Sản phẩm</a>
            <span class="mx-2 text-gray-300">/</span>
            <span class="text-text-main font-semibold truncate max-w-xs">${product.name}</span>
        </nav>

        <!-- MAIN PRODUCT GRID -->
        <div class="grid grid-cols-12 gap-6 lg:gap-8 items-start mb-8">
            
            <!-- LEFT: GALLERY (GỌN VỪA KHUNG) -->
            <div class="col-span-12 lg:col-span-6 sticky top-24">
                <div class="relative w-full aspect-square max-h-[420px] rounded-2xl overflow-hidden bg-white border border-gray-100 shadow-2xs">
                    <c:if test="${product.discountPercent > 0}">
                        <span class="absolute top-3 left-3 z-10 px-2.5 py-1 rounded-lg bg-amber-400 text-gray-900 font-bold text-xs tracking-wider shadow-2xs">
                            -${product.discountPercent}%
                        </span>
                    </c:if>
                    <img id="main-product-img" src="${product.image}" alt="${product.name}" class="w-full h-full object-cover">
                </div>

                <div class="grid grid-cols-4 gap-2.5 mt-3">
                    <c:forEach var="img" items="${imageList}" varStatus="status">
                        <button type="button" onclick="changeMainImage('${img.imageUrl}', this)" class="thumbnail-btn aspect-square rounded-xl overflow-hidden border-2 ${status.first ? 'border-primary' : 'border-gray-100 hover:border-gray-200'} bg-white transition-all p-0.5">
                            <img src="${img.imageUrl}" alt="Ảnh ${status.index + 1}" class="w-full h-full object-cover rounded-lg">
                        </button>
                    </c:forEach>
                </div>
            </div>

            <!-- RIGHT: DETAILS & ACTIONS -->
            <div class="col-span-12 lg:col-span-6 flex flex-col gap-4">
                
                <div>
                    <span class="inline-block px-2.5 py-0.5 rounded-full bg-emerald-50 text-primary text-[11px] font-semibold mb-1.5">
                        ${product.categoryName}
                    </span>
                    <h1 class="text-2xl font-extrabold text-gray-900 tracking-tight leading-snug">
                        ${product.name}
                    </h1>
                </div>

                <!-- Rating & Origin Meta -->
                <div class="flex items-center gap-3 text-xs">
                    <div class="flex items-center gap-1">
                        <div class="flex text-amber-400">
                            <c:forEach begin="1" end="5" var="i"><svg class="w-3.5 h-3.5 fill-current" viewBox="0 0 20 20"><path d="M10 15l-5.878 3.09 1.123-6.545L.489 6.91l6.572-.955L10 0l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545z"/></svg></c:forEach>
                        </div>
                        <span class="font-bold text-gray-800">${product.rating}</span>
                        <span class="text-text-muted">(${product.reviewsCount} đánh giá)</span>
                    </div>
                    <span class="text-gray-200">|</span>
                    <span class="px-2 py-0.5 rounded bg-emerald-50 text-primary font-medium text-[11px]">${product.certification}</span>
                    <span class="text-gray-200">|</span>
                    <span class="text-primary font-semibold">Còn hàng</span>
                </div>

                <!-- Compact Price Box -->
                <div class="bg-gray-50/80 rounded-xl px-4 py-3 border border-gray-100 flex items-baseline gap-3">
                    <span class="text-2xl font-extrabold text-primary" id="display-price">
                        <fmt:formatNumber value="${product.price}" pattern="#,##0"/>đ
                    </span>
                    <span class="text-text-muted text-xs font-medium" id="display-unit">/${product.unit}</span>
                    <span class="text-gray-400 line-through text-xs ml-auto" id="display-old-price">
                        <fmt:formatNumber value="${product.oldPrice}" pattern="#,##0"/>đ
                    </span>
                </div>

                <!-- Quick Facts -->
                <div class="grid grid-cols-2 gap-3 text-xs text-text-muted">
                    <div class="flex items-center gap-2">
                        <span class="w-6 h-6 rounded-full bg-gray-100 flex items-center justify-center shrink-0">📍</span>
                        <span>Xuất xứ: <strong class="text-gray-800">${product.origin}</strong></span>
                    </div>
                    <div class="flex items-center gap-2">
                        <span class="w-6 h-6 rounded-full bg-gray-100 flex items-center justify-center shrink-0">🌡️</span>
                        <span>Bảo quản: <strong class="text-gray-800">10-14°C</strong></span>
                    </div>
                </div>

                <!-- ADD TO CART FORM -->
                <form action="${pageContext.request.contextPath}/cart" method="POST" id="add-to-cart-form" class="space-y-4">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="productId" value="${product.id}">
                    <input type="hidden" name="variantId" id="selected-variant-id" value="${variants[0].variantId}">

                    <!-- QUY CÁCH ĐÓNG GÓI (NHỎ GỌN, TINH TẾ) -->
                    <div>
                        <div class="flex justify-between items-center mb-2">
                            <label class="text-xs font-bold text-gray-900">Quy cách đóng gói</label>
                        </div>
                        <div class="flex flex-col gap-2">
                            <c:forEach var="v" items="${variants}" varStatus="status">
                                <div onclick="selectVariant(this, '${v.variantId}', '${v.price}', '${v.originalPrice}', '${v.unit}', ${v.stockQuantity})" 
                                     class="option-pill px-3.5 py-2.5 rounded-xl border ${status.first ? 'border-primary bg-emerald-50/30' : 'border-gray-200 bg-white hover:border-gray-300'} flex items-center justify-between ${v.stockQuantity <= 0 ? 'opacity-60 bg-gray-50 cursor-not-allowed' : 'cursor-pointer'} transition-all">
                                    <span class="text-xs font-medium text-gray-800">${v.variantName}</span>
                                    <div class="text-right">
                                        <span class="text-xs font-bold ${status.first ? 'text-primary' : 'text-gray-900'}">
                                            <fmt:formatNumber value="${v.price}" pattern="#,##0"/>đ
                                        </span>
                                        <c:if test="${v.stockQuantity <= 0}">
                                            <span class="text-[10px] font-bold text-red-500 block">Hết hàng</span>
                                        </c:if>
                                        <c:if test="${v.stockQuantity > 0}">
                                            <span class="text-[10px] text-gray-500 block">Còn ${v.stockQuantity} sản phẩm</span>
                                        </c:if>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- QUANTITY -->
                    <div>
                        <label class="block text-xs font-bold text-gray-900 mb-2">Số lượng</label>
                        <div class="inline-flex items-center rounded-xl border border-gray-200 bg-white p-0.5">
                            <button type="button" onclick="updateQty(-1)" class="w-8 h-8 rounded-lg text-gray-500 hover:bg-gray-100 font-bold text-sm flex items-center justify-center">-</button>
                            <input type="number" id="quantity-input" name="quantity" value="1" min="1" readonly class="w-10 text-center font-bold text-gray-900 text-xs border-0 outline-none">
                            <button type="button" onclick="updateQty(1)" class="w-8 h-8 rounded-lg text-gray-500 hover:bg-gray-100 font-bold text-sm flex items-center justify-center">+</button>
                        </div>
                    </div>

                    <!-- BUTTON -->
                    <button type="submit" class="w-full py-3 rounded-xl bg-primary hover:bg-primary-hover text-white font-bold text-xs sm:text-sm flex items-center justify-center gap-2 shadow-md shadow-emerald-600/10 active:scale-[0.99] transition-all">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"/></svg>
                        <span>Thêm vào giỏ hàng</span>
                    </button>
                </form>

                <!-- COMMITMENTS -->
                <div class="pt-2 border-t border-gray-100 flex justify-between gap-2 text-[11px] text-text-muted">
                    <span>⚡ Giao nhanh mỗi ngày</span>
                    <span>🔄 Chính sách đổi trả 1-1</span>
                </div>

            </div>
        </div>

        <!-- MÔ TẢ & THÔNG TIN CHI TIẾT -->
        <div class="grid grid-cols-12 gap-6 mb-10">
            <div class="col-span-12 lg:col-span-7 bg-white rounded-2xl p-6 border border-gray-100 shadow-2xs">
                <h3 class="text-base font-bold text-gray-900 mb-3 pb-2 border-b border-gray-100">Mô tả sản phẩm</h3>
                <p class="text-xs text-text-muted leading-relaxed">${product.description}</p>
            </div>

            <div class="col-span-12 lg:col-span-5 bg-white rounded-2xl p-6 border border-gray-100 shadow-2xs">
                <h3 class="text-base font-bold text-gray-900 mb-3 pb-2 border-b border-gray-100">Thông tin chi tiết</h3>
                <div class="divide-y divide-gray-50 text-xs space-y-2">
                    <div class="pt-2 flex justify-between"><span class="text-text-muted">Danh mục</span><span class="font-semibold text-gray-800">${product.categoryName}</span></div>
                    <div class="pt-2 flex justify-between"><span class="text-text-muted">Xuất xứ</span><span class="font-semibold text-gray-800">${product.origin}</span></div>
                    <div class="pt-2 flex justify-between"><span class="text-text-muted">Chứng nhận</span><span class="font-semibold text-emerald-600">${product.certification}</span></div>
                </div>
            </div>
        </div>

    </main>

    <!-- FOOTER -->
    <footer class="bg-gray-950 text-gray-300 pt-12 pb-8 border-t border-gray-800 mt-12">
        <div class="max-w-7xl mx-auto px-4">
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8 mb-10">
                <div class="lg:col-span-2">
                    <a href="${pageContext.request.contextPath}/home" class="inline-flex items-center gap-3 mb-4">
                        <span class="w-10 h-10 rounded-full bg-emerald-50 flex items-center justify-center text-emerald-600"><i class="fa-solid fa-leaf"></i></span>
                        <span class="text-xl font-extrabold text-white">Fresh<span class="text-emerald-500">Fruit</span></span>
                    </a>
                    <p class="max-w-md text-sm leading-relaxed text-gray-400">Hoa quả tươi sạch từ các nông trại, được tuyển chọn và giao đến tận nhà.</p>
                </div>
                <div>
                    <h2 class="font-bold text-white mb-4">Mua sắm</h2>
                    <ul class="space-y-2.5 text-sm text-gray-400">
                        <li><a href="${pageContext.request.contextPath}/products" class="hover:text-emerald-400 transition">Tất cả sản phẩm</a></li>
                        <li><a href="${pageContext.request.contextPath}/store" class="hover:text-emerald-400 transition">Gian hàng nông trại</a></li>
                        <li><a href="${pageContext.request.contextPath}/cart" class="hover:text-emerald-400 transition">Giỏ hàng</a></li>
                    </ul>
                </div>
                <div>
                    <h2 class="font-bold text-white mb-4">Tài khoản</h2>
                    <ul class="space-y-2.5 text-sm text-gray-400">
                        <li><a href="${pageContext.request.contextPath}/login" class="hover:text-emerald-400 transition">Đăng nhập</a></li>
                        <li><a href="${pageContext.request.contextPath}/register" class="hover:text-emerald-400 transition">Đăng ký</a></li>
                    </ul>
                </div>
            </div>
            <div class="border-t border-gray-800 pt-5 text-center text-xs text-gray-500">
                © 2026 FreshFruit Marketplace. Bảo lưu mọi quyền.
            </div>
        </div>
    </footer>

    <!-- INTERACTIVE SCRIPT -->
    <script>
        function changeMainImage(url, btnElement) {
            document.getElementById('main-product-img').src = url;
            document.querySelectorAll('.thumbnail-btn').forEach(btn => {
                btn.classList.remove('border-primary');
                btn.classList.add('border-gray-100');
            });
            btnElement.classList.remove('border-gray-100');
            btnElement.classList.add('border-primary');
        }

        function updateQty(change) {
            const input = document.getElementById('quantity-input');
            let val = parseInt(input.value) + change;
            if (val >= 1) input.value = val;
        }

        function selectVariant(element, variantId, price, originalPrice, unit, stock) {
            if (stock <= 0) return;

            document.getElementById('selected-variant-id').value = variantId;
            document.getElementById('display-price').innerText = new Intl.NumberFormat('vi-VN').format(price) + 'đ';
            document.getElementById('display-unit').innerText = '/' + (unit || 'kg');

            document.querySelectorAll('.option-pill').forEach(opt => {
                opt.classList.remove('border-primary', 'bg-emerald-50/30');
                opt.classList.add('border-gray-200', 'bg-white');
                const priceText = opt.querySelector('.text-primary');
                if(priceText) {
                    priceText.classList.remove('text-primary');
                    priceText.classList.add('text-gray-900');
                }
            });

            element.classList.remove('border-gray-200', 'bg-white');
            element.classList.add('border-primary', 'bg-emerald-50/30');
            const activePrice = element.querySelector('.text-gray-900');
            if(activePrice) {
                activePrice.classList.remove('text-gray-900');
                activePrice.classList.add('text-primary');
            }
        }
    </script>
</body>
</html>
