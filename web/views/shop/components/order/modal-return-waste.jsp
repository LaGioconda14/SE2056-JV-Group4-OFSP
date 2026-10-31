<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div id="returnWasteModalBackdrop" class="modal-backdrop hidden"></div>
<div id="returnWasteModal" class="modal-dialog hidden max-w-lg w-full">
    <div class="p-5 border-b border-slate-100 flex items-center justify-between">
        <div class="flex items-center gap-2.5">
            <div class="w-8 h-8 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center text-sm font-bold border border-rose-200">
                <i class="fa-solid fa-truck-ramp-box"></i>
            </div>
            <div>
                <h3 class="text-sm font-black text-slate-900">Báo Hỏng Do Vận Chuyển &amp; Đứt Chuỗi Lạnh</h3>
                <p class="text-[10px] text-slate-400">Ghi nhận vào sổ hao hụt giai đoạn TRANSIT_DAMAGE</p>
            </div>
        </div>
        <button type="button" id="btnCloseReturnWasteModal" class="w-7 h-7 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 flex items-center justify-center transition cursor-pointer">
            <i class="fa-solid fa-xmark text-sm"></i>
        </button>
    </div>

    <form action="${pageContext.request.contextPath}/shop/order-detail" method="POST" class="p-5 space-y-4">
        <input type="hidden" name="action" value="return_waste">
        <input type="hidden" name="code" value="${subOrder.subOrderCode}">

        <div>
            <label class="block text-xs font-bold text-slate-700 mb-2">
                1. Kiểm tra số lượng nông sản bị dập nát / thối rữa <span class="text-rose-500">*</span>
            </label>
            <div class="space-y-2">
                <c:forEach items="${subOrder.items}" var="it">
                    <div class="flex items-center justify-between gap-3 text-xs bg-slate-50 p-2.5 rounded-lg border border-slate-200">
                        <div class="min-w-0 flex-1">
                            <div class="font-bold text-slate-800 truncate">${it.productNameSnapshot}</div>
                            <div class="text-[11px] text-slate-500">Khách đặt: <b class="text-slate-800">${it.quantity} ${it.unit}</b></div>
                        </div>
                        <div class="flex items-center gap-2 shrink-0">
                            <label class="text-[11px] text-rose-700 font-bold whitespace-nowrap">Số lượng hỏng:</label>
                            <input type="number" name="wastedQty_${it.variantId}" min="0" max="${it.quantity}" value="${it.quantity}" 
                                   class="w-16 p-1.5 text-center text-xs font-black rounded-lg border border-rose-300 focus:outline-none focus:border-rose-600 bg-white text-rose-700">
                            <span class="text-[11px] text-slate-500 font-semibold">${it.unit}</span>
                        </div>
                    </div>
                </c:forEach>
            </div>
            <p class="text-[11px] text-slate-500 italic mt-1.5">
                * Phần bị hỏng sẽ được ghi vào sổ hao hụt để xem xét chế tài bồi thường của đơn vị vận chuyển. Nếu có quả còn ăn/bán được, số lượng đó sẽ tự động được hoàn lại kho.
            </p>
        </div>

        <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">
                2. Ghi chú chi tiết tình trạng hàng hoàn <span class="text-rose-500">*</span>
            </label>
            <textarea name="wasteNote" rows="3" required placeholder="Ghi chú chi tiết (VD: Đá gel tan hoàn toàn, thùng móp méo làm dâu tây bị dập nát 100%, không thể bán lại)..." class="w-full p-2.5 text-xs rounded-xl border border-slate-200 bg-white focus:outline-none focus:border-rose-500"></textarea>
        </div>

        <div class="flex items-center justify-end gap-2 pt-2 border-t border-slate-100">
            <button type="button" id="btnDismissReturnWasteModal" class="px-4 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs transition cursor-pointer">
                Đóng
            </button>
            <button type="submit" class="px-4 py-2 rounded-xl bg-rose-600 hover:bg-rose-700 text-white font-extrabold text-xs transition shadow-2xs cursor-pointer">
                Xác Nhận Tiêu Hủy
            </button>
        </div>
    </form>
</div>
