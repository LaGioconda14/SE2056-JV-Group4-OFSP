<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FreshFruit - Quản Lý Người Dùng & Phân Quyền</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css?v=16">
    <meta name="context-path" content="${pageContext.request.contextPath}">
</head>
<body class="admin-body">

<div class="admin-wrapper">
    <jsp:include page="layout/sidebar.jsp">
        <jsp:param name="activePage" value="users" />
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
                    <h1 class="users-header-title">Quản Lý Người Dùng & Phân Quyền</h1>
                    <p class="text-muted mb-0" style="font-size: 0.82rem;">Tra cứu danh bạ tài khoản đa vai trò, kiểm tra hồ sơ giao dịch và khóa/mở khóa tài khoản an toàn.</p>
                </div>
                <div class="users-header-actions">
                    <button type="button" class="btn-export-list" onclick="alert('Đang xuất danh sách tài khoản & ma trận phân quyền (CSV/Excel)...');">
                        <i class="bi bi-download"></i>
                        <span>Xuất danh sách</span>
                    </button>
                    <button type="button" class="btn-add-admin" data-bs-toggle="modal" data-bs-target="#inviteUserModal">
                        <i class="bi bi-person-plus-fill"></i>
                        <span>Thêm Quản trị viên mới</span>
                    </button>
                </div>
            </div>

            <!-- 2. Segmented Navigation Tabs (Lọc vai trò) -->
            <div class="users-rbac-tabs">
                <a href="${pageContext.request.contextPath}/admin/users?role=ALL" class="rbac-tab-item ${selectedRole == 'ALL' ? 'active' : ''}">
                    <i class="bi bi-people"></i>
                    <span>Tất cả tài khoản</span>
                    <span class="rbac-badge">${not empty roleCounts.total ? roleCounts.total : 0}</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/users?role=ADMIN_STAFF" class="rbac-tab-item ${selectedRole == 'ADMIN_STAFF' ? 'active' : ''}">
                    <i class="bi bi-person-badge"></i>
                    <span>Quản trị & Nhân viên</span>
                    <span class="rbac-badge">${not empty roleCounts.adminStaff ? roleCounts.adminStaff : 0}</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/users?role=SHOP_OWNER" class="rbac-tab-item ${selectedRole == 'SHOP_OWNER' ? 'active' : ''}">
                    <i class="bi bi-shop"></i>
                    <span>Chủ gian hàng</span>
                    <span class="rbac-badge">${not empty roleCounts.shopOwner ? roleCounts.shopOwner : 0}</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/users?role=CUSTOMER" class="rbac-tab-item ${selectedRole == 'CUSTOMER' ? 'active' : ''}">
                    <i class="bi bi-person"></i>
                    <span>Khách hàng</span>
                    <span class="rbac-badge">${not empty roleCounts.customer ? roleCounts.customer : 0}</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/users?role=DRIVER" class="rbac-tab-item ${selectedRole == 'DRIVER' ? 'active' : ''}">
                    <i class="bi bi-truck"></i>
                    <span>Tài xế giao nhận</span>
                    <span class="rbac-badge">${not empty roleCounts.driver ? roleCounts.driver : 0}</span>
                </a>
            </div>

            <!-- 4. Filter Toolbar -->
            <form method="GET" action="${pageContext.request.contextPath}/admin/users" class="users-filter-card" id="userFilterForm">
                <!-- Giữ vai trò đang chọn từ hàng tab phía trên -->
                <input type="hidden" name="role" value="${selectedRole}">

                <div class="users-search-pill">
                    <i class="bi bi-search"></i>
                    <input type="text" name="search" id="userSearchInput" value="<c:out value='${searchKeyword}'/>" placeholder="Tra cứu theo tên, email, sđt, ID, tên gian hàng...">
                </div>

                <div class="users-dropdown-filters">
                    <!-- Dropdown: Trạng thái tài khoản -->
                    <select name="status" id="statusFilterSelect" class="filter-select-btn" onchange="this.form.submit()">
                        <option value="ALL" ${selectedStatus == 'ALL' ? 'selected' : ''}>Trạng thái: Tất cả</option>
                        <option value="ACTIVE" ${selectedStatus == 'ACTIVE' ? 'selected' : ''}>Đang hoạt động (ACTIVE)</option>
                        <option value="BLOCKED" ${selectedStatus == 'BLOCKED' ? 'selected' : ''}>Bị khóa quyền (BLOCKED)</option>
                        <option value="INACTIVE" ${selectedStatus == 'INACTIVE' ? 'selected' : ''}>Chưa kích hoạt (INACTIVE)</option>
                    </select>

                    <button type="submit" class="btn btn-sm text-white d-inline-flex align-items-center gap-1" style="font-size: 0.75rem; padding: 0.38rem 0.85rem; border-radius: 8px; background: #15803d; border: 1px solid #15803d; font-weight: 600;">
                        <i class="bi bi-funnel"></i> Lọc
                    </button>

                    <!-- Nút Đặt lại / Reset -->
                    <c:if test="${(not empty selectedRole && selectedRole != 'ALL') || (not empty selectedStatus && selectedStatus != 'ALL') || not empty searchKeyword}">
                        <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-sm btn-outline-secondary d-inline-flex align-items-center gap-1" style="font-size: 0.75rem; padding: 0.38rem 0.85rem; border-radius: 8px;">
                            <i class="bi bi-arrow-counterclockwise"></i> Đặt lại
                        </a>
                    </c:if>
                </div>
            </form>

            <!-- 5. Users List Table -->
            <div class="users-table-container">
                <table class="users-modern-table">
                    <thead>
                        <tr>
                            <th>THÀNH VIÊN & ĐỊNH DANH</th>
                            <th>VAI TRÒ & PHÂN CẤP</th>
                            <th>NGÀY THAM GIA</th>
                            <th>TRẠNG THÁI</th>
                            <th class="text-end">THAO TÁC</th>
                        </tr>
                    </thead>
                    <tbody id="usersTableBody">
                        <c:forEach items="${usersList}" var="u">
                            <tr>
                                <td>
                                    <div class="user-cell-meta">
                                        <c:choose>
                                            <c:when test="${not empty u.avatarUrl}">
                                                <img src="${u.avatarUrl}" alt="${u.fullName}" class="user-avatar-circle">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="user-avatar-placeholder">
                                                    ${fn:substring(u.fullName, 0, 1)}
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                        <div>
                                            <div class="d-flex align-items-center">
                                                <span class="user-meta-name">${u.fullName}</span>
                                                <c:choose>
                                                    <c:when test="${u.roleName == 'ADMIN'}"><span class="role-pill-super ms-1">QUẢN TRỊ</span></c:when>
                                                    <c:when test="${u.roleName == 'STAFF'}"><span class="role-pill-mod ms-1">NHÂN VIÊN</span></c:when>
                                                    <c:when test="${u.roleName == 'SHOP_OWNER'}"><span class="role-pill-shopmgr ms-1">CHỦ SHOP</span></c:when>
                                                    <c:when test="${u.roleName == 'DRIVER'}"><span class="role-pill-cskh ms-1">TÀI XẾ</span></c:when>
                                                    <c:when test="${u.roleName == 'CUSTOMER'}"><span class="role-pill-accountant ms-1">KHÁCH HÀNG</span></c:when>
                                                    <c:otherwise><span class="role-pill-accountant ms-1">${u.roleName}</span></c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="user-meta-sub">${u.email} • ${u.phone} • ID: #${u.userId}</div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div><strong>${u.membershipTier}</strong></div>
                                    <div class="text-muted" style="font-size: 0.68rem;">
                                        <c:choose>
                                            <c:when test="${not empty u.shopName}">
                                                <span class="text-success fw-semibold"><i class="bi bi-shop"></i> ${u.shopName}</span>
                                            </c:when>
                                            <c:otherwise>Hệ thống FreshFruit</c:otherwise>
                                        </c:choose>
                                    </div>
                                </td>
                                <td>
                                    <span class="d-inline-flex align-items-center gap-1 text-muted fw-medium" style="font-size: 0.8rem;">
                                        <i class="bi bi-calendar3"></i> ${u.createdAtFormatted}
                                    </span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${u.status == 'ACTIVE'}">
                                            <span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1" style="font-size: 0.75rem; border-radius: 6px;">
                                                <i class="bi bi-check-circle-fill me-1"></i> Hoạt động
                                            </span>
                                        </c:when>
                                        <c:when test="${u.status == 'BLOCKED'}">
                                            <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-2 py-1" style="font-size: 0.75rem; border-radius: 6px;">
                                                <i class="bi bi-slash-circle-fill me-1"></i> Bị khóa (BLOCKED)
                                            </span>
                                            <c:if test="${not empty u.decisionReason}">
                                                <div class="text-danger text-truncate mt-1" style="font-size: 0.65rem; max-width: 150px;" title="${fn:escapeXml(u.decisionReason)}">
                                                    <i class="bi bi-info-circle"></i> ${fn:escapeXml(u.decisionReason)}
                                                </div>
                                            </c:if>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-secondary-subtle text-secondary border px-2 py-1" style="font-size: 0.75rem; border-radius: 6px;">
                                                <i class="bi bi-clock-history me-1"></i> ${u.status}
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end text-nowrap">
                                    <!-- Nút 1: Xem hồ sơ & lịch sử -->
                                    <button type="button" class="btn-action-view me-1" title="Kiểm tra hồ sơ & lịch sử giao dịch" onclick="openUserDetailModal('${u.userId}')">
                                        <i class="bi bi-eye"></i> Hồ sơ
                                    </button>

                                    <!-- Nút 2: Khóa / Mở khóa tài khoản (Soft Delete) -->
                                    <c:choose>
                                        <c:when test="${u.status == 'BLOCKED'}">
                                            <button type="button" class="btn-action-unlock me-1" title="Mở khóa tài khoản (Khôi phục ACTIVE)" onclick="openToggleStatusModal('${u.userId}', '${fn:escapeXml(u.fullName)}', '${fn:escapeXml(u.email)}', 'ACTIVE', '${fn:escapeXml(u.decisionReason)}')">
                                                <i class="bi bi-unlock-fill"></i> Mở khóa
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button type="button" class="btn-action-lock me-1" title="Khóa quyền truy cập (BLOCKED)" onclick="openToggleStatusModal('${u.userId}', '${fn:escapeXml(u.fullName)}', '${fn:escapeXml(u.email)}', 'BLOCKED', '${fn:escapeXml(u.decisionReason)}')">
                                                <i class="bi bi-lock-fill"></i> Khóa
                                            </button>
                                        </c:otherwise>
                                    </c:choose>

                                    <!-- Nút 3: Phân quyền vai trò -->
                                    <button type="button" class="btn-action-role" title="Điều chỉnh quyền hạn" onclick="openAssignRoleModal('${u.userId}', '${fn:escapeXml(u.fullName)}', '${u.roleName}')">
                                        <i class="bi bi-pencil"></i>
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty usersList}">
                            <tr>
                                <td colspan="5" class="text-center text-muted py-5">
                                    <i class="bi bi-person-x fs-1 text-secondary d-block mb-2"></i>
                                    Không tìm thấy tài khoản người dùng nào khớp với bộ lọc.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>

                <!-- Pagination Footer -->
                <div class="users-table-footer">
                    <span>Tổng cộng <strong>${not empty usersList ? usersList.size() : 0}</strong> tài khoản trong danh sách hiển thị</span>
                </div>
            </div>
        </main>
    </div>
