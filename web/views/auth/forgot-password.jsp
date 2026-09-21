<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password - FreshFruit Platform</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts: Plus Jakarta Sans -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Custom Auth Stylesheet -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth.css?v=2">
</head>
<body>

<div class="login-wrapper">
    <!-- LEFT PANEL: Brand, Showcase & Metrics -->
    <div class="showcase-panel">
        <div>
            <div class="brand-logo-wrap">
                <div class="brand-logo-icon">🍎</div>
                <div>
                    <div class="brand-name">FreshFruit</div>
                    <div class="brand-sub">DIRECT FROM ORCHARD</div>
                </div>
            </div>
            
            <p class="hero-desc">
                Fresh organic produce delivered right from local family orchards straight to your table.
            </p>

            <div class="pill-badge">
                <i class="bi bi-shield-lock-fill text-warning"></i>
                <span>Account Security & Recovery</span>
            </div>
        </div>

        <!-- 3 Feature Metrics -->
        <div class="metrics-grid">
            <div class="metric-box">
                <i class="bi bi-shield-check"></i>
                <div class="metric-label">100% Certified Organic</div>
            </div>
            <div class="metric-box">
                <i class="bi bi-truck"></i>
                <div class="metric-label">Same-Day Dispatch</div>
            </div>
            <div class="metric-box">
                <i class="bi bi-heart-fill"></i>
                <div class="metric-label">15,000+ Happy Homes</div>
            </div>
        </div>
    </div>

    <!-- RIGHT PANEL: Forgot Password Form -->
    <div class="form-panel">
        <div>
            <!-- Top Status Bar -->
            <div class="top-status-bar">
                <div class="secure-pill">
                    <span class="secure-dot"></span>
                    <span>Recovery Portal</span>
                </div>
                <a href="${pageContext.request.contextPath}/help" class="help-link">
                    <span>Help Center</span>
                    <i class="bi bi-box-arrow-up-right small"></i>
                </a>
            </div>

            <!-- Tab Switcher (Forgot Password is ACTIVE) -->
            <div class="auth-nav-tabs">
                <a href="${pageContext.request.contextPath}/login" class="auth-tab-btn">Sign In</a>
                <a href="${pageContext.request.contextPath}/register" class="auth-tab-btn">Create Account</a>
                <a href="${pageContext.request.contextPath}/forgot-password" class="auth-tab-btn active">Forgot Password</a>
            </div>

            <h1 class="form-title">Reset password</h1>
            <p class="form-subtitle">Enter your registered email address to receive a 6-digit OTP verification code.</p>

            <!-- Error Alert -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center py-2 px-3 mb-3 small" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2 fs-6 flex-shrink-0"></i>
                    <div>${errorMessage}</div>
                    <button type="button" class="btn-close ms-auto py-2" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <!-- Success Alert -->
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success alert-dismissible fade show d-flex align-items-center py-2 px-3 mb-3 small" role="alert">
                    <i class="bi bi-check-circle-fill me-2 fs-6 flex-shrink-0"></i>
                    <div>${successMessage}</div>
                    <button type="button" class="btn-close ms-auto py-2" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <!-- Forgot Password Form -->
            <form action="${pageContext.request.contextPath}/forgot-password" method="POST" id="forgotForm">
                <!-- Email Address -->
                <div class="field-group mb-4">
                    <label class="field-label" for="email">Registered Email Address *</label>
                    <div class="input-box-wrapper">
                        <i class="bi bi-envelope leading-icon"></i>
                        <input type="email" 
                               id="email" 
                               name="email" 
                               placeholder="nguyenvana@example.com" 
                               value="${not empty email ? email : ''}" 
                               required 
                               autocomplete="email"
                               oninput="checkEmailValidity(this)">
                        <span class="trailing-action" id="emailStatusIcon"></span>
                    </div>
                    <div class="form-hint">
                        <i class="bi bi-info-circle"></i>
                        <span>A 6-digit OTP code will be sent to this email and expires in 5 minutes.</span>
                    </div>
                </div>

                <!-- Submit Button -->
                <button type="submit" class="btn-submit-main">
                    <span>Send Reset OTP</span>
                    <i class="bi bi-arrow-right"></i>
                </button>
            </form>

            <div class="text-center mt-4">
                <a href="${pageContext.request.contextPath}/login" class="back-link">
                    <i class="bi bi-arrow-left"></i>
                    <span>Back to Sign In</span>
                </a>
            </div>
        </div>
    </div>
</div>

<!-- Bootstrap 5 JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<!-- Custom Auth JS -->
<script src="${pageContext.request.contextPath}/assets/js/auth.js"></script>

</body>
</html>
