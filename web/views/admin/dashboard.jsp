<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gốc Vườn - Platform Admin Dashboard</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css?v=10">
</head>
<body class="admin-body">

<div class="admin-wrapper">
    <jsp:include page="layout/sidebar.jsp">
        <jsp:param name="activePage" value="dashboard" />
    </jsp:include>

    <div class="admin-main">
        <jsp:include page="layout/header.jsp" />

        <main class="admin-page-content">
            <!-- 1. Simple Dashboard Header -->
            <div class="d-flex flex-wrap align-items-center justify-content-between gap-3 mb-4">
                <div>
                    <h1 class="h4 fw-bold text-dark mb-1">Tổng Quan Quản Trị Hệ Thống</h1>
                    <p class="text-muted small mb-0">Giám sát doanh số, đơn hàng và các hoạt động vận hành trên sàn Gốc Vườn.</p>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <span class="badge bg-white text-dark border px-3 py-2 shadow-sm rounded-pill fw-semibold">
                        <i class="bi bi-shop text-success me-1"></i> ${stats.activeShopsCount} Gian hàng hoạt động
                    </span>
                    <span class="badge bg-white text-dark border px-3 py-2 shadow-sm rounded-pill fw-semibold">
                        <i class="bi bi-people text-primary me-1"></i> ${stats.activeUsersFormatted} Người dùng
                    </span>
                </div>
            </div>

            <!-- 2. 4 Core KPI Metrics Cards -->
            <div class="kpi-grid-4">
                <!-- Card 1: Tổng GMV Toàn Sàn -->
                <div class="stat-card-kpi">
                    <div class="d-flex align-items-center justify-content-between mb-2">
                        <span class="kpi-label">TỔNG GMV TOÀN SÀN</span>
                        <div class="kpi-icon-box bg-green-subtle"><i class="bi bi-cash-stack"></i></div>
                    </div>
                    <div class="kpi-main-val">${stats.totalGmvFullFormatted}</div>
                    <div class="text-muted small mt-2 pt-2 border-top" style="border-color: #f1f5f9 !important;">
                        Doanh số từ ${stats.activeShopsCount} gian hàng hoạt động
                    </div>
                </div>

                <!-- Card 2: Doanh Thu Hoa Hồng Sàn -->
                <div class="stat-card-kpi">
                    <div class="d-flex align-items-center justify-content-between mb-2">
                        <span class="kpi-label">DOANH THU HOA HỒNG SÀN</span>
                        <div class="kpi-icon-box bg-green-subtle"><i class="bi bi-wallet2"></i></div>
                    </div>
                    <div class="kpi-main-val text-success">${stats.netCommissionFullFormatted}</div>
                    <div class="text-muted small mt-2 pt-2 border-top" style="border-color: #f1f5f9 !important;">
                        Tỷ lệ hoa hồng trung bình: <strong class="text-dark">${stats.avgTakeRate}%</strong>
                    </div>
                </div>

                <!-- Card 3: Tổng Đơn Hàng Đã Xử Lý -->
                <div class="stat-card-kpi">
                    <div class="d-flex align-items-center justify-content-between mb-2">
                        <span class="kpi-label">TỔNG ĐƠN HÀNG ĐÃ XỬ LÝ</span>
                        <div class="kpi-icon-box bg-purple-subtle"><i class="bi bi-bag-check-fill"></i></div>
                    </div>
                    <div class="kpi-main-val">${stats.totalOrdersFormatted} <span class="fs-6 fw-normal text-muted">đơn</span></div>
                    <div class="text-muted small mt-2 pt-2 border-top" style="border-color: #f1f5f9 !important;">
                        Tỷ lệ hoàn tất: <strong class="text-dark">${stats.orderCompletionRate}%</strong>
                    </div>
                </div>

                <!-- Card 4: Tài Khoản Hoạt Động -->
                <div class="stat-card-kpi">
                    <div class="d-flex align-items-center justify-content-between mb-2">
                        <span class="kpi-label">TÀI KHOẢN HOẠT ĐỘNG</span>
                        <div class="kpi-icon-box bg-green-subtle"><i class="bi bi-people-fill"></i></div>
                    </div>
                    <div class="kpi-main-val">${stats.activeUsersFormatted}</div>
                    <div class="text-muted small mt-2 pt-2 border-top" style="border-color: #f1f5f9 !important;">
                        ${stats.totalBuyersCount} khách mua &bull; ${stats.totalUsersCount} tổng tài khoản
                    </div>
                </div>
            </div>

            <!-- 3. Action Cards (Khối Cần Xử Lý) -->
            <div class="action-cards-grid-3">
                <!-- Card 1: Xét Duyệt Gian Hàng -->
                <div class="action-card card-orange">
                    <div>
                        <div class="action-card-header">
                            <span class="action-tag-pill action-tag-orange">
                                <i class="bi bi-shop text-warning-emphasis"></i> XÉT DUYỆT GIAN HÀNG
                            </span>
                            <span class="badge-counter badge-counter-orange">${stats.pendingKycCount} Đang Chờ</span>
                        </div>
                        <h3 class="action-card-title">${stats.pendingKycCount} Hồ sơ mở Shop đang chờ duyệt</h3>
                        <p class="action-card-desc">Kiểm tra thông tin thương nhân và pháp lý trước khi cấp quyền bán lẻ.</p>
                    </div>
                    <div class="action-card-footer mt-3">
                        <a href="${pageContext.request.contextPath}/admin/shops?status=PENDING" class="btn-action-pill btn-action-orange text-decoration-none">
                            Xét duyệt Shop (${stats.pendingKycCount}) →
                        </a>
                    </div>
                </div>

                <!-- Card 2: Kiểm Duyệt Sản Phẩm -->
                <div class="action-card card-red">
                    <div>
                        <div class="action-card-header">
                            <span class="action-tag-pill action-tag-red">
                                <i class="bi bi-shield-exclamation text-danger"></i> KIỂM DUYỆT SẢN PHẨM
                            </span>
                            <span class="badge-counter badge-counter-red">${stats.flaggedProductsCount} Cần Xử Lý</span>
                        </div>
                        <h3 class="action-card-title">${stats.flaggedProductsCount} Sản phẩm cần kiểm định</h3>
                        <p class="action-card-desc">Thẩm định chứng nhận nguồn gốc xuất xứ và an toàn thực phẩm.</p>
                    </div>
                    <div class="action-card-footer mt-3">
                        <a href="${pageContext.request.contextPath}/admin/product-moderation" class="btn-action-pill btn-action-red text-decoration-none">
                            Kiểm định sản phẩm (${stats.flaggedProductsCount}) →
                        </a>
                    </div>
                </div>

                <!-- Card 3: Đơn Hàng & Giao Vận -->
                <div class="action-card card-navy">
                    <div>
                        <div class="action-card-header">
                            <span class="action-tag-pill action-tag-navy">
                                <i class="bi bi-box-seam"></i> ĐƠN HÀNG & GIAO VẬN
                            </span>
                            <span class="badge-counter badge-counter-navy">${stats.totalOrdersCount} Đơn</span>
                        </div>
                        <h3 class="action-card-title">Giám sát chuỗi giao nhận nông sản</h3>
                        <p class="action-card-desc">Theo dõi luồng xử lý đơn hàng, điều phối vận chuyển và giao nhận.</p>
                    </div>
                    <div class="action-card-footer mt-3">
                        <a href="${pageContext.request.contextPath}/admin/orders" class="btn-action-pill btn-action-navy text-decoration-none">
                            Quản lý đơn hàng →
                        </a>
                    </div>
                </div>
            </div>

            <!-- 4. Category Share & Operations Overview -->
            <div class="charts-grid-2">
                <!-- Left: Cơ Cấu Doanh Số Theo Danh Mục -->
                <div class="chart-card">
                    <div class="chart-card-header">
                        <div>
                            <h2 class="chart-title">Cơ Cấu Doanh Số Theo Danh Mục</h2>
                            <span class="chart-subtitle">Phân loại theo danh mục hàng hóa trên sàn</span>
                        </div>
                        <a href="${pageContext.request.contextPath}/admin/categories" class="text-muted small text-decoration-none">Quản lý &rarr;</a>
                    </div>

                    <div class="donut-chart-container">
                        <canvas id="categoryYieldChart"></canvas>
                        <div class="donut-center-stat">
                            <div class="donut-stat-amount">${stats.totalGmvFormatted}</div>
                            <div class="donut-stat-sub">100% GMV</div>
                        </div>
                    </div>

                    <div class="donut-legend-list">
                        <c:forEach items="${stats.categoryStats}" var="cs">
                            <div>
                                <div class="donut-legend-item">
                                    <span><span class="d-inline-block rounded-circle me-1" style="width: 8px; height: 8px; background: ${cs.color};"></span> ${cs.name}</span>
                                    <strong>${cs.percent}% (${cs.volumeFormatted})</strong>
                                </div>
                                <div class="donut-bar-track"><div class="donut-bar-fill" style="width: ${cs.percent}%; background: ${cs.color};"></div></div>
                            </div>
                        </c:forEach>
                        <c:if test="${empty stats.categoryStats}">
                            <div class="text-muted small py-3 text-center">Chưa có dữ liệu danh mục</div>
                        </c:if>
                    </div>
                </div>

                <!-- Right: Tình Trạng Vận Hành Sàn -->
                <div class="chart-card">
                    <div class="chart-card-header">
                        <div>
                            <h2 class="chart-title">Tình Trạng Vận Hành Sàn</h2>
                            <span class="chart-subtitle">Tiến độ xử lý đơn hàng và chất lượng sản phẩm</span>
                        </div>
                        <a href="${pageContext.request.contextPath}/admin/orders" class="text-muted small text-decoration-none">Đơn hàng &rarr;</a>
                    </div>

                    <div class="p-2 d-flex flex-column gap-3 flex-grow-1 justify-content-center">
                        <!-- Item 1: Tỷ lệ hoàn thành đơn hàng -->
                        <div>
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <span class="small fw-semibold text-dark"><i class="bi bi-check-circle-fill text-success me-1"></i> Đơn hàng hoàn tất</span>
                                <span class="small fw-bold text-success">${stats.completedOrdersCount} / ${stats.totalOrdersCount} (${stats.orderCompletionRate}%)</span>
                            </div>
                            <div class="progress" style="height: 6px; background-color: #f1f5f9;">
                                <div class="progress-bar bg-success" style="width: ${stats.orderCompletionRate}%;"></div>
                            </div>
                        </div>

                        <!-- Item 2: Đơn hàng đang xử lý -->
                        <div class="d-flex justify-content-between align-items-center p-2 rounded" style="background: #f8fafc;">
                            <span class="small text-muted"><i class="bi bi-hourglass-split text-warning me-1"></i> Đơn hàng đang xử lý</span>
                            <span class="fw-bold text-dark">${stats.processingOrdersCount} đơn</span>
                        </div>

                        <!-- Item 3: Tỷ lệ sản phẩm chứng nhận -->
                        <div>
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <span class="small fw-semibold text-dark"><i class="bi bi-shield-check text-primary me-1"></i> Chuẩn VietGAP / GlobalGAP</span>
                                <span class="small fw-bold text-primary">${stats.certifiedProductRate}%</span>
                            </div>
                            <div class="progress" style="height: 6px; background-color: #f1f5f9;">
                                <div class="progress-bar bg-primary" style="width: ${stats.certifiedProductRate}%;"></div>
                            </div>
                        </div>

                        <!-- Item 4: Hồ sơ Shop chờ duyệt -->
                        <div class="d-flex justify-content-between align-items-center p-2 rounded" style="background: #f8fafc;">
                            <span class="small text-muted"><i class="bi bi-shop text-orange me-1"></i> Gian hàng chờ kích hoạt</span>
                            <span class="badge bg-warning text-dark">${stats.pendingKycCount} yêu cầu</span>
                        </div>

                        <!-- Item 5: Khiếu nại bảo hành -->
                        <div class="d-flex justify-content-between align-items-center p-2 rounded" style="background: #f8fafc;">
                            <span class="small text-muted"><i class="bi bi-exclamation-octagon text-danger me-1"></i> Khiếu nại đang hòa giải</span>
                            <span class="badge ${stats.openDisputesCount > 0 ? 'bg-danger text-white' : 'bg-secondary text-white'}">${stats.openDisputesCount}</span>
                        </div>
                    </div>

                    <div class="chart-bottom-note mt-auto">
                        <span class="text-muted small">Dữ liệu đối soát trực tiếp từ hệ thống</span>
                        <a href="${pageContext.request.contextPath}/admin/orders" class="text-success fw-bold text-decoration-none small">
                            Chi tiết đơn hàng →
                        </a>
                    </div>
                </div>
            </div>

            <!-- 5. Ranking Tables Section -->
            <div class="tables-grid-2">
                <!-- Left Table: Top Nhà Vườn & Gian Hàng Xuất Sắc -->
                <div class="custom-table-card">
                    <div>
                        <div class="custom-table-header">
                            <div>
                                <h3 class="custom-table-title">Top Nhà Vườn & Gian Hàng Xuất Sắc</h3>
                                <span class="custom-table-sub">Xếp hạng theo GMV và điểm phục vụ khách hàng</span>
                            </div>
                            <span class="table-pill-badge">Tháng này</span>
                        </div>

                        <table class="modern-rank-table">
                            <thead>
                                <tr>
                                    <th>CỬA HÀNG / NHÀ VƯỜN</th>
                                    <th>CHỦ GIAN HÀNG</th>
                                    <th>SỐ ĐƠN</th>
                                    <th>DOANH THU</th>
                                    <th>ĐÁNH GIÁ</th>
                                    <th>TRẠNG THÁI</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${stats.topShops}" var="s">
                                    <tr>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <span class="vendor-avatar-tag tag-hg">${s.avatarTag}</span>
                                                <strong>${s.shopName}</strong>
                                            </div>
                                        </td>
                                        <td>${s.ownerName}</td>
                                        <td>${s.ordersCount}</td>
                                        <td><strong>${s.salesFormatted}</strong></td>
                                        <td><span class="text-warning-emphasis fw-bold">${s.rating}</span></td>
                                        <td><span class="status-pill-green">${s.statusLabel}</span></td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty stats.topShops}">
                                    <tr><td colspan="6" class="text-center text-muted py-3">Không có dữ liệu nhà vườn</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>

                    <div class="custom-table-footer">
                        <span>Hiển thị ${stats.topShops.size()} / ${stats.activeShopsCount} gian hàng</span>
                        <a href="${pageContext.request.contextPath}/admin/shops">Xem tất cả ${stats.activeShopsCount} nhà bán hàng →</a>
                    </div>
                </div>

                <!-- Right Table: Mặt Hàng Nông Sản Bán Chạy -->
                <div class="custom-table-card">
                    <div>
                        <div class="custom-table-header">
                            <div>
                                <h3 class="custom-table-title">Mặt Hàng Nông Sản Bán Chạy</h3>
                                <span class="custom-table-sub">Sản lượng tiêu thụ cao nhất trên sàn Gốc Vườn</span>
                            </div>
                            <span class="table-pill-badge">Theo khối lượng (Kg)</span>
                        </div>

                        <table class="modern-rank-table">
                            <thead>
                                <tr>
                                    <th>TÊN SẢN PHẨM</th>
                                    <th>GIAN HÀNG</th>
                                    <th>DANH MỤC</th>
                                    <th>ĐÃ BÁN</th>
                                    <th>TRẠNG THÁI SÀN</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${stats.topProducts}" var="p">
                                    <tr>
                                        <td>
                                            <div class="d-flex align-items-center gap-1">
                                                <span class="dot-green me-1"></span>
                                                <strong>${p.productName}</strong>
                                            </div>
                                        </td>
                                        <td>${p.shopName}</td>
                                        <td>${p.categoryName}</td>
                                        <td><strong>${p.soldFormatted}</strong></td>
                                        <td><span class="status-pill-green">${p.statusLabel}</span></td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty stats.topProducts}">
                                    <tr><td colspan="5" class="text-center text-muted py-3">Chưa có sản phẩm nào</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>

                    <div class="custom-table-footer">
                        <span>Cập nhật trực tiếp từ kho hàng & đơn hàng</span>
                        <a href="${pageContext.request.contextPath}/admin/products">Xem báo cáo toàn bộ danh mục sản phẩm →</a>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<script>
    window.platformCatLabels = ${not empty stats.categoryLabelsJson ? stats.categoryLabelsJson : '[]'};
    window.platformCatData = ${not empty stats.categoryDataJson ? stats.categoryDataJson : '[]'};
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/admin.js?v=13"></script>
</body>
</html>