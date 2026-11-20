<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ Sơ Cá Nhân & Cài Đặt Tài Khoản - Gốc Vườn</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="dns-prefetch" href="https://cdn.tailwindcss.com">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/profile.css?v=2">
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body>

<jsp:include page="/views/common/header.jsp" />

<div class="container py-4">
    <%@include file="components/profile/breadcrumb-hero.jsp"%>

    <div class="row g-4">
        <div class="col-lg-3 col-md-4">
            <%@include file="components/profile/sidebar.jsp"%>
        </div>

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

<%@include file="components/profile/modals.jsp"%>

<script>
    window.contextPath = '${pageContext.request.contextPath}';
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/vietnam-address-data.js?v=<%= System.currentTimeMillis() %>"></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const citySelect = document.getElementById('citySelect');
        const wardSelect = document.getElementById('wardSelect');
        if (!citySelect || !wardSelect) return;

        function resetWards(message) {
            wardSelect.innerHTML = '';
            const option = new Option(message, '');
            option.disabled = true;
            option.selected = true;
            wardSelect.add(option);
            wardSelect.disabled = true;
        }

        citySelect.addEventListener('change', function () {
            const selectedOption = citySelect.options[citySelect.selectedIndex];
            const provinceCode = selectedOption ? selectedOption.dataset.code : null;
            if (!provinceCode) {
                resetWards('Chọn Tỉnh / Thành phố trước');
                return;
            }

            const wardsMap = window.VIETNAM_WARDS_BY_PROVINCE_CODE || {};
            const wards = wardsMap[provinceCode] || [];

            if (wards.length === 0) {
                resetWards('Không có dữ liệu Phường / Xã');
                return;
            }

            wardSelect.innerHTML = '<option value="" selected disabled>Chọn Phường / Xã</option>';
            wards.forEach(function (wardName) {
                wardSelect.add(new Option(wardName, wardName));
            });
            wardSelect.disabled = false;
        });
    });
</script>
<script src="${pageContext.request.contextPath}/assets/js/profile.js?v=<%= System.currentTimeMillis() %>"></script>
</body>
</html>
