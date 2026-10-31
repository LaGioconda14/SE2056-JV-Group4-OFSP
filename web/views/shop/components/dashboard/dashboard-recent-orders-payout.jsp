<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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

