<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<header class="bg-white border-b border-slate-200 sticky top-0 z-20 px-6 py-2.5 flex items-center justify-between shadow-2xs">
    <div class="flex items-center gap-3">
        <c:choose>
            <c:when test="${not empty param.searchAction}">
                <div class="relative w-72 md:w-80">
                    <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs"></i>
                    <form action="${param.searchAction}" method="GET">
                        <input type="text" name="keyword" value="${param.keyword}" placeholder="${not empty param.searchPlaceholder ? param.searchPlaceholder : 'Tìm kiếm...'}" class="w-full pl-9 pr-4 py-1.5 bg-slate-50 border border-slate-200 rounded-xl text-xs focus:outline-none focus:border-emerald-500 focus:bg-white transition-all">
                    </form>
                </div>
            </c:when>
            <c:otherwise>
                <div class="flex items-center gap-2 px-3 py-1.5 rounded-xl border border-slate-200 bg-white text-xs font-semibold text-slate-800 shadow-2xs">
                    <i class="fa-solid fa-seedling text-emerald-600"></i>
                    <span><c:out value="${not empty sessionScope.shopName ? sessionScope.shopName : (not empty sessionScope.shop.shopName ? sessionScope.shop.shopName : (not empty subOrder.shopName ? subOrder.shopName : 'Gian hàng Gốc Vườn'))}"/></span>
                    <i class="fa-solid fa-chevron-down text-[10px] text-slate-400 ml-1"></i>
                </div>
            </c:otherwise>
        </c:choose>
        <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200/60">
            <span class="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
            Đang hoạt động
        </span>
    </div>

    <div class="flex items-center gap-3">
        <button type="button" class="w-8 h-8 rounded-full border border-slate-200 flex items-center justify-center text-slate-600 hover:bg-slate-50 transition" title="Thông báo">
            <i class="fa-regular fa-bell text-xs"></i>
        </button>
        <button type="button" class="w-8 h-8 rounded-full border border-slate-200 flex items-center justify-center text-slate-600 hover:bg-slate-50 transition" title="Tin nhắn">
            <i class="fa-regular fa-comment text-xs"></i>
        </button>

        <div class="relative pl-3 border-l border-slate-200 group" id="shopUserDropdownContainer">
            <button type="button" 
                    id="btnShopUserMenu" 
                    onclick="toggleShopUserDropdown(event)"
                    class="flex items-center gap-2.5 p-1 -mr-1 rounded-xl hover:bg-slate-50 transition-all focus:outline-none cursor-pointer">
                <c:choose>
                    <c:when test="${not empty sessionScope.user.avatarUrl}">
                        <img src="${sessionScope.user.avatarUrl}" alt="Avatar" class="w-8 h-8 rounded-full object-cover border border-emerald-500">
                    </c:when>
                    <c:when test="${not empty sessionScope.userAvatar}">
                        <img src="${sessionScope.userAvatar}" alt="Avatar" class="w-8 h-8 rounded-full object-cover border border-emerald-500">
                    </c:when>
                    <c:otherwise>
                        <div class="w-8 h-8 rounded-full bg-emerald-700 text-white flex items-center justify-center font-bold text-xs border border-emerald-600/30">
                            <i class="fa-solid fa-user text-[11px]"></i>
                        </div>
                    </c:otherwise>
                </c:choose>
                <div class="hidden sm:block text-left text-xs">
                    <div class="font-bold text-slate-900 leading-tight">
                        <c:out value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : (not empty sessionScope.userfullname ? sessionScope.userfullname : 'Chủ Shop')}"/>
                    </div>
                    <div class="text-[10px] text-slate-400">
                        <c:out value="${not empty sessionScope.email ? sessionScope.email : (not empty sessionScope.user.email ? sessionScope.user.email : '')}"/>
                    </div>
                </div>
                <i class="fa-solid fa-chevron-down text-[10px] text-slate-400 transition-transform duration-200 group-hover:rotate-180" id="shopUserDropdownArrow"></i>
            </button>

            <div id="shopUserDropdownMenu" 
                 class="hidden group-hover:block absolute right-0 top-full mt-1.5 w-64 bg-white rounded-2xl shadow-[0_10px_35px_rgba(0,0,0,0.12)] border border-slate-100 py-2 z-50 animate-in fade-in zoom-in-95 duration-150">
                <div class="px-4 py-3 border-b border-slate-100 bg-slate-50/50 rounded-t-2xl">
                    <p class="text-xs font-black text-slate-900 truncate">
                        <c:out value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : (not empty sessionScope.userfullname ? sessionScope.userfullname : 'Chủ Shop')}"/>
                    </p>
                    <p class="text-[11px] text-slate-400 truncate mb-1.5">
                        <c:out value="${not empty sessionScope.email ? sessionScope.email : sessionScope.user.email}"/>
                    </p>
                    <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-md bg-emerald-50 text-emerald-700 text-[10px] font-bold border border-emerald-200/60 truncate max-w-full">
                        <i class="fa-solid fa-store text-[9px]"></i>
                        <span class="truncate"><c:out value="${not empty sessionScope.shopName ? sessionScope.shopName : (not empty sessionScope.shop.shopName ? sessionScope.shop.shopName : 'Kênh Người Bán')}"/></span>
                    </span>
                </div>

                <div class="py-1">
                    <a href="${pageContext.request.contextPath}/profile" 
                       class="flex items-center gap-3 px-4 py-2.5 text-xs text-slate-700 hover:bg-emerald-50 hover:text-emerald-700 font-semibold transition-colors">
                        <i class="fa-regular fa-id-badge text-sm w-4 text-center text-slate-400"></i>
                        <span>Hồ sơ cá nhân</span>
                    </a>

                    <a href="${pageContext.request.contextPath}/store?id=${sessionScope.shopId != null ? sessionScope.shopId : (sessionScope.shop != null ? sessionScope.shop.shopId : 1)}" 
                       target="_blank"
                       class="flex items-center gap-3 px-4 py-2.5 text-xs text-slate-700 hover:bg-emerald-50 hover:text-emerald-700 font-semibold transition-colors">
                        <i class="fa-solid fa-store text-sm w-4 text-center text-emerald-600"></i>
                        <span>Xem gian hàng (Store)</span>
                        <i class="fa-solid fa-arrow-up-right-from-square text-[10px] text-slate-300 ml-auto"></i>
                    </a>

                    <a href="${pageContext.request.contextPath}/shop/settings" 
                       class="flex items-center gap-3 px-4 py-2.5 text-xs text-slate-700 hover:bg-emerald-50 hover:text-emerald-700 font-semibold transition-colors">
                        <i class="fa-solid fa-sliders text-sm w-4 text-center text-slate-400"></i>
                        <span>Cài đặt Shop</span>
                    </a>

                    <a href="${pageContext.request.contextPath}/change-password" 
                       class="flex items-center gap-3 px-4 py-2.5 text-xs text-slate-700 hover:bg-emerald-50 hover:text-emerald-700 font-semibold transition-colors">
                        <i class="fa-solid fa-key text-sm w-4 text-center text-slate-400"></i>
                        <span>Đổi mật khẩu</span>
                    </a>

                    <a href="${pageContext.request.contextPath}/home" 
                       class="flex items-center gap-3 px-4 py-2.5 text-xs text-slate-700 hover:bg-emerald-50 hover:text-emerald-700 font-semibold transition-colors">
                        <i class="fa-solid fa-house text-sm w-4 text-center text-slate-400"></i>
                        <span>Về trang chủ mua sắm</span>
                    </a>
                </div>

                <div class="border-t border-slate-100 pt-1 mt-1">
                    <a href="${pageContext.request.contextPath}/logout" 
                       class="flex items-center gap-3 px-4 py-2.5 text-xs text-rose-600 hover:bg-rose-50 hover:text-rose-700 font-bold transition-colors">
                        <i class="fa-solid fa-arrow-right-from-bracket text-sm w-4 text-center"></i>
                        <span>Đăng xuất</span>
                    </a>
                </div>
            </div>
        </div>
    </div>
</header>

<script>
    function toggleShopUserDropdown(event) {
        if (event) event.stopPropagation();
        const menu = document.getElementById('shopUserDropdownMenu');
        const arrow = document.getElementById('shopUserDropdownArrow');
        if (!menu) return;
        menu.classList.toggle('hidden');
        if (arrow) arrow.classList.toggle('rotate-180');
    }

    document.addEventListener('click', function(e) {
        const container = document.getElementById('shopUserDropdownContainer');
        const menu = document.getElementById('shopUserDropdownMenu');
        const arrow = document.getElementById('shopUserDropdownArrow');
        if (container && menu && !container.contains(e.target)) {
            menu.classList.add('hidden');
            if (arrow) arrow.classList.remove('rotate-180');
        }
    });
</script>

