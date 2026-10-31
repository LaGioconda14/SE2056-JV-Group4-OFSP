<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="rs-step-panel" id="step-3">
    <div class="rs-section-title"><span class="rs-section-num">3</span><span>Address Information (Thông Tin Địa Chỉ)</span></div>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
            <label class="rs-label">Province/City – Tỉnh / Thành phố <span class="text-red-500">*</span></label>
            <select name="province" class="rs-input" required>
                <option value="" selected disabled>-- Chọn Tỉnh / Thành phố --</option>
                <option value="Hà Nội">Hà Nội</option>
                <option value="TP. Hồ Chí Minh">TP. Hồ Chí Minh</option>
                <option value="Đà Nẵng">Đà Nẵng</option>
                <option value="Cần Thơ">Cần Thơ</option>
                <option value="Đồng Nai">Đồng Nai</option>
                <option value="Lâm Đồng">Lâm Đồng</option>
            </select>
            <p class="rs-feedback">Vui lòng chọn Tỉnh / Thành phố.</p>
        </div>
        <div>
            <label class="rs-label">District – Quận / Huyện <span class="text-red-500">*</span></label>
            <input type="text" name="district" class="rs-input" placeholder="Nhập Quận / Huyện" required>
            <p class="rs-feedback">Vui lòng nhập Quận / Huyện.</p>
        </div>
        <div>
            <label class="rs-label">Ward – Phường / Xã <span class="text-red-500">*</span></label>
            <input type="text" name="ward" class="rs-input" placeholder="Nhập Phường / Xã" required>
            <p class="rs-feedback">Vui lòng nhập Phường / Xã.</p>
        </div>
        <div class="md:col-span-3">
            <label class="rs-label">Street Address – Số nhà, tên đường <span class="text-red-500">*</span></label>
            <input type="text" name="streetAddress" class="rs-input" placeholder="Ví dụ: 123 Đường Nguyễn Trãi" required>
            <p class="rs-feedback">Vui lòng nhập số nhà, tên đường.</p>
        </div>
        <div class="md:col-span-3 grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
                <label class="rs-label">Pickup Address – Địa chỉ lấy hàng <span class="text-red-500">*</span></label>
                <input type="text" name="pickupAddress" class="rs-input" placeholder="Địa chỉ để đơn vị vận chuyển tới lấy hàng" required>
                <p class="rs-feedback">Vui lòng nhập địa chỉ lấy hàng.</p>
            </div>
            <div>
                <label class="rs-label">Return Address – Địa chỉ trả hàng <span class="text-red-500">*</span></label>
                <input type="text" name="returnAddress" class="rs-input" placeholder="Địa chỉ nhận hàng hoàn trả (nếu có)" required>
                <p class="rs-feedback">Vui lòng nhập địa chỉ trả hàng.</p>
            </div>
        </div>
    </div>
    <div class="flex justify-between mt-8">
        <button type="button" class="rs-btn-back" onclick="prevStep(3)"><i class="fa-solid fa-arrow-left text-xs"></i> Quay lại</button>
        <button type="button" class="rs-btn-next" onclick="nextStep(3)">Tiếp theo <i class="fa-solid fa-arrow-right text-xs"></i></button>
    </div>
</div>

