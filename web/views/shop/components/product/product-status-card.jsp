<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="form-section-card">
    <div class="form-section-header">
        <div class="flex items-center gap-3">
            <div class="section-icon-box bg-emerald-50 text-emerald-700">
                <i class="fa-solid fa-toggle-on"></i>
            </div>
            <div>
                <h2 class="text-sm font-bold text-slate-900 leading-tight">Trạng thái kinh doanh & Phân phối</h2>
                <p class="text-xs text-slate-400 mt-0.5">Quyết định hiển thị sản phẩm trên sàn mua sắm</p>
            </div>
        </div>
        <span class="section-badge-pill">TRẠNG THÁI</span>
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <label class="border ${product.active ? 'border-emerald-600 bg-emerald-50/40' : 'border-slate-200 bg-white'} rounded-xl p-4 flex items-start gap-3 cursor-pointer transition"
               onclick="setStatus('active', this)">
            <input type="radio" name="statusOption" value="active" ${product.active ? 'checked' : ''} class="mt-1 text-emerald-600 focus:ring-0">
            <div>
                <div class="font-bold text-xs text-slate-900 flex items-center gap-1.5">
                    <span class="w-2 h-2 rounded-full bg-emerald-500"></span>
                    <span>Đang mở bán công khai</span>
                </div>
                <p class="text-[11px] text-slate-500 mt-1 leading-relaxed">
                    Nông sản hiển thị trên toàn sàn giao dịch. Khách hàng có thể tìm kiếm và đặt mua ngay.
                </p>
            </div>
        </label>

        <label class="border ${!product.active ? 'border-amber-500 bg-amber-50/40' : 'border-slate-200 bg-white'} rounded-xl p-4 flex items-start gap-3 cursor-pointer transition"
               onclick="setStatus('hidden', this)">
            <input type="radio" name="statusOption" value="hidden" ${!product.active ? 'checked' : ''} class="mt-1 text-amber-600 focus:ring-0">
            <div>
                <div class="font-bold text-xs text-slate-900 flex items-center gap-1.5">
                    <span class="w-2 h-2 rounded-full bg-slate-400"></span>
                    <span>Tạm ẩn kinh doanh</span>
                </div>
                <p class="text-[11px] text-slate-500 mt-1 leading-relaxed">
                    Tạm ẩn khỏi danh mục mua sắm, khách hàng không thấy sản phẩm. Dữ liệu kho vẫn được lưu trữ.
                </p>
            </div>
        </label>
    </div>
</div>

