<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kiểm Duyệt Sản Phẩm & Nông Sản Toàn Sàn - FreshFruit Platform Admin</title>
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
        <jsp:param name="activePage" value="moderation" />
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
                <span class="text-dark fw-semibold">Kiểm duyệt Sản phẩm</span>
            </div>

            <!-- Page Title Row -->
            <div class="page-title-row mb-3 pb-1">
                <div class="page-title-wrapper">
                    <div class="d-flex align-items-center flex-wrap gap-2">
                        <h1 class="mb-0">Kiểm Duyệt Sản Phẩm & Nông Sản Toàn Sàn</h1>
                        <c:choose>
                            <c:when test="${productStats.inactiveCount > 0}">
                                <span class="badge bg-warning-subtle text-warning-emphasis border border-warning-subtle rounded-pill px-2 py-1 fs-7 fw-bold">
                                    <i class="bi bi-circle-fill text-warning me-1" style="font-size: 0.45rem;"></i>${productStats.inactiveCount} CẦN XỬ LÝ
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-2 py-1 fs-7 fw-bold">
                                    <i class="bi bi-check-circle-fill me-1" style="font-size: 0.75rem;"></i>TẤT CẢ HỢP LỆ (${productStats.activeCount})
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <p class="text-muted mt-1 mb-0 fs-7">
                        Quy trình kiểm định 3 lớp: Đối soát thị giác AI (Vision AI) + Thẩm tra chứng nhận VietGAP/GlobalGAP + Kiểm duyệt nhân sự.
                    </p>
                </div>
                <div class="page-action-tools gap-2">
                    <button class="btn btn-outline-secondary btn-sm bg-white text-dark fw-bold border shadow-xs" data-bs-toggle="modal" data-bs-target="#sopStandardModal">
                        <i class="bi bi-book me-1"></i> Quy chuẩn kiểm duyệt nông sản
                    </button>
                    <button class="btn btn-admin-primary btn-sm fw-bold shadow-xs" onclick="quickApproveSafeProducts()">
                        <i class="bi bi-lightning-charge-fill me-1"></i> Duyệt nhanh (${productStats.safeCount} mã an toàn)
                    </button>
                </div>
            </div>

            <!-- 4 KPI Summary Cards -->
            <div class="kpi-grid-4 mb-3">
                <!-- Card 1: Tổng nông sản niêm yết -->
                <div class="stat-card-kpi">
                    <div class="d-flex justify-content-between align-items-start">
                        <span class="kpi-label text-uppercase fw-bold text-muted fs-8">TỔNG SẢN PHẨM NIÊM YẾT</span>
                        <div class="kpi-icon-box" style="background: #f0fdf4; color: #16a34a;">
                            <i class="bi bi-boxes"></i>
                        </div>
                    </div>
                    <div class="kpi-main-val">${productStats.totalCount} <span class="kpi-unit">sản phẩm</span></div>
                    <div class="kpi-sub-text text-success">
                        <i class="bi bi-check-circle-fill" style="font-size: 0.45rem;"></i>
                        ${productStats.activeCount} mã đang mở bán (${productStats.activeRate}%)
                    </div>
                </div>

                <!-- Card 2: Chờ duyệt / Tạm ẩn -->
                <div class="stat-card-kpi">
                    <div class="d-flex justify-content-between align-items-start">
                        <span class="kpi-label text-uppercase fw-bold text-muted fs-8">CHỜ DUYỆT / TẠM ẨN</span>
                        <div class="kpi-icon-box" style="background: #fff7ed; color: #ea580c;">
                            <i class="bi bi-clock-history"></i>
                        </div>
                    </div>
                    <div class="kpi-main-val text-warning-emphasis">${productStats.inactiveCount} <span class="kpi-unit">yêu cầu</span></div>
                    <div class="kpi-sub-text text-warning-emphasis">
                        <i class="bi bi-circle-fill" style="font-size: 0.4rem; color: #ea580c;"></i>
                        Cần nhân sự sàn kiểm tra
                    </div>
                </div>

                <!-- Card 3: Đạt chuẩn kiểm định -->
                <div class="stat-card-kpi">
                    <div class="d-flex justify-content-between align-items-start">
                        <span class="kpi-label text-uppercase fw-bold text-muted fs-8">ĐẠT CHUẨN KIỂM ĐỊNH</span>
                        <div class="kpi-icon-box" style="background: #eff6ff; color: #2563eb;">
                            <i class="bi bi-shield-check"></i>
                        </div>
                    </div>
                    <div class="kpi-main-val text-primary">${productStats.certifiedCount} <span class="kpi-unit">mã đạt chuẩn</span></div>
                    <div class="kpi-sub-text text-primary">
                        <i class="bi bi-patch-check-fill" style="font-size: 0.45rem;"></i>
                        Tỷ lệ đạt chuẩn: ${productStats.complianceRate}%
                    </div>
                </div>

                <!-- Card 4: Cảnh báo tồn kho -->
                <div class="stat-card-kpi">
                    <div class="d-flex justify-content-between align-items-start">
                        <span class="kpi-label text-uppercase fw-bold text-muted fs-8">CẢNH BÁO TỒN KHO</span>
                        <div class="kpi-icon-box" style="background: #fef2f2; color: #dc2626;">
                            <i class="bi bi-exclamation-triangle"></i>
                        </div>
                    </div>
                    <div class="kpi-main-val text-danger">${productStats.lowStockCount} <span class="kpi-unit">mã tồn thấp</span></div>
                    <div class="kpi-sub-text text-muted">
                        <i class="bi bi-box-seam" style="font-size: 0.45rem;"></i>
                        Dưới ngưỡng an toàn kho lạnh
                    </div>
                </div>
            </div>

            <!-- Segmented Tabs & Sort Bar -->
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
                <div class="d-flex align-items-center flex-wrap gap-2" id="modTabButtons">
                    <button class="tab-btn-pill active" onclick="switchModTab(this, 'all')">
                        Tất cả <span class="badge bg-light text-dark px-1 py-0 fs-8">${productStats.totalCount}</span>
                    </button>
                    <button class="tab-btn-pill" onclick="switchModTab(this, 'approved')">
                        Đang mở bán <span class="badge bg-success-subtle text-success px-1 py-0 fs-8">${productStats.activeCount}</span>
                    </button>
                    <button class="tab-btn-pill" onclick="switchModTab(this, 'pending')">
                        Chờ duyệt / Tạm ẩn <span class="badge bg-warning-subtle text-warning-emphasis px-1 py-0 fs-8">${productStats.inactiveCount}</span>
                    </button>
                    <button class="tab-btn-pill" onclick="switchModTab(this, 'safe')">
                        Đạt chuẩn VietGAP/GlobalGAP <span class="badge bg-light text-muted px-1 py-0 fs-8">${productStats.certifiedCount}</span>
                    </button>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <div class="dropdown">
                        <button class="custom-filter-select dropdown-toggle" type="button" data-bs-toggle="dropdown">
                            <i class="bi bi-arrow-down-up text-muted me-1"></i> Sắp xếp: Ưu tiên chứng nhận
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end shadow-sm fs-7">
                            <li><a class="dropdown-item active" href="javascript:void(0)" onclick="sortModerationFeed('risk')">Ưu tiên đạt chuẩn kiểm định</a></li>
                            <li><a class="dropdown-item" href="javascript:void(0)" onclick="sortModerationFeed('time_asc')">Thời gian: Mới nhất</a></li>
                            <li><a class="dropdown-item" href="javascript:void(0)" onclick="sortModerationFeed('price')">Giá niêm yết: Cao đến thấp</a></li>
                        </ul>
                    </div>
                </div>
            </div>

            <!-- Search & Filters Toolbar -->
            <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3 bg-white p-2 rounded-3 border">
                <div class="d-flex align-items-center flex-grow-1" style="min-width: 280px; max-width: 580px;">
                    <div class="input-group input-group-sm">
                        <span class="input-group-text bg-transparent border-0 text-muted ps-2 pe-1">
                            <i class="bi bi-search"></i>
                        </span>
                        <input type="text" id="modSearchInput" class="form-control border-0 shadow-none fs-7" 
                               placeholder="Tìm theo tên quả, mã SKU, tên nhà vườn, số chứng nhận Viet..." 
                               onkeyup="filterModCards()">
                    </div>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <select class="custom-filter-select" id="catFilterSelect" onchange="filterModCards()">
                        <option value="all">Tất cả ngành hàng</option>
                        <c:forEach items="${categoriesList}" var="c">
                            <option value="${c.categoryName}">${c.categoryName}</option>
                        </c:forEach>
                    </select>
                    <select class="custom-filter-select" id="riskFilterSelect" onchange="filterModCards()">
                        <option value="all">Tiêu chuẩn kiểm định: Tất cả</option>
                        <option value="safe">Đạt chuẩn VietGAP / GlobalGAP / Organic</option>
                        <option value="warning">Chưa có chứng nhận</option>
                    </select>
                </div>
            </div>

            <!-- MODERATION FEED CONTAINER (Real DB & Dynamic Cards) -->
            <div class="mod-feed-container" id="moderationCardsList">
                <c:choose>
                    <c:when test="${not empty productsList}">
                        <c:forEach items="${productsList}" var="p">
                            <div class="mod-card" data-category="${p.categoryName}" data-risk="${p.riskLevel}" data-status="${p.statusGroup}">
                                <div class="mod-card-top">
                                    <div class="mod-product-info">
                                        <div class="mod-thumb-wrapper">
                                            <img src="${p.thumbnailUrl}" 
                                                 alt="${p.productName}" class="mod-thumb-img">
                                        </div>
                                        <div>
                                            <div class="mod-title-row">
                                                <h4 class="mod-product-title">${p.productName} (${p.unit})</h4>
                                                <span class="badge ${p.modTagClass} border fw-bold px-2 py-1 fs-8">
                                                    <i class="bi ${p.modTagIcon} me-1"></i>${p.modTag}
                                                </span>
                                            </div>
                                            <div class="mod-meta-row">
                                                <span><strong>SKU:</strong> ${p.sku}</span>
                                                <span>• <i class="bi bi-shop text-primary"></i> <strong>Đơn vị:</strong> ${p.shopName}</span>
                                                <span>• <i class="bi bi-clock"></i> <strong>Gửi duyệt:</strong> ${p.timeAgo}</span>
                                                <span>• <strong>Giá đề xuất:</strong> <span class="text-success fw-bold">${p.priceFormatted}</span></span>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="badge-ai-risk ${p.riskBadgeClass}">
                                        <i class="bi ${p.riskBadgeIcon}"></i> ${p.riskBadgeText}
                                    </div>
                                </div>

                                <!-- 3 Sub-Inspection Boxes -->
                                <div class="mod-boxes-grid">
                                    <!-- Box 1 -->
                                    <div class="mod-sub-box ${p.riskLevel == 'high' ? 'tint-danger' : (p.riskLevel == 'warning' ? 'tint-warning' : '')}">
                                        <div class="mod-sub-box-title">
                                            <i class="bi bi-geo-alt text-success"></i> NGUỒN GỐC &amp; VÙNG TRỒNG
                                        </div>
                                        <div class="mod-box-line">
                                            <strong>Xuất xứ:</strong> ${p.origin}
                                        </div>
                                        <div class="mod-box-line">
                                            <strong>Bảo quản mát:</strong> ${p.storageTemp}
                                        </div>
                                        <div class="mod-box-line">
                                            <strong>Tồn kho kho lạnh:</strong> <span class="text-success fw-bold">${p.stockFormatted}</span>
                                        </div>
                                    </div>

                                    <!-- Box 2 -->
                                    <div class="mod-sub-box">
                                        <div class="mod-sub-box-title">
                                            <i class="bi bi-file-earmark-check text-primary"></i> HỒ SƠ KIỂM ĐỊNH CHẤT LƯỢNG
                                        </div>
                                        <div class="mod-box-line">
                                            <strong>Chứng nhận:</strong> <span class="badge bg-success-subtle text-success">${p.certification}</span>
                                        </div>
                                        <div class="mod-box-line">
                                            <strong>Ngành hàng:</strong> ${p.categoryName}
                                        </div>
                                        <div class="mod-box-line mt-auto">
                                            <a href="javascript:void(0)" onclick="previewPdfDoc('ho_so_${p.sku}.pdf')" class="text-primary text-decoration-none fw-semibold">
                                                <i class="bi bi-paperclip"></i> ho_so_kiem_dinh_${p.sku}.pdf
                                            </a>
                                        </div>
                                    </div>

                                    <!-- Box 3 -->
                                    <div class="mod-sub-box">
                                        <div class="mod-sub-box-title">
                                            <i class="bi bi-cpu text-info"></i> ĐỐI SOÁT CHẤT LƯỢNG &amp; TIÊU CHUẨN
                                        </div>
                                        <div class="mod-box-line">
                                            <strong>Đánh giá kiểm định:</strong> 
                                            <c:choose>
                                                <c:when test="${not empty p.certification}">
                                                    <span class="text-success fw-bold"><i class="bi bi-patch-check-fill"></i> ${p.certification}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-warning fw-bold"><i class="bi bi-exclamation-circle"></i> Đang chờ bổ sung hồ sơ</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="mod-box-line">
                                            <strong>Trạng thái hiển thị:</strong> ${p.isActive ? '<span class="text-success fw-semibold">Đang mở bán</span>' : '<span class="text-warning fw-semibold">Tạm ẩn / Đang xét duyệt</span>'}
                                        </div>
                                        <div class="mod-box-line">
                                            <strong>Phân hạng sản phẩm:</strong> ${p.isFeatured ? '<span class="badge bg-primary-subtle text-primary">Sản Phẩm Tiêu Biểu</span>' : 'Tiêu chuẩn sàn FreshFruit'}
                                        </div>
                                    </div>
                                </div>

                                <!-- Bottom Actions -->
                                <div class="mod-card-actions">
                                    <label class="form-check-label text-muted fs-7 d-flex align-items-center">
                                        <input type="checkbox" class="form-check-input me-1 mod-item-check" value="${p.sku}"> Chọn xử lý hàng loạt
                                    </label>
                                    <div class="d-flex align-items-center gap-2">
                                        <c:choose>
                                            <c:when test="${p.riskLevel == 'high'}">
                                                <button class="btn btn-outline-secondary btn-sm fw-bold bg-white text-dark" onclick="requestOriginProof('${p.sku}')">
                                                    <i class="bi bi-chat-left-dots me-1"></i> Yêu cầu chứng minh nguồn gốc
                                                </button>
                                                <button class="btn btn-danger btn-sm fw-bold" onclick="rejectAndLockSku('${p.sku}')">
                                                    <i class="bi bi-slash-circle me-1"></i> Từ chối &amp; Khóa SKU
                                                </button>
                                            </c:when>
                                            <c:otherwise>
                                                <button class="btn btn-outline-secondary btn-sm fw-bold bg-white text-dark" 
                                                        data-sku="${p.sku}" data-name="${p.productName} (${p.unit})" data-price="${p.priceFormatted}" 
                                                        data-img="${p.thumbnailUrl}" data-shop="${p.shopName}" data-cert="${p.certification}"
                                                        onclick="previewProductModal(this)">
                                                    <i class="bi bi-eye me-1"></i> Xem trước trang sản phẩm
                                                </button>
                                                <button class="btn btn-admin-primary btn-sm fw-bold" onclick="approveSku('${p.sku}')">
                                                    <i class="bi bi-check2-circle me-1"></i> Phê duyệt &amp; Bật hiển thị ngay
                                                </button>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-5 text-muted bg-white rounded-3 border">
                            <i class="bi bi-inbox fs-1 d-block mb-2"></i>
                            Hiện không có sản phẩm nào cần kiểm duyệt.
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- FreshGuard 3.0 Engine Bottom Banner -->
            <div class="freshguard-banner">
                <div class="d-flex align-items-center gap-3">
                    <div class="freshguard-icon-box">
                        <i class="bi bi-shield-check"></i>
                    </div>
                    <div>
                        <div class="freshguard-title">Cơ Chế Thẩm định AI &amp; Đối Soát Nông sản Quốc gia (FreshGuard 3.0)</div>
                        <div class="freshguard-desc">
                            <div>• Vision AI 3.0 tự động phát hiện ảnh tải mạng, ảnh dập mác trái phép, ảnh hoa quả qua chỉnh sửa màu sắc bất thường.</div>
                            <div>• Hệ thống tự động liên thông API Cục Bảo vệ Thực vật &amp; Cổng Dịch vụ công Quốc gia để tra cứu mã vùng trồng và số hiệu VietGAP.</div>
                        </div>
                    </div>
                </div>
                <div>
                    <button class="btn btn-outline-secondary btn-sm bg-white text-dark fw-bold border shadow-xs" onclick="updateQ4Standards()">
                        <i class="bi bi-gear-wide-connected me-1"></i> Cập nhật tiêu chuẩn kiểm duyệt Q4/2024
                    </button>
                </div>
            </div>

        </main>
    </div>
