<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cổng Giao Vận Chuỗi Lạnh - Gốc Vườn Express Shipper</title>
    <!-- Bootstrap 5 CSS & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Custom Shipper CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/shipper.css" rel="stylesheet">
</head>
<body>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark shipper-navbar py-3 sticky-top">
    <div class="container">
        <a class="navbar-brand fw-bold d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/shipper/deliveries">
            <span class="fs-4">🚚</span>
            <div>
                <div class="lh-1">Gốc Vườn Express</div>
                <small class="fs-xs text-light fw-normal opacity-75">Hệ thống điều phối tài xế chuỗi lạnh</small>
            </div>
        </a>
        <div class="d-flex align-items-center gap-3">
            <div class="dropdown">
                <button class="btn btn-sm btn-light fw-semibold dropdown-toggle rounded-pill px-3" type="button" data-bs-toggle="dropdown">
                    <i class="bi bi-person-circle me-1"></i> ${not empty driverProfile.fullName ? driverProfile.fullName : sessionScope.user.fullName}
                </button>
                <ul class="dropdown-menu dropdown-menu-end shadow-sm">
                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile"><i class="bi bi-person me-2"></i> Hồ sơ cá nhân</a></li>
                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/home.jsp"><i class="bi bi-shop me-2"></i> Xem sàn mua sắm</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-2"></i> Đăng xuất</a></li>
                </ul>
            </div>
        </div>
    </div>
</nav>

