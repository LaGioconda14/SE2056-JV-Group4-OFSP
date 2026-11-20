<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- 1. Modal Nhập Kho Lô Mới (Server-Rendered - 100% No-JS) -->
<c:if test="${param.action eq 'restock'}">
    <div id="modalRestock" class="fixed inset-0 bg-slate-900/50 backdrop-blur-xs flex items-center justify-center z-50 p-4">
        <!-- Bấm ra ngoài nền đen để đóng popup (thẻ <a> sạch, không cần JS) -->
        <a href="${pageContext.request.contextPath}/shop/inventory/batches" class="absolute inset-0 cursor-default" tabindex="-1" aria-label="Đóng popup"></a>

        <div class="bg-white rounded-3xl shadow-2xl w-full max-w-xl overflow-hidden border border-slate-100 relative z-10">
            <div class="flex items-center justify-between px-6 py-4 border-b border-slate-100">
                <div class="flex items-center gap-2.5">
                    <span class="w-8 h-8 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center font-bold"><i class="fa-solid fa-plus text-sm"></i></span>
                    <h3 class="text-base font-black text-slate-900">Nhập Kho Lô Nông Sản Mới</h3>
                </div>
                <a href="${pageContext.request.contextPath}/shop/inventory/batches" class="w-8 h-8 rounded-xl text-slate-400 hover:bg-slate-100 flex items-center justify-center text-decoration-none">
                    <i class="fa-solid fa-xmark text-sm"></i>
                </a>
            </div>

            <form action="${pageContext.request.contextPath}/shop/inventory/restock" method="POST" class="p-6 space-y-4">
                <c:choose>
                    <c:when test="${not empty selectedRestockVariant}">
                        <%-- Nhập cụ thể cho 1 biến thể --%>
                        <input type="hidden" name="variantId" value="${selectedRestockVariant.variantId}">
                        <div>
                            <label class="block text-xs font-bold text-slate-700 mb-1.5">SẢN PHẨM / BIẾN THỂ</label>
                            <input type="text" readonly value="${selectedRestockVariant.productName} - ${selectedRestockVariant.variantName} (${selectedRestockVariant.sku})" 
                                   class="w-full px-3.5 py-2.5 bg-slate-100 border border-slate-200 rounded-xl text-xs font-semibold text-slate-700 focus:outline-none">
                        </div>
                    </c:when>
                    <c:otherwise>
                        <%-- Nhập từ nút Header (chọn trong dropdown) --%>
                        <div>
                            <label class="block text-xs font-bold text-slate-700 mb-1.5">CHỌN MẶT HÀNG / BIẾN THỂ CẦN NHẬP</label>
                            <select name="variantId" required class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-800 focus:outline-none focus:border-emerald-500">
                                <option value="">-- Chọn mặt hàng nông sản --</option>
                                <c:forEach var="entry" items="${variantBatchMap}">
                                    <c:set var="firstBatch" value="${entry.value[0]}" />
                                    <option value="${entry.key}">
                                        ${firstBatch.productName} - ${firstBatch.variantName} (${firstBatch.sku})
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </c:otherwise>
                </c:choose>

                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1.5">MÃ LÔ HÀNG</label>
                        <input type="text" readonly value="Hệ thống tự sinh (LOT-...)" class="w-full px-3.5 py-2.5 bg-slate-100 border border-slate-200 rounded-xl text-xs font-mono font-bold text-slate-400 cursor-not-allowed">
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1.5">SỐ LƯỢNG NHẬP MỚI</label>
                        <input type="number" name="quantity" required min="1" placeholder="Ví dụ: 100" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-800 focus:outline-none focus:border-emerald-500">
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1.5">NGÀY THU HOẠCH</label>
                        <input type="date" name="harvestDate" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-700 focus:outline-none focus:border-emerald-500">
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1.5">HẠN SỬ DỤNG (BẮT BUỘC)</label>
                        <input type="date" name="expiryDate" required class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-700 focus:outline-none focus:border-emerald-500">
                    </div>
                </div>

                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1.5">GHI CHÚ NHẬP KHO</label>
                    <textarea name="note" rows="3" placeholder="Ghi chú thêm..." class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium text-slate-700 resize-none"></textarea>
                </div>

                <div class="flex items-center justify-end gap-3 pt-2">
                    <a href="${pageContext.request.contextPath}/shop/inventory/batches" class="px-5 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-bold text-decoration-none">
                        Hủy
                    </a>
                    <button type="submit" class="px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold shadow-sm">
                        Xác Nhận Tạo Lô Mới
                    </button>
                </div>
            </form>
        </div>
    </div>
</c:if>
