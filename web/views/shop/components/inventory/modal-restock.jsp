<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div id="restockModal" class="modal-overlay hidden">
    <div class="modal-box">
        <div class="flex items-center justify-between pb-3 border-b border-slate-100">
            <div class="flex items-center gap-2 text-slate-900">
                <i class="fa-solid fa-boxes-packing text-emerald-700 text-base"></i>
                <h3 class="font-black text-base">Nhập Kho Nhanh Nông Sản (Restock)</h3>
            </div>
            <button onclick="closeRestockModal()" class="text-slate-400 hover:text-slate-600 text-lg">&times;</button>
        </div>
        
        <form action="${pageContext.request.contextPath}/shop/inventory" method="POST" class="mt-4 space-y-4">
            <input type="hidden" name="action" value="restock">
            
            <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Mặt hàng cần nhập thêm</label>
                <select id="modalVariantSelect" name="variantId" class="w-full p-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:ring-2 focus:ring-emerald-500">
                    <c:forEach var="item" items="${listItems}">
                        <option value="${item.variantId}">${item.productName} (${item.sku}) - Hiện còn: ${item.currentQuantity} ${item.unit}</option>
                    </c:forEach>
                </select>
            </div>

            <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Số lượng thu hoạch bổ sung</label>
                <div class="flex items-center gap-2">
                    <input type="number" name="quantity" min="1" max="1000" value="20" required class="flex-1 p-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold focus:outline-none focus:ring-2 focus:ring-emerald-500">
                    <span id="modalUnitLabel" class="text-xs font-bold text-slate-500">đơn vị</span>
                </div>
            </div>

            <div class="p-3 bg-emerald-50 border border-emerald-100 rounded-xl text-[11px] text-emerald-800 flex items-start gap-2">
                <i class="fa-solid fa-circle-info text-emerald-600 mt-0.5"></i>
                <span>Số lượng nhập mới sẽ tự động cập nhật vào đợt hái trong ngày và giải tỏa cảnh báo nguy cấp.</span>
            </div>

            <div class="flex items-center justify-end gap-2 pt-2">
                <button type="button" onclick="closeRestockModal()" class="px-4 py-2 rounded-xl border border-slate-200 text-xs font-bold text-slate-600 hover:bg-slate-50">Hủy</button>
                <button type="submit" class="px-5 py-2 rounded-xl bg-[#166534] text-white text-xs font-bold hover:bg-[#14532d] shadow-sm">Xác nhận nhập kho</button>
            </div>
        </form>
    </div>
</div>
