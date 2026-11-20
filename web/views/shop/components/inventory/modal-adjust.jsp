<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- 2. Modal TRỪ HÀNG (Server-Rendered - 100% No-JS) -->
<c:if test="${param.action eq 'adjust'}">
    <div id="modalAdjust" class="fixed inset-0 bg-slate-900/50 backdrop-blur-xs flex items-center justify-center z-50 p-4">
        <!-- Bấm ra ngoài nền đen để đóng popup (thẻ <a> sạch, không cần JS) -->
        <a href="${pageContext.request.contextPath}/shop/inventory/batches" class="absolute inset-0 cursor-default" tabindex="-1" aria-label="Đóng popup"></a>

        <div class="bg-white rounded-3xl shadow-2xl w-full max-w-xl overflow-hidden border border-slate-100 relative z-10">
            <div class="flex items-center justify-between px-6 py-4 border-b border-slate-100">
                <div class="flex items-center gap-2.5">
                    <span class="w-8 h-8 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center font-bold"><i class="fa-solid fa-minus text-sm"></i></span>
                    <h3 class="text-base font-black text-slate-900">Trừ Hao Hụt Kho</h3>
                </div>
                <a href="${pageContext.request.contextPath}/shop/inventory/batches" class="w-8 h-8 rounded-xl text-slate-400 hover:bg-slate-100 flex items-center justify-center text-decoration-none">
                    <i class="fa-solid fa-xmark text-sm"></i>
                </a>
            </div>

            <form action="${pageContext.request.contextPath}/shop/inventory/adjust" method="POST" class="p-6 space-y-4">
                <c:choose>
                    <c:when test="${not empty selectedAdjustBatch}">
                        <%-- Đã chọn cụ thể 1 lô hàng từ bảng --%>
                        <input type="hidden" name="variantId" value="${selectedAdjustBatch.variantId}">
                        <input type="hidden" name="batchId" value="${selectedAdjustBatch.batchId}">

                        <div class="grid grid-cols-2 gap-4">
                            <div>
                                <label class="block text-xs font-bold text-slate-700 mb-1.5">SẢN PHẨM</label>
                                <input type="text" readonly value="${selectedAdjustBatch.productName} (${selectedAdjustBatch.variantName})" 
                                       class="w-full px-3.5 py-2.5 bg-slate-100 border border-slate-200 rounded-xl text-xs font-semibold text-slate-600 cursor-not-allowed">
                            </div>
                            <div>
                                <label class="block text-xs font-bold text-slate-700 mb-1.5">MÃ LÔ HÀNG</label>
                                <input type="text" readonly value="${selectedAdjustBatch.batchCode}" 
                                       class="w-full px-3.5 py-2.5 bg-slate-100 border border-slate-200 rounded-xl text-xs font-bold text-slate-600 cursor-not-allowed">
                            </div>
                        </div>

                        <div class="grid grid-cols-2 gap-4">
                            <div>
                                <label class="block text-xs font-bold text-slate-700 mb-1.5">TỒN KHO LÔ HIỆN TẠI</label>
                                <input type="text" readonly value="${selectedAdjustBatch.currentQuantity} đơn vị" 
                                       class="w-full px-3.5 py-2.5 bg-slate-100 border border-slate-200 rounded-xl text-xs font-bold text-slate-600 cursor-not-allowed">
                            </div>
                            <div>
                                <label class="block text-xs font-bold text-slate-700 mb-1.5">SỐ LƯỢNG GIẢM</label>
                                <input type="number" name="deductQuantity" required min="1" max="${selectedAdjustBatch.currentQuantity}" placeholder="Số lượng trừ" 
                                       class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-800 focus:outline-none focus:border-amber-500">
                            </div>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <%-- Mở từ nút trên Header: Hiển thị dropdown chọn lô --%>
                        <div>
                            <label class="block text-xs font-bold text-slate-700 mb-1.5">CHỌN LÔ HÀNG CẦN TRỪ HAO HỤT</label>
                            <select name="batchId" required class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-800 focus:outline-none focus:border-amber-500">
                                <option value="">-- Chọn lô hàng (Mặt hàng - Lô - Tồn kho) --</option>
                                <c:forEach var="entry" items="${variantBatchMap}">
                                    <c:forEach var="b" items="${entry.value}">
                                        <c:if test="${b.currentQuantity > 0}">
                                            <option value="${b.batchId}">
                                                ${b.productName} [${b.variantName}] - Lô ${b.batchCode} (Còn: ${b.currentQuantity})
                                            </option>
                                        </c:if>
                                    </c:forEach>
                                </c:forEach>
                            </select>
                        </div>

                        <div>
                            <label class="block text-xs font-bold text-slate-700 mb-1.5">SỐ LƯỢNG GIẢM</label>
                            <input type="number" name="deductQuantity" required min="1" placeholder="Số lượng trừ" 
                                   class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-800 focus:outline-none focus:border-amber-500">
                        </div>
                    </c:otherwise>
                </c:choose>

                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1.5">LÝ DO TRỪ HÀNG</label>
                    <select name="reason" required class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-700 focus:outline-none focus:border-amber-500">
                        <option value="">-- Chọn lý do --</option>
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
                    <button type="submit" class="px-5 py-2.5 bg-amber-600 hover:bg-amber-700 text-white rounded-xl text-xs font-bold shadow-sm">
                        Xác Nhận Trừ Kho
                    </button>
                </div>
            </form>
        </div>
    </div>
</c:if>
