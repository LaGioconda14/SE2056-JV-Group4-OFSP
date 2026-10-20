<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Danh sách yêu thích - Gốc Vườn</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="${ctx}/assets/css/wishlist.css">
    </head>
    <body class="bg-gray-50 text-gray-800 font-sans antialiased">

        <jsp:include page="/views/common/header.jsp" />

        <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 min-h-[60vh]">

            <!-- Breadcrumb -->
            <nav class="flex items-center gap-2 text-xs text-gray-500 font-medium mb-4">
                <a href="${ctx}/home" class="hover:text-emerald-600 transition">Trang chủ</a>
                <i class="fa-solid fa-chevron-right text-[10px] text-gray-400"></i>
                <span class="text-gray-800 font-semibold">Danh sách yêu thích</span>
            </nav>

            <div class="flex flex-col sm:flex-row sm:items-end justify-between gap-3 mb-6">
                <div>
                    <h1 class="text-2xl sm:text-3xl font-extrabold text-gray-900 tracking-tight flex items-center gap-3">
                        <i class="fa-solid fa-heart text-rose-500"></i> Danh sách yêu thích
                    </h1>
                    <p class="text-sm text-gray-500 mt-1">
                        <span id="wishlistPageCount" class="font-bold text-gray-800"><c:out value="${wishlistCount}"/></span> sản phẩm bạn đã lưu lại
                    </p>
                </div>
                <a href="${ctx}/products" class="inline-flex items-center gap-2 text-sm font-bold text-emerald-600 hover:text-emerald-700 transition">
                    <i class="fa-solid fa-arrow-left"></i> Tiếp tục mua sắm
                </a>
            </div>

            <c:if test="${not empty wishlistError}">
                <div class="mb-6 flex items-center gap-3 bg-red-50 border border-red-200 text-red-800 px-4 py-3 rounded-2xl text-sm font-semibold">
                    <i class="fa-solid fa-circle-exclamation"></i>
                    <span><c:out value="${wishlistError}"/></span>
                </div>
            </c:if>

            <!-- Danh sách sản phẩm -->
            <div id="wishlistGrid" class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6 ${empty wishlistItems ? 'hidden' : ''}">
                <c:forEach var="p" items="${wishlistItems}">
                    <div class="bg-white rounded-3xl p-4 border border-gray-100 shadow-sm flex flex-col justify-between transition hover:shadow-lg"
                         data-wishlist-item data-product-id="${p.id}">
                        <div>
                            <a href="${ctx}/detail?id=${p.id}" class="block aspect-square rounded-2xl overflow-hidden bg-gray-100 mb-3.5">
                                <img src="<c:out value='${p.image}'/>" alt="<c:out value='${p.name}'/>"
                                     class="w-full h-full object-cover hover:scale-105 transition-transform duration-500">
                            </a>

                            <span class="text-[11px] font-bold text-emerald-700 uppercase tracking-wide"><c:out value="${p.categoryName}"/></span>

                            <h3 class="font-bold text-sm text-gray-900 leading-snug mt-1 line-clamp-2" title="<c:out value='${p.name}'/>">
                                <a href="${ctx}/detail?id=${p.id}" class="hover:text-emerald-600 transition"><c:out value="${p.name}"/></a>
                            </h3>

                            <c:if test="${not empty p.origin}">
                                <p class="text-xs text-gray-500 mt-1.5 flex items-center gap-1.5">
                                    <i class="fa-solid fa-location-dot text-[10px] text-emerald-600"></i> <c:out value="${p.origin}"/>
                                </p>
                            </c:if>
                        </div>

                        <div class="mt-4 pt-3 border-t border-gray-100">
                            <div class="flex items-center justify-between mb-3">
                                <c:choose>
                                    <c:when test="${p.price gt 0}">
                                        <span class="text-base font-black text-emerald-700">
                                            <fmt:formatNumber value="${p.price}" pattern="#,###" />đ<c:if test="${not empty p.unit}"><span class="text-xs font-semibold text-emerald-800/70">/<c:out value="${p.unit}"/></span></c:if>
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-sm font-bold text-gray-400">Chưa có giá</span>
                                    </c:otherwise>
                                </c:choose>

                                <c:choose>
                                    <c:when test="${p.defaultVariantId gt 0}">
                                        <span class="px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700 text-[10px] font-bold">Còn hàng</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="px-2 py-0.5 rounded-full bg-gray-100 text-gray-500 text-[10px] font-bold">Hết hàng</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div class="flex items-stretch gap-2">
                                <%-- Form này có action chứa /cart/add nên header.jsp tự gửi bằng AJAX, cập nhật số giỏ hàng + thông báo --%>
                                <form action="${ctx}/cart/add" method="POST" class="flex-1">
                                    <input type="hidden" name="csrfToken" value="${sessionScope.cartCsrfToken}" />
                                    <input type="hidden" name="variantId" value="${p.defaultVariantId}" />
                                    <input type="hidden" name="quantity" value="1" />
                                    <input type="hidden" name="returnUrl" value="/wishlist" />
                                    <button type="submit" ${p.defaultVariantId le 0 ? 'disabled' : ''}
                                            class="w-full inline-flex items-center justify-center gap-2 px-3 py-2.5 rounded-xl bg-emerald-600 text-white text-xs font-bold transition hover:bg-emerald-700 disabled:bg-gray-200 disabled:text-gray-400 disabled:cursor-not-allowed">
                                        <i class="fa-solid fa-cart-plus"></i> Thêm vào giỏ
                                    </button>
                                </form>

                                <button type="button" class="wishlist-remove-btn shrink-0 w-10 inline-flex items-center justify-center rounded-xl border border-gray-200 text-gray-500 transition hover:bg-rose-50 hover:text-rose-600 hover:border-rose-200 disabled:opacity-60"
                                        data-product-id="${p.id}" title="Xóa khỏi danh sách yêu thích" aria-label="Xóa khỏi danh sách yêu thích">
                                    <i class="fa-regular fa-trash-can"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- Trạng thái trống (JS sẽ hiện lên khi xóa hết sản phẩm) -->
            <div id="wishlistEmpty" class="${empty wishlistItems ? '' : 'hidden'} text-center py-16 bg-white rounded-3xl border border-gray-100 shadow-sm">
                <div class="w-20 h-20 mx-auto mb-4 rounded-full bg-rose-50 flex items-center justify-center">
                    <i class="fa-regular fa-heart text-3xl text-rose-400"></i>
                </div>
                <p class="text-gray-800 font-bold text-lg">Danh sách yêu thích đang trống</p>
                <p class="text-gray-500 text-sm mt-1">Bấm vào biểu tượng trái tim trên sản phẩm để lưu lại món bạn thích.</p>
                <a href="${ctx}/home" class="inline-flex items-center gap-2 mt-6 px-5 py-2.5 rounded-xl bg-emerald-600 text-white text-sm font-bold hover:bg-emerald-700 transition">
                    <i class="fa-solid fa-store"></i> Khám phá sản phẩm
                </a>
            </div>
        </main>

        <footer class="bg-gray-950 text-gray-400 border-t border-gray-800 mt-12">
            <div class="max-w-7xl mx-auto px-4 py-8 flex flex-col sm:flex-row justify-between items-center gap-3 text-xs">
                <span class="text-base font-extrabold text-white">Gốc <span class="text-emerald-500">Vườn</span></span>
                <p>&copy; 2026 Gốc Vườn Marketplace Inc. Bảo lưu mọi quyền.</p>
            </div>
        </footer>

        <%-- Ở trang này không cần nút nổi (đang ở trang wishlist rồi), chỉ nạp script --%>
        <jsp:include page="/views/common/wishlist-fab.jsp">
            <jsp:param name="hideButton" value="true" />
        </jsp:include>
    </body>
</html>
