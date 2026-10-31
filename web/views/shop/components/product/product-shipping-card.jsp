<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div class="form-section-card">
    <div class="form-section-header">
        <div class="flex items-center gap-3">
            <div class="section-icon-box bg-amber-50 text-amber-700">
                <i class="fa-solid fa-truck-ramp-box"></i>
            </div>
            <div>
                <h2 class="text-sm font-bold text-slate-900 leading-tight">Tiêu chuẩn bảo quản &amp; Giao nhận cam kết</h2>
                <p class="text-xs text-slate-400 mt-0.5">Đảm bảo độ tươi ngon nguyên bản khi đến tay người tiêu dùng</p>
            </div>
        </div>
        <span class="section-badge-pill shipping">VẬN CHUYỂN</span>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <label class="shipping-guarantee-card active">
            <input type="checkbox" name="shippingStandard" value="Chuỗi Lạnh FreshCold 2H" checked class="mt-1 rounded text-blue-600 focus:ring-0">
            <div>
                <div class="flex items-center gap-1.5 text-xs font-bold text-slate-900">
                    <i class="fa-solid fa-snowflake text-blue-600"></i>
                    <span>Chuỗi Lạnh FreshCold 2H</span>
                </div>
                <p class="text-[11px] text-slate-500 mt-1 leading-relaxed">
                    Vận chuyển bằng xe tải lạnh chuyên dụng duy trì 4°C - 10°C liên tục từ vườn đến kho phân phối nội đô.
                </p>
            </div>
        </label>

        <label class="shipping-guarantee-card active">
            <input type="checkbox" name="shippingStandard" value="Hái tươi trong ngày" checked class="mt-1 rounded text-blue-600 focus:ring-0">
            <div>
                <div class="flex items-center gap-1.5 text-xs font-bold text-slate-900">
                    <i class="fa-solid fa-leaf text-emerald-600"></i>
                    <span>Hái tươi trong ngày (Same-Day Harvest)</span>
                </div>
                <p class="text-[11px] text-slate-500 mt-1 leading-relaxed">
                    Nông sản chỉ được thu hoạch vào sáng sớm (trước 6h AM) ngay trong ngày giao đơn hàng cho khách.
                </p>
            </div>
        </label>
    </div>
</div>

