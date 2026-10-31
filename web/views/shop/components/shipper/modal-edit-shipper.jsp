<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div id="editModalBackdrop" class="modal-backdrop hidden" onclick="closeEditModal()"></div>
<div id="editShipperModal" class="modal-dialog hidden w-full max-w-lg bg-white rounded-2xl border border-slate-200 shadow-2xl">
    <div class="p-5 border-b border-slate-100 flex items-center justify-between">
        <div class="flex items-center gap-2.5">
            <div class="w-9 h-9 rounded-xl bg-blue-50 text-blue-700 flex items-center justify-center text-base font-bold border border-blue-200">
                <i class="fa-solid fa-pen-to-square"></i>
            </div>
            <div>
                <h3 class="text-sm font-black text-slate-900">Chỉnh Sửa Thông Tin Nhân Viên</h3>
                <p class="text-[11px] text-slate-400">Cập nhật thông tin phương tiện, thiết bị và trạng thái</p>
            </div>
        </div>
        <button type="button" onclick="closeEditModal()" class="w-8 h-8 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 flex items-center justify-center transition cursor-pointer">
            <i class="fa-solid fa-xmark text-sm"></i>
        </button>
    </div>

    <form action="${pageContext.request.contextPath}/shop/shippers" method="POST" class="p-5 space-y-4">
        <input type="hidden" name="action" value="edit">
        <input type="hidden" name="driverId" id="editDriverId">

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Họ và tên <span class="text-rose-500">*</span></label>
                <input type="text" name="fullName" id="editFullName" required class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500">
            </div>
            <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Số điện thoại <span class="text-rose-500">*</span></label>
                <input type="tel" name="phone" id="editPhone" required class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500">
            </div>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Loại phương tiện</label>
                <input type="text" name="vehicleType" id="editVehicleType" class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500">
            </div>
            <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Biển số xe</label>
                <input type="text" name="vehiclePlate" id="editVehiclePlate" class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500 uppercase">
            </div>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Thiết bị bảo quản lạnh</label>
                <input type="text" name="coldStorageType" id="editColdStorageType" class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500">
            </div>
            <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Trạng thái hoạt động</label>
                <select name="availabilityStatus" id="editAvailabilityStatus" class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500 bg-white">
                    <option value="AVAILABLE">Sẵn sàng nhận đơn</option>
                    <option value="BUSY">Đang đi giao hàng</option>
                    <option value="OFFLINE">Tạm nghỉ / Offline</option>
                </select>
            </div>
        </div>

        <div class="flex items-center justify-end gap-2 pt-2 border-t border-slate-100">
            <button type="button" onclick="closeEditModal()" class="px-4 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs transition cursor-pointer">
                Hủy
            </button>
            <button type="submit" class="px-4 py-2 rounded-xl bg-blue-600 hover:bg-blue-700 text-white font-extrabold text-xs transition shadow-2xs cursor-pointer flex items-center gap-1.5">
                <i class="fa-solid fa-check"></i>
                <span>Lưu Thay Đổi</span>
            </button>
        </div>
    </form>
</div>

