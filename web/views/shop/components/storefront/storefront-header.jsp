<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<header class="sticky top-0 z-40 bg-white shadow-sm border-b border-gray-100">
    <div class="max-w-7xl mx-auto px-4 py-3 sm:py-3.5">
        <div class="flex items-center justify-between gap-4">
            <a href="${pageContext.request.contextPath}/home" class="flex items-center gap-2.5 flex-shrink-0 group">
                <div class="w-10 h-10 bg-emerald-50 rounded-full flex items-center justify-center p-1.5 border border-emerald-200 shadow-xs">
                    <svg viewBox="0 0 100 100" class="w-full h-full">
                        <circle cx="50" cy="56" r="32" fill="#16a34a"/>
                        <path d="M 28 45 Q 36 34 50 34" stroke="#ffffff" stroke-width="6" stroke-linecap="round" fill="none"/>
                        <circle cx="68" cy="46" r="5" fill="#ffffff"/>
                        <path d="M 52 26 C 58 16 68 14 74 18 C 74 24 64 32 52 26 Z" fill="#f97316"/>
                    </svg>
                </div>
                <span class="text-xl sm:text-2xl font-black tracking-tight text-gray-900">
                    Fresh<span class="text-emerald-600">Fruit</span>
                </span>
            </a>

            <div class="flex-1 max-w-2xl mx-4 hidden md:block">
                <form action="${pageContext.request.contextPath}/search" method="GET" class="flex items-center bg-gray-50 border border-gray-200 hover:border-emerald-500 focus-within:border-emerald-600 rounded-full p-1 transition shadow-inner">
                    <div class="relative pl-3 pr-2 py-1 border-r border-gray-200">
                        <select name="categoryId" class="bg-transparent text-xs font-bold text-gray-700 focus:outline-none cursor-pointer pr-4">
                            <option value="">Tất Cả Quả</option>
                            <c:forEach var="c" items="${categories}">
                                <option value="${c.categoryId}">${c.categoryName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <input type="text" name="query" placeholder="Tìm kiếm dâu tây, cam canh mật ong, mận tam hoa, organic..."
                           class="flex-1 bg-transparent px-3 py-1.5 text-xs sm:text-sm text-gray-800 focus:outline-none placeholder-gray-400">
                    <button type="submit" class="w-9 h-9 bg-emerald-600 hover:bg-emerald-700 text-white rounded-full flex items-center justify-center transition shadow-sm flex-shrink-0">
                        <i class="fa-solid fa-magnifying-glass text-xs"></i>
                    </button>
                </form>
            </div>

            <div class="flex items-center gap-3.5">
                <a href="#" class="relative p-2 text-gray-500 hover:text-emerald-700 transition" title="Danh sách yêu thích">
                    <i class="fa-regular fa-heart text-xl"></i>
                    <span class="absolute top-0 right-0 bg-red-500 text-white text-[10px] w-4 h-4 rounded-full flex items-center justify-center font-bold">0</span>
                </a>

                <a href="${pageContext.request.contextPath}/cart" class="flex items-center gap-2.5 bg-emerald-50 hover:bg-emerald-100 border border-emerald-200/80 px-3.5 py-1.5 rounded-full transition group">
                    <div class="relative">
                        <i class="fa-solid fa-basket-shopping text-emerald-800 text-lg"></i>
                        <span class="absolute -top-1.5 -right-2 bg-emerald-700 text-white text-[10px] w-4 h-4 rounded-full flex items-center justify-center font-black">
                            ${sessionScope.cartSize != null ? sessionScope.cartSize : 1}
                        </span>
                    </div>
                    <div class="hidden sm:block text-left text-xs leading-tight">
                        <span class="block text-[10px] text-gray-500 font-semibold uppercase">Giỏ hàng</span>
                        <span class="font-extrabold text-emerald-800">285.000₫</span>
                    </div>
                </a>

                <c:choose>
                    <c:when test="${empty sessionScope.account and empty sessionScope.user}">
                        <a href="${pageContext.request.contextPath}/login" class="text-xs font-bold bg-emerald-700 hover:bg-emerald-800 text-white px-4 py-2 rounded-full transition shadow-xs">
                            Đăng Nhập
                        </a>
                    </c:when>
                    <c:otherwise>
                        <c:set var="currentUser" value="${not empty sessionScope.account ? sessionScope.account : sessionScope.user}" />
                        <div class="relative group cursor-pointer">
                            <img src="${not empty currentUser.avatar ? currentUser.avatar : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop'}" 
                                 alt="Avatar" class="w-9 h-9 rounded-full object-cover border border-emerald-500 shadow-xs">
                            <div class="absolute right-0 top-full pt-2 w-52 hidden group-hover:block z-50">
                                <div class="bg-white rounded-2xl shadow-xl border border-gray-100 p-2 space-y-1 text-xs">
                                    <div class="px-3 py-2 border-b border-gray-100">
                                        <p class="font-bold text-gray-900 truncate">${currentUser.fullName}</p>
                                        <p class="text-[11px] text-gray-400 truncate">${currentUser.email}</p>
                                    </div>
                                    <c:if test="${currentUser.role eq 'SHOP_OWNER'}">
                                        <a href="${pageContext.request.contextPath}/shop/products" class="flex items-center gap-2 px-3 py-2 font-bold text-emerald-700 bg-emerald-50 rounded-xl hover:bg-emerald-100 transition">
                                            <i class="fa-solid fa-store"></i> Kênh Quản Lý Shop
                                        </a>
                                    </c:if>
                                    <a href="${pageContext.request.contextPath}/profile" class="flex items-center gap-2 px-3 py-2 text-gray-700 hover:bg-gray-100 rounded-xl transition">
                                        <i class="fa-solid fa-user text-gray-400"></i> Tài khoản của tôi
                                    </a>
                                    <a href="${pageContext.request.contextPath}/logout" class="flex items-center gap-2 px-3 py-2 text-red-600 hover:bg-red-50 rounded-xl font-semibold transition">
                                        <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                                    </a>
                                </div>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</header>

<nav class="bg-white border-b border-gray-100 hidden md:block">
    <div class="max-w-7xl mx-auto px-4 flex items-center justify-between text-xs font-semibold text-gray-600">
        <div class="flex items-center space-x-6 py-2.5">
            <a href="${pageContext.request.contextPath}/home" class="hover:text-emerald-700 transition">Trang Chủ</a>
            <a href="${pageContext.request.contextPath}/store" class="text-emerald-700 font-bold flex items-center gap-1.5 transition">
                <span class="w-1.5 h-1.5 rounded-full bg-emerald-600"></span> Gian Hàng Shop
            </a>
            <a href="#shop-products" class="hover:text-emerald-700 transition">Danh Mục Nông Sản</a>
            <a href="#reviews" class="hover:text-emerald-700 transition">Đánh Giá Khách Hàng</a>
            <a href="#footer" class="hover:text-emerald-700 transition">Liên Hệ</a>
        </div>
        <div>
            <span class="inline-flex items-center gap-1.5 bg-amber-50 text-amber-800 border border-amber-200/80 px-3 py-1 rounded-full text-[11px] font-bold">
                <i class="fa-solid fa-bolt text-amber-500"></i> Ưu Đãi Mùa Vụ - Giảm Đến 25%
            </span>
        </div>
    </div>
</nav>

