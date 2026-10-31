<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<div class="form-section-card">
    <div class="form-section-header">
        <div class="flex items-center gap-3">
            <div class="section-icon-box bg-blue-50 text-blue-600">
                <i class="fa-solid fa-store"></i>
            </div>
            <div>
                <h2 class="text-sm font-bold text-slate-900 leading-tight">Biến thể, Định lượng & Kho hàng</h2>
                <p class="text-xs text-slate-400 mt-0.5">Thiết lập đơn vị tính giá bán và lượng tồn kho thực tế tại vườn</p>
            </div>
        </div>
        <span class="section-badge-pill price">GIÁ & KHO</span>
    </div>

    <div class="space-y-4">
        <div>
            <label class="form-label">Chọn đơn vị tính cơ sở <span class="req">*</span></label>
            <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 mt-1">
                <div class="unit-radio-card ${product.unit != null && product.unit.contains('Hộp') ? 'active' : ''}" onclick="selectUnit(this, 'Hộp (500g - 1kg)')">
                    <i class="fa-solid ${product.unit != null && product.unit.contains('Hộp') ? 'fa-circle-dot text-emerald-700' : 'fa-circle text-slate-400'} text-sm"></i>
                    <span>Hộp (500g - 1kg)</span>
                </div>
                <div class="unit-radio-card ${product.unit != null && product.unit.contains('Kg') ? 'active' : ''}" onclick="selectUnit(this, 'Kg (Kilogram)')">
                    <i class="fa-solid ${product.unit != null && product.unit.contains('Kg') ? 'fa-circle-dot text-emerald-700' : 'fa-circle text-slate-400'} text-sm"></i>
                    <span>Kg (Kilogram)</span>
                </div>
                <div class="unit-radio-card ${product.unit != null && (product.unit.contains('Quả') || product.unit.contains('Trái')) ? 'active' : ''}" onclick="selectUnit(this, 'Quả / Trái đơn')">
                    <i class="fa-solid ${product.unit != null && (product.unit.contains('Quả') || product.unit.contains('Trái')) ? 'fa-circle-dot text-emerald-700' : 'fa-circle text-slate-400'} text-sm"></i>
                    <span>Quả / Trái đơn</span>
                </div>
                <div class="unit-radio-card ${product.unit != null && product.unit.contains('Giỏ') ? 'active' : ''}" onclick="selectUnit(this, 'Giỏ quà biếu')">
                    <i class="fa-solid ${product.unit != null && product.unit.contains('Giỏ') ? 'fa-circle-dot text-emerald-700' : 'fa-circle text-slate-400'} text-sm"></i>
                    <span>Giỏ quà biếu</span>
                </div>
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
                <div class="form-label">
                    <span>Giá niêm yết (VNĐ) <span class="req">*</span></span>
                </div>
                <div class="relative">
                    <input type="number" step="1000" name="originalPrice" id="inputOrigPrice" required
                           value="<fmt:formatNumber value='${product.originalPrice}' pattern='#' groupingUsed='false'/>"
                           class="form-input font-bold text-slate-800 pr-8">
                    <span class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 font-bold text-xs">₫</span>
                </div>
            </div>

            <div>
                <div class="form-label">
                    <span>Giá bán / khuyến mãi (VNĐ)</span>
                </div>
                <div class="relative">
                    <input type="number" step="1000" name="price" id="inputSalePrice"
                           value="<fmt:formatNumber value='${product.price}' pattern='#' groupingUsed='false'/>"
                           class="form-input font-bold text-orange-600 pr-8">
                    <span class="absolute right-3 top-1/2 -translate-y-1/2 text-orange-400 font-bold text-xs">₫</span>
                </div>
            </div>

            <div>
                <div class="form-label">
                    <span>Số lượng tồn kho thực tế <span class="req">*</span></span>
                </div>
                <div class="relative">
                    <input type="number" name="stockQuantity" id="inputStockQty" required
                           value="${product.stockQuantity}"
                           class="form-input font-bold text-slate-800 pr-14">
                    <span id="unitStockSuffix" class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 font-medium text-xs">
                        ${not empty product.unit ? product.unit : 'Hộp'}
                    </span>
                </div>
            </div>
        </div>

        <div class="warning-threshold-box">
            <div class="flex items-center gap-3">
                <div class="w-8 h-8 rounded-full bg-amber-100 text-amber-700 flex items-center justify-center shrink-0">
                    <i class="fa-solid fa-triangle-exclamation text-sm"></i>
                </div>
                <div>
                    <div class="text-xs font-bold text-amber-900 leading-tight">Cảnh báo tồn kho tối thiểu</div>
                    <p class="text-[11px] text-amber-700 mt-0.5">Hệ thống sẽ tự động bật trạng thái "Sắp hết hàng" khi kho chạm ngưỡng</p>
                </div>
            </div>
            <div class="flex items-center gap-2 shrink-0">
                <input type="number" name="lowStockThreshold"
                       value="${product.lowStockThreshold > 0 ? product.lowStockThreshold : 15}"
                       class="w-16 text-center font-bold py-1.5 px-2 text-xs border border-amber-300 rounded-lg bg-white">
                <span id="unitThresholdSuffix" class="text-xs font-semibold text-slate-600">
                    ${not empty product.unit ? product.unit : 'Hộp'}
                </span>
            </div>
        </div>
    </div>
</div>

