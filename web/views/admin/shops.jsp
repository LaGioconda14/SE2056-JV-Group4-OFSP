<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FreshFruit - Quản Lý Gian Hàng & Hồ Sơ Đăng Ký (Shops & Applications)</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css?v=13">
</head>
<body class="admin-body">

<div class="admin-wrapper">
    <jsp:include page="layout/sidebar.jsp">
        <jsp:param name="activePage" value="shops" />
    </jsp:include>

    <div class="admin-main">
        <jsp:include page="layout/header.jsp" />

        <main class="admin-page-content">
            <!-- 1. Page Header & Actions -->
            <div class="users-page-header">
                <div>
                    <div class="d-flex align-items-center gap-2 mb-1">
                        <span class="badge-kyc-hub">KYC & Compliance Hub</span>
                        <span class="protocol-subtext">• Cập nhật tức thời</span>
                    </div>
                    <h1 class="users-header-title">Quản Lý Gian Hàng & Hồ Sơ Đăng Ký (Shops & Applications)</h1>
                    <p class="users-header-desc">Xét duyệt hồ sơ đối tác mở gian hàng, thẩm định chứng chỉ VietGAP/GlobalGAP và giám sát uy tín nhà vườn.</p>
                </div>
                <div class="users-header-actions">
                    <button type="button" class="btn-export-list" onclick="alert('Đang tạo liên kết mời đối tác nhà vườn tham gia...');">
                        <i class="bi bi-link-45deg"></i>
                        <span>Mời Nhà vườn tham gia sàn</span>
                    </button>
                    <button type="button" class="btn-add-admin" ${shopStats.pendingKyc == 0 ? 'disabled style="opacity:.55;cursor:not-allowed;"' : ''}
                            onclick="approveAllPending(${shopStats.pendingKyc})">
                        <i class="bi bi-check2-all"></i>
                        <span>Duyệt hàng loạt (${shopStats.pendingKyc})</span>
                    </button>
                </div>
            </div>

            <c:if test="${not empty flashMessage}">
                <div class="alert alert-${flashType == 'success' ? 'success' : 'danger'} d-flex align-items-center gap-2 py-2" style="font-size:.82rem; border-radius:12px;">
                    <i class="bi ${flashType == 'success' ? 'bi-check-circle-fill' : 'bi-exclamation-triangle-fill'}"></i>
                    <span><c:out value="${flashMessage}"/></span>
                </div>
            </c:if>

            <!-- 2. 4 Summary Metric Cards -->
            <div class="shops-summary-grid">
                <!-- Card 1: Hồ sơ chờ thẩm định -->
                <div class="user-summary-card">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-1">
                            <span class="user-summary-title">Hồ sơ chờ thẩm định</span>
                            <span class="badge-counter-orange" style="font-size: 0.65rem;">${shopStats.pendingKyc} Đang Chờ</span>
                        </div>
                        <div class="user-summary-val">${shopStats.pendingKyc} <span class="fs-6 fw-normal text-muted">đơn</span></div>
                        <c:choose>
                            <c:when test="${shopStats.pendingKyc > 0}">
                                <div class="text-danger fw-bold d-flex align-items-center gap-1" style="font-size: 0.72rem;">
                                    <i class="bi bi-exclamation-circle-fill"></i> Cần xử lý sớm
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="text-success d-flex align-items-center gap-1" style="font-size: 0.72rem;">
                                    <i class="bi bi-check-circle-fill"></i> Không còn hồ sơ tồn đọng
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="shop-kpi-sub-row">
                        <span class="text-uppercase" style="letter-spacing: 0.04em;">HỒ SƠ CHỜ LÂU NHẤT</span>
                        <strong class="text-dark">${shopStats.oldestPendingDays >= 0 ? shopStats.oldestPendingDays : 0} ngày</strong>
                    </div>
                </div>

                <!-- Card 2: Gian hàng đang hoạt động -->
                <div class="user-summary-card">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-1">
                            <span class="user-summary-title">Gian hàng đang hoạt động</span>
                            <span class="badge-kpi-growth" style="font-size: 0.65rem;">Đã xác minh</span>
                        </div>
                        <div class="user-summary-val">${shopStats.activeShops} <span class="fs-6 fw-normal text-muted">shop</span></div>
                        <div class="text-success d-flex align-items-center gap-1" style="font-size: 0.72rem;">
                            <i class="bi bi-check-circle-fill"></i> Đang mở bán trên sàn
                        </div>
                    </div>
                    <div class="shop-kpi-sub-row">
                        <span class="text-uppercase" style="letter-spacing: 0.04em;">ĐÃ DUYỆT / TỔNG HỒ SƠ</span>
                        <strong class="text-dark">${shopStats.approvedShops} / ${shopStats.totalShops}</strong>
                    </div>
                </div>

                <!-- Card 3: Hoa hồng -->
                <div class="user-summary-card">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-1">
                            <span class="user-summary-title">Mức hoa hồng trung bình</span>
                            <div class="user-summary-icon-box bg-green-subtle">
                                <i class="bi bi-wallet2"></i>
                            </div>
                        </div>
                        <div class="user-summary-val" style="font-size: 1.45rem;">${shopStats.avgComm}</div>
                        <div class="text-success d-flex align-items-center gap-1" style="font-size: 0.72rem;">
                            <i class="bi bi-graph-up-arrow"></i> Chiết khấu hoa hồng sàn
                        </div>
                    </div>
                    <div class="shop-kpi-sub-row">
                        <span class="text-uppercase" style="letter-spacing: 0.04em;">TỶ LỆ TAKE RATE</span>
                        <strong class="text-success">Theo hợp đồng</strong>
                    </div>
                </div>

                <!-- Card 4: Bị tạm khóa -->
                <div class="user-summary-card">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-1">
                            <span class="user-summary-title">Gian hàng bị tạm khóa</span>
                            <span class="badge-counter-red" style="font-size: 0.65rem;">Giám sát</span>
                        </div>
                        <div class="user-summary-val text-danger">${shopStats.suspended} <span class="fs-6 fw-normal text-muted">shop</span></div>
                        <div class="text-muted d-flex align-items-center gap-1" style="font-size: 0.7rem;">
                            <i class="bi bi-exclamation-triangle-fill text-warning"></i> ${shopStats.openDisputes} khiếu nại đang xử lý trên sàn
                        </div>
                    </div>
                    <div class="shop-kpi-sub-row">
                        <span class="text-uppercase" style="letter-spacing: 0.04em;">TỈ LỆ BỊ KHÓA</span>
                        <strong class="text-danger">${shopStats.suspendRate}% shop đã duyệt</strong>
                    </div>
                </div>
            </div>

            <!-- 3. Segmented Navigation Tabs -->
            <div class="users-rbac-tabs">
                <a href="${pageContext.request.contextPath}/admin/shops?status=ALL" class="rbac-tab-item ${selectedStatus == 'ALL' ? 'active' : ''}">
                    <i class="bi bi-shop"></i>
                    <span>Tất cả gian hàng</span>
                    <span class="rbac-badge">${shopStats.totalShops}</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/shops?status=ACTIVE" class="rbac-tab-item ${selectedStatus == 'ACTIVE' ? 'active' : ''}">
                    <i class="bi bi-check-circle"></i>
                    <span>Đang hoạt động</span>
                    <span class="rbac-badge">${shopStats.activeShops}</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/shops?status=PENDING_KYC" class="rbac-tab-item ${selectedStatus == 'PENDING_KYC' ? 'active' : ''}">
                    <i class="bi bi-file-earmark-check"></i>
                    <span>Chờ xét duyệt KYC</span>
                    <span class="rbac-badge">${shopStats.pendingKyc}</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/shops?status=SUSPENDED" class="rbac-tab-item ${selectedStatus == 'SUSPENDED' ? 'active' : ''}">
                    <i class="bi bi-lock"></i>
                    <span>Bị tạm khóa</span>
                    <span class="rbac-badge">${shopStats.suspended}</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/shops?status=REJECTED" class="rbac-tab-item ${selectedStatus == 'REJECTED' ? 'active' : ''}">
                    <i class="bi bi-x-octagon"></i>
                    <span>Đã từ chối</span>
                    <span class="rbac-badge">${shopStats.rejected}</span>
                </a>
            </div>

            <!-- 4. Filter Toolbar -->
            <form method="GET" action="${pageContext.request.contextPath}/admin/shops" class="users-filter-card" id="shopFilterForm">
                <input type="hidden" name="status" value="${selectedStatus}">

                <div class="users-search-pill">
                    <i class="bi bi-search"></i>
                    <input type="text" name="search" id="shopSearchInput" value="<c:out value='${searchKeyword}'/>" placeholder="Tìm tên nhà vườn, chủ sở hữu, email, tỉnh thành...">
                </div>

                <div class="users-dropdown-filters">
                    <select name="type" id="typeFilterSelect" class="filter-select-btn" onchange="this.form.submit()">
                        <option value="ALL" ${selectedType == 'ALL' ? 'selected' : ''}>Loại hình: Tất cả</option>
                        <c:forEach items="${businessTypes}" var="bt">
                            <option value="<c:out value='${bt}'/>" ${selectedType == bt ? 'selected' : ''}><c:out value="${bt}"/></option>
                        </c:forEach>
                    </select>

                    <button type="submit" class="btn btn-sm text-white d-inline-flex align-items-center gap-1" style="font-size: 0.75rem; padding: 0.38rem 0.85rem; border-radius: 8px; background: #15803d; border: 1px solid #15803d; font-weight: 600;">
                        <i class="bi bi-funnel"></i> Lọc
                    </button>

                    <c:if test="${(not empty selectedType && selectedType != 'ALL') || not empty searchKeyword}">
                        <a href="${pageContext.request.contextPath}/admin/shops?status=${selectedStatus}" class="btn btn-sm btn-outline-secondary d-inline-flex align-items-center gap-1" style="font-size: 0.75rem; padding: 0.38rem 0.85rem; border-radius: 8px;">
                            <i class="bi bi-arrow-counterclockwise"></i> Đặt lại
                        </a>
                    </c:if>
                </div>
            </form>

            <!-- 5. Applications Queue Table -->
            <div class="shops-table-container">
                <div class="shops-table-header">
                    <div class="shops-table-title">
                        <span>
                            <c:choose>
                                <c:when test="${selectedStatus == 'ACTIVE'}">Danh sách Gian hàng Đang hoạt động</c:when>
                                <c:when test="${selectedStatus == 'PENDING_KYC'}">Danh sách Hồ sơ Đăng ký chờ xét duyệt (KYC Queue)</c:when>
                                <c:when test="${selectedStatus == 'SUSPENDED'}">Danh sách Gian hàng Bị tạm khóa</c:when>
                                <c:when test="${selectedStatus == 'REJECTED'}">Danh sách Hồ sơ Đã bị từ chối</c:when>
                                <c:otherwise>Danh sách Toàn bộ Gian hàng Đối tác</c:otherwise>
                            </c:choose>
                        </span>
                        <span class="badge-live-engine" style="background: #dcfce7; padding: 3px 8px; border-radius: 9999px;">${not empty shopsList ? shopsList.size() : 0} Gian Hàng</span>
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
                            <th>THÔNG TIN THANH TOÁN</th>
                            <th>TRẠNG THÁI</th>
                            <th style="min-width:230px;">THAO TÁC</th>
                        </tr>
                    </thead>
                    <tbody id="shopsTableBody">
                        <c:forEach items="${shopsList}" var="s">
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <c:choose>
                                            <c:when test="${not empty s.shopLogoUrl}">
                                                <img src="${s.shopLogoUrl}" class="rounded-circle" width="36" height="36" style="object-fit: cover;">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="user-summary-icon-box bg-green-subtle" style="width: 36px; height: 36px; font-size: 0.95rem; flex-shrink: 0;">
                                                    <i class="bi bi-shop text-success"></i>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                        <div>
                                            <strong class="text-dark fs-6" style="font-size: 0.85rem !important;"><c:out value="${s.shopName}"/></strong>
                                            <div class="text-muted" style="font-size: 0.7rem;">CCCD: ${s.idCardNumber} • MST: ${not empty s.taxCode ? s.taxCode : 'Không có'}</div>
                                            <div class="text-muted" style="font-size: 0.68rem;"><i class="bi bi-geo-alt"></i> ${s.streetAddress}, ${s.ward}, ${s.district}, ${s.province}</div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div class="shop-model-pill">
                                        ${s.businessType}
                                    </div>
                                </td>
                                <td>
                                    <div style="font-size: 0.75rem;">
                                        <div><strong>Ngân hàng:</strong> ${s.bankName}</div>
                                        <div><strong>STK:</strong> ${s.bankAccountNumber}</div>
                                        <div><strong>Chủ TK:</strong> ${s.bankAccountHolder}</div>
                                    </div>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${s.status == 'ACTIVE'}"><span class="shop-state st-active"><i class="bi bi-check-circle-fill"></i> Đang hoạt động</span></c:when>
                                        <c:when test="${s.status == 'PAUSED'}"><span class="shop-state st-paused"><i class="bi bi-pause-circle-fill"></i> Shop tạm ngưng</span></c:when>
                                        <c:when test="${s.status == 'CLOSED'}"><span class="shop-state st-closed"><i class="bi bi-moon-fill"></i> Đóng cửa</span></c:when>
                                        <c:when test="${s.status == 'SUSPENDED'}"><span class="shop-state st-suspended"><i class="bi bi-lock-fill"></i> Tạm khóa</span></c:when>
                                        <c:when test="${s.status == 'PENDING'}"><span class="shop-state st-pending"><i class="bi bi-hourglass-split"></i> Chờ duyệt KYC</span></c:when>
                                        <c:when test="${s.status == 'REJECTED'}"><span class="shop-state st-rejected"><i class="bi bi-x-circle-fill"></i> Đã từ chối</span></c:when>
                                        <c:otherwise><span class="shop-state st-closed"><c:out value="${s.status}"/></span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="d-flex align-items-center flex-wrap gap-2">
                                        <button type="button" class="act-btn act-view" onclick="openDetail(${s.requestId})" title="Xem chi tiết hồ sơ">
                                            <i class="bi bi-eye-fill"></i><span>Chi tiết</span>
                                        </button>
                                        <c:if test="${s.status == 'PENDING'}">
                                            <button type="button" class="act-btn act-approve" onclick="approveShop(${s.requestId})" title="Duyệt gian hàng">
                                                <i class="bi bi-check-lg"></i><span>Duyệt</span>
                                            </button>
                                            <button type="button" class="act-btn act-reject" onclick="openRejectModal(${s.requestId})" title="Từ chối hồ sơ">
                                                <i class="bi bi-x-lg"></i><span>Từ chối</span>
                                            </button>
                                        </c:if>
                                        <c:if test="${s.status == 'ACTIVE' || s.status == 'PAUSED' || s.status == 'CLOSED'}">
                                            <button type="button" class="act-btn act-suspend" onclick="openSuspendModal(${s.requestId})" title="Tạm khóa gian hàng">
                                                <i class="bi bi-lock-fill"></i><span>Tạm khóa</span>
                                            </button>
                                        </c:if>
                                        <c:if test="${s.status == 'SUSPENDED'}">
                                            <button type="button" class="act-btn act-unlock" onclick="unlockShop(${s.requestId})" title="Mở khóa gian hàng">
                                                <i class="bi bi-unlock-fill"></i><span>Mở khóa</span>
                                            </button>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty shopsList}">
                            <tr>
                                <td colspan="5" class="text-center text-muted py-4">Chưa có gian hàng nào trong danh sách.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>

                <!-- Pagination Footer -->
                <div class="users-table-footer">
                    <span>Tổng cộng <strong>${not empty shopsList ? shopsList.size() : 0}</strong> gian hàng đối tác</span>
                </div>
            </div>

            <!-- 6. Bottom Split Section -->
            <div class="bottom-split-grid" style="grid-template-columns: 1fr;">
                <!-- Left (2/3): Quy trình chuẩn thẩm định 3 bước -->
                <div class="sop-process-card">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-2">
                            <div class="d-flex align-items-center gap-2">
                                <div class="kpi-icon-box bg-green-subtle">
                                    <i class="bi bi-file-earmark-check-fill text-success"></i>
                                </div>
                                <h3 class="role-matrix-title mb-0">Quy Trình Chuẩn Thẩm Định Đối Tác Nông Nghiệp (3 Bước)</h3>
                            </div>
                            <span class="table-pill-badge" style="background: #f1f5f9; font-size: 0.65rem;">SOP FRESHFRUIT 2024</span>
                        </div>
                        <p class="role-matrix-desc">Mỗi gian hàng trước khi được kích hoạt kinh doanh trái cây trên sàn đều phải trải qua quy trình kiểm soát chuỗi lạnh và chứng nhận nguồn gốc xuất xứ.</p>

                        <!-- 3 Steps -->
                        <div class="sop-steps-grid">
                            <!-- Step 1 -->
                            <div class="sop-step-box">
                                <div>
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="step-num-circle">1</span>
                                        <strong class="text-dark" style="font-size: 0.78rem;">Xác thực pháp lý</strong>
                                    </div>
                                    <p class="text-muted" style="font-size: 0.7rem; line-height: 1.45;">
                                        Đối soát CCCD gắn chip chủ nhà vườn, kiểm tra Mã Số Thuế doanh nghiệp & giấy phép kinh doanh hợp lệ qua cổng CSDL Quốc gia.
                                    </p>
                                </div>
                                <div class="mt-2 pt-2 border-top text-success fw-bold d-flex align-items-center gap-1" style="font-size: 0.68rem; border-color: #e2e8f0 !important;">
                                    <i class="bi bi-check2-circle"></i> Tự động qua OCR AI
                                </div>
                            </div>

                            <!-- Step 2 -->
                            <div class="sop-step-box">
                                <div>
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="step-num-circle">2</span>
                                        <strong class="text-dark" style="font-size: 0.78rem;">Thẩm định chứng chỉ</strong>
                                    </div>
                                    <p class="text-muted" style="font-size: 0.7rem; line-height: 1.45;">
                                        Tra cứu tính hợp lệ của giấy chứng nhận VietGAP, GlobalGAP, OCOP còn thời hạn; kiểm tra mã số vùng trồng cấp bởi Cục BVTV.
                                    </p>
                                </div>
                                <div class="mt-2 pt-2 border-top text-primary fw-bold d-flex align-items-center gap-1" style="font-size: 0.68rem; border-color: #e2e8f0 !important;">
                                    <i class="bi bi-person-check"></i> Cần chuyên viên duyệt
                                </div>
                            </div>

                            <!-- Step 3 -->
                            <div class="sop-step-box">
                                <div>
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="step-num-circle">3</span>
                                        <strong class="text-dark" style="font-size: 0.78rem;">Ký cam kết chất lượng</strong>
                                    </div>
                                    <p class="text-muted" style="font-size: 0.7rem; line-height: 1.45;">
                                        Ký điện tử thỏa thuận bảo quản chuỗi lạnh (≤ 8°C cho trái cây tươi), cam kết bồi thường 100% nếu dập nát và kích hoạt mở bán.
                                    </p>
                                </div>
                                <div class="mt-2 pt-2 border-top text-success fw-bold d-flex align-items-center gap-1" style="font-size: 0.68rem; border-color: #e2e8f0 !important;">
                                    <i class="bi bi-lightning-charge"></i> Kích hoạt ngay lập tức
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="d-flex align-items-center justify-content-between pt-2 border-top" style="border-color: #f1f5f9 !important;">
                        <span class="text-muted" style="font-size: 0.72rem;">
                            <i class="bi bi-headset text-success"></i> Đội ngũ Thẩm định Nông sản: Trực tuyến 08:00 - 22:00 hàng ngày
                        </span>
                        <a href="javascript:void(0)" onclick="alert('Đang mở sổ tay thẩm định VietGAP/GlobalGAP...');" class="text-success fw-bold text-decoration-none" style="font-size: 0.74rem;">
                            Xem sổ tay hướng dẫn thẩm định VietGAP →
                        </a>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<!-- MODAL CHI TIẾT GIAN HÀNG -->
