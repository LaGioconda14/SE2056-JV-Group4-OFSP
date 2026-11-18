<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<form action="${pageContext.request.contextPath}/reset-password" method="POST" id="resetForm">
    <div class="field-group">
        <label class="field-label" for="email">Email nhận mã OTP *</label>
        <div class="input-box-wrapper">
            <i class="bi bi-envelope leading-icon"></i>
            <input type="email" 
                   id="email" 
                   name="email" 
                   placeholder="nguyenvana@example.com" 
                   value="${email}" 
                   required 
                   autocomplete="email">
        </div>
    </div>

    <div class="field-group">
        <div class="d-flex justify-content-between align-items-center mb-1">
            <label class="field-label mb-0" for="otp">Mã xác thực OTP (6 chữ số) *</label>
            <button type="submit" name="action" value="resend" formnovalidate
                    class="small text-decoration-none border-0 bg-transparent p-0"
                    style="font-size: 12px; color: var(--primary-green); font-weight: 600;">
                Gửi lại mã OTP?
            </button>
        </div>
        <div class="input-box-wrapper">
            <i class="bi bi-shield-check leading-icon"></i>
            <input type="text" 
                   id="otp" 
                   name="otp" 
                   placeholder="123456" 
                   value="${otp}" 
                   maxlength="6"
                   style="letter-spacing: 4px; font-weight: 700; color: var(--primary-green);"
                   required 
                   autofocus>
        </div>
        <div class="form-hint">
            <i class="bi bi-clock-history"></i>
            <span>Mã OTP có hiệu lực trong 5 phút. Vui lòng kiểm tra hộp thư đến và thư rác.</span>
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

    <button type="submit" class="btn-submit-main mt-2">
        <span>Cập Nhật Mật Khẩu</span>
        <i class="bi bi-arrow-right"></i>
    </button>
</form>

<div class="text-center mt-3">
    <a href="${pageContext.request.contextPath}/login" class="back-link">
        <i class="bi bi-arrow-left"></i>
        <span>Quay lại Đăng nhập</span>
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
