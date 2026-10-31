<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div id="createModalBackdrop" class="modal-backdrop hidden" onclick="closeCreateModal()"></div>
<div id="createShipperModal" class="modal-dialog hidden w-full max-w-lg bg-white rounded-2xl border border-slate-200 shadow-2xl">
    <div class="p-5 border-b border-slate-100 flex items-center justify-between">
        <div class="flex items-center gap-2.5">
            <div class="w-9 h-9 rounded-xl bg-emerald-50 text-emerald-700 flex items-center justify-center text-base font-bold border border-emerald-200">
                <i class="fa-solid fa-user-plus"></i>
            </div>
            <div>
                <h3 class="text-sm font-black text-slate-900">Đăng Ký Tài Khoản Shipper Cho Shop</h3>
                <p class="text-[11px] text-slate-400">Tạo tài khoản và hồ sơ nhân viên giao hàng thuộc sự quản lý của Shop</p>
            </div>
        </div>
        <button type="button" onclick="closeCreateModal()" class="w-8 h-8 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 flex items-center justify-center transition cursor-pointer">
            <i class="fa-solid fa-xmark text-sm"></i>
        </button>
    </div>

    <form action="${pageContext.request.contextPath}/shop/shippers" method="POST" class="p-5 space-y-4">
        <input type="hidden" name="action" value="create">

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Họ và tên tài xế <span class="text-rose-500">*</span></label>
                <input type="text" name="fullName" id="createFullName" required placeholder="VD: Nguyễn Văn Nam" class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500">
            </div>
            <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Số điện thoại <span class="text-rose-500">*</span></label>
                <input type="tel" name="phone" id="createPhone" required placeholder="VD: 0912345678" class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500">
            </div>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Email đăng nhập <span class="text-rose-500">*</span></label>
                <input type="email" name="email" id="createEmail" required placeholder="VD: shipper.nam@dalatfarm.vn" class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500">
            </div>
            <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Mật khẩu khởi tạo <span class="text-rose-500">*</span></label>
                <input type="text" name="password" id="createPassword" value="123456" required class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500" placeholder="Mặc định: 123456">
            </div>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Loại phương tiện <span class="text-rose-500">*</span></label>
                <select name="vehicleType" id="createVehicleType" class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500 bg-white">
                    <option value="Xe máy chuyên dụng FreshBox">Xe máy chuyên dụng FreshBox</option>
                    <option value="Xe máy có thùng giữ nhiệt FreshFruit">Xe máy có thùng giữ nhiệt FreshFruit</option>
                    <option value="Xe tải lạnh chuyên dụng 1.25 tấn">Xe tải lạnh chuyên dụng 1.25 tấn</option>
                    <option value="Xe tải bảo ôn 2.5 tấn">Xe tải bảo ôn 2.5 tấn</option>
                    <option value="Xe bán tải lạnh">Xe bán tải lạnh</option>
                </select>
            </div>
            <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Biển số xe <span class="text-rose-500">*</span></label>
                <input type="text" name="vehiclePlate" id="createVehiclePlate" required placeholder="VD: 29-F1 888.88" class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500 uppercase">
            </div>
        </div>

        <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">Thiết bị bảo quản lạnh</label>
            <input type="text" name="coldStorageType" id="createColdStorageType" value="Thùng giữ nhiệt FreshBox 2-5°C" class="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-emerald-500">
        </div>

        <div class="p-3 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-900 text-xs flex items-start gap-2">
            <i class="fa-solid fa-circle-info text-emerald-600 mt-0.5 text-sm shrink-0"></i>
            <div class="leading-relaxed">
                <b>Quyền hạn:</b> Sau khi đăng ký, tài khoản Shipper sẽ thuộc quyền quản lý trực tiếp của Shop. Shipper có thể dùng Email và Mật khẩu để đăng nhập nhận đơn giao hàng.
            </div>
        </div>

        <div class="flex items-center justify-end gap-2 pt-2 border-t border-slate-100">
            <button type="button" onclick="closeCreateModal()" class="px-4 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs transition cursor-pointer">
                Hủy
            </button>
            <button type="submit" class="px-4 py-2 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white font-extrabold text-xs transition shadow-2xs cursor-pointer flex items-center gap-1.5">
                <i class="fa-solid fa-user-plus"></i>
                <span>Đăng Ký Shipper</span>
            </button>
        </div>
    </form>
</div>

