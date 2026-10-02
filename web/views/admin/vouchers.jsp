<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Khuyến Mại & Voucher Toàn Sàn - FreshFruit Admin</title>
    <!-- Google Fonts & Bootstrap -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css?v=14">
    <style>
        .fs-7 { font-size: 0.76rem !important; }
        .fs-8 { font-size: 0.70rem !important; }
        .kpi-main-val { font-size: 1.85rem; font-weight: 800; color: #0f172a; line-height: 1.1; margin: 0.35rem 0 0.2rem 0; }
        .kpi-unit { font-size: 0.88rem; font-weight: 600; color: #64748b; }
        .kpi-sub-text { font-size: 0.74rem; font-weight: 600; display: flex; align-items: center; gap: 0.25rem; }
        .kpi-icon-box { width: 36px; height: 36px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.1rem; }
        .tab-btn-pill { border: 1px solid #e2e8f0; background: #ffffff; color: #475569; font-weight: 600; font-size: 0.78rem; border-radius: 8px; padding: 0.45rem 0.85rem; display: inline-flex; align-items: center; gap: 0.4rem; cursor: pointer; transition: all 0.15s ease; text-decoration: none; }
        .tab-btn-pill:hover { background: #f8fafc; color: #0f172a; }
        .tab-btn-pill.active { background: #15803d; color: #ffffff; border-color: #15803d; }
        .tab-btn-pill.active .badge { background: rgba(255, 255, 255, 0.25) !important; color: #ffffff !important; }
        .custom-filter-select { font-size: 0.78rem; border: 1px solid #e2e8f0; border-radius: 8px; padding: 0.45rem 0.85rem; background-color: #ffffff; color: #334155; font-weight: 500; outline: none; }
        .custom-filter-select:focus { border-color: #15803d; }
    </style>
</head>
<body class="admin-body">
<div class="admin-wrapper">
    <!-- Platform Sidebar -->
    <jsp:include page="layout/sidebar.jsp">
        <jsp:param name="activePage" value="vouchers" />
    </jsp:include>

    <!-- Main Container -->
    <div class="admin-main">
        <!-- Header -->
        <jsp:include page="layout/header.jsp" />

        <main class="admin-page-content">
            <!-- Breadcrumbs -->
            <div class="admin-breadcrumbs mb-2 text-muted fs-7">
                <span>Quản trị sàn</span>
                <span class="mx-1">&gt;</span>
                <span>Quản trị vận hành (Governance)</span>
                <span class="mx-1">&gt;</span>
                <span class="text-dark fw-semibold">Khuyến mại &amp; Voucher toàn sàn</span>
            </div>

            <!-- Page Title Row -->
            <div class="page-title-row mb-3 pb-1">
                <div class="page-title-wrapper">
                    <div class="d-flex align-items-center flex-wrap gap-2">
                        <h1 class="mb-0">Quản Lý Khuyến Mại &amp; Voucher Toàn Sàn</h1>
                        <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-2 py-1 fs-8 fw-bold">
                            FRESH PLATFORM
                        </span>
                    </div>
                    <p class="text-muted mt-1 mb-0 fs-7">
                        Thiết lập các chương trình trợ giá toàn sàn, mã miễn phí vận chuyển chuỗi lạnh (Freeship Xtra) và voucher mùa vụ kích cầu tiêu thụ trái cây tươi, chuẩn OCOP.
                    </p>
                </div>
                <div class="page-action-tools gap-2">
                    <button class="btn btn-outline-secondary btn-sm bg-white text-dark fw-bold border shadow-xs" onclick="exportVoucherReport()">
                        <i class="bi bi-graph-up me-1"></i> Báo cáo hiệu quả ngân sách
                    </button>
                    <button class="btn btn-admin-primary btn-sm fw-bold shadow-xs" data-bs-toggle="modal" data-bs-target="#createVoucherModal">
                        <i class="bi bi-plus-circle me-1"></i> Tạo Voucher Toàn Sàn Mới
                    </button>
                </div>
            </div>

            <!-- 4 KPI Summary Cards -->
            <div class="kpi-grid-4 mb-3">
                <!-- Card 1: Ngân sách tháng 10 -->
                <div class="stat-card-kpi">
                    <div class="d-flex justify-content-between align-items-start">
                        <span class="kpi-label text-uppercase fw-bold text-muted fs-8">NGÂN SÁCH THÁNG 10</span>
                        <div class="kpi-icon-box" style="background: #f0fdf4; color: #16a34a;">
                            <i class="bi bi-credit-card-2-front"></i>
                        </div>
                    </div>
                    <div class="kpi-main-val">₫50,000,000</div>
                    <div class="d-flex justify-content-between align-items-center mt-2">
                        <span class="text-muted fs-8">Đã giải ngân: ₫32,460,000</span>
                        <span class="badge bg-success-subtle text-success px-1 py-0 fs-8 fw-bold">64.8%</span>
                    </div>
                    <div class="progress mt-1" style="height: 5px;">
                        <div class="progress-bar bg-success" style="width: 64.8%;"></div>
                    </div>
                </div>

                <!-- Card 2: GMV kích cầu Voucher -->
                <div class="stat-card-kpi">
                    <div class="d-flex justify-content-between align-items-start">
                        <span class="kpi-label text-uppercase fw-bold text-muted fs-8">GMV KÍCH CẦU VOUCHER</span>
                        <div class="kpi-icon-box" style="background: #f0fdf4; color: #16a34a;">
                            <i class="bi bi-graph-up-arrow"></i>
                        </div>
                    </div>
                    <div class="kpi-main-val">₫148,920,000</div>
                    <div class="d-flex justify-content-between align-items-center mt-2">
                        <span class="kpi-sub-text text-success"><i class="bi bi-check-circle-fill"></i> Hiệu suất ROI: 4.6x</span>
                        <span class="badge bg-success-subtle text-success px-1 py-0 fs-8 fw-bold">+18.2% MoM</span>
                    </div>
                </div>

                <!-- Card 3: Freeship Xtra Lạnh -->
                <div class="stat-card-kpi">
                    <div class="d-flex justify-content-between align-items-start">
                        <span class="kpi-label text-uppercase fw-bold text-muted fs-8">FREESHIP XTRA LẠNH</span>
                        <div class="kpi-icon-box" style="background: #eff6ff; color: #2563eb;">
                            <i class="bi bi-truck"></i>
                        </div>
                    </div>
                    <div class="kpi-main-val">3 Chiến Dịch</div>
                    <div class="kpi-sub-text text-muted mt-2">
                        <i class="bi bi-snow2 text-primary"></i>
                        Giảm nhiệt độ SLA ship ...
                    </div>
                </div>

                <!-- Card 4: Lượt dùng toàn sàn -->
                <div class="stat-card-kpi">
                    <div class="d-flex justify-content-between align-items-start">
                        <span class="kpi-label text-uppercase fw-bold text-muted fs-8">LƯỢT DÙNG TOÀN SÀN</span>
                        <div class="kpi-icon-box" style="background: #fff7ed; color: #ea580c;">
                            <i class="bi bi-ticket-perforated"></i>
                        </div>
                    </div>
                    <div class="kpi-main-val">4,820 Lượt</div>
                    <div class="d-flex justify-content-between align-items-center mt-2">
                        <span class="text-muted fs-8">Tỷ lệ chuyển đổi:</span>
                        <span class="badge bg-success-subtle text-success px-1 py-0 fs-8 fw-bold">+24.5% CR</span>
                    </div>
                </div>
            </div>

            <!-- 2 Mid Banners (Side-by-Side Cards) -->
            <div class="row g-3 mb-3">
                <!-- Banner 1 (Left - Cơ Chế Đồng Tài Trợ Co-funding) -->
                <div class="col-lg-6">
                    <div class="admin-card p-3 h-100 border">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <div class="d-flex align-items-center gap-2">
                                <i class="bi bi-shield-check text-success fs-5"></i>
                                <h4 class="fw-bold mb-0 text-dark" style="font-size: 0.95rem;">Cơ Chế Đồng Tài Trợ (Co-funding)</h4>
                            </div>
                            <span class="badge bg-light text-muted border fs-8">Áp dụng trừ GMV</span>
                        </div>
                        <p class="text-muted fs-8 mb-3">
                            Chính sách san sẻ kinh phí khuyến mại giữa Sàn Nông Sản và Hợp tác xã/Nhà vườn đối tác nhằm gia tăng biên lợi nhuận cho người nông dân.
                        </p>

                        <div class="row g-2 mb-3">
                            <div class="col-6">
                                <div class="p-2 rounded-2 border bg-light">
                                    <div class="d-flex align-items-center gap-1 fs-8 fw-bold text-success mb-1">
                                        <i class="bi bi-circle-fill" style="font-size: 0.45rem;"></i> Sàn FreshFruit (65%)
                                    </div>
                                    <div class="text-muted fs-8">Mức hỗ trợ sàn tối đa:</div>
                                    <div class="fw-bold text-dark fs-7">₫35,000 / đơn</div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="p-2 rounded-2 border bg-light">
                                    <div class="d-flex align-items-center gap-1 fs-8 fw-bold text-warning-emphasis mb-1">
                                        <i class="bi bi-circle-fill" style="font-size: 0.45rem; color: #ea580c;"></i> Nhà Vườn / HTX (35%)
                                    </div>
                                    <div class="text-muted fs-8">Ngưỡng tối thiểu HTX:</div>
                                    <div class="fw-bold text-dark fs-7">₫10,000</div>
                                </div>
                            </div>
                        </div>

                        <div class="d-flex justify-content-between align-items-center pt-2 border-top">
                            <div class="d-flex align-items-center gap-2 fs-8">
                                <div class="bg-success-subtle text-success p-1 rounded-2">
                                    <i class="bi bi-shop"></i>
                                </div>
                                <div>
                                    <strong class="text-dark">72/84 Gian Hàng Tham Gia</strong>
                                    <div class="text-muted">85.7% đối tác nông sản đã kích hoạt gói tài trợ giá</div>
                                </div>
                            </div>
                            <button class="btn btn-outline-secondary btn-sm bg-white border fs-8 fw-bold" onclick="alert('Mở bảng cài đặt tỷ lệ co-funding!')">
                                Cài đặt tỷ lệ
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Banner 2 (Right - Flash Sale Giờ Vàng Nông Sản) -->
                <div class="col-lg-6">
                    <div class="admin-card p-3 h-100 border">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <div class="d-flex align-items-center gap-2">
                                <span class="badge bg-danger text-white fs-8 fw-bold">🔴 LIVE NOW</span>
                                <h4 class="fw-bold mb-0 text-dark" style="font-size: 0.95rem;">Flash Sale Giờ Vàng Nông Sản</h4>
                            </div>
                            <span class="badge bg-success-subtle text-success border border-success-subtle fs-8 fw-bold">
                                <i class="bi bi-clock me-1"></i> CÒN 01H 24M
                            </span>
                        </div>
                        <p class="text-muted fs-8 mb-3">
                            Chiến dịch kích cầu đơn hàng trái cây tươi hái trong ngày trong khung 11h00 - 13h00
                        </p>

                        <div class="p-2 rounded-2 border bg-light mb-3">
                            <div class="row g-2 text-center">
                                <div class="col-4 border-end">
                                    <div class="text-muted fs-8">Mã Đang Phát:</div>
                                    <div class="fw-bold text-dark fs-7">FLASHCHIN20</div>
                                    <div class="text-muted fs-8">Giảm 20k đơn từ 120k</div>
                                </div>
                                <div class="col-4 border-end">
                                    <div class="text-muted fs-8">Tốc Độ Hấp Thụ:</div>
                                    <div class="fw-bold text-dark fs-7">92.4%</div>
                                    <div class="text-muted fs-8">462 / 500 mã nhận</div>
                                </div>
                                <div class="col-4">
                                    <div class="text-muted fs-8">Doanh Số Đột Biến:</div>
                                    <div class="fw-bold text-success fs-7">+34.8%</div>
                                    <div class="text-muted fs-8">So cùng giờ tuần trước</div>
                                </div>
                            </div>
                        </div>

                        <div class="d-flex justify-content-between align-items-center pt-2 border-top">
                            <div class="d-flex align-items-center gap-2 fs-8 text-muted">
                                <div class="d-flex">
                                    <img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=32&h=32&fit=crop" class="rounded-circle border" style="width: 20px; height: 20px;">
                                    <img src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=32&h=32&fit=crop" class="rounded-circle border ms-n1" style="width: 20px; height: 20px; margin-left: -6px;">
                                </div>
                                <span class="text-truncate" style="max-width: 270px;">Áp dụng đặc quyền nhóm vườn Tiền Giang, Bến Tre &amp; Đồng Tháp</span>
                            </div>
                            <a href="javascript:void(0)" onclick="alert('Chi tiết chiến dịch Flash Sale')" class="text-success text-decoration-none fs-8 fw-bold">
                                Xem chi tiết &rarr;
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Segmented Tabs & Filters Toolbar -->
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
                <div class="d-flex align-items-center flex-wrap gap-2" id="voucherTabButtons">
                    <button class="tab-btn-pill active" onclick="switchVoucherTab(this, 'all')">
                        Tất cả <span class="badge bg-white text-success px-1 py-0 fs-8">${not empty vouchersList ? vouchersList.size() : 5}</span>
                    </button>
                    <button class="tab-btn-pill" onclick="switchVoucherTab(this, 'active')">
                        Đang hoạt động <span class="badge bg-light text-muted px-1 py-0 fs-8">${not empty vouchersList ? vouchersList.size() : 5}</span>
                    </button>
                    <button class="tab-btn-pill" onclick="switchVoucherTab(this, 'upcoming')">
                        Sắp diễn ra <span class="badge bg-light text-muted px-1 py-0 fs-8">0</span>
                    </button>
                    <button class="tab-btn-pill" onclick="switchVoucherTab(this, 'expired')">
                        Đã kết thúc <span class="badge bg-light text-muted px-1 py-0 fs-8">0</span>
                    </button>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <span class="text-muted fs-8">Sắp xếp:</span>
                    <select class="custom-filter-select" id="voucherSortSelect" onchange="sortVouchers(this.value)">
                        <option value="priority">Ưu tiên cao nhất</option>
                        <option value="newest">Ngày tạo: Mới nhất</option>
                        <option value="budget">Ngân sách: Cao đến thấp</option>
                        <option value="usage">Lượt dùng nhiều nhất</option>
                    </select>
                </div>
            </div>

            <!-- Search and Filter Bar -->
            <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3 bg-white p-2 rounded-3 border">
                <div class="d-flex align-items-center flex-grow-1" style="min-width: 240px; max-width: 420px;">
                    <div class="input-group input-group-sm">
                        <span class="input-group-text bg-transparent border-0 text-muted ps-2 pe-1">
                            <i class="bi bi-search"></i>
                        </span>
                        <input type="text" id="voucherSearchInput" class="form-control border-0 shadow-none fs-7" 
                               placeholder="Tìm theo mã..." 
                               onkeyup="filterVouchersList()">
                    </div>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <select class="custom-filter-select" id="voucherTypeFilter" onchange="filterVouchersList()">
                        <option value="all">Loại: Tất cả loại voucher</option>
                        <option value="freeship">Freeship Xtra Lạnh</option>
                        <option value="discount">Giảm giá % đơn hàng</option>
                        <option value="flash">Flash Sale Giờ Vàng</option>
                        <option value="welcome">Khách hàng mới</option>
                        <option value="season">Mùa vụ đặc sản</option>
                    </select>
                    <select class="custom-filter-select" id="voucherSponsorFilter" onchange="filterVouchersList()">
                        <option value="all">Nguồn: Tất cả nguồn ngân sách</option>
                        <option value="platform">100% Sàn tài trợ</option>
                        <option value="cofunding">Đồng tài trợ (Sàn + Shop)</option>
                    </select>
                    <select class="custom-filter-select">
                        <option>Tháng 10/2024</option>
                        <option>Tháng 09/2024</option>
                        <option>Tháng 11/2024</option>
                    </select>
                    <button class="btn btn-outline-secondary btn-sm bg-white border" title="Xóa bộ lọc" onclick="resetVoucherFilters()">
                        <i class="bi bi-arrow-counterclockwise"></i>
                    </button>
                </div>
            </div>

            <!-- 5 Voucher Cards Feed -->
            <div class="voucher-feed-container" id="vouchersListContainer">
                <c:choose>
                    <c:when test="${not empty vouchersList}">
                        <c:forEach items="${vouchersList}" var="v">
                            <div class="voucher-card-item" data-code="${v.couponCode}" data-type="${v.discountType}" data-sponsor="${v.sponsorType}" data-status="${v.isActive ? 'active' : 'expired'}">
                                <!-- Left Ticket Stub -->
                                <div class="voucher-stub" style="background: ${v.stubBg}; color: ${v.stubColor};">
                                    <i class="bi ${v.stubIcon} fs-4"></i>
                                    <div class="voucher-stub-val">${v.stubVal}</div>
                                    <div class="voucher-stub-tag">${v.stubTag}</div>
                                </div>

                                <!-- Middle Info Body -->
                                <div class="voucher-body">
                                    <div class="d-flex align-items-center gap-2 mb-1 flex-wrap">
                                        <span class="badge bg-light border text-dark font-monospace fw-bold fs-8 px-2 py-1">
                                            ${v.couponCode}
                                        </span>
                                        <c:choose>
                                            <c:when test="${v.isActive}">
                                                <span class="badge bg-success-subtle text-success border border-success-subtle fs-8 fw-bold">
                                                    ĐANG PHÁT HÀNH
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary-subtle text-secondary border fs-8 fw-bold">
                                                    TẠM DỪNG
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                        <span class="badge bg-light text-muted border fs-8">${v.sponsorTag}</span>
                                    </div>
                                    <h4 class="fw-bold text-dark mb-1" style="font-size: 0.95rem;">
                                        ${v.title}
                                    </h4>
                                    <div class="text-muted fs-8 mb-2">
                                        ${v.discountFormatted} | Đơn tối thiểu ${v.minSpendFormatted}
                                    </div>
                                    <div class="d-flex align-items-center gap-3 fs-8 text-secondary">
                                        <span><i class="bi bi-calendar3 me-1"></i> Áp dụng mùa vụ 2024</span>
                                        <span>• <i class="bi bi-geo-alt me-1"></i> Toàn sàn FreshFruit</span>
                                    </div>
                                </div>

                                <!-- Right Metrics Box -->
                                <div class="voucher-metrics-box">
                                    <div class="voucher-metric-col">
                                        <span class="voucher-metric-title">Ngân Sách Ước Tính:</span>
                                        <span class="voucher-metric-num">${v.budgetUsedFormatted}</span>
                                        <div class="progress mt-1" style="height: 4px;">
                                            <div class="progress-bar bg-success" style="width: ${v.percentUsed}%;"></div>
                                        </div>
                                        <span class="voucher-metric-sub">${v.percentUsed}% giới hạn</span>
                                    </div>
                                    <div class="voucher-metric-col">
                                        <span class="voucher-metric-title">Lượt Áp Dụng:</span>
                                        <span class="voucher-metric-num">${v.usedCount} / ${v.usageLimit} mã</span>
                                        <span class="voucher-metric-sub text-success">Còn lại ${v.remainingCount} lượt</span>
                                    </div>
                                    <div class="voucher-metric-col">
                                        <span class="voucher-metric-title">GMV Tương Ứng:</span>
                                        <span class="voucher-metric-num text-success">${v.gmvFormatted}</span>
                                        <span class="voucher-metric-sub">Kích cầu doanh số</span>
                                    </div>
                                </div>

                                <!-- Actions -->
                                <div class="voucher-actions">
                                    <button class="btn btn-outline-secondary btn-sm bg-white border p-1" title="Sao chép mã" onclick="copyVoucherCode('${v.couponCode}')">
                                        <i class="bi bi-clipboard"></i>
                                    </button>
                                    <button class="btn btn-outline-secondary btn-sm bg-white border fw-bold fs-8" onclick="editVoucherModal('${v.couponCode}')">
                                        <i class="bi bi-pencil me-1"></i> Chỉnh sửa
                                    </button>
                                    <button class="btn btn-outline-danger btn-sm bg-white border fw-bold fs-8" onclick="pauseVoucher('${v.couponCode}')">
                                        <i class="bi bi-pause-circle me-1"></i> Tạm dừng
                                    </button>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-5 text-muted bg-white rounded-3 border">
                            <i class="bi bi-ticket-perforated fs-1 d-block mb-2"></i>
                            Chưa có chương trình voucher nào được tạo.
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Pagination Bar -->
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mt-4 pt-2 border-top">
                <div class="text-muted fs-8">
                    Hiển thị 1 - ${not empty vouchersList ? vouchersList.size() : 5} của tổng số ${not empty vouchersList ? vouchersList.size() : 5} mã khuyến mại toàn sàn
                </div>
                <nav aria-label="Voucher navigation">
                    <ul class="pagination pagination-sm mb-0">
                        <li class="page-item disabled"><a class="page-link" href="#">&lt;</a></li>
                        <li class="page-item active"><a class="page-link bg-success border-success" href="#">1</a></li>
                        <li class="page-item"><a class="page-link text-dark" href="#">2</a></li>
                        <li class="page-item"><a class="page-link text-dark" href="#">3</a></li>
                        <li class="page-item disabled"><a class="page-link" href="#">...</a></li>
                        <li class="page-item"><a class="page-link text-dark" href="#">6</a></li>
                        <li class="page-item"><a class="page-link text-dark" href="#">&gt;</a></li>
                    </ul>
                </nav>
            </div>

        </main>
    </div>
</div>

<!-- Modal: Tạo Voucher Toàn Sàn Mới -->
<div class="modal fade" id="createVoucherModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header border-bottom">
                <div class="d-flex align-items-center gap-2">
                    <div class="bg-success-subtle text-success p-2 rounded-2">
                        <i class="bi bi-ticket-perforated-fill fs-5"></i>
                    </div>
                    <div>
                        <h5 class="modal-title fw-bold mb-0">Tạo Voucher Khuyến Mại Toàn Sàn Mới</h5>
                        <div class="text-muted fs-8">Hệ thống phân bổ ngân sách tự động từ quỹ kích cầu nền tảng</div>
                    </div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label fs-7 fw-bold">Mã Voucher (Code):</label>
                        <input type="text" class="form-control form-control-sm text-uppercase font-monospace" placeholder="VD: FRESHMANGO20" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fs-7 fw-bold">Loại Chương Trình:</label>
                        <select class="form-select form-select-sm">
                            <option>Freeship Xtra (Chuỗi Lạnh)</option>
                            <option>Giảm Giá % Giá Trị Đơn Hàng</option>
                            <option>Flash Sale Giờ Vàng</option>
                            <option>Mã Chào Bạn Mới (Evergreen)</option>
                            <option>Lễ Hội Nông Sản Mùa Vụ OCOP</option>
                        </select>
                    </div>
                    <div class="col-md-12">
                        <label class="form-label fs-7 fw-bold">Tên Chiến Dịch Hiển Thị:</label>
                        <input type="text" class="form-control form-control-sm" placeholder="VD: Tuần Lễ Xoài Cát Chu Cao Lãnh Đồng Tháp">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fs-7 fw-bold">Mức Giảm:</label>
                        <input type="text" class="form-control form-control-sm" placeholder="VD: 30.000 đ hoặc 15%">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fs-7 fw-bold">Đơn Tối Thiểu:</label>
                        <input type="text" class="form-control form-control-sm" placeholder="VD: 200.000 đ">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fs-7 fw-bold">Hạn Mức Ngân Sách:</label>
                        <input type="text" class="form-control form-control-sm" placeholder="VD: 20.000.000 đ">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fs-7 fw-bold">Nguồn Tài Trợ:</label>
                        <select class="form-select form-select-sm">
                            <option>100% Sàn FreshFruit Tài Trợ</option>
                            <option>Đồng Tài Trợ Co-funding (Sàn 65% - Shop 35%)</option>
                            <option>Đồng Tài Trợ Co-funding (Sàn 70% - Shop 30%)</option>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fs-7 fw-bold">Thời Gian Áp Dụng:</label>
                        <div class="input-group input-group-sm">
                            <input type="date" class="form-control">
                            <span class="input-group-text">đến</span>
                            <input type="date" class="form-control">
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer border-top bg-light">
                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Hủy bỏ</button>
                <button type="button" class="btn btn-admin-primary btn-sm" onclick="saveNewVoucher()">
                    <i class="bi bi-check-circle me-1"></i> Lưu &amp; Kích Hoạt Voucher
                </button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/admin.js?v=7"></script>
<script>
    // Tab switching
    function switchVoucherTab(btn, statusKey) {
        document.querySelectorAll('#voucherTabButtons .tab-btn-pill').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');

        const items = document.querySelectorAll('#vouchersListContainer .voucher-card-item');
        items.forEach(item => {
            const itemStatus = item.getAttribute('data-status') || '';
            if (statusKey === 'all') {
                item.style.display = 'flex';
            } else if (itemStatus.includes(statusKey)) {
                item.style.display = 'flex';
            } else {
                item.style.display = 'none';
            }
        });
    }

    // Filter vouchers
    function filterVouchersList() {
        const query = (document.getElementById('voucherSearchInput').value || '').toLowerCase().trim();
        const typeFilter = document.getElementById('voucherTypeFilter').value;
        const sponsorFilter = document.getElementById('voucherSponsorFilter').value;
        const items = document.querySelectorAll('#vouchersListContainer .voucher-card-item');

        items.forEach(item => {
            const text = item.textContent.toLowerCase();
            const type = item.getAttribute('data-type');
            const sponsor = item.getAttribute('data-sponsor');

            const matchQuery = !query || text.includes(query);
            const matchType = typeFilter === 'all' || type === typeFilter;
            const matchSponsor = sponsorFilter === 'all' || sponsor === sponsorFilter;

            if (matchQuery && matchType && matchSponsor) {
                item.style.display = 'flex';
            } else {
                item.style.display = 'none';
            }
        });
    }

    // Reset filters
    function resetVoucherFilters() {
        document.getElementById('voucherSearchInput').value = '';
        document.getElementById('voucherTypeFilter').value = 'all';
        document.getElementById('voucherSponsorFilter').value = 'all';
        filterVouchersList();
        showToast('Đã đặt lại toàn bộ bộ lọc mã khuyến mại!');
    }

    // Sort vouchers
    function sortVouchers(type) {
        showToast('Đã sắp xếp danh sách theo: ' + type);
    }

    // Copy voucher code
    function copyVoucherCode(code) {
        navigator.clipboard.writeText(code).then(() => {
            showToast('Đã sao chép mã voucher: ' + code);
        }).catch(() => {
            showToast('Đã sao chép mã voucher: ' + code);
        });
    }

    // Edit voucher modal
    function editVoucherModal(code) {
        showToast('Mở trình chỉnh sửa thông số cho voucher: ' + code);
    }

    // Pause voucher
    function pauseVoucher(code) {
        if (confirm('Bạn có chắc chắn muốn tạm dừng phát hành mã voucher ' + code + '?')) {
            showToast('Đã tạm dừng mã voucher ' + code + ' trên toàn sàn!');
        }
    }

    // Publish voucher early
    function publishVoucherEarly(code) {
        showToast('Đã kích hoạt phát hành sớm mã voucher: ' + code + '!');
    }

    // Save new voucher
    function saveNewVoucher() {
        const modalEl = document.getElementById('createVoucherModal');
        const modal = bootstrap.Modal.getInstance(modalEl);
        if (modal) modal.hide();
        showToast('Đã tạo thành công voucher mới và phân bổ ngân sách toàn sàn!');
    }

    // Export report
    function exportVoucherReport() {
        showToast('Đang kết xuất báo cáo hiệu quả ngân sách trợ giá (ROI/GMV) định dạng Excel...');
    }

    // Toast helper
    function showToast(message) {
        const toast = document.createElement('div');
        toast.className = 'position-fixed bottom-0 end-0 p-3';
        toast.style.zIndex = '9999';
        toast.innerHTML = `
            <div class="toast show align-items-center text-white bg-dark border-0 shadow-lg rounded-3" role="alert">
                <div class="d-flex">
                    <div class="toast-body fs-7"><i class="bi bi-info-circle-fill text-success me-2"></i>` + message + `</div>
                    <button type="button" class="btn-close btn-close-white me-2 m-auto" onclick="this.parentElement.parentElement.parentElement.remove()"></button>
                </div>
            </div>
        `;
        document.body.appendChild(toast);
        setTimeout(() => toast.remove(), 4000);
    }
</script>
</body>
</html>
