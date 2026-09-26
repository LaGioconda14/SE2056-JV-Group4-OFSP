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
    <!-- Google Fonts: Plus Jakarta Sans -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Dedicated Profile CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/profile.css?v=1">
</head>
<body>

<!-- 1. TOP ANNOUNCEMENT BAR -->
<div class="top-announcement">
    <div class="container d-flex justify-content-between align-items-center">
        <div>
            <i class="bi bi-truck me-1"></i> Giao hàng miễn phí trong ngày cho đơn từ 200.000₫ | <strong>Cam kết 100% Nông Trại Sạch</strong>
        </div>
        <div class="d-none d-md-flex align-items-center gap-3">
            <span><i class="bi bi-telephone-fill me-1"></i> Hotline: 1900 6868</span>
            <span>VND (₫)</span>
            <span>Tiếng Việt</span>
        </div>
    </div>
</div>

<!-- 2. MAIN NAVBAR -->
<nav class="navbar-main py-3">
    <div class="container d-flex align-items-center justify-content-between gap-3">
        <!-- Logo -->
        <a href="${pageContext.request.contextPath}/home.jsp" class="d-flex align-items-center gap-2 text-decoration-none">
            <span class="fs-2">🍎</span>
            <div>
                <div class="brand-title">FreshFruit</div>
                <div class="brand-sub">DIRECT FROM ORCHARD</div>
            </div>
        </a>

        <!-- Search Bar -->
        <div class="d-none d-lg-block flex-grow-1 mx-4" style="max-width: 520px;">
            <div class="search-container">
                <select class="form-select border-0 bg-transparent text-secondary small fw-semibold" style="width: 140px; box-shadow: none;">
                    <option>Tất cả danh mục</option>
                    <option>Trái cây nội địa</option>
                    <option>Trái cây nhập khẩu</option>
                    <option>Giỏ quà organic</option>
                </select>
                <div class="vr my-1"></div>
                <input type="text" placeholder="Tìm kiếm dâu tây, bơ sáp, nho mẫu đơn...">
                <button class="btn btn-fresh-green btn-sm rounded-pill px-3 py-1">
                    <i class="bi bi-search"></i>
                </button>
            </div>
        </div>

        <!-- Right Quick Actions -->
        <div class="d-flex align-items-center gap-3">
            <!-- Cart Preview -->
            <a href="${pageContext.request.contextPath}/cart" class="d-flex align-items-center gap-2 text-decoration-none px-3 py-2 rounded-pill" style="background: #f0fdf4; border: 1px solid #bbf7d0;">
                <div class="position-relative">
                    <i class="bi bi-cart3 fs-5" style="color: var(--primary-green);"></i>
                    <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger" style="font-size: 10px;">3</span>
                </div>
                <span class="fw-bold small d-none d-sm-inline" style="color: var(--primary-green);">345.000₫</span>
            </a>

            <!-- User Menu -->
            <div class="dropdown">
                <a href="#" class="d-flex align-items-center gap-2 text-decoration-none dropdown-toggle px-2 py-1 rounded-pill" style="background: #f1f5f9;" data-bs-toggle="dropdown">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user.avatarUrl}">
                            <img src="${pageContext.request.contextPath}/${sessionScope.user.avatarUrl}" class="rounded-circle object-fit-cover" style="width: 32px; height: 32px;" alt="Avatar">
                        </c:when>
                        <c:otherwise>
                            <div class="avatar-placeholder rounded-circle" style="width: 32px; height: 32px; font-size: 14px;">
                                ${not empty sessionScope.user.fullName ? sessionScope.user.fullName.substring(0, 1).toUpperCase() : 'U'}
                            </div>
                        </c:otherwise>
                    </c:choose>
                    <span class="fw-semibold small text-dark d-none d-md-inline">
                        ${sessionScope.user.fullName}
                    </span>
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

<!-- 3. SUB NAVBAR -->
<div class="sub-nav d-none d-md-block">
    <div class="container d-flex justify-content-between align-items-center">
        <div class="d-flex">
            <a href="${pageContext.request.contextPath}/home.jsp" class="nav-link">Trang Chủ</a>
            <a href="#" class="nav-link">Cửa Hàng</a>
            <a href="#" class="nav-link">Danh Mục Trái Cây</a>
            <a href="#" class="nav-link">Hộp Quà & Combo</a>
            <a href="#" class="nav-link">Về Nông Trại</a>
            <a href="#" class="nav-link">Liên Hệ</a>
        </div>
        <div class="text-danger small fw-semibold">
            <i class="bi bi-lightning-charge-fill"></i> Flash Sale Hôm Nay: Giảm 30% Cam & Bưởi Da Xanh
        </div>
    </div>
</div>

