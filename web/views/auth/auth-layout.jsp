<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${not empty param.pageTitle ? param.pageTitle : 'Gốc Vườn - Nông sản tận vườn'}"/></title>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="preconnect" href="https://cdn.jsdelivr.net">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth.css?v=2">
</head>
<body>

<div class="login-wrapper">
    <!-- Showcase Panel (Cột trái dùng chung) -->
    <div class="showcase-panel">
        <div>
            <div class="brand-logo-wrap">
                <div class="brand-logo-icon">🍎</div>
                <div>
                    <div class="brand-name">Gốc Vườn</div>
                    <div class="brand-sub">NÔNG SẢN TẬN VƯỜN</div>
                </div>
            </div>
            
            <p class="hero-desc">
                Nông sản hữu cơ tươi sạch thu hoạch từ các nhà vườn chuẩn VietGAP &amp; GlobalGAP, giao thẳng đến gian bếp gia đình bạn.
            </p>

            <c:if test="${not empty param.pillBadgeText}">
                <div class="pill-badge">
                    <i class="bi ${not empty param.pillBadgeIcon ? param.pillBadgeIcon : 'bi-shield-lock-fill'} text-warning"></i>
                    <span><c:out value="${param.pillBadgeText}"/></span>
                </div>
            </c:if>
        </div>

        <div class="metrics-grid">
            <div class="metric-box">
                <i class="bi bi-shield-check"></i>
                <div class="metric-label">100% Nông sản chuẩn sạch</div>
            </div>
            <div class="metric-box">
                <i class="bi bi-truck"></i>
                <div class="metric-label">Chuỗi lạnh Fresh-Lock</div>
            </div>
            <div class="metric-box">
                <i class="bi bi-heart-fill"></i>
                <div class="metric-label">15.000+ Gia đình tin chọn</div>
            </div>
        </div>
    </div>

    <!-- Form Panel (Cột phải) -->
    <div class="form-panel">
        <div>
            <!-- Top Status Bar -->
            <div class="top-status-bar">
                <div class="secure-pill">
                    <span class="secure-dot"></span>
                    <span><c:out value="${not empty param.statusPill ? param.statusPill : 'Cổng bảo mật SSL'}"/></span>
                </div>
                <a href="${pageContext.request.contextPath}/home" class="help-link">
                    <span>Trang chủ</span>
                    <i class="bi bi-house small"></i>
                </a>
            </div>

            <!-- Navigation Tabs -->
            <c:if test="${empty param.showTabs or param.showTabs != 'false'}">
                <div class="auth-nav-tabs">
                    <a href="${pageContext.request.contextPath}/login" class="auth-tab-btn ${param.activeTab == 'login' ? 'active' : ''}">Đăng nhập</a>
                    <a href="${pageContext.request.contextPath}/register" class="auth-tab-btn ${param.activeTab == 'register' ? 'active' : ''}">Đăng ký</a>
                    <a href="${pageContext.request.contextPath}/forgot-password" class="auth-tab-btn ${(param.activeTab == 'forgot' or param.activeTab == 'reset') ? 'active' : ''}">
                        <c:out value="${not empty param.forgotTabLabel ? param.forgotTabLabel : 'Quên mật khẩu'}"/>
                    </a>
                </div>
            </c:if>

            <!-- User Info Badge (Dành cho đổi mật khẩu khi đã đăng nhập) -->
            <c:if test="${param.showUserBadge == 'true' and not empty sessionScope.user}">
                <div class="p-3 mb-3 rounded-3 d-flex align-items-center justify-content-between" style="background-color: #f0fdf4; border: 1px solid #bbf7d0;">
                    <div class="d-flex align-items-center gap-2">
                        <i class="bi bi-person-circle fs-4" style="color: var(--primary-green);"></i>
                        <div>
                            <div class="fw-bold text-dark small">${sessionScope.user.fullName}</div>
                            <div class="text-muted" style="font-size: 11.5px;">${sessionScope.user.email}</div>
                        </div>
                    </div>
                    <span class="badge" style="background-color: var(--primary-green); font-size: 11px;">${sessionScope.user.role}</span>
                </div>
            </c:if>

            <!-- Form Title & Subtitle -->
            <c:if test="${not empty param.formTitle}">
                <h1 class="form-title"><c:out value="${param.formTitle}"/></h1>
            </c:if>
            <c:if test="${not empty param.formSubtitle}">
                <p class="form-subtitle"><c:out value="${param.formSubtitle}"/></p>
            </c:if>

            <!-- Flash Alerts -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center py-2 px-3 mb-3 small" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2 fs-6 flex-shrink-0"></i>
                    <div>${errorMessage}</div>
                    <button type="button" class="btn-close ms-auto py-2" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <c:if test="${not empty successMessage}">
                <div class="alert alert-success alert-dismissible fade show d-flex align-items-center py-2 px-3 mb-3 small" role="alert">
                    <i class="bi bi-check-circle-fill me-2 fs-6 flex-shrink-0"></i>
                    <div>${successMessage}</div>
                    <button type="button" class="btn-close ms-auto py-2" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <!-- Google Social Auth (Tuỳ chọn cho login & register) -->
            <c:if test="${param.showGoogle == 'true'}">
                <a href="${pageContext.request.contextPath}/login-google" class="social-btn w-100" id="btnGoogleLogin">
                    <svg width="18" height="18" viewBox="0 0 24 24">
                        <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                        <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                        <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"/>
                        <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"/>
                    </svg>
                    <span><c:out value="${not empty param.googleBtnText ? param.googleBtnText : 'Đăng nhập bằng Google'}"/></span>
                </a>

                <div class="or-divider">
                    <span>HOẶC DÙNG EMAIL / SỐ ĐIỆN THOẠI</span>
                </div>
            </c:if>

            <!-- Dynamic Form Content -->
            <c:if test="${not empty param.contentPage}">
                <jsp:include page="${param.contentPage}" />
            </c:if>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/auth.js"></script>

</body>
</html>
