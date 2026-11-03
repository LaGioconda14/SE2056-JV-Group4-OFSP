<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="tab-pane fade" id="nav-security" role="tabpanel">
    <div class="profile-section-card">
        <span class="section-tag">AN TOÀN TÀI KHOẢN</span>
        <h3 class="section-heading mb-4">Đổi Mật Khẩu Tài Khoản</h3>

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
    </div>
</div>