<div class="container py-4">

    <!-- Flash Notification Messages -->
    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center mb-4 shadow-sm rounded-4" role="alert">
            <i class="bi bi-check-circle-fill me-2 fs-5 flex-shrink-0"></i>
            <div>${sessionScope.successMessage}</div>
            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="successMessage" scope="session" />
    </c:if>
    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center mb-4 shadow-sm rounded-4" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-5 flex-shrink-0"></i>
            <div>${sessionScope.errorMessage}</div>
            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="errorMessage" scope="session" />
    </c:if>

    <!-- Driver Hero Info Card (Core MVP Scope) -->
    <div class="shipper-hero-card">
        <div class="row align-items-center g-3">
            <div class="col-md-7 d-flex align-items-center gap-3">
                <div class="driver-avatar-box">
                    <img src="${not empty sessionScope.user.avatarUrl ? sessionScope.user.avatarUrl : (not empty driverProfile.avatarUrl ? driverProfile.avatarUrl : 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=100&h=100&fit=crop')}" alt="Avatar">
                </div>
                <div>
                    <div class="d-flex align-items-center gap-2">
                        <h4 class="fw-bold mb-0 text-dark">${not empty driverProfile.fullName ? driverProfile.fullName : sessionScope.user.fullName}</h4>
                        <c:choose>
                            <c:when test="${not empty driverProfile.shopName}">
                                <span class="badge bg-success text-white small fw-semibold shadow-xs">
                                    <i class="bi bi-shop me-1"></i> Đội ngũ: ${driverProfile.shopName}
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-success-subtle text-success small fw-semibold">
                                    <i class="bi bi-patch-check-fill me-1"></i> Tài xế Gốc Vườn Express
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="text-muted small mt-1">
                        <i class="bi bi-telephone me-1"></i> SĐT: <strong class="text-dark">${not empty sessionScope.user.phone ? sessionScope.user.phone : driverProfile.phone}</strong> 
                        &bull; Phương tiện: <strong class="text-dark">${driverProfile.vehicleType}</strong>
                        &bull; Biển số: <strong class="text-dark">${driverProfile.licensePlate}</strong> 
                        <c:if test="${not empty driverProfile.coldBoxType}">
                            <span class="text-muted">(${driverProfile.coldBoxType})</span>
                        </c:if>
                    </div>
                    <div class="mt-2 d-flex flex-wrap gap-2 align-items-center">
                        <span class="badge bg-light text-dark border">
                            <i class="bi bi-geo-alt-fill text-danger me-1"></i> Khu vực: <strong>${not empty driverProfile.operatingCity ? driverProfile.operatingCity : 'Toàn hệ thống'}</strong>
                        </span>
                        <span class="badge bg-light text-primary border border-primary-subtle">
                            <i class="bi bi-box-seam me-1"></i> Đang phụ trách: <strong>${activeOrderCount != null ? activeOrderCount : 0} đơn</strong>
                        </span>
                    </div>
                </div>
            </div>
            <div class="col-md-5 text-md-end">
                <div class="bg-light p-3 rounded-4 border d-inline-block text-start shadow-xs">
                    <div class="text-muted small mb-1"><i class="bi bi-cash-stack text-success me-1"></i> Tiền COD đã thu:</div>
                    <div class="text-success fw-bold fs-4">
                        <fmt:formatNumber value="${totalCod != null ? totalCod : 0}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                    </div>
                </div>
            </div>
        </div>
    </div>


    <!-- Deliveries List -->
    <c:choose>
        <c:when test="${not empty deliveries}">
            <div class="row g-3">
                <c:forEach items="${deliveries}" var="del">
                    <c:set var="statusUpper" value="${del.deliveryStatus.toUpperCase()}" />
                    <div class="col-12 col-lg-6">
                        <div class="delivery-card h-100 d-flex flex-column justify-content-between">
                            <div>
                                <!-- Card Header -->
                                <div class="delivery-card-header">
                                    <div class="tracking-badge">
                                        <i class="bi bi-upc-scan text-success"></i> ${del.trackingNumber != null ? del.trackingNumber : del.subOrderCode}
                                        <span class="text-muted small fw-normal">(${del.subOrderCode})</span>
                                    </div>
                                    <c:choose>
                                        <c:when test="${statusUpper == 'DELIVERED'}">
                                            <span class="badge bg-success-subtle text-success border border-success-subtle px-3 py-1 rounded-pill">
                                                <i class="bi bi-check-circle-fill me-1"></i> GIAO THÀNH CÔNG
                                            </span>
                                        </c:when>
                                        <c:when test="${statusUpper == 'DELIVERING' or statusUpper == 'IN_TRANSIT'}">
                                            <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-3 py-1 rounded-pill">
                                                <i class="bi bi-truck me-1"></i> ĐANG ĐI GIAO
                                            </span>
                                        </c:when>
                                        <c:when test="${statusUpper == 'FAILED' or statusUpper == 'CANCELLED'}">
                                            <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-3 py-1 rounded-pill">
                                                <i class="bi bi-x-circle-fill me-1"></i> GIAO THẤT BẠI
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-warning-subtle text-warning-emphasis border border-warning-subtle px-3 py-1 rounded-pill">
                                                <i class="bi bi-box-seam me-1"></i> CHỜ LẤY HÀNG
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <!-- Cold Chain Temp Requirement & Delivery Scope Badge -->
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <div class="d-flex gap-2 align-items-center">
                                        <span class="temp-guarantee-pill">
                                            <i class="bi bi-snow"></i> Chuỗi lạnh: ${del.storageTemp}
                                        </span>
                                        <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill small py-1 px-2">
                                            <i class="bi bi-truck me-1"></i> Giao hàng tiêu chuẩn
                                        </span>
                                    </div>
                                    <span class="text-muted small">
                                        <i class="bi bi-clock me-1"></i> Slot: ${not empty del.deliverySlot ? del.deliverySlot : 'Hỏa tốc trong ngày'}
                                    </span>
                                </div>

                                <!-- Route Stop 1: Pickup from Shop -->
                                <div class="route-stop-box">
                                    <div class="route-stop-line"></div>
                                    <div class="route-stop-icon bg-success-subtle text-success">
                                        <i class="bi bi-shop"></i>
                                    </div>
                                    <div class="route-stop-details">
                                        <div class="d-flex justify-content-between align-items-baseline">
                                            <strong class="text-dark fs-6">${not empty del.shopName ? del.shopName : 'Cửa hàng Nông sản'}</strong>
                                            <c:if test="${not empty del.shopPhone}">
                                                <a href="tel:${del.shopPhone}" class="btn btn-sm btn-outline-success py-0 px-2 rounded-pill small">
                                                    <i class="bi bi-telephone-fill"></i> Gọi Cửa Hàng
                                                </a>
                                            </c:if>
                                        </div>
                                        <div class="text-muted small mt-1">
                                            <i class="bi bi-geo-alt"></i> ${not empty del.shopAddress ? del.shopAddress : 'Địa chỉ cửa hàng nông sản'}
                                        </div>
                                    </div>
                                </div>

                                <!-- Route Stop 2: Destination to Customer -->
                                <div class="route-stop-box pb-0">
                                    <div class="route-stop-icon bg-primary-subtle text-primary">
                                        <i class="bi bi-geo-alt-fill"></i>
                                    </div>
                                    <div class="route-stop-details">
                                        <div class="d-flex justify-content-between align-items-baseline">
                                            <strong class="text-dark fs-6">${del.recipientName}</strong>
                                            <c:if test="${not empty del.recipientPhone}">
                                                <a href="tel:${del.recipientPhone}" class="btn btn-sm btn-outline-primary py-0 px-2 rounded-pill small">
                                                    <i class="bi bi-telephone-fill"></i> Gọi Khách
                                                </a>
                                            </c:if>
                                        </div>
                                        <div class="text-dark small mt-1 fw-semibold">
                                            ${del.fullDeliveryAddress}
                                        </div>
                                        <c:if test="${not empty del.deliveryNote}">
                                            <div class="p-2 rounded bg-light border text-muted small mt-2">
                                                <i class="bi bi-chat-left-text text-primary me-1"></i> Ghi chú: ${del.deliveryNote}
                                            </div>
                                        </c:if>
                                    </div>
                                </div>

                                <!-- COD / Payment Information Banner -->
                                <div class="cod-collect-banner">
                                    <div>
                                        <span class="text-muted small d-block">Hình thức thanh toán:</span>
                                        <strong class="text-dark">${del.paymentMethod}</strong>
                                    </div>
                                    <div class="text-end">
                                        <c:choose>
                                            <c:when test="${del.COD and del.paymentStatus ne 'PAID'}">
                                                <span class="text-danger small fw-semibold d-block">Tiền cần thu hộ (COD):</span>
                                                <span class="fs-5 fw-bold text-danger">${del.formattedTotal}</span>
                                            </c:when>
                                            <c:when test="${del.paymentStatus eq 'PAID'}">
                                                <span class="text-success small fw-semibold d-block">Đã thanh toán Online:</span>
                                                <span class="fs-6 fw-bold text-success">0₫ (Không thu tiền)</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-warning small fw-semibold d-block">Đang chờ thanh toán:</span>
                                                <span class="fs-6 fw-bold text-warning">Không thu tiền mặt</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>

                                <!-- Product items preview -->
                                <div class="delivery-items-preview">
                                    <div class="text-muted small fw-semibold mb-2">
                                        <i class="bi bi-basket2 me-1"></i> Kiện hàng đóng gói riêng (${del.items.size()} sản phẩm):
                                    </div>
                                    <c:forEach items="${del.items}" var="it">
                                        <div class="d-flex align-items-center justify-content-between py-1 border-bottom border-light">
                                            <div class="d-flex align-items-center gap-2">
                                                <img src="${it.imageUrl}" class="delivery-item-thumb" alt="${it.productNameSnapshot}">
                                                <div>
                                                    <div class="text-dark small fw-semibold">${it.productNameSnapshot}</div>
                                                    <div class="text-muted fs-xs">${it.variantNameSnapshot} &bull; x${it.quantity}</div>
                                                </div>
                                            </div>
                                            <span class="text-success small fw-bold">${it.formattedTotalPrice}</span>
                                        </div>
                                    </c:forEach>
                                </div>

                                <!-- PoD Evidence Photo (if DELIVERED) -->
                                <c:if test="${statusUpper == 'DELIVERED' and not empty del.proofImageUrl}">
                                    <div class="d-flex align-items-center gap-3 p-2 bg-success-subtle rounded-3 mb-3 border border-success-subtle">
                                        <img src="${del.proofImageUrl}" class="pod-preview-image" alt="Proof of Delivery" onclick="viewImageModal('${del.proofImageUrl}')">
                                        <div>
                                            <strong class="text-success small d-block"><i class="bi bi-camera-fill me-1"></i> Bằng chứng giao hàng (PoD)</strong>
                                            <span class="text-muted fs-xs">Bấm vào ảnh để phóng to xác thực chữ ký/ảnh nhận.</span>
                                        </div>
                                    </div>
                                </c:if>

                                <!-- Failure Reason (if FAILED) -->
                                <c:if test="${statusUpper == 'FAILED' and not empty del.failureReason}">
                                    <div class="alert alert-danger py-2 px-3 small rounded-3 mb-3">
                                        <strong><i class="bi bi-exclamation-triangle-fill me-1"></i> Lý do giao thất bại:</strong> ${del.failureReason}
                                    </div>
                                </c:if>
                            </div>

                            <!-- Actions Footer matching Business Flow Diagram -->
                            <div class="pt-3 border-top mt-2">
                                <c:choose>
                                    <%-- CASE 1: Chờ lấy hàng tại Shop -> Driver bấm "Xác nhận lấy hàng" --%>
                                    <c:when test="${statusUpper == 'ASSIGNING' or statusUpper == 'ASSIGNED'}">
                                        <form method="post" action="${pageContext.request.contextPath}/shipper/deliveries">
                                            <input type="hidden" name="action" value="pickup">
                                            <input type="hidden" name="deliveryId" value="${del.deliveryId}">
                                            <button type="submit" class="btn btn-warning w-100 fw-bold py-2 rounded-3 shadow-xs" onclick="return confirm('Bạn xác nhận đã nhận đủ kiện hoa quả tươi từ Shop?')">
                                                <i class="bi bi-box-arrow-in-down me-1"></i> Xác Nhận Đã Lấy Hàng Tại Shop
                                            </button>
                                        </form>
                                    </c:when>

                                    <%-- CASE 2: Đang đi giao -> Bàn giao đồng kiểm tra -> Giao thành công hoặc Báo lỗi --%>
                                    <c:when test="${statusUpper == 'DELIVERING' or statusUpper == 'IN_TRANSIT'}">
                                        <div class="d-flex flex-column gap-2">
                                            <div class="d-flex gap-2">
                                                <button type="button" class="btn btn-success flex-grow-1 fw-bold py-2 rounded-3 shadow-xs"
                                                        onclick="openCompleteModal('${del.deliveryId}', '${del.trackingNumber}', '${del.formattedTotal}', ${del.COD})">
                                                    <i class="bi bi-check-circle-fill me-1"></i> Giao Thành Công (Chụp PoD)
                                                </button>
                                                <button type="button" class="btn btn-outline-danger px-3 py-2 rounded-3 fw-semibold"
                                                        onclick="openFailedModal('${del.deliveryId}', '${del.trackingNumber}')" title="Khách từ chối nhận hoặc quả hỏng">
                                                    <i class="bi bi-x-circle"></i> Báo Sự Cố
                                                </button>
                                            </div>
                                            <div class="d-flex justify-content-end align-items-center small text-muted">
                                                <a href="https://maps.google.com/?q=${del.fullDeliveryAddress}" target="_blank" class="text-decoration-none text-primary fw-semibold">
                                                    <i class="bi bi-compass me-1"></i> Chỉ đường tới Khách (Google Maps)
                                                </a>
                                            </div>
                                        </div>
                                    </c:when>

                                    <%-- CASE 3: Đã giao thành công --%>
                                    <c:when test="${statusUpper == 'DELIVERED'}">
                                        <div class="d-flex justify-content-between align-items-center text-muted small">
                                            <span class="text-success fw-semibold"><i class="bi bi-shield-check"></i> Đã hoàn tất chuyến giao chuỗi lạnh</span>
                                            <fmt:formatDate value="${del.deliveredAt}" pattern="HH:mm dd/MM/yyyy"/>
                                        </div>
                                    </c:when>

                                    <%-- CASE 4: Giao thất bại --%>
                                    <c:otherwise>
                                        <div class="d-flex justify-content-between align-items-center text-muted small">
                                            <span class="text-danger fw-semibold"><i class="bi bi-x-circle"></i> Giao hàng không thành công</span>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div class="text-center py-5 bg-white rounded-4 border">
                <i class="bi bi-inbox display-3 text-muted opacity-50 mb-3 d-block"></i>
                <h5 class="fw-bold text-dark">Chưa có chuyến giao nào trong mục này</h5>
                <p class="text-muted small mb-0">Khi hệ thống điều phối đơn hàng mới, danh sách sẽ tự động xuất hiện tại đây.</p>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<!-- ========================================================================
     MODALS CHO SHIPPER
     ======================================================================== -->