<div class="modal fade" id="detailModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-scrollable modal-dialog-centered">
        <div class="modal-content shop-detail-modal">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold text-success" style="font-size:.95rem;"><i class="bi bi-file-earmark-text"></i> Chi tiết hồ sơ gian hàng</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="detailBody"></div>
            <div class="modal-footer" id="detailFooter"></div>
        </div>
    </div>
</div>

<!-- MODAL TỪ CHỐI -->
<div class="modal fade" id="rejectModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <form action="${pageContext.request.contextPath}/admin/shops" method="POST">
            <input type="hidden" name="action" value="reject">
            <input type="hidden" name="tab" value="${selectedStatus}">
            <input type="hidden" name="id" id="rejectRequestId">
            <div class="modal-content" style="border-radius:16px; overflow:hidden;">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title" style="font-size:.95rem;"><i class="bi bi-x-octagon"></i> Từ chối hồ sơ: <span id="rejectShopName"></span></h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <label class="form-label fw-bold" style="font-size:.82rem;">Lý do từ chối (sẽ gửi thông báo cho người bán) <span class="text-danger">*</span></label>
                    <textarea class="form-control" name="reason" rows="4" placeholder="Ví dụ: Ảnh CCCD bị mờ, thông tin ngân hàng không hợp lệ..." required></textarea>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-danger btn-sm">Xác nhận từ chối</button>
                </div>
            </div>
        </form>
    </div>
