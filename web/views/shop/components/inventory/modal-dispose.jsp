<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- 3. Modal HỦY LÔ (Server-Rendered - 100% No-JS) -->
<c:if test="${param.action eq 'dispose' and not empty selectedDisposeBatch}">
    <div id="modalDispose" class="fixed inset-0 bg-slate-900/50 backdrop-blur-xs flex items-center justify-center z-50 p-4">
        <!-- Bấm ra ngoài nền đen để đóng popup (thẻ <a> sạch, không cần JS) -->
        <a href="${pageContext.request.contextPath}/shop/inventory/batches" class="absolute inset-0 cursor-default" tabindex="-1" aria-label="Đóng popup"></a>

        <div class="bg-white rounded-3xl shadow-2xl w-full max-w-xl overflow-hidden border border-slate-100 relative z-10">
            <div class="flex items-center justify-between px-6 py-4 border-b border-slate-100">
                <div class="flex items-center gap-2.5">
                    <span class="w-8 h-8 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center font-bold"><i class="fa-solid fa-ban text-sm"></i></span>
                    <h3 class="text-base font-black text-slate-900">Xuất Hủy Trọn Gói Lô Hàng</h3>
                </div>
                <a href="${pageContext.request.contextPath}/shop/inventory/batches" class="w-8 h-8 rounded-xl text-slate-400 hover:bg-slate-100 flex items-center justify-center text-decoration-none">
                    <i class="fa-solid fa-xmark text-sm"></i>
                </a>
            </div>

            <form action="${pageContext.request.contextPath}/shop/inventory/dispose" method="POST" class="p-6 space-y-4">
                <input type="hidden" name="variantId" value="${selectedDisposeBatch.variantId}">
                <input type="hidden" name="batchId" value="${selectedDisposeBatch.batchId}">

                <div class="px-3.5 py-3 bg-rose-50 border border-rose-200 rounded-xl text-[11px] font-semibold text-rose-700 leading-relaxed">
                    Toàn bộ số lượng còn lại của lô sẽ về 0 và bị trừ khỏi tồn kho của sản phẩm. Thao tác này không thể hoàn tác.
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1.5">SẢN PHẨM</label>
                        <input type="text" readonly value="${selectedDisposeBatch.productName} (${selectedDisposeBatch.sku})" 
                               class="w-full px-3.5 py-2.5 bg-slate-100 border border-slate-200 rounded-xl text-xs font-semibold text-slate-600 cursor-not-allowed">
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1.5">MÃ LÔ HÀNG</label>
                        <input type="text" readonly value="${selectedDisposeBatch.batchCode}" 
                               class="w-full px-3.5 py-2.5 bg-slate-100 border border-slate-200 rounded-xl text-xs font-bold text-slate-600 cursor-not-allowed">
                    </div>
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1.5">SỐ LƯỢNG HỦY TOÀN BỘ LÔ</label>
                    <input type="text" readonly value="${selectedDisposeBatch.currentQuantity} đơn vị" 
                           class="w-full px-3.5 py-2.5 bg-rose-50 border border-rose-200 text-rose-700 rounded-xl text-xs font-bold cursor-not-allowed">
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1.5">LÝ DO XUẤT HỦY LÔ</label>
                    <select name="reason" required class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-700 focus:outline-none focus:border-rose-500">
                        <option value="EXPIRED">Hàng hết hạn sử dụng (Hủy toàn bộ lô)</option>
                        <option value="DAMAGED">Trái cây bị dập nát, hư hỏng cơ học</option>
                        <option value="STORAGE_ISSUE">Sự cố bảo quản kho mát / mất điện đột xuất</option>
                        <option value="QUALITY_FAIL">Không đạt tiêu chuẩn ATVSTP kiểm định</option>
                        <option value="LOST">Kiểm kê thất thoát kho</option>
                    </select>
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1.5">CHI TIẾT MÔ TẢ THÊM</label>
                    <textarea name="description" rows="3" placeholder="Ghi chú cụ thể..." class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium text-slate-700 resize-none"></textarea>
                </div>
                <div class="flex items-center justify-end gap-3 pt-2">
                    <a href="${pageContext.request.contextPath}/shop/inventory/batches" class="px-5 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-bold text-decoration-none">
                        Hủy
                    </a>
                    <button type="submit" class="px-5 py-2.5 bg-rose-600 hover:bg-rose-700 text-white rounded-xl text-xs font-bold shadow-sm">
                        Xác Nhận Hủy Lô
                    </button>
                </div>
            </form>
        </div>
    </div>
</c:if>