</div>

<!-- Modal: Quy chuẩn kiểm duyệt nông sản -->
<div class="modal fade" id="sopStandardModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header border-bottom">
                <div class="d-flex align-items-center gap-2">
                    <div class="bg-success-subtle text-success p-2 rounded-2">
                        <i class="bi bi-book-half fs-5"></i>
                    </div>
                    <div>
                        <h5 class="modal-title fw-bold mb-0">Quy Chuẩn Kiểm Duyệt Nông Sản &amp; Trái Cây Sàn FreshFruit</h5>
                        <div class="text-muted fs-8">Phiên bản ban hành FreshStandard v3.2 - Áp dụng từ 10/2024</div>
                    </div>
                </div>
                <button type="button" class="btn-close" data-bs-toggle="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div class="row g-3">
                    <div class="col-md-4">
                        <div class="border rounded-3 p-3 h-100 bg-light">
                            <div class="fw-bold text-success mb-2"><i class="bi bi-1-circle-fill me-1"></i> 1. Thị giác &amp; Hình ảnh</div>
                            <ul class="ps-3 mb-0 fs-7 text-muted">
                                <li>Hình ảnh phải do nhà vườn/gian hàng tự chụp thực tế.</li>
                                <li>Nghiêm cấm ảnh mạng, watermark của đối thủ.</li>
                                <li>Không áp bộ lọc màu quá mức sai lệch màu thịt quả.</li>
                            </ul>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="border rounded-3 p-3 h-100 bg-light">
                            <div class="fw-bold text-primary mb-2"><i class="bi bi-2-circle-fill me-1"></i> 2. Nguồn gốc &amp; Pháp lý</div>
                            <ul class="ps-3 mb-0 fs-7 text-muted">
                                <li>Mã vùng trồng (PUC) hợp lệ Cục BVTV cấp.</li>
                                <li>Giấy chứng nhận VietGAP / GlobalGAP còn thời hạn.</li>
                                <li>Hàng nhập khẩu bắt buộc có C/O và Giấy Kiểm dịch TV.</li>
                            </ul>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="border rounded-3 p-3 h-100 bg-light">
                            <div class="fw-bold text-danger mb-2"><i class="bi bi-3-circle-fill me-1"></i> 3. Nhãn mác &amp; An toàn</div>
                            <ul class="ps-3 mb-0 fs-7 text-muted">
                                <li>In rõ NSX, HSD dập nổi hoặc in laser.</li>
                                <li>Tem phụ Tiếng Việt cho toàn bộ hàng nhập khẩu.</li>
                                <li>Tồn dư thuốc BVTV âm tính theo quy định BYT.</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer border-top bg-light">
                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Đóng</button>
                <button type="button" class="btn btn-admin-primary btn-sm" onclick="alert('Đã tải tài liệu PDF quy chuẩn về máy.')">
                    <i class="bi bi-download me-1"></i> Tải trọn bộ SOP (PDF)
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Xem trước trang sản phẩm -->
<div class="modal fade" id="productPreviewModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header border-bottom">
                <h5 class="modal-title fw-bold">Xem Trước Trang Sản Phẩm Khách Hàng</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body text-center p-4">
                <div class="mb-3">
                    <img id="previewModalImg" src="" 
                         alt="Preview" class="rounded-3 border img-fluid" style="max-height: 200px; display: none;">
                </div>
                <h5 class="fw-bold mb-1" id="previewModalTitle"></h5>
                <div class="text-success fw-bold fs-5 mb-2" id="previewModalPrice"></div>
                <div class="text-muted fs-7" id="previewModalSub"></div>
            </div>
            <div class="modal-footer border-top">
                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Đóng</button>
                <button type="button" class="btn btn-admin-primary btn-sm" onclick="approveCurrentModalProduct()">
                    <i class="bi bi-check2-circle me-1"></i> Phê duyệt luôn
                </button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/admin.js?v=7"></script>
