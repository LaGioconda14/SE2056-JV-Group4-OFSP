<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gốc Vườn - Giám Sát Đơn Hàng & Giao Vận Toàn Sàn (Orders & Deliveries)</title>

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
                    <button type="button" class="btn-export-list" onclick="window.print()">
                        <i class="bi bi-printer"></i>
                        <span>In danh sách đơn</span>
                    </button>
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn-add-admin text-decoration-none">
                        <i class="bi bi-graph-up"></i>
                        <span>Xem tổng quan tài chính</span>
                    </a>
                </div>
            </div>

            <!-- 2. 4 Summary Metric Cards (Dữ liệu thực từ DB) -->
            <div class="shops-summary-grid">
                <!-- Card 1: TỔNG ĐƠN TOÀN SÀN -->
                <div class="user-summary-card">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-1">
                            <span class="user-summary-title text-uppercase" style="letter-spacing: 0.04em;">TỔNG ĐƠN HÀNG</span>
                            <div class="user-summary-icon-box bg-green-subtle">
                                <i class="bi bi-bag-check-fill"></i>
                            </div>
                        </div>
                        <div class="user-summary-val">
                            <c:out value="${not empty orderStats.totalOrders ? orderStats.totalOrders : 0}"/> <span class="fs-6 fw-normal text-muted">đơn</span>
                        </div>
                    </div>
                    <div class="shop-kpi-sub-row">
                        <span>Tổng doanh thu sàn:</span>
                        <strong class="text-dark"><c:out value="${not empty orderStats.totalGmvFormatted ? orderStats.totalGmvFormatted : '0 ₫'}"/></strong>
                    </div>
                </div>

                <!-- Card 2: GIAO HỎA TỐC & CHUỖI LẠNH -->
                <div class="user-summary-card">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-1">
                            <span class="user-summary-title text-uppercase" style="letter-spacing: 0.04em;">ĐANG ĐI GIAO</span>
                            <div class="user-summary-icon-box" style="background: #e0f2fe; color: #0284c7;">
                                <i class="bi bi-snow"></i>
                            </div>
                        </div>
                        <div class="user-summary-val">
                            <c:out value="${not empty orderStats.shippingOrders ? orderStats.shippingOrders : 0}"/> <span class="badge" style="background: #dcfce7; color: #15803d; font-size: 0.65rem; vertical-align: middle;">Chuỗi lạnh</span>
                        </div>
                    </div>
                    <div class="shop-kpi-sub-row">
                        <span>Chuyến xe vận hành:</span>
                        <strong class="text-dark"><c:out value="${not empty orderStats.activeDeliveries ? orderStats.activeDeliveries : 0}"/> chuyến</strong>
                    </div>
                </div>

                <!-- Card 3: ĐANG XỬ LÝ -->
                <div class="user-summary-card">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-1">
                            <span class="user-summary-title text-uppercase" style="letter-spacing: 0.04em;">ĐANG XỬ LÝ / ĐÓNG GÓI</span>
                            <div class="user-summary-icon-box" style="background: #fef3c7; color: #d97706;">
                                <i class="bi bi-box-seam"></i>
                            </div>
                        </div>
                        <div class="user-summary-val text-warning">
                            <c:out value="${not empty orderStats.processingOrders ? orderStats.processingOrders : 0}"/> <span class="fs-6 fw-normal text-muted">đơn</span>
                        </div>
                    </div>
                    <div class="shop-kpi-sub-row">
                        <span>Kiện con các shop:</span>
                        <strong class="text-dark"><c:out value="${not empty orderStats.totalSubOrders ? orderStats.totalSubOrders : 0}"/> kiện</strong>
                    </div>
                </div>

                <!-- Card 4: HOÀN TẤT GIAO HÀNG -->
                <div class="user-summary-card">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-1">
                            <span class="user-summary-title text-uppercase" style="letter-spacing: 0.04em;">GIAO THÀNH CÔNG</span>
                            <div class="user-summary-icon-box bg-green-subtle">
                                <i class="bi bi-check-circle-fill"></i>
                            </div>
                        </div>
                        <div class="user-summary-val text-success">
                            <c:out value="${not empty orderStats.completedOrders ? orderStats.completedOrders : 0}"/> <span class="fs-6 fw-normal text-muted">đơn</span>
                        </div>
                    </div>
                    <div class="shop-kpi-sub-row">
                        <span>Đã hủy / thất bại:</span>
                        <strong class="text-danger"><c:out value="${not empty orderStats.cancelledOrders ? orderStats.cancelledOrders : 0}"/> đơn</strong>
                    </div>
                </div>
            </div>

            <!-- 3. Segmented Navigation Tabs (Thực tế từ DB) -->
            <div class="users-rbac-tabs">
                <a href="${pageContext.request.contextPath}/admin/orders?status=ALL" class="rbac-tab-item ${selectedStatus == 'ALL' || empty selectedStatus ? 'active' : ''}">
                    <span>Tất cả đơn</span>
                    <span class="rbac-badge"><c:out value="${not empty orderStats.totalOrders ? orderStats.totalOrders : 0}"/></span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/orders?status=PROCESSING" class="rbac-tab-item ${selectedStatus == 'PROCESSING' ? 'active' : ''}">
                    <span>Đang xử lý</span>
                    <span class="rbac-badge"><c:out value="${not empty orderStats.processingOrders ? orderStats.processingOrders : 0}"/></span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/orders?status=SHIPPING" class="rbac-tab-item ${selectedStatus == 'SHIPPING' ? 'active' : ''}">
                    <span>Đang giao hàng</span>
                    <span class="rbac-badge"><c:out value="${not empty orderStats.shippingOrders ? orderStats.shippingOrders : 0}"/></span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/orders?status=COMPLETED" class="rbac-tab-item ${selectedStatus == 'COMPLETED' ? 'active' : ''}">
                    <span>Đã giao thành công</span>
                    <span class="rbac-badge" style="background: #dcfce7; color: #15803d;"><c:out value="${not empty orderStats.completedOrders ? orderStats.completedOrders : 0}"/></span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/orders?status=CANCELLED" class="rbac-tab-item ${selectedStatus == 'CANCELLED' ? 'active' : ''}">
                    <span>Đã hủy đơn</span>
                    <span class="rbac-badge" style="background: #fee2e2; color: #dc2626;"><c:out value="${not empty orderStats.cancelledOrders ? orderStats.cancelledOrders : 0}"/></span>
                </a>
            </div>

            <!-- 4. Filter Toolbar -->
            <form method="GET" action="${pageContext.request.contextPath}/admin/orders" class="users-filter-card">
                <input type="hidden" name="status" value="${selectedStatus}">
                <div class="users-search-pill">
                    <i class="bi bi-search"></i>
                    <input type="text" name="search" id="orderSearchInput" value="<c:out value='${searchKeyword}'/>" placeholder="Tìm theo Mã đơn (ORD-...), Người nhận, Số điện thoại, Địa chỉ...">
                </div>

                <div class="users-dropdown-filters">
                    <button type="submit" class="btn btn-sm btn-success px-3 py-1.5 rounded-3 fw-bold">
                        <i class="bi bi-search me-1"></i> Tìm kiếm
                    </button>
                    <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-sm btn-light border d-inline-flex align-items-center gap-1 text-muted" style="border-radius: 8px; font-size: 0.75rem; padding: 0.42rem 0.75rem;">
                        <i class="bi bi-arrow-counterclockwise"></i>
                        <span>Đặt lại lọc</span>
                    </a>
                </div>
            </form>

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
                                            <strong class="text-dark" style="font-size: 0.8rem;"><c:out value="${not empty o.shopNames ? o.shopNames : 'Gian hàng sàn'}"/></strong>
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
                <!-- Left (2/3): Tình Trạng Điều Phối Vận Hành Thực Tế -->
                <div class="sop-process-card">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-2">
                            <div class="d-flex align-items-center gap-2">
                                <div class="kpi-icon-box bg-green-subtle">
                                    <i class="bi bi-truck text-success"></i>
                                </div>
                                <div>
                                    <h3 class="role-matrix-title mb-0">Tình Trạng Điều Phối Đơn Hàng Sàn</h3>
                                    <div class="text-muted" style="font-size: 0.7rem;">Cập nhật theo dữ liệu đơn hàng và vận chuyển thời gian thực từ cơ sở dữ liệu</div>
                                </div>
                            </div>
                            <span class="status-pill-green" style="font-size: 0.65rem;">● Dữ liệu thực tế</span>
                        </div>

                        <!-- 3 Real Metric Boxes -->
                        <div class="sop-steps-grid">
                            <!-- Box 1: Đang chuẩn bị -->
                            <div class="sop-step-box">
                                <div>
                                    <span class="user-summary-title">Đơn đang đóng gói / xử lý</span>
                                    <div class="d-flex align-items-baseline gap-2 mt-1">
                                        <strong class="fs-4 text-warning"><c:out value="${not empty orderStats.processingOrders ? orderStats.processingOrders : 0}"/></strong>
                                        <span class="text-muted" style="font-size: 0.72rem;">đơn</span>
                                    </div>
                                </div>
                                <div class="mt-2 pt-2 border-top text-muted" style="font-size: 0.68rem; border-color: #e2e8f0 !important;">
                                    <a href="${pageContext.request.contextPath}/admin/orders?status=PROCESSING" class="text-decoration-none text-success fw-bold">Xem danh sách xử lý &rarr;</a>
                                </div>
                            </div>

                            <!-- Box 2: Đang giao -->
                            <div class="sop-step-box">
                                <div>
                                    <span class="user-summary-title">Đơn đang trên đường giao</span>
                                    <div class="d-flex align-items-baseline gap-2 mt-1">
                                        <strong class="fs-4 text-primary"><c:out value="${not empty orderStats.shippingOrders ? orderStats.shippingOrders : 0}"/></strong>
                                        <span class="text-muted" style="font-size: 0.72rem;">đơn</span>
                                    </div>
                                </div>
                                <div class="mt-2 pt-2 border-top text-muted" style="font-size: 0.68rem; border-color: #e2e8f0 !important;">
                                    <a href="${pageContext.request.contextPath}/admin/orders?status=SHIPPING" class="text-decoration-none text-primary fw-bold">Xem đơn đang giao &rarr;</a>
                                </div>
                            </div>

                            <!-- Box 3: Giao thành công -->
                            <div class="sop-step-box">
                                <div>
                                    <span class="user-summary-title">Đã giao thành công</span>
                                    <div class="d-flex align-items-baseline gap-2 mt-1">
                                        <strong class="fs-4 text-success"><c:out value="${not empty orderStats.completedOrders ? orderStats.completedOrders : 0}"/></strong>
                                        <span class="text-muted" style="font-size: 0.72rem;">đơn</span>
                                    </div>
                                </div>
                                <div class="mt-2 pt-2 border-top text-muted" style="font-size: 0.68rem; border-color: #e2e8f0 !important;">
                                    <a href="${pageContext.request.contextPath}/admin/orders?status=COMPLETED" class="text-decoration-none text-success fw-bold">Xem đơn hoàn tất &rarr;</a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Policy Banner -->
                    <div class="d-flex align-items-center justify-content-between p-3 rounded" style="background: #f8fafc; border: 1px solid #e2e8f0;">
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-shield-check text-success fs-5"></i>
                            <div>
                                <strong class="text-dark" style="font-size: 0.78rem;">Chính Sách Vận Hành Chuỗi Lạnh Sàn Gốc Vườn</strong>
                                <div class="text-muted" style="font-size: 0.7rem;">Giám sát thời gian thực từ khâu thu hái, đóng gói đá gel tới bưu tá giao tận tay khách hàng.</div>
                            </div>
                        </div>
                        <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-sm btn-light border fw-bold text-dark px-3" style="font-size: 0.72rem; border-radius: 8px;">
                            Xem Báo Cáo
                        </a>
                    </div>
                </div>

                <!-- Right (1/3): Thống Kê Nhanh Vận Hành -->
                <div class="quick-preview-card">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-3">
                            <div class="d-flex align-items-center gap-2">
                                <i class="bi bi-bar-chart-line-fill text-success fs-5"></i>
                                <div>
                                    <strong class="text-dark" style="font-size: 0.82rem;">Chỉ Số Khối Lượng Đơn</strong>
                                    <div class="text-muted" style="font-size: 0.68rem;">Tổng quan tỷ lệ hoàn tất giao nhận</div>
                                </div>
                            </div>
                            <span class="badge bg-light text-dark border" style="font-size: 0.65rem;">Toàn sàn</span>
                        </div>

                        <div class="d-flex flex-column gap-2 mb-3">
                            <div class="p-2.5 rounded-3 border bg-light">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <span class="small text-muted" style="font-size: 0.72rem;">Tổng giá trị giao dịch (GMV)</span>
                                    <strong class="text-success" style="font-size: 0.85rem;"><c:out value="${not empty orderStats.totalGmvFormatted ? orderStats.totalGmvFormatted : '0 ₫'}"/></strong>
                                </div>
                            </div>
                            <div class="p-2.5 rounded-3 border bg-light">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <span class="small text-muted" style="font-size: 0.72rem;">Kiện hàng con các shop</span>
                                    <strong class="text-dark" style="font-size: 0.82rem;"><c:out value="${not empty orderStats.totalSubOrders ? orderStats.totalSubOrders : 0}"/> kiện</strong>
                                </div>
                            </div>
                            <div class="p-2.5 rounded-3 border bg-light">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <span class="small text-muted" style="font-size: 0.72rem;">Đơn đã hủy</span>
                                    <strong class="text-danger" style="font-size: 0.82rem;"><c:out value="${not empty orderStats.cancelledOrders ? orderStats.cancelledOrders : 0}"/> đơn</strong>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="d-flex align-items-center justify-content-between pt-2 border-top" style="border-color: #f1f5f9 !important; font-size: 0.72rem;">
                        <span class="text-muted">
                            <i class="bi bi-info-circle text-success me-1"></i> Trạng thái đồng bộ tự động
                        </span>
                        <a href="${pageContext.request.contextPath}/admin/orders" class="text-success text-decoration-none fw-semibold">
                            Làm mới dữ liệu &rarr;
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
