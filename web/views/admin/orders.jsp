<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FreshFruit - Giám Sát Đơn Hàng & Giao Vận Toàn Sàn (Orders & Deliveries)</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css?v=14">
</head>
<body class="admin-body">

<div class="admin-wrapper">
    <jsp:include page="layout/sidebar.jsp">
        <jsp:param name="activePage" value="orders" />
    </jsp:include>

    <div class="admin-main">
        <jsp:include page="layout/header.jsp" />

        <main class="admin-page-content">
            <!-- 1. Breadcrumbs & Header -->
            <div class="users-page-header">
                <div>
                    <nav aria-label="breadcrumb" class="mb-1" style="font-size: 0.72rem;">
                        <ol class="breadcrumb mb-0">
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard" class="text-muted text-decoration-none">Quản trị sàn</a></li>
                            <li class="breadcrumb-item text-muted">Quản trị vận hành (Governance)</li>
                            <li class="breadcrumb-item active text-success fw-bold" aria-current="page">Đơn hàng & Giao vận</li>
                        </ol>
                    </nav>
                    <h1 class="users-header-title">Giám Sát Đơn Hàng & Giao Vận Toàn Sàn</h1>
                    <p class="users-header-desc">Điều phối và giám sát luồng đơn hàng đa nhà vườn, đối tác vận chuyển hỏa tốc/chuỗi lạnh và tỷ lệ hoàn tất giao nhận.</p>
                </div>
                <div class="users-header-actions">
                    <button type="button" class="btn-export-list" onclick="alert('Đang xuất báo cáo vận chuyển & SLA chuỗi lạnh (.Excel)...');">
                        <i class="bi bi-download"></i>
                        <span>Xuất báo cáo vận chuyển</span>
                    </button>
                    <button type="button" class="btn-add-admin" onclick="alert('Đang mở trang cài đặt kết nối đối tác giao vận & API...');">
                        <i class="bi bi-truck"></i>
                        <span>Cấu hình đối tác ship</span>
                    </button>
                </div>
            </div>

            <!-- 2. 4 Summary Metric Cards -->
            <div class="shops-summary-grid">
                <!-- Card 1: TỔNG ĐƠN HÔM NAY -->
                <div class="user-summary-card">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-1">
                            <span class="user-summary-title text-uppercase" style="letter-spacing: 0.04em;">TỔNG ĐƠN HÔM NAY</span>
                            <div class="user-summary-icon-box bg-green-subtle">
                                <i class="bi bi-bag-check-fill"></i>
                            </div>
                        </div>
                        <div class="user-summary-val">
                            542 <span class="badge-kpi-growth" style="font-size: 0.68rem; vertical-align: middle;">+18%</span>
                        </div>
                    </div>
                    <div class="shop-kpi-sub-row">
                        <span>Tổng giá trị hàng:</span>
                        <strong class="text-dark">₫28,450,000</strong>
                    </div>
                </div>

                <!-- Card 2: GIAO HỎA TỐC (COLD-CHAIN) -->
                <div class="user-summary-card">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-1">
                            <span class="user-summary-title text-uppercase" style="letter-spacing: 0.04em;">GIAO HỎA TỐC (COLD-CHAIN)</span>
                            <div class="user-summary-icon-box" style="background: #e0f2fe; color: #0284c7;">
                                <i class="bi bi-snow"></i>
                            </div>
                        </div>
                        <div class="user-summary-val">
                            128 <span class="badge" style="background: #dcfce7; color: #15803d; font-size: 0.65rem; vertical-align: middle;">Chuyên dụng</span>
                        </div>
                    </div>
                    <div class="shop-kpi-sub-row">
                        <span>Tỷ lệ đúng giờ:</span>
                        <strong class="text-dark">97.4%</strong>
                    </div>
                </div>

                <!-- Card 3: CẦN HỖ TRỢ / CHẬM TRỄ -->
                <div class="user-summary-card">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-1">
                            <span class="user-summary-title text-uppercase" style="letter-spacing: 0.04em;">CẦN HỖ TRỢ / CHẬM TRỄ</span>
                            <div class="user-summary-icon-box" style="background: #fee2e2; color: #dc2626;">
                                <i class="bi bi-broadcast"></i>
                            </div>
                        </div>
                        <div class="user-summary-val text-danger">
                            06 <span class="badge" style="background: #fee2e2; color: #dc2626; font-size: 0.65rem; vertical-align: middle;">Ưu tiên xử lý</span>
                        </div>
                    </div>
                    <div class="shop-kpi-sub-row">
                        <span>Cảnh báo nhiệt độ & SLA:</span>
                        <strong class="text-danger">Cần can thiệp</strong>
                    </div>
                </div>

                <!-- Card 4: TỶ LỆ GIAO THÀNH CÔNG -->
                <div class="user-summary-card">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-1">
                            <span class="user-summary-title text-uppercase" style="letter-spacing: 0.04em;">TỶ LỆ GIAO THÀNH CÔNG</span>
                            <div class="user-summary-icon-box bg-green-subtle">
                                <i class="bi bi-check-circle-fill"></i>
                            </div>
                        </div>
                        <div class="user-summary-val">
                            96.8% <span class="text-muted fw-normal" style="font-size: 0.68rem;">Tháng 05</span>
                        </div>
                    </div>
                    <div class="shop-kpi-sub-row">
                        <span>Đã hoàn tất:</span>
                        <strong class="text-dark">3,720 / 3,842 đơn</strong>
                    </div>
                </div>
            </div>

            <!-- 3. Segmented Navigation Tabs -->
            <div class="users-rbac-tabs">
                <a href="${pageContext.request.contextPath}/admin/orders?status=ALL" class="rbac-tab-item active">
                    <span>Tất cả đơn</span>
                    <span class="rbac-badge">542</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/orders?status=PICKING" class="rbac-tab-item">
                    <span>Chờ lấy hàng từ vườn</span>
                    <span class="rbac-badge">48</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/orders?status=DELIVERING" class="rbac-tab-item">
                    <span>Đang giao hàng</span>
                    <span class="rbac-badge">128</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/orders?status=COMPLETED" class="rbac-tab-item">
                    <span>Đã giao thành công</span>
                    <span class="rbac-badge" style="background: #dcfce7; color: #15803d;">342</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/orders?status=FAILED" class="rbac-tab-item">
                    <span>Giao thất bại / Hoàn trả</span>
                </a>
            </div>

            <!-- 4. Filter Toolbar -->
            <div class="users-filter-card">
                <div class="users-search-pill">
                    <i class="bi bi-search"></i>
                    <input type="text" id="orderSearchInput" placeholder="Tìm theo Mã đơn (ORD-...), Shop bán, Khách hàng">
                </div>

                <div class="users-dropdown-filters">
                    <!-- Dropdown: ĐVVC -->
                    <div class="dropdown">
                        <button class="filter-select-btn dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="bi bi-truck text-muted"></i>
                            <span>Đối tác: Tất cả ĐVVC</span>
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end shadow-sm" style="font-size: 0.78rem;">
                            <li><a class="dropdown-item fw-bold" href="#">Tất cả đơn vị vận chuyển</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="#">GrabExpress Hỏa Tốc (Xe bảo ôn)</a></li>
                            <li><a class="dropdown-item" href="#">Ahamove Fresh (Thùng lạnh)</a></li>
                            <li><a class="dropdown-item" href="#">ViettelPost Lạnh (Liên tỉnh)</a></li>
                            <li><a class="dropdown-item" href="#">GHTK Tiêu chuẩn</a></li>
                        </ul>
                    </div>

                    <!-- Dropdown: Nông sản -->
                    <div class="dropdown">
                        <button class="filter-select-btn dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="bi bi-apple text-muted"></i>
                            <span>Nông sản...</span>
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end shadow-sm" style="font-size: 0.78rem;">
                            <li><a class="dropdown-item fw-bold" href="#">Tất cả chủng loại</a></li>
                            <li><a class="dropdown-item" href="#">Trái cây tươi (Hàng dễ hỏng)</a></li>
                            <li><a class="dropdown-item" href="#">Giỏ quà biếu cao cấp</a></li>
                            <li><a class="dropdown-item" href="#">Trái cây sấy khô</a></li>
                        </ul>
                    </div>

                    <button type="button" class="btn btn-sm btn-light border d-inline-flex align-items-center gap-1 text-muted" onclick="location.reload();" style="border-radius: 8px; font-size: 0.75rem; padding: 0.42rem 0.75rem;">
                        <i class="bi bi-arrow-counterclockwise"></i>
                        <span>Đặt lại lọc</span>
                    </button>
                </div>
            </div>

            <!-- 5. Orders Table -->
            <div class="shops-table-container">
                <table class="shops-modern-table">
                    <thead>
                        <tr>
                            <th>MÃ ĐƠN & THỜI GIAN</th>
                            <th>GIAN HÀNG / NHÀ VƯỜN</th>
                            <th>KHÁCH HÀNG & ĐỊA CHỈ</th>
                            <th>SẢN PHẨM & GIÁ TRỊ</th>
                            <th>VẬN CHUYỂN / BẢO QUẢN</th>
                            <th>TRẠNG THÁI</th>
                        </tr>
                    </thead>
                    <tbody id="ordersTableBody">
                        <c:forEach items="${ordersList}" var="o">
                            <tr>
                                <td>
                                    <div>
                                        <span class="order-code-green">${o.orderCode}</span>
                                        <div class="text-muted" style="font-size: 0.68rem;"><i class="bi bi-clock"></i> ID: #${o.orderId}</div>
                                        <span class="payment-tag payment-tag-online mt-1">${o.paymentMethod}</span>
                                    </div>
                                </td>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <div class="user-summary-icon-box bg-green-subtle" style="width: 32px; height: 32px; font-size: 0.9rem;">
                                            <i class="bi bi-shop text-success"></i>
                                        </div>
                                        <div>
                                            <strong class="text-dark" style="font-size: 0.8rem;">Gian Hàng Sàn</strong>
                                            <div class="text-muted" style="font-size: 0.68rem;"><i class="bi bi-geo-alt"></i> ${o.city}</div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div>
                                        <strong class="text-dark" style="font-size: 0.8rem;">${o.customerName}</strong>
                                        <div class="text-muted text-truncate" style="font-size: 0.68rem; max-width: 170px;">${o.city}</div>
                                    </div>
                                </td>
                                <td>
                                    <div>
                                        <div class="d-flex align-items-center gap-2 mt-1">
                                            <strong class="text-success" style="font-size: 0.85rem;">${o.finalAmountFormatted}</strong>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div>
                                        <div class="fw-semibold text-dark" style="font-size: 0.76rem;">● Giao hàng tiêu chuẩn</div>
                                        <div class="mt-1">
                                            <span class="ship-spec-box ship-spec-blue">
                                                <i class="bi bi-snow"></i> Chuỗi lạnh bảo quản
                                            </span>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div>
                                        <c:choose>
                                            <c:when test="${o.orderStatus == 'COMPLETED'}">
                                                <span class="status-badge-delivered"><i class="bi bi-check-circle-fill"></i> Hoàn tất</span>
                                            </c:when>
                                            <c:when test="${o.orderStatus == 'SHIPPING'}">
                                                <span class="status-badge-shipping"><i class="bi bi-truck"></i> Đang giao</span>
                                            </c:when>
                                            <c:when test="${o.orderStatus == 'CANCELLED'}">
                                                <span class="status-badge-failed"><i class="bi bi-x-circle-fill"></i> Đã hủy</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-badge-sorting"><i class="bi bi-hourglass-split"></i> ${o.orderStatus}</span>
                                            </c:otherwise>
                                        </c:choose>
                                        <div class="text-muted mt-1" style="font-size: 0.68rem;">${o.paymentStatus}</div>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty ordersList}">
                            <tr>
                                <td colspan="6" class="text-center text-muted py-4">Chưa có đơn hàng nào trong hệ thống.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>

                <!-- Pagination Footer -->
                <div class="users-table-footer">
                    <span>Tổng cộng <strong>${not empty ordersList ? ordersList.size() : 0}</strong> đơn hàng trong danh sách</span>
                </div>
            </div>

            <!-- 6. Bottom Split Section -->
            <div class="bottom-split-grid">
                <!-- Left (2/3): SLA Chuỗi Lạnh & Giao Vận Nông Sản -->
                <div class="sop-process-card">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-2">
                            <div class="d-flex align-items-center gap-2">
                                <div class="kpi-icon-box bg-green-subtle">
                                    <i class="bi bi-file-earmark-ruled-fill text-success"></i>
                                </div>
                                <div>
                                    <h3 class="role-matrix-title mb-0">Chỉ Số SLA Chuỗi Lạnh & Giao Vận Nông Sản</h3>
                                    <div class="text-muted" style="font-size: 0.7rem;">Dữ liệu tổng hợp theo chu kỳ 24h trên toàn bộ 63 tỉnh thành</div>
                                </div>
                            </div>
                            <span class="status-pill-green" style="font-size: 0.65rem;">● Thời gian thực</span>
                        </div>

                        <!-- 3 SLA Metric Boxes -->
                        <div class="sop-steps-grid">
                            <!-- Box 1 -->
                            <div class="sop-step-box">
                                <div>
                                    <span class="user-summary-title">Lấy hàng đúng hẹn từ vườn</span>
                                    <div class="d-flex align-items-baseline gap-2 mt-1">
                                        <strong class="fs-4 text-dark">94.2%</strong>
                                        <span class="text-success fw-bold" style="font-size: 0.72rem;"><i class="bi bi-arrow-up-short"></i>1.5%</span>
                                    </div>
                                </div>
                                <div class="mt-2 pt-2 border-top text-muted" style="font-size: 0.68rem; border-color: #e2e8f0 !important;">
                                    Mục tiêu quốc gia > 92.0%
                                </div>
                            </div>

                            <!-- Box 2 -->
                            <div class="sop-step-box">
                                <div>
                                    <span class="user-summary-title">Đạt chuẩn giữ nhiệt/đá gel</span>
                                    <div class="d-flex align-items-baseline gap-2 mt-1">
                                        <strong class="fs-4 text-dark">98.6%</strong>
                                        <span class="text-success fw-bold" style="font-size: 0.72rem;"><i class="bi bi-arrow-up-short"></i>0.8%</span>
                                    </div>
                                </div>
                                <div class="mt-2 pt-2 border-top text-muted" style="font-size: 0.68rem; border-color: #e2e8f0 !important;">
                                    Kiểm tra tự động bằng AI camera
                                </div>
                            </div>

                            <!-- Box 3 -->
                            <div class="sop-step-box">
                                <div>
                                    <span class="user-summary-title">Thời gian giao nội thành</span>
                                    <div class="d-flex align-items-baseline gap-2 mt-1">
                                        <strong class="fs-4 text-dark">42</strong> <span class="fs-6 fw-normal text-muted">phút</span>
                                    </div>
                                    <div class="progress mt-2" style="height: 4px; background: #e2e8f0;">
                                        <div class="progress-bar" style="width: 70%; background: #3b82f6;"></div>
                                    </div>
                                </div>
                                <div class="mt-2 pt-2 border-top text-muted" style="font-size: 0.68rem; border-color: #e2e8f0 !important;">
                                    Nhanh hơn 12 phút so với tháng trước
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Policy Banner -->
                    <div class="d-flex align-items-center justify-content-between p-3 rounded" style="background: #f8fafc; border: 1px solid #e2e8f0;">
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-shield-check text-success fs-5"></i>
                            <div>
                                <strong class="text-dark" style="font-size: 0.78rem;">Chính Sách Cam Kết Độ Tươi & Bồi Thường Nông Sản</strong>
                                <div class="text-muted" style="font-size: 0.7rem;">Sàn FreshFruit tự động hoàn tiền 100% nếu trái cây dập hỏng do chậm giao > 90 phút.</div>
                            </div>
                        </div>
                        <a href="javascript:void(0)" onclick="alert('Đang mở quy chế bảo quản chuỗi lạnh SLA...');" class="btn btn-sm btn-light border fw-bold text-dark px-3" style="font-size: 0.72rem; border-radius: 8px;">
                            Xem quy chế SLA
                        </a>
                    </div>
                </div>

                <!-- Right (1/3): Cảnh Báo Nóng Trái Cây Tươi -->
                <div class="quick-preview-card">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-3">
                            <div class="d-flex align-items-center gap-2">
                                <i class="bi bi-bell-fill text-danger fs-5"></i>
                                <div>
                                    <strong class="text-dark" style="font-size: 0.82rem;">Cảnh Báo Nóng Trái Cây Tươi</strong>
                                    <div class="text-muted" style="font-size: 0.68rem;">Đơn hàng cần đẩy gấp trước 12:00 trưa</div>
                                </div>
                            </div>
                            <span class="badge" style="background: #fee2e2; color: #dc2626; font-size: 0.65rem;">3 đơn cấp bách</span>
                        </div>

                        <!-- 3 Alerts -->
                        <div class="d-flex flex-column gap-2 mb-3">
                            <!-- Alert 1 -->
                            <div class="alert-item-card">
                                <div>
                                    <div class="d-flex align-items-center gap-1">
                                        <strong class="text-dark" style="font-size: 0.76rem;">ORD-98228</strong>
                                        <span class="text-danger fw-bold" style="font-size: 0.68rem;">Chậm > 45 phút</span>
                                    </div>
                                    <div class="text-muted" style="font-size: 0.68rem;">Giỏ quà biếu ngoại nhập • Shipper kẹt xe Ba Đình</div>
                                </div>
                                <button type="button" class="btn btn-sm btn-success fw-bold px-2 py-1" style="background: #15803d; border-color: #15803d; font-size: 0.68rem; border-radius: 6px; white-space: nowrap;" onclick="alert('Đã chuyển đơn sang tài xế dự phòng!');">
                                    Tái điều phối
                                </button>
                            </div>

                            <!-- Alert 2 -->
                            <div class="alert-item-card">
                                <div>
                                    <div class="d-flex align-items-center gap-1">
                                        <strong class="text-dark" style="font-size: 0.76rem;">ORD-98215</strong>
                                        <span class="text-danger fw-bold" style="font-size: 0.68rem;">Nhiệt độ cảnh báo 28°C</span>
                                    </div>
                                    <div class="text-muted" style="font-size: 0.68rem;">Dâu tây Mộc Châu • Yêu cầu shipper bổ sung đá gel</div>
                                </div>
                                <button type="button" class="btn btn-sm btn-light border fw-bold px-2 py-1 text-primary" style="font-size: 0.68rem; border-radius: 6px; white-space: nowrap;" onclick="alert('Đang kết nối cuộc gọi tới Shipper...');">
                                    Gọi Shipper
                                </button>
                            </div>

                            <!-- Alert 3 -->
                            <div class="alert-item-card">
                                <div>
                                    <div class="d-flex align-items-center gap-1">
                                        <strong class="text-dark" style="font-size: 0.76rem;">ORD-98204</strong>
                                        <span class="text-muted fw-bold" style="font-size: 0.68rem;">Sai định vị nhà vườn</span>
                                    </div>
                                    <div class="text-muted" style="font-size: 0.68rem;">Vườn Bơ Sáp DakLak • Tài xế không tìm thấy điểm lấy</div>
                                </div>
                                <button type="button" class="btn btn-sm btn-light border fw-bold px-2 py-1 text-primary" style="font-size: 0.68rem; border-radius: 6px; white-space: nowrap;" onclick="alert('Đã gửi SMS tọa độ Google Maps cho tài xế!');">
                                    Gửi tọa độ
                                </button>
                            </div>
                        </div>
                    </div>

                    <div class="d-flex align-items-center justify-content-between pt-2 border-top" style="border-color: #f1f5f9 !important; font-size: 0.72rem;">
                        <span class="text-muted">
                            <i class="bi bi-headset text-success"></i> Bộ phận trực giao nhận sàn: <strong>1900 8892</strong>
                        </span>
                        <a href="javascript:void(0)" onclick="alert('Đang mở nhật ký can thiệp giao nhận...');" class="text-muted text-decoration-none">
                            Lịch sử can thiệp
                        </a>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/admin.js?v=14"></script>
</body>
</html>
