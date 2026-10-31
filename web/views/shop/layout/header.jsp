<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="hdSearchAction" value="${not empty param.searchAction ? param.searchAction : '/shop/products'}" />

<header class="shop-header">
    <div class="flex items-center gap-3">

        <button type="button" class="shop-sidebar-toggle" id="shopSidebarToggle" aria-label="Mở menu">
            <i class="fa-solid fa-bars text-sm"></i>
        </button>

        <div class="header-search-container">
            <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs"></i>
            <form action="${ctx}${hdSearchAction}" method="GET">
                <input type="text" id="shopHeaderSearch" name="keyword" value="<c:out value='${param.keyword}'/>"
                       placeholder="Tìm theo SKU, tên trái cây, hoặc mã đơn con (Ctrl + K)..." class="header-search-input">
            </form>
        </div>
    </div>

    <div class="flex items-center gap-4">

        <a href="${ctx}/home" class="hidden sm:inline-flex items-center gap-2 px-3 py-1.5 rounded-xl border border-emerald-200 bg-emerald-50 text-emerald-700 text-xs font-bold hover:bg-emerald-100 transition"
           title="Về trang chủ mua sắm">
            <i class="fa-solid fa-house text-[11px]"></i> Về trang chủ
        </a>

        <div class="status-receiving-orders">
            <span class="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
            <span>Đang nhận đơn</span>
        </div>

        <button class="header-icon-action" type="button" title="Tin nhắn">
            <i class="fa-regular fa-comment-dots text-sm"></i>
        </button>

        <div class="relative" id="shop-noti-container">
            <button class="header-icon-action relative cursor-pointer" type="button" id="shop-noti-btn" onclick="toggleShopNoti(event)" title="Thông báo">
                <i class="fa-regular fa-bell text-sm"></i>
                <span id="shop-noti-badge" class="header-icon-badge hidden">0</span>
            </button>

            <!-- Dropdown Thông Báo Shop -->
            <div id="shop-noti-popover" class="hidden absolute right-0 mt-2 w-80 sm:w-96 bg-white rounded-2xl shadow-2xl border border-slate-100 p-4 z-50 transform origin-top-right transition-all">
                <div class="flex items-center justify-between pb-3 border-b border-slate-100 mb-3">
                    <div class="flex items-center gap-2">
                        <i class="fa-regular fa-bell text-[#00652c] text-sm"></i>
                        <span class="font-bold text-slate-900 text-sm">Thông Báo Gian Hàng</span>
                    </div>
                    <button type="button" onclick="clearShopNotifications(event)" class="text-xs text-[#00652c] hover:underline font-semibold cursor-pointer">Đánh dấu đã đọc</button>
                </div>
                <div class="max-h-72 overflow-y-auto space-y-2.5" id="shop-noti-list">
                    <div class="py-6 text-center text-xs text-slate-400">Đang tải thông báo...</div>
                </div>
            </div>
        </div>

        <div class="flex items-center gap-3 pl-3 border-l border-slate-200">
            <div class="text-right hidden sm:block">
                <span class="text-xs font-bold text-gray-900 block leading-tight">
                    <c:out value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Chủ gian hàng'}" />
                </span>
                <span class="text-[11px] text-gray-500 block leading-tight">Chủ gian hàng</span>
            </div>
            <div class="w-9 h-9 rounded-full bg-[#166534] text-white flex items-center justify-center font-bold text-sm shrink-0 shadow-xs">
                <c:choose>
                    <c:when test="${not empty sessionScope.user.avatarUrl}">
                        <img src="<c:out value='${sessionScope.user.avatarUrl}'/>" alt="Avatar" class="w-full h-full rounded-full object-cover">
                    </c:when>
                    <c:otherwise>
                        <i class="fa-regular fa-user text-xs"></i>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</header>
