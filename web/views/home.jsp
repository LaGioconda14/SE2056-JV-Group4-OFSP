<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
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
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/wishlist.css">
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
                        <a href="${pageContext.request.contextPath}/products" class="hero-btn-secondary">
                            Khám Phá Cửa Hàng
                        </a>
                    </div>
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

                            <%-- Trạng thái yêu thích của sản phẩm này với người dùng đang đăng nhập --%>
                            <c:set var="wished" value="${not empty wishlistIds and wishlistIds.contains(p.id)}" />

                            <div class="product-card group">
                                <div class="product-card-media">
                                    <button type="button" class="wishlist-btn ${wished ? 'active' : ''}" data-product-id="${p.id}"
                                            aria-pressed="${wished}" title="${wished ? 'Bỏ khỏi yêu thích' : 'Thêm vào yêu thích'}"
                                            aria-label="Yêu thích sản phẩm ${p.name}">
                                        <i class="${wished ? 'fa-solid' : 'fa-regular'} fa-heart"></i>
                                    </button>

                                    <a href="${pageContext.request.contextPath}/detail?id=${p.id}" class="product-thumb">
                                        <img src="${p.image}" alt="${p.name}">
                                    </a>
                                    
                                    <div class="product-meta">
                                        <span class="product-cat-name">${p.categoryName}</span>
                                        <c:if test="${p.onPromotion}">
                                            <span class="inline-flex items-center gap-1 rounded-full bg-rose-500 px-2 py-0.5 text-[10px] font-bold text-white shadow-sm" title="<c:out value='${p.promotionName}'/>"><i class="fa-solid fa-bolt text-[9px]"></i><c:out value="${p.promotionLabel}"/></span>
                                        </c:if>

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

        <!-- Footer Chuẩn Đồng Bộ Website Gốc Vườn -->
        <jsp:include page="/views/common/site-footer.jsp" />

        <script src="${pageContext.request.contextPath}/assets/js/home.js" defer></script>
        <%-- Nút trái tim nổi góc dưới bên phải: bấm vào để mở trang danh sách yêu thích --%>
        <jsp:include page="/views/common/wishlist-fab.jsp" />
    </body>
</html>
