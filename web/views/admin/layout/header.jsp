<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<header class="admin-topbar">
    <div class="d-flex align-items-center gap-3 flex-grow-1">
        <div class="topbar-search-box">
            <i class="bi bi-search"></i>
            <input type="text" placeholder="Search orders, shops, users, reports (Ctrl + K)..." data-i18n-attr="placeholder:search_placeholder">
            <span class="shortcut-badge">⌘K</span>
        </div>
    </div>

    <div class="d-flex align-items-center gap-2">
        <!-- Date Filter Dropdown -->
        <button class="btn-date-range" type="button">
            <i class="bi bi-calendar3"></i>
            <span data-i18n="btn_date_filter">Last 30 Days</span>
            <i class="bi bi-chevron-down ms-1" style="font-size: 0.65rem;"></i>
        </button>

        <!-- Export Report Button -->
        <button class="btn-export-report" type="button" onclick="alert('Đang tạo báo cáo tài chính & vận hành sàn...');">
            <i class="bi bi-download"></i>
            <span data-i18n="btn_export_report">Export Report</span>
        </button>

        <!-- Language Switcher Dropdown -->
        <div class="dropdown lang-dropdown ms-1">
            <button class="btn-lang-switcher dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false" id="currentLangBtn" title="Chuyển đổi ngôn ngữ / Change language">
                <span id="currentLangFlag">🇻🇳</span> <span id="currentLangLabel">VIE</span>
            </button>
            <ul class="dropdown-menu dropdown-menu-end shadow-sm" aria-labelledby="currentLangBtn">
                <li>
                    <button class="dropdown-item lang-option d-flex align-items-center gap-2" type="button" data-lang="vi" onclick="setLanguage('vi')">
                        <span>🇻🇳</span> <span>Tiếng Việt (VIE)</span>
                    </button>
                </li>
                <li>
                    <button class="dropdown-item lang-option d-flex align-items-center gap-2" type="button" data-lang="en" onclick="setLanguage('en')">
                        <span>🇬🇧</span> <span>English (ENG)</span>
                    </button>
                </li>
            </ul>
        </div>

        <!-- Notification Bell -->
        <a href="${pageContext.request.contextPath}/admin/disputes" class="btn-notification-bell ms-1" title="Thông báo hệ thống">
            <i class="bi bi-bell"></i>
            <span class="badge-dot">3</span>
        </a>

        <!-- User Avatar & Profile -->
        <a href="${pageContext.request.contextPath}/admin/users" class="d-flex align-items-center gap-2 text-decoration-none ms-1">
            <c:choose>
                <c:when test="${not empty sessionScope.user and not empty sessionScope.user.avatarUrl}">
                    <img src="${sessionScope.user.avatarUrl}" alt="Avatar" style="width: 34px; height: 34px; border-radius: 50%; object-fit: cover; border: 2px solid #ffffff; box-shadow: 0 1px 3px rgba(0,0,0,0.1);">
                </c:when>
                <c:otherwise>
                    <div class="rounded-circle bg-success text-white d-flex align-items-center justify-content-center fw-bold" style="width: 34px; height: 34px; font-size: 0.8rem;">AD</div>
                </c:otherwise>
            </c:choose>
            <div class="d-none d-sm-block text-start" style="line-height: 1.15;">
                <div class="fw-bold text-dark" style="font-size: 0.76rem;">${not empty sessionScope.user ? sessionScope.user.fullName : 'Quản Trị Viên'}</div>
                <div class="text-muted" style="font-size: 0.65rem;">Platform Admin</div>
            </div>
        </a>
    </div>
</header>
