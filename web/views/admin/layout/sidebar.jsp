<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<aside class="admin-sidebar">
    <div class="sidebar-header">
        <div class="brand-icon-box">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#15803d" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M11 20A7 7 0 0 1 9.8 6.1C15.5 5 17 4.48 19 2c1 2 2 4.18 2 8 0 5.5-4.78 10-10 10Z"/>
                <path d="M2 21c0-3 1.85-5.36 5.08-6C9.5 14.52 12 13 13 12"/>
            </svg>
        </div>
        <div class="brand-text">
            <h4>FreshFruit</h4>
            <span class="brand-badge" data-i18n="brand_badge">PLATFORM ADMIN</span>
        </div>
    </div>

    <div class="sidebar-content">
        <!-- 1. CORE -->
        <div class="nav-section-title" data-i18n="nav_sec_core">CORE</div>
        <ul class="sidebar-nav">
            <li>
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="sidebar-nav-link ${param.activePage == 'dashboard' ? 'active' : ''}">
                    <i class="bi bi-grid-fill"></i>
                    <span data-i18n="nav_dashboard">Overview Dashboard</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/users" class="sidebar-nav-link ${param.activePage == 'users' ? 'active' : ''}">
                    <i class="bi bi-people"></i>
                    <span data-i18n="nav_users">Users & Permissions</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/shops" class="sidebar-nav-link ${param.activePage == 'shops' ? 'active' : ''}">
                    <i class="bi bi-shop"></i>
                    <span data-i18n="nav_shops_apps">Shops & Applications</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/categories" class="sidebar-nav-link ${param.activePage == 'categories' ? 'active' : ''}">
                    <i class="bi bi-diagram-3"></i>
                    <span data-i18n="nav_categories">Global Categories</span>
                </a>
            </li>
        </ul>

        <!-- 2. GOVERNANCE -->
        <div class="nav-section-title" data-i18n="nav_sec_gov">GOVERNANCE</div>
        <ul class="sidebar-nav">
            <li>
                <a href="${pageContext.request.contextPath}/admin/orders" class="sidebar-nav-link ${param.activePage == 'orders' ? 'active' : ''}">
                    <i class="bi bi-box-seam"></i>
                    <span data-i18n="nav_orders">Orders & Deliveries</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/product-moderation" class="sidebar-nav-link ${param.activePage == 'moderation' ? 'active' : ''}">
                    <i class="bi bi-shield-check"></i>
                    <span data-i18n="nav_moderation">Product Moderation</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/disputes" class="sidebar-nav-link ${param.activePage == 'disputes' ? 'active' : ''}">
                    <i class="bi bi-scale"></i>
                    <span data-i18n="nav_disputes">Disputes & Refunds</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/vouchers" class="sidebar-nav-link ${param.activePage == 'vouchers' ? 'active' : ''}">
                    <i class="bi bi-ticket-perforated"></i>
                    <span data-i18n="nav_vouchers">Platform Vouchers</span>
                </a>
            </li>
        </ul>
    </div>

    <div class="sidebar-footer">
        <div class="sidebar-user-card">
            <c:choose>
                <c:when test="${not empty sessionScope.user and not empty sessionScope.user.avatarUrl}">
                    <img src="${sessionScope.user.avatarUrl}" alt="Avatar" style="width: 32px; height: 32px; border-radius: 50%; object-fit: cover; flex-shrink: 0;">
                </c:when>
                <c:otherwise>
                    <div class="rounded-circle bg-success text-white d-flex align-items-center justify-content-center fw-bold" style="width: 32px; height: 32px; font-size: 0.75rem; flex-shrink: 0;">AD</div>
                </c:otherwise>
            </c:choose>
            <div class="sidebar-user-info">
                <div class="sidebar-user-name">${sessionScope.user != null ? sessionScope.user.fullName : 'Quản Trị Viên'}</div>
                <div class="sidebar-user-role" data-i18n="user_role">Platform Admin</div>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="sidebar-logout-btn" title="Đăng Xuất">
                <i class="bi bi-box-arrow-right"></i>
            </a>
        </div>
    </div>
</aside>
