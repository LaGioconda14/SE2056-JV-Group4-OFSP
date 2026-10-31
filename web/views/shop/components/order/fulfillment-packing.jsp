<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<div class="bg-white rounded-2xl border border-slate-200 p-6 shadow-xs">
    <div class="flex items-center justify-between pb-4 border-b border-slate-100">
        <div class="flex items-center gap-2.5">
            <div class="w-8 h-8 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center text-sm font-bold">
                <i class="fa-solid fa-boxes-packing"></i>
            </div>
            <h2 class="text-base font-extrabold text-slate-900">Danh sách kiểm tra</h2>
        </div>
        <span id="qcProgressBadge" class="px-3 py-1 rounded-full bg-blue-50 text-blue-700 font-bold text-xs border border-blue-200/60 transition-all">
            Bắt buộc hoàn thành <span id="qcCount">0</span>/4
        </span>
    </div>

    <form id="formReadyToShip" action="${pageContext.request.contextPath}/shop/order-detail" method="POST" class="mt-4 space-y-4">
        <input type="hidden" name="action" value="ready_to_ship">
        <input type="hidden" name="code" value="${subOrder.subOrderCode}">

        <div class="space-y-2.5">
            <label class="qc-check-label flex items-center gap-3 p-3 rounded-xl border border-slate-200 bg-white hover:border-emerald-400 transition cursor-pointer select-none">
                <input type="checkbox" class="qc-check w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500 border-slate-300">
                <span class="text-xs font-semibold text-slate-800">Đã kiểm tra đúng sản phẩm và số lượng</span>
            </label>
            <label class="qc-check-label flex items-center gap-3 p-3 rounded-xl border border-slate-200 bg-white hover:border-emerald-400 transition cursor-pointer select-none">
                <input type="checkbox" class="qc-check w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500 border-slate-300">
                <span class="text-xs font-semibold text-slate-800">Đã kiểm tra chất lượng trái cây</span>
            </label>
            <label class="qc-check-label flex items-center gap-3 p-3 rounded-xl border border-slate-200 bg-white hover:border-emerald-400 transition cursor-pointer select-none">
                <input type="checkbox" class="qc-check w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500 border-slate-300">
                <span class="text-xs font-semibold text-slate-800">Đã chuẩn bị bao bì phù hợp</span>
            </label>
            <label class="qc-check-label flex items-center gap-3 p-3 rounded-xl border border-slate-200 bg-white hover:border-emerald-400 transition cursor-pointer select-none">
                <input type="checkbox" class="qc-check w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500 border-slate-300">
                <span class="text-xs font-semibold text-slate-800">Đã đáp ứng yêu cầu bảo quản của đơn</span>
            </label>
        </div>

        <c:choose>
            <c:when test="${not empty shopShippers}">
                <div class="p-3.5 bg-slate-50 rounded-xl border border-slate-200">
                    <label for="driverUserIdSelect" class="block text-xs font-bold text-slate-700 mb-1.5">
                        <i class="fa-solid fa-motorcycle text-emerald-600 mr-1"></i> Phân công nhân viên giao hàng của Shop: <span class="text-rose-500">*</span>
                    </label>
                    <select name="driverUserId" id="driverUserIdSelect" required class="w-full p-2.5 text-xs rounded-lg border border-slate-300 bg-white focus:outline-none focus:border-emerald-500">
                        <option value="">-- Chọn 1 nhân viên giao hàng của Shop --</option>
                        <c:forEach items="${shopShippers}" var="shp">
                            <option value="${shp.userId}" ${shp.userId eq subOrder.driverId ? 'selected' : ''}>
                                ${shp.fullName} (${shp.phone}) - ${shp.licensePlate} [${shp.availabilityLabel}]
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </c:when>
            <c:otherwise>
                <div class="p-3.5 bg-amber-50 rounded-xl border border-amber-200 text-amber-900 text-xs">
                    <div class="flex items-center gap-2 font-bold mb-1">
                        <i class="fa-solid fa-triangle-exclamation text-amber-600"></i>
                        <span>Shop chưa có nhân viên giao hàng</span>
                    </div>
                    <p class="text-[11px] text-amber-700 leading-relaxed mb-2">
                        Để chỉ định người giao đơn hoa quả, vui lòng thêm hoặc đăng ký tài khoản cho nhân viên giao hàng của Shop.
                    </p>
                    <a href="${pageContext.request.contextPath}/shop/shippers" target="_blank" class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-emerald-700 hover:bg-emerald-800 text-white font-bold text-[11px] transition">
                        <i class="fa-solid fa-user-plus"></i> Thêm nhân viên giao hàng ngay
                    </a>
                </div>
            </c:otherwise>
        </c:choose>

        <button type="submit" id="btnFinishPacking" disabled class="w-full py-3 px-4 rounded-xl bg-slate-200 text-slate-400 font-extrabold text-sm transition shadow-sm flex items-center justify-center gap-2 cursor-not-allowed">
            <i class="fa-solid fa-box-check"></i> Hoàn tất đóng gói &amp; Báo sẵn sàng giao
        </button>
    </form>
</div>

