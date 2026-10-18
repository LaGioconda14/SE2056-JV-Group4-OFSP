<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<nav aria-label="breadcrumb" class="profile-breadcrumb">
    <ol class="breadcrumb mb-0">
        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home.jsp">Trang chủ</a></li>
        <li class="breadcrumb-item text-muted">Tài khoản của tôi</li>
        <li class="breadcrumb-item active text-success fw-semibold" aria-current="page">Hồ Sơ Cá Nhân & Cài Đặt</li>
    </ol>
</nav>

<div class="profile-hero">
    <div>
        <h1 class="profile-title">Hồ Sơ Cá Nhân & Cài Đặt Tài Khoản</h1>
    </div>
    <button type="button" class="btn-security-quick" onclick="switchTab('nav-security-tab')">
        <i class="bi bi-shield-check me-1"></i> Lịch sử đăng nhập & Bảo mật
    </button>
</div>

<c:if test="${not empty successMessage}">
    <div class="alert alert-success alert-dismissible fade show profile-alert" role="alert">
        <i class="bi bi-check-circle-fill me-2 fs-5"></i>
        <div>${successMessage}</div>
        <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<c:if test="${not empty warningMessage or (not empty user and empty user.phone)}">
    <div class="alert alert-warning alert-dismissible fade show profile-alert border-warning shadow-sm" role="alert">
        <i class="bi bi-exclamation-triangle-fill text-warning me-2 fs-5"></i>
        <div>
            <strong>Lưu ý quan trọng:</strong> 
            <c:choose>
                <c:when test="${not empty warningMessage}">
                    ${warningMessage}
                </c:when>
                <c:otherwise>
                    Tài khoản của bạn chưa cập nhật Số điện thoại liên hệ. Vui lòng bổ sung số điện thoại ở form bên dưới để nhân viên giao hàng có thể liên lạc khi giao đơn!
                </c:otherwise>
            </c:choose>
        </div>
        <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<c:if test="${not empty errorMessage}">
    <div class="alert alert-danger alert-dismissible fade show profile-alert" role="alert">
        <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
        <div>${errorMessage}</div>
        <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>
