<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký tài khoản - Online Fruit Shop</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts: Plus Jakarta Sans -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background: linear-gradient(135deg, #e8f5e9 0%, #f1f8e9 50%, #e0f2f1 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 30px 20px;
        }
        .auth-card {
            background: #ffffff;
            border-radius: 1.25rem;
            box-shadow: 0 15px 35px rgba(34, 139, 34, 0.12);
            border: 1px solid rgba(40, 167, 69, 0.15);
            width: 100%;
            max-width: 480px;
            overflow: hidden;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .auth-header {
            background: linear-gradient(135deg, #2e7d32, #43a047);
            color: #ffffff;
            padding: 26px 25px 20px;
            text-align: center;
        }
        .auth-header .logo-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 58px;
            height: 58px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            font-size: 26px;
            margin-bottom: 10px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }
        .auth-body {
            padding: 26px 30px;
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
            background-color: #f8f9fa;
            border-right: none;
            color: #2e7d32;
        }
        .form-control {
            border-left: none;
        }
        .input-group:focus-within .input-group-text {
            border-color: #43a047;
        }
        .auth-link {
            color: #2e7d32;
            text-decoration: none;
            font-weight: 600;
        }
        .auth-link:hover {
            color: #1b5e20;
            text-decoration: underline;
        }
        .btn-toggle-pass {
            border-left: none;
            background-color: #f8f9fa;
            border-color: #dee2e6;
            color: #6c757d;
        }
        .btn-toggle-pass:hover {
            color: #2e7d32;
            background-color: #e9ecef;
        }
    </style>
</head>
<body>

<div class="auth-card">
    <!-- Header -->
    <div class="auth-header">
        <div class="logo-badge">
            🍎
        </div>
        <h4 class="fw-bold mb-1">Tạo Tài Khoản Mới</h4>
        <p class="small mb-0 opacity-75">Tham gia cùng Online Fruit Shop ngay hôm nay</p>
    </div>

    <!-- Body -->
    <div class="auth-body">
        <!-- Thông báo Lỗi -->
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center py-2 px-3 small" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2 fs-5 flex-shrink-0"></i>
                <div>${errorMessage}</div>
                <button type="button" class="btn-close ms-auto py-2" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/register" method="POST" novalidate>
            <!-- Họ và tên -->
            <div class="mb-3">
                <label for="fullName" class="form-label small fw-semibold text-secondary">Họ và tên <span class="text-danger">*</span></label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-person"></i></span>
                    <input type="text" 
                           class="form-control" 
                           id="fullName" 
                           name="fullName" 
                           value="${not empty fullName ? fullName : ''}" 
                           placeholder="Nguyễn Văn A" 
                           required 
                           autofocus>
                </div>
            </div>

            <!-- Email -->
            <div class="mb-3">
                <label for="email" class="form-label small fw-semibold text-secondary">Địa chỉ Email <span class="text-danger">*</span></label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                    <input type="email" 
                           class="form-control" 
                           id="email" 
                           name="email" 
                           value="${not empty email ? email : ''}" 
                           placeholder="example@fruitshop.com" 
                           required>
                </div>
            </div>

            <!-- Số điện thoại -->
            <div class="mb-3">
                <label for="phone" class="form-label small fw-semibold text-secondary">Số điện thoại</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-telephone"></i></span>
                    <input type="tel" 
                           class="form-control" 
                           id="phone" 
                           name="phone" 
                           value="${not empty phone ? phone : ''}" 
                           placeholder="0912345678">
                </div>
            </div>

            <!-- Mật khẩu -->
            <div class="mb-3">
                <label for="password" class="form-label small fw-semibold text-secondary">Mật khẩu <span class="text-danger">*</span></label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-lock"></i></span>
                    <input type="password" 
                           class="form-control" 
                           id="password" 
                           name="password" 
                           placeholder="Tối thiểu 6 ký tự" 
                           required>
                    <button class="btn btn-outline-secondary btn-toggle-pass" 
                            type="button" 
                            onclick="togglePasswordVisibility('password', this)"
                            tabindex="-1">
                        <i class="bi bi-eye"></i>
                    </button>
                </div>
            </div>

            <!-- Xác nhận Mật khẩu -->
            <div class="mb-4">
                <label for="confirmPassword" class="form-label small fw-semibold text-secondary">Xác nhận mật khẩu <span class="text-danger">*</span></label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-shield-lock"></i></span>
                    <input type="password" 
                           class="form-control" 
                           id="confirmPassword" 
                           name="confirmPassword" 
                           placeholder="Nhập lại mật khẩu" 
                           required>
                    <button class="btn btn-outline-secondary btn-toggle-pass" 
                            type="button" 
                            onclick="togglePasswordVisibility('confirmPassword', this)"
                            tabindex="-1">
                        <i class="bi bi-eye"></i>
                    </button>
                </div>
            </div>

            <!-- Nút Đăng ký -->
            <div class="d-grid mb-3">
                <button type="submit" class="btn btn-fruit d-flex align-items-center justify-content-center gap-2">
                    <i class="bi bi-person-plus-fill"></i>
                    <span>Đăng Ký Tài Khoản</span>
                </button>
            </div>

            <!-- Link chuyển sang Đăng nhập -->
            <div class="text-center small text-secondary">
                Đã có tài khoản? 
                <a href="${pageContext.request.contextPath}/login" class="auth-link">Đăng nhập ngay</a>
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

