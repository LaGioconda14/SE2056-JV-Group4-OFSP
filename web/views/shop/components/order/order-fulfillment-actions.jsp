<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN" />

<c:choose>
    <c:when test="${subOrder.status eq 'CANCELLED'}">
        <jsp:include page="/views/shop/components/order/fulfillment-cancelled.jsp" />
    </c:when>

    <c:when test="${subOrder.status eq 'NEW'}">
        <jsp:include page="/views/shop/components/order/fulfillment-new.jsp" />
    </c:when>

    <c:when test="${subOrder.status eq 'PACKING' or empty subOrder.status}">
        <jsp:include page="/views/shop/components/order/fulfillment-packing.jsp" />
    </c:when>

    <c:when test="${isFailedOrder}">
        <div class="bg-white rounded-2xl border border-rose-200 p-6 shadow-xs bg-rose-50/20">
            <div class="flex items-start gap-4">
                <div class="w-11 h-11 rounded-2xl bg-rose-100 text-rose-600 flex items-center justify-center text-xl font-bold shrink-0 shadow-2xs border border-rose-200">
                    <i class="fa-solid fa-truck-ramp-box"></i>
                </div>
                <div class="flex-1 min-w-0">
                    <div class="flex flex-wrap items-center justify-between gap-2 pb-3 border-b border-rose-100">
                        <div class="flex items-center gap-2">
                            <h2 class="text-base font-extrabold text-rose-950">Giao Hàng Thất Bại &amp; Kích Hoạt Hoàn Hàng</h2>
                            <span class="px-2.5 py-0.5 rounded-full text-[10px] font-black bg-rose-100 text-rose-700 border border-rose-300 uppercase">
                                GIAO THẤT BẠI
                            </span>
                        </div>
                        <c:if test="${not empty subOrder.deliveredAt or not empty subOrder.updatedAt}">
                            <span class="text-xs text-rose-600 font-medium">
                                <i class="fa-regular fa-clock mr-1"></i>
                                <fmt:formatDate value="${not empty subOrder.deliveredAt ? subOrder.deliveredAt : subOrder.updatedAt}" pattern="HH:mm dd/MM/yyyy" />
                            </span>
                        </c:if>
                    </div>

                    <div class="mt-3.5 p-3.5 rounded-xl bg-white border border-rose-200/90 text-xs space-y-2 shadow-2xs">
                        <div class="flex items-center justify-between">
                            <div class="font-extrabold text-rose-800 flex items-center gap-1.5">
                                <i class="fa-solid fa-triangle-exclamation text-rose-600"></i> Lý do giao không thành công từ Shipper / Khách:
                            </div>
                            <span class="font-mono text-[11px] text-slate-500">Mã vận đơn: <b>${subOrder.trackingNumber}</b></span>
                        </div>
                        <div class="text-slate-800 leading-relaxed font-semibold pl-4 border-l-2 border-rose-400 bg-rose-50/40 p-2 rounded-r-lg">
                            ${not empty subOrder.cancelReason ? subOrder.cancelReason : (not empty subOrder.failureReason ? subOrder.failureReason : 'Khách hàng từ chối nhận hoa quả khi đồng kiểm hoặc không liên lạc được.')}
                        </div>
                        <c:if test="${not empty subOrder.driverName}">
                            <div class="text-[11px] text-slate-500 pt-1 border-t border-slate-100 flex items-center justify-between">
                                <span>Tài xế bàn giao: <b class="text-slate-800">${subOrder.driverName}</b> <c:if test="${not empty subOrder.driverPhone}">(${subOrder.driverPhone})</c:if></span>
                                <span class="text-emerald-700 font-bold"><i class="fa-solid fa-snowflake"></i> Xe lạnh bảo ôn Gốc Vườn</span>
                            </div>
                        </c:if>
                    </div>

                    <div class="mt-3 flex items-start gap-2.5 text-xs text-slate-700 bg-amber-50/80 border border-amber-200 p-3 rounded-xl">
                        <i class="fa-solid fa-circle-info text-amber-600 text-sm mt-0.5 shrink-0"></i>
                        <div class="leading-relaxed">
                            <b>Tiến trình hỗ trợ Gian hàng:</b> Hệ thống đã tự động ghi nhận khiếu nại hoàn trả. Kiện hàng nông sản tươi sẽ được tài xế chuyển hoàn về kho/vườn của bạn. Mọi hỗ trợ xin liên hệ tổng đài <b>1900 6868</b>.
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </c:when>

    <c:when test="${isDeliveredOrder}">
        <div class="bg-white rounded-2xl border border-teal-200 p-6 shadow-xs bg-teal-50/20">
            <div class="flex items-center justify-between pb-3 border-b border-teal-100">
                <div class="flex items-center gap-2.5">
                    <div class="w-8 h-8 rounded-lg bg-teal-600 text-white flex items-center justify-center text-sm font-bold shadow-xs">
                        <i class="fa-solid fa-circle-check"></i>
                    </div>
                    <div>
                        <h2 class="text-base font-extrabold text-slate-900">Đơn Hàng Đã Giao Thành Công</h2>
                        <p class="text-[11px] text-slate-500">Khách hàng đã nhận và đồng kiểm chất lượng hoa quả tươi đạt chuẩn</p>
                    </div>
                </div>
                <span class="px-3 py-1 rounded-full text-xs font-black bg-teal-100 text-teal-800 border border-teal-300">
                    HOÀN TẤT GIAO HÀNG
                </span>
            </div>
            <div class="mt-4 p-4 rounded-xl bg-white border border-teal-200 text-xs text-slate-700 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                <div>
                    <div class="font-bold text-slate-900">Vận chuyển lạnh Gốc Vườn Express (GVX)</div>
                    <div class="text-slate-500 text-[11px] mt-0.5">Mã vận đơn: <b class="font-mono text-teal-800 text-xs">${not empty subOrder.trackingNumber ? subOrder.trackingNumber : subOrder.subOrderCode}</b></div>
                </div>
                <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-lg bg-teal-50 text-teal-700 font-extrabold text-xs">
                    <i class="fa-solid fa-box-check"></i> Đã tới tay khách hàng
                </div>
            </div>
        </div>
    </c:when>

    <c:when test="${subOrder.status eq 'RETURNED' or subOrder.status eq 'FAILED' or subOrder.deliveryStatus eq 'FAILED'}">
        <jsp:include page="/views/shop/components/order/fulfillment-returned.jsp" />
    </c:when>

    <c:otherwise>
        <div class="bg-white rounded-2xl border border-emerald-200 p-6 shadow-xs bg-emerald-50/20">
            <div class="flex items-center justify-between pb-3 border-b border-emerald-100">
                <div class="flex items-center gap-2.5">
                    <div class="w-8 h-8 rounded-lg bg-emerald-600 text-white flex items-center justify-center text-sm font-bold shadow-xs">
                        <i class="fa-solid fa-truck-fast"></i>
                    </div>
                    <div>
                        <h2 class="text-base font-extrabold text-slate-900">Sẵn Sàng Giao - Chờ Bàn Giao Xe Lạnh</h2>
                        <p class="text-[11px] text-slate-500">Kiện hàng đã hoàn tất đóng gói, bảo quản nhiệt độ mát 2-5°C chờ tài xế</p>
                    </div>
                </div>
                <span class="px-3 py-1 rounded-full text-xs font-black bg-emerald-100 text-emerald-800 border border-emerald-300">
                    CHỜ BÀN GIAO
                </span>
            </div>
            <div class="mt-4 p-4 rounded-xl bg-white border border-emerald-200 text-xs text-slate-700 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                <div>
                    <div class="font-bold text-slate-900">Vận chuyển lạnh Gốc Vườn Express (GVX)</div>
                    <div class="text-slate-500 text-[11px] mt-0.5">Mã vận đơn: <b class="font-mono text-emerald-800 text-xs">${not empty subOrder.trackingNumber ? subOrder.trackingNumber : subOrder.subOrderCode}</b></div>
                </div>
                <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-lg bg-emerald-50 text-emerald-700 font-extrabold text-xs">
                    <i class="fa-solid fa-snowflake"></i> Thùng bảo ôn 2-5°C
                </div>
            </div>
        </div>
    </c:otherwise>
</c:choose>