</div>

<!-- MODAL TẠM KHÓA -->
<div class="modal fade" id="suspendModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <form action="${pageContext.request.contextPath}/admin/shops" method="POST">
            <input type="hidden" name="action" value="suspend">
            <input type="hidden" name="tab" value="${selectedStatus}">
            <input type="hidden" name="id" id="suspendRequestId">
            <div class="modal-content" style="border-radius:16px; overflow:hidden;">
                <div class="modal-header text-white" style="background:#d97706;">
                    <h5 class="modal-title" style="font-size:.95rem;"><i class="bi bi-lock-fill"></i> Tạm khóa gian hàng: <span id="suspendShopName"></span></h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="alert alert-warning py-2" style="font-size:.78rem;">
                        Shop sẽ bị ẩn khỏi sàn và không thể tự mở lại. Hệ thống sẽ gửi thông báo kèm lý do cho chủ shop.
                    </div>
                    <label class="form-label fw-bold" style="font-size:.82rem;">Lý do tạm khóa <span class="text-danger">*</span></label>
                    <textarea class="form-control" name="reason" rows="4" placeholder="Ví dụ: Nhiều khiếu nại về chất lượng trái cây, vi phạm chính sách bảo quản lạnh..." required></textarea>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-sm text-white" style="background:#d97706;">Xác nhận tạm khóa</button>
                </div>
            </div>
        </form>
    </div>
