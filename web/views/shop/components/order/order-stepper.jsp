<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN" />

<c:set var="isFailedOrder" value="${subOrder.status eq 'RETURNED' or subOrder.status eq 'FAILED' or subOrder.delivery.deliveryStatus eq 'FAILED'}" />
<c:set var="isDeliveredOrder" value="${subOrder.status eq 'DELIVERED' or subOrder.status eq 'COMPLETED' or subOrder.delivery.deliveryStatus eq 'DELIVERED' or not empty subOrder.delivery.deliveredAt}" />
<c:set var="isCancelledOrder" value="${subOrder.status eq 'CANCELLED'}" />

<div class="bg-white rounded-2xl border border-slate-200 p-5 shadow-xs overflow-x-auto">
    <div class="min-w-[680px]">
        <div class="flex items-start justify-between relative">

            <div class="flex flex-col items-center text-center w-36 z-10">
                <div class="w-9 h-9 rounded-full bg-emerald-600 text-white flex items-center justify-center font-bold text-sm shadow-sm ring-4 ring-emerald-50">
                    <i class="fa-solid fa-check"></i>
                </div>
                <div class="mt-2.5 font-extrabold text-xs text-slate-900">Đã Tạo Đơn Con</div>
                <div class="text-[11px] text-slate-400 mt-0.5 font-medium">
                    <fmt:formatDate value="${subOrder.createdAt}" pattern="HH:mm dd/MM" />
                </div>
            </div>

            <div class="flex flex-col items-center text-center w-36 z-10">
                <c:choose>
                    <c:when test="${isCancelledOrder}">
                        <div class="w-9 h-9 rounded-full bg-rose-600 text-white ring-4 ring-rose-100 flex items-center justify-center font-bold text-sm shadow-sm">
                            <i class="fa-solid fa-ban"></i>
                        </div>
                        <div class="mt-2.5 font-extrabold text-xs text-rose-600">Đã Hủy Đơn</div>
                        <div class="text-[11px] text-rose-500 font-semibold mt-0.5 truncate max-w-[140px]" title="${subOrder.cancelReason}">
                            ${not empty subOrder.cancelReason ? subOrder.cancelReason : "Đơn hàng đã bị hủy"}
                        </div>
                    </c:when>
                    <c:when test="${subOrder.status eq 'NEW'}">
                        <c:choose>
                            <c:when test="${(subOrder.paymentMethod eq 'VNPAY' or subOrder.paymentMethod eq 'CARD') and subOrder.paymentStatus ne 'PAID'}">
                                <div class="w-9 h-9 rounded-full bg-amber-500 text-white ring-4 ring-amber-100 flex items-center justify-center font-bold text-sm shadow-sm animate-pulse">
                                    <i class="fa-solid fa-credit-card"></i>
                                </div>
                                <div class="mt-2.5 font-extrabold text-xs text-amber-700">Chờ Thanh Toán</div>
                                <div class="text-[11px] text-amber-600 font-semibold mt-0.5">${subOrder.paymentMethod} chưa trả</div>
                            </c:when>
                            <c:otherwise>
                                <div class="w-9 h-9 rounded-full bg-amber-500 text-white ring-4 ring-amber-100 flex items-center justify-center font-bold text-sm shadow-sm animate-pulse">
                                    <i class="fa-solid fa-clock"></i>
                                </div>
                                <div class="mt-2.5 font-extrabold text-xs text-amber-700">Chờ Shop Duyệt</div>
                                <div class="text-[11px] text-slate-400 mt-0.5 font-medium">Kiểm định tồn kho</div>
                            </c:otherwise>
                        </c:choose>
                    </c:when>
                    <c:otherwise>
                        <div class="w-9 h-9 rounded-full bg-emerald-600 text-white ring-4 ring-emerald-50 flex items-center justify-center font-bold text-sm shadow-sm">
                            <i class="fa-solid fa-check"></i>
                        </div>
                        <div class="mt-2.5 font-extrabold text-xs text-slate-900">Shop Xác Nhận</div>
                        <div class="text-[11px] text-slate-400 mt-0.5 font-medium">Tiếp nhận nông sản</div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="flex flex-col items-center text-center w-36 z-10">
                <c:choose>
                    <c:when test="${subOrder.status eq 'PACKING'}">
                        <div class="w-9 h-9 rounded-full bg-emerald-700 text-white ring-4 ring-emerald-100 shadow-md scale-110 flex items-center justify-center font-bold text-sm animate-pulse">
                            <i class="fa-solid fa-box-open"></i>
                        </div>
                        <div class="mt-2.5 font-extrabold text-xs text-emerald-700">Đang Đóng Gói</div>
                        <div class="text-[11px] text-emerald-700 font-semibold mt-0.5">QC độ tươi &amp; đá gel</div>
                    </c:when>
                    <c:when test="${subOrder.status eq 'SHIPPING' or isDeliveredOrder or isFailedOrder}">
                        <div class="w-9 h-9 rounded-full bg-emerald-600 text-white ring-4 ring-emerald-50 flex items-center justify-center font-bold text-sm shadow-sm">
                            <i class="fa-solid fa-check"></i>
                        </div>
                        <div class="mt-2.5 font-extrabold text-xs text-slate-900">Đã Đóng Gói</div>
                        <div class="text-[11px] text-slate-400 mt-0.5 font-medium">Đạt chuẩn xuất kho</div>
                    </c:when>
                    <c:otherwise>
                        <div class="w-9 h-9 rounded-full bg-slate-100 border border-slate-200 text-slate-400 flex items-center justify-center font-bold text-sm">
                            <i class="fa-solid fa-box-open"></i>
                        </div>
                        <div class="mt-2.5 font-extrabold text-xs text-slate-400">Đóng Gói Hàng</div>
                        <div class="text-[11px] text-slate-400 mt-0.5 font-medium">QC độ tươi &amp; đá gel</div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="flex flex-col items-center text-center w-36 z-10">
                <c:choose>
                    <c:when test="${(subOrder.status eq 'SHIPPING' or subOrder.delivery.deliveryStatus eq 'DELIVERING' or subOrder.delivery.deliveryStatus eq 'PICKED_UP' or subOrder.delivery.deliveryStatus eq 'IN_TRANSIT') and not isDeliveredOrder and not isFailedOrder}">
                        <div class="w-9 h-9 rounded-full bg-emerald-700 text-white ring-4 ring-emerald-100 shadow-md scale-110 flex items-center justify-center font-bold text-sm animate-pulse">
                            <i class="fa-solid fa-truck-fast"></i>
                        </div>
                        <div class="mt-2.5 font-extrabold text-xs text-emerald-700">Đang Vận Chuyển</div>
                        <div class="text-[11px] text-emerald-700 font-semibold mt-0.5">Xe lạnh tiếp nhận</div>
                    </c:when>
                    <c:when test="${isDeliveredOrder or isFailedOrder}">
                        <div class="w-9 h-9 rounded-full bg-emerald-600 text-white ring-4 ring-emerald-50 flex items-center justify-center font-bold text-sm shadow-sm">
                            <i class="fa-solid fa-check"></i>
                        </div>
                        <div class="mt-2.5 font-extrabold text-xs text-slate-900">Đã Bàn Giao Xe Lạnh</div>
                        <div class="text-[11px] text-slate-400 mt-0.5 font-medium">Tài xế giao hàng</div>
                    </c:when>
                    <c:otherwise>
                        <div class="w-9 h-9 rounded-full bg-slate-100 border border-slate-200 text-slate-400 flex items-center justify-center font-bold text-sm">
                            <i class="fa-solid fa-truck-fast"></i>
                        </div>
                        <div class="mt-2.5 font-extrabold text-xs text-slate-400">Bàn Giao Xe Lạnh</div>
                        <div class="text-[11px] text-slate-400 mt-0.5 font-medium">Chờ xuất kho</div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="flex flex-col items-center text-center w-36 z-10">
                <c:choose>
                    <c:when test="${isFailedOrder}">
                        <div class="w-9 h-9 rounded-full bg-rose-600 text-white ring-4 ring-rose-100 shadow-md flex items-center justify-center font-bold text-sm">
                            <i class="fa-solid fa-circle-xmark"></i>
                        </div>
                        <div class="mt-2.5 font-extrabold text-xs text-rose-600">Giao Thất Bại</div>
                        <div class="text-[11px] text-rose-500 font-semibold mt-0.5 truncate max-w-[140px]" title="${not empty subOrder.cancelReason ? subOrder.cancelReason : 'Khách từ chối nhận'}">
                            <c:out value="${not empty subOrder.cancelReason ? subOrder.cancelReason : 'Khách từ chối nhận'}"/>
                        </div>
                    </c:when>
                    <c:when test="${isDeliveredOrder}">
                        <div class="w-9 h-9 rounded-full bg-emerald-600 text-white ring-4 ring-emerald-50 flex items-center justify-center font-bold text-sm shadow-sm">
                            <i class="fa-solid fa-circle-check"></i>
                        </div>
                        <div class="mt-2.5 font-extrabold text-xs text-emerald-700">Giao Thành Công</div>
                        <div class="text-[11px] text-emerald-600 font-medium mt-0.5">Đã tới tay khách</div>
                    </c:when>
                    <c:otherwise>
                        <div class="w-9 h-9 rounded-full bg-slate-100 border border-slate-200 text-slate-400 flex items-center justify-center font-bold text-sm">
                            <i class="fa-solid fa-circle-check"></i>
                        </div>
                        <div class="mt-2.5 font-extrabold text-xs text-slate-400">Giao Thành Công</div>
                        <div class="text-[11px] text-slate-400 mt-0.5 font-medium">Chờ giao khách</div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="absolute top-[18px] left-[72px] right-[72px] h-1 bg-slate-100 -z-0">
                <div class="h-full ${isCancelledOrder or isFailedOrder ? 'bg-rose-500' : 'bg-emerald-600'} transition-all duration-500 ${isCancelledOrder or subOrder.status eq 'NEW' ? 'w-1/4' : (subOrder.status eq 'PACKING' ? 'w-2/4' : ((subOrder.status eq 'SHIPPING' or subOrder.delivery.deliveryStatus eq 'DELIVERING') and not isDeliveredOrder ? 'w-3/4' : 'w-full'))}"></div>
            </div>

        </div>
    </div>
</div>
