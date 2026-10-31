<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
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

