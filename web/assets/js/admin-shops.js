/**
 * Gốc Vườn Admin - Shops & Seller Onboarding Management JavaScript
 * Module: /admin/shops
 */

// 1. Mở modal thẩm định chi tiết hồ sơ KYC (Seller Onboarding)
function openKycInspectModal(btn) {
    if (!btn) return;
    const d = btn.dataset;
    const modalEl = document.getElementById('kycInspectModal');
    const modal = bootstrap.Modal.getOrCreateInstance(modalEl);

    document.getElementById('kycModalSubTitle').textContent = 'Mã hồ sơ: #REQ-' + (d.requestId || '') + ' • Nộp lúc: ' + (d.createdAt || '-');
    document.getElementById('kycApplicantName').textContent = d.applicantName || '-';
    document.getElementById('kycIdCard').textContent = d.idCardNumber || 'Chưa cung cấp';
    document.getElementById('kycApplicantPhone').textContent = d.applicantPhone || '-';
    document.getElementById('kycApplicantEmail').textContent = d.applicantEmail || '-';
    document.getElementById('kycUserId').textContent = '#' + (d.userId || '');

    document.getElementById('kycShopName').textContent = d.shopName || '-';
    document.getElementById('kycBusinessType').textContent = d.businessType || '-';
    document.getElementById('kycCertName').textContent = d.certificationName || 'Chưa có chứng nhận';
    document.getElementById('kycProvince').textContent = d.province || '-';
    document.getElementById('kycFarmAddress').textContent = d.farmAddress || '-';

    document.getElementById('kycSpecialty').textContent = d.produceSpecialty || '-';
    document.getElementById('kycReason').textContent = d.reason ? ('"' + d.reason + '"') : 'Không có ghi chú thêm.';

    const resultBox = document.getElementById('kycReviewResultBox');
    const status = d.status || 'PENDING';
    if (status !== 'PENDING') {
        resultBox.style.display = 'block';
        if (status === 'APPROVED') {
            resultBox.className = 'p-3 border rounded-3 mb-2 bg-success-subtle border-success-subtle';
            document.getElementById('kycResultTitle').textContent = 'Hồ sơ đã được phê duyệt';
            document.getElementById('kycResultBadge').innerHTML = '<span class="badge bg-success">Đã phê duyệt</span>';
        } else {
            resultBox.className = 'p-3 border rounded-3 mb-2 bg-danger-subtle border-danger-subtle';
            document.getElementById('kycResultTitle').textContent = 'Hồ sơ đã bị từ chối';
            document.getElementById('kycResultBadge').innerHTML = '<span class="badge bg-danger">Đã từ chối</span>';
        }
        document.getElementById('kycReviewerMeta').textContent = 'Người thẩm định: ' + (d.reviewerName || 'Admin') + ' • Thời gian: ' + (d.reviewedAt || '-');
        document.getElementById('kycReviewNote').textContent = d.reviewNote ? ('Lý do / Ghi chú: ' + d.reviewNote) : '';
    } else {
        resultBox.style.display = 'none';
    }

    // Action buttons in inspect footer
    const actionBtns = document.getElementById('kycInspectActionBtns');
    if (status === 'PENDING') {
        actionBtns.innerHTML = 
            '<button type="button" class="btn btn-sm btn-outline-danger fw-bold px-3 me-2" onclick="bootstrap.Modal.getInstance(document.getElementById(\'kycInspectModal\')).hide(); openRejectModal(\'' + d.requestId + '\', \'' + escapeJs(d.shopName) + '\', \'' + escapeJs(d.applicantName) + '\');">' +
                '<i class="bi bi-x me-1"></i> Từ Chối' +
            '</button>' +
            '<button type="button" class="btn btn-sm btn-success fw-bold px-3" style="background: #15803d; border-color: #15803d;" onclick="bootstrap.Modal.getInstance(document.getElementById(\'kycInspectModal\')).hide(); openApproveModal(\'' + d.requestId + '\', \'' + escapeJs(d.shopName) + '\', \'' + escapeJs(d.applicantName) + '\');">' +
                '<i class="bi bi-check2 me-1"></i> Phê Duyệt Ngay' +
            '</button>';
    } else {
        actionBtns.innerHTML = '';
    }

    modal.show();
}

