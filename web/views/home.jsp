<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    // Tự động load danh sách sản phẩm trang chủ và danh mục qua Service nếu truy cập trực tiếp
    if (request.getAttribute("listProduct") == null) {
        service.IProductService pService = new service.impl.ProductServiceImpl();
        request.setAttribute("listProduct", pService.getHomeProducts());
        request.setAttribute("homeTabs", pService.getHomeFeaturedTabs());
        request.setAttribute("hierarchyCategories", pService.getHierarchyCategories());
        request.setAttribute("categories", pService.getAllCategories());
    }
    if (request.getAttribute("homeTabs") == null) {
        service.IProductService pService = new service.impl.ProductServiceImpl();
        request.setAttribute("homeTabs", pService.getHomeFeaturedTabs());
    }
    if (request.getAttribute("hierarchyCategories") == null) {
        service.IProductService pService = new service.impl.ProductServiceImpl();
        request.setAttribute("hierarchyCategories", pService.getHierarchyCategories());
    }
%>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Gốc Vườn - Siêu Thị Hoa Quả Tươi Sạch</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
        <script src="${pageContext.request.contextPath}/assets/js/home.js" defer></script>

    </head>
    <body class="bg-gray-50 text-gray-800 font-sans antialiased selection:bg-emerald-500 selection:text-white">

        <c:set var="currentUser" value="${not empty sessionScope.account ? sessionScope.account : sessionScope.user}" />

        <jsp:include page="/views/common/header.jsp" />

        <section class="hero-banner">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
                <div class="relative z-10 max-w-3xl">
                    <div class="hero-badge">
                        <i class="fa-solid fa-award text-amber-300"></i> 100% Organic Đạt Chuẩn VietGAP & GlobalGAP
                    </div>
                    <h1 class="hero-title">
                        Hoa Quả Tươi Sạch,<br>Giao Nhanh Mỗi Ngày.
                    </h1>
                    <p class="hero-desc">
                        Tuyển chọn từ những nông trại hữu cơ hàng đầu, thu hoạch chín tự nhiên và vận chuyển bằng công nghệ lạnh khép kín giữ trọn vitamin.
                    </p>
                    <div class="flex flex-wrap items-center gap-4">
                        <a href="#featured" class="hero-btn-primary">
                            Mua Ngay <i class="fa-solid fa-arrow-right"></i>
                        </a>
                        <a href="#categories" class="hero-btn-secondary">
                            Khám Phá Danh Mục
                        </a>
                    </div>
                </div>
            </div>
        </section>

        <section id="categories" class="max-w-7xl mx-auto px-4 py-8">
            <div class="flex justify-between items-end mb-6">
                <div>
                    <h2 class="text-xl sm:text-2xl font-extrabold text-gray-900 tracking-tight flex items-center gap-2">
                        <i class="fa-solid fa-layer-group text-emerald-600"></i> Khám Phá Danh Mục Nông Sản
                    </h2>
                    <p class="text-xs sm:text-sm text-gray-500 mt-1">Tuyển tập hoa quả tươi ngon, chuẩn sạch VietGAP & GlobalGAP theo nhu cầu dinh dưỡng</p>
                </div>
                <a href="${pageContext.request.contextPath}/products" class="text-xs sm:text-sm font-bold text-emerald-600 hover:text-emerald-700 flex items-center gap-1 transition group">
                    Xem Tất Cả <i class="fa-solid fa-arrow-right group-hover:translate-x-1 transition-transform"></i>
                </a>
            </div>

            <div class="bg-white rounded-3xl p-6 sm:p-8 border border-gray-100 shadow-sm">
                <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4 sm:gap-6">
                    <c:forEach var="cat" items="${categories}">
                        <c:set var="nameLower" value="${fn:toLowerCase(cat.categoryName)}" />
                        
                        <c:set var="realImg" value="https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=200&h=200&fit=crop" />
                        
                        <c:choose>
                            <c:when test="${fn:contains(nameLower, 'táo envy')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'táo') or fn:contains(nameLower, 'lê') or fn:contains(nameLower, 'ổi')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1570913149827-d2ac84ab3f9a?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'nho')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'xoài') or fn:contains(nameLower, 'chuối')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1553279768-865429fa0078?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'dâu') or fn:contains(nameLower, 'mọng')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'dưa hấu') or fn:contains(nameLower, 'dưa lưới') or fn:contains(nameLower, 'giải nhiệt')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'thanh long')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1527661591475-527312dd65f5?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'bưởi') or fn:contains(nameLower, 'cam') or fn:contains(nameLower, 'quýt')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1611080626919-7cf5a9dbab5b?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'kiwi')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1585059895050-66e5b5a21670?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'mận')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1596363505789-4e6139223594?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'hộp quà') or fn:contains(nameLower, 'quà tặng')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'nhập khẩu')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'việt nam')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1528825871115-3581a5387919?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'thùng') or fn:contains(nameLower, 'nguyên kiện')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1595855759920-86582396756a?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'cắt sẵn') or fn:contains(nameLower, 'eat-clean') or fn:contains(nameLower, 'văn phòng')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1519996529931-28324d5a630e?w=200&h=200&fit=crop" />
                            </c:when>
                        </c:choose>

                        <a href="${pageContext.request.contextPath}/products?category=${cat.slug}" 
                           class="group flex flex-col items-center justify-center p-4 rounded-2xl bg-gray-50/70 hover:bg-emerald-50/60 border border-gray-100 hover:border-emerald-200 transition-all duration-300 hover:-translate-y-1 hover:shadow-md text-center">
                            
                            <div class="w-16 h-16 sm:w-20 sm:h-20 rounded-full flex items-center justify-center mb-3 bg-white border-2 border-gray-100 group-hover:border-emerald-500 shadow-xs group-hover:scale-105 transition-all duration-300 overflow-hidden">
                                <img src="${not empty cat.imageUrl ? pageContext.request.contextPath.concat('/').concat(cat.imageUrl) : realImg}" 
                                     alt="${cat.categoryName}" 
                                     data-fallback="${realImg}" 
                                     class="category-card-img w-full h-full object-cover group-hover:scale-110 transition-transform duration-500">
                            </div>

                            <h3 class="font-bold text-xs sm:text-sm text-gray-800 group-hover:text-emerald-600 transition line-clamp-2 leading-snug">
                                ${cat.categoryName}
                            </h3>
                        </a>
                    </c:forEach>
                </div>
            </div>
        </section>

        <section id="featured" class="max-w-7xl mx-auto px-4 py-8">
            <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4">
                <div>
                    <h2 class="text-xl sm:text-2xl font-extrabold text-gray-900 tracking-tight">Sản Phẩm Tươi Ngon Theo Danh Mục</h2>
                    <p class="text-xs sm:text-sm text-gray-500">Tuyển tập hoa quả hữu cơ chuẩn VietGAP & GlobalGAP tươi sạch mỗi ngày</p>
                </div>
            </div>

            <div id="homeProductGrid" class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
                <c:choose>
                    <c:when test="${not empty listProduct}">
                        <c:forEach var="p" items="${listProduct}">

                            <div class="product-card group">
                                <div>
                                    <a href="${pageContext.request.contextPath}/detail?id=${p.id}" class="product-thumb">
                                        <img src="${p.image}" alt="${p.name}">
                                    </a>
                                    
                                    <div class="product-meta">
                                        <span class="product-cat-name">${p.categoryName}</span>

                                    </div>

                                    <h3 class="product-name" title="${p.name}">
                                        <a href="${pageContext.request.contextPath}/detail?id=${p.id}">${p.name}</a>
                                    </h3>

                                    <c:if test="${not empty p.origin}">
                                        <p class="product-origin">
                                            <i class="fa-solid fa-location-dot text-[10px] text-emerald-600"></i> ${p.origin}
                                        </p>
                                    </c:if>
                                </div>

                                <div class="product-card-footer">
                                    <div>
                                        <span class="product-price">
                                            <fmt:formatNumber value="${p.price}" pattern="#,###" />đ
                                            <c:if test="${not empty p.unit}">
                                                <span class="text-xs font-semibold text-emerald-800/70">/${p.unit}</span>
                                            </c:if>
                                        </span>
                                        <c:if test="${p.oldPrice > p.price}">
                                            <span class="product-old-price">
                                                <fmt:formatNumber value="${p.oldPrice}" pattern="#,###" />đ
                                            </span>
                                        </c:if>
                                    </div>

                                    <form action="${pageContext.request.contextPath}/cart/add" method="POST">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.cartCsrfToken}" />
                                        <input type="hidden" name="variantId" value="${p.defaultVariantId}" />
                                        <input type="hidden" name="quantity" value="1" />
                                        <button type="submit" class="btn-add-cart" title="${p.defaultVariantId gt 0 ? 'Thêm vào giỏ hàng' : 'Sản phẩm đã hết hàng'}" ${p.defaultVariantId le 0 ? 'disabled' : ''}>
                                            <i class="fa-solid fa-cart-plus"></i>
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="col-span-full text-center py-12 bg-white rounded-3xl border border-gray-100 shadow-sm">
                            <i class="fa-solid fa-box-open text-4xl text-gray-300 mb-3"></i>
                            <p class="text-gray-500 font-medium text-base">Chưa có sản phẩm nào được cập nhật.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>

        <footer id="about" class="bg-gray-950 text-gray-300 pt-16 pb-8 border-t border-gray-800 mt-12">
            <div class="max-w-7xl mx-auto px-4">
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

                            <span class="text-xl font-extrabold text-white">Gốc <span class="text-emerald-500">Vườn</span></span>
                        </div>
                        <p class="text-xs sm:text-sm text-gray-400 mb-6 leading-relaxed max-w-sm">
                            Hệ thống phân phối hoa quả tươi sạch hàng đầu Việt Nam. Mang thiên nhiên thuần khiết và nguồn dinh dưỡng an toàn đến từng gia đình.
                        </p>
                    </div>
                    <div>
                        <h3 class="font-bold text-white text-sm uppercase tracking-wider mb-4">Danh Mục Mua Sắm</h3>
                        <ul class="space-y-2.5 text-xs text-gray-400">
                            <c:forEach var="c" items="${categories}" end="4">
                                <li><a href="${pageContext.request.contextPath}/products?category=${c.slug}" class="hover:text-emerald-400 transition">${c.categoryName}</a></li>
                            </c:forEach>
                        </ul>
                    </div>
                    <div>
                        <h3 class="font-bold text-white text-sm uppercase tracking-wider mb-4">Hỗ Trợ Khách Hàng</h3>
                        <ul class="space-y-2.5 text-xs text-gray-400">
                            <li><a href="#" class="hover:text-emerald-400 transition">Trung Tâm Trợ Giúp</a></li>
                            <li><a href="#" class="hover:text-emerald-400 transition">Chính Sách Đổi Trả 1-1</a></li>
                            <li><a href="#" class="hover:text-emerald-400 transition">Hướng Dẫn Mua Hàng</a></li>
                        </ul>
                    </div>
                    <div>
                        <h3 class="font-bold text-white text-sm uppercase tracking-wider mb-4">Đăng Ký Nhận Bản Tin</h3>

                        <form id="newsletterForm" class="space-y-2">
                            <input type="email" placeholder="Nhập email của bạn..." class="w-full bg-gray-900 border border-gray-800 rounded-xl px-3.5 py-2.5 text-xs text-white focus:outline-none focus:border-emerald-500" required>
                            <button type="submit" class="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs py-2.5 rounded-xl transition shadow">Đăng Ký Ngay</button>
                        </form>
                    </div>
                </div>
                <div class="pt-8 border-t border-gray-900 flex flex-col sm:flex-row justify-between items-center text-xs text-gray-500 gap-4">

                    <p>&copy; 2026 Gốc Vườn Marketplace Inc. Bảo lưu mọi quyền.</p>
                </div>
            </div>
        </footer>

        <script src="${pageContext.request.contextPath}/assets/js/home.js" defer></script>
    </body>
</html>
