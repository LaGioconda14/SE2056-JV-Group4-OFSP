<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div id="discountModal" class="modal-overlay hidden">
    <div class="modal-box">
        <div class="flex items-center justify-between pb-3 border-b border-slate-100">
            <div class="flex items-center gap-2 text-slate-900">
                <i class="fa-solid fa-bolt text-orange-600 text-base"></i>
                <h3 class="font-black text-base">Đề Xuất Xả Tươi Nông Sản</h3>
            </div>
            <button onclick="closeDiscountModal()" class="text-slate-400 hover:text-slate-600 text-lg">&times;</button>
        </div>
        
        <form action="${pageContext.request.contextPath}/shop/inventory" method="POST" class="mt-4 space-y-4">
            <input type="hidden" name="action" value="discount">
            <input type="hidden" id="discountVariantId" name="variantId" value="">
            
            <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Mặt hàng áp dụng xả tươi</label>
                <input type="text" id="discountProductName" readonly class="w-full p-2.5 bg-slate-100 border border-slate-200 rounded-xl text-xs font-bold text-slate-800">
            </div>

            <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Mức giảm giá trực tiếp (%)</label>
                <select name="discountPercent" class="w-full p-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-orange-700">
                    <option value="10">Giảm 10% (Ưu tiên xả trong 12h)</option>
                    <option value="15" selected>Giảm 15% (Đề xuất tối ưu cho quả 50h tuổi)</option>
                    <option value="20">Giảm 20% (Xả gấp thu hồi vốn)</option>
                </select>
            </div>

            <div class="flex items-center justify-end gap-2 pt-2">
                <button type="button" onclick="closeDiscountModal()" class="px-4 py-2 rounded-xl border border-slate-200 text-xs font-bold text-slate-600 hover:bg-slate-50">Hủy</button>
                <button type="submit" class="px-5 py-2 rounded-xl bg-[#ea580c] text-white text-xs font-bold hover:bg-[#c2410c] shadow-sm">Áp dụng giảm giá</button>
            </div>
        </form>
    </div>
</div>
