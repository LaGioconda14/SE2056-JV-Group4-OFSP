<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ Sơ Cá Nhân & Cài Đặt Tài Khoản - FreshFruit</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/profile.css?v=4">
</head>
<body>

<div class="top-announcement">
    <div class="container d-flex justify-content-between align-items-center">
        <div>
            <i class="bi bi-truck me-1"></i> Giao hàng miễn phí trong ngày cho đơn từ 200.000₫ | <strong>Cam kết 100% Nông Trại Sạch</strong>
        </div>
        <div class="announcement-hotline">
            <span><i class="bi bi-telephone-fill me-1"></i> Hotline: 1900 6868</span>
            <span>VND (₫)</span>
            <span>Tiếng Việt</span>
        </div>
    </div>
</div>

<nav class="navbar-main">
    <div class="container navbar-main-inner">
        <a href="${pageContext.request.contextPath}/home.jsp" class="brand-link">
            <span class="fs-2">🍎</span>
            <div>
                <div class="brand-title">FreshFruit</div>
                <div class="brand-sub">DIRECT FROM ORCHARD</div>
            </div>
        </a>

        <div class="nav-search-wrap">
            <div class="search-container">
                <select class="nav-search-select">
                    <option>Tất cả danh mục</option>
                    <option>Trái cây nội địa</option>
                    <option>Trái cây nhập khẩu</option>
                    <option>Giỏ quà organic</option>
                </select>
                <div class="vr my-1"></div>
                <input type="text" placeholder="Tìm kiếm dâu tây, bơ sáp, nho mẫu đơn...">
                <button class="btn btn-fresh-green btn-sm px-3 py-1">
                    <i class="bi bi-search"></i>
                </button>
            </div>
        </div>

        <div class="nav-right-actions">
            <a href="${pageContext.request.contextPath}/cart" class="nav-cart-btn">
                <div class="nav-cart-icon-wrap">
                    <i class="bi bi-cart3 nav-cart-icon"></i>
                    <c:if test="${not empty sessionScope.cartCount and sessionScope.cartCount > 0}">
                        <span class="nav-cart-badge">${sessionScope.cartCount}</span>
                    </c:if>
                </div>
                <span class="nav-cart-text">Giỏ hàng</span>
            </a>

            <div class="dropdown">
                <a href="#" class="nav-user-btn dropdown-toggle" data-bs-toggle="dropdown">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user.avatarUrl}">
                            <c:set var="navAvatar" value="${sessionScope.user.avatarUrl.startsWith('http://') or sessionScope.user.avatarUrl.startsWith('https://') ? sessionScope.user.avatarUrl : pageContext.request.contextPath.concat('/').concat(sessionScope.user.avatarUrl)}" />
                            <img src="${navAvatar}" class="avatar-nav" alt="Avatar" onerror="this.onerror=null; this.src='https://ui-avatars.com/api/?name=${sessionScope.user.fullName}&background=046A38&color=fff';">
                        </c:when>
                        <c:otherwise>
                            <div class="avatar-placeholder avatar-nav">
                                ${not empty sessionScope.user.fullName ? sessionScope.user.fullName.substring(0, 1).toUpperCase() : 'U'}
                            </div>
                        </c:otherwise>
                    </c:choose>
                    <span class="nav-user-name">${sessionScope.user.fullName}</span>
                </a>
                <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0 rounded-3 mt-2">
                    <li><h6 class="dropdown-header small text-muted">Tài khoản hội viên</h6></li>
                    <li><a class="dropdown-item active small" href="${pageContext.request.contextPath}/profile"><i class="bi bi-person me-2"></i>Hồ sơ cá nhân</a></li>
                    <li><a class="dropdown-item small" href="${pageContext.request.contextPath}/change-password"><i class="bi bi-key me-2"></i>Đổi mật khẩu</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item small text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-2"></i>Đăng xuất</a></li>
                </ul>
            </div>
        </div>
    </div>
</nav>