</div>

<!-- Form ẩn cho các thao tác đơn giản (duyệt / mở khóa / duyệt hàng loạt) -->
<form id="quickActionForm" action="${pageContext.request.contextPath}/admin/shops" method="POST" style="display:none;">
    <input type="hidden" name="action" id="qaAction">
    <input type="hidden" name="id" id="qaId">
    <input type="hidden" name="tab" value="${selectedStatus}">
</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/admin.js?v=13"></script>
<script>
    const CTX = '${pageContext.request.contextPath}';
    const SHOPS = ${empty shopsJson ? '[]' : shopsJson};
    const SHOP_MAP = {};
    SHOPS.forEach(function (s) { SHOP_MAP[s.requestId] = s; });

    function esc(v) {
        if (v === null || v === undefined || v === '') return '';
        return String(v).replace(/[&<>"']/g, function (c) {
            return {'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'}[c];
        });
    }
    function val(v) { return v ? esc(v) : '<span class="text-muted fst-italic">Chưa cung cấp</span>'; }
    function imgUrl(u) {
        if (!u) return '';
        if (/^(https?:|data:)/i.test(u)) return u;
        return CTX + '/' + u.replace(/^\/+/, '');
    }
    function showModal(id) { bootstrap.Modal.getOrCreateInstance(document.getElementById(id)).show(); }
    function hideModal(id) { bootstrap.Modal.getOrCreateInstance(document.getElementById(id)).hide(); }
    function submitQuick(action, id) {
        document.getElementById('qaAction').value = action;
        document.getElementById('qaId').value = id || '';
        document.getElementById('quickActionForm').submit();
    }

    function approveShop(id) {
        var s = SHOP_MAP[id];
        if (confirm('Duyệt gian hàng "' + (s ? s.shopName : '') + '"?')) submitQuick('approve', id);
    }
    function unlockShop(id) {
        var s = SHOP_MAP[id];
        if (confirm('Mở khóa gian hàng "' + (s ? s.shopName : '') + '"?')) submitQuick('unlock', id);
    }
    function approveAllPending(n) {
        if (n > 0 && confirm('Duyệt tất cả ' + n + ' hồ sơ đang chờ?')) submitQuick('approveAll', '');
    }
    function openRejectModal(id) {
        hideModal('detailModal');
        var s = SHOP_MAP[id];
        document.getElementById('rejectRequestId').value = id;
        document.getElementById('rejectShopName').innerText = s ? s.shopName : '';
        setTimeout(function () { showModal('rejectModal'); }, 200);
    }
    function openSuspendModal(id) {
        hideModal('detailModal');
        var s = SHOP_MAP[id];
        document.getElementById('suspendRequestId').value = id;
        document.getElementById('suspendShopName').innerText = s ? s.shopName : '';
        setTimeout(function () { showModal('suspendModal'); }, 200);
    }

    var STATUS_VIEW = {
        ACTIVE:    ['st-active', 'bi-check-circle-fill', 'Đang hoạt động'],
        PAUSED:    ['st-paused', 'bi-pause-circle-fill', 'Shop tạm ngưng'],
        CLOSED:    ['st-closed', 'bi-moon-fill', 'Đóng cửa'],
        SUSPENDED: ['st-suspended', 'bi-lock-fill', 'Tạm khóa'],
        PENDING:   ['st-pending', 'bi-hourglass-split', 'Chờ duyệt KYC'],
        REJECTED:  ['st-rejected', 'bi-x-circle-fill', 'Đã từ chối']
    };

    function field(label, html) {
        return '<div class="dt-field"><span class="dt-label">' + label + '</span><span class="dt-value">' + html + '</span></div>';
    }
    function idImage(label, url) {
        var u = imgUrl(url);
        return '<div class="dt-idimg"><span class="dt-label">' + label + '</span>' +
            (u ? '<a href="' + esc(u) + '" target="_blank"><img src="' + esc(u) + '" alt="' + label + '"></a>'
               : '<div class="dt-noimg"><i class="bi bi-image"></i> Chưa có ảnh</div>') + '</div>';
    }

    function openDetail(id) {
        var s = SHOP_MAP[id];
        if (!s) return;
        var sv = STATUS_VIEW[s.status] || ['st-closed', 'bi-dot', s.status];
        var banner = imgUrl(s.shopBannerUrl);
        var logo = imgUrl(s.shopLogoUrl);
        var address = [s.streetAddress, s.ward, s.district, s.province].filter(Boolean).join(', ');

        var h = '';
        // --- Banner + logo (kiểu trang profile) ---
        h += '<div class="dt-banner" style="' + (banner ? "background-image:url('" + esc(banner) + "')" : '') + '"></div>';
        h += '<div class="dt-head">';
        h += (logo ? '<img class="dt-logo" src="' + esc(logo) + '" alt="logo">'
                   : '<div class="dt-logo dt-logo-empty"><i class="bi bi-shop"></i></div>');
        h += '<div class="dt-head-info"><h4>' + esc(s.shopName) + '</h4>' +
             '<div class="d-flex flex-wrap align-items-center gap-2 mt-1">' +
             '<span class="shop-state ' + sv[0] + '"><i class="bi ' + sv[1] + '"></i> ' + sv[2] + '</span>' +
             (s.businessType ? '<span class="shop-model-pill">' + esc(s.businessType) + '</span>' : '') +
             '<span class="text-muted" style="font-size:.7rem;">Mã hồ sơ #' + s.requestId + '</span></div></div></div>';

        // --- Mô tả ---
        h += '<div class="dt-section"><div class="dt-title"><i class="bi bi-card-text"></i> Giới thiệu gian hàng</div>' +
             '<p class="dt-desc">' + (s.shopDescription ? esc(s.shopDescription) : '<span class="text-muted fst-italic">Chưa có mô tả</span>') + '</p></div>';

        // --- Chủ sở hữu ---
        h += '<div class="dt-section"><div class="dt-title"><i class="bi bi-person-badge"></i> Chủ sở hữu</div><div class="dt-grid">' +
             field('Họ và tên', val(s.ownerName)) + field('Email', val(s.ownerEmail)) +
             field('Số điện thoại', val(s.ownerPhone)) + field('Ngày sinh', val(s.ownerBirth)) + '</div></div>';

        // --- Định danh ---
        h += '<div class="dt-section"><div class="dt-title"><i class="bi bi-person-vcard"></i> Thông tin định danh</div><div class="dt-grid">' +
             field('Số CCCD / CMND', val(s.idCardNumber)) + field('Mã số thuế', val(s.taxCode)) + '</div>' +
             '<div class="dt-idrow">' + idImage('Ảnh CCCD mặt trước', s.idCardFrontUrl) + idImage('Ảnh CCCD mặt sau', s.idCardBackUrl) + '</div></div>';

        // --- Địa chỉ ---
        h += '<div class="dt-section"><div class="dt-title"><i class="bi bi-geo-alt"></i> Địa chỉ &amp; kho hàng</div><div class="dt-grid">' +
             field('Tỉnh / Thành phố', val(s.province)) + field('Quận / Huyện', val(s.district)) +
             field('Phường / Xã', val(s.ward)) + field('Địa chỉ chi tiết', val(s.streetAddress)) +
             field('Địa chỉ lấy hàng', val(s.pickupAddress)) + field('Địa chỉ hoàn trả', val(s.returnAddress)) + '</div></div>';

        // --- Ngân hàng ---
        h += '<div class="dt-section"><div class="dt-title"><i class="bi bi-bank"></i> Ngân hàng &amp; thanh toán</div><div class="dt-grid">' +
             field('Ngân hàng', val(s.bankName)) + field('Số tài khoản', val(s.bankAccountNumber)) +
             field('Chủ tài khoản', val(s.bankAccountHolder)) +
             (s.commissionRate ? field('Hoa hồng sàn', esc(s.commissionRate)) : '') + '</div></div>';

        // --- Lịch sử hồ sơ ---
        h += '<div class="dt-section"><div class="dt-title"><i class="bi bi-clock-history"></i> Lịch sử hồ sơ</div><div class="dt-grid">' +
             field('Ngày nộp hồ sơ', val(s.createdAt)) +
             field('Người xét duyệt', val(s.reviewerName)) +
             field('Ngày xét duyệt', val(s.reviewedAt)) + '</div></div>';

        // --- Lý do từ chối / tạm khóa (cuối modal) ---
        if (s.status === 'REJECTED') {
            h += '<div class="dt-reason dt-reason-red"><div class="dt-title text-danger"><i class="bi bi-x-octagon-fill"></i> Lý do từ chối hồ sơ</div>' +
                 '<p>' + (s.rejectReason ? esc(s.rejectReason) : '<span class="fst-italic">Admin không ghi lý do.</span>') + '</p></div>';
        }
        if (s.status === 'SUSPENDED') {
            h += '<div class="dt-reason dt-reason-amber"><div class="dt-title" style="color:#b45309;"><i class="bi bi-lock-fill"></i> Lý do tạm khóa' +
                 (s.suspendedAt ? ' <small class="fw-normal">(' + esc(s.suspendedAt) + ')</small>' : '') + '</div>' +
                 '<p>' + (s.suspendReason ? esc(s.suspendReason) : '<span class="fst-italic">Không có ghi chú lý do.</span>') + '</p></div>';
        }
        document.getElementById('detailBody').innerHTML = h;

        // --- Footer: thao tác theo trạng thái ---
        var f = '<button type="button" class="btn btn-light btn-sm me-auto" data-bs-dismiss="modal">Đóng</button>';
        if (s.status === 'PENDING') {
            f += '<button type="button" class="act-btn act-reject" onclick="openRejectModal(' + s.requestId + ')"><i class="bi bi-x-lg"></i><span>Từ chối</span></button>' +
                 '<button type="button" class="act-btn act-approve" onclick="approveShop(' + s.requestId + ')"><i class="bi bi-check-lg"></i><span>Duyệt</span></button>';
        } else if (s.status === 'ACTIVE' || s.status === 'PAUSED' || s.status === 'CLOSED') {
            f += '<button type="button" class="act-btn act-suspend" onclick="openSuspendModal(' + s.requestId + ')"><i class="bi bi-lock-fill"></i><span>Tạm khóa</span></button>';
        } else if (s.status === 'SUSPENDED') {
            f += '<button type="button" class="act-btn act-unlock" onclick="unlockShop(' + s.requestId + ')"><i class="bi bi-unlock-fill"></i><span>Mở khóa</span></button>';
        }
        document.getElementById('detailFooter').innerHTML = f;
        showModal('detailModal');
    }
</script>
</body>
</html>
