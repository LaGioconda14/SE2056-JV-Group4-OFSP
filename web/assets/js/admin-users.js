/**
 * FreshFruit Admin - Users & RBAC Management JavaScript
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
        alertEl.innerHTML = '<strong><i class="bi bi-exclamation-octagon-fill me-1"></i> CẢNH BÁO:</strong> Khi chuyển sang trạng thái <strong>BLOCKED</strong>, người dùng sẽ bị <strong>vô hiệu hóa tức thì mọi quyền đăng nhập</strong>, không thể đặt hàng hay quản lý gian hàng trên FreshFruit.';
        reasonInput.placeholder = 'Nhập lý do quản trị bắt buộc (Ví dụ: Phát hiện gian lận đặt đơn ảo / Spam đánh giá / Vi phạm điều khoản sử dụng)...';
        submitBtn.className = 'btn btn-danger btn-sm fw-bold px-3';
        submitBtn.innerHTML = '<i class="bi bi-lock-fill me-1"></i> Xác Nhận Khóa Tài Khoản';
    } else {
        titleEl.innerHTML = '<i class="bi bi-shield-check text-success me-1"></i> Mở Khóa Tài Khoản (Khôi Phục ACTIVE)';
        alertEl.className = 'alert alert-success mb-3';
        alertEl.innerHTML = '<strong><i class="bi bi-check-circle-fill me-1"></i> XÁC NHẬN:</strong> Khôi phục trạng thái <strong>ACTIVE</strong> cho phép người dùng đăng nhập lại bình thường vào hệ sinh thái FreshFruit.';
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

// -------------------------------------------------------------------------
// Function: Mở Modal Xem Hồ Sơ & Lịch Sử Giao Dịch / Mua Bán (AJAX)
// -------------------------------------------------------------------------
function openUserDetailModal(userId) {
    const modalEl = document.getElementById('viewUserDetailModal');
    const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
    modal.show();

    const loadingEl = document.getElementById('modalDetailLoading');
    const contentEl = document.getElementById('modalDetailContent');
    loadingEl.style.display = 'block';
    contentEl.style.display = 'none';

    // Reset to first tab
    const firstTabBtn = document.getElementById('tab-profile-btn');
    if (firstTabBtn) {
        const tabObj = new bootstrap.Tab(firstTabBtn);
        tabObj.show();
    }

    const ctx = typeof getAdminContextPath === 'function' ? getAdminContextPath() : '';
    fetch(ctx + '/admin/users?action=detail&userId=' + encodeURIComponent(userId))
        .then(res => {
            if (!res.ok) throw new Error('Không thể tải thông tin chi tiết người dùng.');
            return res.json();
        })
        .then(data => {
            const u = data.user || {};
            const s = data.shop;
            const addrs = data.addresses || [];
            const orders = data.orders || [];
            const vendorOrders = data.vendorOrders || [];
            const auditLogs = data.statusLogs || [];
            const stats = data.stats || {};

            // 1. Header
            document.getElementById('modalUserFullName').textContent = u.fullName || 'Người dùng';
            document.getElementById('modalUserSubMeta').textContent = 'ID: #' + u.userId + ' • ' + (u.email || '') + ' • ' + (u.phone || '');

            const avatarWrap = document.getElementById('modalUserAvatarWrap');
            if (u.avatarUrl) {
                avatarWrap.innerHTML = '<img src="' + u.avatarUrl + '" class="user-avatar-circle" style="width: 44px; height: 44px;">';
            } else {
                const initial = (u.fullName || 'U').charAt(0).toUpperCase();
                avatarWrap.innerHTML = '<div class="user-avatar-placeholder" style="width: 44px; height: 44px; font-size: 1.1rem;">' + initial + '</div>';
            }

            // Role & Status Badges in Header
            let roleBadgeHtml = '<span class="role-pill-accountant">' + (u.roleName || 'CUSTOMER') + '</span>';
            if (u.roleName === 'ADMIN') roleBadgeHtml = '<span class="role-pill-super">QUẢN TRỊ</span>';
            else if (u.roleName === 'STAFF') roleBadgeHtml = '<span class="role-pill-mod">NHÂN VIÊN</span>';
            else if (u.roleName === 'SHOP_OWNER') roleBadgeHtml = '<span class="role-pill-shopmgr">CHỦ SHOP</span>';
            else if (u.roleName === 'DRIVER') roleBadgeHtml = '<span class="role-pill-cskh">TÀI XẾ</span>';
            document.getElementById('modalUserRoleBadge').innerHTML = roleBadgeHtml;

            let statusBadgeHtml = '<span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1"><i class="bi bi-check-circle-fill me-1"></i> Hoạt động</span>';
            if (u.status === 'BLOCKED') {
                statusBadgeHtml = '<span class="badge bg-danger-subtle text-danger border border-danger-subtle px-2 py-1"><i class="bi bi-slash-circle-fill me-1"></i> Bị khóa (BLOCKED)</span>';
            } else if (u.status === 'INACTIVE') {
                statusBadgeHtml = '<span class="badge bg-secondary-subtle text-secondary border px-2 py-1"><i class="bi bi-clock-history me-1"></i> Chưa kích hoạt</span>';
            }
            document.getElementById('modalUserStatusBadge').innerHTML = statusBadgeHtml;

            // 2. Tab 1: Profile Info
            document.getElementById('infoUserId').textContent = '#' + u.userId;
            document.getElementById('infoFullName').textContent = u.fullName || '-';
            document.getElementById('infoEmail').textContent = u.email || '-';
            document.getElementById('infoPhone').textContent = u.phone || '-';
            document.getElementById('infoGender').textContent = u.gender || '-';
            document.getElementById('infoBirthDate').textContent = u.birthDate || '-';
            document.getElementById('infoRoleTitle').textContent = u.roleTitle || u.roleName;
            document.getElementById('infoMembershipTier').textContent = u.membershipTier || '-';
            document.getElementById('infoStatus').textContent = u.status === 'ACTIVE' ? 'Đang hoạt động (ACTIVE)' : (u.status === 'BLOCKED' ? 'Bị khóa quyền (BLOCKED)' : u.status);
            document.getElementById('infoCreatedAt').textContent = u.createdAtFormatted || '-';
            document.getElementById('infoUpdatedAt').textContent = u.updatedAtFormatted || '-';

            // Decision Alert
            const decisionAlert = document.getElementById('modalDecisionAlert');
            if (u.decisionReason) {
                decisionAlert.style.display = 'flex';
                document.getElementById('modalDecisionReasonText').textContent = u.decisionReason;
                document.getElementById('modalDecisionDateText').textContent = u.decisionAtFormatted ? ('Ghi nhận lúc: ' + u.decisionAtFormatted) : '';
            } else {
                decisionAlert.style.display = 'none';
            }

            // Shop Info
            const shopSection = document.getElementById('modalShopInfoSection');
            if (s) {
                shopSection.style.display = 'block';
                document.getElementById('shopInfoName').textContent = s.shopName || '-';
                document.getElementById('shopInfoType').textContent = s.businessType || '-';
                document.getElementById('shopInfoProvince').textContent = s.province || '-';
                document.getElementById('shopInfoCert').textContent = s.certificationName || 'Chưa cấp';
                document.getElementById('shopInfoComm').textContent = s.commissionRate || '8.0%';
                document.getElementById('shopInfoSales').textContent = s.totalSalesFormatted || '0 ₫';
            } else {
                shopSection.style.display = 'none';
            }

            // Addresses
            const addressListEl = document.getElementById('modalAddressList');
            if (addrs.length === 0) {
                addressListEl.innerHTML = '<div class="text-muted small py-2 fst-italic">Tài khoản này chưa lưu địa chỉ nhận hàng nào.</div>';
            } else {
                let addrHtml = '';
                addrs.forEach(a => {
                    addrHtml += '<div class="address-box ' + (a.isDefault ? 'is-default' : '') + '">';
                    addrHtml += '  <div class="d-flex align-items-center justify-content-between mb-1">';
                    addrHtml += '    <strong><i class="bi bi-person-fill text-muted me-1"></i>' + escapeHtml(a.recipientName) + ' • ' + escapeHtml(a.recipientPhone) + '</strong>';
                    if (a.isDefault) {
                        addrHtml += '    <span class="badge bg-success" style="font-size: 0.65rem;"><i class="bi bi-check2"></i> Mặc định</span>';
                    }
                    addrHtml += '  </div>';
                    addrHtml += '  <div class="text-muted small"><i class="bi bi-geo-alt me-1"></i>' + escapeHtml(a.fullAddress) + '</div>';
                    addrHtml += '</div>';
                });
                addressListEl.innerHTML = addrHtml;
            }

            // 3. Tab 2: Orders Stats & Tables
            document.getElementById('statTotalSpent').textContent = stats.totalSpentFormatted || '0 ₫';
            document.getElementById('statTotalOrders').textContent = stats.totalOrders || 0;
            document.getElementById('statCompletedOrders').textContent = stats.completedOrders || 0;
            document.getElementById('statOtherOrders').textContent = (stats.cancelledOrders || 0) + (stats.pendingOrders || 0);

            const ordersTbody = document.getElementById('modalOrdersTableBody');
            if (orders.length === 0) {
                ordersTbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted py-3">Chưa có đơn hàng nào được đặt.</td></tr>';
            } else {
                let oHtml = '';
                orders.forEach(o => {
                    let statusBadge = '<span class="badge bg-secondary-subtle text-secondary">' + o.orderStatus + '</span>';
                    if (o.orderStatus === 'COMPLETED') statusBadge = '<span class="badge bg-success-subtle text-success">Hoàn tất</span>';
                    else if (o.orderStatus === 'PROCESSING' || o.orderStatus === 'CONFIRMED') statusBadge = '<span class="badge bg-primary-subtle text-primary">Đang xử lý</span>';
                    else if (o.orderStatus === 'CANCELLED') statusBadge = '<span class="badge bg-danger-subtle text-danger">Đã hủy</span>';

                    oHtml += '<tr>';
                    oHtml += '  <td><strong class="text-success">#' + escapeHtml(o.orderCode) + '</strong></td>';
                    oHtml += '  <td>' + escapeHtml(o.createdAtFormatted) + '</td>';
                    oHtml += '  <td>' + o.itemsCount + ' món</td>';
                    oHtml += '  <td><strong class="text-dark">' + escapeHtml(o.finalAmountFormatted) + '</strong></td>';
                    oHtml += '  <td><span class="badge bg-light text-dark border">' + escapeHtml(o.paymentMethod) + ' (' + escapeHtml(o.paymentStatus) + ')</span></td>';
                    oHtml += '  <td>' + statusBadge + '</td>';
                    oHtml += '</tr>';
                });
                ordersTbody.innerHTML = oHtml;
            }

            // Vendor Orders Table (if Shop Owner)
            const vendorSection = document.getElementById('modalVendorOrdersSection');
            const vendorTbody = document.getElementById('modalVendorOrdersTableBody');
            if (vendorOrders.length > 0) {
                vendorSection.style.display = 'block';
                let voHtml = '';
                vendorOrders.forEach(vo => {
                    voHtml += '<tr>';
                    voHtml += '  <td><strong class="text-primary">' + escapeHtml(vo.subOrderCode) + '</strong></td>';
                    voHtml += '  <td>' + escapeHtml(vo.createdAtFormatted) + '</td>';
                    voHtml += '  <td>' + escapeHtml(vo.buyerName || '-') + ' (' + escapeHtml(vo.buyerPhone || '-') + ')</td>';
                    voHtml += '  <td><strong class="text-success">' + escapeHtml(vo.shopTotalFormatted) + '</strong></td>';
                    voHtml += '  <td><span class="text-danger">-' + escapeHtml(vo.commissionAmountFormatted) + '</span></td>';
                    voHtml += '  <td><span class="badge bg-light text-dark border">' + escapeHtml(vo.status) + '</span></td>';
                    voHtml += '</tr>';
                });
                vendorTbody.innerHTML = voHtml;
            } else {
                vendorSection.style.display = 'none';
            }

            // 4. Tab 3: Audit Logs
            const auditTbody = document.getElementById('modalAuditLogsTableBody');
            if (auditLogs.length === 0) {
                auditTbody.innerHTML = '<tr><td colspan="4" class="text-center text-muted py-3">Chưa có quyết định thay đổi trạng thái nào được ghi nhận.</td></tr>';
            } else {
                let logHtml = '';
                auditLogs.forEach(l => {
                    logHtml += '<tr>';
                    logHtml += '  <td><i class="bi bi-clock me-1 text-muted"></i>' + escapeHtml(l.createdAtFormatted) + '</td>';
                    logHtml += '  <td><span class="badge bg-light text-dark border">' + (l.oldStatus || 'NONE') + '</span> → <span class="badge ' + (l.newStatus === 'BLOCKED' ? 'bg-danger text-white' : 'bg-success text-white') + '">' + l.newStatus + '</span></td>';
                    logHtml += '  <td><strong>' + escapeHtml(l.changedBy || 'Admin') + '</strong></td>';
                    logHtml += '  <td class="text-dark">' + escapeHtml(l.decisionReason || '-') + '</td>';
                    logHtml += '</tr>';
                });
                auditTbody.innerHTML = logHtml;
            }

            loadingEl.style.display = 'none';
            contentEl.style.display = 'block';
        })
        .catch(err => {
            loadingEl.innerHTML = '<div class="alert alert-danger m-3">' + err.message + '</div>';
        });
}

// Helper: Escape HTML string
function escapeHtml(text) {
    if (!text) return '';
    return String(text)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

