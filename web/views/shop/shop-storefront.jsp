<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${not empty shop.shopName ? shop.shopName : 'Nông Trại Hữu Cơ Mộc Châu'} - FreshFruit Storefront</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-storefront.css">
</head>
<body class="min-h-screen flex flex-col antialiased">

    <jsp:include page="/views/shop/components/storefront/storefront-header.jsp" />

    <jsp:include page="/views/shop/components/storefront/storefront-banner.jsp" />

    <section id="shop-products" class="max-w-7xl mx-auto px-4 pt-12 pb-6">
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-gray-200/70 pb-5">
            <div class="flex items-center gap-2 overflow-x-auto hide-scrollbar py-1">
                <a href="${pageContext.request.contextPath}/store?id=${shop.shopId}&sort=${selectedSort}" 
                   class="px-4 py-2 rounded-full text-xs font-bold transition flex items-center gap-1.5 whitespace-nowrap shadow-xs ${empty selectedCatId ? 'bg-emerald-800 text-white' : 'bg-white border border-gray-200 text-gray-700 hover:border-emerald-600'}">
                    Tất Cả Sản Phẩm (${totalProductsCount})
                </a>
                <c:forEach var="c" items="${categories}">
                    <a href="${pageContext.request.contextPath}/store?id=${shop.shopId}&cat=${c.categoryId}&sort=${selectedSort}" 
                       class="px-4 py-2 rounded-full text-xs font-bold transition flex items-center gap-1.5 whitespace-nowrap shadow-xs ${selectedCatId eq c.categoryId ? 'bg-emerald-800 text-white' : 'bg-white border border-gray-200 text-gray-700 hover:border-emerald-600'}">
                        ${c.categoryName} (${c.productCount})
                    </a>
                </c:forEach>
            </div>

            <div class="flex items-center gap-2 flex-shrink-0 self-end md:self-auto">
                <span class="text-xs text-gray-500 font-medium">Sắp xếp:</span>
                <select onchange="location.href='${pageContext.request.contextPath}/store?id=${shop.shopId}&cat=${selectedCatId}&sort=' + this.value" 
                        class="bg-white border border-gray-200 rounded-xl px-3 py-1.5 text-xs font-bold text-gray-800 focus:outline-none focus:border-emerald-600 cursor-pointer shadow-xs">
                    <option value="featured" ${selectedSort eq 'featured' ? 'selected' : ''}>Nổi Bật Nhất</option>
                    <option value="price_asc" ${selectedSort eq 'price_asc' ? 'selected' : ''}>Giá: Thấp Đến Cao</option>
                    <option value="price_desc" ${selectedSort eq 'price_desc' ? 'selected' : ''}>Giá: Cao Đến Thấp</option>
                    <option value="newest" ${selectedSort eq 'newest' ? 'selected' : ''}>Mới Thu Hoạch</option>
                </select>
            </div>
        </div>
    </section>

    <main class="max-w-7xl mx-auto px-4 pb-14">
        <c:choose>
            <c:when test="${not empty products}">
                <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
                    <c:forEach var="p" items="${products}">
                        <div class="bg-white rounded-3xl p-4 border border-gray-100 shadow-xs hover:shadow-xl transition-all duration-300 flex flex-col justify-between group">
                            <div>
                                <div class="relative aspect-square rounded-2xl overflow-hidden bg-gray-50 mb-3.5">
                                    <a href="${pageContext.request.contextPath}/detail?id=${p.id}" class="block w-full h-full">
                                        <img src="${p.image}" alt="${p.name}" 
                                             class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500">
                                    </a>
                                    <div class="absolute top-2.5 left-2.5 flex flex-col gap-1">
                                        <c:if test="${not empty p.tag}">
                                            <span class="bg-emerald-950/80 backdrop-blur-xs text-emerald-200 text-[10px] font-bold px-2.5 py-0.5 rounded-full uppercase tracking-wider shadow-xs">
                                                ${p.tag}
                                            </span>
                                        </c:if>
                                        <c:if test="${p.discountPercent > 0}">
                                            <span class="bg-rose-600 text-white text-[10px] font-extrabold px-2 py-0.5 rounded-full shadow-xs">
                                                -${p.discountPercent}%
                                            </span>
                                        </c:if>
                                    </div>
                                    <button type="button" onclick="this.classList.toggle('text-rose-600'); this.classList.toggle('text-gray-400');"
                                            class="absolute top-2.5 right-2.5 w-8 h-8 rounded-full bg-white/90 backdrop-blur-xs hover:bg-white text-gray-400 hover:text-rose-600 flex items-center justify-center transition shadow-xs" title="Yêu thích">
                                        <i class="fa-solid fa-heart text-xs"></i>
                                    </button>
                                </div>

                                <div class="flex items-center justify-between text-[11px] text-gray-400 font-medium mb-1">
                                    <span>${p.origin}</span>
                                    <div class="flex items-center gap-1 text-amber-500 font-bold">
                                        <i class="fa-solid fa-star text-[10px]"></i>
                                        <span class="text-gray-800">${p.rating}</span>
                                        <span class="text-gray-400 font-normal">(${p.reviewsCount})</span>
                                    </div>
                                </div>

                                <h3 class="font-extrabold text-sm sm:text-base text-gray-900 group-hover:text-emerald-700 transition line-clamp-2 leading-snug mb-1">
                                    <a href="${pageContext.request.contextPath}/detail?id=${p.id}">${p.name}</a>
                                </h3>

                                <p class="text-xs text-gray-500 mb-3 font-medium">
                                    ${p.unit}
                                </p>
                            </div>

                            <div class="flex items-center justify-between pt-2 border-t border-gray-50">
                                <div>
                                    <c:if test="${p.oldPrice > p.price}">
                                        <span class="block text-[11px] text-gray-400 line-through">
                                            <fmt:formatNumber value="${p.oldPrice}" pattern="#,###" />₫
                                        </span>
                                    </c:if>
                                    <span class="text-base sm:text-lg font-black text-gray-950">
                                        <fmt:formatNumber value="${p.price}" pattern="#,###" />₫
                                    </span>
                                </div>

                                <form action="${pageContext.request.contextPath}/add-to-cart" method="GET">
                                    <input type="hidden" name="productId" value="${p.id}">
                                    <button type="submit" 
                                            class="bg-emerald-800 hover:bg-emerald-900 text-white font-extrabold text-xs px-4 py-2 rounded-xl transition shadow-xs flex items-center gap-1.5 transform active:scale-95">
                                        <i class="fa-solid fa-plus text-xs"></i> Thêm
                                    </button>
                                </form>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="text-center py-16 bg-white rounded-3xl border border-gray-100 shadow-sm">
                    <i class="fa-solid fa-box-open text-4xl text-gray-300 mb-3"></i>
                    <p class="text-gray-600 font-bold text-base">Chưa có sản phẩm nào trong danh mục này.</p>
                    <a href="${pageContext.request.contextPath}/store?id=${shop.shopId}" class="inline-block mt-3 text-xs font-bold text-emerald-700 hover:underline">
                        &larr; Xem tất cả sản phẩm của shop
                    </a>
                </div>
            </c:otherwise>
        </c:choose>
    </main>

    <section id="reviews" class="max-w-7xl mx-auto px-4 pb-20">
        <div class="flex flex-col sm:flex-row sm:items-end justify-between gap-4 mb-8">
            <div>
                <span class="text-[11px] font-black uppercase tracking-widest text-emerald-700">PHẢN HỒI XÁC THỰC</span>
                <h2 class="text-2xl sm:text-3xl font-black text-gray-950 tracking-tight">
                    Đánh Giá Khách Hàng Cho ${not empty shop.shopName ? shop.shopName : 'Nông Trại Hữu Cơ Mộc Châu'}
                </h2>
            </div>
            <div class="flex items-center gap-2 bg-white px-4 py-2 rounded-2xl border border-gray-100 shadow-xs">
                <span class="text-xl font-black text-gray-950">${shop.rating != null ? shop.rating : '4.9'}</span>
                <div class="flex text-amber-400 text-xs gap-0.5">
                    <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                </div>
                <span class="text-xs text-gray-400 font-medium">(${reviews != null ? reviews.size() : 1420} lượt đánh giá)</span>
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <c:forEach var="rev" items="${reviews}">
                <div class="bg-white rounded-3xl p-6 border border-gray-100 shadow-xs flex flex-col justify-between space-y-4">
                    <div>
                        <div class="flex items-center justify-between mb-3">
                            <div class="flex items-center gap-3">
                                <img src="${rev.customerAvatar}" alt="Customer" class="w-10 h-10 rounded-full object-cover border border-gray-200">
                                <div>
                                    <h4 class="font-extrabold text-sm text-gray-900 leading-tight">${rev.customerName}</h4>
                                    <span class="text-[11px] text-gray-400 font-medium">Đã mua hàng &bull; ${rev.timeAgo}</span>
                                </div>
                            </div>
                            <div class="flex text-amber-400 text-[11px] gap-0.5">
                                <c:forEach begin="1" end="${rev.rating}">
                                    <i class="fa-solid fa-star"></i>
                                </c:forEach>
                            </div>
                        </div>

                        <p class="text-xs sm:text-sm text-gray-600 leading-relaxed font-normal italic">
                            "${rev.comment}"
                        </p>
                    </div>

                    <div class="pt-3 border-t border-gray-50">
                        <span class="inline-flex items-center gap-1.5 text-[11px] text-emerald-800 font-bold bg-emerald-50 px-3 py-1 rounded-full">
                            <i class="fa-solid fa-check text-emerald-600"></i> Đã mua: ${rev.productName}
                        </span>
                    </div>
                </div>
            </c:forEach>
        </div>
    </section>

    <jsp:include page="/views/shop/components/storefront/storefront-footer.jsp" />

    <script src="${pageContext.request.contextPath}/assets/js/shop-storefront.js"></script>

</body>
</html>
