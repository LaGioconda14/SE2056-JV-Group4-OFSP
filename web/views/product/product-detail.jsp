<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>${not empty product ? product.name : 'Chi Tiết Sản Phẩm'} - FreshFruit</title>
        <!-- Tailwind CSS -->
        <script src="https://cdn.tailwindcss.com"></script>
        <!-- FontAwesome Icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <!-- Google Fonts Inter -->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        
        <!-- CSS Tùy Chỉnh Đồng Bộ Giao Diện Home -->
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
        </style>
    </head>
    <body class="bg-gray-50 text-gray-800 font-sans antialiased selection:bg-emerald-500 selection:text-white">

        <c:set var="currentUser" value="${not empty sessionScope.account ? sessionScope.account : sessionScope.user}" />

        <!-- Header Đồng Bộ Cart -->
        <jsp:include page="/views/common/header.jsp" />

        <!-- Breadcrumb / Thước đo điều hướng -->
        <div class="max-w-7xl mx-auto px-4 pt-6 pb-2">
            <nav class="flex text-xs text-gray-500 gap-2 items-center">
                <a href="${pageContext.request.contextPath}/home" class="hover:text-emerald-600 transition">Trang chủ</a>
                <i class="fa-solid fa-chevron-right text-[10px]"></i>
                <a href="${pageContext.request.contextPath}/products" class="hover:text-emerald-600 transition">Sản phẩm</a>
                <i class="fa-solid fa-chevron-right text-[10px]"></i>
                <span class="text-gray-800 font-semibold truncate max-w-xs">${product.name}</span>
            </nav>
        </div>

        <!-- Khung Nội Dung Chi Tiết Sản Phẩm -->
        <main class="max-w-7xl mx-auto px-4 py-6">
            <c:if test="${not empty successMessage}">
                <div id="product-toast" class="mb-5 flex items-center justify-between gap-4 rounded-2xl border border-emerald-200 bg-emerald-50 px-5 py-4 text-emerald-800 shadow-sm" role="status">
                    <div class="flex items-center gap-3"><i class="fa-solid fa-circle-check text-lg"></i><strong><c:out value="${successMessage}"/></strong></div>
                    <button type="button" aria-label="Đóng thông báo" onclick="this.parentElement.remove()" class="text-emerald-700 hover:text-emerald-950"><i class="fa-solid fa-xmark"></i></button>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div id="product-toast" class="mb-5 flex items-center justify-between gap-4 rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-red-700 shadow-sm" role="alert">
                    <div class="flex items-center gap-3"><i class="fa-solid fa-circle-exclamation text-lg"></i><strong><c:out value="${errorMessage}"/></strong></div>
                    <button type="button" aria-label="Đóng thông báo" onclick="this.parentElement.remove()" class="text-red-600 hover:text-red-900"><i class="fa-solid fa-xmark"></i></button>
                </div>
            </c:if>
            <c:choose>
                <c:when test="${not empty product}">
                    <div class="bg-white rounded-3xl p-6 sm:p-10 border border-gray-100 shadow-sm grid grid-cols-1 md:grid-cols-2 gap-8 md:gap-12">
                        
                        <!-- Cột Trái: Ảnh Sản Phẩm & Thư Viện Ảnh -->
                        <div class="space-y-4">
                            <div class="w-full h-80 sm:h-96 rounded-2xl overflow-hidden bg-gray-50 border border-gray-100 shadow-inner relative group">
                                <img src="${product.image}" alt="${product.name}" class="w-full h-full object-cover group-hover:scale-105 transition duration-500">
                                <c:if test="${not empty product.certification}">
                                    <span class="absolute top-4 left-4 bg-emerald-600 text-white text-xs font-extrabold px-3 py-1 rounded-full shadow-md">
                                        <i class="fa-solid fa-certificate"></i> ${product.certification}
                                    </span>
                                </c:if>
                            </div>

                            <!-- Thư viện ảnh nhỏ (nếu có) -->
                            <c:if test="${not empty product.images}">
                                <div class="flex items-center gap-3 overflow-x-auto pb-2">
                                    <c:forEach var="imgUrl" items="${product.images}">
                                        <div class="w-16 h-16 rounded-xl overflow-hidden border-2 border-emerald-500 cursor-pointer flex-shrink-0">
                                            <img src="${imgUrl}" alt="Thumbnail" class="w-full h-full object-cover">
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>

                        <!-- Cột Phải: Thông Tin & Đặt Hàng -->
                        <div class="flex flex-col justify-between">
                            <div>
                                <div class="flex items-center gap-2 mb-2">
                                    <span class="bg-emerald-50 text-emerald-700 text-xs font-extrabold px-3 py-1 rounded-full uppercase tracking-wider">
                                        ${not empty product.categoryName ? product.categoryName : 'Trái Cây Tươi'}
                                    </span>
                                    <c:if test="${not empty product.tag}">
                                        <span class="bg-amber-50 text-amber-700 text-xs font-bold px-2.5 py-1 rounded-full">
                                            ${product.tag}
                                        </span>
                                    </c:if>
                                </div>

                                <h1 class="text-2xl sm:text-3xl font-extrabold text-gray-900 leading-tight mb-3">
                                    ${product.name}
                                </h1>

                                <c:if test="${not empty product.origin}">
                                    <p class="text-xs sm:text-sm text-gray-500 mb-4 flex items-center gap-1.5">
                                        <i class="fa-solid fa-location-dot text-emerald-600"></i> Xuất xứ: 
                                        <span class="font-bold text-gray-700">${product.origin}</span>
                                    </p>
                                </c:if>

                                <!-- Khung Giá & Khuyến Mãi -->
                                <div class="bg-emerald-50/70 p-5 rounded-2xl mb-6 border border-emerald-100 flex items-baseline gap-4">
                                    <span id="detail-price" class="text-3xl sm:text-4xl font-extrabold text-emerald-600">
                                        <fmt:formatNumber value="${product.price}" pattern="#,###" />đ
                                    </span>
                                    <c:if test="${product.oldPrice gt product.price}">
                                        <span class="text-base text-gray-400 line-through">
                                            <fmt:formatNumber value="${product.oldPrice}" pattern="#,###" />đ
                                        </span>
                                    </c:if>
                                    <span id="detail-unit" class="text-sm font-bold text-emerald-800/80">
                                        /${not empty product.unit ? product.unit : 'kg'}
                                    </span>
                                </div>

                                <c:if test="${not empty product.variants}">
                                    <div class="mb-6">
                                        <div class="flex items-center justify-between gap-3 mb-3">
                                            <h3 class="text-xs font-bold uppercase tracking-wider text-gray-500">Chọn phân loại</h3>
                                            <span id="detail-stock" class="text-xs font-semibold text-emerald-700">Còn ${product.variants[0].stockQuantity} sản phẩm</span>
                                        </div>
                                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3" id="variant-options">
                                            <c:forEach var="variant" items="${product.variants}" varStatus="variantStatus">
                                                <label class="variant-option cursor-pointer rounded-2xl border-2 p-4 transition ${variantStatus.first ? 'border-emerald-500 bg-emerald-50' : 'border-gray-200 hover:border-emerald-300'} ${variant.stockQuantity le 0 ? 'opacity-50 cursor-not-allowed' : ''}">
                                                    <input type="radio" name="displayVariant" value="${variant.variantId}" class="sr-only"
                                                           data-price="${variant.price}" data-unit="${variant.unit}" data-stock="${variant.stockQuantity}"
                                                           <c:if test="${variantStatus.first}">checked</c:if> <c:if test="${variant.stockQuantity le 0}">disabled</c:if>>
                                                    <span class="block font-bold text-gray-900"><c:out value="${variant.variantName}"/></span>
                                                    <span class="mt-1 flex items-center justify-between gap-2 text-xs text-gray-500">
                                                        <span><fmt:formatNumber value="${variant.price}" pattern="#,###"/>đ / <c:out value="${variant.unit}"/></span>
                                                        <span>Kho: <c:out value="${variant.stockQuantity}"/></span>
                                                    </span>
                                                </label>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </c:if>

                                <!-- Mô Tả Sản Phẩm -->
                                <div class="space-y-2 mb-6">
                                    <h3 class="text-xs font-bold uppercase tracking-wider text-gray-400">Đặc điểm nổi bật</h3>
                                    <p class="text-sm text-gray-600 leading-relaxed">
                                        ${not empty product.description ? product.description : 'Sản phẩm được tuyển chọn nghiêm ngặt từ nông trại hữu cơ, thu hoạch chín tự nhiên và bảo quản khép kín giữ nguyên hàm lượng dinh dưỡng và vitamin tươi ngon nhất.'}
                                    </p>
                                </div>

                                <c:if test="${not empty product.storageTemp}">
                                    <div class="p-3 bg-gray-50 rounded-xl border border-gray-100 text-xs text-gray-600 mb-6 flex items-center gap-2">
                                        <i class="fa-solid fa-snowflake text-sky-500"></i>
                                        <span>Bảo quản gợi ý: <strong>${product.storageTemp}</strong></span>
                                    </div>
                                </c:if>
                            </div>

                            <!-- Nút Thêm Vào Giỏ Hàng -->
                            <form action="${pageContext.request.contextPath}/cart/add" method="POST" class="pt-4 border-t border-gray-100">
                                <input type="hidden" name="csrfToken" value="${sessionScope.cartCsrfToken}" />
                                <input type="hidden" name="returnUrl" value="/detail?id=${product.id}" />
                                <input type="hidden" id="selected-variant-id" name="variantId" value="${not empty product.variants ? product.variants[0].variantId : 0}" />
                                <input type="hidden" name="quantity" value="1" />
                                <div class="flex items-center gap-4">
                                    <button type="submit" ${empty product.variants ? 'disabled' : ''} class="flex-1 bg-emerald-600 hover:bg-emerald-700 disabled:bg-gray-300 disabled:cursor-not-allowed text-white font-extrabold py-4 px-6 rounded-2xl transition shadow-lg shadow-emerald-600/25 flex items-center justify-center gap-3 text-base">
                                        <i class="fa-solid fa-cart-plus text-lg"></i> Thêm Vào Giỏ Hàng
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="col-span-full text-center py-16 bg-white rounded-3xl border border-gray-100 shadow-sm">
                        <i class="fa-solid fa-box-open text-5xl text-gray-300 mb-4"></i>
                        <p class="text-gray-500 font-medium text-lg">Không tìm thấy sản phẩm yêu cầu.</p>
                        <a href="${pageContext.request.contextPath}/home" class="inline-block mt-4 px-6 py-2.5 bg-emerald-600 text-white rounded-xl font-bold text-sm hover:bg-emerald-700 transition">Quay về trang chủ</a>
                    </div>
                </c:otherwise>
            </c:choose>
        </main>

        <!-- Footer Đồng Bộ Home -->
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
                            <span class="text-xl font-extrabold text-white">Fresh<span class="text-emerald-500">Fruit</span></span>
                        </div>
                        <p class="text-xs sm:text-sm text-gray-400 mb-6 leading-relaxed max-w-sm">
                            Hệ thống phân phối hoa quả tươi sạch hàng đầu Việt Nam. Mang thiên nhiên thuần khiết và nguồn dinh dưỡng an toàn đến từng gia đình.
                        </p>
                    </div>
                    <div>
                        <h3 class="font-bold text-white text-sm uppercase tracking-wider mb-4">Danh Mục Mua Sắm</h3>
                        <ul class="space-y-2.5 text-xs text-gray-400">
                            <li><a href="${pageContext.request.contextPath}/products" class="hover:text-emerald-400 transition">Trái Cây Nhập Khẩu</a></li>
                            <li><a href="${pageContext.request.contextPath}/products" class="hover:text-emerald-400 transition">Trái Cây Việt Nam</a></li>
                            <li><a href="${pageContext.request.contextPath}/products" class="hover:text-emerald-400 transition">Hộp Quà Biếu Tặng</a></li>
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
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const formatter = new Intl.NumberFormat('vi-VN');
                const radios = document.querySelectorAll('input[name="displayVariant"]');
                const selectedVariant = document.getElementById('selected-variant-id');
                const price = document.getElementById('detail-price');
                const unit = document.getElementById('detail-unit');
                const stock = document.getElementById('detail-stock');

                function selectVariant(radio) {
                    if (!radio || radio.disabled) return;
                    if (selectedVariant) selectedVariant.value = radio.value;
                    if (price) price.textContent = formatter.format(Number(radio.dataset.price || 0)) + 'đ';
                    if (unit) unit.textContent = '/' + (radio.dataset.unit || 'sản phẩm');
                    if (stock) stock.textContent = 'Còn ' + radio.dataset.stock + ' sản phẩm';
                    document.querySelectorAll('.variant-option').forEach(function (option) {
                        option.classList.remove('border-emerald-500', 'bg-emerald-50');
                        option.classList.add('border-gray-200');
                    });
                    const option = radio.closest('.variant-option');
                    if (option) {
                        option.classList.remove('border-gray-200');
                        option.classList.add('border-emerald-500', 'bg-emerald-50');
                    }
                }

                radios.forEach(function (radio) {
                    radio.addEventListener('change', function () { selectVariant(radio); });
                });
                selectVariant(document.querySelector('input[name="displayVariant"]:checked'));

                const toast = document.getElementById('product-toast');
                if (toast) window.setTimeout(function () { toast.remove(); }, 4500);
            });
        </script>
    </body>
</html>