</div>

<!-- ========================================================================= -->
<!-- MODAL: KIỂM TRA HỒ SƠ & LỊCH SỬ GIAO DỊCH / MUA BÁN                       -->
<!-- ========================================================================= -->
<div class="modal fade" id="viewUserDetailModal" tabindex="-1" aria-labelledby="viewUserDetailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content" style="border-radius: 14px; border: 1px solid #e2e8f0;">
            <div class="modal-header d-flex align-items-center justify-content-between" style="border-bottom: 1px solid #f1f5f9; padding: 1.15rem 1.4rem;">
                <div class="d-flex align-items-center gap-3">
                    <div id="modalUserAvatarWrap">
                        <!-- Populated by JS -->
                    </div>
                    <div>
                        <div class="d-flex align-items-center gap-2">
                            <h5 class="modal-title fw-bold mb-0 text-dark" id="modalUserFullName" style="font-size: 1.05rem;">Nguyễn Văn An</h5>
                            <span id="modalUserRoleBadge"></span>
                            <span id="modalUserStatusBadge"></span>
                        </div>
                        <div class="text-muted small mt-1" id="modalUserSubMeta">ID: #1 • email@freshfruit.com</div>
                    </div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <!-- Modal Nav Tabs -->
            <div style="border-bottom: 1px solid #e2e8f0; background: #fafafa; padding: 0 1.25rem;">
                <ul class="nav modal-detail-nav" role="tablist">
                    <li class="nav-item">
                        <button class="nav-link active" id="tab-profile-btn" data-bs-toggle="tab" data-bs-target="#tab-profile" type="button" role="tab">
                            <i class="bi bi-person-lines-fill me-1"></i> Hồ sơ cá nhân & Địa chỉ
                        </button>
                    </li>
                    <li class="nav-item">
                        <button class="nav-link" id="tab-orders-btn" data-bs-toggle="tab" data-bs-target="#tab-orders" type="button" role="tab">
                            <i class="bi bi-receipt me-1"></i> Lịch sử giao dịch & Mua bán
                        </button>
                    </li>
                    <li class="nav-item">
                        <button class="nav-link" id="tab-audit-btn" data-bs-toggle="tab" data-bs-target="#tab-audit" type="button" role="tab">
                            <i class="bi bi-shield-check me-1"></i> Nhật ký Quản trị (Audit Log)
                        </button>
                    </li>
                </ul>
            </div>

            <div class="modal-body" style="padding: 1.25rem 1.4rem; min-height: 280px;">
                <!-- Loading Spinner -->
                <div id="modalDetailLoading" class="text-center py-5">
                    <div class="spinner-border text-success" role="status">
                        <span class="visually-hidden">Đang tải...</span>
                    </div>
                    <div class="text-muted small mt-2">Đang tải hồ sơ và trích xuất lịch sử giao dịch...</div>
                </div>

                <!-- Detail Content Container -->
                <div id="modalDetailContent" style="display: none;">
                    <div class="tab-content">
                        <!-- TAB 1: THÔNG TIN CÁ NHÂN & ĐỊA CHỈ -->
                        <div class="tab-pane fade show active" id="tab-profile" role="tabpanel">
                            <!-- Alert lý do quản trị gần nhất (nếu có) -->
                            <div id="modalDecisionAlert" style="display: none;" class="alert alert-warning d-flex align-items-start gap-2 mb-3" style="border-radius: 8px;">
                                <i class="bi bi-exclamation-triangle-fill text-warning fs-5 flex-shrink-0"></i>
                                <div class="small">
                                    <strong>Ghi chú quản trị viên (Decision Reason):</strong>
                                    <div id="modalDecisionReasonText" class="mt-1"></div>
                                    <div id="modalDecisionDateText" class="text-muted mt-1" style="font-size: 0.72rem;"></div>
                                </div>
                            </div>

                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <div class="detail-card-stat h-100">
                                        <h6 class="fw-bold text-dark mb-2" style="font-size: 0.85rem;"><i class="bi bi-person-vcard text-success me-1"></i> Thông Tin Cơ Bản</h6>
                                        <div class="detail-info-row">
                                            <span class="detail-info-label">Mã tài khoản:</span>
                                            <span class="detail-info-value fw-bold text-success" id="infoUserId">#1</span>
                                        </div>
                                        <div class="detail-info-row">
                                            <span class="detail-info-label">Họ và tên:</span>
                                            <span class="detail-info-value" id="infoFullName">-</span>
                                        </div>
                                        <div class="detail-info-row">
                                            <span class="detail-info-label">Email:</span>
                                            <span class="detail-info-value" id="infoEmail">-</span>
                                        </div>
                                        <div class="detail-info-row">
                                            <span class="detail-info-label">Số điện thoại:</span>
                                            <span class="detail-info-value" id="infoPhone">-</span>
                                        </div>
                                        <div class="detail-info-row">
                                            <span class="detail-info-label">Giới tính:</span>
                                            <span class="detail-info-value" id="infoGender">-</span>
                                        </div>
                                        <div class="detail-info-row">
                                            <span class="detail-info-label">Ngày sinh:</span>
                                            <span class="detail-info-value" id="infoBirthDate">-</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="detail-card-stat h-100">
                                        <h6 class="fw-bold text-dark mb-2" style="font-size: 0.85rem;"><i class="bi bi-shield-shaded text-primary me-1"></i> Phân Cấp & Tài Khoản</h6>
                                        <div class="detail-info-row">
                                            <span class="detail-info-label">Vai trò:</span>
                                            <span class="detail-info-value fw-bold" id="infoRoleTitle">-</span>
                                        </div>
                                        <div class="detail-info-row">
                                            <span class="detail-info-label">Hạng thành viên:</span>
                                            <span class="detail-info-value" id="infoMembershipTier">-</span>
                                        </div>
                                        <div class="detail-info-row">
                                            <span class="detail-info-label">Trạng thái:</span>
                                            <span class="detail-info-value" id="infoStatus">-</span>
                                        </div>
                                        <div class="detail-info-row">
                                            <span class="detail-info-label">Ngày đăng ký:</span>
                                            <span class="detail-info-value" id="infoCreatedAt">-</span>
                                        </div>
                                        <div class="detail-info-row">
                                            <span class="detail-info-label">Cập nhật cuối:</span>
                                            <span class="detail-info-value" id="infoUpdatedAt">-</span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Shop Info (nếu là chủ gian hàng) -->
                            <div id="modalShopInfoSection" class="p-3 mb-3 border rounded-3" style="background: #f0fdf4; border-color: #dcfce7 !important; display: none;">
                                <h6 class="fw-bold text-success mb-2" style="font-size: 0.85rem;"><i class="bi bi-shop me-1"></i> Thông Tin Gian Hàng / Nhà Vườn Sở Hữu</h6>
                                <div class="row g-2 small">
                                    <div class="col-md-4"><strong>Tên gian hàng:</strong> <span id="shopInfoName">-</span></div>
                                    <div class="col-md-4"><strong>Loại hình:</strong> <span id="shopInfoType">-</span></div>
                                    <div class="col-md-4"><strong>Tỉnh / Thành:</strong> <span id="shopInfoProvince">-</span></div>
                                    <div class="col-md-4"><strong>Chứng nhận:</strong> <span class="badge bg-success-subtle text-success" id="shopInfoCert">-</span></div>
                                    <div class="col-md-4"><strong>Hoa hồng sàn:</strong> <span id="shopInfoComm">-</span></div>
                                    <div class="col-md-4"><strong>Tổng doanh thu:</strong> <strong class="text-success" id="shopInfoSales">-</strong></div>
                                </div>
                            </div>

                            <!-- Danh sách sổ địa chỉ nhận hàng -->
                            <div class="mt-3">
                                <h6 class="fw-bold text-dark mb-2" style="font-size: 0.85rem;"><i class="bi bi-geo-alt-fill text-danger me-1"></i> Sổ Địa Chỉ Giao Hàng</h6>
                                <div id="modalAddressList">
                                    <!-- Populated by JS -->
                                </div>
                            </div>
                        </div>

                        <!-- TAB 2: LỊCH SỬ GIAO DỊCH & MUA BÁN -->
                        <div class="tab-pane fade" id="tab-orders" role="tabpanel">
                            <!-- 4 KPI thống kê giao dịch -->
                            <div class="row g-2 mb-3">
                                <div class="col-3">
                                    <div class="p-2 border rounded-2 text-center bg-light">
                                        <div class="text-muted" style="font-size: 0.7rem;">TỔNG GIAO DỊCH</div>
                                        <div class="fw-bold text-success fs-6" id="statTotalSpent">0 ₫</div>
                                    </div>
                                </div>
                                <div class="col-3">
                                    <div class="p-2 border rounded-2 text-center bg-light">
                                        <div class="text-muted" style="font-size: 0.7rem;">TỔNG SỐ ĐƠN</div>
                                        <div class="fw-bold text-dark fs-6" id="statTotalOrders">0</div>
                                    </div>
                                </div>
                                <div class="col-3">
                                    <div class="p-2 border rounded-2 text-center bg-light">
                                        <div class="text-muted" style="font-size: 0.7rem;">ĐƠN HOÀN TẤT</div>
                                        <div class="fw-bold text-primary fs-6" id="statCompletedOrders">0</div>
                                    </div>
                                </div>
                                <div class="col-3">
                                    <div class="p-2 border rounded-2 text-center bg-light">
                                        <div class="text-muted" style="font-size: 0.7rem;">ĐANG XỬ LÝ / HỦY</div>
                                        <div class="fw-bold text-danger fs-6" id="statOtherOrders">0</div>
                                    </div>
                                </div>
                            </div>

                            <!-- Bảng đơn hàng đã mua -->
                            <h6 class="fw-bold text-dark mb-2" style="font-size: 0.85rem;"><i class="bi bi-bag-check-fill text-primary me-1"></i> Danh Sách Đơn Hàng Đã Mua (Buyer Orders)</h6>
                            <div class="table-responsive border rounded-3 mb-3">
                                <table class="table table-sm table-hover align-middle mb-0" style="font-size: 0.78rem;">
                                    <thead class="table-light">
                                        <tr>
                                            <th>MÃ ĐƠN</th>
                                            <th>THỜI GIAN ĐẶT</th>
                                            <th>SỐ MÓN</th>
                                            <th>TỔNG THANH TOÁN</th>
                                            <th>PT THANH TOÁN</th>
                                            <th>TRẠNG THÁI</th>
                                        </tr>
                                    </thead>
                                    <tbody id="modalOrdersTableBody">
                                        <!-- Populated by JS -->
                                    </tbody>
                                </table>
                            </div>

                            <!-- Bảng đơn hàng bán của shop (nếu có) -->
                            <div id="modalVendorOrdersSection" style="display: none;">
                                <h6 class="fw-bold text-dark mb-2" style="font-size: 0.85rem;"><i class="bi bi-shop text-success me-1"></i> Danh Sách Đơn Bán Của Gian Hàng (Vendor Orders)</h6>
                                <div class="table-responsive border rounded-3">
                                    <table class="table table-sm table-hover align-middle mb-0" style="font-size: 0.78rem;">
                                        <thead class="table-light">
                                            <tr>
                                                <th>MÃ ĐƠN CON</th>
                                                <th>NGÀY ĐẶT</th>
                                                <th>NGƯỜI MUA</th>
                                                <th>GIÁ TRỊ SHOP</th>
                                                <th>HOA HỒNG SÀN</th>
                                                <th>TRẠNG THÁI</th>
                                            </tr>
                                        </thead>
                                        <tbody id="modalVendorOrdersTableBody">
                                            <!-- Populated by JS -->
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>

                        <!-- TAB 3: NHẬT KÝ QUẢN TRỊ (AUDIT LOG) -->
                        <div class="tab-pane fade" id="tab-audit" role="tabpanel">
                            <h6 class="fw-bold text-dark mb-2" style="font-size: 0.85rem;"><i class="bi bi-clock-history text-secondary me-1"></i> Lịch Sử Quyết Định Khóa / Mở Khóa Tài Khoản</h6>
                            <div class="table-responsive border rounded-3">
                                <table class="table table-sm table-hover align-middle mb-0" style="font-size: 0.78rem;">
                                    <thead class="table-light">
                                        <tr>
                                            <th>THỜI GIAN</th>
                                            <th>TRẠNG THÁI</th>
                                            <th>NGƯỜI QUYẾT ĐỊNH</th>
                                            <th>LÝ DO QUẢN TRỊ (DECISION REASON)</th>
                                        </tr>
                                    </thead>
                                    <tbody id="modalAuditLogsTableBody">
                                        <!-- Populated by JS -->
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer" style="border-top: 1px solid #f1f5f9; padding: 0.85rem 1.4rem;">
                <button type="button" class="btn btn-light btn-sm fw-bold px-3" data-bs-dismiss="modal" style="border-radius: 8px;">Đóng</button>
            </div>
        </div>
    </div>
