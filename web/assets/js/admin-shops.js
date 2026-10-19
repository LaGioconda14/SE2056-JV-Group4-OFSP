/**
 * Gốc Vườn Admin - Shops & Seller Onboarding Management JavaScript
 * Module: /admin/shops
 */

// 1. Mở modal thẩm định chi tiết hồ sơ KYC (Seller Onboarding)
function openKycInspectModal(requestId) {
    const modalEl = document.getElementById('kycInspectModal');
    const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
    modal.show();

    const loading = document.getElementById('kycInspectLoading');
    const body = document.getElementById('kycInspectBody');
    loading.style.display = 'block';
    body.style.display = 'none';

    const ctx = typeof getAdminContextPath === 'function' ? getAdminContextPath() : '';
    fetch(ctx + '/admin/shops?action=requestDetail&requestId=' + encodeURIComponent(requestId))
        .then(res => res.json())
        .then(data => {
            if (data.error) throw new Error(data.error);

            document.getElementById('kycModalSubTitle').textContent = 'Mã hồ sơ: #REQ-' + data.requestId + ' • Nộp lúc: ' + data.createdAtFormatted;
            document.getElementById('kycApplicantName').textContent = data.applicantName || '-';
            document.getElementById('kycIdCard').textContent = data.idCardNumber || 'Chưa cung cấp';
            document.getElementById('kycApplicantPhone').textContent = data.applicantPhone || '-';
            document.getElementById('kycApplicantEmail').textContent = data.applicantEmail || '-';
            document.getElementById('kycUserId').textContent = '#' + data.userId;

            document.getElementById('kycShopName').textContent = data.shopName || '-';
            document.getElementById('kycBusinessType').textContent = data.businessType || '-';
            document.getElementById('kycCertName').textContent = data.certificationName || 'Chưa có chứng nhận';
            document.getElementById('kycProvince').textContent = data.province || '-';
            document.getElementById('kycFarmAddress').textContent = data.farmAddress || '-';

            document.getElementById('kycSpecialty').textContent = data.produceSpecialty || '-';
            document.getElementById('kycReason').textContent = data.reason ? ('"' + data.reason + '"') : 'Không có ghi chú thêm.';

            const resultBox = document.getElementById('kycReviewResultBox');
            if (data.status !== 'PENDING') {
                resultBox.style.display = 'block';
                if (data.status === 'APPROVED') {
                    resultBox.className = 'p-3 border rounded-3 mb-2 bg-success-subtle border-success-subtle';
                    document.getElementById('kycResultTitle').textContent = 'Hồ sơ đã được phê duyệt';
                    document.getElementById('kycResultBadge').innerHTML = '<span class="badge bg-success">Đã phê duyệt</span>';
                } else {
                    resultBox.className = 'p-3 border rounded-3 mb-2 bg-danger-subtle border-danger-subtle';
                    document.getElementById('kycResultTitle').textContent = 'Hồ sơ đã bị từ chối';
                    document.getElementById('kycResultBadge').innerHTML = '<span class="badge bg-danger">Đã từ chối</span>';
                }
                document.getElementById('kycReviewerMeta').textContent = 'Người thẩm định: ' + (data.reviewerName || 'Admin') + ' • Thời gian: ' + data.reviewedAtFormatted;
                document.getElementById('kycReviewNote').textContent = data.reviewNote ? ('Lý do / Ghi chú: ' + data.reviewNote) : '';
            } else {
                resultBox.style.display = 'none';
            }

            // Action buttons in inspect footer
            const actionBtns = document.getElementById('kycInspectActionBtns');
            if (data.status === 'PENDING') {
                actionBtns.innerHTML = 
                    '<button type="button" class="btn btn-sm btn-outline-danger fw-bold px-3 me-2" onclick="bootstrap.Modal.getInstance(document.getElementById(\'kycInspectModal\')).hide(); openRejectModal(\'' + data.requestId + '\', \'' + escapeJs(data.shopName) + '\', \'' + escapeJs(data.applicantName) + '\');">' +
                        '<i class="bi bi-x me-1"></i> Từ Chối' +
                    '</button>' +
                    '<button type="button" class="btn btn-sm btn-success fw-bold px-3" style="background: #15803d; border-color: #15803d;" onclick="bootstrap.Modal.getInstance(document.getElementById(\'kycInspectModal\')).hide(); openApproveModal(\'' + data.requestId + '\', \'' + escapeJs(data.shopName) + '\', \'' + escapeJs(data.applicantName) + '\');">' +
                        '<i class="bi bi-check2 me-1"></i> Phê Duyệt Ngay' +
                    '</button>';
            } else {
                actionBtns.innerHTML = '';
            }

            loading.style.display = 'none';
            body.style.display = 'block';
        })
        .catch(err => {
            loading.innerHTML = '<div class="alert alert-danger m-2">' + err.message + '</div>';
        });
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
function openShopDetailModal(shopId) {
    const modal = bootstrap.Modal.getOrCreateInstance(document.getElementById('shopDetailModal'));
    modal.show();

    const loading = document.getElementById('shopDetailLoading');
    const body = document.getElementById('shopDetailBody');
    loading.style.display = 'block';
    body.style.display = 'none';

    const ctx = typeof getAdminContextPath === 'function' ? getAdminContextPath() : '';
    fetch(ctx + '/admin/shops?action=shopDetail&shopId=' + encodeURIComponent(shopId))
        .then(res => res.json())
        .then(data => {
            if (data.error) throw new Error(data.error);

            document.getElementById('sdShopName').textContent = data.shopName;
            document.getElementById('sdBusinessType').textContent = data.businessType + ' • ID: #' + data.shopId;
            
            let sBadge = '<span class="status-pill-green">Đang hoạt động</span>';
            if (data.status === 'SUSPENDED') sBadge = '<span class="badge bg-danger">Bị đình chỉ</span>';
            else if (data.status === 'PENDING_KYC') sBadge = '<span class="badge bg-warning text-dark">Chờ duyệt KYC</span>';
            document.getElementById('sdStatusBadge').innerHTML = sBadge;

            document.getElementById('sdOwnerName').textContent = data.ownerName;
            document.getElementById('sdPhone').textContent = data.phone || '-';
            document.getElementById('sdEmail').textContent = data.ownerEmail || '-';
            document.getElementById('sdProvince').textContent = data.province || '-';
            document.getElementById('sdAddress').textContent = data.address || '-';
            document.getElementById('sdCert').textContent = data.certificationName || 'Chưa cập nhật';
            document.getElementById('sdComm').textContent = data.commissionRate;
            document.getElementById('sdSales').textContent = data.totalSalesFormatted;
            document.getElementById('sdOrders').textContent = data.totalOrdersCount + ' đơn';

            const suspBox = document.getElementById('sdSuspendedBox');
            if (data.status === 'SUSPENDED' && data.suspendedReason) {
                suspBox.style.display = 'block';
                document.getElementById('sdSuspendedReason').textContent = data.suspendedReason;
                document.getElementById('sdSuspendedDate').textContent = 'Đình chỉ lúc: ' + data.suspendedAtFormatted;
            } else {
                suspBox.style.display = 'none';
            }

            loading.style.display = 'none';
            body.style.display = 'block';
        })
        .catch(err => {
            loading.innerHTML = '<div class="alert alert-danger m-2">' + err.message + '</div>';
        });
}

function escapeJs(str) {
    if (!str) return '';
    return String(str).replace(/'/g, "\\'").replace(/"/g, '&quot;');
}