<!-- 4. MAIN PAGE BODY -->
<div class="container py-4">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb small">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home.jsp" class="text-decoration-none text-muted">Trang chủ</a></li>
            <li class="breadcrumb-item text-muted">Tài khoản của tôi</li>
            <li class="breadcrumb-item active text-success fw-semibold" aria-current="page">Hồ Sơ Cá Nhân & Cài Đặt</li>
        </ol>
    </nav>

    <!-- Page Title & Actions -->
    <div class="profile-hero d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
        <div>
            <h1 class="h3 fw-bold mb-0 text-dark">Hồ Sơ Cá Nhân & Cài Đặt Tài Khoản</h1>
        </div>
        <div class="d-flex align-items-center gap-2 flex-shrink-0">
            <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill px-3 py-2 fw-semibold" onclick="switchTab('nav-security-tab')">
                <i class="bi bi-shield-check me-1"></i> Lịch sử đăng nhập & Bảo mật
            </button>
        </div>
    </div>

    <!-- Alert Notifications -->
    <c:if test="${not empty successMessage}">
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center rounded-3 mb-4" role="alert">
            <i class="bi bi-check-circle-fill me-2 fs-5"></i>
            <div>${successMessage}</div>
            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center rounded-3 mb-4" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
            <div>${errorMessage}</div>
            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <!-- 5. TWO-COLUMN LAYOUT -->
    <div class="row g-4">
        <!-- ================= LEFT COLUMN ================= -->
        <div class="col-lg-3 col-md-4">
            <!-- User Mini Profile & Points Card -->
            <div class="sidebar-user-card text-center">
                <div class="user-avatar-wrap">
                    <c:choose>
                        <c:when test="${not empty user.avatarUrl}">
                            <img src="${pageContext.request.contextPath}/${user.avatarUrl}" class="rounded-circle shadow-sm object-fit-cover" style="width: 72px; height: 72px;" alt="Avatar">
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
                <p class="text-muted small mb-2">${user.email}</p>
                

                <!-- Harvest Points Progress
                <div class="text-start mt-2 pt-2 border-top">
                    <div class="d-flex justify-content-between small fw-semibold">
                        <span class="text-muted">Tích điểm :</span>
                        <span class="text-success fw-bold">1,425 / 2,000</span>
                    </div>
                    <div class="points-progress">
                        <div class="progress-bar" style="width: 71%;"></div>
                    </div>
                    <div class="d-flex justify-content-between text-muted" style="font-size: 11px;">
                        <span>Hạng Gold Harvest</span>
                        <span>Còn 575đ lên Platinum</span>
                    </div>
                </div> -->
            </div>

            <!-- Navigation Menu Card (Có đơn mua, kho voucher, thông báo theo yêu cầu) -->
            <div class="sidebar-menu-card">
                <div class="nav flex-column" id="profileSidebarTab" role="tablist">
                    <!-- 1. Thông tin cá nhân -->
                    <button class="sidebar-nav-item active text-start border-0" id="nav-profile-tab" data-bs-toggle="pill" data-bs-target="#nav-profile" type="button" role="tab">
                        <span><i class="bi bi-person-fill"></i> Thông tin cá nhân</span>
                        <i class="bi bi-chevron-right small"></i>
                    </button>

                    <!-- 2. Đơn mua -->
                    <button class="sidebar-nav-item text-start border-0" id="nav-orders-tab" data-bs-toggle="pill" data-bs-target="#nav-orders" type="button" role="tab">
                        <span><i class="bi bi-bag-check-fill"></i> Đơn mua</span>
                        <span class="badge bg-success rounded-pill" style="font-size: 11px;">2 đang giao</span>
                    </button>

                    <!-- 3. Kho voucher -->
                    <button class="sidebar-nav-item text-start border-0" id="nav-vouchers-tab" data-bs-toggle="pill" data-bs-target="#nav-vouchers" type="button" role="tab">
                        <span><i class="bi bi-ticket-perforated-fill"></i> Kho voucher</span>
                        <span class="badge bg-warning text-dark rounded-pill fw-bold" style="font-size: 11px;">5 mã</span>
                    </button>

                    <!-- 4. Thông báo -->
                    <button class="sidebar-nav-item text-start border-0" id="nav-notifications-tab" data-bs-toggle="pill" data-bs-target="#nav-notifications" type="button" role="tab">
                        <span><i class="bi bi-bell-fill"></i> Thông báo</span>
                        <span class="badge bg-danger rounded-pill" style="font-size: 11px;">3 mới</span>
                    </button>

                    <!-- 5. Địa chỉ -->
                    <button class="sidebar-nav-item text-start border-0" id="nav-address-tab" data-bs-toggle="pill" data-bs-target="#nav-address" type="button" role="tab">
                        <span><i class="bi bi-geo-alt-fill"></i> Địa chỉ</span>
                        <i class="bi bi-chevron-right small"></i>
                    </button>

                    <!-- 6. Bảo mật & Đăng nhập -->
                    <button class="sidebar-nav-item text-start border-0" id="nav-security-tab" data-bs-toggle="pill" data-bs-target="#nav-security" type="button" role="tab">
                        <span><i class="bi bi-shield-lock-fill"></i> Bảo mật & Đăng nhập</span>
                        <span class="badge bg-success rounded-pill" style="font-size: 10px;">Chuẩn</span>
                    </button>

                    <hr class="my-2 border-secondary-subtle">

                    <!-- 7. Đăng xuất -->
                    <a href="${pageContext.request.contextPath}/logout" class="sidebar-nav-item text-danger text-decoration-none">
                        <span><i class="bi bi-box-arrow-right text-danger"></i> Đăng xuất tài khoản</span>
                    </a>
                </div>
            </div>

            <!-- Farm Guarantee Box -->
            <div class="farm-badge-box text-start">
                <div class="d-flex align-items-center gap-2 mb-2">
                    <i class="bi bi-patch-check-fill fs-4 text-success"></i>
                    <strong class="text-dark small">Bảo chứng 100% Nông Trại</strong>
                </div>
                <p class="text-muted mb-0" style="font-size: 11.5px; line-height: 1.5;">
                    Mỗi sản phẩm trái cây giao đến đều có tem QR truy xuất nguồn gốc từ các nông trại sạch VietGAP/GlobalGAP liên kết.
                </p>
            </div>
        </div>

        <!-- ================= RIGHT COLUMN (TAB PANES) ================= -->
        <div class="col-lg-9 col-md-8">
            <div class="tab-content" id="profileTabContent">

                <!-- ***************** TAB 1: THÔNG TIN CÁ NHÂN ***************** -->
                <div class="tab-pane fade show active" id="nav-profile" role="tabpanel">
                    
                    <!-- Form ẩn để Upload Avatar độc lập -->
                    <form id="avatarUploadForm" action="${pageContext.request.contextPath}/profile" method="POST" enctype="multipart/form-data" style="display:none;">
                        <input type="hidden" name="action" value="uploadAvatar">
                        <input type="file" id="avatarFileInput" name="avatarFile" accept="image/png, image/jpeg, image/jpg, image/webp" onchange="submitAvatarForm()">
                    </form>

                    <!-- Form ẩn để Xóa Avatar độc lập -->
                    <form id="avatarDeleteForm" action="${pageContext.request.contextPath}/profile" method="POST" style="display:none;">
                        <input type="hidden" name="action" value="deleteAvatar">
                    </form>

                    <!-- Form Thông tin Cá Nhân Cơ Bản -->
                    <form action="${pageContext.request.contextPath}/profile" method="POST" id="profileMainForm">
                        <input type="hidden" name="action" value="updateProfile">
                        
                        <div class="profile-section-card">
                            <span class="section-tag">THÔNG TIN ĐỊNH DANH</span>
                            <h3 class="section-heading">Thông tin Cá Nhân Cơ Bản</h3>

                            <!-- Khu vực Ảnh đại diện & Tải ảnh mới -->
                            <div class="d-flex flex-column flex-sm-row align-items-center gap-3 p-3 mb-4 rounded-3" style="background: #f8fafc; border: 1px dashed #cbd5e1;">
                                <c:choose>
                                    <c:when test="${not empty user.avatarUrl}">
                                        <img src="${pageContext.request.contextPath}/${user.avatarUrl}" class="rounded-circle shadow-sm object-fit-cover flex-shrink-0" style="width: 76px; height: 76px;" alt="Avatar">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="avatar-placeholder rounded-circle shadow-sm flex-shrink-0" style="width: 76px; height: 76px; font-size: 30px;">
                                            ${not empty user.fullName ? user.fullName.substring(0, 1).toUpperCase() : 'U'}
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                                <div>
                                    <div class="d-flex align-items-center gap-2 mb-1">
                                        <button type="button" class="btn btn-fresh-green btn-sm rounded-pill px-3" onclick="document.getElementById('avatarFileInput').click();">
                                            <i class="bi bi-upload me-1"></i> Tải ảnh mới
                                        </button>
                                        <c:if test="${not empty user.avatarUrl}">
                                            <button type="button" class="btn btn-outline-danger btn-sm rounded-pill px-3" onclick="confirmDeleteAvatar()">Xóa ảnh</button>
                                        </c:if>
                                    </div>
                                    <div class="text-muted" style="font-size: 11.5px;">
                                        Ảnh đại diện hiển thị trên đơn hàng và hồ sơ khách hàng. Định dạng JPG, PNG, WEBP tối đa 2MB.
                                    </div>
                                </div>
                            </div>

                            <div class="row g-3">
                                <!-- Họ và tên -->
                                <div class="col-md-6 field-box">
                                    <label class="field-label" for="fullName">Họ và tên *</label>
                                    <div class="input-icon-group">
                                        <i class="bi bi-person lead-icon"></i>
                                        <input type="text" id="fullName" name="fullName" value="${user.fullName}" required placeholder="Nhập họ và tên của bạn">
                                    </div>
                                </div>

                                <!-- Tên hiển thị -->
                                <div class="col-md-6 field-box">
                                    <label class="field-label" for="displayName">Tên hiển thị & Xưng hô giao dịch</label>
                                    <div class="input-icon-group">
                                        <i class="bi bi-card-heading lead-icon"></i>
                                        <input type="text" id="displayName" name="displayName" value="${user.fullName}" placeholder="Tên gọi khi shipper liên hệ">
                                    </div>
                                </div>

                                <!-- Email (ẩn ****) -->
                                <div class="col-md-6 field-box">
                                    <label class="field-label" for="email">Địa chỉ Email nhận hóa đơn *</label>
                                    <div class="input-icon-group position-relative">
                                        <i class="bi bi-envelope lead-icon"></i>
                                        <input type="text" id="email" value="${user.maskedEmail}" readonly style="background-color: #f8fafc; cursor: not-allowed; padding-right: 40px;" title="Email đăng nhập">
                                        <button type="button" class="btn btn-sm btn-link text-decoration-none text-muted position-absolute end-0 top-50 translate-middle-y me-2 p-1" onclick="toggleEmailMask(this)" title="Ẩn/Hiện Email">
                                            <i class="bi bi-eye-slash" id="emailEyeIcon"></i>
                                        </button>
                                    </div>
                                </div>

                                <!-- Số điện thoại (ẩn ****) -->
                                <div class="col-md-6 field-box">
                                    <label class="field-label" for="phone">Số điện thoại giao hàng *</label>
                                    <div class="input-icon-group position-relative">
                                        <i class="bi bi-telephone lead-icon"></i>
                                        <input type="text" id="phone" name="phone" value="${user.maskedPhone}" data-original="${not empty user.phone ? user.phone : ''}" data-masked="${user.maskedPhone}" placeholder="Ví dụ: 0912345678" style="padding-right: 40px;" onfocus="onPhoneFocus(this)" onblur="onPhoneBlur(this)">
                                        <button type="button" class="btn btn-sm btn-link text-decoration-none text-muted position-absolute end-0 top-50 translate-middle-y me-2 p-1" onclick="togglePhoneMask(this)" title="Ẩn/Hiện Số điện thoại">
                                            <i class="bi bi-eye-slash" id="phoneEyeIcon"></i>
                                        </button>
                                    </div>
                                </div>

                                <!-- Ngày sinh (ẩn ****) -->
                                <div class="col-md-6 field-box">
                                    <label class="field-label" for="birthDate">Ngày sinh (để nhận quà quả tươi sinh nhật)</label>
                                    <div class="input-icon-group position-relative">
                                        <i class="bi bi-calendar3 lead-icon"></i>
                                        <input type="text" id="birthDateMasked" value="${user.maskedBirthDate}" readonly style="cursor: pointer; padding-right: 40px;" onclick="enableBirthDateEdit()" title="Bấm để xem hoặc chọn ngày sinh">
                                        <input type="date" id="birthDate" name="birthDate" value="${user.birthDate}" style="display: none; padding-right: 40px;">
                                        <button type="button" class="btn btn-sm btn-link text-decoration-none text-muted position-absolute end-0 top-50 translate-middle-y me-2 p-1" onclick="toggleBirthDateMask(this)" title="Ẩn/Hiện Ngày sinh">
                                            <i class="bi bi-eye-slash" id="birthDateEyeIcon"></i>
                                        </button>
                                    </div>
                                </div>

                                <!-- Giới tính (Lưu vào DB) -->
                                <div class="col-md-6 field-box">
                                    <label class="field-label">Giới tính</label>
                                    <div class="btn-group w-100" role="group">
                                        <input type="radio" class="btn-check" name="gender" id="genderFemale" value="FEMALE" autocomplete="off" ${user.gender == 'FEMALE' ? 'checked' : ''}>
                                        <label class="btn btn-outline-success btn-sm py-2" for="genderFemale"><i class="bi bi-gender-female me-1"></i>Nữ</label>

                                        <input type="radio" class="btn-check" name="gender" id="genderMale" value="MALE" autocomplete="off" ${user.gender == 'MALE' ? 'checked' : ''}>
                                        <label class="btn btn-outline-success btn-sm py-2" for="genderMale"><i class="bi bi-gender-male me-1"></i>Nam</label>

                                        <input type="radio" class="btn-check" name="gender" id="genderOther" value="OTHER" autocomplete="off" ${user.gender == 'OTHER' ? 'checked' : ''}>
                                        <label class="btn btn-outline-success btn-sm py-2" for="genderOther"><i class="bi bi-gender-ambiguous me-1"></i>Khác</label>
                                    </div>
                                </div>

                                <!-- Ngôn ngữ giao dịch -->
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

                                <!-- Múi giờ giao nhận -->
                                <div class="col-md-6 field-box">
                                    <label class="field-label" for="timezone">Múi giờ giao nhận</label>
                                    <div class="input-icon-group">
                                        <i class="bi bi-globe-asia-australia lead-icon"></i>
                                        <select id="timezone" name="timezone">
                                            <option selected>GMT+7:00 Bangkok, Hanoi, Jakarta</option>
                                            <option>GMT+8:00 Singapore, Taipei</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Sticky Action Bar -->
                        <div class="sticky-action-bar">
                            <div class="text-muted small">
                                <i class="bi bi-info-circle text-success me-1"></i> Tất cả các tùy chỉnh sẽ có hiệu lực ngay tức thì trên hệ thống FreshFruit.
                            </div>
                            <div class="d-flex gap-2">
                                <button type="reset" class="btn btn-outline-secondary btn-sm px-3 rounded-pill">Hủy bỏ</button>
                                <button type="submit" class="btn btn-fresh-green btn-sm px-4 rounded-pill">
                                    <i class="bi bi-check2 me-1"></i> Lưu thay đổi
                                </button>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- ***************** TAB 2: ĐƠN MUA ***************** -->
                <div class="tab-pane fade" id="nav-orders" role="tabpanel">
                    <div class="profile-section-card">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div>
                                <span class="section-tag">LỊCH SỬ ĐẶT HÀNG</span>
                                <h3 class="section-heading mb-0">Đơn Hàng Của Bạn</h3>
                            </div>
                            <span class="badge bg-success bg-opacity-10 text-success fw-bold px-3 py-1 rounded-pill small">
                                4 đơn hàng gần nhất
                            </span>
                        </div>

                        <!-- Status filter tabs -->
                        <div class="d-flex flex-wrap gap-2 mb-4 border-bottom pb-3">
                            <button class="btn btn-fresh-green btn-sm rounded-pill px-3">Tất cả (4)</button>
                            <button class="btn btn-outline-secondary btn-sm rounded-pill px-3">Đang giao (2)</button>
                            <button class="btn btn-outline-secondary btn-sm rounded-pill px-3">Đã giao (1)</button>
                            <button class="btn btn-outline-secondary btn-sm rounded-pill px-3">Đã hủy (1)</button>
                        </div>

                        <!-- Order Card 1: Delivering -->
                        <div class="card border rounded-3 p-3 mb-3 shadow-none">
                            <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-2">
                                <div>
                                    <strong class="text-dark">Mã đơn: #FF-ORD-8821</strong>
                                    <span class="text-muted small ms-2"><i class="bi bi-clock"></i> 26/09/2026 14:30</span>
                                </div>
                                <span class="badge bg-primary bg-opacity-10 text-primary px-3 py-1 rounded-pill fw-semibold">
                                    <i class="bi bi-truck me-1"></i> Đang giao hàng (Chuỗi lạnh 4.2°C)
                                </span>
                            </div>
                            <div class="row align-items-center">
                                <div class="col-md-8">
                                    <div class="d-flex align-items-center gap-3">
                                        <div class="bg-light p-2 rounded-3 fs-3">🍒🥑🍓</div>
                                        <div>
                                            <div class="fw-semibold text-dark">Combo Quả Tươi Mùa Thu + Bơ sáp 034 Đắk Lắk (2kg)</div>
                                            <div class="text-muted small">Kèm hộp dâu tây Mộc Châu Organic 500g</div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-4 text-md-end mt-2 mt-md-0">
                                    <div class="text-muted small">Tổng thanh toán:</div>
                                    <div class="fw-bold fs-5 text-success">765.000₫</div>
                                    <div class="mt-2">
                                        <button class="btn btn-outline-success btn-sm rounded-pill px-3">Theo dõi đơn</button>
                                        <button class="btn btn-light btn-sm rounded-pill px-3">Chi tiết</button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Order Card 2: Completed -->
                        <div class="card border rounded-3 p-3 shadow-none">
                            <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-2">
                                <div>
                                    <strong class="text-dark">Mã đơn: #FF-ORD-8815</strong>
                                    <span class="text-muted small ms-2"><i class="bi bi-clock"></i> 22/09/2026 09:15</span>
                                </div>
                                <span class="badge bg-success bg-opacity-10 text-success px-3 py-1 rounded-pill fw-semibold">
                                    <i class="bi bi-check-circle me-1"></i> Đã giao thành công
                                </span>
                            </div>
                            <div class="row align-items-center">
                                <div class="col-md-8">
                                    <div class="d-flex align-items-center gap-3">
                                        <div class="bg-light p-2 rounded-3 fs-3">🍇🍊</div>
                                        <div>
                                            <div class="fw-semibold text-dark">Nho Mẫu Đơn Shine Muscat Nhật (1 chùm) + Cam Cara Úc (2kg)</div>
                                            <div class="text-muted small">Đóng hộp quà tặng cao cấp</div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-4 text-md-end mt-2 mt-md-0">
                                    <div class="text-muted small">Tổng thanh toán:</div>
                                    <div class="fw-bold fs-5 text-success">1.150.000₫</div>
                                    <div class="mt-2">
                                        <button class="btn btn-fresh-green btn-sm rounded-pill px-3">Mua lại đơn này</button>
                                        <button class="btn btn-light btn-sm rounded-pill px-3">Đánh giá</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ***************** TAB 3: KHO VOUCHER ***************** -->
                <div class="tab-pane fade" id="nav-vouchers" role="tabpanel">
                    <div class="profile-section-card">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div>
                                <span class="section-tag">ƯU ĐÃI DÀNH RIÊNG CHO BẠN</span>
                                <h3 class="section-heading mb-0">Kho Voucher & Mã Khuyến Mãi</h3>
                            </div>
                            <span class="badge bg-warning bg-opacity-10 text-warning-emphasis fw-bold px-3 py-1 rounded-pill small">
                                5 voucher sẵn sàng sử dụng
                            </span>
                        </div>

                        <div class="row g-3">
                            <!-- Voucher 1 -->
                            <div class="col-md-6">
                                <div class="voucher-ticket">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <span class="badge bg-success mb-2">GIẢM 15%</span>
                                            <h5 class="fw-bold text-dark mb-1">Mã: FRESHHARVEST</h5>
                                            <p class="text-muted small mb-2">Giảm tối đa 100.000₫ cho đơn hoa quả từ 400.000₫.</p>
                                            <div class="text-danger small"><i class="bi bi-clock me-1"></i>Hết hạn: 31/10/2026</div>
                                        </div>
                                        <button class="btn btn-outline-success btn-sm rounded-pill px-3" onclick="navigator.clipboard.writeText('FRESHHARVEST'); alert('Đã sao chép mã FRESHHARVEST!');">
                                            Sao chép
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <!-- Voucher 2 -->
                            <div class="col-md-6">
                                <div class="voucher-ticket">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <span class="badge bg-primary mb-2">FREESHIP</span>
                                            <h5 class="fw-bold text-dark mb-1">Mã: FREESHIP_COLD</h5>
                                            <p class="text-muted small mb-2">Miễn phí 100% phí bảo quản chuỗi lạnh cho đơn từ 250.000₫.</p>
                                            <div class="text-danger small"><i class="bi bi-clock me-1"></i>Hết hạn: 15/10/2026</div>
                                        </div>
                                        <button class="btn btn-outline-success btn-sm rounded-pill px-3" onclick="navigator.clipboard.writeText('FREESHIP_COLD'); alert('Đã sao chép mã FREESHIP_COLD!');">
                                            Sao chép
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <!-- Voucher 3 -->
                            <div class="col-md-6">
                                <div class="voucher-ticket">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <span class="badge bg-warning text-dark mb-2">GOLD VIP</span>
                                            <h5 class="fw-bold text-dark mb-1">Mã: GOLDVIP50</h5>
                                            <p class="text-muted small mb-2">Tặng 50.000₫ áp dụng toàn bộ giỏ hoa quả nhập khẩu.</p>
                                            <div class="text-danger small"><i class="bi bi-clock me-1"></i>Hết hạn: 30/11/2026</div>
                                        </div>
                                        <button class="btn btn-outline-success btn-sm rounded-pill px-3" onclick="navigator.clipboard.writeText('GOLDVIP50'); alert('Đã sao chép mã GOLDVIP50!');">
                                            Sao chép
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <!-- Voucher 4 -->
                            <div class="col-md-6">
                                <div class="voucher-ticket">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <span class="badge bg-secondary mb-2">SINH NHẬT</span>
                                            <h5 class="fw-bold text-dark mb-1">Mã: BDAY_ORCHARD</h5>
                                            <p class="text-muted small mb-2">Tặng 1 hộp Cherry đỏ hoặc dâu tây nhân tháng sinh nhật.</p>
                                            <div class="text-muted small"><i class="bi bi-gift me-1"></i>Kích hoạt trong tháng sinh</div>
                                        </div>
                                        <button class="btn btn-outline-secondary btn-sm rounded-pill px-3" disabled>Chờ kích hoạt</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ***************** TAB 4: THÔNG BÁO ***************** -->
                <div class="tab-pane fade" id="nav-notifications" role="tabpanel">
                    <div class="profile-section-card">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div>
                                <span class="section-tag">KẾT NỐI & CẬP NHẬT</span>
                                <h3 class="section-heading mb-0">Hộp Thư Thông Báo</h3>
                            </div>
                            <button class="btn btn-link text-success text-decoration-none small fw-semibold">
                                <i class="bi bi-check2-all me-1"></i> Đánh dấu đã đọc tất cả
                            </button>
                        </div>

                        <div class="list-group list-group-flush border-top">
                            <!-- Notification 1 -->
                            <div class="list-group-item px-0 py-3 d-flex gap-3 align-items-start">
                                <div class="bg-primary bg-opacity-10 text-primary p-2 rounded-circle fs-5 flex-shrink-0">
                                    <i class="bi bi-truck"></i>
                                </div>
                                <div class="flex-grow-1">
                                    <div class="d-flex justify-content-between">
                                        <strong class="text-dark small">Đơn hàng #FF-ORD-8821 đang trên đường giao!</strong>
                                        <span class="text-muted" style="font-size: 11px;">10 phút trước</span>
                                    </div>
                                    <p class="text-muted small mb-0 mt-1">
                                        Tài xế chuỗi lạnh đang di chuyển. Nhiệt độ thùng bảo quản đạt chuẩn 4.2°C. Dự kiến giao lúc 10:30.
                                    </p>
                                </div>
                            </div>

                            <!-- Notification 2 -->
                            <div class="list-group-item px-0 py-3 d-flex gap-3 align-items-start">
                                <div class="bg-success bg-opacity-10 text-success p-2 rounded-circle fs-5 flex-shrink-0">
                                    <i class="bi bi-basket2-fill"></i>
                                </div>
                                <div class="flex-grow-1">
                                    <div class="d-flex justify-content-between">
                                        <strong class="text-dark small">Lô Dâu Tây Mộc Châu vụ mới vừa cập bến!</strong>
                                        <span class="text-muted" style="font-size: 11px;">2 giờ trước</span>
                                    </div>
                                    <p class="text-muted small mb-0 mt-1">
                                        Dâu tây organic hái tại vườn sáng sớm nay đã về kho lạnh trung tâm. Đặt sớm để nhận quả tươi nhất!
                                    </p>
                                </div>
                            </div>

                            <!-- Notification 3 -->
                            <div class="list-group-item px-0 py-3 d-flex gap-3 align-items-start">
                                <div class="bg-warning bg-opacity-10 text-warning-emphasis p-2 rounded-circle fs-5 flex-shrink-0">
                                    <i class="bi bi-award-fill"></i>
                                </div>
                                <div class="flex-grow-1">
                                    <div class="d-flex justify-content-between">
                                        <strong class="text-dark small">+150 Harvest Points được cộng vào ví của bạn</strong>
                                        <span class="text-muted" style="font-size: 11px;">1 ngày trước</span>
                                    </div>
                                    <p class="text-muted small mb-0 mt-1">
                                        Điểm thưởng từ đơn hàng thành công #FF-ORD-8815 đã được ghi nhận. Bạn chỉ còn 575 điểm để lên hạng Platinum!
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ***************** TAB 5: ĐỊA CHỈ & CHUỖI LẠNH ***************** -->
                <div class="tab-pane fade" id="nav-address" role="tabpanel">
                    <div class="profile-section-card">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div>
                                <span class="section-tag">ĐỊA ĐIỂM GIAO NHẬN</span>
                                <h3 class="section-heading mb-0">Địa Chỉ Nhận Trái Cây Chuỗi Lạnh</h3>
                            </div>
                            <button class="btn btn-fresh-green btn-sm rounded-pill px-3">
                                <i class="bi bi-plus-lg me-1"></i> Thêm địa chỉ mới
                            </button>
                        </div>

                        <!-- Address card 1 -->
                        <div class="card border rounded-3 p-3 mb-3" style="border-color: #bbf7d0 !important; background-color: #f0fdf4;">
                            <div class="d-flex justify-content-between align-items-start">
                                <div>
                                    <div class="d-flex align-items-center gap-2 mb-1">
                                        <strong class="text-dark">${user.fullName}</strong>
                                        <span class="badge bg-success small">Mặc định</span>
                                        <span class="badge bg-light text-secondary border small">Nhà riêng</span>
                                    </div>
                                    <div class="text-muted small mb-1"><i class="bi bi-telephone me-1"></i>${user.phone}</div>
                                    <div class="text-dark small"><i class="bi bi-geo-alt me-1 text-success"></i>Tòa S2.05 VinHomes Smart City, Phường Tây Mỗ, Quận Nam Từ Liêm, Hà Nội</div>
                                    <div class="mt-2 text-success small">
                                        <i class="bi bi-shield-check me-1"></i> Ghi chú chuỗi lạnh: Gửi lễ tân bảo quản nếu vắng mặt.
                                    </div>
                                </div>
                                <div>
                                    <button class="btn btn-outline-success btn-sm rounded-pill">Sửa</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ***************** TAB 6: BẢO MẬT & ĐĂNG NHẬP ***************** -->
                <div class="tab-pane fade" id="nav-security" role="tabpanel">
                    <div class="profile-section-card">
                        <span class="section-tag">AN TOÀN TÀI KHOẢN</span>
                        <h3 class="section-heading">Mật Khẩu & Bảo Mật 2 Lớp (2FA)</h3>

                        <!-- Change password subform -->
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

                            <button type="submit" class="btn btn-fresh-green btn-sm rounded-pill px-4">
                                <i class="bi bi-shield-lock me-1"></i> Cập nhật mật khẩu mới
                            </button>
                        </form>

                        <hr class="my-4">

                        <!-- Two-Factor Authentication (2FA) -->
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div>
                                <strong class="text-dark d-block">Xác thực hai yếu tố (2FA)</strong>
                                <span class="text-muted small">Tăng cường an toàn cho tài khoản khi đăng nhập bằng mã OTP qua điện thoại hoặc ứng dụng Google Authenticator.</span>
                            </div>
                            <button class="btn btn-outline-success btn-sm rounded-pill px-3">Cấu hình 2FA</button>
                        </div>

                        <!-- Active sessions -->
                        <div class="border-top pt-3">
                            <strong class="text-dark small d-block mb-2">Thiết bị & Phiên đăng nhập</strong>
                            <div class="d-flex align-items-center justify-content-between p-2 rounded-3 bg-light">
                                <div class="d-flex align-items-center gap-2">
                                    <i class="bi bi-laptop fs-5 text-success"></i>
                                    <div>
                                        <span class="small fw-semibold text-dark">Chrome trên Windows</span>
                                        <span class="badge bg-success ms-2" style="font-size: 10px;">Thiết bị này</span>
                                        <div class="text-muted" style="font-size: 11px;">Hà Nội, Việt Nam &bull; Đang hoạt động</div>
                                    </div>
                                </div>
                                <span class="text-success small fw-bold"><i class="bi bi-circle-fill text-success" style="font-size: 8px;"></i> Online</span>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>

