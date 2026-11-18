<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<form action="${pageContext.request.contextPath}/register" method="POST" id="registerForm">
    <div class="form-row-2col">
        <div class="field-group">
            <label class="field-label" for="fullName">Họ và tên *</label>
            <div class="input-box-wrapper">
                <i class="bi bi-person leading-icon"></i>
                <input type="text" 
                       id="fullName" 
                       name="fullName" 
                       placeholder="Nguyễn Văn A" 
                       value="${not empty fullName ? fullName : ''}" 
                       required 
                       autocomplete="name">
            </div>
        </div>

        <div class="field-group">
            <label class="field-label" for="phone">Số điện thoại</label>
            <div class="input-box-wrapper">
                <i class="bi bi-telephone leading-icon"></i>
                <input type="tel" 
                       id="phone" 
                       name="phone" 
                       placeholder="0912 345 678" 
                       value="${not empty phone ? phone : ''}" 
                       autocomplete="tel">
            </div>
        </div>
    </div>

    <div class="field-group">
        <label class="field-label" for="email">Địa chỉ Email *</label>
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
    </div>

    <div class="form-row-2col">
        <div class="field-group">
            <label class="field-label" for="password">Mật khẩu *</label>
            <div class="input-box-wrapper">
                <i class="bi bi-lock leading-icon"></i>
                <input type="password" 
                       id="password" 
                       name="password" 
                       placeholder="Tối thiểu 6 ký tự" 
                       required 
                       autocomplete="new-password">
                <span class="trailing-action" onclick="togglePasswordVisibility('password', this)" title="Hiện/Ẩn mật khẩu">
                    <i class="bi bi-eye"></i>
                </span>
            </div>
        </div>

        <div class="field-group">
            <label class="field-label" for="confirmPassword">Xác nhận mật khẩu *</label>
            <div class="input-box-wrapper">
                <i class="bi bi-shield-check leading-icon"></i>
                <input type="password" 
                       id="confirmPassword" 
                       name="confirmPassword" 
                       placeholder="Nhập lại mật khẩu" 
                       required 
                       autocomplete="new-password">
                <span class="trailing-action" onclick="togglePasswordVisibility('confirmPassword', this)" title="Hiện/Ẩn mật khẩu">
                    <i class="bi bi-eye"></i>
                </span>
            </div>
            <span id="passwordMatchHint" class="form-hint"></span>
        </div>
    </div>

    <div class="form-actions-row">
        <label class="remember-label" for="terms">
            <input type="checkbox" id="terms" required checked>
            <span>Tôi đồng ý với Điều khoản dịch vụ và Chính sách bảo mật của Gốc Vườn</span>
        </label>
    </div>

    <button type="submit" class="btn-submit-main">
        <span>Tạo tài khoản Gốc Vườn</span>
        <i class="bi bi-arrow-right"></i>
    </button>
</form>

<div class="auth-bottom-switch">
    <span>Đã có tài khoản?</span>
    <a href="${pageContext.request.contextPath}/login">Đăng nhập</a>
</div>
