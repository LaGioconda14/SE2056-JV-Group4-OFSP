<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FreshFruit - Platform Admin Dashboard</title>

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
            <!-- 1. Live Engine Telemetry Banner -->
            <div class="engine-telemetry-banner">
                <div class="d-flex flex-wrap align-items-center justify-content-between gap-3">
                    <div>
                        <div class="d-flex align-items-center gap-2 mb-1">
                            <span class="badge-live-engine"><i class="bi bi-circle-fill text-success" style="font-size: 0.55rem;"></i> LIVE E-COMMERCE ENGINE</span>
                        </div>
                        <h1 class="telemetry-banner-title">Tổng Quan Hoạt Động Sàn Nông Sản</h1>
                        <p class="telemetry-banner-desc mb-0">Giám sát dòng tiền GMV, chất lượng nhà vườn và phê duyệt kiểm định sản phẩm toàn hệ thống FreshFruit.</p>
                    </div>
                    <div class="d-flex align-items-center gap-2">
                        <div class="banner-pill-stat">
                            <i class="bi bi-shop text-success fs-5"></i>
                            <div>
                                <span class="fw-bold text-dark fs-6">${stats.activeShopsCount}</span>
                                <div class="text-muted" style="font-size: 0.65rem; line-height: 1.1;">Gian hàng<br>hoạt động</div>
                            </div>
                        </div>
                        <div class="banner-pill-stat">
                            <i class="bi bi-shield-check text-primary fs-5"></i>
                            <div>
                                <span class="fw-bold text-dark fs-6">${stats.certifiedProductRate}%</span>
                                <div class="text-muted" style="font-size: 0.65rem; line-height: 1.1;">Chuẩn VietGAP /<br>GlobalGAP</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 2. 4 KPI Metrics Cards -->
            <div class="kpi-grid-4">
                <!-- Card 1: Tổng GMV Toàn Sàn -->
                <div class="stat-card-kpi">
                    <div class="d-flex align-items-center justify-content-between mb-1">
                        <span class="kpi-label">TỔNG GMV TOÀN SÀN</span>
                        <div class="kpi-icon-box bg-green-subtle"><i class="bi bi-cash-stack"></i></div>
                    </div>
                    <div class="kpi-main-val">${stats.totalGmvFullFormatted}</div>
                    <div class="d-flex align-items-center gap-2 my-1">
                        <span class="badge-kpi-growth">${stats.gmvGrowthFormatted}</span>
                        <span class="text-muted" style="font-size: 0.7rem;">so với chu kỳ trước</span>
                    </div>
                    <div class="d-flex align-items-center justify-content-between mt-2 pt-2 border-top" style="border-color: #f1f5f9 !important;">
                        <span class="text-muted" style="font-size: 0.68rem;">GMV từ ${stats.activeShopsCount} shop hoạt động</span>
                        <svg width="65" height="18" viewBox="0 0 65 18" fill="none">
                            <path d="M1 14C10 14 16 5 26 10C36 15 48 2 64 6" stroke="#15803d" stroke-width="2" stroke-linecap="round"/>
                        </svg>
                    </div>
                </div>

                <!-- Card 2: Doanh Thu Hoa Hồng Sàn -->
                <div class="stat-card-kpi">
                    <div class="d-flex align-items-center justify-content-between mb-1">
                        <span class="kpi-label">DOANH THU HOA HỒNG SÀN</span>
                        <div class="kpi-icon-box bg-green-subtle"><i class="bi bi-wallet2"></i></div>
                    </div>
                    <div class="kpi-main-val text-success">${stats.netCommissionFullFormatted}</div>
                    <div class="d-flex align-items-center gap-2 my-1">
                        <span class="badge-kpi-growth">${stats.commissionGrowthFormatted}</span>
                        <span class="text-muted" style="font-size: 0.7rem;">so với chu kỳ trước</span>
                    </div>
                    <div class="d-flex align-items-center justify-content-between mt-2 pt-2 border-top" style="border-color: #f1f5f9 !important;">
                        <span class="text-muted" style="font-size: 0.68rem;">Takerate định mức: ${stats.avgTakeRate}%</span>
                        <div class="d-flex align-items-end gap-1" style="height: 16px;">
                            <span style="width: 3px; height: 8px; background: #15803d; border-radius: 1px;"></span>
                            <span style="width: 3px; height: 11px; background: #15803d; border-radius: 1px;"></span>
                            <span style="width: 3px; height: 14px; background: #15803d; border-radius: 1px;"></span>
                            <span style="width: 3px; height: 16px; background: #15803d; border-radius: 1px;"></span>
                            <span style="width: 3px; height: 12px; background: #15803d; border-radius: 1px;"></span>
                        </div>
                    </div>
                </div>

                <!-- Card 3: Tổng Đơn Hàng Đã Xử Lý -->
                <div class="stat-card-kpi">
                    <div class="d-flex align-items-center justify-content-between mb-1">
                        <span class="kpi-label">TỔNG ĐƠN HÀNG ĐÃ XỬ LÝ</span>
                        <div class="kpi-icon-box bg-purple-subtle"><i class="bi bi-bag-check-fill"></i></div>
                    </div>
                    <div class="kpi-main-val">${stats.totalOrdersFormatted} <span class="fs-6 fw-normal text-muted">đơn</span></div>
                    <div class="d-flex align-items-center gap-2 my-1">
                        <span class="badge-kpi-growth">${stats.orderGrowthFormatted}</span>
                        <span class="text-muted" style="font-size: 0.7rem;">${stats.orderCompletionRate}% hoàn tất</span>
                    </div>
                    <div class="progress mt-2" style="height: 4px; background-color: #f1f5f9;">
                        <div class="progress-bar bg-success" style="width: ${stats.orderCompletionRate}%;"></div>
                    </div>
                </div>

                <!-- Card 4: Tài Khoản Hoạt Động -->
                <div class="stat-card-kpi">
                    <div class="d-flex align-items-center justify-content-between mb-1">
                        <span class="kpi-label">TÀI KHOẢN HOẠT ĐỘNG</span>
                        <div class="kpi-icon-box bg-green-subtle"><i class="bi bi-people-fill"></i></div>
                    </div>
                    <div class="kpi-main-val">${stats.activeUsersFormatted}</div>
                    <div class="d-flex align-items-center gap-2 my-1">
                        <span class="badge-kpi-purple">Tỷ lệ Active ${stats.activeUserRate}%</span>
                    </div>
                    <div class="mt-2 pt-2 border-top text-muted" style="font-size: 0.68rem; border-color: #f1f5f9 !important;">
                        +${stats.totalBuyersCount} khách mua & ${stats.activeShopsCount} shop đối tác
                    </div>
                </div>
            </div>

            <!-- 3. 3 Action / Attention Cards (Khối Cần Xử Lý Ngay) -->
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
                        <h3 class="action-card-title">${stats.pendingKycCount} Đơn đăng ký mở Shop đang chờ duyệt</h3>
                        <p class="action-card-desc">Hồ sơ KYC thương nhân & chứng chỉ VietGAP/GlobalGAP cần thẩm định pháp lý trước khi cấp quyền mở bán.</p>
                    </div>
                    <div class="action-card-footer">
                        <div class="avatar-stack">
                            <c:forEach items="${stats.pendingShops}" var="ps" begin="0" end="2">
                                <span class="avatar-stack-item bg-orange">${ps.avatarAbbr}</span>
                            </c:forEach>
                            <c:if test="${empty stats.pendingShops}">
                                <span class="avatar-stack-item bg-secondary">-</span>
                            </c:if>
                        </div>
                        <a href="${pageContext.request.contextPath}/admin/shops?status=PENDING_KYC" class="btn-action-pill btn-action-orange">
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
                            <span class="badge-counter badge-counter-red">${stats.flaggedProductsCount} Báo Cáo</span>
                        </div>
                        <h3 class="action-card-title">${stats.flaggedProductsCount} Sản phẩm đang chờ kiểm duyệt / tạm ẩn</h3>
                        <p class="action-card-desc">Thẩm định chứng nhận nguồn gốc xuất xứ nông sản, tiêu chuẩn an toàn thực phẩm trước khi mở bán.</p>
                    </div>
                    <div class="action-card-footer">
                        <span class="text-danger fw-bold" style="font-size: 0.72rem;">
                            <i class="bi bi-exclamation-triangle-fill me-1"></i> Cần xử lý trước 24h
                        </span>
                        <a href="${pageContext.request.contextPath}/admin/categories" class="btn-action-pill btn-action-red">
                            Kiểm định sản phẩm (${stats.flaggedProductsCount}) →
                        </a>
                    </div>
                </div>

                <!-- Card 3: Hòa Giải Tranh Chấp -->
                <div class="action-card card-navy">
                    <div>
                        <div class="action-card-header">
                            <span class="action-tag-pill action-tag-navy">
                                <i class="bi bi-scale"></i> HÒA GIẢI TRANH CHẤP
                            </span>
                            <span class="badge-counter badge-counter-navy">${stats.openDisputesCount} Yêu Cầu</span>
                        </div>
                        <h3 class="action-card-title">${stats.openDisputesCount} Khiếu nại chất lượng cần hòa giải</h3>
                        <p class="action-card-desc">Tranh chấp giữa Khách hàng và Nhà vườn về hoa quả dập nát, lên men trong khâu vận chuyển hàng tươi.</p>
                    </div>
                    <div class="action-card-footer">
                        <span class="text-muted" style="font-size: 0.72rem;">
                            Tạm giữ ví: <strong class="text-dark">${stats.totalEscrowFormatted}</strong>
                        </span>
                        <a href="${pageContext.request.contextPath}/admin/disputes" class="btn-action-pill btn-action-navy">
                            Xử lý tranh chấp (${stats.openDisputesCount}) →
                        </a>
                    </div>
                </div>
            </div>

            <!-- 4. Charts Section -->
            <div class="charts-grid-2">
                <!-- Left: Xu Hướng Doanh Thu Sàn & Sản Lượng Đơn -->
                <div class="chart-card">
                    <div class="chart-card-header flex-wrap gap-2">
                        <div>
                            <h2 class="chart-title">Xu Hướng Doanh Thu Sàn & Sản Lượng Đơn</h2>
                            <span class="chart-subtitle">Biểu đồ tổng hợp dữ liệu giao dịch từ các đơn hàng</span>
                        </div>
                        <div class="d-flex align-items-center gap-3">
                            <div class="chart-filter-pills">
                                <button type="button" class="chart-pill-btn active">Tất cả</button>
                                <button type="button" class="chart-pill-btn">Nhập khẩu</button>
                                <button type="button" class="chart-pill-btn">Nội địa</button>
                            </div>
                            <div class="d-flex align-items-center gap-2">
                                <span class="chart-legend-badge"><span class="dot-green"></span> GMV Sàn</span>
                                <span class="chart-legend-badge"><span class="dot-orange"></span> Hoa Hồng ${stats.avgTakeRate}%</span>
                            </div>
                        </div>
                    </div>

                    <div class="chart-canvas-wrapper">
                        <!-- Peak Day Tooltip Callout -->
                        <div class="peak-callout-box">
                            <div class="peak-title">● GMV Sàn Trực Tuyến</div>
                            <div>${stats.totalGmvFormatted} | ${stats.totalOrdersFormatted} Đơn</div>
                        </div>
                        <canvas id="revenueVelocityChart"></canvas>
                    </div>

                    <div class="chart-bottom-note">
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-check-circle-fill text-success"></i>
                            <span>Đã đối soát thanh toán trực tuyến qua VNPAY, MoMo, Visa/Mastercard tự động.</span>
                        </div>
                        <a href="${pageContext.request.contextPath}/admin/orders" class="text-success fw-bold text-decoration-none">
                            Xem đơn hàng thanh toán →
                        </a>
                    </div>
                </div>

                <!-- Right: Cơ Cấu Doanh Số -->
                <div class="chart-card">
                    <div class="chart-card-header">
                        <div>
                            <h2 class="chart-title">Cơ Cấu Doanh Số</h2>
                            <span class="chart-subtitle">Phân loại theo danh mục hàng hóa</span>
                        </div>
                        <button type="button" class="btn btn-sm btn-link text-muted p-0"><i class="bi bi-three-dots-vertical"></i></button>
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
                            <div class="text-muted small py-2 text-center">Chưa có phân loại danh mục</div>
                        </c:if>
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
                                <span class="custom-table-sub">Sản lượng tiêu thụ cao nhất trên sàn FreshFruit</span>
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
    window.platformChartLabels = ${not empty stats.chartLabelsJson ? stats.chartLabelsJson : '[]'};
    window.platformGmvData = ${not empty stats.chartGmvJson ? stats.chartGmvJson : '[]'};
    window.platformCommData = ${not empty stats.chartCommissionJson ? stats.chartCommissionJson : '[]'};
    window.platformCatLabels = ${not empty stats.categoryLabelsJson ? stats.categoryLabelsJson : '[]'};
    window.platformCatData = ${not empty stats.categoryDataJson ? stats.categoryDataJson : '[]'};
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/admin.js?v=11"></script>
</body>
</html>
