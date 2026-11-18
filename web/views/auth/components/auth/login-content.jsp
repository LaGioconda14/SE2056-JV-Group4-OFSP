<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<form action="${pageContext.request.contextPath}/login" method="POST" id="loginForm">
    <div class="field-group">
        <label class="field-label" for="email">Email hoặc Số điện thoại</label>
        <div class="input-box-wrapper">
            <i class="bi bi-person leading-icon"></i>
            <input type="text" 
                   id="email" 
                   name="email" 
                   placeholder="nguyenvana@example.com hoặc 0912345678" 
                   value="${not empty rememberEmail ? rememberEmail : (not empty email ? email : '')}" 
                   required 
                   autocomplete="username"
                   oninput="checkEmailValidity(this)">
            <span class="trailing-action" id="emailStatusIcon"></span>
        </div>
    </div>

    <div class="field-group">
        <label class="field-label" for="password">Mật khẩu</label>
        <div class="input-box-wrapper">
            <i class="bi bi-lock leading-icon"></i>
            <input type="password" 
                   id="password" 
                   name="password" 
                   placeholder="••••••••••••••••" 
                   required 
                   autocomplete="current-password">
            <span class="trailing-action" onclick="togglePasswordVisibility('password', this)" title="Hiện/Ẩn mật khẩu">
                <i class="bi bi-eye"></i>
            </span>
        </div>
    </div>

    <div class="form-actions-row">
        <label class="remember-label" for="remember">
            <input type="checkbox" 
                   name="remember" 
                   id="remember" 
                   value="1" 
                   ${not empty rememberChecked ? 'checked' : ''}>
            <span>Ghi nhớ đăng nhập trên thiết bị này</span>
        </label>
        <a href="${pageContext.request.contextPath}/forgot-password" class="forgot-link">Quên mật khẩu?</a>
    </div>

    <button type="submit" class="btn-submit-main">
        <span>Đăng nhập vào Gốc Vườn</span>
        <i class="bi bi-arrow-right"></i>
    </button>
</form>

<div class="auth-bottom-switch">
    <span>Bạn chưa có tài khoản?</span>
    <a href="${pageContext.request.contextPath}/register">Đăng ký ngay</a>
</div>
