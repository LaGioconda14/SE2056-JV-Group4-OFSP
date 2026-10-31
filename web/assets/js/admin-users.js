/**
 * Gốc Vườn Admin - Users & RBAC Management JavaScript
 * Module: /admin/users
 */

// -------------------------------------------------------------------------
// Function: Mở Modal Khóa / Mở khóa tài khoản với lý do bắt buộc (Decision Reason)
// -------------------------------------------------------------------------
function openToggleStatusModal(userId, fullName, email, targetStatus, currentReason) {
    document.getElementById('toggleStatusUserId').value = userId;
    document.getElementById('toggleStatusNewStatus').value = targetStatus;
    document.getElementById('toggleUserNameDisplay').textContent = fullName + ' (ID: #' + userId + ')';
    document.getElementById('toggleUserEmailDisplay').textContent = email;

    const reasonInput = document.getElementById('toggleStatusReasonInput');
    reasonInput.value = '';

    const titleEl = document.getElementById('toggleModalTitle');
    const alertEl = document.getElementById('toggleWarningAlert');
    const submitBtn = document.getElementById('toggleStatusSubmitBtn');

    if (targetStatus === 'BLOCKED') {
        titleEl.innerHTML = '<i class="bi bi-shield-slash-fill text-danger me-1"></i> Khóa Quyền Truy Cập Tài Khoản (BLOCKED)';
        alertEl.className = 'alert alert-danger mb-3';
        alertEl.innerHTML = '<strong><i class="bi bi-exclamation-octagon-fill me-1"></i> CẢNH BÁO:</strong> Khi chuyển sang trạng thái <strong>BLOCKED</strong>, người dùng sẽ bị <strong>vô hiệu hóa tức thì mọi quyền đăng nhập</strong>, không thể đặt hàng hay quản lý gian hàng trên Gốc Vườn.';
        reasonInput.placeholder = 'Nhập lý do quản trị bắt buộc (Ví dụ: Phát hiện gian lận đặt đơn ảo / Spam đánh giá / Vi phạm điều khoản sử dụng)...';
        submitBtn.className = 'btn btn-danger btn-sm fw-bold px-3';
        submitBtn.innerHTML = '<i class="bi bi-lock-fill me-1"></i> Xác Nhận Khóa Tài Khoản';
    } else {
        titleEl.innerHTML = '<i class="bi bi-shield-check text-success me-1"></i> Mở Khóa Tài Khoản (Khôi Phục ACTIVE)';
        alertEl.className = 'alert alert-success mb-3';
        alertEl.innerHTML = '<strong><i class="bi bi-check-circle-fill me-1"></i> XÁC NHẬN:</strong> Khôi phục trạng thái <strong>ACTIVE</strong> cho phép người dùng đăng nhập lại bình thường vào hệ sinh thái Gốc Vườn.';
        reasonInput.placeholder = 'Nhập lý do quản trị bắt buộc (Ví dụ: Khách hàng đã giải trình thành công / Đã hoàn tất xác minh danh tính)...';
        submitBtn.className = 'btn btn-success btn-sm fw-bold px-3';
        submitBtn.style.background = '#15803d';
        submitBtn.style.borderColor = '#15803d';
        submitBtn.innerHTML = '<i class="bi bi-unlock-fill me-1"></i> Xác Nhận Mở Khóa';
    }

    const modalEl = document.getElementById('toggleUserStatusModal');
    const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
    modal.show();
}
