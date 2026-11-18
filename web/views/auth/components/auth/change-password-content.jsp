<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<form action="${pageContext.request.contextPath}/change-password" method="POST" id="changePasswordForm">
    <div class="field-group">
        <label class="field-label" for="oldPassword">Mật khẩu hiện tại *</label>
        <div class="input-box-wrapper">
            <i class="bi bi-key leading-icon"></i>
            <input type="password" 
                   id="oldPassword" 
                   name="oldPassword" 
                   placeholder="Nhập mật khẩu hiện tại" 
                   required 
                   autofocus 
                   autocomplete="current-password">
            <span class="trailing-action" onclick="togglePasswordVisibility('oldPassword', this)" title="Ẩn/hiện mật khẩu">
                <i class="bi bi-eye"></i>
            </span>
        </div>
    </div>

    <div class="field-group">
        <label class="field-label" for="newPassword">Mật khẩu mới *</label>
        <div class="input-box-wrapper">
            <i class="bi bi-lock leading-icon"></i>
            <input type="password" 
                   id="newPassword" 
                   name="newPassword" 
                   placeholder="Tối thiểu 6 ký tự" 
                   required 
                   autocomplete="new-password">
            <span class="trailing-action" onclick="togglePasswordVisibility('newPassword', this)" title="Ẩn/hiện mật khẩu">
                <i class="bi bi-eye"></i>
            </span>
        </div>
    </div>

    <div class="field-group">
        <label class="field-label" for="confirmPassword">Xác nhận mật khẩu mới *</label>
        <div class="input-box-wrapper">
            <i class="bi bi-lock-fill leading-icon"></i>
            <input type="password" 
                   id="confirmPassword" 
                   name="confirmPassword" 
                   placeholder="Nhập lại mật khẩu mới" 
                   required 
                   autocomplete="new-password">
            <span class="trailing-action" onclick="togglePasswordVisibility('confirmPassword', this)" title="Ẩn/hiện mật khẩu">
                <i class="bi bi-eye"></i>
            </span>
        </div>
        <div class="form-hint" id="passwordMatchHint"></div>
    </div>

    <button type="submit" class="btn-submit-main mt-3">
        <span>Cập Nhật Mật Khẩu</span>
        <i class="bi bi-arrow-right"></i>
    </button>
</form>

<div class="d-flex justify-content-between align-items-center mt-3 pt-2">
    <a href="${pageContext.request.contextPath}/home" class="back-link">
        <i class="bi bi-arrow-left"></i>
        <span>Trang chủ</span>
    </a>
    <a href="${pageContext.request.contextPath}/logout" class="text-danger text-decoration-none small d-inline-flex align-items-center gap-1 fw-semibold">
        <i class="bi bi-box-arrow-right"></i>
        <span>Đăng xuất</span>
    </a>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const pass = document.getElementById('newPassword');
        const confirm = document.getElementById('confirmPassword');
        const hint = document.getElementById('passwordMatchHint');
        if (!pass || !confirm) return;

        function checkMatch() {
            if (!confirm.value) {
                if (hint) hint.textContent = '';
                confirm.setCustomValidity('');
                return;
            }
            if (pass.value !== confirm.value) {
                if (hint) {
                    hint.textContent = 'Mật khẩu xác nhận không khớp!';
                    hint.className = 'form-hint text-danger';
                }
                confirm.setCustomValidity('Mật khẩu xác nhận không khớp!');
            } else {
                if (hint) {
                    hint.textContent = 'Mật khẩu khớp nhau';
                    hint.className = 'form-hint text-success';
                }
                confirm.setCustomValidity('');
            }
        }

        pass.addEventListener('input', checkMatch);
        confirm.addEventListener('input', checkMatch);
    });
</script>
