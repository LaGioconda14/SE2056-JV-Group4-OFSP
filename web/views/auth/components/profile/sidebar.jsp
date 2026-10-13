<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="sidebar-user-card">
    <div class="user-avatar-wrap">
        <c:choose>
            <c:when test="${not empty user.avatarUrl}">
                <c:set var="userSidebarAvatar" value="${user.avatarUrl.startsWith('http://') or user.avatarUrl.startsWith('https://') ? user.avatarUrl : pageContext.request.contextPath.concat('/').concat(user.avatarUrl)}" />
                <img src="${userSidebarAvatar}" class="avatar-sidebar" alt="Avatar" onerror="this.onerror=null; this.src='https://ui-avatars.com/api/?name=${user.fullName}&background=046A38&color=fff';">
            </c:when>
            <c:otherwise>
                <div class="avatar-placeholder">
                    ${not empty user.fullName ? user.fullName.substring(0, 1).toUpperCase() : 'U'}
                </div>
            </c:otherwise>
        </c:choose>
        <span class="online-dot" title="Tài khoản đang hoạt động"></span>
    </div>
    <h5 class="fw-bold text-dark mb-1">${user.fullName}</h5>
    <p class="text-muted small mb-0">${user.email}</p>
</div>

<div class="sidebar-menu-card">
    <div class="nav flex-column" id="profileSidebarTab" role="tablist">
        <button class="sidebar-nav-item active" id="nav-profile-tab" data-bs-toggle="pill" data-bs-target="#nav-profile" type="button" role="tab">
            <span><i class="bi bi-person-fill"></i> Thông tin cá nhân</span>
            <i class="bi bi-chevron-right small"></i>
        </button>

        <button class="sidebar-nav-item" id="nav-orders-tab" data-bs-toggle="pill" data-bs-target="#nav-orders" type="button" role="tab">
            <span><i class="bi bi-bag-check-fill"></i> Đơn mua</span>
            <c:choose>
                <c:when test="${not empty ordersCount and ordersCount > 0}">
                    <span class="badge bg-success rounded-pill badge-sidebar-sm">${ordersCount}</span>
                </c:when>
                <c:otherwise>
                    <i class="bi bi-chevron-right small"></i>
                </c:otherwise>
            </c:choose>
        </button>

        <button class="sidebar-nav-item" id="nav-vouchers-tab" data-bs-toggle="pill" data-bs-target="#nav-vouchers" type="button" role="tab">
            <span><i class="bi bi-ticket-perforated-fill"></i> Kho voucher</span>
            <c:choose>
                <c:when test="${not empty vouchersCount and vouchersCount > 0}">
                    <span class="badge bg-warning text-dark rounded-pill fw-bold badge-sidebar-sm">${vouchersCount} mã</span>
                </c:when>
                <c:otherwise>
                    <i class="bi bi-chevron-right small"></i>
                </c:otherwise>
            </c:choose>
        </button>

        <button class="sidebar-nav-item" id="nav-notifications-tab" data-bs-toggle="pill" data-bs-target="#nav-notifications" type="button" role="tab">
            <span><i class="bi bi-bell-fill"></i> Thông báo</span>
            <c:choose>
                <c:when test="${not empty unreadNotificationsCount and unreadNotificationsCount > 0}">
                    <span class="badge bg-danger rounded-pill badge-sidebar-sm">${unreadNotificationsCount} mới</span>
                </c:when>
                <c:otherwise>
                    <i class="bi bi-chevron-right small"></i>
                </c:otherwise>
            </c:choose>
        </button>

        <button class="sidebar-nav-item" id="nav-address-tab" data-bs-toggle="pill" data-bs-target="#nav-address" type="button" role="tab">
            <span><i class="bi bi-geo-alt-fill"></i> Địa chỉ</span>
            <i class="bi bi-chevron-right small"></i>
        </button>

        <button class="sidebar-nav-item" id="nav-security-tab" data-bs-toggle="pill" data-bs-target="#nav-security" type="button" role="tab">
            <span><i class="bi bi-shield-lock-fill"></i> Bảo mật & Đăng nhập</span>
            <span class="badge bg-success rounded-pill badge-xs">Chuẩn</span>
        </button>

        <hr class="my-2 border-secondary-subtle">

        <a href="${pageContext.request.contextPath}/logout" class="sidebar-nav-item logout-link">
            <span><i class="bi bi-box-arrow-right text-danger"></i> Đăng xuất tài khoản</span>
        </a>
    </div>
</div>

<div class="farm-badge-box">
    <div class="farm-badge-header">
        <i class="bi bi-patch-check-fill fs-4 text-success"></i>
        <strong class="text-dark small">Bảo chứng 100% Nông Trại</strong>
    </div>
    <p class="farm-guarantee-text">
        Mỗi sản phẩm trái cây giao đến đều có tem QR truy xuất nguồn gốc từ các nông trại sạch VietGAP/GlobalGAP liên kết.
    </p>
</div>

