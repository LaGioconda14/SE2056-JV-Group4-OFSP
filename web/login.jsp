<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - Online Fruit Shop</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts: Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background: linear-gradient(135deg, #e8f5e9 0%, #f1f8e9 50%, #e0f2f1 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .auth-card {
            background: #ffffff;
            border-radius: 1.25rem;
            box-shadow: 0 15px 35px rgba(34, 139, 34, 0.12);
            border: 1px solid rgba(40, 167, 69, 0.15);
            width: 100%;
            max-width: 440px;
            overflow: hidden;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .auth-header {
            background: linear-gradient(135deg, #2e7d32, #43a047);
            color: #ffffff;
            padding: 30px 25px 20px;
            text-align: center;
        }
        .auth-header .logo-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 60px;
            height: 60px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            font-size: 28px;
            margin-bottom: 12px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }
        .btn-fruit {
            background: linear-gradient(135deg, #2e7d32, #43a047);
            border: none;
            color: #ffffff;
            font-weight: 600;
            padding: 12px;
            border-radius: 0.75rem;
            transition: all 0.3s ease;
        }
        .btn-fruit:hover {
            background: linear-gradient(135deg, #1b5e20, #2e7d32);
            color: #ffffff;
            transform: translateY(-1px);
            box-shadow: 0 6px 15px rgba(46, 125, 50, 0.3);
        }
        .form-control:focus {
            border-color: #43a047;
            box-shadow: 0 0 0 0.25rem rgba(67, 160, 71, 0.2);
        }
        .input-group-text {
            background-color: #f8faf9;
            border-right: none;
            color: #2e7d32;
        }
        .form-control {
            border-left: none;
        }
        .form-control:focus + .input-group-text,
        .input-group-text:focus-within {
            border-color: #43a047;
        }
        .form-check-input:checked {
            background-color: #2e7d32;
            border-color: #2e7d32;
        }
        .auth-link {
            color: #2e7d32;
            text-decoration: none;
            font-weight: 500;
        }
        .auth-link:hover {
            color: #1b5e20;
            text-decoration: underline;
        }
        .password-toggle {
            cursor: pointer;
            border-left: none;
            border-right: 1px solid #dee2e6;
            background-color: #fff;
            color: #6c757d;
        }
        .password-toggle:hover {
            color: #2e7d32;
        }
    </style>
</head>
<body>

<div class="auth-card">
    <div class="auth-header">
        <div class="logo-badge">🍎</div>
        <h4 class="fw-bold mb-1">Online Fruit Shop</h4>
        <p class="text-white-50 small mb-0">Đăng nhập tài khoản của bạn</p>
    </div>

    <div class="p-4 pt-3">
        <!-- Thông báo Lỗi -->
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center py-2 px-3 small" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2 fs-5 flex-shrink-0"></i>
                <div>${errorMessage}</div>
                <button type="button" class="btn-close ms-auto py-2" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <!-- Thông báo Thành công -->
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success alert-dismissible fade show d-flex align-items-center py-2 px-3 small" role="alert">
                <i class="bi bi-check-circle-fill me-2 fs-5 flex-shrink-0"></i>
                <div>${successMessage}</div>
                <button type="button" class="btn-close ms-auto py-2" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/login" method="POST" novalidate>
            <!-- Email -->
            <div class="mb-3">
                <label for="email" class="form-label small fw-semibold text-secondary">Địa chỉ Email</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                    <input type="email" 
                           class="form-control" 
                           id="email" 
                           name="email" 
                           value="${not empty rememberEmail ? rememberEmail : (not empty email ? email : '')}" 
                           placeholder="name@example.com" 
                           required 
                           autofocus>
                </div>
            </div>

            <!-- Mật khẩu -->
            <div class="mb-3">
                <div class="d-flex justify-content-between align-items-center mb-1">
                    <label for="password" class="form-label small fw-semibold text-secondary mb-0">Mật khẩu</label>
                    <a href="${pageContext.request.contextPath}/forgot-password" class="auth-link small">Quên mật khẩu?</a>
                </div>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-shield-lock"></i></span>
                    <input type="password" 
                           class="form-control" 
                           id="password" 
                           name="password" 
                           value="${not empty rememberPassword ? rememberPassword : ''}" 
                           placeholder="••••••••" 
                           required>
                    <span class="input-group-text password-toggle" onclick="togglePasswordVisibility('password', this)">
                        <i class="bi bi-eye"></i>
                    </span>
                </div>
            </div>

            <!-- Ghi nhớ đăng nhập -->
            <div class="form-check mb-4">
                <input class="form-check-input" 
                       type="checkbox" 
                       name="remember" 
                       id="remember" 
                       value="1" 
                       ${not empty rememberChecked ? 'checked' : ''}>
                <label class="form-check-label small text-secondary" for="remember">
                    Ghi nhớ đăng nhập (Remember Me)
                </label>
            </div>

            <!-- Nút Đăng nhập -->
            <div class="d-grid mb-3">
                <button type="submit" class="btn btn-fruit d-flex align-items-center justify-content-center gap-2">
                    <i class="bi bi-box-arrow-in-right"></i>
                    <span>Đăng Nhập</span>
                </button>
            </div>

            <div class="text-center text-secondary small">
                Tài khoản mẫu thử nghiệm:
                <br>
                <span class="badge bg-light text-dark border mt-1">customer@fruitshop.com / 123456</span>
            </div>
        </form>
    </div>
</div>

<!-- Bootstrap 5 JS Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
    function togglePasswordVisibility(fieldId, toggleEl) {
        const input = document.getElementById(fieldId);
        const icon = toggleEl.querySelector('i');
        if (input.type === 'password') {
            input.type = 'text';
            icon.classList.remove('bi-eye');
            icon.classList.add('bi-eye-slash');
        } else {
            input.type = 'password';
            icon.classList.remove('bi-eye-slash');
            icon.classList.add('bi-eye');
        }
    }
</script>
</body>
</html>