<script>
    // Tab switching
    function switchModTab(btn, statusKey) {
        document.querySelectorAll('#modTabButtons .tab-btn-pill').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');

        const cards = document.querySelectorAll('#moderationCardsList .mod-card');
        cards.forEach(card => {
            const cardStatus = card.getAttribute('data-status') || '';
            if (statusKey === 'all') {
                card.style.display = 'block';
            } else if (cardStatus.includes(statusKey)) {
                card.style.display = 'block';
            } else {
                card.style.display = 'none';
            }
        });
    }

    // Filter cards
    function filterModCards() {
        const query = (document.getElementById('modSearchInput').value || '').toLowerCase().trim();
        const catFilter = document.getElementById('catFilterSelect').value;
        const riskFilter = document.getElementById('riskFilterSelect').value;
        const cards = document.querySelectorAll('#moderationCardsList .mod-card');

        cards.forEach(card => {
            const text = card.textContent.toLowerCase();
            const category = card.getAttribute('data-category');
            const risk = card.getAttribute('data-risk');

            const matchQuery = !query || text.includes(query);
            const matchCat = catFilter === 'all' || category === catFilter;
            const matchRisk = riskFilter === 'all' || risk === riskFilter;

            if (matchQuery && matchCat && matchRisk) {
                card.style.display = 'block';
            } else {
                card.style.display = 'none';
            }
        });
    }

    // Sort feed
    function sortModerationFeed(type) {
        const list = document.getElementById('moderationCardsList');
        const cards = Array.from(list.children);
        if (type === 'risk') {
            cards.sort((a, b) => {
                const ra = a.getAttribute('data-risk') === 'high' ? 0 : (a.getAttribute('data-risk') === 'warning' ? 1 : 2);
                const rb = b.getAttribute('data-risk') === 'high' ? 0 : (b.getAttribute('data-risk') === 'warning' ? 1 : 2);
                return ra - rb;
            });
        }
        cards.forEach(card => list.appendChild(card));
        showToast('Đã sắp xếp danh sách theo tiêu chí đã chọn');
    }

    // Quick approve safe
    function quickApproveSafeProducts() {
        const safeCards = document.querySelectorAll('#moderationCardsList .mod-card[data-risk="safe"]');
        let count = 0;
        safeCards.forEach(c => {
            c.style.transition = 'all 0.5s ease';
            c.style.background = '#f0fdf4';
            c.style.borderColor = '#86efac';
            count++;
        });
        showToast('Đã phê duyệt nhanh ' + count + ' sản phẩm an toàn đạt điểm AI cao!');
    }

    // Approve SKU
    function approveSku(sku) {
        const card = findCardBySku(sku);
        if (card) {
            card.style.transition = 'all 0.4s ease';
            card.style.opacity = '0.4';
            setTimeout(() => {
                card.style.opacity = '1';
                card.style.background = '#f0fdf4';
                card.style.borderColor = '#86efac';
                const actions = card.querySelector('.mod-card-actions');
                if (actions) {
                    actions.innerHTML = '<span class="text-success fw-bold fs-7"><i class="bi bi-check-circle-fill me-1"></i> Đã phê duyệt & Đang hiển thị trực tiếp trên sàn</span>';
                }
            }, 300);
            showToast('Đã duyệt và kích hoạt hiển thị SKU: ' + sku);
        }
    }

    // Reject & lock SKU
    function rejectAndLockSku(sku) {
        if (confirm('Bạn có chắc chắn muốn từ chối và khóa mã SKU ' + sku + '?')) {
            const card = findCardBySku(sku);
            if (card) {
                card.style.background = '#fff1f2';
                card.style.borderColor = '#fca5a5';
                const actions = card.querySelector('.mod-card-actions');
                if (actions) {
                    actions.innerHTML = '<span class="text-danger fw-bold fs-7"><i class="bi bi-x-circle-fill me-1"></i> Đã từ chối & Khóa mã SKU trên hệ thống</span>';
                }
                showToast('Đã khóa và gửi thông báo từ chối cho nhà vườn!');
            }
        }
    }

    // Request origin proof
    function requestOriginProof(sku) {
        const msg = prompt('Nhập yêu cầu bổ sung chứng minh nguồn gốc gửi nhà vườn (HTX):', 'Yêu cầu cung cấp mã định danh vùng trồng PUC tại Tiền Giang và hóa đơn phôi giống Black Thorn.');
        if (msg) {
            showToast('Đã gửi thông báo yêu cầu tài liệu bổ sung đến nhà vườn.');
        }
    }

    // Request sub-label
    function requestSubLabel(sku) {
        showToast('Đã gửi thông báo yêu cầu bổ sung nhãn phụ & dập in HSD rõ nét đến HTX Mộc Châu.');
    }

    // Hide product temporary
    function hideProductTemporary(sku) {
        const card = findCardBySku(sku);
        if (card) {
            card.style.opacity = '0.5';
            showToast('Đã tạm ẩn sản phẩm ' + sku + ' trên sàn.');
        }
    }

    // Helper find card
    function findCardBySku(sku) {
        const cards = document.querySelectorAll('#moderationCardsList .mod-card');
        for (let c of cards) {
            if (c.textContent.includes(sku)) return c;
        }
        return null;
    }

    // Preview product modal
    let currentPreviewSku = '';
    function previewProductModal(btnOrSku) {
        let sku = '';
        if (typeof btnOrSku === 'object' && btnOrSku !== null) {
            sku = btnOrSku.getAttribute('data-sku') || '';
            const imgUrl = btnOrSku.getAttribute('data-img') || '';
            const name = btnOrSku.getAttribute('data-name') || '';
            const price = btnOrSku.getAttribute('data-price') || '';
            const shop = btnOrSku.getAttribute('data-shop') || '';
            const cert = btnOrSku.getAttribute('data-cert') || '';

            const imgEl = document.getElementById('previewModalImg');
            if (imgEl) {
                if (imgUrl) {
                    imgEl.src = imgUrl;
                    imgEl.style.display = 'inline-block';
                } else {
                    imgEl.style.display = 'none';
                }
            }
            const titleEl = document.getElementById('previewModalTitle');
            if (titleEl) titleEl.textContent = name;
            const priceEl = document.getElementById('previewModalPrice');
            if (priceEl) priceEl.textContent = price;
            const subEl = document.getElementById('previewModalSub');
            if (subEl) subEl.textContent = 'Gian hàng: ' + shop + (cert ? (' • ' + cert) : '');
        } else {
            sku = btnOrSku || '';
        }
        currentPreviewSku = sku;
        const myModal = new bootstrap.Modal(document.getElementById('productPreviewModal'));
        myModal.show();
    }

    function approveCurrentModalProduct() {
        const myModalEl = document.getElementById('productPreviewModal');
        const modal = bootstrap.Modal.getInstance(myModalEl);
        if (modal) modal.hide();
        if (currentPreviewSku) approveSku(currentPreviewSku);
    }

    // Preview PDF doc
    function previewPdfDoc(filename) {
        alert('Đang mở tài liệu xác thực: ' + filename + '\n(Hệ thống xác thực mã số qua Cổng Dịch Vụ Công Bộ Nông Nghiệp)');
    }

    // Edit sub tag modal
    function editSubTagModal(sku) {
        showToast('Mở trình chỉnh sửa tag phụ cho SKU: ' + sku);
    }

    // Update Q4 standards
    function updateQ4Standards() {
        showToast('Hệ thống FreshGuard 3.0 đã đồng bộ tiêu chuẩn kiểm duyệt Q4/2024 mới nhất từ Cục Bảo vệ Thực vật!');
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
