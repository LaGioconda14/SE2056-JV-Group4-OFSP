<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Lịch sử sử dụng voucher - Kênh Người Bán</title>
    <jsp:include page="/views/shop/layout/head.jsp" />
    <link rel="stylesheet" href="${ctx}/assets/css/shop-marketing.css"/>
    <script src="${ctx}/assets/js/shop-marketing.js" defer></script>
</head>
<body class="bg-[#f8fafc] text-[#0f172a]">

    <jsp:include page="/views/shop/layout/sidebar.jsp"><jsp:param name="active" value="vouchers" /></jsp:include>
    <jsp:include page="/views/shop/layout/header.jsp" />

    <main class="shop-main-wrapper">
        <div class="shop-content-container">

            <nav class="flex items-center gap-2 text-xs text-slate-500 font-medium">
                <span>Kênh Người Bán</span>
                <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                <a href="${ctx}/shop/vouchers" class="hover:text-emerald-700">Voucher Shop</a>
                <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                <span class="text-slate-800 font-semibold">Lịch sử sử dụng</span>
            </nav>

            <div class="flex flex-col md:flex-row md:items-end justify-between gap-4">
                <div>
                    <div class="flex items-center flex-wrap gap-3">
                        <h1 class="text-2xl font-black text-slate-900 tracking-tight"><c:out value="${voucher.title}"/></h1>
                        <jsp:include page="/views/shop/layout/mk-status.jsp"><jsp:param name="status" value="${voucher.status}"/></jsp:include>
                    </div>
                    <p class="text-sm text-slate-500 mt-2 flex flex-wrap items-center gap-3">
                        <span class="mk-code"><c:out value="${voucher.code}"/></span>
                        <span><fmt:formatDate value="${voucher.startDate}" pattern="dd/MM/yyyy HH:mm"/> – <fmt:formatDate value="${voucher.endDate}" pattern="dd/MM/yyyy HH:mm"/></span>
                    </p>
                </div>
                <div class="flex gap-2">
                    <a href="${ctx}/shop/vouchers" class="mk-btn-ghost"><i class="fa-solid fa-arrow-left"></i> Quay lại</a>
                    <c:if test="${voucher.status != 'ENDED'}">
                        <a href="${ctx}/shop/vouchers?action=edit&id=${voucher.couponId}" class="mk-btn-primary"><i class="fa-solid fa-pen"></i> Chỉnh sửa</a>
                    </c:if>
                </div>
            </div>

            <div class="grid grid-cols-2 xl:grid-cols-4 gap-4">
                <div class="mk-card mk-stat">
                    <span class="mk-stat-icon bg-emerald-50 text-emerald-600"><i class="fa-solid fa-ticket"></i></span>
                    <span><span class="mk-stat-num">${voucher.usedCount} / ${voucher.usageLimit}</span><span class="mk-stat-label">Lượt đã dùng (còn ${voucher.remaining})</span></span>
                </div>
                <div class="mk-card mk-stat">
                    <span class="mk-stat-icon bg-violet-50 text-violet-600"><i class="fa-solid fa-users"></i></span>
                    <span><span class="mk-stat-num">${usageStats.uniqueCustomers}</span><span class="mk-stat-label">Khách hàng đã dùng</span></span>
                </div>
                <div class="mk-card mk-stat">
                    <span class="mk-stat-icon bg-amber-50 text-amber-600"><i class="fa-solid fa-hand-holding-dollar"></i></span>
                    <span><span class="mk-stat-num"><fmt:formatNumber value="${usageStats.totalDiscount}" pattern="#,##0"/> ₫</span><span class="mk-stat-label">Tổng tiền đã giảm</span></span>
                </div>
                <div class="mk-card mk-stat">
                    <span class="mk-stat-icon bg-sky-50 text-sky-600"><i class="fa-solid fa-calculator"></i></span>
                    <span><span class="mk-stat-num"><fmt:formatNumber value="${usageStats.avgDiscount}" pattern="#,##0"/> ₫</span><span class="mk-stat-label">Giảm trung bình / lượt</span></span>
                </div>
            </div>

            <div class="mk-card overflow-hidden">
                <div class="mk-card-pad border-b border-slate-100"><h2 class="mk-h2"><i class="fa-solid fa-clock-rotate-left"></i> Lịch sử sử dụng</h2></div>
                <c:choose>
                    <c:when test="${not empty usageList}">
                        <div class="overflow-x-auto">
                            <table class="mk-table">
                                <thead>
                                    <tr><th>Thời gian</th><th>Khách hàng</th><th>Mã đơn hàng</th><th class="text-right">Giá trị đơn</th><th class="text-right">Đã giảm</th></tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="u" items="${usageList}">
                                        <tr>
                                            <td class="text-[13px] text-slate-600 whitespace-nowrap"><fmt:formatDate value="${u.usedAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                            <td>
                                                <div class="text-[13px] font-semibold text-slate-800"><c:out value="${u.customerName}"/></div>
                                                <div class="text-[11px] text-slate-400"><c:out value="${u.customerEmail}"/></div>
                                            </td>
                                            <td class="text-[13px] font-semibold text-slate-700"><c:out value="${empty u.orderCode ? '—' : u.orderCode}"/></td>
                                            <td class="text-right text-[13px] text-slate-700">
                                                <c:choose>
                                                    <c:when test="${not empty u.orderAmount}"><fmt:formatNumber value="${u.orderAmount}" pattern="#,##0"/> ₫</c:when>
                                                    <c:otherwise>—</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-right text-[13px] font-extrabold text-emerald-700">-<fmt:formatNumber value="${u.discount}" pattern="#,##0"/> ₫</td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="mk-empty"><i class="fa-solid fa-receipt"></i>Chưa có khách hàng nào sử dụng voucher này.</div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </main>
</body>
</html>
