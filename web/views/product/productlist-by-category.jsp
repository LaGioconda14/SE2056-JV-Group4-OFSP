<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Danh Mục Nông Sản - FreshFruit</title>
        <!-- Tailwind CSS -->
        <script src="https://cdn.tailwindcss.com"></script>
        <!-- FontAwesome Icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <!-- Google Fonts Inter -->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        
        <!-- CSS Tùy Chỉnh Đồng Bộ Giao Diện Trang Home -->
        <style>
            body { font-family: 'Inter', sans-serif; }
            .home-search-input {
                width: 100%;
                padding: 0.6rem 2.8rem 0.6rem 1rem;
                background-color: #f3f4f6;
                border: 1px solid #e5e7eb;
                border-radius: 0.75rem;
                font-size: 0.875rem;
                outline: none;
                transition: all 0.2s;
            }
            .home-search-input:focus {
                background-color: #ffffff;
                border-color: #10b981;
                box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.15);
            }
            .home-search-btn {
                position: absolute;
                right: 0.5rem;
                top: 50%;
                transform: translateY(-50%);
                width: 2rem;
                height: 2rem;
                background-color: #10b981;
                color: white;
                border-radius: 0.5rem;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            .home-nav-item {
                padding: 0.75rem 1rem;
                display: inline-flex;
                align-items: center;
                gap: 0.5rem;
                color: #e5e7eb;
                transition: color 0.2s;
            }
            .home-nav-item:hover, .home-nav-item.active {
                color: #ffffff;
                font-weight: 600;
            }
            .product-card {
                background: white;
                border-radius: 1.25rem;
                border: 1px solid #f3f4f6;
                padding: 1rem;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                height: 100%;
                transition: all 0.3s ease;
            }
            .product-card:hover {
                transform: translateY(-4px);
                box-shadow: 0 12px 24px -8px rgba(0, 0, 0, 0.08);
                border-color: #a7f3d0;
            }
            .product-card > div:first-child {
                flex: 1;
                display: flex;
                flex-direction: column;
            }
            .product-thumb {
                position: relative;
                width: 100%;
                height: 180px;
                border-radius: 0.85rem;
                overflow: hidden;
                margin-bottom: 0.75rem;
                background-color: #f9fafb;
                flex-shrink: 0;
            }
            .product-thumb img {
                width: 100%;
                height: 100%;
                object-fit: cover;
                transition: transform 0.5s ease;
            }
            .product-card:hover .product-thumb img { transform: scale(1.08); }
            .product-name {
                font-weight: 700;
                font-size: 0.95rem;
                color: #111827;
                line-height: 1.4;
                margin-bottom: 0.35rem;
                display: -webkit-box;
                -webkit-line-clamp: 2;
                -webkit-box-orient: vertical;
                overflow: hidden;
                text-overflow: ellipsis;
                height: 2.8em;
            }
            .product-card-footer { 
                display: flex; 
                align-items: center; 
                justify-content: space-between; 
                padding-top: 0.75rem; 
                border-top: 1px solid #f3f4f6; 
                margin-top: auto;
            }
            .product-price { font-size: 1.1rem; font-weight: 800; color: #059669; }
            .product-old-price { font-size: 0.75rem; color: #9ca3af; text-decoration: line-through; margin-left: 0.35rem; }
            .btn-add-cart {
                width: 2.25rem;
                height: 2.25rem;
                background-color: #ecfdf5;
                color: #059669;
                border-radius: 0.65rem;
                display: flex;
                align-items: center;
                justify-content: center;
                transition: all 0.2s;
                flex-shrink: 0;
            }
            .btn-add-cart:hover { background-color: #059669; color: white; }
        </style>
    </head>
    <body class="bg-gray-50 text-gray-800 font-sans antialiased selection:bg-emerald-500 selection:text-white">

        <c:set var="currentUser" value="${not empty sessionScope.account ? sessionScope.account : sessionScope.user}" />

        <!-- Header Đồng Bộ Cart -->
        <jsp:include page="/views/common/header.jsp" />

        <!-- Main Content Layout (Sidebar Danh Mục + Grid Sản Phẩm) -->
        <main class="max-w-7xl mx-auto px-4 py-8">
            <div class="flex flex-col md:flex-row gap-8">
                
                <!-- Sidebar Danh Mục (Cột trái) -->
                <aside class="w-full md:w-64 flex-shrink-0">
                    <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm sticky top-24">
                        <h3 class="font-extrabold text-gray-900 text-base mb-4 flex items-center gap-2 pb-3 border-b border-gray-100">
                            <i class="fa-solid fa-list text-emerald-600"></i> Danh Mục Nông Sản
                        </h3>
                        <ul class="space-y-1.5 text-sm font-medium">
                            <li>
                                <a href="${pageContext.request.contextPath}/products" 
                                   class="flex items-center justify-between px-3 py-2 rounded-xl transition ${empty selectedCategory ? 'bg-emerald-50 text-emerald-700 font-bold' : 'text-gray-600 hover:bg-gray-50 hover:text-emerald-600'}">
                                    <span><i class="fa-solid fa-border-all mr-2 text-xs"></i> Tất cả sản phẩm</span>
                                </a>
                            </li>
                            <c:forEach var="cat" items="${categories}">
                                <li>
                                    <a href="${pageContext.request.contextPath}/products?category=${cat.slug}" 
                                       class="flex items-center justify-between px-3 py-2 rounded-xl transition ${selectedCategory eq cat.slug ? 'bg-emerald-50 text-emerald-700 font-bold' : 'text-gray-600 hover:bg-gray-50 hover:text-emerald-600'}">
                                        <span class="truncate">${cat.categoryName}</span>
                                        <i class="fa-solid fa-chevron-right text-[10px] text-gray-400"></i>
                                    </a>
                                </li>
                            </c:forEach>
                        </ul>
                    </div>
                </aside>

                <!-- Lưới Sản Phẩm (Cột phải) -->
                <div class="flex-1">
                    <div class="bg-emerald-900 text-white rounded-3xl p-6 sm:p-8 mb-8 flex items-center justify-between shadow-md relative overflow-hidden">
                        <div class="relative z-10">
                            <h1 class="text-xl sm:text-2xl font-extrabold mb-1">
                                <c:choose>
                                    <c:when test="${not empty selectedCategory}">Danh Mục Lọc</c:when>
                                    <c:otherwise>Tất Cả Sản Phẩm Tươi Sạch</c:otherwise>
                                </c:choose>
                            </h1>
                            <p class="text-xs sm:text-sm text-emerald-200">Cam kết 100% organic, chuẩn sạch VietGAP & GlobalGAP.</p>
                        </div>
                        <div class="absolute right-4 bottom-0 opacity-10 text-9xl pointer-events-none">
                            <i class="fa-solid fa-seedling"></i>
                        </div>
                    </div>

                    <!-- Hiển thị danh sách sản phẩm -->
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                        <c:choose>
                            <c:when test="${not empty listProduct}">
                                <c:forEach var="p" items="${listProduct}">
                                    <div class="product-card group">
                                        <div>
                                            <a href="${pageContext.request.contextPath}/detail?id=${p.id}" class="product-thumb">
                                                <img src="${p.image}" alt="${p.name}">
                                            </a>
                                            <div class="text-[0.7rem] font-bold text-emerald-600 uppercase mb-1">${p.categoryName}</div>
                                            <h3 class="product-name" title="${p.name}">
                                                <a href="${pageContext.request.contextPath}/detail?id=${p.id}">${p.name}</a>
                                            </h3>
                                            <c:if test="${not empty p.origin}">
                                                <p class="text-xs text-gray-500 mb-2"><i class="fa-solid fa-location-dot text-emerald-600"></i> ${p.origin}</p>
                                            </c:if>
                                        </div>

                                        <div class="product-card-footer">
                                            <div>
                                                <span class="product-price"><fmt:formatNumber value="${p.price}" pattern="#,###" />đ</span>
                                                <c:if test="${not empty p.unit}"><span class="text-xs font-semibold text-gray-500">/${p.unit}</span></c:if>
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
                                <div class="col-span-full text-center py-16 bg-white rounded-3xl border border-gray-100 shadow-sm">
                                    <i class="fa-solid fa-box-open text-5xl text-gray-300 mb-4"></i>
                                    <p class="text-gray-600 font-semibold text-base">Chưa có sản phẩm nào trong danh mục này.</p>
                                    <a href="${pageContext.request.contextPath}/home" class="inline-block mt-4 px-5 py-2.5 bg-emerald-600 text-white text-sm font-bold rounded-xl hover:bg-emerald-700 transition">Quay về trang chủ</a>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

            </div>
        </main>

        <!-- Footer đầy đủ chi tiết -->
        <footer class="bg-gray-950 text-gray-300 pt-16 pb-8 border-t border-gray-800 mt-16">
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
                            <span class="text-xl font-extrabold text-white">Fresh<span class="text-emerald-500">Fruit</span></span>
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
                        <form onsubmit="event.preventDefault(); alert('Đăng ký nhận bản tin thành công!');" class="space-y-2">
                            <input type="email" placeholder="Nhập email của bạn..." class="w-full bg-gray-900 border border-gray-800 rounded-xl px-3.5 py-2.5 text-xs text-white focus:outline-none focus:border-emerald-500">
                            <button type="submit" class="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs py-2.5 rounded-xl transition shadow">Đăng Ký Ngay</button>
                        </form>
                    </div>
                </div>
                <div class="pt-8 border-t border-gray-900 flex flex-col sm:flex-row justify-between items-center text-xs text-gray-500 gap-4">
                    <p>&copy; 2026 FreshFruit Marketplace Inc. Bảo lưu mọi quyền.</p>
                </div>
            </div>
        </footer>
    </body>
</html>
