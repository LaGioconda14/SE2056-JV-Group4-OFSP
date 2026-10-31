<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Tổng quan Shop - Kênh Người Bán FreshFruit</title>
    <jsp:include page="/views/shop/layout/head.jsp" />
    <link rel="stylesheet" href="${ctx}/assets/css/shop-dashboard.css"/>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
</head>
<body class="bg-[#f8fafc] text-[#0f172a]">

    <jsp:include page="/views/shop/layout/sidebar.jsp">
        <jsp:param name="active" value="overview" />
    </jsp:include>
    <jsp:include page="/views/shop/layout/header.jsp" />

    <main class="shop-main-wrapper">
        <div class="shop-content-container">

            <c:if test="${not empty errorMessage}">
                <div class="p-4 bg-red-50 border border-red-200 text-red-700 rounded-xl text-sm"><c:out value="${errorMessage}"/></div>
            </c:if>

            <div class="flex flex-col md:flex-row md:items-end justify-between gap-4">
                <div>
                    <nav class="flex items-center gap-2 text-xs text-slate-500 font-medium mb-1">
                        <span>Kênh Người Bán</span>
                        <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                        <span>Tổng quan</span>
                    </nav>
                    <h1 class="text-2xl font-extrabold text-slate-900">
                        Xin chào, <c:out value="${sessionScope.user.fullName}"/> 👋
                    </h1>
                    <p class="text-sm text-slate-500 mt-1">
                        Số liệu <b><c:out value="${rangeLabel}"/></b>
                        (<fmt:formatDate value="${fromDate}" pattern="dd/MM/yyyy"/> – <fmt:formatDate value="${toDate}" pattern="dd/MM/yyyy"/>)
                    </p>
                </div>
                <div class="inline-flex bg-white border border-slate-200 rounded-xl p-1 gap-1 shadow-sm self-start md:self-auto">
                    <a href="${ctx}/shop/dashboard?range=7"   class="range-pill ${range == '7'   ? 'is-active' : ''}">7 ngày</a>
                    <a href="${ctx}/shop/dashboard?range=30"  class="range-pill ${range == '30'  ? 'is-active' : ''}">30 ngày</a>
                    <a href="${ctx}/shop/dashboard?range=90"  class="range-pill ${range == '90'  ? 'is-active' : ''}">90 ngày</a>
                    <a href="${ctx}/shop/dashboard?range=365" class="range-pill ${range == '365' ? 'is-active' : ''}">12 tháng</a>
                    <a href="${ctx}/shop/dashboard?range=all" class="range-pill ${range == 'all' ? 'is-active' : ''}">Tất cả</a>
                </div>
            </div>

            <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
                <a href="${ctx}/shop/orders" class="todo-card">
                    <span class="todo-icon bg-amber-50 text-amber-600"><i class="fa-solid fa-box-open"></i></span>
                    <span><span class="todo-num">${pendingOrders}</span><span class="todo-label">Đơn chờ xử lý</span></span>
                </a>
                <a href="${ctx}/shop/orders" class="todo-card">
                    <span class="todo-icon bg-sky-50 text-sky-600"><i class="fa-solid fa-truck-fast"></i></span>
                    <span><span class="todo-num">${shippingOrders}</span><span class="todo-label">Đơn đang giao</span></span>
                </a>
                <a href="${ctx}/shop/inventory" class="todo-card">
                    <span class="todo-icon bg-red-50 text-red-600"><i class="fa-solid fa-triangle-exclamation"></i></span>
                    <span><span class="todo-num">${lowStockCount}</span><span class="todo-label">SKU sắp hết hàng</span></span>
                </a>
                <a href="${ctx}/shop/reviews" class="todo-card">
                    <span class="todo-icon bg-violet-50 text-violet-600"><i class="fa-solid fa-comment-dots"></i></span>
                    <span><span class="todo-num">${unrepliedReviews}</span><span class="todo-label">Đánh giá chưa phản hồi</span></span>
                </a>
            </div>

            <jsp:include page="/views/shop/components/dashboard/dashboard-kpi-cards.jsp" />

            <jsp:include page="/views/shop/components/dashboard/dashboard-charts.jsp" />

            <jsp:include page="/views/shop/components/dashboard/dashboard-bestsellers-reviews.jsp" />

            <jsp:include page="/views/shop/components/dashboard/dashboard-recent-orders-payout.jsp" />

        </div>
    </main>

    <script src="${ctx}/assets/js/shop-dashboard.js"></script>
    <script>
        initDashboardCharts({
            trend: {
                labels: ${empty trendLabelsJson ? '[]' : trendLabelsJson},
                revenue: ${empty trendRevenueJson ? '[]' : trendRevenueJson},
                orders: ${empty trendOrdersJson ? '[]' : trendOrdersJson}
            },
            status: {
                labels: ${empty statusLabelsJson ? '[]' : statusLabelsJson},
                values: ${empty statusValuesJson ? '[]' : statusValuesJson}
            }
        });
    </script>
</body>
</html>
