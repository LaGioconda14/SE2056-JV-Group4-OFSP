<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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

