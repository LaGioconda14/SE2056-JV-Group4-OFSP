<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng Ký Shop - FreshFruit</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${ctx}/assets/css/home.css">
    <link rel="stylesheet" href="${ctx}/assets/css/register-shop.css">
    <script src="${ctx}/assets/js/home.js" defer></script>
    <script src="${ctx}/assets/js/register-shop.js" defer></script>
</head>
<body class="bg-gray-50 text-gray-800 font-sans antialiased selection:bg-emerald-500 selection:text-white">

    <jsp:include page="/views/common/site-header.jsp" />

    <main class="max-w-5xl mx-auto px-4 py-6 sm:py-8" id="rsTop">

        <nav class="rs-breadcrumb mb-6" aria-label="Breadcrumb">
            <a href="${ctx}/home"><i class="fa-solid fa-house text-xs"></i> Trang chủ</a>
            <i class="fa-solid fa-chevron-right sep"></i>
            <span class="current">Đăng ký shop</span>
        </nav>

        <div class="text-center mb-8">
            <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-100 text-xs font-bold mb-3">
                <i class="fa-solid fa-store"></i> Kênh Người Bán FreshFruit
            </div>
            <h1 class="text-2xl sm:text-3xl font-extrabold text-gray-900 tracking-tight">
                Đăng Ký Trở Thành <span class="text-emerald-600">Shop Owner</span>
            </h1>
            <p class="text-sm text-gray-500 mt-2 max-w-xl mx-auto">
                Hoàn thành 5 bước đơn giản để mở gian hàng bán hoa quả tươi sạch trên hệ thống.
            </p>
        </div>

        <div class="rs-stepper">
            <div class="rs-stepper-progress" id="stepperProgress"></div>
            <div class="rs-step active" id="step-indicator-1"><div class="rs-step-counter">1</div><div class="rs-step-name">Người bán</div></div>
            <div class="rs-step" id="step-indicator-2"><div class="rs-step-counter">2</div><div class="rs-step-name">Cửa hàng</div></div>
            <div class="rs-step" id="step-indicator-3"><div class="rs-step-counter">3</div><div class="rs-step-name">Địa chỉ</div></div>
            <div class="rs-step" id="step-indicator-4"><div class="rs-step-counter">4</div><div class="rs-step-name">Ngân hàng</div></div>
            <div class="rs-step" id="step-indicator-5"><div class="rs-step-counter">5</div><div class="rs-step-name">Xác nhận</div></div>
        </div>

        <c:if test="${not empty errorMessage}">
            <div class="rs-alert-error mb-4">
                <i class="fa-solid fa-circle-exclamation"></i> <span><c:out value="${errorMessage}"/></span>
            </div>
        </c:if>

        <c:if test="${not empty rejectedRequest}">
            <div class="rs-alert-error mb-4" style="align-items:flex-start">
                <i class="fa-solid fa-triangle-exclamation mt-0.5"></i>
                <span>
                    <b>Hồ sơ đăng ký trước đó đã bị từ chối.</b>
                    <c:if test="${not empty rejectedRequest.reason}">Lý do: <c:out value="${rejectedRequest.reason}"/>.</c:if>
                    Bạn có thể chỉnh sửa thông tin và gửi lại hồ sơ bên dưới.
                </span>
            </div>
        </c:if>

        <form action="${ctx}/register-shop" method="POST" enctype="multipart/form-data" id="multiStepForm" novalidate>
            <div class="rs-card p-6 md:p-10">
                <jsp:include page="/views/shop/components/register/register-step1.jsp" />
                <jsp:include page="/views/shop/components/register/register-step2.jsp" />
                <jsp:include page="/views/shop/components/register/register-step3.jsp" />
                <jsp:include page="/views/shop/components/register/register-step4.jsp" />
                <jsp:include page="/views/shop/components/register/register-step5.jsp" />
            </div>
        </form>
    </main>

    <jsp:include page="/views/common/site-footer.jsp" />
    <jsp:include page="/views/shop/terms-modals.jsp" />

</body>
</html>
