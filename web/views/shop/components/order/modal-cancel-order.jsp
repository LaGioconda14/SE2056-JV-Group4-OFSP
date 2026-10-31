<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div id="cancelModalBackdrop" class="modal-backdrop hidden"></div>
<div id="cancelOrderModal" class="modal-dialog hidden">
    <div class="p-5 border-b border-slate-100 flex items-center justify-between">
        <div class="flex items-center gap-2.5">
            <div class="w-8 h-8 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center text-sm font-bold border border-rose-200">
                <i class="fa-solid fa-triangle-exclamation"></i>
            </div>
            <div>
                <h3 class="text-sm font-black text-slate-900">Hủy Đơn Hàng Con #${subOrder.subOrderCode}</h3>
                <p class="text-[10px] text-slate-400">Nông sản không đủ tồn kho hoặc không đạt chuẩn tươi</p>
            </div>
        </div>
        <button type="button" id="btnCloseCancelModal" class="w-7 h-7 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 flex items-center justify-center transition cursor-pointer">
            <i class="fa-solid fa-xmark text-sm"></i>
        </button>
    </div>

    <form action="${pageContext.request.contextPath}/shop/order-detail" method="POST" class="p-5 space-y-4">
        <input type="hidden" name="action" value="cancel_sub_order">
        <input type="hidden" name="code" value="${subOrder.subOrderCode}">

        <div>
            <label class="block text-xs font-bold text-slate-700 mb-2">
                1. Phân loại lý do hủy đơn <span class="text-rose-500">*</span>
            </label>
            <div class="space-y-2">
                <label class="cancel-reason-option flex items-start gap-2.5 p-2.5 rounded-xl border border-slate-200 hover:border-rose-400 cursor-pointer transition is-selected">
                    <input type="radio" name="cancelReasonCategory" value="Nông sản không đạt chuẩn chất lượng (dập nát, thâm úng)" class="mt-0.5 text-rose-600" checked>
                    <div class="text-xs">
                        <div class="font-bold text-slate-800">Nông sản không đạt tiêu chuẩn chất lượng (Hàng hỏng)</div>
                        <div class="text-[11px] text-slate-400">Soi kiểm tra QC thấy hoa quả bị thâm úng, biến chất, sâu bệnh hoặc dập nát.</div>
                    </div>
                </label>
                <label class="cancel-reason-option flex items-start gap-2.5 p-2.5 rounded-xl border border-slate-200 hover:border-rose-400 cursor-pointer transition">
                    <input type="radio" name="cancelReasonCategory" value="Lý do khác" class="mt-0.5 text-rose-600">
                    <div class="text-xs">
                        <div class="font-bold text-slate-800">Lý do phát sinh khác (Quả còn tươi nguyên)</div>
                        <div class="text-[11px] text-slate-400">Khách đổi ý, đặt nhầm, hoặc không thể giao tới địa chỉ nhận.</div>
                    </div>
                </label>
            </div>
        </div>

        <div id="qcWasteBreakdown" class="p-3.5 rounded-xl bg-rose-50/70 border border-rose-200 space-y-3">
            <div class="flex items-center justify-between pb-2 border-b border-rose-200/60">
                <div class="text-xs font-bold text-rose-900 flex items-center gap-1.5">
                    <i class="fa-solid fa-scale-unbalanced text-rose-600"></i>
                    <span>Kiểm định số lượng hỏng thực tế</span>
                </div>
                <span class="text-[10px] text-rose-600 font-bold">Quả tốt còn lại sẽ tự hoàn vào kho bán</span>
            </div>
            <c:forEach items="${subOrder.items}" var="it">
                <div class="flex items-center justify-between gap-3 text-xs bg-white p-2.5 rounded-lg border border-rose-100 shadow-2xs">
                    <div class="min-w-0 flex-1">
                        <div class="font-bold text-slate-800 truncate">${it.productNameSnapshot}</div>
                        <div class="text-[11px] text-slate-500">Khách đặt mua: <b class="text-slate-800">${it.quantity} ${it.unit}</b></div>
                    </div>
                    <div class="flex items-center gap-2 shrink-0">
                        <label class="text-[11px] text-rose-700 font-bold whitespace-nowrap">Số lượng hỏng:</label>
                        <input type="number" name="wastedQty_${it.variantId}" min="0" max="${it.quantity}" value="${it.quantity}" 
                               class="w-16 p-1.5 text-center text-xs font-black rounded-lg border border-rose-300 focus:outline-none focus:border-rose-600 bg-rose-50/50 text-rose-700">
                        <span class="text-[11px] text-slate-500 font-semibold">${it.unit}</span>
                    </div>
                </div>
            </c:forEach>
        </div>

        <div id="restockNotice" class="hidden p-3 rounded-xl bg-blue-50 border border-blue-200 text-blue-900 text-xs flex items-start gap-2">
            <i class="fa-solid fa-rotate-left text-blue-600 mt-0.5 text-sm"></i>
            <div class="leading-relaxed">
                <b>Hoàn kho 100%:</b> Hoa quả còn tươi nguyên trong kho. Toàn bộ số lượng khách đặt sẽ được <b>cộng hoàn trả lại kho bán</b> ngay lập tức.
            </div>
        </div>

        <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">
                2. Ghi chú chi tiết cho khách hàng &amp; sàn <span class="text-rose-500">*</span>
            </label>
            <textarea name="cancelReasonNote" rows="3" required placeholder="Ghi chú chi tiết gửi khách hàng (VD: Lô dâu tây sáng nay về bị dập bề mặt do mưa, nhà vườn xin phép hủy đơn và hỗ trợ hoàn tiền)..." class="w-full p-2.5 text-xs rounded-xl border border-slate-200 bg-white focus:outline-none focus:border-rose-500"></textarea>
        </div>

        <div class="flex items-center justify-end gap-2 pt-2 border-t border-slate-100">
            <button type="button" id="btnDismissCancelModal" class="px-4 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs transition cursor-pointer">
                Đóng
            </button>
            <button type="submit" class="px-4 py-2 rounded-xl bg-rose-600 hover:bg-rose-700 text-white font-extrabold text-xs transition shadow-2xs cursor-pointer">
                Xác Nhận Hủy Đơn
            </button>
        </div>
    </form>
</div>
