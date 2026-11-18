<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<form action="${pageContext.request.contextPath}/forgot-password" method="POST" id="forgotForm">
    <div class="field-group mb-4">
        <label class="field-label" for="email">Địa chỉ Email đã đăng ký *</label>
        <div class="input-box-wrapper">
            <i class="bi bi-envelope leading-icon"></i>
            <input type="email" 
                   id="email" 
                   name="email" 
                   placeholder="nguyenvana@example.com" 
                   value="${not empty email ? email : ''}" 
                   required 
                   autocomplete="email"
                   oninput="checkEmailValidity(this)">
            <span class="trailing-action" id="emailStatusIcon"></span>
        </div>
        <div class="form-hint">
            <i class="bi bi-info-circle"></i>
            <span>Mã xác thực OTP gồm 6 chữ số sẽ được gửi vào email và có hiệu lực trong 5 phút.</span>
        </div>
    </div>

    <button type="submit" class="btn-submit-main">
        <span>Gửi mã xác thực OTP</span>
        <i class="bi bi-arrow-right"></i>
    </button>
</form>

<div class="text-center mt-4">
    <a href="${pageContext.request.contextPath}/login" class="back-link">
        <i class="bi bi-arrow-left"></i>
        <span>Quay lại trang Đăng nhập</span>
    </a>
</div>
