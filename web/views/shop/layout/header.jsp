<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
    HEADER DÙNG CHUNG CHO KÊNH NGƯỜI BÁN (SELLER DASHBOARD)
    Cách dùng (đặt ngay sau sidebar):
        <jsp:include page="/views/shop/layout/header.jsp" />

    Tuỳ chọn: ô tìm kiếm mặc định gửi tới /shop/products, muốn đổi thì truyền thêm:
        <jsp:include page="/views/shop/layout/header.jsp">
            <jsp:param name="searchAction" value="/shop/inventory" />
        </jsp:include>
--%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="hdSearchAction" value="${not empty param.searchAction ? param.searchAction : '/shop/products'}" />

<header class="shop-header">
    <div class="flex items-center gap-3">
        <!-- Nút mở sidebar (chỉ hiện trên màn hình nhỏ) -->
        <button type="button" class="shop-sidebar-toggle" id="shopSidebarToggle" aria-label="Mở menu">
            <i class="fa-solid fa-bars text-sm"></i>
        </button>

        <!-- Search bar -->
        <div class="header-search-container">
            <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs"></i>
            <form action="${ctx}${hdSearchAction}" method="GET">
                <input type="text" id="shopHeaderSearch" name="keyword" value="<c:out value='${param.keyword}'/>"
                       placeholder="Tìm theo SKU, tên trái cây, hoặc mã đơn con (Ctrl + K)..." class="header-search-input">
            </form>
        </div>
    </div>

    <!-- Right Header Items -->
    <div class="flex items-center gap-4">
        <!-- Về trang chủ mua sắm -->
        <a href="${ctx}/home" class="hidden sm:inline-flex items-center gap-2 px-3 py-1.5 rounded-xl border border-emerald-200 bg-emerald-50 text-emerald-700 text-xs font-bold hover:bg-emerald-100 transition"
           title="Về trang chủ mua sắm">
            <i class="fa-solid fa-house text-[11px]"></i> Về trang chủ
        </a>

        <!-- Active receiving orders status -->
        <div class="status-receiving-orders">
            <span class="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
            <span>Đang nhận đơn</span>
        </div>

        <!-- Chat icon -->
        <button class="header-icon-action" type="button" title="Tin nhắn">
            <i class="fa-regular fa-comment-dots text-sm"></i>
        </button>

        <!-- Notification icon with badge -->
        <button class="header-icon-action" type="button" title="Thông báo">
            <i class="fa-regular fa-bell text-sm"></i>
            <span class="header-icon-badge">5</span>
        </button>

        <!-- User profile -->
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
