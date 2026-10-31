<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="rs-step-panel active" id="step-1">
    <div class="rs-section-title"><span class="rs-section-num">1</span><span>Seller Information (Thông Tin Người Bán)</span></div>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
            <label class="rs-label">Full Name – Họ và tên <span class="text-red-500">*</span></label>
            <input type="text" name="fullName" class="rs-input" value="<c:out value='${sessionScope.user.fullName}'/>" placeholder="Nhập họ và tên" required>
            <p class="rs-feedback">Vui lòng nhập họ và tên.</p>
        </div>
        <div>
            <label class="rs-label">Date of Birth – Ngày sinh <span class="text-red-500">*</span></label>
            <input type="date" name="dob" class="rs-input" value="${sessionScope.user.birthDate}" required>
            <p class="rs-feedback">Vui lòng chọn ngày sinh.</p>
        </div>
        <div>
            <label class="rs-label">Phone Number – Số điện thoại <span class="text-red-500">*</span></label>
            <input type="tel" name="phone" class="rs-input" value="<c:out value='${sessionScope.user.phone}'/>" placeholder="Nhập số điện thoại" required>
            <p class="rs-feedback">Vui lòng nhập số điện thoại.</p>
        </div>
        <div>
            <label class="rs-label">Email – Email <span class="text-red-500">*</span></label>
            <input type="email" name="email" class="rs-input" value="<c:out value='${sessionScope.user.email}'/>" placeholder="example@domain.com" required>
            <p class="rs-feedback">Vui lòng nhập email hợp lệ.</p>
        </div>
        <div>
            <label class="rs-label">ID/CCCD Number – Số CCCD <span class="text-red-500">*</span></label>
            <input type="text" name="idCardNumber" class="rs-input" placeholder="Nhập số CCCD (12 chữ số)" pattern="[0-9]{12}" inputmode="numeric" required>
            <p class="rs-feedback">Số CCCD phải gồm đúng 12 chữ số.</p>
        </div>
        <div>
            <label class="rs-label">Tax Identification Number (TIN) – Mã số thuế</label>
            <input type="text" name="taxCode" class="rs-input" placeholder="Mã số thuế cá nhân / hộ kinh doanh">
        </div>

        <div>
            <label class="rs-label">ID/CCCD Front Image – Ảnh CCCD mặt trước <span class="text-red-500">*</span></label>
            <div class="rs-upload" id="box-idFrontInput" onclick="document.getElementById('idFrontInput').click()">
                <i class="fa-regular fa-id-card"></i>
                <p>Nhấp để tải lên ảnh CCCD mặt trước</p>
            </div>
            <input type="file" id="idFrontInput" name="idCardFront" accept="image/*" class="hidden" onchange="previewImage(this, 'idFrontPreview', 'box-idFrontInput', 'wrap-idFront')" required>
            <div id="wrap-idFront" class="rs-preview hidden">
                <img id="idFrontPreview" alt="Ảnh CCCD mặt trước">
                <button type="button" class="rs-preview-remove" onclick="removeImage('idFrontInput', 'idFrontPreview', 'box-idFrontInput', 'wrap-idFront')" title="Xóa ảnh"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <p class="rs-feedback" id="err-idFrontInput">Vui lòng tải lên ảnh CCCD mặt trước.</p>
        </div>
        <div>
            <label class="rs-label">ID/CCCD Back Image – Ảnh CCCD mặt sau <span class="text-red-500">*</span></label>
            <div class="rs-upload" id="box-idBackInput" onclick="document.getElementById('idBackInput').click()">
                <i class="fa-regular fa-credit-card"></i>
                <p>Nhấp để tải lên ảnh CCCD mặt sau</p>
            </div>
            <input type="file" id="idBackInput" name="idCardBack" accept="image/*" class="hidden" onchange="previewImage(this, 'idBackPreview', 'box-idBackInput', 'wrap-idBack')" required>
            <div id="wrap-idBack" class="rs-preview hidden">
                <img id="idBackPreview" alt="Ảnh CCCD mặt sau">
                <button type="button" class="rs-preview-remove" onclick="removeImage('idBackInput', 'idBackPreview', 'box-idBackInput', 'wrap-idBack')" title="Xóa ảnh"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <p class="rs-feedback" id="err-idBackInput">Vui lòng tải lên ảnh CCCD mặt sau.</p>
        </div>
    </div>
    <div class="flex justify-end mt-8">
        <button type="button" class="rs-btn-next" onclick="nextStep(1)">Tiếp theo <i class="fa-solid fa-arrow-right text-xs"></i></button>
    </div>
</div>

