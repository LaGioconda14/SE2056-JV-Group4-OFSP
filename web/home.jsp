<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang Chủ - Online Fruit Shop</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background-color: #f8faf9;
            min-height: 100vh;
        }
        .navbar-fruit {
            background: linear-gradient(135deg, #2e7d32, #388e3c);
            box-shadow: 0 4px 15px rgba(46, 125, 50, 0.15);
        }
        .hero-banner {
            background: linear-gradient(135deg, #e8f5e9, #c8e6c9);
            border-radius: 1.5rem;
            padding: 40px;
            margin-top: 30px;
            border: 1px solid #a5d6a7;
        }
        .card-custom {
            border-radius: 1rem;
            border: 1px solid #e0e0e0;
            transition: all 0.3s ease;
        }
        .card-custom:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.08);
        }
        .btn-fruit {
            background: linear-gradient(135deg, #2e7d32, #43a047);
            border: none;
            color: #ffffff;
            font-weight: 600;
        }
        .btn-fruit:hover {
            background: linear-gradient(135deg, #1b5e20, #2e7d32);
            color: #ffffff;
        }
    </style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark navbar-fruit py-3">
    <div class="container">
        <a class="navbar-brand fw-bold d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/home.jsp">
            <span>🍎 Online Fruit Shop</span>
        </a>
        <div class="d-flex align-items-center gap-3">
            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <span class="text-white small d-none d-md-inline">
                        Xin chào, <strong>${sessionScope.user.fullName}</strong> (${sessionScope.user.role})
                    </span>
                    <a href="${pageContext.request.contextPath}/change-password" class="btn btn-sm btn-outline-light d-flex align-items-center gap-1">
                        <i class="bi bi-key"></i> Đổi mật khẩu
                    </a>
                    <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm btn-warning d-flex align-items-center gap-1">
                        <i class="bi bi-box-arrow-right"></i> Đăng xuất
                    </a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-light btn-sm fw-bold">
                        Đăng Nhập
                    </a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</nav>

<!-- Main Container -->
<div class="container py-4">
    <!-- Hero Banner -->
    <div class="hero-banner mb-5 text-center text-md-start">
        <div class="row align-items-center">
            <div class="col-md-8">
                <span class="badge bg-success mb-2 px-3 py-2 rounded-pill">Module FE-01.2: Authentication & Security</span>
                <h1 class="display-6 fw-bold text-success mb-2">Chào mừng đến với Online Fruit Shop! 🍇🥑🍓</h1>
                <p class="text-secondary mb-3">
                    Nền tảng mua sắm hoa quả tươi sạch trực tuyến. Hệ thống xác thực và bảo mật tài khoản người dùng đã sẵn sàng hoạt động.
                </p>
                <c:if test="${empty sessionScope.user}">
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-fruit px-4 py-2 rounded-pill">
                        Đăng nhập ngay
                    </a>
                </c:if>
            </div>
            <div class="col-md-4 text-center mt-3 mt-md-0">
                <div style="font-size: 5rem;">🍍🍊🍉</div>
            </div>
        </div>
    </div>

    <!-- Account Details Card (if logged in) -->
    <c:if test="${not empty sessionScope.user}">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card card-custom p-4 bg-white shadow-sm mb-4">
                    <h5 class="fw-bold text-success mb-3 border-bottom pb-2 d-flex align-items-center gap-2">
                        <i class="bi bi-person-check-fill"></i> Thông Tin Tài Khoản Đang Đăng Nhập
                    </h5>
                    <div class="row g-3">
                        <div class="col-sm-6">
                            <span class="text-muted small d-block">Họ và tên</span>
                            <span class="fw-semibold">${sessionScope.user.fullName}</span>
                        </div>
                        <div class="col-sm-6">
                            <span class="text-muted small d-block">Email</span>
                            <span class="fw-semibold">${sessionScope.user.email}</span>
                        </div>
                        <div class="col-sm-6">
                            <span class="text-muted small d-block">Số điện thoại</span>
                            <span class="fw-semibold">${sessionScope.user.phone}</span>
                        </div>
                        <div class="col-sm-6">
                            <span class="text-muted small d-block">Vai trò hệ thống</span>
                            <span class="badge bg-primary">${sessionScope.user.role}</span>
                        </div>
                        <div class="col-sm-6">
                            <span class="text-muted small d-block">Trạng thái</span>
                            <span class="badge bg-success">Đang hoạt động (Active)</span>
                        </div>
                    </div>
                    <div class="mt-4 pt-3 border-top d-flex gap-2">
                        <a href="${pageContext.request.contextPath}/change-password" class="btn btn-fruit btn-sm px-3">
                            <i class="bi bi-shield-lock"></i> Đổi Mật Khẩu
                        </a>
                        <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-danger btn-sm px-3">
                            <i class="bi bi-box-arrow-right"></i> Đăng Xuất
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </c:if>
</div>

<!-- Bootstrap 5 JS Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