// 2. Mở modal phê duyệt hồ sơ
function openApproveModal(requestId, shopName, applicantName) {
    document.getElementById('approveRequestId').value = requestId;
    document.getElementById('approveShopNameDisplay').textContent = shopName + ' (#REQ-' + requestId + ')';
    document.getElementById('approveApplicantDisplay').textContent = 'Người nộp: ' + applicantName;
    const modal = bootstrap.Modal.getOrCreateInstance(document.getElementById('approveRequestModal'));
    modal.show();
}

// 3. Mở modal từ chối hồ sơ
function openRejectModal(requestId, shopName, applicantName) {
    document.getElementById('rejectRequestId').value = requestId;
    document.getElementById('rejectShopNameDisplay').textContent = shopName + ' (#REQ-' + requestId + ')';
    document.getElementById('rejectApplicantDisplay').textContent = 'Người nộp: ' + applicantName;
    const modal = bootstrap.Modal.getOrCreateInstance(document.getElementById('rejectRequestModal'));
    modal.show();
}

// 4. Mở modal đình chỉ gian hàng
function openSuspendShopModal(shopId, shopName, ownerName) {
    document.getElementById('suspendShopId').value = shopId;
    document.getElementById('suspendShopNameDisplay').textContent = shopName + ' (ID: #' + shopId + ')';
    document.getElementById('suspendOwnerDisplay').textContent = 'Chủ sở hữu: ' + ownerName;
    const modal = bootstrap.Modal.getOrCreateInstance(document.getElementById('suspendShopModal'));
    modal.show();
}

// 5. Mở modal mở lại hoạt động gian hàng
function openReactivateShopModal(shopId, shopName, ownerName) {
    document.getElementById('reactivateShopId').value = shopId;
    document.getElementById('reactivateShopNameDisplay').textContent = shopName + ' (ID: #' + shopId + ')';
    document.getElementById('reactivateOwnerDisplay').textContent = 'Chủ sở hữu: ' + ownerName;
    const modal = bootstrap.Modal.getOrCreateInstance(document.getElementById('reactivateShopModal'));
    modal.show();
}

// 6. Mở modal chi tiết gian hàng
function openShopDetailModal(btn) {
    if (!btn) return;
    const d = btn.dataset;
    const modalEl = document.getElementById('shopDetailModal');
    const modal = bootstrap.Modal.getOrCreateInstance(modalEl);

    document.getElementById('sdShopName').textContent = d.shopName || '-';
    document.getElementById('sdBusinessType').textContent = (d.businessType || '-') + ' • ID: #' + (d.shopId || '');
    
    let sBadge = '<span class="status-pill-green">Đang hoạt động</span>';
    if (d.status === 'SUSPENDED') sBadge = '<span class="badge bg-danger">Bị đình chỉ</span>';
    else if (d.status === 'PENDING_KYC') sBadge = '<span class="badge bg-warning text-dark">Chờ duyệt KYC</span>';
    document.getElementById('sdStatusBadge').innerHTML = sBadge;

    document.getElementById('sdOwnerName').textContent = d.ownerName || '-';
    document.getElementById('sdPhone').textContent = d.phone || '-';
    document.getElementById('sdEmail').textContent = d.email || '-';
    document.getElementById('sdProvince').textContent = d.province || '-';
    document.getElementById('sdAddress').textContent = d.address || '-';
    document.getElementById('sdCert').textContent = d.certificationName || 'Chưa cập nhật';
    document.getElementById('sdComm').textContent = d.commissionRate || '-';
    document.getElementById('sdSales').textContent = d.totalSales || '0 ₫';
    document.getElementById('sdOrders').textContent = (d.totalOrders || '0') + ' đơn';

    const suspBox = document.getElementById('sdSuspendedBox');
    if (d.status === 'SUSPENDED' && d.suspendedReason) {
        suspBox.style.display = 'block';
        document.getElementById('sdSuspendedReason').textContent = d.suspendedReason;
        document.getElementById('sdSuspendedDate').textContent = 'Đình chỉ lúc: ' + (d.suspendedDate || '-');
    } else {
        suspBox.style.display = 'none';
    }

    modal.show();
}

function escapeJs(str) {
    if (!str) return '';
    return String(str).replace(/'/g, "\\\'").replace(/"/g, '&quot;');
}
