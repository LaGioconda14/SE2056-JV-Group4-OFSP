<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<div class="bg-white rounded-2xl border border-rose-200 p-6 shadow-xs bg-rose-50/20">
    <div class="flex items-start gap-4">
        <div class="w-11 h-11 rounded-2xl bg-rose-100 text-rose-600 flex items-center justify-center text-xl font-bold shrink-0 shadow-2xs border border-rose-200">
            <i class="fa-solid fa-ban"></i>
        </div>
        <div class="flex-1 min-w-0">
            <div class="flex flex-wrap items-center justify-between gap-2 pb-3 border-b border-rose-100">
                <div class="flex items-center gap-2">
                    <h2 class="text-base font-extrabold text-rose-950">Đơn Hàng Con Đã Bị Hủy</h2>
                    <span class="px-2.5 py-0.5 rounded-full text-[10px] font-black bg-rose-100 text-rose-700 border border-rose-300 uppercase">
                        CANCELLED
                    </span>
                </div>
                <c:if test="${not empty subOrder.cancelledAt}">
                    <span class="text-xs text-rose-600 font-medium">
                        <i class="fa-regular fa-clock mr-1"></i>
                        <fmt:formatDate value="${subOrder.cancelledAt}" pattern="HH:mm dd/MM/yyyy" />
                    </span>
                </c:if>
            </div>

            <div class="mt-3 p-3.5 rounded-xl bg-white border border-rose-200/90 text-xs space-y-1.5 shadow-2xs">
                <div class="font-extrabold text-rose-800 flex items-center gap-1.5">
                    <i class="fa-solid fa-triangle-exclamation text-rose-600"></i> Lý do hủy đơn từ Gian hàng:
                </div>
                <div class="text-slate-800 leading-relaxed font-semibold pl-4 border-l-2 border-rose-300">
                    ${not empty subOrder.cancelReason ? subOrder.cancelReason : "Gian hàng hủy đơn do không đủ điều kiện xuất kho."}
                </div>
            </div>

            <div class="mt-3 flex items-start gap-2.5 text-xs text-emerald-900 bg-emerald-50 border border-emerald-200 p-3 rounded-xl">
                <i class="fa-solid fa-circle-check text-emerald-600 text-sm mt-0.5"></i>
                <div class="leading-relaxed">
                    <b>Tiến trình hệ thống tự động:</b> Hệ thống Gốc Vườn đã gửi thông báo hủy đến khách hàng và kích hoạt quy trình hoàn tiền tự động theo chính sách sàn.
                </div>
            </div>
        </div>
    </div>
</div>

