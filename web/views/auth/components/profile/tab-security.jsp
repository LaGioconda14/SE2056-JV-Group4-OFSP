<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="tab-pane fade" id="nav-security" role="tabpanel">
    <div class="profile-section-card">
        <span class="section-tag">AN TOÀN TÀI KHOẢN</span>
        <h3 class="section-heading mb-4">Mật Khẩu & Bảo Mật 2 Lớp (2FA)</h3>

        <form action="${pageContext.request.contextPath}/profile" method="POST">
            <input type="hidden" name="action" value="changePassword">

            <div class="row g-3 mb-3">
                <div class="col-md-4 field-box">
                    <label class="field-label" for="oldPassword">Mật khẩu hiện tại *</label>
                    <div class="input-icon-group">
                        <i class="bi bi-key lead-icon"></i>
                        <input type="password" id="oldPassword" name="oldPassword" required placeholder="••••••••">
                    </div>
                </div>
                <div class="col-md-4 field-box">
                    <label class="field-label" for="newPassword">Mật khẩu mới *</label>
                    <div class="input-icon-group">
                        <i class="bi bi-lock lead-icon"></i>
                        <input type="password" id="newPassword" name="newPassword" required placeholder="Tối thiểu 6 ký tự">
                    </div>
                </div>
                <div class="col-md-4 field-box">
                    <label class="field-label" for="confirmPassword">Xác nhận mật khẩu *</label>
                    <div class="input-icon-group">
                        <i class="bi bi-lock-fill lead-icon"></i>
                        <input type="password" id="confirmPassword" name="confirmPassword" required placeholder="Nhập lại mật khẩu mới">
                    </div>
                </div>
            </div>

            <button type="submit" class="btn btn-fresh-green btn-sm px-4">
                <i class="bi bi-shield-lock me-1"></i> Cập nhật mật khẩu mới
            </button>
        </form>

        <hr class="my-4">

        <div class="security-2fa-row">
            <div>
                <strong class="text-dark d-block">Xác thực hai yếu tố (2FA)</strong>
                <span class="text-muted small">Tăng cường an toàn cho tài khoản khi đăng nhập bằng mã OTP qua điện thoại hoặc ứng dụng Google Authenticator.</span>
            </div>
            <button class="btn-pill-success">Cấu hình 2FA</button>
        </div>

        <div class="border-top pt-3">
            <strong class="text-dark small d-block mb-2">Thiết bị & Phiên đăng nhập</strong>
            <div class="session-device-box">
                <div class="d-flex align-items-center gap-2">
                    <i class="bi bi-laptop fs-5 text-success"></i>
                    <div>
                        <span class="small fw-semibold text-dark">Chrome trên Windows</span>
                        <span class="badge bg-success ms-2 badge-xs">Thiết bị này</span>
                        <div class="session-device-desc">Hà Nội, Việt Nam &bull; Đang hoạt động</div>
                    </div>
                </div>
                <span class="text-success small fw-bold"><i class="bi bi-circle-fill text-success online-indicator-dot"></i> Online</span>
            </div>
        </div>
    </div>
</div>

