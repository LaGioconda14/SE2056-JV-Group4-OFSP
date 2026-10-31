<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div id="wasteModalBackdrop" class="waste-modal-backdrop">
    <div class="waste-modal-dialog">
        <div class="p-5 border-b border-slate-100 flex items-center justify-between">
            <div class="flex items-center gap-2.5">
                <div class="w-8 h-8 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center text-sm font-bold border border-rose-200">
                    <i class="fa-solid fa-trash-can"></i>
                </div>
                <div>
                    <h3 class="text-sm font-black text-slate-900">Báo Tiêu Hủy Nông Sản Kho Lạnh</h3>
                    <p class="text-[10px] text-slate-400">Trừ trực tiếp số lượng tồn kho và ghi nhận chi phí hao hụt</p>
                </div>
            </div>
            <button type="button" id="btnCloseManualWasteModal" class="w-7 h-7 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 flex items-center justify-center transition cursor-pointer">
                <i class="fa-solid fa-xmark text-sm"></i>
            </button>
        </div>

        <form id="formManualWaste" action="${pageContext.request.contextPath}/shop/waste" method="POST" class="p-5 space-y-4">
            <input type="hidden" name="action" value="manual_waste">

            <div>
                <label for="selectVariantWaste" class="block text-xs font-bold text-slate-700 mb-1.5">
                    1. Chọn nông sản / biến thể cần tiêu hủy: <span class="text-rose-500">*</span>
                </label>
                <select name="variantId" id="selectVariantWaste" required class="w-full p-2.5 text-xs rounded-xl border border-slate-300 bg-white focus:outline-none focus:border-rose-500 font-medium">
                    <option value="">-- Chọn một sản phẩm trong kho --</option>
                    <c:forEach items="${variants}" var="v">
                        <option value="${v.variantId}" data-stock="${v.stockQuantity}" data-unit="${v.unit}" data-price="${v.price}">
                            ${v.productName} - ${v.variantName} [Tồn kho: ${v.stockQuantity} ${v.unit}]
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div class="grid grid-cols-2 gap-3">
                <div>
                    <label for="inputWasteQuantity" class="block text-xs font-bold text-slate-700 mb-1.5">
                        2. Số lượng tiêu hủy: <span class="text-rose-500">*</span>
                    </label>
                    <div class="relative">
                        <input type="number" name="quantity" id="inputWasteQuantity" min="1" required placeholder="0" class="w-full p-2.5 text-xs rounded-xl border border-slate-300 bg-white focus:outline-none focus:border-rose-500 font-bold text-rose-600">
                        <span id="textUnitLabel" class="absolute right-3 top-2.5 text-xs font-bold text-slate-400">kg</span>
                    </div>
                </div>

                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1.5">Tồn kho khả dụng:</label>
                    <div class="p-2.5 rounded-xl bg-slate-50 border border-slate-200 text-xs font-black text-slate-800 flex items-center justify-between">
                        <span id="textAvailableStock">0</span>
                        <span class="text-[11px] font-normal text-slate-400">trong kho</span>
                    </div>
                </div>
            </div>

            <div>
                <label for="textareaReasonNote" class="block text-xs font-bold text-slate-700 mb-1.5">
                    3. Lý do hoa quả bị hỏng / thâm úng: <span class="text-rose-500">*</span>
                </label>
                <textarea name="reasonNote" id="textareaReasonNote" rows="3" required placeholder="Mô tả hiện trạng (VD: Nho bị thâm đốm do đứt lạnh kho bảo ôn, dâu tây chín quá độ bị dập bề mặt)..." class="w-full p-2.5 text-xs rounded-xl border border-slate-300 bg-white focus:outline-none focus:border-rose-500"></textarea>
            </div>

            <div class="p-3 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 text-xs flex items-start gap-2">
                <i class="fa-solid fa-triangle-exclamation text-amber-600 mt-0.5 text-sm shrink-0"></i>
                <div class="leading-relaxed">
                    <b>Lưu ý toàn vẹn kho:</b> Sau khi xác nhận, số lượng tồn kho của biến thể này sẽ bị <b>giảm trừ ngay lập tức</b> và được ghi nhận vào báo cáo tài chính hao hụt.
                </div>
            </div>

            <div class="flex items-center justify-end gap-2 pt-2 border-t border-slate-100">
                <button type="button" id="btnCancelManualWasteModal" class="px-4 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs transition cursor-pointer">
                    Hủy bỏ
                </button>
                <button type="submit" class="px-4 py-2 rounded-xl bg-rose-600 hover:bg-rose-700 text-white font-extrabold text-xs transition shadow-sm cursor-pointer">
                    Xác Nhận Tiêu Hủy
                </button>
            </div>
        </form>
    </div>
</div>
