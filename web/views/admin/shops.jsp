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

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css?v=12">
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
                    <button type="button" class="btn-add-admin" onclick="alert('Đang phê duyệt hàng loạt 12 hồ sơ hợp lệ...');">
                        <i class="bi bi-check2-all"></i>
                        <span>Duyệt hàng loạt (12)</span>
                    </button>
                </div>
            </div>

            <!-- 2. 4 Summary Metric Cards -->
            <div class="shops-summary-grid">
                <!-- Card 1: Hồ sơ chờ thẩm định -->
                <div class="user-summary-card">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-1">
                            <span class="user-summary-title">Hồ sơ chờ thẩm định</span>
                            <span class="badge-counter-orange" style="font-size: 0.65rem;">${not empty shopStats.pendingKyc ? shopStats.pendingKyc : 2} Đang Chờ</span>
                        </div>
                        <div class="user-summary-val">${not empty shopStats.pendingKyc ? shopStats.pendingKyc : 2} <span class="fs-6 fw-normal text-muted">đơn</span></div>
                        <div class="text-danger fw-bold d-flex align-items-center gap-1" style="font-size: 0.72rem;">
                            <i class="bi bi-exclamation-circle-fill"></i> Cần xử lý trước 24h
                        </div>
                    </div>
                    <div class="shop-kpi-sub-row">
                        <span class="text-uppercase" style="letter-spacing: 0.04em;">TỒN ĐỌNG TRUNG BÌNH</span>
                        <strong class="text-dark">Hồ sơ KYC mới</strong>
                    </div>
                </div>

                <!-- Card 2: Gian hàng đang hoạt động -->
                <div class="user-summary-card">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-1">
                            <span class="user-summary-title">Gian hàng đang hoạt động</span>
                            <span class="badge-kpi-growth" style="font-size: 0.65rem;">Đã xác minh</span>
                        </div>
                        <div class="user-summary-val">${not empty shopStats.totalShops ? shopStats.totalShops : 4} <span class="fs-6 fw-normal text-muted">shop</span></div>
                        <div class="text-success d-flex align-items-center gap-1" style="font-size: 0.72rem;">
                            <i class="bi bi-check-circle-fill"></i> Tuân thủ chuẩn VietGAP / GlobalGAP
                        </div>
                    </div>
                    <div class="shop-kpi-sub-row">
                        <span class="text-uppercase" style="letter-spacing: 0.04em;">ĐẠT CHUẨN XUẤT KHẨU</span>
                        <strong class="text-dark">Nhà vườn chính thức</strong>
                    </div>
                </div>

                <!-- Card 3: Tổng doanh thu nhà vườn -->
                <div class="user-summary-card">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-1">
                            <span class="user-summary-title">Mức hoa hồng định mức</span>
                            <div class="user-summary-icon-box bg-green-subtle">
                                <i class="bi bi-wallet2"></i>
                            </div>
                        </div>
                        <div class="user-summary-val" style="font-size: 1.45rem;">${not empty shopStats.avgComm ? shopStats.avgComm : '7.8%'}</div>
                        <div class="text-success d-flex align-items-center gap-1" style="font-size: 0.72rem;">
                            <i class="bi bi-graph-up-arrow"></i> Chiết khấu hoa hồng sàn
                        </div>
                    </div>
                    <div class="shop-kpi-sub-row">
                        <span class="text-uppercase" style="letter-spacing: 0.04em;">TỶ LỆ TAKE RATE</span>
                        <strong class="text-success">Theo hợp đồng</strong>
                    </div>
                </div>

                <!-- Card 4: Gian hàng bị cảnh báo / Tạm khóa -->
                <div class="user-summary-card">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-1">
                            <span class="user-summary-title">Gian hàng bị cảnh báo / Tạm khóa</span>
                            <span class="badge-counter-red" style="font-size: 0.65rem;">Giám sát</span>
                        </div>
                        <div class="user-summary-val text-danger">${not empty shopStats.suspended ? shopStats.suspended : 0} <span class="fs-6 fw-normal text-muted">shop</span></div>
                        <div class="text-muted d-flex align-items-center gap-1" style="font-size: 0.7rem;">
                            <i class="bi bi-exclamation-triangle-fill text-warning"></i> 2 dập nát vận chuyển, 1 sai nguồn gốc
                        </div>
                    </div>
                    <div class="shop-kpi-sub-row">
                        <span class="text-uppercase" style="letter-spacing: 0.04em;">TỈ LỆ SỰ CỐ</span>
                        <strong class="text-danger">3.5% tổng sàn</strong>
                    </div>
                </div>
            </div>

            <!-- 3. Segmented Navigation Tabs -->
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
                    <span>Chờ xét duyệt KYC</span>
                    <span class="rbac-badge">${not empty shopStats.pendingKyc ? shopStats.pendingKyc : 0}</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/shops?status=SUSPENDED" class="rbac-tab-item ${selectedStatus == 'SUSPENDED' ? 'active' : ''}">
                    <i class="bi bi-exclamation-diamond"></i>
                    <span>Bị cảnh báo / Tạm khóa</span>
                    <span class="rbac-badge">${not empty shopStats.suspended ? shopStats.suspended : 0}</span>
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
                        <option value="Nhà vườn trực tiếp" ${selectedType == 'Nhà vườn trực tiếp' ? 'selected' : ''}>Nhà vườn trực tiếp</option>
                        <option value="Hợp tác xã" ${selectedType == 'Hợp tác xã' ? 'selected' : ''}>Hợp tác xã</option>
                        <option value="Hộ gia đình" ${selectedType == 'Hộ gia đình' ? 'selected' : ''}>Hộ gia đình</option>
                        <option value="Doanh nghiệp bao tiêu" ${selectedType == 'Doanh nghiệp bao tiêu' ? 'selected' : ''}>Doanh nghiệp bao tiêu</option>
                        <option value="Doanh nghiệp nhập khẩu" ${selectedType == 'Doanh nghiệp nhập khẩu' ? 'selected' : ''}>Doanh nghiệp nhập khẩu</option>
                    </select>

                    <select name="cert" id="certFilterSelect" class="filter-select-btn" onchange="this.form.submit()">
                        <option value="ALL" ${selectedCert == 'ALL' ? 'selected' : ''}>Chứng nhận: Tất cả</option>
                        <option value="VietGAP" ${selectedCert == 'VietGAP' ? 'selected' : ''}>VietGAP</option>
                        <option value="GlobalGAP" ${selectedCert == 'GlobalGAP' ? 'selected' : ''}>GlobalGAP</option>
                        <option value="Organic" ${selectedCert == 'Organic' ? 'selected' : ''}>Hữu cơ Organic</option>
                        <option value="Kiểm dịch" ${selectedCert == 'Kiểm dịch' ? 'selected' : ''}>Kiểm dịch</option>
                    </select>

                    <button type="submit" class="btn btn-sm text-white d-inline-flex align-items-center gap-1" style="font-size: 0.75rem; padding: 0.38rem 0.85rem; border-radius: 8px; background: #15803d; border: 1px solid #15803d; font-weight: 600;">
                        <i class="bi bi-funnel"></i> Lọc
                    </button>

                    <c:if test="${(not empty selectedStatus && selectedStatus != 'ALL') || (not empty selectedType && selectedType != 'ALL') || (not empty selectedCert && selectedCert != 'ALL') || not empty searchKeyword}">
                        <a href="${pageContext.request.contextPath}/admin/shops" class="btn btn-sm btn-outline-secondary d-inline-flex align-items-center gap-1" style="font-size: 0.75rem; padding: 0.38rem 0.85rem; border-radius: 8px;">
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
                                <c:when test="${selectedStatus == 'SUSPENDED'}">Danh sách Gian hàng Bị cảnh báo / Tạm khóa</c:when>
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
                            <th>THAO TÁC DUYỆT KYC</th>
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
                                            <strong class="text-dark fs-6" style="font-size: 0.85rem !important;">${s.shopName}</strong>
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
                                        <c:when test="${s.status == 'ACTIVE' || s.status == 'APPROVED'}">
                                            <span class="status-pill-green">Đã duyệt</span>
                                        </c:when>
                                        <c:when test="${s.status == 'PENDING' || s.status == 'PENDING_KYC'}">
                                            <span class="badge bg-warning-subtle text-warning-emphasis border border-warning-subtle px-2 py-1" style="border-radius: 9999px; font-size: 0.68rem; font-weight: 700;">Chờ duyệt KYC</span>
                                        </c:when>
                                        <c:when test="${s.status == 'REJECTED'}">
                                            <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-2 py-1" style="border-radius: 9999px; font-size: 0.68rem; font-weight: 700;">Đã từ chối</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-pill-warning">${s.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="d-flex align-items-center gap-1">
                                        <!-- Nút xem chi tiết -->
                                        <button type="button" class="btn btn-sm btn-outline-primary py-0 px-2" style="font-size: 0.72rem;" 
                                                onclick="viewDetail('${s.shopName}', '${s.idCardNumber}', '${s.taxCode}', '${pageContext.request.contextPath}/${s.idCardFrontUrl}', '${pageContext.request.contextPath}/${s.idCardBackUrl}', '${s.shopDescription}', '${s.pickupAddress}', '${s.returnAddress}')">
                                            <i class="bi bi-eye"></i> Chi tiết
                                        </button>
                                        
                                        <c:if test="${s.status == 'PENDING' || s.status == 'PENDING_KYC'}">
                                            <!-- Nút Duyệt -->
                                            <form action="${pageContext.request.contextPath}/admin/shops" method="GET" style="display:inline;" onsubmit="return confirm('Bạn chắc chắn muốn duyệt gian hàng ${s.shopName}?');">
                                                <input type="hidden" name="action" value="approve">
                                                <input type="hidden" name="id" value="${s.requestId}">
                                                <button type="submit" class="btn btn-sm btn-success py-0 px-2" style="font-size: 0.72rem;">
                                                    <i class="bi bi-check-lg"></i> Duyệt
                                                </button>
                                            </form>
                                            <!-- Nút Từ chối -->
                                            <button type="button" class="btn btn-sm btn-danger py-0 px-2" style="font-size: 0.72rem;" 
                                                    onclick="openRejectModal('${s.requestId}', '${s.shopName}')">
                                                <i class="bi bi-x-lg"></i> Từ chối
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
            <div class="bottom-split-grid">
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

                <!-- Right (1/3): Xem nhanh hồ sơ tiêu biểu -->
                <div class="quick-preview-card">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-3">
                            <span class="kpi-label mb-0">XEM NHANH HỒ SƠ TIÊU BIỂU</span>
                            <span class="status-pill-green">Điểm cao nhất</span>
                        </div>

                        <!-- Shop Preview Banner -->
                        <div class="d-flex align-items-center gap-2 p-2 rounded mb-3" style="background: #f8fafc; border: 1px solid #e2e8f0;">
                            <img src="https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=80&h=80&fit=crop" class="shop-avatar-thumb" alt="Mộc Châu">
                            <div>
                                <strong class="text-dark" style="font-size: 0.82rem;">Nông Trại Hữu Cơ Mộc Châu</strong>
                                <div class="text-success fw-bold" style="font-size: 0.72rem;">
                                    <i class="bi bi-cpu"></i> AI Score: 98/100
                                </div>
                            </div>
                        </div>

                        <!-- Checklist -->
                        <div class="d-flex flex-column gap-2 mb-3" style="font-size: 0.74rem;">
                            <div class="d-flex align-items-center justify-content-between">
                                <span class="d-flex align-items-center gap-2">
                                    <i class="bi bi-check-circle-fill text-success"></i> CCCD & Tài khoản Ngân hàng
                                </span>
                                <strong class="text-dark">Khớp 100%</strong>
                            </div>
                            <div class="d-flex align-items-center justify-content-between">
                                <span class="d-flex align-items-center gap-2">
                                    <i class="bi bi-check-circle-fill text-success"></i> Chứng nhận VietGAP Trồng trọt
                                </span>
                                <strong class="text-dark">Còn hạn 2026</strong>
                            </div>
                            <div class="d-flex align-items-center justify-content-between">
                                <span class="d-flex align-items-center gap-2">
                                    <i class="bi bi-check-circle-fill text-success"></i> Cam kết nhiệt độ bảo quản xe lạnh
                                </span>
                                <strong class="text-dark">Đã ký số</strong>
                            </div>
                        </div>
                    </div>

                    <div>
                        <button type="button" class="btn-approve-drawer" onclick="alert('Đã phê duyệt và kích hoạt quyền kinh doanh trên sàn cho Nông Trại Hữu Cơ Mộc Châu!');">
                            <i class="bi bi-check2"></i> Duyệt & Kích hoạt Gian Hàng Này
                        </button>
                        <a href="javascript:void(0)" onclick="alert('Đang tải tệp ZIP hồ sơ gốc...');" class="drawer-zip-link">
                            <i class="bi bi-folder2-open"></i> Mở toàn bộ hồ sơ gốc (.ZIP)
                        </a>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<!-- MODAL XEM CHI TIẾT HỒ SƠ KYC -->
<div class="modal fade" id="detailModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold text-success"><i class="bi bi-file-earmark-text"></i> Chi Tiết Hồ Sơ KYC: <span id="modalShopName"></span></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="row g-3">
                    <div class="col-md-6">
                        <p><strong>Số CCCD:</strong> <span id="modalIdCard"></span></p>
                        <p><strong>Mã số thuế:</strong> <span id="modalTaxCode"></span></p>
                        <p><strong>Địa chỉ lấy hàng:</strong> <span id="modalPickup"></span></p>
                        <p><strong>Địa chỉ trả hàng:</strong> <span id="modalReturn"></span></p>
                    </div>
                    <div class="col-md-6">
                        <p><strong>Mô tả cửa hàng:</strong> <br><span id="modalDesc" class="text-muted"></span></p>
                    </div>
                    <div class="col-md-6 text-center">
                        <label class="form-label fw-bold">Ảnh CCCD Mặt Trước</label>
                        <div><img id="modalFrontImg" src="" class="img-fluid border rounded" style="max-height: 200px; object-fit: contain;"></div>
                    </div>
                    <div class="col-md-6 text-center">
                        <label class="form-label fw-bold">Ảnh CCCD Mặt Sau</label>
                        <div><img id="modalBackImg" src="" class="img-fluid border rounded" style="max-height: 200px; object-fit: contain;"></div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<!-- MODAL TỪ CHỐI ĐƠN (CÓ NHẬP LÝ DO) -->
<div class="modal fade" id="rejectModal" tabindex="-1">
    <div class="modal-dialog">
        <form action="${pageContext.request.contextPath}/admin/shops" method="GET">
            <input type="hidden" name="action" value="reject">
            <input type="hidden" name="id" id="rejectRequestId">
            <div class="modal-content">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title"><i class="bi bi-exclamation-triangle"></i> Từ Chối Đơn Đăng Ký: <span id="rejectShopName"></span></h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label fw-bold">Vui lòng nhập lý do từ chối (Gửi thông báo về cho người bán): <span class="text-danger">*</span></label>
                        <textarea class="form-control" name="reason" rows="4" placeholder="Ví dụ: Ảnh CCCD bị mờ, không rõ số hoặc thông tin ngân hàng không hợp lệ..." required></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-danger btn-sm">Xác Nhận Từ Chối</button>
                </div>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/admin.js?v=12"></script>

<script>
    function viewDetail(name, idCard, tax, frontUrl, backUrl, desc, pickup, ret) {
        document.getElementById('modalShopName').innerText = name;
        document.getElementById('modalIdCard').innerText = idCard;
        document.getElementById('modalTaxCode').innerText = tax && tax !== 'null' ? tax : 'Không có';
        document.getElementById('modalPickup').innerText = pickup && pickup !== 'null' ? pickup : 'Không có';
        document.getElementById('modalReturn').innerText = ret && ret !== 'null' ? ret : 'Không có';
        document.getElementById('modalDesc').innerText = desc && desc !== 'null' ? desc : 'Không có mô tả';
        document.getElementById('modalFrontImg').src = frontUrl;
        document.getElementById('modalBackImg').src = backUrl;
        
        var myModal = new bootstrap.Modal(document.getElementById('detailModal'));
        myModal.show();
    }

    function openRejectModal(id, name) {
        document.getElementById('rejectRequestId').value = id;
        document.getElementById('rejectShopName').innerText = name;
        
        var myModal = new bootstrap.Modal(document.getElementById('rejectModal'));
        myModal.show();
    }
</script>
</body>
</html>