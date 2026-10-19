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

            <!-- ===== TIÊU ĐỀ + BỘ LỌC KỲ ===== -->
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

            <!-- ===== VIỆC CẦN LÀM ===== -->
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

            <!-- ===== KPI ===== -->
            <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">

                <!-- Doanh thu -->
                <div class="kpi-card">
                    <div class="flex items-center justify-between">
                        <span class="kpi-label">Doanh thu (đơn đã giao)</span>
                        <span class="kpi-icon bg-emerald-50 text-emerald-600"><i class="fa-solid fa-sack-dollar"></i></span>
                    </div>
                    <div class="kpi-value"><fmt:formatNumber value="${revenue}" pattern="#,##0"/> ₫</div>
                    <div class="kpi-sub">
                        <c:if test="${hasCompare}">
                            <c:choose>
                                <c:when test="${empty revenueChange}"><span class="chg chg-up">Mới</span></c:when>
                                <c:when test="${revenueChange > 0}"><span class="chg chg-up"><i class="fa-solid fa-arrow-trend-up"></i> <fmt:formatNumber value="${revenueChange}" maxFractionDigits="1"/>%</span></c:when>
                                <c:when test="${revenueChange < 0}"><span class="chg chg-down"><i class="fa-solid fa-arrow-trend-down"></i> <fmt:formatNumber value="${-revenueChange}" maxFractionDigits="1"/>%</span></c:when>
                                <c:otherwise><span class="chg chg-flat">0%</span></c:otherwise>
                            </c:choose>
                            so với kỳ trước
                        </c:if>
                        <c:if test="${not hasCompare}">Thực nhận sau hoa hồng: <b><fmt:formatNumber value="${netRevenue}" pattern="#,##0"/> ₫</b></c:if>
                    </div>
                </div>

                <!-- Tổng đơn -->
                <div class="kpi-card">
                    <div class="flex items-center justify-between">
                        <span class="kpi-label">Tổng đơn hàng</span>
                        <span class="kpi-icon bg-sky-50 text-sky-600"><i class="fa-solid fa-receipt"></i></span>
                    </div>
                    <div class="kpi-value"><fmt:formatNumber value="${orders}" pattern="#,##0"/></div>
                    <div class="kpi-sub">
                        <c:if test="${hasCompare}">
                            <c:choose>
                                <c:when test="${empty ordersChange}"><span class="chg chg-up">Mới</span></c:when>
                                <c:when test="${ordersChange > 0}"><span class="chg chg-up"><i class="fa-solid fa-arrow-trend-up"></i> <fmt:formatNumber value="${ordersChange}" maxFractionDigits="1"/>%</span></c:when>
                                <c:when test="${ordersChange < 0}"><span class="chg chg-down"><i class="fa-solid fa-arrow-trend-down"></i> <fmt:formatNumber value="${-ordersChange}" maxFractionDigits="1"/>%</span></c:when>
                                <c:otherwise><span class="chg chg-flat">0%</span></c:otherwise>
                            </c:choose>
                            so với kỳ trước
                        </c:if>
                        <c:if test="${not hasCompare}">${delivered} đã giao · ${cancelled} hủy/hoàn</c:if>
                    </div>
                </div>

                <!-- Sản lượng -->
                <div class="kpi-card">
                    <div class="flex items-center justify-between">
                        <span class="kpi-label">Sản phẩm đã bán</span>
                        <span class="kpi-icon bg-orange-50 text-orange-600"><i class="fa-solid fa-apple-whole"></i></span>
                    </div>
                    <div class="kpi-value"><fmt:formatNumber value="${itemsSold}" pattern="#,##0"/></div>
                    <div class="kpi-sub">
                        <c:if test="${hasCompare}">
                            <c:choose>
                                <c:when test="${empty itemsChange}"><span class="chg chg-up">Mới</span></c:when>
                                <c:when test="${itemsChange > 0}"><span class="chg chg-up"><i class="fa-solid fa-arrow-trend-up"></i> <fmt:formatNumber value="${itemsChange}" maxFractionDigits="1"/>%</span></c:when>
                                <c:when test="${itemsChange < 0}"><span class="chg chg-down"><i class="fa-solid fa-arrow-trend-down"></i> <fmt:formatNumber value="${-itemsChange}" maxFractionDigits="1"/>%</span></c:when>
                                <c:otherwise><span class="chg chg-flat">0%</span></c:otherwise>
                            </c:choose>
                            so với kỳ trước
                        </c:if>
                        <c:if test="${not hasCompare}">Tổng số lượng các món đã bán</c:if>
                    </div>
                </div>

                <!-- Giá trị đơn TB -->
                <div class="kpi-card">
                    <div class="flex items-center justify-between">
                        <span class="kpi-label">Giá trị đơn trung bình</span>
                        <span class="kpi-icon bg-violet-50 text-violet-600"><i class="fa-solid fa-chart-simple"></i></span>
                    </div>
                    <div class="kpi-value"><fmt:formatNumber value="${avgOrderValue}" pattern="#,##0"/> ₫</div>
                    <div class="kpi-sub">
                        <c:if test="${hasCompare}">
                            <c:choose>
                                <c:when test="${empty aovChange}"><span class="chg chg-up">Mới</span></c:when>
                                <c:when test="${aovChange > 0}"><span class="chg chg-up"><i class="fa-solid fa-arrow-trend-up"></i> <fmt:formatNumber value="${aovChange}" maxFractionDigits="1"/>%</span></c:when>
                                <c:when test="${aovChange < 0}"><span class="chg chg-down"><i class="fa-solid fa-arrow-trend-down"></i> <fmt:formatNumber value="${-aovChange}" maxFractionDigits="1"/>%</span></c:when>
                                <c:otherwise><span class="chg chg-flat">0%</span></c:otherwise>
                            </c:choose>
                            so với kỳ trước
                        </c:if>
                        <c:if test="${not hasCompare}">Doanh thu / số đơn đã giao</c:if>
                    </div>
                </div>
            </div>

            <!-- ===== BIỂU ĐỒ ===== -->
            <div class="grid grid-cols-1 xl:grid-cols-12 gap-6">
                <div class="xl:col-span-8 panel">
                    <div class="panel-head">
                        <h2>Doanh thu &amp; đơn hàng theo thời gian</h2>
                        <span class="text-xs text-slate-400">Cột: doanh thu (₫) · Đường: số đơn</span>
                    </div>
                    <div class="chart-box"><canvas id="trendChart"></canvas></div>
                </div>

                <div class="xl:col-span-4 panel">
                    <div class="panel-head"><h2>Cơ cấu trạng thái đơn</h2></div>
                    <c:choose>
                        <c:when test="${hasStatusData}">
                            <div class="chart-box chart-box-sm"><canvas id="statusChart"></canvas></div>
                            <div class="mt-4 grid grid-cols-2 gap-3 text-xs">
                                <div class="mini-stat"><span>Hủy / hoàn</span><b><fmt:formatNumber value="${cancelRate}" maxFractionDigits="1"/>%</b></div>
                                <div class="mini-stat"><span>Hoa hồng sàn</span><b><fmt:formatNumber value="${commission}" pattern="#,##0"/> ₫</b></div>
                            </div>
                        </c:when>
                        <c:otherwise><div class="empty-state"><i class="fa-regular fa-chart-bar"></i>Chưa có đơn hàng trong kỳ này</div></c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- ===== BEST SELLER + ĐÁNH GIÁ ===== -->
            <div class="grid grid-cols-1 xl:grid-cols-12 gap-6">
                <div class="xl:col-span-7 panel">
                    <div class="panel-head">
                        <h2>Top trái cây bán chạy</h2>
                        <a href="${ctx}/shop/products" class="panel-link">Xem sản phẩm <i class="fa-solid fa-arrow-right text-[10px]"></i></a>
                    </div>
                    <c:choose>
                        <c:when test="${not empty bestSellers}">
                            <c:set var="topQty" value="${bestSellers[0].qty}"/>
                            <ul class="flex flex-col gap-4">
                                <c:forEach var="b" items="${bestSellers}" varStatus="st">
                                    <li class="flex items-center gap-3">
                                        <span class="rank-badge rank-${st.index + 1}">${st.index + 1}</span>
                                        <c:choose>
                                            <c:when test="${not empty b.image}"><img src="${b.image}" alt="" class="w-11 h-11 rounded-xl object-cover border border-slate-100"/></c:when>
                                            <c:otherwise><span class="w-11 h-11 rounded-xl bg-emerald-50 text-emerald-500 flex items-center justify-center"><i class="fa-solid fa-apple-whole"></i></span></c:otherwise>
                                        </c:choose>
                                        <div class="flex-1 min-w-0">
                                            <div class="flex items-center justify-between gap-3">
                                                <span class="text-sm font-semibold text-slate-800 truncate"><c:out value="${b.name}"/></span>
                                                <span class="text-sm font-bold text-slate-900 whitespace-nowrap"><fmt:formatNumber value="${b.revenue}" pattern="#,##0"/> ₫</span>
                                            </div>
                                            <div class="bar-track"><div class="bar-fill" style="width: ${topQty > 0 ? (b.qty * 100 / topQty) : 0}%"></div></div>
                                            <span class="text-[11px] text-slate-500">${b.qty} đã bán · ${b.orders} đơn</span>
                                        </div>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:when>
                        <c:otherwise><div class="empty-state"><i class="fa-solid fa-apple-whole"></i>Chưa có sản phẩm nào được bán trong kỳ này</div></c:otherwise>
                    </c:choose>
                </div>

                <div class="xl:col-span-5 panel">
                    <div class="panel-head">
                        <h2>Đánh giá của khách hàng</h2>
                        <a href="${ctx}/shop/reviews" class="panel-link">Xem tất cả <i class="fa-solid fa-arrow-right text-[10px]"></i></a>
                    </div>
                    <c:choose>
                        <c:when test="${ratingStats.total > 0}">
                            <div class="flex items-center gap-5">
                                <div class="text-center">
                                    <div class="text-4xl font-extrabold text-slate-900"><fmt:formatNumber value="${ratingStats.avg}" minFractionDigits="1" maxFractionDigits="1"/></div>
                                    <div class="text-amber-400 text-xs mt-1">
                                        <c:forEach begin="1" end="5" var="i"><i class="fa-solid fa-star ${ratingStats.avg >= i - 0.25 ? '' : 'opacity-25'}"></i></c:forEach>
                                    </div>
                                    <div class="text-[11px] text-slate-500 mt-1">${ratingStats.total} đánh giá</div>
                                </div>
                                <div class="flex-1 flex flex-col gap-1.5">
                                    <div class="rate-row"><span>5★</span><div class="bar-track"><div class="bar-fill bg-amber-400" style="width:${ratingStats.p5}%"></div></div><span>${ratingStats.c5}</span></div>
                                    <div class="rate-row"><span>4★</span><div class="bar-track"><div class="bar-fill bg-amber-400" style="width:${ratingStats.p4}%"></div></div><span>${ratingStats.c4}</span></div>
                                    <div class="rate-row"><span>3★</span><div class="bar-track"><div class="bar-fill bg-amber-400" style="width:${ratingStats.p3}%"></div></div><span>${ratingStats.c3}</span></div>
                                    <div class="rate-row"><span>2★</span><div class="bar-track"><div class="bar-fill bg-amber-400" style="width:${ratingStats.p2}%"></div></div><span>${ratingStats.c2}</span></div>
                                    <div class="rate-row"><span>1★</span><div class="bar-track"><div class="bar-fill bg-amber-400" style="width:${ratingStats.p1}%"></div></div><span>${ratingStats.c1}</span></div>
                                </div>
                            </div>
                            <p class="text-xs text-slate-500 mt-3"><b>${ratingStats.newInPeriod}</b> đánh giá mới trong kỳ này</p>

                            <div class="mt-4 pt-4 border-t border-slate-100 flex flex-col gap-4">
                                <c:forEach var="r" items="${latestReviews}">
                                    <div>
                                        <div class="flex items-center justify-between">
                                            <span class="text-sm font-semibold text-slate-800"><c:out value="${r.customer}"/></span>
                                            <span class="text-amber-400 text-[10px]">
                                                <c:forEach begin="1" end="5" var="i"><i class="fa-solid fa-star ${r.rating >= i ? '' : 'opacity-25'}"></i></c:forEach>
                                            </span>
                                        </div>
                                        <p class="text-[11px] text-slate-400"><c:out value="${r.product}"/> · <fmt:formatDate value="${r.createdAt}" pattern="dd/MM/yyyy"/></p>
                                        <c:if test="${not empty r.comment}"><p class="text-sm text-slate-600 mt-1 line-clamp-2"><c:out value="${r.comment}"/></p></c:if>
                                        <c:if test="${empty r.reply}"><span class="inline-block mt-1 text-[11px] font-semibold text-violet-600">Chưa phản hồi</span></c:if>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise><div class="empty-state"><i class="fa-regular fa-star"></i>Shop chưa có đánh giá nào</div></c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- ===== ĐƠN GẦN ĐÂY + TÀI CHÍNH + TỒN KHO ===== -->
            <div class="grid grid-cols-1 xl:grid-cols-12 gap-6">
                <div class="xl:col-span-8 panel">
                    <div class="panel-head">
                        <h2>Đơn hàng gần đây</h2>
                        <a href="${ctx}/shop/orders" class="panel-link">Tất cả đơn hàng <i class="fa-solid fa-arrow-right text-[10px]"></i></a>
                    </div>
                    <c:choose>
                        <c:when test="${not empty recentOrders}">
                            <div class="overflow-x-auto">
                                <table class="w-full text-sm">
                                    <thead>
                                        <tr class="text-left text-[11px] uppercase text-slate-400 border-b border-slate-100">
                                            <th class="py-2 pr-3 font-semibold">Mã đơn</th>
                                            <th class="py-2 pr-3 font-semibold">Khách hàng</th>
                                            <th class="py-2 pr-3 font-semibold">Ngày đặt</th>
                                            <th class="py-2 pr-3 font-semibold text-right">Giá trị</th>
                                            <th class="py-2 font-semibold text-right">Trạng thái</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="o" items="${recentOrders}">
                                            <tr class="border-b border-slate-50 last:border-0">
                                                <td class="py-3 pr-3">
                                                    <div class="font-semibold text-slate-800"><c:out value="${o.subOrderCode}"/></div>
                                                    <div class="text-[11px] text-slate-400">${o.items} sản phẩm</div>
                                                </td>
                                                <td class="py-3 pr-3 text-slate-600"><c:out value="${o.customer}"/></td>
                                                <td class="py-3 pr-3 text-slate-500"><fmt:formatDate value="${o.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                                <td class="py-3 pr-3 text-right font-semibold"><fmt:formatNumber value="${o.total}" pattern="#,##0"/> ₫</td>
                                                <td class="py-3 text-right">
                                                    <c:choose>
                                                        <c:when test="${o.status == 'NEW'}"><span class="st st-amber">Mới</span></c:when>
                                                        <c:when test="${o.status == 'CONFIRMED'}"><span class="st st-sky">Đã xác nhận</span></c:when>
                                                        <c:when test="${o.status == 'PACKING'}"><span class="st st-sky">Đang đóng gói</span></c:when>
                                                        <c:when test="${o.status == 'SHIPPING'}"><span class="st st-violet">Đang giao</span></c:when>
                                                        <c:when test="${o.status == 'DELIVERED'}"><span class="st st-green">Đã giao</span></c:when>
                                                        <c:when test="${o.status == 'CANCELLED'}"><span class="st st-red">Đã hủy</span></c:when>
                                                        <c:when test="${o.status == 'REFUNDED'}"><span class="st st-red">Hoàn tiền</span></c:when>
                                                        <c:otherwise><span class="st st-gray"><c:out value="${o.status}"/></span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise><div class="empty-state"><i class="fa-solid fa-receipt"></i>Shop chưa có đơn hàng nào</div></c:otherwise>
                    </c:choose>
                </div>

                <div class="xl:col-span-4 flex flex-col gap-6">
                    <!-- Quyết toán -->
                    <div class="panel">
                        <div class="panel-head"><h2>Quyết toán doanh thu</h2></div>
                        <c:choose>
                            <c:when test="${not empty latestPayout}">
                                <p class="text-xs text-slate-500"><c:out value="${latestPayout.cycle}"/></p>
                                <div class="text-2xl font-extrabold text-slate-900 mt-1"><fmt:formatNumber value="${latestPayout.net}" pattern="#,##0"/> ₫</div>
                                <p class="text-[11px] text-slate-400 mt-1">
                                    Doanh số <fmt:formatNumber value="${latestPayout.gross}" pattern="#,##0"/> ₫ − hoa hồng <fmt:formatNumber value="${latestPayout.commission}" pattern="#,##0"/> ₫
                                </p>
                                <div class="mt-3">
                                    <c:choose>
                                        <c:when test="${latestPayout.status == 'COMPLETED'}"><span class="st st-green">Đã chi trả</span></c:when>
                                        <c:when test="${latestPayout.status == 'PROCESSING'}"><span class="st st-amber">Đang xử lý</span></c:when>
                                        <c:otherwise><span class="st st-red">Tạm giữ</span></c:otherwise>
                                    </c:choose>
                                </div>
                            </c:when>
                            <c:otherwise><div class="empty-state"><i class="fa-solid fa-wallet"></i>Chưa có kỳ quyết toán nào</div></c:otherwise>
                        </c:choose>
                        <c:if test="${openDisputes > 0}">
                            <a href="${ctx}/shop/orders" class="mt-4 flex items-center gap-2 text-xs font-semibold text-red-600 bg-red-50 rounded-lg px-3 py-2">
                                <i class="fa-solid fa-scale-balanced"></i> ${openDisputes} khiếu nại đang mở cần phản hồi
                            </a>
                        </c:if>
                    </div>

                    <!-- Tồn kho -->
                    <div class="panel">
                        <div class="panel-head">
                            <h2>Cảnh báo tồn kho</h2>
                            <a href="${ctx}/shop/inventory" class="panel-link">Kho <i class="fa-solid fa-arrow-right text-[10px]"></i></a>
                        </div>
                        <c:choose>
                            <c:when test="${not empty lowStockItems}">
                                <ul class="flex flex-col gap-3">
                                    <c:forEach var="l" items="${lowStockItems}">
                                        <li class="flex items-center justify-between gap-3">
                                            <div class="min-w-0">
                                                <div class="text-sm font-semibold text-slate-800 truncate"><c:out value="${l.name}"/></div>
                                                <div class="text-[11px] text-slate-400 truncate"><c:out value="${l.variant}"/> · <c:out value="${l.sku}"/></div>
                                            </div>
                                            <span class="st ${l.stock == 0 ? 'st-red' : 'st-amber'} whitespace-nowrap">Còn ${l.stock}</span>
                                        </li>
                                    </c:forEach>
                                </ul>
                            </c:when>
                            <c:otherwise><div class="empty-state"><i class="fa-solid fa-circle-check text-emerald-400"></i>Tồn kho ổn định</div></c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

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
