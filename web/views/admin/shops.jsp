<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FreshFruit - Thẩm Định & Quản Lý Gian Hàng</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css?v=16">
    <meta name="context-path" content="${pageContext.request.contextPath}">
</head>
<body class="admin-body">

<div class="admin-wrapper">
    <jsp:include page="layout/sidebar.jsp">
        <jsp:param name="activePage" value="shops" />
    </jsp:include>

    <div class="admin-main">
        <jsp:include page="layout/header.jsp" />

        <main class="admin-page-content">
            <!-- Alert Messages -->
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success alert-dismissible fade show d-flex align-items-center gap-2 mb-3 shadow-sm" role="alert" style="border-radius: 10px; font-size: 0.88rem; background: #f0fdf4; border-color: #bbf7d0; color: #166534;">
                    <i class="bi bi-check-circle-fill text-success fs-5"></i>
                    <div class="flex-grow-1">${successMessage}</div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center gap-2 mb-3 shadow-sm" role="alert" style="border-radius: 10px; font-size: 0.88rem; background: #fef2f2; border-color: #fecaca; color: #991b1b;">
                    <i class="bi bi-exclamation-triangle-fill text-danger fs-5"></i>
                    <div class="flex-grow-1">${errorMessage}</div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <!-- 1. Page Header & Actions -->
            <div class="users-page-header">
                <div>
                    <div class="d-flex align-items-center gap-2 mb-1">
                        <span class="badge-kyc-hub">Trung tâm Thẩm định & Kiểm soát Đối tác</span>
                        <span class="protocol-subtext">• Cập nhật liên tục</span>
                    </div>
                    <h1 class="users-header-title">Thẩm Định & Quản Lý Gian Hàng</h1>
                    <p class="users-header-desc">Xét duyệt hồ sơ mở shop mới (Seller Onboarding), thẩm định chứng chỉ VietGAP/GlobalGAP/HACCP/OCOP, và đình chỉ/mở lại hoạt động đối tác.</p>
                </div>
                <div class="users-header-actions">
                    <a href="${pageContext.request.contextPath}/admin/shops?status=PENDING_KYC" class="btn-add-admin text-decoration-none">
                        <i class="bi bi-file-earmark-check"></i>
                        <span>Hàng đợi duyệt KYC (${not empty shopStats.pendingKyc ? shopStats.pendingKyc : 0})</span>
                    </a>
                </div>
            </div>

            <!-- 2. Segmented Navigation Tabs -->
            <div class="users-rbac-tabs">
                <a href="${pageContext.request.contextPath}/admin/shops?status=ALL" class="rbac-tab-item ${selectedStatus == 'ALL' ? 'active' : ''}">
                    <i class="bi bi-shop"></i>
                    <span>Tất cả gian hàng</span>
                    <span class="rbac-badge">${not empty shopStats.totalShops ? shopStats.totalShops : 0}</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/shops?status=ACTIVE" class="rbac-tab-item ${selectedStatus == 'ACTIVE' ? 'active' : ''}">
                    <i class="bi bi-check-circle"></i>
                    <span>Đang hoạt động</span>
                    <span class="rbac-badge">${not empty shopStats.activeShops ? shopStats.activeShops : 0}</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/shops?status=PENDING_KYC" class="rbac-tab-item ${selectedStatus == 'PENDING_KYC' ? 'active' : ''}">
                    <i class="bi bi-file-earmark-check"></i>
                    <span>Hồ sơ mở Shop (KYC)</span>
                    <span class="rbac-badge" style="background: #fef08a; color: #854d0e;">${not empty shopStats.pendingKyc ? shopStats.pendingKyc : 0} chờ duyệt</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/shops?status=SUSPENDED" class="rbac-tab-item ${selectedStatus == 'SUSPENDED' ? 'active' : ''}">
                    <i class="bi bi-exclamation-diamond"></i>
                    <span>Bị đình chỉ / Tạm khóa</span>
                    <span class="rbac-badge" style="background: #fecaca; color: #991b1b;">${not empty shopStats.suspended ? shopStats.suspended : 0}</span>
                </a>
            </div>

            <!-- 3. Filter Toolbar -->
            <form method="GET" action="${pageContext.request.contextPath}/admin/shops" class="users-filter-card" id="shopFilterForm">
                <input type="hidden" name="status" value="${selectedStatus}">

                <div class="users-search-pill">
                    <i class="bi bi-search"></i>
                    <input type="text" name="search" id="shopSearchInput" value="<c:out value='${searchKeyword}'/>" placeholder="Tìm tên nhà vườn, người nộp, email, sđt, tỉnh thành, mã số...">
                </div>

                <div class="users-dropdown-filters">
                    <!-- Dropdown: Loại hình kinh doanh -->
                    <select name="type" id="typeFilterSelect" class="filter-select-btn" onchange="this.form.submit()">
                        <option value="ALL" ${selectedType == 'ALL' ? 'selected' : ''}>Mô hình: Tất cả</option>
                        <option value="Nhà vườn trực tiếp" ${selectedType == 'Nhà vườn trực tiếp' ? 'selected' : ''}>Nhà vườn trực tiếp</option>
                        <option value="Hợp tác xã" ${selectedType == 'Hợp tác xã' ? 'selected' : ''}>Hợp tác xã</option>
                        <option value="Hộ gia đình" ${selectedType == 'Hộ gia đình' ? 'selected' : ''}>Hộ gia đình</option>
                        <option value="Doanh nghiệp bao tiêu" ${selectedType == 'Doanh nghiệp bao tiêu' ? 'selected' : ''}>Doanh nghiệp bao tiêu</option>
                        <option value="Doanh nghiệp nhập khẩu" ${selectedType == 'Doanh nghiệp nhập khẩu' ? 'selected' : ''}>Doanh nghiệp nhập khẩu</option>
                    </select>

                    <!-- Dropdown: Tiêu chuẩn chứng nhận an toàn -->
                    <select name="cert" id="certFilterSelect" class="filter-select-btn" onchange="this.form.submit()">
                        <option value="ALL" ${selectedCert == 'ALL' ? 'selected' : ''}>Chứng nhận: Tất cả</option>
                        <option value="VietGAP" ${selectedCert == 'VietGAP' ? 'selected' : ''}>VietGAP</option>
                        <option value="GlobalGAP" ${selectedCert == 'GlobalGAP' ? 'selected' : ''}>GlobalGAP</option>
                        <option value="Organic" ${selectedCert == 'Organic' ? 'selected' : ''}>Hữu cơ Organic</option>
                        <option value="HACCP" ${selectedCert == 'HACCP' ? 'selected' : ''}>HACCP</option>
                        <option value="OCOP" ${selectedCert == 'OCOP' ? 'selected' : ''}>OCOP</option>
                        <option value="Kiểm dịch" ${selectedCert == 'Kiểm dịch' ? 'selected' : ''}>Kiểm dịch hải quan</option>
                    </select>

                    <button type="submit" class="btn btn-sm text-white d-inline-flex align-items-center gap-1" style="font-size: 0.75rem; padding: 0.38rem 0.85rem; border-radius: 8px; background: #15803d; border: 1px solid #15803d; font-weight: 600;">
                        <i class="bi bi-funnel"></i> Lọc
                    </button>

                    <c:if test="${(not empty selectedStatus && selectedStatus != 'ALL') || (not empty selectedType && selectedType != 'ALL') || (not empty selectedCert && selectedCert != 'ALL') || not empty searchKeyword}">
                        <a href="${pageContext.request.contextPath}/admin/shops?status=${selectedStatus}" class="btn btn-sm btn-outline-secondary d-inline-flex align-items-center gap-1" style="font-size: 0.75rem; padding: 0.38rem 0.85rem; border-radius: 8px;">
                            <i class="bi bi-arrow-counterclockwise"></i> Đặt lại
                        </a>
                    </c:if>
                </div>
            </form>

            <c:choose>
                <%-- ========================================================= --%>
                <%-- VIEW A: HÀNG ĐỢI XÉT DUYỆT HỒ SƠ MỞ SHOP (PENDING_KYC)    --%>
                <%-- ========================================================= --%>
                <c:when test="${selectedStatus == 'PENDING_KYC'}">
                    <div class="shops-table-container">
                        <div class="shops-table-header">
                            <div class="shops-table-title">
                                <span>Hàng Đợi Thẩm Định Hồ Sơ Mở Shop Mới (Seller Onboarding)</span>
                                <span class="badge-live-engine" style="background: #fef08a; color: #854d0e; padding: 3px 8px; border-radius: 9999px;">
                                    ${not empty shopRequestsList ? shopRequestsList.size() : 0} Hồ Sơ
                                </span>
                            </div>
                            <div class="text-muted small">Kiểm tra pháp lý, địa chỉ vườn/kho, hotline và cấp phép SHOP_OWNER</div>
                        </div>

                        <table class="shops-modern-table">
                            <thead>
                                <tr>
                                    <th>MÃ HỒ SƠ & GIAN HÀNG XIN MỞ</th>
                                    <th>MÔ HÌNH & NÔNG SẢN CHỦ LỰC</th>
                                    <th>ĐỊA CHỈ TRANG TRẠI / VÙNG TRỒNG</th>
                                    <th>PHÁP LÝ & CHỨNG NHẬN ATTP</th>
                                    <th>TRẠNG THÁI</th>
                                    <th class="text-end">THẨM ĐỊNH & THAO TÁC</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${shopRequestsList}" var="r">
                                    <tr>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="user-summary-icon-box" style="background: #fef9c3; border: 1px solid #fde047; width: 36px; height: 36px; font-size: 0.95rem; flex-shrink: 0; border-radius: 8px; display:flex; align-items:center; justify-content:center;">
                                                    <i class="bi bi-file-earmark-person-fill text-warning-emphasis"></i>
                                                </div>
                                                <div>
                                                    <strong class="text-dark fs-6" style="font-size: 0.85rem !important;">${r.shopName}</strong>
                                                    <div class="text-muted" style="font-size: 0.72rem;">Người nộp: <strong>${r.applicantName}</strong> • ${r.applicantPhone}</div>
                                                    <div class="text-muted" style="font-size: 0.68rem;">Email: ${r.applicantEmail} • Mã đơn: <strong>#REQ-${r.requestId}</strong></div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="shop-model-pill">${r.businessType}</div>
                                            <div class="text-muted mt-1" style="font-size: 0.7rem;" title="${fn:escapeXml(r.produceSpecialty)}">
                                                <i class="bi bi-basket2 text-success"></i> ${r.produceSpecialty}
                                            </div>
                                        </td>
                                        <td>
                                            <div><strong>${r.province}</strong></div>
                                            <div class="text-muted text-truncate" style="font-size: 0.7rem; max-width: 220px;" title="${fn:escapeXml(r.farmAddress)}">
                                                <i class="bi bi-geo-alt"></i> ${r.farmAddress}
                                            </div>
                                        </td>
                                        <td>
                                            <div>
                                                <span class="badge bg-light text-dark border">
                                                    <i class="bi bi-shield-check text-success"></i> ${r.certificationName}
                                                </span>
                                            </div>
                                            <div class="text-muted mt-1" style="font-size: 0.7rem;">
                                                <i class="bi bi-person-vcard text-primary"></i> CCCD: <strong>${r.idCardNumber}</strong>
                                            </div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${r.status == 'PENDING'}">
                                                    <span class="badge bg-warning-subtle text-warning-emphasis border border-warning-subtle px-2 py-1" style="border-radius: 9999px; font-size: 0.7rem; font-weight: 700;">
                                                        <i class="bi bi-hourglass-split me-1"></i> Chờ duyệt
                                                    </span>
                                                </c:when>
                                                <c:when test="${r.status == 'APPROVED'}">
                                                    <span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1" style="border-radius: 9999px; font-size: 0.7rem; font-weight: 700;">
                                                        <i class="bi bi-check-circle-fill me-1"></i> Đã phê duyệt
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-2 py-1" style="border-radius: 9999px; font-size: 0.7rem; font-weight: 700;">
                                                        <i class="bi bi-x-circle-fill me-1"></i> Đã từ chối
                                                    </span>
                                                    <c:if test="${not empty r.reviewNote}">
                                                        <div class="text-danger small mt-1" style="font-size: 0.65rem;" title="${fn:escapeXml(r.reviewNote)}">
                                                            Lý do: ${fn:escapeXml(r.reviewNote)}
                                                        </div>
                                                    </c:if>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-end text-nowrap">
                                            <!-- Nút 1: Xem hồ sơ pháp lý chi tiết -->
                                            <button type="button" class="btn-action-sm btn-action-inspect me-1" title="Xem toàn bộ hồ sơ pháp lý & chứng nhận" onclick="openKycInspectModal('${r.requestId}')">
                                                <i class="bi bi-eye"></i> Xem hồ sơ
                                            </button>

                                            <c:if test="${r.status == 'PENDING'}">
                                                <!-- Nút 2: Phê duyệt (Approve) -->
                                                <button type="button" class="btn-action-sm btn-action-approve me-1" title="Phê duyệt mở shop & cấp quyền SHOP_OWNER" onclick="openApproveModal('${r.requestId}', '${fn:escapeXml(r.shopName)}', '${fn:escapeXml(r.applicantName)}')">
                                                    <i class="bi bi-check2"></i> Duyệt
                                                </button>

                                                <!-- Nút 3: Từ chối (Reject) -->
                                                <button type="button" class="btn-action-sm btn-action-reject" title="Từ chối hồ sơ kèm lý do phản hồi" onclick="openRejectModal('${r.requestId}', '${fn:escapeXml(r.shopName)}', '${fn:escapeXml(r.applicantName)}')">
                                                    <i class="bi bi-x"></i> Từ chối
                                                </button>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty shopRequestsList}">
                                    <tr>
                                        <td colspan="6" class="text-center text-muted py-5">
                                            <i class="bi bi-check2-circle fs-1 text-success d-block mb-2"></i>
                                            Hiện không có hồ sơ đăng ký gian hàng nào đang chờ xử lý.
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>

                        <div class="users-table-footer">
                            <span>Tổng cộng <strong>${not empty shopRequestsList ? shopRequestsList.size() : 0}</strong> hồ sơ thẩm định mở shop</span>
                        </div>
                    </div>
                </c:when>

                <%-- ========================================================= --%>
                <%-- VIEW B: DANH SÁCH GIAN HÀNG ĐỐI TÁC (ALL, ACTIVE, SUSPENDED) --%>
                <%-- ========================================================= --%>
                <c:otherwise>
                    <div class="shops-table-container">
                        <div class="shops-table-header">
                            <div class="shops-table-title">
                                <span>
                                    <c:choose>
                                        <c:when test="${selectedStatus == 'ACTIVE'}">Danh Sách Gian Hàng Đang Hoạt Động Trên Sàn</c:when>
                                        <c:when test="${selectedStatus == 'SUSPENDED'}">Danh Sách Gian Hàng Bị Đình Chỉ / Tạm Khóa</c:when>
                                        <c:otherwise>Danh Sách Toàn Bộ Gian Hàng Đối Tác</c:otherwise>
                                    </c:choose>
                                </span>
                                <span class="badge-live-engine" style="background: #dcfce7; padding: 3px 8px; border-radius: 9999px;">
                                    ${not empty shopsList ? shopsList.size() : 0} Gian Hàng
                                </span>
                            </div>
                            <div class="d-flex align-items-center gap-2">
                                <button type="button" class="btn btn-sm btn-light border p-1 px-2 text-muted" title="Làm mới" onclick="location.reload();">
                                    <i class="bi bi-arrow-clockwise"></i>
                                </button>
                                <button type="button" class="btn btn-sm btn-light border p-1 px-2 text-muted" title="Tải xuống danh sách" onclick="alert('Đang tải danh sách hồ sơ (.CSV)...');">
                                    <i class="bi bi-download"></i>
                                </button>
                            </div>
                        </div>

                        <table class="shops-modern-table">
                            <thead>
                                <tr>
                                    <th>THÔNG TIN GIAN HÀNG & CHỦ SỞ HỮU</th>
                                    <th>MÔ HÌNH KINH DOANH</th>
                                    <th>CHỨNG TỪ & TIÊU CHUẨN</th>
                                    <th>DOANH SỐ / ĐƠN HÀNG</th>
                                    <th>CHIẾT KHẤU</th>
                                    <th>TRẠNG THÁI</th>
                                    <th class="text-end">THAO TÁC</th>
                                </tr>
                            </thead>
                            <tbody id="shopsTableBody">
                                <c:forEach items="${shopsList}" var="s">
                                    <tr>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="user-summary-icon-box bg-green-subtle" style="width: 36px; height: 36px; font-size: 0.95rem; flex-shrink: 0;">
                                                    <i class="bi bi-shop text-success"></i>
                                                </div>
                                                <div>
                                                    <strong class="text-dark fs-6" style="font-size: 0.85rem !important;">${s.shopName}</strong>
                                                    <div class="text-muted" style="font-size: 0.7rem;">Chủ: <strong>${s.ownerName}</strong> • ${s.phone}</div>
                                                    <div class="text-muted" style="font-size: 0.68rem;"><i class="bi bi-geo-alt"></i> ${s.province}</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="shop-model-pill">
                                                ${s.businessType}
                                            </div>
                                        </td>
                                        <td>
                                            <span class="badge bg-light text-dark border">
                                                <i class="bi bi-shield-check text-success"></i> ${s.certificationName}
                                            </span>
                                            <div class="text-muted mt-1" style="font-size: 0.68rem;">
                                                <i class="bi bi-star-fill text-warning"></i> ${s.rating} / 5.0
                                            </div>
                                        </td>
                                        <td>
                                            <div>
                                                <strong class="text-success">${s.totalSalesFormatted}</strong>
                                                <div class="text-muted" style="font-size: 0.68rem;">${s.totalOrdersCount} đơn hoàn tất</div>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="fw-bold text-dark">${s.commissionRate}</span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${s.status == 'ACTIVE'}">
                                                    <span class="status-pill-green">
                                                        <i class="bi bi-circle-fill" style="font-size: 0.45rem;"></i> Hoạt động
                                                    </span>
                                                </c:when>
                                                <c:when test="${s.status == 'PENDING_KYC'}">
                                                    <span class="badge bg-warning-subtle text-warning-emphasis border border-warning-subtle px-2 py-1" style="border-radius: 9999px; font-size: 0.68rem; font-weight: 700;">
                                                        <i class="bi bi-hourglass-split me-1"></i> Chờ duyệt KYC
                                                    </span>
                                                </c:when>
                                                <c:when test="${s.status == 'SUSPENDED'}">
                                                    <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-2 py-1" style="border-radius: 9999px; font-size: 0.68rem; font-weight: 700;" title="Lý do: ${fn:escapeXml(s.suspendedReason)}">
                                                        <i class="bi bi-exclamation-octagon-fill me-1"></i> Bị đình chỉ
                                                    </span>
                                                    <c:if test="${not empty s.suspendedReason}">
                                                        <div class="text-danger small mt-1 text-truncate" style="font-size: 0.65rem; max-width: 140px;" title="${fn:escapeXml(s.suspendedReason)}">
                                                            ${fn:escapeXml(s.suspendedReason)}
                                                        </div>
                                                    </c:if>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-pill-warning">${s.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-end text-nowrap">
                                            <!-- Nút 1: Xem chi tiết shop -->
                                            <button type="button" class="btn-action-sm btn-action-inspect me-1" title="Xem hồ sơ gian hàng" onclick="openShopDetailModal('${s.shopId}')">
                                                <i class="bi bi-eye"></i> Chi tiết
                                            </button>

                                            <!-- Nút 2: Đình chỉ hoặc Mở lại hoạt động -->
                                            <c:choose>
                                                <c:when test="${s.status == 'ACTIVE'}">
                                                    <button type="button" class="btn-action-sm btn-action-suspend" title="Đình chỉ tạm ngưng gian hàng (vi phạm chất lượng / khiếu nại)" onclick="openSuspendShopModal('${s.shopId}', '${fn:escapeXml(s.shopName)}', '${fn:escapeXml(s.ownerName)}')">
                                                        <i class="bi bi-pause-circle"></i> Đình chỉ
                                                    </button>
                                                </c:when>
                                                <c:when test="${s.status == 'SUSPENDED'}">
                                                    <button type="button" class="btn-action-sm btn-action-reactivate" title="Mở lại hoạt động bình thường cho gian hàng" onclick="openReactivateShopModal('${s.shopId}', '${fn:escapeXml(s.shopName)}', '${fn:escapeXml(s.ownerName)}')">
                                                        <i class="bi bi-play-circle"></i> Mở lại
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <a href="${pageContext.request.contextPath}/admin/shops?status=PENDING_KYC" class="btn-action-sm btn-action-approve text-decoration-none">
                                                        <i class="bi bi-file-earmark-check"></i> Duyệt KYC
                                                    </a>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty shopsList}">
                                    <tr>
                                        <td colspan="7" class="text-center text-muted py-5">
                                            <i class="bi bi-shop fs-1 text-secondary d-block mb-2"></i>
                                            Không tìm thấy gian hàng nào phù hợp với bộ lọc tìm kiếm.
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>

                        <div class="users-table-footer">
                            <span>Tổng cộng <strong>${not empty shopsList ? shopsList.size() : 0}</strong> gian hàng đối tác trong danh mục</span>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </main>
    </div>
