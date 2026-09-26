<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In - FreshFruit Platform</title>
    
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

    <!-- RIGHT PANEL: Sign In Form -->
    <div class="form-panel">
        <div>
            <!-- Top Status Bar -->
            <div class="top-status-bar">
                <div class="secure-pill">
                    <span class="secure-dot"></span>
                    <span>Secure Portal</span>
                </div>
                <a href="${pageContext.request.contextPath}/help" class="help-link">
                    <span>Help Center</span>
                    <i class="bi bi-box-arrow-up-right small"></i>
                </a>
            </div>

            <!-- Tab Switcher -->
            <div class="auth-nav-tabs">
                <a href="${pageContext.request.contextPath}/login" class="auth-tab-btn active">Sign In</a>
                <a href="${pageContext.request.contextPath}/register" class="auth-tab-btn">Create Account</a>
                <a href="${pageContext.request.contextPath}/forgot-password" class="auth-tab-btn">Forgot Password</a>
            </div>

            <h1 class="form-title">Welcome back!</h1>
            <p class="form-subtitle">Enter your account credentials to access fresh daily harvests.</p>

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

            <!-- Social Sign-in Button -->
            <a href="${pageContext.request.contextPath}/login-google" class="social-btn w-100" id="btnGoogleLogin">
                <svg width="18" height="18" viewBox="0 0 24 24">
                    <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                    <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                    <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"/>
                    <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"/>
                </svg>
                <span>Continue with Google</span>
            </a>

            <!-- Divider -->
            <div class="or-divider">
                <span>OR EMAIL</span>
            </div>

            <!-- Main Form -->
            <form action="${pageContext.request.contextPath}/login" method="POST" id="loginForm">
                <!-- Email Address -->
                <div class="field-group">
                    <label class="field-label" for="email">Email Address</label>
                    <div class="input-box-wrapper">
                        <i class="bi bi-envelope leading-icon"></i>
                        <input type="email" 
                               id="email" 
                               name="email" 
                               placeholder="nguyenvana@example.com" 
                               value="${not empty rememberEmail ? rememberEmail : (not empty email ? email : '')}" 
                               required 
                               autocomplete="email"
                               oninput="checkEmailValidity(this)">
                        <span class="trailing-action" id="emailStatusIcon"></span>
                    </div>
                </div>

                <!-- Password -->
                <div class="field-group">
                    <label class="field-label" for="password">Password</label>
                    <div class="input-box-wrapper">
                        <i class="bi bi-lock leading-icon"></i>
                        <input type="password" 
                               id="password" 
                               name="password" 
                               placeholder="••••••••••••••••" 
                               value="${not empty rememberPassword ? rememberPassword : ''}" 
                               required 
                               autocomplete="current-password">
                        <span class="trailing-action" onclick="togglePasswordVisibility('password', this)" title="Show/Hide password">
                            <i class="bi bi-eye"></i>
                        </span>
                    </div>
                </div>

                <!-- Actions Row -->
                <div class="form-actions-row">
                    <label class="remember-label" for="remember">
                        <input type="checkbox" 
                               name="remember" 
                               id="remember" 
                               value="1" 
                               ${not empty rememberChecked ? 'checked' : ''}>
                        <span>Remember me on this device</span>
                    </label>
                    <a href="${pageContext.request.contextPath}/forgot-password" class="forgot-link">Forgot password?</a>
                </div>

                <!-- Submit Button -->
                <button type="submit" class="btn-submit-main">
                    <span>Sign In to FreshFruit</span>
                    <i class="bi bi-arrow-right"></i>
                </button>
            </form>

            <div class="auth-bottom-switch">
                <span>Don't have an account?</span>
                <a href="${pageContext.request.contextPath}/register">Create Account</a>
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
