<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="rs-step-panel" id="step-5">
    <div class="rs-section-title"><span class="rs-section-num">5</span><span>Verification &amp; Agreement (Điều Khoản &amp; Cam Kết)</span></div>

    <div class="rs-summary">
        <div class="rs-summary-box"><h4><i class="fa-solid fa-user"></i> Người bán</h4><p id="sum-owner">—</p></div>
        <div class="rs-summary-box"><h4><i class="fa-solid fa-store"></i> Cửa hàng</h4><p id="sum-shop">—</p></div>
        <div class="rs-summary-box"><h4><i class="fa-solid fa-location-dot"></i> Địa chỉ</h4><p id="sum-address">—</p></div>
        <div class="rs-summary-box"><h4><i class="fa-solid fa-building-columns"></i> Ngân hàng</h4><p id="sum-bank">—</p></div>
    </div>

    <div class="rs-agree-box">
        <label class="rs-check">
            <input type="checkbox" value="true" id="termsCheck" name="agreeTerms" required>
            <span>
                Tôi đã đọc và đồng ý với
                <button type="button" class="rs-terms-link" data-open-terms="tos">Điều khoản &amp; Điều kiện dịch vụ</button>
                dành cho Shop Owner. <span class="text-red-500">*</span>
            </span>
        </label>
        <label class="rs-check">
            <input type="checkbox" value="true" id="policyCheck" name="agreePolicies" required>
            <span>
                Tôi cam kết tuân thủ
                <button type="button" class="rs-terms-link" data-open-terms="policy">Chính sách bán hàng &amp; An toàn thực phẩm</button>
                của nền tảng. <span class="text-red-500">*</span>
            </span>
        </label>
    </div>
    <p class="text-xs text-gray-500 mt-3"><i class="fa-solid fa-lock text-emerald-600"></i> Thông tin của bạn được bảo mật và chỉ dùng cho việc thẩm định hồ sơ, vận hành gian hàng theo quy định pháp luật về bảo vệ dữ liệu cá nhân.</p>

    <div class="flex justify-between mt-8">
        <button type="button" class="rs-btn-back" onclick="prevStep(5)"><i class="fa-solid fa-arrow-left text-xs"></i> Quay lại</button>
        <button type="submit" class="rs-btn-submit" id="submitBtn"><i class="fa-solid fa-circle-check"></i> Gửi Đăng Ký</button>
    </div>
</div>