</div>

<!-- ========================================================================= -->
<!-- MODAL: KHÓA / MỞ KHÓA TÀI KHOẢN (SOFT DELETE / RECOVERY)                  -->
<!-- ========================================================================= -->
<div class="modal fade" id="toggleUserStatusModal" tabindex="-1" aria-labelledby="toggleUserStatusModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 14px; border: 1px solid #e2e8f0;">
            <div class="modal-header" style="border-bottom: 1px solid #f1f5f9; padding: 1.15rem 1.4rem;">
                <h5 class="modal-title fw-bold" id="toggleModalTitle" style="font-size: 1rem; color: #0f172a;">
                    <!-- Set by JS -->
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/users" method="POST" id="toggleStatusForm">
                <input type="hidden" name="action" value="changeStatus">
                <input type="hidden" name="userId" id="toggleStatusUserId">
                <input type="hidden" name="newStatus" id="toggleStatusNewStatus">
                <input type="hidden" name="currentRole" value="${selectedRole}">
                <input type="hidden" name="currentStatus" value="${selectedStatus}">
                <input type="hidden" name="currentSearch" value="<c:out value='${searchKeyword}'/>">

                <div class="modal-body" style="padding: 1.25rem 1.4rem;">
                    <!-- Warning / Info Alert -->
                    <div class="alert mb-3" id="toggleWarningAlert" style="border-radius: 8px; font-size: 0.82rem;">
                        <!-- Set by JS -->
                    </div>

                    <!-- Target User Summary Box -->
                    <div class="p-3 mb-3" style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px;">
                        <div class="small text-muted mb-1">Tài khoản được chọn:</div>
                        <div class="fw-bold text-dark fs-6" id="toggleUserNameDisplay">Nguyễn Văn An (ID: #1)</div>
                        <div class="text-muted small" id="toggleUserEmailDisplay">an.nguyen@dalatfarm.vn</div>
                    </div>

                    <!-- Mandatory Decision Reason Input -->
                    <div class="mb-3">
                        <label class="form-label small fw-bold text-dark">
                            Lý do quản trị (Decision Reason) <span class="text-danger">* Bắt buộc</span>
                        </label>
                        <textarea name="decisionReason" id="toggleStatusReasonInput" class="form-control" rows="3" required minlength="5" placeholder="Nhập lý do cụ thể..." style="font-size: 0.82rem; border-radius: 8px;"></textarea>
                        <div class="form-text text-muted" style="font-size: 0.72rem;">
                            <i class="bi bi-info-circle-fill text-primary"></i> Lý do này là bắt buộc theo quy chế kiểm toán nội bộ FreshFruit để lưu vết lịch sử mọi thao tác khóa/mở khóa tài khoản.
                        </div>
                    </div>
                </div>

                <div class="modal-footer" style="border-top: 1px solid #f1f5f9; padding: 0.85rem 1.4rem;">
                    <button type="button" class="btn btn-light btn-sm fw-bold px-3" data-bs-dismiss="modal" style="border-radius: 8px;">Hủy bỏ</button>
                    <button type="submit" class="btn btn-sm fw-bold px-3" id="toggleStatusSubmitBtn" style="border-radius: 8px;">
                        <!-- Text set by JS -->
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ========================================================================= -->
<!-- MODAL: THÊM QUẢN TRỊ VIÊN MỚI                                             -->
<!-- ========================================================================= -->
<div class="modal fade" id="inviteUserModal" tabindex="-1" aria-labelledby="inviteUserModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 14px; border: 1px solid #e2e8f0;">
            <div class="modal-header" style="border-bottom: 1px solid #f1f5f9; padding: 1.15rem 1.4rem;">
                <h5 class="modal-title fw-bold" id="inviteUserModalLabel" style="font-size: 1rem; color: #0f172a;">
                    <i class="bi bi-person-plus-fill text-success me-1"></i> Thêm Quản Trị Viên / Nhân Sự Mới
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/users/invite" method="post">
                <div class="modal-body" style="padding: 1.25rem 1.4rem;">
                    <div class="mb-3">
                        <label class="form-label small fw-bold text-muted">Họ Và Tên Thành Viên <span class="text-danger">*</span></label>
                        <input type="text" name="fullName" class="form-control" placeholder="Ví dụ: Nguyễn Văn An" required style="font-size: 0.82rem; border-radius: 8px;">
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-bold text-muted">Email Cơ Quan (@freshfruit.com) <span class="text-danger">*</span></label>
                        <input type="email" name="email" class="form-control" placeholder="an.nguyen@freshfruit.com" required style="font-size: 0.82rem; border-radius: 8px;">
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-bold text-muted">Vai Trò & Nhóm Quyền Hạn (RBAC) <span class="text-danger">*</span></label>
                        <select name="roleCode" class="form-select" required style="font-size: 0.82rem; border-radius: 8px;">
                            <option value="ADMIN">👑 Super Admin (Toàn quyền hệ thống)</option>
                            <option value="STAFF" selected>🛡️ Nhân viên Vận hành Sàn</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer" style="border-top: 1px solid #f1f5f9; padding: 0.85rem 1.4rem;">
                    <button type="button" class="btn btn-light btn-sm fw-bold px-3" data-bs-dismiss="modal" style="border-radius: 8px;">Hủy bỏ</button>
                    <button type="submit" class="btn btn-success btn-sm fw-bold px-3" style="background: #15803d; border-color: #15803d; border-radius: 8px;">
                        <i class="bi bi-send-check me-1"></i> Thêm Quản Trị Viên
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ========================================================================= -->
<!-- MODAL: ĐIỀU CHỈNH NHÓM QUYỀN HẠN (RBAC)                                   -->
<!-- ========================================================================= -->
<div class="modal fade" id="assignRoleModal" tabindex="-1" aria-labelledby="assignRoleModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 14px; border: 1px solid #e2e8f0;">
            <div class="modal-header" style="border-bottom: 1px solid #f1f5f9; padding: 1.15rem 1.4rem;">
                <h5 class="modal-title fw-bold" id="assignRoleModalLabel" style="font-size: 1rem; color: #0f172a;">
                    <i class="bi bi-shield-lock-fill text-success me-1"></i> Điều Chỉnh Nhóm Quyền Hạn
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/users/assign-role" method="post">
                <input type="hidden" name="userId" id="modalUserId" value="">
                <div class="modal-body" style="padding: 1.25rem 1.4rem;">
                    <div class="p-3 mb-3" style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px;">
                        <div class="small text-muted mb-1">Thành viên được chọn:</div>
                        <div class="fw-bold fs-6 text-dark" id="modalUserNameDisplay">User</div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-bold text-muted">Nhóm Vai Trò Hệ Thống <span class="text-danger">*</span></label>
                        <select name="newRole" id="modalUserRoleSelect" class="form-select" style="font-size: 0.82rem; border-radius: 8px;">
                            <option value="ADMIN">👑 Quản trị viên cấp cao (ADMIN)</option>
                            <option value="STAFF">🛡️ Nhân viên vận hành (STAFF)</option>
                            <option value="SHOP_OWNER">🏪 Chủ gian hàng / Nhà vườn (SHOP_OWNER)</option>
                            <option value="DRIVER">🚚 Tài xế giao nhận chuỗi lạnh (DRIVER)</option>
                            <option value="CUSTOMER">🛒 Khách hàng mua sắm (CUSTOMER)</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer" style="border-top: 1px solid #f1f5f9; padding: 0.85rem 1.4rem;">
                    <button type="button" class="btn btn-light btn-sm fw-bold px-3" data-bs-dismiss="modal" style="border-radius: 8px;">Đóng</button>
                    <button type="submit" class="btn btn-success btn-sm fw-bold px-3" style="background: #15803d; border-color: #15803d; border-radius: 8px;">
                        <i class="bi bi-check2-circle me-1"></i> Lưu Cấu Hình Quyền
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/admin.js?v=16"></script>
<script src="${pageContext.request.contextPath}/assets/js/admin-users.js"></script>
</body>
</html>
