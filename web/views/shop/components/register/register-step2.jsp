<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="rs-step-panel" id="step-2">
    <div class="rs-section-title"><span class="rs-section-num">2</span><span>Shop Information (Thông Tin Cửa Hàng)</span></div>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
            <label class="rs-label">Shop Name – Tên cửa hàng <span class="text-red-500">*</span></label>
            <input type="text" name="shopName" class="rs-input" placeholder="Ví dụ: Nông Sản Tươi Xanh" required>
            <p class="rs-feedback">Vui lòng nhập tên cửa hàng.</p>
        </div>
        <div>
            <label class="rs-label">Business Type – Mô hình kinh doanh <span class="text-red-500">*</span></label>
            <select name="businessType" class="rs-input" required>
                <option value="" selected disabled>-- Chọn danh mục chính --</option>
                <option value="TRAI_CAY_NOI_DIA">Trái Cây Nội Địa</option>
                <option value="TRAI_CAY_NHAP_KHAU">Trái Cây Nhập Khẩu</option>
                <option value="TRAI_CAY_HUU_CO">Trái Cây Hữu Cơ (Organic)</option>
                <option value="HOA_QUA_SAY">Hoa Quả Sấy &amp; Chế Biến</option>
                <option value="COMBO_GIOT_HOA_QUA">Giỏ Quà Trái Cây</option>
            </select>
            <p class="rs-feedback">Vui lòng chọn danh mục kinh doanh.</p>
        </div>
        <div class="md:col-span-2">
            <label class="rs-label">Shop Description – Mô tả cửa hàng</label>
            <textarea name="shopDescription" class="rs-input" rows="3" placeholder="Giới thiệu ngắn gọn về gian hàng, nguồn gốc xuất xứ sản phẩm..."></textarea>
        </div>
        <div>
            <label class="rs-label">Shop Logo – Logo cửa hàng <span class="text-red-500">*</span></label>
            <div class="rs-upload" id="box-shopLogoInput" onclick="document.getElementById('shopLogoInput').click()">
                <i class="fa-regular fa-image"></i>
                <p>Tải lên logo cửa hàng (JPG, PNG)</p>
            </div>
            <input type="file" id="shopLogoInput" name="shopLogo" accept="image/*" class="hidden" onchange="previewImage(this, 'shopLogoPreview', 'box-shopLogoInput', 'wrap-shopLogo')" required>
            <div id="wrap-shopLogo" class="rs-preview hidden">
                <img id="shopLogoPreview" alt="Logo cửa hàng">
                <button type="button" class="rs-preview-remove" onclick="removeImage('shopLogoInput', 'shopLogoPreview', 'box-shopLogoInput', 'wrap-shopLogo')" title="Xóa ảnh"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <p class="rs-feedback" id="err-shopLogoInput">Vui lòng tải lên logo cửa hàng.</p>
        </div>
        <div>
            <label class="rs-label">Shop Banner – Ảnh bìa cửa hàng <span class="text-red-500">*</span></label>
            <div class="rs-upload" id="box-shopBannerInput" onclick="document.getElementById('shopBannerInput').click()">
                <i class="fa-regular fa-file-image"></i>
                <p>Tải lên ảnh bìa / banner (khuyên dùng 1200x400px)</p>
            </div>
            <input type="file" id="shopBannerInput" name="shopBanner" accept="image/*" class="hidden" onchange="previewImage(this, 'shopBannerPreview', 'box-shopBannerInput', 'wrap-shopBanner')" required>
            <div id="wrap-shopBanner" class="rs-preview hidden">
                <img id="shopBannerPreview" alt="Banner cửa hàng">
                <button type="button" class="rs-preview-remove" onclick="removeImage('shopBannerInput', 'shopBannerPreview', 'box-shopBannerInput', 'wrap-shopBanner')" title="Xóa ảnh"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <p class="rs-feedback" id="err-shopBannerInput">Vui lòng tải lên banner cửa hàng.</p>
        </div>
    </div>
    <div class="flex justify-between mt-8">
        <button type="button" class="rs-btn-back" onclick="prevStep(2)"><i class="fa-solid fa-arrow-left text-xs"></i> Quay lại</button>
        <button type="button" class="rs-btn-next" onclick="nextStep(2)">Tiếp theo <i class="fa-solid fa-arrow-right text-xs"></i></button>
    </div>
</div>

