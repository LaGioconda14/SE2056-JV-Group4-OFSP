<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký tài khoản - FreshFruit Platform</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts: Plus Jakarta Sans -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Custom Auth Stylesheet -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth.css">
</head>
<body>

<div class="login-wrapper">
    <!-- LEFT PANEL: Brand, Orchard Background, Social Proof & Metrics -->
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
                <i class="bi bi-patch-check-fill text-warning"></i>
                <span>100% Organically Grown & Harvested</span>
            </div>
        </div>

        <!-- Floating Customer Review Card -->
        <div class="review-card">
            <div class="star-row">
                <i class="bi bi-star-fill"></i>
                <i class="bi bi-star-fill"></i>
                <i class="bi bi-star-fill"></i>
                <i class="bi bi-star-fill"></i>
                <i class="bi bi-star-fill"></i>
            </div>
            <div class="review-quote">
                "Signing up was seamless! The fruits arrived chilled and orchard-fresh within a few hours."
            </div>
            <div class="reviewer-meta">
                <div class="reviewer-user">
                    <div class="avatar-initials">TN</div>
                    <div>
                        <div class="reviewer-name">Thành Nam</div>
                        <div class="reviewer-tier">New Member • Fresh Fruit Club</div>
                    </div>
                </div>
                <i class="bi bi-patch-check-fill text-success fs-5"></i>
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

    <!-- RIGHT PANEL: Registration Form -->
    <div class="form-panel">
        <div>
            <!-- Top Status Bar -->
            <div class="top-status-bar">
                <div class="secure-pill">
                    <span class="secure-dot"></span>
                    <span>Secure Registration</span>
                </div>
                <a href="${pageContext.request.contextPath}/help" class="help-link">
                    <span>Help Center</span>
                    <i class="bi bi-box-arrow-up-right small"></i>
                </a>
            </div>

            <!-- Tab Switcher (Create Account is ACTIVE) -->
            <div class="auth-nav-tabs">
                <a href="${pageContext.request.contextPath}/login" class="auth-tab-btn">Sign In</a>
                <a href="${pageContext.request.contextPath}/register" class="auth-tab-btn active">Create Account</a>
                <a href="${pageContext.request.contextPath}/forgot-password" class="auth-tab-btn">Forgot Password</a>
            </div>

            <h1 class="form-title">Create account</h1>
            <p class="form-subtitle">Join FreshFruit today to enjoy fresh harvests and member discounts.</p>

            <!-- Alert Lỗi -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center py-2 px-3 mb-3 small" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2 fs-6 flex-shrink-0"></i>
                    <div>${errorMessage}</div>
                    <button type="button" class="btn-close ms-auto py-2" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <!-- Registration Form -->
            <form action="${pageContext.request.contextPath}/register" method="POST" id="registerForm">
                <!-- Row 1: Full Name & Phone -->
                <div class="form-row-2col">
                    <div class="field-group">
                        <label class="field-label" for="fullName">Họ và tên *</label>
                        <div class="input-box-wrapper">
                            <i class="bi bi-person leading-icon"></i>
                            <input type="text" 
                                   id="fullName" 
                                   name="fullName" 
                                   placeholder="Nguyễn Văn A" 
                                   value="${not empty fullName ? fullName : ''}" 
                                   required 
                                   autocomplete="name">
                        </div>
                    </div>

                    <div class="field-group">
                        <label class="field-label" for="phone">Số điện thoại</label>
                        <div class="input-box-wrapper">
                            <i class="bi bi-telephone leading-icon"></i>
                            <input type="tel" 
                                   id="phone" 
                                   name="phone" 
                                   placeholder="0912345678" 
                                   value="${not empty phone ? phone : ''}" 
                                   autocomplete="tel">
                        </div>
                    </div>
                </div>

                <!-- Email Address -->
                <div class="field-group">
                    <label class="field-label" for="email">Email Address *</label>
                    <div class="input-box-wrapper">
                        <i class="bi bi-envelope leading-icon"></i>
                        <input type="email" 
                               id="email" 
                               name="email" 
                               placeholder="user@example.com" 
                               value="${not empty email ? email : ''}" 
                               required 
                               autocomplete="email"
                               oninput="checkEmailValidity(this)">
                        <span class="trailing-action" id="emailStatusIcon"></span>
                    </div>
                </div>

                <!-- Row 2: Password & Confirm Password -->
                <div class="form-row-2col">
                    <div class="field-group">
                        <label class="field-label" for="password">Mật khẩu *</label>
                        <div class="input-box-wrapper">
                            <i class="bi bi-lock leading-icon"></i>
                            <input type="password" 
                                   id="password" 
                                   name="password" 
                                   placeholder="Tối thiểu 6 ký tự" 
                                   required 
                                   autocomplete="new-password">
                            <span class="trailing-action" onclick="togglePasswordVisibility('password', this)" title="Ẩn/Hiện">
                                <i class="bi bi-eye"></i>
                            </span>
                        </div>
                    </div>

                    <div class="field-group">
                        <label class="field-label" for="confirmPassword">Xác nhận mật khẩu *</label>
                        <div class="input-box-wrapper">
                            <i class="bi bi-shield-check leading-icon"></i>
                            <input type="password" 
                                   id="confirmPassword" 
                                   name="confirmPassword" 
                                   placeholder="Nhập lại mật khẩu" 
                                   required 
                                   autocomplete="new-password">
                            <span class="trailing-action" onclick="togglePasswordVisibility('confirmPassword', this)" title="Ẩn/Hiện">
                                <i class="bi bi-eye"></i>
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Policy Agreement -->
                <div class="form-actions-row">
                    <label class="remember-label" for="terms">
                        <input type="checkbox" id="terms" required checked>
                        <span>Tôi đồng ý với Điều khoản dịch vụ & Chính sách bảo mật</span>
                    </label>
                </div>

                <!-- Submit Button -->
                <button type="submit" class="btn-submit-main">
                    <span>Create Account</span>
                    <i class="bi bi-arrow-right"></i>
                </button>
            </form>

            <div class="text-center mt-3">
                <span class="text-muted small">Đã có tài khoản? </span>
                <a href="${pageContext.request.contextPath}/login" class="forgot-link small">Sign In</a>
            </div>

            <!-- Security Footer -->
            <div class="security-footer-note">
                <i class="bi bi-shield-fill-check"></i>
                <span>Protected by 256-bit SSL encryption. We never sell your personal data.</span>
            </div>
        </div>

        <!-- Test State Switcher Bar -->
        <div class="test-state-bar">
            <span class="test-state-label">TEST STATE:</span>
            <div class="test-state-links">
                <a href="${pageContext.request.contextPath}/login" class="test-state-pill">Sign In</a>
                <a href="${pageContext.request.contextPath}/register" class="test-state-pill active">Register</a>
                <a href="${pageContext.request.contextPath}/verify-otp" class="test-state-pill">OTP Screen</a>
                <a href="${pageContext.request.contextPath}/forgot-password" class="test-state-pill">Reset Sent</a>
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
