<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FreshFruit - Quản Lý Người Dùng & Phân Quyền (Users & Permissions)</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css?v=11">
</head>
<body class="admin-body">

<div class="admin-wrapper">
    <jsp:include page="layout/sidebar.jsp">
        <jsp:param name="activePage" value="users" />
    </jsp:include>

    <div class="admin-main">
        <jsp:include page="layout/header.jsp" />

        <main class="admin-page-content">
            <!-- 1. Page Header & Actions -->
            <div class="users-page-header">
                <div>
                    <div class="d-flex align-items-center gap-2 mb-1">
                        <span class="badge-protocol-tag">HỆ THỐNG QUẢN TRỊ FRESHFRUIT</span>
                        <span class="protocol-subtext">• RBAC Security Protocol v2.4</span>
                    </div>
                    <h1 class="users-header-title">Quản Lý Người Dùng & Phân Quyền (Users & Permissions)</h1>
                    <p class="users-header-desc">Quản trị danh sách người dùng toàn sàn, tài khoản nhân sự nội bộ và ma trận phân quyền vai trò (RBAC).</p>
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

            <!-- 2. 4 Summary Metric Cards -->
            <div class="users-summary-grid">
                <!-- Card 1: Tổng tài khoản hệ thống -->
                <div class="user-summary-card">
                    <div class="d-flex align-items-center justify-content-between">
                        <span class="user-summary-title">Tổng tài khoản hệ thống</span>
                        <div class="user-summary-icon-box bg-green-subtle">
                            <i class="bi bi-people-fill"></i>
                        </div>
                    </div>
                    <div class="user-summary-val">${not empty roleCounts.total ? roleCounts.total : 0}</div>
                    <div class="user-summary-sub">
                        <span class="text-success fw-bold d-inline-flex align-items-center">
                            <i class="bi bi-check2-circle fs-6"></i>Đã xác thực hệ thống
                        </span>
                    </div>
                </div>

                <!-- Card 2: Khách hàng (Người mua) -->
                <div class="user-summary-card">
                    <div class="d-flex align-items-center justify-content-between">
                        <span class="user-summary-title">Khách hàng (Người mua)</span>
                        <div class="user-summary-icon-box bg-purple-subtle">
                            <i class="bi bi-bag-check-fill"></i>
                        </div>
                    </div>
                    <div class="user-summary-val">${not empty roleCounts.customer ? roleCounts.customer : 0}</div>
                    <div class="user-summary-sub d-flex justify-content-between w-100">
                        <span>Tài khoản mua hàng</span>
                        <span class="text-muted">Hoạt động</span>
                    </div>
                </div>

                <!-- Card 3: Chủ gian hàng (Vendors) -->
                <div class="user-summary-card">
                    <div class="d-flex align-items-center justify-content-between">
                        <span class="user-summary-title">Chủ gian hàng (Vendors)</span>
                        <div class="user-summary-icon-box" style="background: #ffedd5; color: #ea580c;">
                            <i class="bi bi-shop"></i>
                        </div>
                    </div>
                    <div class="user-summary-val">${not empty roleCounts.shopOwner ? roleCounts.shopOwner : 0}</div>
                    <div class="user-summary-sub">
                        <span class="text-success fw-bold d-inline-flex align-items-center gap-1">
                            <i class="bi bi-circle-fill" style="font-size: 0.45rem;"></i> Đối tác nhà vườn
                        </span>
                    </div>
                </div>

                <!-- Card 4: Nhân sự & Ban Quản trị -->
                <div class="user-summary-card">
                    <div class="d-flex align-items-center justify-content-between">
                        <span class="user-summary-title">Nhân sự & Ban Quản trị</span>
                        <div class="user-summary-icon-box bg-green-subtle">
                            <i class="bi bi-shield-shaded"></i>
                        </div>
                    </div>
                    <div class="user-summary-val">${not empty roleCounts.adminStaff ? roleCounts.adminStaff : 0}</div>
                    <div class="user-summary-sub d-flex align-items-center justify-content-between w-100">
                        <span><strong>${not empty roleCounts.admin ? roleCounts.admin : 1}</strong> Admin</span>
                        <span><strong>${not empty roleCounts.staff ? roleCounts.staff : 1}</strong> Staff</span>
                    </div>
                </div>
            </div>

            <!-- 3. Segmented Navigation Tabs -->
            <div class="users-rbac-tabs">
                <a href="${pageContext.request.contextPath}/admin/users?role=ADMIN_STAFF" class="rbac-tab-item active">
                    <i class="bi bi-person-badge"></i>
                    <span>Nhân sự & Phân quyền nội bộ</span>
                    <span class="rbac-badge">46</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/users?role=CUSTOMER" class="rbac-tab-item">
                    <i class="bi bi-person"></i>
                    <span>Tài khoản Khách hàng</span>
                    <span class="rbac-badge">12,216</span>
                </a>
                <a href="#roleMatrixSection" class="rbac-tab-item">
                    <i class="bi bi-diagram-3"></i>
                    <span>Ma trận Vai trò & Quyền hạn (Roles & RBAC)</span>
                    <span class="rbac-badge">6</span>
                </a>
            </div>

            <!-- 4. Filter Toolbar -->
            <div class="users-filter-card">
                <div class="users-search-pill">
                    <i class="bi bi-search"></i>
                    <input type="text" id="userSearchInput" placeholder="Tìm theo tên, email, mã nhân viên, vai trò...">
                </div>

                <div class="users-dropdown-filters">
                    <!-- Dropdown: Vai trò -->
                    <div class="dropdown">
                        <button class="filter-select-btn dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <span>Vai trò: Tất cả vai trò (46)</span>
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end shadow-sm" style="font-size: 0.78rem;">
                            <li><a class="dropdown-item fw-bold" href="#">Tất cả vai trò (46)</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="#">Super Admin (4)</a></li>
                            <li><a class="dropdown-item" href="#">Moderator Sản phẩm (18)</a></li>
                            <li><a class="dropdown-item" href="#">Kế toán Tài chính (14)</a></li>
                            <li><a class="dropdown-item" href="#">CSKH & Trọng tài (10)</a></li>
                        </ul>
                    </div>

                    <!-- Dropdown: Trạng thái -->
                    <div class="dropdown">
                        <button class="filter-select-btn dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <span>Trạng thái: Tất cả</span>
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end shadow-sm" style="font-size: 0.78rem;">
                            <li><a class="dropdown-item fw-bold" href="#">Tất cả trạng thái</a></li>
                            <li><a class="dropdown-item" href="#">Đang hoạt động</a></li>
                            <li><a class="dropdown-item" href="#">Tạm dừng</a></li>
                        </ul>
                    </div>

                    <!-- Dropdown: 2FA -->
                    <div class="dropdown">
                        <button class="filter-select-btn dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <span>2FA: Đã bật</span>
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end shadow-sm" style="font-size: 0.78rem;">
                            <li><a class="dropdown-item fw-bold" href="#">2FA: Đã bật</a></li>
                            <li><a class="dropdown-item" href="#">Google Auth</a></li>
                            <li><a class="dropdown-item" href="#">FIDO2 Security Key</a></li>
                            <li><a class="dropdown-item" href="#">SMS OTP</a></li>
                            <li><a class="dropdown-item" href="#">Chưa kích hoạt 2FA</a></li>
                        </ul>
                    </div>
                </div>
            </div>

            <!-- 5. Staff & Permissions Table -->
            <div class="users-table-container">
                <table class="users-modern-table">
                    <thead>
                        <tr>
                            <th>THÀNH VIÊN & ĐỊNH DANH</th>
                            <th>BỘ PHẬN / NHÓM</th>
                            <th>BẢO MẬT 2FA</th>
                            <th>HOẠT ĐỘNG GẦN NHẤT</th>
                            <th>TRẠNG THÁI</th>
                            <th class="text-end">THAO TÁC</th>
                        </tr>
                    </thead>
                    <tbody id="usersTableBody">
                        <c:forEach items="${usersList}" var="u">
                            <tr>
                                <td>
                                    <div class="user-cell-meta">
                                        <div class="rounded-circle bg-light text-success fw-bold d-flex align-items-center justify-content-center border" style="width: 38px; height: 38px; font-size: 0.85rem; flex-shrink: 0;">
                                            ${fn:substring(u.fullName, 0, 1)}
                                        </div>
                                        <div>
                                            <div class="d-flex align-items-center">
                                                <span class="user-meta-name">${u.fullName}</span>
                                                <span class="role-pill-super ms-1">${u.roleName}</span>
                                            </div>
                                            <div class="user-meta-sub">${u.email} • ${u.phone} • ID: #${u.userId}</div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div><strong>${u.membershipTier}</strong></div>
                                    <div class="text-muted" style="font-size: 0.68rem;">
                                        <c:choose>
                                            <c:when test="${not empty u.shopName}">Shop: ${u.shopName}</c:when>
                                            <c:otherwise>Ngày tạo: ${u.createdAtFormatted}</c:otherwise>
                                        </c:choose>
                                    </div>
                                </td>
                                <td>
                                    <span class="badge-2fa-green">
                                        <i class="bi bi-shield-check"></i> Xác thực
                                    </span>
                                </td>
                                <td>
                                    <span class="d-inline-flex align-items-center gap-1 text-success fw-semibold">
                                        <i class="bi bi-circle-fill" style="font-size: 0.45rem;"></i> ${u.createdAtFormatted}
                                    </span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${u.status == 'ACTIVE'}">
                                            <span class="status-active-pill">
                                                <i class="bi bi-circle-fill" style="font-size: 0.45rem;"></i> Hoạt động
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-paused-pill">
                                                <i class="bi bi-circle-fill" style="font-size: 0.45rem;"></i> ${u.status}
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end">
                                    <button type="button" class="action-tool-btn" title="Chỉnh sửa quyền" onclick="openAssignRoleModal('${u.userId}', '${u.fullName}', '${u.roleName}')">
                                        <i class="bi bi-pencil"></i>
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty usersList}">
                            <tr>
                                <td colspan="6" class="text-center text-muted py-4">Không tìm thấy tài khoản người dùng nào.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>

                <!-- Pagination Footer -->
                <div class="users-table-footer">
                    <span>Tổng cộng <strong>${not empty usersList ? usersList.size() : 0}</strong> tài khoản trong danh sách</span>
                </div>
            </div>

            <!-- 6. Role Matrix Overview Section -->
            <div class="role-matrix-section" id="roleMatrixSection">
                <div class="role-matrix-header">
                    <div>
                        <h2 class="role-matrix-title">Phân Quyền Nhanh Theo Vai Trò (Role Matrix Overview)</h2>
                        <p class="role-matrix-desc">Các nhóm quyền quản trị được cấu hình theo chính sách bảo mật nội bộ FreshFruit.</p>
                    </div>
                    <a href="#roleMatrixSection" class="role-matrix-link">
                        Xem toàn bộ 6 nhóm quyền →
                    </a>
                </div>

                <div class="role-matrix-grid-4">
                    <!-- Role Card 1: Super Admin -->
                    <div class="role-card">
                        <div>
                            <div class="role-card-top">
                                <div class="role-icon-circle circle-purple">
                                    <i class="bi bi-shield-lock-fill"></i>
                                </div>
                                <span class="badge-role-members badge-members-purple">4 thành viên</span>
                            </div>
                            <h3 class="role-card-title">Super Admin</h3>
                            <p class="role-card-desc">Toàn quyền truy cập mọi module, quản lý tài chính, phân quyền nhân sự cấp cao và cấu hình hệ sinh thái sàn.</p>
                        </div>
                        <a href="javascript:void(0)" onclick="alert('Đang mở ma trận phân quyền Super Admin...')" class="btn-role-config">
                            <span>Cấu hình chi tiết quyền hạn</span>
                            <i class="bi bi-gear"></i>
                        </a>
                    </div>

                    <!-- Role Card 2: Quản lý Gian hàng & Kiểm duyệt -->
                    <div class="role-card">
                        <div>
                            <div class="role-card-top">
                                <div class="role-icon-circle circle-blue">
                                    <i class="bi bi-card-checklist"></i>
                                </div>
                                <span class="badge-role-members badge-members-blue">18 thành viên</span>
                            </div>
                            <h3 class="role-card-title">Quản lý Gian hàng & Kiểm duyệt</h3>
                            <p class="role-card-desc">Thẩm định hồ sơ pháp lý shop, kiểm tra chứng nhận tiêu chuẩn VietGAP/GlobalGAP, duyệt hoặc gỡ sản phẩm nông sản.</p>
                        </div>
                        <a href="javascript:void(0)" onclick="alert('Đang mở ma trận phân quyền Kiểm duyệt & Shop...')" class="btn-role-config">
                            <span>Cấu hình chi tiết quyền hạn</span>
                            <i class="bi bi-gear"></i>
                        </a>
                    </div>

                    <!-- Role Card 3: Kế toán Tài chính -->
                    <div class="role-card">
                        <div>
                            <div class="role-card-top">
                                <div class="role-icon-circle circle-green">
                                    <i class="bi bi-wallet2"></i>
                                </div>
                                <span class="badge-role-members badge-members-green">14 thành viên</span>
                            </div>
                            <h3 class="role-card-title">Kế toán Tài chính</h3>
                            <p class="role-card-desc">Quản lý đối soát doanh thu chuỗi cung ứng, phê duyệt lệnh rút tiền ví của Nhà vườn và theo dõi phí hoa hồng nền tảng.</p>
                        </div>
                        <a href="javascript:void(0)" onclick="alert('Đang mở ma trận phân quyền Kế toán Tài chính...')" class="btn-role-config">
                            <span>Cấu hình chi tiết quyền hạn</span>
                            <i class="bi bi-gear"></i>
                        </a>
                    </div>

                    <!-- Role Card 4: CSKH & Hòa giải Khiếu nại -->
                    <div class="role-card">
                        <div>
                            <div class="role-card-top">
                                <div class="role-icon-circle circle-orange">
                                    <i class="bi bi-headset"></i>
                                </div>
                                <span class="badge-role-members badge-members-orange">10 thành viên</span>
                            </div>
                            <h3 class="role-card-title">CSKH & Hòa giải Khiếu nại</h3>
                            <p class="role-card-desc">Xử lý tranh chấp quả dập hỏng, xử lý yêu cầu hoàn tiền người mua, quản trị đánh giá sản phẩm và hỗ trợ người dùng 24/7.</p>
                        </div>
                        <a href="javascript:void(0)" onclick="alert('Đang mở ma trận phân quyền CSKH & Hòa giải...')" class="btn-role-config">
                            <span>Cấu hình chi tiết quyền hạn</span>
                            <i class="bi bi-gear"></i>
                        </a>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<!-- Modal 1: Thêm Quản trị viên mới -->
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
                        <label class="form-label small fw-bold text-muted">Mã Nhân Viên Định Danh</label>
                        <input type="text" name="employeeId" class="form-control" placeholder="NV-052" style="font-size: 0.82rem; border-radius: 8px;">
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-bold text-muted">Bộ Phận / Khối Nghiệp Vụ <span class="text-danger">*</span></label>
                        <select name="department" class="form-select" required style="font-size: 0.82rem; border-radius: 8px;">
                            <option value="BAN_GIAM_DOC">Ban Giám Đốc (Executive Leadership)</option>
                            <option value="VAN_HANH" selected>Vận Hành Sàn (Marketplace Operations)</option>
                            <option value="KE_TOAN">Tài Chính – Kế Toán (Finance & Settlement)</option>
                            <option value="CSKH">Chăm Sóc Khách Hàng (Customer Support & Mediation)</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-bold text-muted">Vai Trò & Nhóm Quyền Hạn (RBAC) <span class="text-danger">*</span></label>
                        <select name="roleCode" class="form-select" required style="font-size: 0.82rem; border-radius: 8px;">
                            <option value="SUPER_ADMIN">👑 Super Admin (Toàn quyền hệ thống)</option>
                            <option value="MODERATOR" selected>🛡️ Moderator Sản phẩm (Kiểm định VietGAP)</option>
                            <option value="ACCOUNTANT">💰 Kế toán Đối soát (Ví sàn & Thanh toán)</option>
                            <option value="CSKH">🎧 Hòa giải & CSKH (Khiếu nại & Hoàn cọc)</option>
                            <option value="SHOP_MANAGER">🏪 Quản lý Gian hàng (Thẩm định hợp tác xã)</option>
                        </select>
                    </div>
                    <div class="form-check mb-2">
                        <input class="form-check-input" type="checkbox" id="require2fa" name="require2fa" checked>
                        <label class="form-check-label small text-muted" for="require2fa">
                            Bắt buộc kích hoạt xác thực 2 bước (2FA) khi đăng nhập lần đầu
                        </label>
                    </div>
                </div>
                <div class="modal-footer" style="border-top: 1px solid #f1f5f9; padding: 0.85rem 1.4rem;">
                    <button type="button" class="btn btn-light btn-sm fw-bold px-3" data-bs-dismiss="modal" style="border-radius: 8px;">Hủy bỏ</button>
                    <button type="submit" class="btn btn-success btn-sm fw-bold px-3" style="background: #15803d; border-color: #15803d; border-radius: 8px;">
                        <i class="bi bi-send-check me-1"></i> Gửi Thư Mời Gia Nhập
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal 2: Phân quyền & Cấp vai trò -->
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
                        <div class="fw-bold fs-6 text-dark" id="modalUserNameDisplay">Sarah Jenkins (ID: #1)</div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-bold text-muted">Nhóm Vai Trò Hệ Thống <span class="text-danger">*</span></label>
                        <select name="newRole" id="modalUserRoleSelect" class="form-select" style="font-size: 0.82rem; border-radius: 8px;">
                            <option value="SUPER_ADMIN">👑 Super Admin (Toàn quyền hệ thống)</option>
                            <option value="MODERATOR">🛡️ Moderator Sản phẩm (Kiểm định chất lượng)</option>
                            <option value="ACCOUNTANT">💰 Kế toán Đối soát (Ví sàn & Quyết toán)</option>
                            <option value="CSKH">🎧 Hòa giải & CSKH (Khiếu nại hư hỏng)</option>
                            <option value="SHOP_MANAGER">🏪 Quản lý Gian hàng (Thẩm định hợp tác xã)</option>
                        </select>
                    </div>
                    <div class="mb-2">
                        <label class="form-label small fw-bold text-muted">Trạng Thái Tài Khoản</label>
                        <select name="userStatus" class="form-select" style="font-size: 0.82rem; border-radius: 8px;">
                            <option value="ACTIVE" selected>● Đang hoạt động (Active)</option>
                            <option value="PAUSED">● Tạm dừng (Paused)</option>
                            <option value="LOCKED">● Khóa quyền truy cập (Locked)</option>
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
<script src="${pageContext.request.contextPath}/assets/js/admin.js?v=11"></script>
</body>
</html>
