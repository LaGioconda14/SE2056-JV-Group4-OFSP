<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đổi mật khẩu - FreshFruit Platform</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts: Plus Jakarta Sans -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Custom Auth Stylesheet -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth.css?v=2">
</head>
<body>

<div class="login-wrapper">
    <!-- LEFT PANEL: Brand, Showcase & Metrics -->
    <div class="showcase-panel">
        <div>
            <div class="brand-logo-wrap">
                <div class="brand-logo-icon">🍎</div>
                <div>
                    <div class="brand-name">FreshFruit</div>
                    <div class="brand-sub">DIRECT FROM ORCHARD</div>
                </div>
            </div>
            
            <p class="hero-desc">
                Fresh organic produce delivered right from local family orchards straight to your table.
            </p>

            <div class="pill-badge">
                <i class="bi bi-shield-lock-fill text-warning"></i>
                <span>Account Security Center</span>
            </div>
        </div>

        <!-- 3 Feature Metrics -->
        <div class="metrics-grid">
            <div class="metric-box">
                <i class="bi bi-shield-check"></i>
                <div class="metric-label">100% Certified Organic</div>
            </div>
            <div class="metric-box">
                <i class="bi bi-truck"></i>
                <div class="metric-label">Same-Day Dispatch</div>
            </div>
            <div class="metric-box">
                <i class="bi bi-heart-fill"></i>
                <div class="metric-label">15,000+ Happy Homes</div>
            </div>
        </div>
    </div>

    <!-- RIGHT PANEL: Change Password Form -->
    <div class="form-panel">
        <div>
            <!-- Top Status Bar -->
            <div class="top-status-bar">
                <div class="secure-pill">
                    <span class="secure-dot"></span>
                    <span>Security Settings</span>
                </div>
                <a href="${pageContext.request.contextPath}/help" class="help-link">
                    <span>Help Center</span>
                    <i class="bi bi-box-arrow-up-right small"></i>
                </a>
            </div>

            <!-- Current User Badge (if logged in) -->
            <c:if test="${not empty sessionScope.user}">
                <div class="p-3 mb-3 rounded-3 d-flex align-items-center justify-content-between" style="background-color: #f0fdf4; border: 1px solid #bbf7d0;">
                    <div class="d-flex align-items-center gap-2">
                        <i class="bi bi-person-circle fs-4" style="color: var(--primary-green);"></i>
                        <div>
                            <div class="fw-bold text-dark small">${sessionScope.user.fullName}</div>
                            <div class="text-muted" style="font-size: 11.5px;">${sessionScope.user.email}</div>
                        </div>
                    </div>
                    <span class="badge" style="background-color: var(--primary-green); font-size: 11px;">${sessionScope.user.role}</span>
                </div>
            </c:if>

            <h1 class="form-title">Đổi mật khẩu</h1>
            <p class="form-subtitle">Cập nhật mật khẩu để bảo vệ an toàn cho tài khoản FreshFruit của bạn.</p>

            <!-- Error Alert -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center py-2 px-3 mb-3 small" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2 fs-6 flex-shrink-0"></i>
                    <div>${errorMessage}</div>
                    <button type="button" class="btn-close ms-auto py-2" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <!-- Success Alert -->
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success alert-dismissible fade show d-flex align-items-center py-2 px-3 mb-3 small" role="alert">
                    <i class="bi bi-check-circle-fill me-2 fs-6 flex-shrink-0"></i>
                    <div>${successMessage}</div>
                    <button type="button" class="btn-close ms-auto py-2" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <!-- Change Password Form -->
            <form action="${pageContext.request.contextPath}/change-password" method="POST" id="changePasswordForm">
                <!-- Current Password -->
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

                <!-- New Password -->
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

                <!-- Confirm New Password -->
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

                <!-- Submit Button -->
                <button type="submit" class="btn-submit-main mt-3">
                    <span>Cập Nhật Mật Khẩu</span>
                    <i class="bi bi-arrow-right"></i>
                </button>
            </form>

            <div class="d-flex justify-content-between align-items-center mt-3 pt-2">
                <a href="${pageContext.request.contextPath}/home.jsp" class="back-link">
                    <i class="bi bi-arrow-left"></i>
                    <span>Trang chủ</span>
                </a>
                <a href="${pageContext.request.contextPath}/logout" class="text-danger text-decoration-none small d-inline-flex align-items-center gap-1 fw-semibold">
                    <i class="bi bi-box-arrow-right"></i>
                    <span>Đăng xuất</span>
                </a>
            </div>
        </div>
    </div>
</div>

<!-- Bootstrap 5 JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<!-- Custom Auth JS -->
<script src="${pageContext.request.contextPath}/assets/js/auth.js"></script>

<script>
    // Live match check for newPassword & confirmPassword
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

</body>
</html>