<!-- 1. Modal Hoàn Tất Giao Hàng & Upload PoD (Proof of Delivery) -->
<div class="modal fade" id="completeDeliveryModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg rounded-4">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title fw-bold d-flex align-items-center gap-2">
                    <i class="bi bi-camera-fill"></i> Xác Nhận Giao Thành Công
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/shipper/deliveries">
                <input type="hidden" name="action" value="complete">
                <input type="hidden" name="deliveryId" id="completeDeliveryId">
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <span class="text-muted small d-block">Mã vận đơn:</span>
                        <strong class="fs-6 text-dark" id="completeTrackingNumber"></strong>
                    </div>

                    <!-- COD Amount Check -->
                    <div id="completeCodInfoBox" class="alert alert-warning py-2 px-3 rounded-3 mb-3 d-flex align-items-center justify-content-between">
                        <div>
                            <i class="bi bi-cash-stack fs-5 me-1 text-danger"></i>
                            <strong>Số tiền COD cần thu từ khách:</strong>
                        </div>
                        <span class="fs-5 fw-bold text-danger" id="completeCodAmount">0₫</span>
                    </div>

                    <!-- Proof of Delivery Image Selection / Input -->
                    <div class="mb-3">
                        <label class="form-label fw-bold small text-dark">
                            <i class="bi bi-image text-success me-1"></i> Ảnh bằng chứng giao hàng (PoD):
                        </label>
                        <input type="text" class="form-control mb-2" name="proofImageUrl" id="proofImageUrlInput"
                               placeholder="Nhập link ảnh hoặc bấm chọn mẫu bên dưới"
                               value="https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=600">

                        <div class="text-muted fs-xs mb-2">Ảnh mẫu chụp thực tế đồng kiểm nhận quả tươi:</div>
                        <div class="d-flex gap-2">
                            <img src="https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=200&h=150&fit=crop"
                                 class="rounded border cursor-pointer" style="width: 70px; height: 50px; object-fit: cover;"
                                 alt="PoD 1" onclick="selectPoDPreset('https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=600')" title="Chọn mẫu ảnh 1">
                            <img src="https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=200&h=150&fit=crop"
                                 class="rounded border cursor-pointer" style="width: 70px; height: 50px; object-fit: cover;"
                                 alt="PoD 2" onclick="selectPoDPreset('https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=600')" title="Chọn mẫu ảnh 2">
                            <img src="https://images.unsplash.com/photo-1587334274328-64186a80aeee?w=200&h=150&fit=crop"
                                 class="rounded border cursor-pointer" style="width: 70px; height: 50px; object-fit: cover;"
                                 alt="PoD 3" onclick="selectPoDPreset('https://images.unsplash.com/photo-1587334274328-64186a80aeee?w=600')" title="Chọn mẫu ảnh 3">
                        </div>
                        <div class="mt-2 text-center">
                            <img id="podPreviewImg" src="https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=600" class="rounded border shadow-xs" style="max-height: 120px; object-fit: cover;">
                        </div>
                    </div>

                    <div class="form-check mb-2">
                        <input class="form-check-input" type="checkbox" id="checkQcInspection" checked required>
                        <label class="form-check-label small text-muted" for="checkQcInspection">
                            Khách hàng đã đồng kiểm tra cuống quả, độ tươi và đồng ý nhận hàng đầy đủ.
                        </label>
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary rounded-pill px-3" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-success fw-bold rounded-pill px-4">
                        <i class="bi bi-check2-circle me-1"></i> Hoàn Tất Chuyến Giao
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- 2. Modal Báo Giao Thất Bại & Kích Hoạt Hoàn Hàng (Record Failed Delivery) -->
<div class="modal fade" id="failedDeliveryModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg rounded-4">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title fw-bold d-flex align-items-center gap-2">
                    <i class="bi bi-exclamation-triangle-fill"></i> Báo Giao Hàng Thất Bại
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/shipper/deliveries">
                <input type="hidden" name="action" value="failed">
                <input type="hidden" name="deliveryId" id="failedDeliveryId">
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <span class="text-muted small d-block">Mã vận đơn:</span>
                        <strong class="fs-6 text-dark" id="failedTrackingNumber"></strong>
                    </div>

                    <div class="alert alert-warning py-2 px-3 small rounded-3 mb-3">
                        <i class="bi bi-info-circle me-1"></i> Khi xác nhận sự cố, đơn hàng sẽ chuyển sang trạng thái <strong>Giao thất bại</strong>.
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold small text-dark">Lý do giao thất bại / Khách từ chối:</label>
                        <select class="form-select" name="failureReason" required>
                            <option value="Quả dập nát / úng hỏng khi đồng kiểm">Quả dập nát / úng hỏng khi đồng kiểm</option>
                            <option value="Đứt gãy chuỗi bảo quản lạnh (quả héo, biến chất)">Đứt gãy chuỗi bảo quản lạnh (quả héo, biến chất)</option>
                            <option value="Giao sai loại quả hoặc thiếu số lượng">Giao sai loại quả hoặc thiếu số lượng</option>
                            <option value="Khách hàng đổi ý, từ chối nhận hoa quả">Khách hàng đổi ý, từ chối nhận hoa quả</option>
                            <option value="Không thể liên lạc được người nhận qua 3 cuộc gọi">Không thể liên lạc được người nhận qua 3 cuộc gọi</option>
                            <option value="Sai thông tin địa chỉ giao hàng">Sai thông tin địa chỉ giao hàng</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary rounded-pill px-3" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-danger fw-bold rounded-pill px-4" onclick="return confirm('Bạn chắc chắn muốn báo giao thất bại cho đơn này?')">
                        <i class="bi bi-arrow-return-left me-1"></i> Xác Nhận Trả Hàng
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- 3. Modal Phóng To Ảnh PoD -->
<div class="modal fade" id="imageViewModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content bg-transparent border-0 text-center">
            <div class="modal-body p-0 position-relative">
                <button type="button" class="btn-close btn-close-white position-absolute top-0 end-0 m-3 z-3" data-bs-dismiss="modal"></button>
                <img id="imageViewModalImg" src="" class="img-fluid rounded-4 shadow-lg border border-3 border-white">
            </div>
        </div>
    </div>
</div>

<!-- Bootstrap Bundle & Custom Shipper JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/shipper.js"></script>
</body>
</html>

