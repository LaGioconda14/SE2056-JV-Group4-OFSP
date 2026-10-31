<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="tab-content active flex-col gap-6 mt-6" id="tab-profile">
    <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">
        <div class="lg:col-span-8 bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex flex-col gap-5">
            <h2 class="text-lg font-bold text-slate-900 border-b pb-3">Store Identity &amp; Editorial Bio</h2>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Registered Shop Name</label>
                    <input class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm outline-none focus:border-emerald-500" type="text" name="shopName" value="<c:out value='${shop.shopName}'/>"/>
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Business Type</label>
                    <input class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm outline-none focus:border-emerald-500" type="text" name="businessType" value="<c:out value='${shop.businessType}'/>"/>
                </div>
            </div>
            <div>
                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Shop Description</label>
                <textarea class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm outline-none focus:border-emerald-500 resize-none" name="shopDescription" rows="4"><c:out value="${shop.shopDescription}"/></textarea>
            </div>
        </div>
        <div class="lg:col-span-4 bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex flex-col gap-5">
            <h3 class="text-base font-bold text-slate-900 border-b pb-3">Owner &amp; Principal</h3>
            <div>
                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Họ và tên</label>
                <input class="w-full bg-slate-100 border border-slate-200 rounded-xl px-4 py-2 text-sm text-slate-600" type="text" value="<c:out value='${sessionScope.user.fullName}'/>" readonly/>
            </div>
            <div>
                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Số điện thoại</label>
                <input class="w-full bg-slate-100 border border-slate-200 rounded-xl px-4 py-2 text-sm text-slate-600" type="text" value="<c:out value='${sessionScope.user.phone}'/>" readonly/>
            </div>
            <div>
                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Email (Gmail)</label>
                <input class="w-full bg-slate-100 border border-slate-200 rounded-xl px-4 py-2 text-sm text-slate-600" type="email" value="<c:out value='${owner.email}'/>" readonly/>
            </div>
            <div>
                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Ngày sinh</label>
                <input class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2 text-sm outline-none focus:border-emerald-500" type="date" name="birthDate" value="${owner.birthDate}" max="<%= java.time.LocalDate.now() %>"/>
            </div>
        </div>
    </div>
</div>

<div class="tab-content hidden flex-col gap-6 mt-6" id="tab-operations">
    <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex flex-col gap-5">
        <h2 class="text-lg font-bold text-slate-900 border-b pb-3">Thông Tin Định Danh Người Bán</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Số CCCD / CMND</label>
                <input class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm outline-none focus:border-emerald-500" type="text" name="idCardNumber" value="<c:out value='${shop.idCardNumber}'/>"/>
            </div>
            <div>
                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Mã số thuế</label>
                <input class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm outline-none focus:border-emerald-500" type="text" name="taxCode" value="<c:out value='${shop.taxCode}'/>"/>
            </div>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 pt-4">
            <div class="text-center p-4 border border-dashed rounded-xl bg-slate-50">
                <p class="text-xs font-semibold text-slate-500 mb-2">Ảnh CCCD Mặt Trước</p>
                <img src="${not empty shop.idCardFrontUrl ? shop.idCardFrontUrl : 'https://via.placeholder.com/300x180'}" class="mx-auto h-32 object-cover rounded-lg border"/>
            </div>
            <div class="text-center p-4 border border-dashed rounded-xl bg-slate-50">
                <p class="text-xs font-semibold text-slate-500 mb-2">Ảnh CCCD Mặt Sau</p>
                <img src="${not empty shop.idCardBackUrl ? shop.idCardBackUrl : 'https://via.placeholder.com/300x180'}" class="mx-auto h-32 object-cover rounded-lg border"/>
            </div>
        </div>
    </div>
</div>

<div class="tab-content hidden flex-col gap-6 mt-6" id="tab-fulfillment">
    <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex flex-col gap-5">
        <h2 class="text-lg font-bold text-slate-900 border-b pb-3">Địa Chỉ &amp; Kho Hàng</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Tỉnh / Thành phố</label>
                <div class="combo" id="comboProvince">
                    <input class="combo-input" type="text" name="province" autocomplete="off" placeholder="Chọn hoặc gõ để tìm tỉnh / thành phố" value="<c:out value='${shop.province}'/>"/>
                    <i class="fa-solid fa-chevron-down combo-arrow"></i>
                    <div class="combo-list hidden"></div>
                </div>
            </div>
            <div>
                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Quận / Huyện</label>
                <div class="combo" id="comboDistrict">
                    <input class="combo-input" type="text" name="district" autocomplete="off" placeholder="Chọn hoặc gõ để tìm quận / huyện" value="<c:out value='${shop.district}'/>"/>
                    <i class="fa-solid fa-chevron-down combo-arrow"></i>
                    <div class="combo-list hidden"></div>
                </div>
            </div>
            <div>
                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Phường / Xã</label>
                <div class="combo" id="comboWard">
                    <input class="combo-input" type="text" name="ward" autocomplete="off" placeholder="Chọn hoặc gõ để tìm phường / xã" value="<c:out value='${shop.ward}'/>"/>
                    <i class="fa-solid fa-chevron-down combo-arrow"></i>
                    <div class="combo-list hidden"></div>
                </div>
            </div>
        </div>
        <div>
            <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Địa chỉ chi tiết</label>
            <input class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm outline-none focus:border-emerald-500" type="text" name="streetAddress" value="<c:out value='${shop.streetAddress}'/>"/>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Địa chỉ lấy hàng</label>
                <input class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm outline-none focus:border-emerald-500" type="text" name="pickupAddress" value="<c:out value='${shop.pickupAddress}'/>"/>
            </div>
            <div>
                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Địa chỉ hoàn trả</label>
                <input class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm outline-none focus:border-emerald-500" type="text" name="returnAddress" value="<c:out value='${shop.returnAddress}'/>"/>
            </div>
        </div>
    </div>
</div>

<div class="tab-content hidden flex-col gap-6 mt-6" id="tab-approval">
    <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex flex-col gap-5">
        <h2 class="text-lg font-bold text-slate-900 border-b pb-3">Ngân Hàng &amp; Tài Chính</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Tên Ngân Hàng</label>
                <div class="combo" id="comboBank">
                    <input class="combo-input" type="text" name="bankName" autocomplete="off" placeholder="Chọn hoặc gõ để tìm ngân hàng" value="<c:out value='${shop.bankName}'/>"/>
                    <i class="fa-solid fa-chevron-down combo-arrow"></i>
                    <div class="combo-list hidden"></div>
                </div>
            </div>
            <div>
                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Số Tài Khoản</label>
                <input class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm outline-none focus:border-emerald-500" type="text" name="bankAccountNumber" value="<c:out value='${shop.bankAccountNumber}'/>"/>
            </div>
            <div>
                <label class="block text-xs font-semibold text-slate-500 uppercase mb-1">Chủ Tài Khoản</label>
                <input class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm uppercase outline-none focus:border-emerald-500" type="text" name="bankAccountHolder" value="<c:out value='${shop.bankAccountHolder}'/>"/>
            </div>
        </div>
    </div>
</div>

