<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ Sơ Cá Nhân & Cài Đặt Tài Khoản - FreshFruit</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Custom Profile CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/profile.css?v=20261012_pill_nav">
</head>
<body>

<!-- Tailwind CSS CDN -->
<script src="https://cdn.tailwindcss.com"></script>

<!-- Header & Navigation Đồng Bộ Home -->
<jsp:include page="/views/common/header.jsp" />

<div class="container py-4">
    <!-- Breadcrumb & Hero Banner -->
    <%@include file="components/profile/breadcrumb-hero.jsp"%>

    <div class="row g-4">
        <!-- Cột trái: Sidebar Menu & Thẻ User -->
        <div class="col-lg-3 col-md-4">
            <%@include file="components/profile/sidebar.jsp"%>
        </div>

        <!-- Cột phải: Các Tabs chức năng -->
        <div class="col-lg-9 col-md-8">
            <div class="tab-content" id="profileTabContent">
                <%@include file="components/profile/tab-info.jsp"%>
                <%@include file="components/profile/tab-orders.jsp"%>
                <%@include file="components/profile/tab-vouchers.jsp"%>
                <%@include file="components/profile/tab-notifications.jsp"%>
                <%@include file="components/profile/tab-address.jsp"%>
                <%@include file="components/profile/tab-security.jsp"%>
            </div>
        </div>
    </div>
</div>

<!-- Popups / Modals -->
<%@include file="components/profile/modals.jsp"%>

<!-- Bootstrap JS Bundle & Profile Controller JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/profile.js"></script>
</body>
</html>