<!-- Bootstrap 5 JS Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // Tab Switch Helper
    function switchTab(tabButtonId) {
        const tabEl = document.getElementById(tabButtonId);
        if (tabEl) {
            const tabTrigger = new bootstrap.Tab(tabEl);
            tabTrigger.show();
            window.scrollTo({ top: 0, behavior: 'smooth' });
        }
    }

    // Xử lý Upload Avatar tự động khi chọn file
    function submitAvatarForm() {
        const fileInput = document.getElementById('avatarFileInput');
        if (fileInput && fileInput.files && fileInput.files[0]) {
            const file = fileInput.files[0];
            const validTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
            if (!validTypes.includes(file.type)) {
                alert('Định dạng file không hỗ trợ! Vui lòng chọn ảnh JPG, PNG hoặc WEBP.');
                fileInput.value = '';
                return;
            }
            if (file.size > 2 * 1024 * 1024) {
                alert('Kích thước file vượt quá 2MB! Vui lòng chọn ảnh nhẹ hơn.');
                fileInput.value = '';
                return;
            }
            document.getElementById('avatarUploadForm').submit();
        }
    }

    // Xử lý Xóa Avatar
    function confirmDeleteAvatar() {
        if (confirm('Bạn có chắc chắn muốn xóa ảnh đại diện hiện tại không?')) {
            document.getElementById('avatarDeleteForm').submit();
        }
    }

    // Auto open tab based on URL Hash (e.g., #security, #orders, #vouchers)
    document.addEventListener('DOMContentLoaded', function() {
        const hash = window.location.hash;
        if (hash === '#security') {
            switchTab('nav-security-tab');
        } else if (hash === '#orders') {
            switchTab('nav-orders-tab');
        } else if (hash === '#vouchers') {
            switchTab('nav-vouchers-tab');
        } else if (hash === '#notifications') {
            switchTab('nav-notifications-tab');
        }
    });
</script>

</body>
</html>
