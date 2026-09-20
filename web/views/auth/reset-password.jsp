<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt lại mật khẩu - Online Fruit Shop</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts -->
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
            max-width: 480px;
            overflow: hidden;
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
        .auth-link {
            color: #2e7d32;
            text-decoration: none;
            font-weight: 500;
        }
        .auth-link:hover {
            color: #1b5e20;
            text-decoration: underline;
        }
        .otp-input {
            letter-spacing: 6px;
            font-size: 1.2rem;
            font-weight: 700;
            color: #2e7d32;
            text-align: center;
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
        <div class="logo-badge">🔑</div>
        <h4 class="fw-bold mb-1">Xác Nhận Đặt Lại Mật Khẩu</h4>
        <p class="text-white-50 small mb-0">Nhập mã OTP và mật khẩu mới của bạn</p>
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

        <form action="${pageContext.request.contextPath}/reset-password" method="POST">
            <!-- Email -->
            <div class="mb-3">
                <label for="email" class="form-label small fw-semibold text-secondary">Email nhận mã</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                    <input type="email" 
                           class="form-control" 
                           id="email" 
                           name="email" 
                           value="${email}" 
                           placeholder="name@example.com" 
                           required>
                </div>
            </div>

            <!-- Mã OTP -->
            <div class="mb-3">
                <label for="otp" class="form-label small fw-semibold text-secondary">Mã OTP (6 chữ số)</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-shield-check"></i></span>
                    <input type="text" 
                           class="form-control otp-input" 
                           id="otp" 
                           name="otp" 
                           value="${otp}" 
                           maxlength="6" 
                           placeholder="123456" 
                           required 
                           autofocus>
                </div>
                <div class="d-flex justify-content-between align-items-center mt-1">
                    <span class="text-muted small">Thời hạn OTP: 5 phút</span>
                    <a href="${pageContext.request.contextPath}/forgot-password" class="auth-link small">Gửi lại mã OTP?</a>
                </div>
            </div>

            <!-- Mật khẩu mới -->
            <div class="mb-3">
                <label for="newPassword" class="form-label small fw-semibold text-secondary">Mật khẩu mới</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-lock"></i></span>
                    <input type="password" 
                           class="form-control" 
                           id="newPassword" 
                           name="newPassword" 
                           placeholder="Tối thiểu 6 ký tự" 
                           required>
                    <span class="input-group-text password-toggle" onclick="togglePasswordVisibility('newPassword', this)">
                        <i class="bi bi-eye"></i>
                    </span>
                </div>
            </div>

            <!-- Xác nhận mật khẩu mới -->
            <div class="mb-4">
                <label for="confirmPassword" class="form-label small fw-semibold text-secondary">Xác nhận mật khẩu mới</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-lock-fill"></i></span>
                    <input type="password" 
                           class="form-control" 
                           id="confirmPassword" 
                           name="confirmPassword" 
                           placeholder="Nhập lại mật khẩu mới" 
                           required>
                    <span class="input-group-text password-toggle" onclick="togglePasswordVisibility('confirmPassword', this)">
                        <i class="bi bi-eye"></i>
                    </span>
                </div>
            </div>

            <!-- Nút Xác nhận -->
            <div class="d-grid mb-3">
                <button type="submit" class="btn btn-fruit d-flex align-items-center justify-content-center gap-2">
                    <i class="bi bi-check2-circle"></i>
                    <span>Cập Nhật Mật Khẩu</span>
                </button>
            </div>

            <div class="text-center pt-2">
                <a href="${pageContext.request.contextPath}/login" class="auth-link small d-inline-flex align-items-center gap-1">
                    <i class="bi bi-arrow-left"></i>
                    <span>Quay lại Đăng nhập</span>
                </a>
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

