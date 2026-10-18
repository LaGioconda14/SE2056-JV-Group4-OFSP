<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!-- Top Announcement Bar -->
<div class="top-announcement">
    <div class="container d-flex justify-content-between align-items-center">
        <div>
            <i class="bi bi-truck me-1"></i> Giao hàng miễn phí trong ngày cho đơn từ 200.000₫ | <strong>Cam kết 100% Nông Trại Sạch</strong>
        </div>
        <div class="announcement-hotline">
            <span><i class="bi bi-telephone-fill me-1"></i> Hotline: 1900 6868</span>
            <span>VND (₫)</span>
            <span>Tiếng Việt</span>
        </div>
    </div>
</div>

<!-- Main Navbar -->
<nav class="navbar-main">
    <div class="container navbar-main-inner">
        <a href="${pageContext.request.contextPath}/home.jsp" class="brand-link">
            <span class="fs-2">🍎</span>
            <div>
                <div class="brand-title">FreshFruit</div>
                <div class="brand-sub">DIRECT FROM ORCHARD</div>
            </div>
        </a>

        <div class="nav-search-wrap">
            <div class="search-container">
                <select class="nav-search-select">
                    <option>Tất cả danh mục</option>
                    <option>Trái cây nội địa</option>
                    <option>Trái cây nhập khẩu</option>
                    <option>Giỏ quà organic</option>
                </select>
                <div class="vr my-1"></div>
                <input type="text" placeholder="Tìm kiếm dâu tây, bơ sáp, nho mẫu đơn...">
                <button class="btn btn-fresh-green btn-sm px-3 py-1">
                    <i class="bi bi-search"></i>
                </button>
            </div>
        </div>

        <div class="nav-right-actions">
            <a href="${pageContext.request.contextPath}/cart" class="nav-cart-btn">
                <div class="nav-cart-icon-wrap">
                    <i class="bi bi-cart3 nav-cart-icon"></i>
                    <c:if test="${not empty sessionScope.cartCount and sessionScope.cartCount > 0}">
                        <span class="nav-cart-badge">${sessionScope.cartCount}</span>
                    </c:if>
                </div>
                <span class="nav-cart-text">Giỏ hàng</span>
            </a>

            <div class="dropdown">
                <a href="#" class="nav-user-btn dropdown-toggle" data-bs-toggle="dropdown">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user.avatarUrl}">
                            <c:set var="navAvatar" value="${sessionScope.user.avatarUrl.startsWith('http://') or sessionScope.user.avatarUrl.startsWith('https://') ? sessionScope.user.avatarUrl : pageContext.request.contextPath.concat('/').concat(sessionScope.user.avatarUrl)}" />
                            <img src="${navAvatar}" class="avatar-nav" alt="Avatar" onerror="this.onerror=null; this.src='https://ui-avatars.com/api/?name=${sessionScope.user.fullName}&background=046A38&color=fff';">
                        </c:when>
                        <c:otherwise>
                            <div class="avatar-placeholder avatar-nav">
                                ${not empty sessionScope.user.fullName ? sessionScope.user.fullName.substring(0, 1).toUpperCase() : 'U'}
                            </div>
                        </c:otherwise>
                    </c:choose>
                    <span class="nav-user-name">${sessionScope.user.fullName}</span>
                </a>
                <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0 rounded-3 mt-2">
                    <li><h6 class="dropdown-header small text-muted">Tài khoản hội viên</h6></li>
                    <c:if test="${sessionScope.user.role == 'DRIVER' or sessionScope.user.role == 'driver'}">
                        <li>
                            <a class="dropdown-item small text-warning-emphasis fw-bold bg-warning-subtle py-2" href="${pageContext.request.contextPath}/shipper/deliveries">
                                <i class="bi bi-truck me-2 text-warning"></i>Cổng Giao Vận (Tài Xế)
                            </a>
                        </li>
                        <li><hr class="dropdown-divider"></li>
                    </c:if>
                    <c:if test="${sessionScope.user.role == 'ADMIN' or sessionScope.user.role == 'STAFF'}">
                        <li>
                            <a class="dropdown-item small text-warning-emphasis fw-bold bg-warning-subtle py-2" href="${pageContext.request.contextPath}/shipper/deliveries">
                                <i class="bi bi-truck me-2 text-warning"></i>Cổng Giao Vận (Demo Driver 9)
                            </a>
                        </li>
                        <li><hr class="dropdown-divider"></li>
                    </c:if>
                    <c:if test="${sessionScope.user.role == 'SHOP_OWNER' or sessionScope.user.role == 'shop_owner'}">
                        <li>
                            <a class="dropdown-item small text-success fw-bold bg-success-subtle py-2" href="${pageContext.request.contextPath}/shop/orders">
                                <i class="bi bi-shop me-2 text-success"></i>Quản Lý Gian Hàng
                            </a>
                        </li>
                        <li><hr class="dropdown-divider"></li>
                    </c:if>
                    <li><a class="dropdown-item active small" href="${pageContext.request.contextPath}/profile"><i class="bi bi-person me-2"></i>Hồ sơ cá nhân</a></li>
                    <li><a class="dropdown-item small" href="${pageContext.request.contextPath}/change-password"><i class="bi bi-key me-2"></i>Đổi mật khẩu</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item small text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-2"></i>Đăng xuất</a></li>
                </ul>
            </div>
        </div>
    </div>
</nav>

<!-- Sub Navigation -->
<div class="sub-nav">
    <div class="container sub-nav-inner">
        <div class="sub-nav-links">
            <a href="${pageContext.request.contextPath}/home.jsp" class="nav-link">Trang Chủ</a>
            <a href="#" class="nav-link">Cửa Hàng</a>
            <a href="#" class="nav-link">Danh Mục Trái Cây</a>
            <a href="#" class="nav-link">Hộp Quà & Combo</a>
            <a href="#" class="nav-link">Về Nông Trại</a>
            <a href="#" class="nav-link">Liên Hệ</a>
        </div>
        <div class="flash-sale-badge">
            <i class="bi bi-lightning-charge-fill"></i> Flash Sale Hôm Nay: Giảm 30% Cam & Bưởi Da Xanh
        </div>
    </div>
</div>