</div>

<!-- ========================================================================= -->
<!-- MODAL 1: THẨM ĐỊNH HỒ SƠ PHÁP LÝ & AN TOÀN THỰC PHẨM (KYC INSPECT)        -->
<!-- ========================================================================= -->
<div class="modal fade" id="kycInspectModal" tabindex="-1" aria-labelledby="kycInspectModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content" style="border-radius: 14px; border: 1px solid #e2e8f0;">
            <div class="modal-header" style="border-bottom: 1px solid #f1f5f9; padding: 1.15rem 1.4rem;">
                <div>
                    <h5 class="modal-title fw-bold text-dark" id="kycInspectModalLabel" style="font-size: 1.05rem;">
                        <i class="bi bi-file-earmark-medical-fill text-success me-1"></i> Thẩm Định Hồ Sơ Mở Gian Hàng (Seller Onboarding)
                    </h5>
                    <div class="text-muted small mt-1" id="kycModalSubTitle">Mã hồ sơ: #REQ-1</div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" style="padding: 1.25rem 1.4rem;">
                <div id="kycInspectLoading" class="text-center py-5">
                    <div class="spinner-border text-success" role="status"></div>
                    <div class="text-muted small mt-2">Đang tải hồ sơ thẩm định...</div>
                </div>

                <div id="kycInspectBody" style="display: none;">
                    <div class="row g-3 mb-3">
                        <!-- Thông tin chủ hộ & Pháp lý -->
                        <div class="col-md-6">
                            <div class="kyc-doc-card h-100">
                                <h6 class="fw-bold text-dark mb-2" style="font-size: 0.85rem;"><i class="bi bi-person-bounding-box text-primary me-1"></i> Pháp Lý & Chủ Sở Hữu</h6>
                                <div class="kyc-info-row">
                                    <span class="kyc-info-label">Người đại diện:</span>
                                    <span class="kyc-info-value fw-bold" id="kycApplicantName">-</span>
                                </div>
                                <div class="kyc-info-row">
                                    <span class="kyc-info-label">Số CCCD / CMND:</span>
                                    <span class="kyc-info-value fw-bold text-primary" id="kycIdCard">-</span>
                                </div>
                                <div class="kyc-info-row">
                                    <span class="kyc-info-label">Số điện thoại:</span>
                                    <span class="kyc-info-value" id="kycApplicantPhone">-</span>
                                </div>
                                <div class="kyc-info-row">
                                    <span class="kyc-info-label">Email liên hệ:</span>
                                    <span class="kyc-info-value" id="kycApplicantEmail">-</span>
                                </div>
                                <div class="kyc-info-row">
                                    <span class="kyc-info-label">Mã tài khoản:</span>
                                    <span class="kyc-info-value" id="kycUserId">#</span>
                                </div>
                            </div>
                        </div>

                        <!-- Thông tin trang trại & Chứng nhận -->
                        <div class="col-md-6">
                            <div class="kyc-doc-card h-100">
                                <h6 class="fw-bold text-dark mb-2" style="font-size: 0.85rem;"><i class="bi bi-patch-check-fill text-success me-1"></i> Vùng Trồng & Chứng Nhận ATTP</h6>
                                <div class="kyc-info-row">
                                    <span class="kyc-info-label">Tên gian hàng:</span>
                                    <span class="kyc-info-value fw-bold text-success" id="kycShopName">-</span>
                                </div>
                                <div class="kyc-info-row">
                                    <span class="kyc-info-label">Mô hình:</span>
                                    <span class="kyc-info-value" id="kycBusinessType">-</span>
                                </div>
                                <div class="kyc-info-row">
                                    <span class="kyc-info-label">Chứng nhận ATTP:</span>
                                    <span class="kyc-info-value"><span class="badge bg-success-subtle text-success border border-success-subtle" id="kycCertName">-</span></span>
                                </div>
                                <div class="kyc-info-row">
                                    <span class="kyc-info-label">Tỉnh / Thành:</span>
                                    <span class="kyc-info-value" id="kycProvince">-</span>
                                </div>
                                <div class="kyc-info-row">
                                    <span class="kyc-info-label">Địa chỉ vườn/kho:</span>
                                    <span class="kyc-info-value" id="kycFarmAddress">-</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Nông sản chủ lực & Giới thiệu -->
                    <div class="kyc-doc-card mb-3">
                        <h6 class="fw-bold text-dark mb-2" style="font-size: 0.85rem;"><i class="bi bi-card-text text-secondary me-1"></i> Nông Sản & Giới Thiệu Nguồn Gốc</h6>
                        <div class="mb-2">
                            <strong>Trái cây chủ lực:</strong> <span id="kycSpecialty" class="text-dark">-</span>
                        </div>
                        <div>
                            <strong>Nguyện vọng / Giới thiệu:</strong>
                            <p class="text-muted small mb-0 mt-1 fst-italic" id="kycReason">-</p>
                        </div>
                    </div>

                    <!-- Kết quả thẩm định (nếu đã thẩm định) -->
                    <div id="kycReviewResultBox" style="display: none;" class="p-3 border rounded-3 mb-2">
                        <div class="d-flex align-items-center gap-2 mb-1">
                            <strong id="kycResultTitle">Kết quả thẩm định:</strong>
                            <span id="kycResultBadge"></span>
                        </div>
                        <div class="small text-muted" id="kycReviewerMeta"></div>
                        <div class="small text-dark mt-1" id="kycReviewNote"></div>
                    </div>
                </div>
            </div>
            <div class="modal-footer d-flex justify-content-between" style="border-top: 1px solid #f1f5f9; padding: 0.85rem 1.4rem;">
                <button type="button" class="btn btn-light btn-sm fw-bold px-3" data-bs-dismiss="modal" style="border-radius: 8px;">Đóng</button>
                <div id="kycInspectActionBtns">
                    <!-- Populated by JS for PENDING requests -->
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ========================================================================= -->
<!-- MODAL 2: PHÊ DUYỆT HỒ SƠ MỞ SHOP (APPROVE REQUEST)                        -->
<!-- ========================================================================= -->
<div class="modal fade" id="approveRequestModal" tabindex="-1" aria-labelledby="approveRequestModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 14px; border: 1px solid #e2e8f0;">
            <div class="modal-header" style="border-bottom: 1px solid #f1f5f9; padding: 1.15rem 1.4rem;">
                <h5 class="modal-title fw-bold text-success" id="approveRequestModalLabel" style="font-size: 1rem;">
                    <i class="bi bi-check-circle-fill me-1"></i> Phê Duyệt Hồ Sơ & Cấp Phép Mở Gian Hàng
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/shops" method="POST">
                <input type="hidden" name="action" value="approveRequest">
                <input type="hidden" name="requestId" id="approveRequestId">
                <div class="modal-body" style="padding: 1.25rem 1.4rem;">
                    <div class="alert alert-success d-flex align-items-start gap-2 mb-3" style="font-size: 0.82rem; border-radius: 8px;">
                        <i class="bi bi-info-circle-fill fs-5 text-success flex-shrink-0"></i>
                        <div>
                            <strong>TỰ ĐỘNG KÍCH HOẠT:</strong> Khi phê duyệt, hệ thống sẽ tự động <strong>kích hoạt Shop ở trạng thái ACTIVE</strong> và cấp quyền <strong>SHOP_OWNER</strong> vào tài khoản của người dùng.
                        </div>
                    </div>

                    <div class="p-3 mb-3" style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px;">
                        <div class="small text-muted mb-1">Gian hàng phê duyệt:</div>
                        <div class="fw-bold text-dark fs-6" id="approveShopNameDisplay">Nông Trại Đà Lạt</div>
                        <div class="text-muted small" id="approveApplicantDisplay">Nguyễn Văn An</div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label small fw-bold text-dark">Tỷ lệ phí hoa hồng sàn (Commission Rate)</label>
                        <div class="input-group">
                            <input type="number" step="0.1" min="1" max="50" name="commissionRate" class="form-control" value="8.0" style="font-size: 0.82rem; border-radius: 8px 0 0 8px;">
                            <span class="input-group-text small" style="border-radius: 0 8px 8px 0;">%</span>
                        </div>
                        <div class="form-text small text-muted">Mặc định hoa hồng sàn FreshFruit là 8.0%.</div>
                    </div>

                    <div class="mb-2">
                        <label class="form-label small fw-bold text-dark">Ghi chú thẩm định / Quyết định duyệt</label>
                        <textarea name="reviewNote" class="form-control" rows="2" style="font-size: 0.82rem; border-radius: 8px;" placeholder="Hồ sơ pháp lý và chứng nhận ATTP hợp lệ. Chấp thuận mở bán trên sàn."></textarea>
                    </div>
                </div>
                <div class="modal-footer" style="border-top: 1px solid #f1f5f9; padding: 0.85rem 1.4rem;">
                    <button type="button" class="btn btn-light btn-sm fw-bold px-3" data-bs-dismiss="modal" style="border-radius: 8px;">Hủy bỏ</button>
                    <button type="submit" class="btn btn-success btn-sm fw-bold px-3" style="background: #15803d; border-color: #15803d; border-radius: 8px;">
                        <i class="bi bi-check2-circle me-1"></i> Xác Nhận Phê Duyệt & Mở Gian Hàng
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ========================================================================= -->
<!-- MODAL 3: TỪ CHỐI HỒ SƠ MỞ SHOP (REJECT REQUEST)                           -->
<!-- ========================================================================= -->
<div class="modal fade" id="rejectRequestModal" tabindex="-1" aria-labelledby="rejectRequestModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 14px; border: 1px solid #e2e8f0;">
            <div class="modal-header" style="border-bottom: 1px solid #f1f5f9; padding: 1.15rem 1.4rem;">
                <h5 class="modal-title fw-bold text-danger" id="rejectRequestModalLabel" style="font-size: 1rem;">
                    <i class="bi bi-x-circle-fill me-1"></i> Từ Chối Hồ Sơ Mở Gian Hàng
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/shops" method="POST">
                <input type="hidden" name="action" value="rejectRequest">
                <input type="hidden" name="requestId" id="rejectRequestId">
                <div class="modal-body" style="padding: 1.25rem 1.4rem;">
                    <div class="p-3 mb-3" style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px;">
                        <div class="small text-muted mb-1">Hồ sơ từ chối:</div>
                        <div class="fw-bold text-dark fs-6" id="rejectShopNameDisplay">Nông Trại Đà Lạt</div>
                        <div class="text-muted small" id="rejectApplicantDisplay">Nguyễn Văn An</div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label small fw-bold text-dark">
                            Lý do từ chối phản hồi cho khách hàng <span class="text-danger">* Bắt buộc</span>
                        </label>
                        <textarea name="reviewNote" class="form-control" rows="3" required minlength="5" style="font-size: 0.82rem; border-radius: 8px;" placeholder="Ví dụ: Giấy chứng nhận VietGAP đã hết hiệu lực / Địa chỉ vùng trồng không xác minh được / Thiếu hình ảnh chụp giấy tờ thực tế..."></textarea>
                        <div class="form-text small text-muted">Lý do này sẽ được gửi phản hồi trực tiếp để nhà vườn bổ sung hồ sơ.</div>
                    </div>
                </div>
                <div class="modal-footer" style="border-top: 1px solid #f1f5f9; padding: 0.85rem 1.4rem;">
                    <button type="button" class="btn btn-light btn-sm fw-bold px-3" data-bs-dismiss="modal" style="border-radius: 8px;">Hủy bỏ</button>
                    <button type="submit" class="btn btn-danger btn-sm fw-bold px-3" style="border-radius: 8px;">
                        <i class="bi bi-x-circle me-1"></i> Xác Nhận Từ Chối Hồ Sơ
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ========================================================================= -->
<!-- MODAL 4: ĐÌNH CHỈ GIAN HÀNG VI PHẠM (SUSPEND SHOP)                       -->
<!-- ========================================================================= -->
<div class="modal fade" id="suspendShopModal" tabindex="-1" aria-labelledby="suspendShopModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 14px; border: 1px solid #e2e8f0;">
            <div class="modal-header" style="border-bottom: 1px solid #f1f5f9; padding: 1.15rem 1.4rem;">
                <h5 class="modal-title fw-bold text-danger" id="suspendShopModalLabel" style="font-size: 1rem;">
                    <i class="bi bi-exclamation-octagon-fill me-1"></i> Đình Chỉ Hoạt Động Gian Hàng (SUSPENDED)
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/shops" method="POST">
                <input type="hidden" name="action" value="suspendShop">
                <input type="hidden" name="shopId" id="suspendShopId">
                <input type="hidden" name="currentStatus" value="${selectedStatus}">
                <div class="modal-body" style="padding: 1.25rem 1.4rem;">
                    <div class="alert alert-danger d-flex align-items-start gap-2 mb-3" style="font-size: 0.82rem; border-radius: 8px;">
                        <i class="bi bi-shield-x fs-5 text-danger flex-shrink-0"></i>
                        <div>
                            <strong>CẢNH BÁO ĐÌNH CHỈ:</strong> Gian hàng sẽ bị <strong>tạm ngưng kinh doanh ngay lập tức</strong>, ẩn toàn bộ sản phẩm trên sàn người mua và không thể tạo đơn hàng mới.
                        </div>
                    </div>

                    <div class="p-3 mb-3" style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px;">
                        <div class="small text-muted mb-1">Gian hàng bị đình chỉ:</div>
                        <div class="fw-bold text-dark fs-6" id="suspendShopNameDisplay">Gian Hàng</div>
                        <div class="text-muted small" id="suspendOwnerDisplay">Chủ sở hữu</div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label small fw-bold text-dark">
                            Lý do đình chỉ quản trị <span class="text-danger">* Bắt buộc</span>
                        </label>
                        <textarea name="reason" class="form-control" rows="3" required minlength="5" style="font-size: 0.82rem; border-radius: 8px;" placeholder="Ví dụ: Phát hiện bán trái cây dập nát, tỷ lệ khiếu nại chất lượng vượt mức 5.0% trong tuần qua / Không duy trì bảo quản lạnh đúng quy chuẩn..."></textarea>
                    </div>
                </div>
                <div class="modal-footer" style="border-top: 1px solid #f1f5f9; padding: 0.85rem 1.4rem;">
                    <button type="button" class="btn btn-light btn-sm fw-bold px-3" data-bs-dismiss="modal" style="border-radius: 8px;">Hủy bỏ</button>
                    <button type="submit" class="btn btn-danger btn-sm fw-bold px-3" style="border-radius: 8px;">
                        <i class="bi bi-slash-circle me-1"></i> Xác Nhận Đình Chỉ Gian Hàng
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ========================================================================= -->
<!-- MODAL 5: MỞ LẠI HOẠT ĐỘNG GIAN HÀNG (REACTIVATE SHOP)                     -->
<!-- ========================================================================= -->
<div class="modal fade" id="reactivateShopModal" tabindex="-1" aria-labelledby="reactivateShopModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 14px; border: 1px solid #e2e8f0;">
            <div class="modal-header" style="border-bottom: 1px solid #f1f5f9; padding: 1.15rem 1.4rem;">
                <h5 class="modal-title fw-bold text-success" id="reactivateShopModalLabel" style="font-size: 1rem;">
                    <i class="bi bi-play-circle-fill me-1"></i> Mở Lại Hoạt Động Gian Hàng (Khôi phục ACTIVE)
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/shops" method="POST">
                <input type="hidden" name="action" value="reactivateShop">
                <input type="hidden" name="shopId" id="reactivateShopId">
                <input type="hidden" name="currentStatus" value="${selectedStatus}">
                <div class="modal-body" style="padding: 1.25rem 1.4rem;">
                    <div class="alert alert-success d-flex align-items-start gap-2 mb-3" style="font-size: 0.82rem; border-radius: 8px;">
                        <i class="bi bi-check-circle-fill fs-5 text-success flex-shrink-0"></i>
                        <div>
                            <strong>KHÔI PHỤC HOẠT ĐỘNG:</strong> Gian hàng sẽ chuyển lại sang trạng thái <strong>ACTIVE</strong>, mở lại hiển thị sản phẩm và tiếp tục nhận đơn hàng bình thường.
                        </div>
                    </div>

                    <div class="p-3 mb-2" style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px;">
                        <div class="small text-muted mb-1">Gian hàng mở lại:</div>
                        <div class="fw-bold text-dark fs-6" id="reactivateShopNameDisplay">Gian Hàng</div>
                        <div class="text-muted small" id="reactivateOwnerDisplay">Chủ sở hữu</div>
                    </div>
                </div>
                <div class="modal-footer" style="border-top: 1px solid #f1f5f9; padding: 0.85rem 1.4rem;">
                    <button type="button" class="btn btn-light btn-sm fw-bold px-3" data-bs-dismiss="modal" style="border-radius: 8px;">Hủy bỏ</button>
                    <button type="submit" class="btn btn-success btn-sm fw-bold px-3" style="background: #15803d; border-color: #15803d; border-radius: 8px;">
                        <i class="bi bi-play-fill me-1"></i> Xác Nhận Mở Lại Gian Hàng
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ========================================================================= -->
<!-- MODAL 6: XEM CHI TIẾT GIAN HÀNG (SHOP DETAIL)                             -->
<!-- ========================================================================= -->
<div class="modal fade" id="shopDetailModal" tabindex="-1" aria-labelledby="shopDetailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 14px; border: 1px solid #e2e8f0;">
            <div class="modal-header" style="border-bottom: 1px solid #f1f5f9; padding: 1.15rem 1.4rem;">
                <h5 class="modal-title fw-bold text-dark" id="shopDetailModalLabel" style="font-size: 1rem;">
                    <i class="bi bi-shop text-success me-1"></i> Chi Tiết Gian Hàng Đối Tác
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" style="padding: 1.25rem 1.4rem;">
                <div id="shopDetailLoading" class="text-center py-4">
                    <div class="spinner-border text-success" role="status"></div>
                </div>
                <div id="shopDetailBody" style="display: none;">
                    <div class="d-flex align-items-center gap-3 p-3 rounded-3 mb-3" style="background: #f0fdf4; border: 1px solid #dcfce7;">
                        <div class="user-summary-icon-box bg-white text-success fs-4" style="width: 48px; height: 48px; border-radius: 10px; display:flex; align-items:center; justify-content:center;">
                            <i class="bi bi-shop"></i>
                        </div>
                        <div>
                            <h6 class="fw-bold text-dark mb-0 fs-6" id="sdShopName">-</h6>
                            <div class="text-muted small" id="sdBusinessType">-</div>
                            <div class="mt-1" id="sdStatusBadge"></div>
                        </div>
                    </div>

                    <div class="kyc-doc-card mb-2">
                        <div class="kyc-info-row"><span class="kyc-info-label">Chủ sở hữu:</span><span class="kyc-info-value fw-bold" id="sdOwnerName">-</span></div>
                        <div class="kyc-info-row"><span class="kyc-info-label">Hotline:</span><span class="kyc-info-value" id="sdPhone">-</span></div>
                        <div class="kyc-info-row"><span class="kyc-info-label">Email:</span><span class="kyc-info-value" id="sdEmail">-</span></div>
                        <div class="kyc-info-row"><span class="kyc-info-label">Tỉnh / Thành:</span><span class="kyc-info-value" id="sdProvince">-</span></div>
                        <div class="kyc-info-row"><span class="kyc-info-label">Địa chỉ kho/vườn:</span><span class="kyc-info-value" id="sdAddress">-</span></div>
                        <div class="kyc-info-row"><span class="kyc-info-label">Chứng nhận ATTP:</span><span class="kyc-info-value fw-bold text-success" id="sdCert">-</span></div>
                        <div class="kyc-info-row"><span class="kyc-info-label">Chiết khấu sàn:</span><span class="kyc-info-value fw-bold" id="sdComm">-</span></div>
                        <div class="kyc-info-row"><span class="kyc-info-label">Tổng doanh số:</span><span class="kyc-info-value fw-bold text-success" id="sdSales">-</span></div>
                        <div class="kyc-info-row"><span class="kyc-info-label">Tổng đơn bán:</span><span class="kyc-info-value" id="sdOrders">-</span></div>
                    </div>

                    <div id="sdSuspendedBox" style="display: none;" class="alert alert-danger mt-2 mb-0 small">
                        <strong>Lý do đình chỉ:</strong> <span id="sdSuspendedReason">-</span>
                        <div class="text-muted mt-1" id="sdSuspendedDate" style="font-size: 0.72rem;"></div>
                    </div>
                </div>
            </div>
            <div class="modal-footer" style="border-top: 1px solid #f1f5f9; padding: 0.85rem 1.4rem;">
                <button type="button" class="btn btn-light btn-sm fw-bold px-3" data-bs-dismiss="modal" style="border-radius: 8px;">Đóng</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/admin.js?v=16"></script>
<script src="${pageContext.request.contextPath}/assets/js/admin-shops.js"></script>
</body>
</html>