<div class="sub-nav">
    <div class="container sub-nav-inner">
        <div class="sub-nav-links">
            <a href="${pageContext.request.contextPath}/home.jsp" class="nav-link">Trang Chủ</a>
            <a href="#" class="nav-link">Cửa Hàng</a>
            <a href="#" class="nav-link">Danh Mục Trái Cây</a>
            <a href="#" class="nav-link">Hộp Quà & Combo</a>
            <a href="#" class="nav-link">Về Nông Trại</a>
            <a href="#" class="nav-link">Liên Hệ</a>
        </div>
        <div class="flash-sale-badge">
            <i class="bi bi-lightning-charge-fill"></i> Flash Sale Hôm Nay: Giảm 30% Cam & Bưởi Da Xanh
        </div>
    </div>
</div>

<div class="container py-4">
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

    <div class="row g-4">
        <div class="col-lg-3 col-md-4">
            <div class="sidebar-user-card">
                <div class="user-avatar-wrap">
                    <c:choose>
                        <c:when test="${not empty user.avatarUrl}">
                            <c:set var="userSidebarAvatar" value="${user.avatarUrl.startsWith('http://') or user.avatarUrl.startsWith('https://') ? user.avatarUrl : pageContext.request.contextPath.concat('/').concat(user.avatarUrl)}" />
                            <img src="${userSidebarAvatar}" class="avatar-sidebar" alt="Avatar" onerror="this.onerror=null; this.src='https://ui-avatars.com/api/?name=${user.fullName}&background=046A38&color=fff';">
                        </c:when>
                        <c:otherwise>
                            <div class="avatar-placeholder">
                                ${not empty user.fullName ? user.fullName.substring(0, 1).toUpperCase() : 'U'}
                            </div>
                        </c:otherwise>
                    </c:choose>
                    <span class="online-dot" title="Tài khoản đang hoạt động"></span>
                </div>
                <h5 class="fw-bold text-dark mb-1">${user.fullName}</h5>
                <p class="text-muted small mb-0">${user.email}</p>
            </div>

            <div class="sidebar-menu-card">
                <div class="nav flex-column" id="profileSidebarTab" role="tablist">
                    <button class="sidebar-nav-item active" id="nav-profile-tab" data-bs-toggle="pill" data-bs-target="#nav-profile" type="button" role="tab">
                        <span><i class="bi bi-person-fill"></i> Thông tin cá nhân</span>
                        <i class="bi bi-chevron-right small"></i>
                    </button>

                    <button class="sidebar-nav-item" id="nav-orders-tab" data-bs-toggle="pill" data-bs-target="#nav-orders" type="button" role="tab">
                        <span><i class="bi bi-bag-check-fill"></i> Đơn mua</span>
                        <c:choose>
                            <c:when test="${not empty ordersCount and ordersCount > 0}">
                                <span class="badge bg-success rounded-pill badge-sidebar-sm">${ordersCount}</span>
                            </c:when>
                            <c:otherwise>
                                <i class="bi bi-chevron-right small"></i>
                            </c:otherwise>
                        </c:choose>
                    </button>

                    <button class="sidebar-nav-item" id="nav-vouchers-tab" data-bs-toggle="pill" data-bs-target="#nav-vouchers" type="button" role="tab">
                        <span><i class="bi bi-ticket-perforated-fill"></i> Kho voucher</span>
                        <c:choose>
                            <c:when test="${not empty vouchersCount and vouchersCount > 0}">
                                <span class="badge bg-warning text-dark rounded-pill fw-bold badge-sidebar-sm">${vouchersCount} mã</span>
                            </c:when>
                            <c:otherwise>
                                <i class="bi bi-chevron-right small"></i>
                            </c:otherwise>
                        </c:choose>
                    </button>

                    <button class="sidebar-nav-item" id="nav-notifications-tab" data-bs-toggle="pill" data-bs-target="#nav-notifications" type="button" role="tab">
                        <span><i class="bi bi-bell-fill"></i> Thông báo</span>
                        <c:choose>
                            <c:when test="${not empty unreadNotificationsCount and unreadNotificationsCount > 0}">
                                <span class="badge bg-danger rounded-pill badge-sidebar-sm">${unreadNotificationsCount} mới</span>
                            </c:when>
                            <c:otherwise>
                                <i class="bi bi-chevron-right small"></i>
                            </c:otherwise>
                        </c:choose>
                    </button>

                    <button class="sidebar-nav-item" id="nav-address-tab" data-bs-toggle="pill" data-bs-target="#nav-address" type="button" role="tab">
                        <span><i class="bi bi-geo-alt-fill"></i> Địa chỉ</span>
                        <i class="bi bi-chevron-right small"></i>
                    </button>

                    <button class="sidebar-nav-item" id="nav-security-tab" data-bs-toggle="pill" data-bs-target="#nav-security" type="button" role="tab">
                        <span><i class="bi bi-shield-lock-fill"></i> Bảo mật & Đăng nhập</span>
                        <span class="badge bg-success rounded-pill badge-xs">Chuẩn</span>
                    </button>

                    <hr class="my-2 border-secondary-subtle">

                    <a href="${pageContext.request.contextPath}/logout" class="sidebar-nav-item logout-link">
                        <span><i class="bi bi-box-arrow-right text-danger"></i> Đăng xuất tài khoản</span>
                    </a>
                </div>
            </div>

            <div class="farm-badge-box">
                <div class="farm-badge-header">
                    <i class="bi bi-patch-check-fill fs-4 text-success"></i>
                    <strong class="text-dark small">Bảo chứng 100% Nông Trại</strong>
                </div>
                <p class="farm-guarantee-text">
                    Mỗi sản phẩm trái cây giao đến đều có tem QR truy xuất nguồn gốc từ các nông trại sạch VietGAP/GlobalGAP liên kết.
                </p>
            </div>
        </div>

        <div class="col-lg-9 col-md-8">
            <div class="tab-content" id="profileTabContent">

                <div class="tab-pane fade show active" id="nav-profile" role="tabpanel">
                    <form id="avatarUploadForm" action="${pageContext.request.contextPath}/profile" method="POST" enctype="multipart/form-data" class="d-none-form">
                        <input type="hidden" name="action" value="uploadAvatar">
                        <input type="file" id="avatarFileInput" name="avatarFile" accept="image/png, image/jpeg, image/jpg, image/webp" onchange="submitAvatarForm()">
                    </form>

                    <form id="avatarDeleteForm" action="${pageContext.request.contextPath}/profile" method="POST" class="d-none-form">
                        <input type="hidden" name="action" value="deleteAvatar">
                    </form>

                    <form action="${pageContext.request.contextPath}/profile" method="POST" id="profileMainForm">
                        <input type="hidden" name="action" value="updateProfile">
                        
                        <div class="profile-section-card">
                            <span class="section-tag">THÔNG TIN ĐỊNH DANH</span>
                            <h3 class="section-heading mb-4">Thông tin Cá Nhân Cơ Bản</h3>

                            <div class="avatar-upload-box">
                                <c:choose>
                                    <c:when test="${not empty user.avatarUrl}">
                                        <c:set var="formUserAvatar" value="${user.avatarUrl.startsWith('http://') or user.avatarUrl.startsWith('https://') ? user.avatarUrl : pageContext.request.contextPath.concat('/').concat(user.avatarUrl)}" />
                                        <img src="${formUserAvatar}" class="avatar-form" alt="Avatar" onerror="this.onerror=null; this.src='https://ui-avatars.com/api/?name=${user.fullName}&background=046A38&color=fff';">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="avatar-placeholder avatar-form">
                                            ${not empty user.fullName ? user.fullName.substring(0, 1).toUpperCase() : 'U'}
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                                <div>
                                    <div class="avatar-actions">
                                        <button type="button" class="btn btn-fresh-green btn-sm" onclick="document.getElementById('avatarFileInput').click();">
                                            <i class="bi bi-upload me-1"></i> Tải ảnh mới
                                        </button>
                                        <c:if test="${not empty user.avatarUrl}">
                                            <button type="button" class="btn-pill-danger" onclick="confirmDeleteAvatar()">Xóa ảnh</button>
                                        </c:if>
                                    </div>
                                    <div class="avatar-hint-text">
                                        Ảnh đại diện hiển thị trên đơn hàng và hồ sơ khách hàng. Định dạng JPG, PNG, WEBP tối đa 2MB.
                                    </div>
                                </div>
                            </div>

                            <div class="row g-3">
                                <div class="col-md-6 field-box">
                                    <label class="field-label" for="fullName">Họ và tên *</label>
                                    <div class="input-icon-group">
                                        <i class="bi bi-person lead-icon"></i>
                                        <input type="text" id="fullName" name="fullName" value="${user.fullName}" required placeholder="Nhập họ và tên của bạn">
                                    </div>
                                </div>

                                <div class="col-md-6 field-box">
                                    <label class="field-label" for="displayName">Tên hiển thị & Xưng hô giao dịch</label>
                                    <div class="input-icon-group">
                                        <i class="bi bi-card-heading lead-icon"></i>
                                        <input type="text" id="displayName" name="displayName" value="${user.fullName}" placeholder="Tên gọi khi shipper liên hệ">
                                    </div>
                                </div>

                                <div class="col-md-6 field-box">
                                    <label class="field-label" for="email">Địa chỉ Email đăng nhập *</label>
                                    <div class="input-icon-group">
                                        <i class="bi bi-envelope lead-icon"></i>
                                        <input type="text" id="email" value="${user.email}" readonly class="input-readonly-fixed" title="Email tài khoản được cố định để bảo vệ an toàn">
                                    </div>
                                </div>

                                <div class="col-md-6 field-box">
                                    <label class="field-label" for="phone">Số điện thoại giao hàng *</label>
                                    <div class="input-icon-group">
                                        <i class="bi bi-telephone lead-icon"></i>
                                        <input type="tel" id="phone" name="phone" value="${not empty user.phone ? user.phone : ''}" placeholder="Ví dụ: 0912345678" maxlength="11" autocomplete="tel">
                                    </div>
                                </div>

                                <div class="col-md-6 field-box">
                                    <label class="field-label" for="birthDate">Ngày sinh (để nhận quà quả tươi sinh nhật)</label>
                                    <div class="input-icon-group">
                                        <i class="bi bi-calendar3 lead-icon"></i>
                                        <input type="date" id="birthDate" name="birthDate" value="${user.birthDate}">
                                    </div>
                                </div>

                                <div class="col-md-6 field-box">
                                    <label class="field-label">Giới tính</label>
                                    <div class="btn-group w-100" role="group">
                                        <input type="radio" class="btn-check" name="gender" id="genderFemale" value="FEMALE" autocomplete="off" ${user.gender == 'FEMALE' ? 'checked' : ''}>
                                        <label class="gender-choice" for="genderFemale"><i class="bi bi-gender-female me-1"></i>Nữ</label>

                                        <input type="radio" class="btn-check" name="gender" id="genderMale" value="MALE" autocomplete="off" ${user.gender == 'MALE' ? 'checked' : ''}>
                                        <label class="gender-choice" for="genderMale"><i class="bi bi-gender-male me-1"></i>Nam</label>

                                        <input type="radio" class="btn-check" name="gender" id="genderOther" value="OTHER" autocomplete="off" ${user.gender == 'OTHER' ? 'checked' : ''}>
                                        <label class="gender-choice" for="genderOther"><i class="bi bi-gender-ambiguous me-1"></i>Khác</label>
                                    </div>
                                </div>

                                <div class="col-md-6 field-box">
                                    <label class="field-label" for="language">Ngôn ngữ giao diện</label>
                                    <div class="input-icon-group">
                                        <i class="bi bi-translate lead-icon"></i>
                                        <select id="language" name="language">
                                            <option selected>Tiếng Việt (Mặc định)</option>
                                            <option>English (US)</option>
                                        </select>
                                    </div>
                                </div>

                                <div class="col-12 field-box">
                                    <div class="default-address-header">
                                        <label class="field-label mb-0">Địa chỉ nhận hàng mặc định</label>
                                        <button type="button" class="btn btn-link btn-sm text-success text-decoration-none p-0 fw-semibold" onclick="switchTab('nav-address-tab')">
                                            <i class="bi bi-geo-alt me-1"></i> Quản lý địa chỉ (${not empty addresses ? addresses.size() : 0})
                                        </button>
                                    </div>
                                    <div class="default-address-box">
                                        <c:choose>
                                            <c:when test="${not empty addresses}">
                                                <c:set var="defaultFound" value="false" />
                                                <c:forEach items="${addresses}" var="a">
                                                    <c:if test="${(a.isDefault or a['default']) and not defaultFound}">
                                                        <div class="d-flex align-items-start gap-2">
                                                            <i class="bi bi-geo-alt-fill text-success fs-5 mt-1"></i>
                                                            <div>
                                                                <strong class="text-dark">${a.recipientName}</strong> &bull; <span class="text-muted">${a.recipientPhone}</span>
                                                                <div class="text-secondary small mt-1">${a.fullAddress}</div>
                                                            </div>
                                                        </div>
                                                        <c:set var="defaultFound" value="true" />
                                                    </c:if>
                                                </c:forEach>
                                                <c:if test="${not defaultFound}">
                                                    <div class="text-muted small">
                                                        ${addresses[0].recipientName} &bull; ${addresses[0].recipientPhone} - ${addresses[0].fullAddress}
                                                    </div>
                                                </c:if>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <span class="text-muted small">Chưa có địa chỉ nhận hàng nào được lưu.</span>
                                                    <button type="button" class="btn-pill-success" data-bs-toggle="modal" data-bs-target="#addAddressModal">
                                                        <i class="bi bi-plus-lg me-1"></i> Thêm địa chỉ
                                                    </button>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="sticky-action-bar">
                            <div class="text-muted small">
                                <i class="bi bi-info-circle text-success me-1"></i> Tất cả các tùy chỉnh sẽ có hiệu lực ngay tức thì trên hệ thống FreshFruit.
                            </div>
                            <div class="d-flex gap-2">
                                <button type="reset" class="btn-pill-sec">Hủy bỏ</button>
                                <button type="submit" class="btn btn-fresh-green btn-sm px-4">
                                    <i class="bi bi-check2 me-1"></i> Lưu thay đổi
                                </button>
                            </div>
                        </div>
                    </form>
                </div>

                <div class="tab-pane fade" id="nav-orders" role="tabpanel">
                    <div class="profile-section-card">
                        <div class="profile-section-header">
                            <div>
                                <span class="section-tag">LỊCH SỬ ĐẶT HÀNG</span>
                                <h3 class="section-heading">Đơn Hàng Của Bạn</h3>
                            </div>
                            <span class="badge-soft-success">
                                ${not empty orders ? orders.size() : 0} đơn hàng
                            </span>
                        </div>

                        <c:choose>
                            <c:when test="${not empty orders}">
                                <div class="d-flex flex-wrap gap-2 mb-4 border-bottom pb-3">
                                    <button class="btn btn-fresh-green btn-sm px-3">Tất cả (${orders.size()})</button>
                                </div>
                                <c:forEach items="${orders}" var="order">
                                    <div class="order-card">
                                        <div class="order-card-header">
                                            <div>
                                                <strong class="text-dark">Mã đơn: #${order.id}</strong>
                                                <span class="text-muted small ms-2"><i class="bi bi-clock"></i> ${order.createdAt}</span>
                                            </div>
                                            <span class="badge-soft-primary">
                                                ${order.status}
                                            </span>
                                        </div>
                                        <div class="row align-items-center">
                                            <div class="col-md-8">
                                                <div class="fw-semibold text-dark">${order.note}</div>
                                            </div>
                                            <div class="col-md-4 text-md-end mt-2 mt-md-0">
                                                <div class="text-muted small">Tổng thanh toán:</div>
                                                <div class="fw-bold fs-5 text-success">${order.totalAmount}₫</div>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <div class="empty-state">
                                    <div class="empty-state-icon">
                                        <i class="bi bi-bag-x"></i>
                                    </div>
                                    <h5 class="fw-bold text-dark">Chưa có đơn hàng nào</h5>
                                    <p class="text-muted small mb-4">Bạn chưa thực hiện đơn đặt hàng trái cây nào trên hệ thống.</p>
                                    <a href="${pageContext.request.contextPath}/home.jsp" class="btn btn-fresh-green px-4 py-2">
                                        <i class="bi bi-basket2 me-1"></i> Khám phá nông sản ngay
                                    </a>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="tab-pane fade" id="nav-vouchers" role="tabpanel">
                    <div class="profile-section-card">
                        <div class="profile-section-header">
                            <div>
                                <span class="section-tag">ƯU ĐÃI DÀNH RIÊNG CHO BẠN</span>
                                <h3 class="section-heading">Kho Voucher & Mã Khuyến Mãi</h3>
                            </div>
                            <span class="badge-soft-warning">
                                ${not empty vouchers ? vouchers.size() : 0} voucher sẵn sàng sử dụng
                            </span>
                        </div>

                        <c:choose>
                            <c:when test="${not empty vouchers}">
                                <div class="row g-3">
                                    <c:forEach items="${vouchers}" var="voucher">
                                        <div class="col-md-6">
                                            <div class="voucher-ticket">
                                                <span class="badge bg-success mb-2">${voucher.discountPercent}% OFF</span>
                                                <h5 class="fw-bold text-dark mb-1">Mã: ${voucher.code}</h5>
                                                <p class="text-muted small mb-0">${voucher.description}</p>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="empty-state">
                                    <div class="empty-state-icon">
                                        <i class="bi bi-ticket-perforated"></i>
                                    </div>
                                    <h5 class="fw-bold text-dark">Chưa có mã giảm giá nào</h5>
                                    <p class="text-muted small mb-4">Hiện tại bạn chưa có mã voucher nào. Hãy theo dõi các sự kiện khuyến mãi mới nhất trên sàn nhé!</p>
                                    <a href="${pageContext.request.contextPath}/home.jsp" class="btn-pill-success py-2">
                                        <i class="bi bi-tag me-1"></i> Xem ưu đãi hôm nay
                                    </a>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="tab-pane fade" id="nav-notifications" role="tabpanel">
                    <div class="profile-section-card">
                        <div class="profile-section-header">
                            <div>
                                <span class="section-tag">KẾT NỐI & CẬP NHẬT</span>
                                <h3 class="section-heading">Hộp Thư Thông Báo</h3>
                            </div>
                            <c:if test="${not empty notifications}">
                                <button class="btn btn-link text-success text-decoration-none small fw-semibold">
                                    <i class="bi bi-check2-all me-1"></i> Đánh dấu đã đọc tất cả
                                </button>
                            </c:if>
                        </div>

                        <c:choose>
                            <c:when test="${not empty notifications}">
                                <div class="border-top">
                                    <c:forEach items="${notifications}" var="noti">
                                        <div class="notification-item">
                                            <div class="bg-primary bg-opacity-10 text-primary p-2 rounded-circle fs-5 flex-shrink-0">
                                                <i class="bi bi-bell"></i>
                                            </div>
                                            <div class="flex-grow-1">
                                                <strong class="text-dark small">${noti.title}</strong>
                                                <p class="text-muted small mb-0 mt-1">${noti.content}</p>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="empty-state">
                                    <div class="empty-state-icon">
                                        <i class="bi bi-bell-slash"></i>
                                    </div>
                                    <h5 class="fw-bold text-dark">Chưa có thông báo mới</h5>
                                    <p class="text-muted small mb-0">Các cập nhật về đơn hàng, vận chuyển chuỗi lạnh và khuyến mãi sẽ xuất hiện tại đây.</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="tab-pane fade" id="nav-address" role="tabpanel">
                    <div class="profile-section-card">
                        <div class="profile-section-header">
                            <div>
                                <span class="section-tag">ĐỊA ĐIỂM GIAO NHẬN</span>
                                <h3 class="section-heading">Địa Chỉ Nhận Trái Cây Chuỗi Lạnh</h3>
                            </div>
                            <c:if test="${not empty addresses}">
                                <button class="btn btn-fresh-green btn-sm px-3" data-bs-toggle="modal" data-bs-target="#addAddressModal">
                                    <i class="bi bi-plus-lg me-1"></i> Thêm địa chỉ mới
                                </button>
                            </c:if>
                        </div>

                        <c:choose>
                            <c:when test="${not empty addresses}">
                                <c:forEach items="${addresses}" var="addr">
                                    <div class="address-item ${(addr.isDefault or addr['default']) ? 'address-item-default' : ''}">
                                        <div>
                                            <div class="d-flex align-items-center gap-2 mb-1 flex-wrap">
                                                <strong class="text-dark fs-6">${addr.recipientName}</strong>
                                                <c:if test="${addr.isDefault or addr['default']}">
                                                    <span class="badge bg-success rounded-pill small"><i class="bi bi-check-circle-fill me-1"></i>Mặc định</span>
                                                </c:if>
                                            </div>
                                            <div class="text-muted small mb-1">
                                                <i class="bi bi-telephone text-success me-1"></i><strong>${addr.recipientPhone}</strong>
                                            </div>
                                            <div class="text-dark small">
                                                <i class="bi bi-geo-alt-fill text-danger me-1"></i>${addr.fullAddress}
                                            </div>
                                        </div>
                                        <div class="address-item-actions">
                                            <c:if test="${not (addr.isDefault or addr['default'])}">
                                                <form action="${pageContext.request.contextPath}/profile" method="POST" class="d-inline m-0">
                                                    <input type="hidden" name="action" value="setDefaultAddress">
                                                    <input type="hidden" name="addressId" value="${addr.addressId}">
                                                    <button type="submit" class="btn-pill-sec py-1" title="Đặt làm địa chỉ nhận hàng ưu tiên">
                                                        Thiết lập mặc định
                                                    </button>
                                                </form>
                                            </c:if>
                                            <form action="${pageContext.request.contextPath}/profile" method="POST" class="d-inline m-0" onsubmit="return confirm('Bạn có chắc chắn muốn xóa địa chỉ này?');">
                                                <input type="hidden" name="action" value="deleteAddress">
                                                <input type="hidden" name="addressId" value="${addr.addressId}">
                                                <button type="submit" class="btn-pill-danger" title="Xóa địa chỉ">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <div class="empty-state">
                                    <div class="empty-state-icon">
                                        <i class="bi bi-geo-alt"></i>
                                    </div>
                                    <h5 class="fw-bold text-dark">Chưa lưu địa chỉ nhận hàng</h5>
                                    <p class="text-muted small mb-3">Thêm địa chỉ giao nhận để đặt hàng và nhận trái cây tươi nhanh chóng hơn.</p>
                                    <button class="btn-pill-success py-2" data-bs-toggle="modal" data-bs-target="#addAddressModal">
                                        <i class="bi bi-plus-lg me-1"></i> Thêm địa chỉ nhận hàng
                                    </button>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="tab-pane fade" id="nav-security" role="tabpanel">
                    <div class="profile-section-card">
                        <span class="section-tag">AN TOÀN TÀI KHOẢN</span>
                        <h3 class="section-heading mb-4">Mật Khẩu & Bảo Mật 2 Lớp (2FA)</h3>

                        <form action="${pageContext.request.contextPath}/profile" method="POST">
                            <input type="hidden" name="action" value="changePassword">

                            <div class="row g-3 mb-3">
                                <div class="col-md-4 field-box">
                                    <label class="field-label" for="oldPassword">Mật khẩu hiện tại *</label>
                                    <div class="input-icon-group">
                                        <i class="bi bi-key lead-icon"></i>
                                        <input type="password" id="oldPassword" name="oldPassword" required placeholder="••••••••">
                                    </div>
                                </div>
                                <div class="col-md-4 field-box">
                                    <label class="field-label" for="newPassword">Mật khẩu mới *</label>
                                    <div class="input-icon-group">
                                        <i class="bi bi-lock lead-icon"></i>
                                        <input type="password" id="newPassword" name="newPassword" required placeholder="Tối thiểu 6 ký tự">
                                    </div>
                                </div>
                                <div class="col-md-4 field-box">
                                    <label class="field-label" for="confirmPassword">Xác nhận mật khẩu *</label>
                                    <div class="input-icon-group">
                                        <i class="bi bi-lock-fill lead-icon"></i>
                                        <input type="password" id="confirmPassword" name="confirmPassword" required placeholder="Nhập lại mật khẩu mới">
                                    </div>
                                </div>
                            </div>

                            <button type="submit" class="btn btn-fresh-green btn-sm px-4">
                                <i class="bi bi-shield-lock me-1"></i> Cập nhật mật khẩu mới
                            </button>
                        </form>

                        <hr class="my-4">

                        <div class="security-2fa-row">
                            <div>
                                <strong class="text-dark d-block">Xác thực hai yếu tố (2FA)</strong>
                                <span class="text-muted small">Tăng cường an toàn cho tài khoản khi đăng nhập bằng mã OTP qua điện thoại hoặc ứng dụng Google Authenticator.</span>
                            </div>
                            <button class="btn-pill-success">Cấu hình 2FA</button>
                        </div>

                        <div class="border-top pt-3">
                            <strong class="text-dark small d-block mb-2">Thiết bị & Phiên đăng nhập</strong>
                            <div class="session-device-box">
                                <div class="d-flex align-items-center gap-2">
                                    <i class="bi bi-laptop fs-5 text-success"></i>
                                    <div>
                                        <span class="small fw-semibold text-dark">Chrome trên Windows</span>
                                        <span class="badge bg-success ms-2 badge-xs">Thiết bị này</span>
                                        <div class="session-device-desc">Hà Nội, Việt Nam &bull; Đang hoạt động</div>
                                    </div>
                                </div>
                                <span class="text-success small fw-bold"><i class="bi bi-circle-fill text-success online-indicator-dot"></i> Online</span>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="addAddressModal" tabindex="-1" aria-labelledby="addAddressModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content border-0 shadow-lg rounded-4 overflow-hidden">
            <form action="${pageContext.request.contextPath}/profile" method="POST">
                <input type="hidden" name="action" value="addAddress">
                <div class="modal-header bg-success text-white px-4 py-3">
                    <h5 class="modal-title fw-bold d-flex align-items-center gap-2" id="addAddressModalLabel">
                        <i class="bi bi-geo-alt-fill"></i> Thêm Địa Chỉ Nhận Hàng Mới
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label-bold" for="recipientName">
                                Họ và tên người nhận <span class="text-danger">*</span>
                            </label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="bi bi-person text-muted"></i></span>
                                <input type="text" class="form-control border-start-0" id="recipientName" name="recipientName" required maxlength="100">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label-bold" for="recipientPhone">
                                Số điện thoại nhận hàng <span class="text-danger">*</span>
                            </label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="bi bi-telephone text-muted"></i></span>
                                <input type="tel" class="form-control border-start-0" id="recipientPhone" name="recipientPhone" required pattern="0[0-9]{9,10}" maxlength="11">
                            </div>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label-bold" for="citySelect">
                                Tỉnh / Thành phố <span class="text-danger">*</span>
                            </label>
                            <select class="form-select" id="citySelect" name="city" required>
                                <option value="" selected disabled>Chọn Tỉnh / Thành phố</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label-bold" for="districtSelect">
                                Quận / Huyện <span class="text-danger">*</span>
                            </label>
                            <select class="form-select" id="districtSelect" name="district" required disabled>
                                <option value="" selected disabled>Chọn Quận / Huyện</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label-bold" for="wardSelect">
                                Phường / Xã
                            </label>
                            <select class="form-select" id="wardSelect" name="ward" disabled>
                                <option value="" selected disabled>Chọn Phường / Xã</option>
                            </select>
                        </div>

                        <div class="col-12">
                            <label class="form-label-bold" for="streetAddress">
                                Địa chỉ cụ thể (Số nhà, tên ngõ, tòa nhà...) <span class="text-danger">*</span>
                            </label>
                            <input type="text" class="form-control" id="streetAddress" name="streetAddress" required maxlength="255">
                        </div>

                        <div class="col-12">
                            <div class="form-check p-3 rounded-3 bg-light border">
                                <input class="form-check-input ms-0 me-2" type="checkbox" name="isDefault" value="true" id="isDefaultCheck">
                                <label class="form-check-label small fw-semibold text-dark" for="isDefaultCheck">
                                    Đặt làm địa chỉ nhận hàng mặc định cho các đơn hàng tiếp theo
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer bg-light px-4 py-3">
                    <button type="button" class="btn-pill-sec" data-bs-dismiss="modal">Hủy bỏ</button>
                    <button type="submit" class="btn btn-fresh-green px-4 fw-semibold">
                        <i class="bi bi-check-lg me-1"></i> Lưu địa chỉ
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/profile.js"></script>
</body>
</html>
