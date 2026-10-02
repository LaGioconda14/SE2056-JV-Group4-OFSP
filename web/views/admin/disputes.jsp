<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hòa Giải Khiếu Nại, Tranh Chấp & Hoàn Tiền - FreshFruit Admin</title>
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
        <jsp:param name="activePage" value="disputes" />
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
                <span class="text-dark fw-semibold">Hòa giải Khiếu nại &amp; Tranh chấp</span>
            </div>

            <!-- Page Title Row -->
            <div class="page-title-row mb-3 pb-1">
                <div class="page-title-wrapper">
                    <div class="d-flex align-items-center flex-wrap gap-2">
                        <h1 class="mb-0">Hòa Giải Khiếu Nại, Tranh Chấp &amp; Hoàn Tiền</h1>
                        <span class="badge bg-danger-subtle text-danger border border-danger-subtle rounded-pill px-2 py-1 fs-7 fw-bold">
                            5 CHỜ PHÁN QUYẾT
                        </span>
                    </div>
                    <p class="text-muted mt-1 mb-0 fs-7">
                        Trung tâm trọng tài sàn giải quyết các sự cố chất lượng nông sản (trái cây dập nát, hỏng úng, giao trễ) giữa Người mua và Gian hàng đối tác.
                    </p>
                </div>
                <div class="page-action-tools gap-2">
                    <button class="btn btn-outline-secondary btn-sm bg-white text-dark fw-bold border shadow-xs" onclick="exportDisputeData()">
                        <i class="bi bi-box-arrow-up me-1"></i> Xuất dữ liệu khiếu nại
                    </button>
                    <button class="btn btn-admin-primary btn-sm fw-bold shadow-xs" data-bs-toggle="modal" data-bs-target="#coldChainRulesModal">
                        <i class="bi bi-shield-check me-1"></i> Quy tắc bồi hoàn chuỗi lạnh
                    </button>
                </div>
            </div>

            <c:set var="firstDis" value="${not empty disputesList ? disputesList[0] : null}" />

            <!-- 4 KPI Summary Cards -->
            <div class="kpi-grid-4 mb-3">
                <!-- Card 1: Vụ việc chờ xử lý -->
                <div class="stat-card-kpi">
                    <div class="d-flex justify-content-between align-items-start">
                        <span class="kpi-label text-uppercase fw-bold text-muted fs-8">VỤ VIỆC CHỜ XỬ LÝ</span>
                        <div class="kpi-icon-box" style="background: #fef2f2; color: #dc2626;">
                            <i class="bi bi-exclamation-octagon"></i>
                        </div>
                    </div>
                    <div class="kpi-main-val">${not empty disputesList ? disputesList.size() : 3} <span class="kpi-unit">hồ sơ</span></div>
                    <div class="kpi-sub-text text-danger">
                        <i class="bi bi-circle-fill" style="font-size: 0.4rem;"></i>
                        Cần xử lý trong 24h bảo vệ khách
                    </div>
                </div>

                <!-- Card 2: Tiền hoàn đang đóng băng -->
                <div class="stat-card-kpi">
                    <div class="d-flex justify-content-between align-items-start">
                        <span class="kpi-label text-uppercase fw-bold text-muted fs-8">TIỀN HOÀN ĐANG ĐÓNG BĂNG</span>
                        <div class="kpi-icon-box" style="background: #fffbeb; color: #d97706;">
                            <i class="bi bi-lock-fill"></i>
                        </div>
                    </div>
                    <div class="kpi-main-val">₫890,000</div>
                    <div class="kpi-sub-text text-warning-emphasis">
                        <i class="bi bi-circle-fill" style="font-size: 0.4rem; color: #d97706;"></i>
                        Tạm giữ từ ví ký quỹ đối tác
                    </div>
                </div>

                <!-- Card 3: Thời gian xử lý trung bình -->
                <div class="stat-card-kpi">
                    <div class="d-flex justify-content-between align-items-start">
                        <span class="kpi-label text-uppercase fw-bold text-muted fs-8">THỜI GIAN XỬ LÝ TRUNG BÌNH</span>
                        <div class="kpi-icon-box" style="background: #f0fdf4; color: #16a34a;">
                            <i class="bi bi-lightning-charge-fill"></i>
                        </div>
                    </div>
                    <div class="kpi-main-val">4.2 <span class="kpi-unit">giờ</span></div>
                    <div class="kpi-sub-text text-success">
                        <i class="bi bi-check-circle-fill"></i>
                        SLA chuẩn nông sản &lt; 12 giờ
                    </div>
                </div>

                <!-- Card 4: Tỷ lệ đồng thuận hòa giải -->
                <div class="stat-card-kpi">
                    <div class="d-flex justify-content-between align-items-start">
                        <span class="kpi-label text-uppercase fw-bold text-muted fs-8">TỶ LỆ ĐỒNG THUẬN HÒA GIẢI</span>
                        <div class="kpi-icon-box" style="background: #f0fdf4; color: #16a34a;">
                            <i class="bi bi-shield-check"></i>
                        </div>
                    </div>
                    <div class="kpi-main-val">94.6%</div>
                    <div class="kpi-sub-text text-success">
                        <i class="bi bi-check-circle-fill"></i>
                        Khách &amp; Shop không leo thang cấp cao
                    </div>
                </div>
            </div>

            <!-- Segmented Tabs & Filters Toolbar -->
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
                <div class="d-flex align-items-center flex-wrap gap-2" id="disputeTabButtons">
                    <button class="tab-btn-pill active" onclick="switchDisputeTab(this, 'all')">
                        Tất cả <span class="badge bg-white text-success px-1 py-0 fs-8">${not empty disputesList ? disputesList.size() : 3}</span>
                    </button>
                    <button class="tab-btn-pill" onclick="switchDisputeTab(this, 'admin_decision')">
                        Chờ Admin phán quyết <span class="badge bg-light text-muted px-1 py-0 fs-8">1</span>
                    </button>
                    <button class="tab-btn-pill" onclick="switchDisputeTab(this, 'negotiating')">
                        Shop &amp; Khách đối soát <span class="badge bg-light text-muted px-1 py-0 fs-8">1</span>
                    </button>
                    <button class="tab-btn-pill" onclick="switchDisputeTab(this, 'refunded')">
                        Đã hoàn tiền <span class="badge bg-light text-muted px-1 py-0 fs-8">1</span>
                    </button>
                </div>
            </div>

            <!-- Search and Filter Bar -->
            <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3 bg-white p-2 rounded-3 border">
                <div class="d-flex align-items-center flex-grow-1" style="min-width: 280px; max-width: 480px;">
                    <div class="input-group input-group-sm">
                        <span class="input-group-text bg-transparent border-0 text-muted ps-2 pe-1">
                            <i class="bi bi-search"></i>
                        </span>
                        <input type="text" id="disputeSearchInput" class="form-control border-0 shadow-none fs-7" 
                               placeholder="Tìm theo Mã tranh chấp (DIS-...), Mã đơn hàng..." 
                               onkeyup="filterDisputeQueue()">
                    </div>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <select class="custom-filter-select" id="disputeReasonFilter" onchange="filterDisputeQueue()">
                        <option value="all">Lý do: Tất cả lý do</option>
                        <option value="Quả dập nát/úng hỏng">Lý do: Quả dập nát/úng hỏng</option>
                        <option value="Đứt gãy bảo quản lạnh">Lý do: Đứt gãy bảo quản lạnh</option>
                        <option value="Giao thiếu số lượng">Lý do: Giao thiếu số lượng</option>
                    </select>
                    <select class="custom-filter-select" id="disputeStatusFilter" onchange="filterDisputeQueue()">
                        <option value="all">Trạng thái: Tất cả trạng thái</option>
                        <option value="admin_decision">Trạng thái: Chờ phán quyết</option>
                        <option value="negotiating">Trạng thái: Đang đối soát</option>
                        <option value="refunded">Trạng thái: Đã hoàn tiền</option>
                    </select>
                    <button class="btn btn-outline-secondary btn-sm bg-white border" title="Bộ lọc nâng cao">
                        <i class="bi bi-funnel"></i>
                    </button>
                </div>
            </div>

            <!-- Main 2-Column Dispute Content Split -->
            <div class="row g-3">

                <!-- LEFT COLUMN: Active Case Details & Arbitration Action (~65%) -->
                <div class="col-lg-8">
                    <div class="admin-card p-3 mb-3">
                        
                        <!-- Top Case Header Box -->
                        <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 pb-3 mb-3 border-bottom">
                            <div class="d-flex align-items-center gap-2">
                                <span class="badge bg-danger-subtle text-danger fw-bold fs-7 px-2 py-1 border border-danger-subtle rounded-2" id="detailDisCode">
                                    ${not empty firstDis ? firstDis.disputeCode : 'DIS-892'}
                                </span>
                                <div>
                                    <h4 class="fw-bold mb-0 text-dark" style="font-size: 1.05rem;" id="detailOrderCode">
                                        Đơn hàng ${not empty firstDis ? firstDis.orderCode : '#ORD-2024-8819'}
                                    </h4>
                                    <div class="text-muted fs-8" id="detailTimeInfo">
                                        Khởi tạo lúc ${not empty firstDis ? firstDis.createdFormatted : 'Hôm nay'} • <span class="text-danger fw-semibold"><i class="bi bi-clock"></i> SLA: 03:45:12</span>
                                    </div>
                                </div>
                            </div>
                            <div>
                                <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-2 py-1 fs-8 fw-bold" id="detailStatusPill">
                                    ${not empty firstDis ? firstDis.statusPill : 'CẦN ADMIN PHÁN QUYẾT'}
                                </span>
                            </div>
                        </div>

                        <!-- 2 Parties Summary (Buyer & Seller) Side-by-Side -->
                        <div class="row g-3 mb-3">
                            <!-- Party 1: Người mua -->
                            <div class="col-md-6">
                                <div class="dispute-party-card h-100">
                                    <div class="d-flex align-items-center justify-content-between mb-2">
                                        <div class="d-flex align-items-center gap-2">
                                            <div class="bg-success text-white rounded-circle d-flex align-items-center justify-content-center fw-bold fs-7" style="width: 32px; height: 32px;" id="detailBuyerInitials">
                                                ${not empty firstDis ? firstDis.initials : 'NH'}
                                            </div>
                                            <div>
                                                <div class="fw-bold text-dark fs-7" id="detailBuyerName">${not empty firstDis ? firstDis.customerName : 'Nguyễn Thu Hà'}</div>
                                                <div class="text-success fs-8 fw-semibold">VIP Gold (Khách quen)</div>
                                            </div>
                                        </div>
                                        <span class="badge bg-light text-muted border fs-8">Người mua</span>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center mt-2 pt-2 border-top">
                                        <span class="text-muted fs-7">Yêu cầu bồi hoàn:</span>
                                        <span class="text-danger fw-bold fs-6" id="detailBuyerClaim">${not empty firstDis ? firstDis.claimAmountFormatted : '₫420,000'} (100%)</span>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center mt-1">
                                        <span class="text-muted fs-8">Phương thức:</span>
                                        <span class="text-dark fw-semibold fs-8">Hoàn lại vào Ví FreshPay</span>
                                    </div>
                                </div>
                            </div>

                            <!-- Party 2: Gian hàng -->
                            <div class="col-md-6">
                                <div class="dispute-party-card h-100">
                                    <div class="d-flex align-items-center justify-content-between mb-2">
                                        <div class="d-flex align-items-center gap-2">
                                            <div class="bg-light border text-primary rounded-2 d-flex align-items-center justify-content-center fw-bold fs-7" style="width: 32px; height: 32px;">
                                                <i class="bi bi-shop"></i>
                                            </div>
                                            <div>
                                                <div class="fw-bold text-dark fs-7" id="detailShopName">${not empty firstDis ? firstDis.shopName : 'HTX Sầu Riêng Tiền Giang'}</div>
                                                <div class="text-muted fs-8">Điểm uy tín: 96/100 (${not empty firstDis ? firstDis.shopRating : '4.8 ★'})</div>
                                            </div>
                                        </div>
                                        <span class="badge bg-light text-muted border fs-8">Gian hàng</span>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center mt-2 pt-2 border-top">
                                        <span class="text-muted fs-7">Đề xuất từ Shop:</span>
                                        <span class="text-danger fw-bold fs-6" id="detailShopOffer">${not empty firstDis ? firstDis.shopOfferFormatted : '₫210,000'} (50%)</span>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center mt-1">
                                        <span class="text-muted fs-8">Lý do Shop đưa ra:</span>
                                        <span class="text-dark fw-semibold fs-8 text-truncate" style="max-width: 170px;" title="Quả xuất vườn vẫn đạt chuẩn, hỗ trợ thiện chí">Quả xuất vườn vẫn đ...</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Chi tiết sự cố & Bằng chứng giám định -->
                        <div class="mb-3">
                            <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-2">
                                <div class="fw-bold text-dark fs-7 d-flex align-items-center">
                                    <i class="bi bi-exclamation-triangle-fill text-danger me-2"></i>
                                    Chi tiết sự cố &amp; Bằng chứng giám định
                                </div>
                                <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-2 py-1 fs-8" id="detailIncidentTag">
                                    Lý do: ${not empty firstDis ? firstDis.reasonCategory : 'Quả dập nát/úng hỏng'}
                                </span>
                            </div>
                            
                            <!-- Customer Statement -->
                            <div class="p-3 rounded-3 bg-light border mb-3 fs-7 text-secondary fst-italic" id="detailStatement">
                                "${not empty firstDis ? firstDis.complaintText : 'Tôi nhận 2 hộp sầu riêng Ri6 nhưng múi bên trong bị chua ủng, có mùi rượu lên men không thể ăn được. Yêu cầu bồi hoàn.'}"
                            </div>

                            <!-- Evidence Media Gallery (3 Thumbnails) -->
                            <div class="row g-2" id="detailEvidenceGallery">
                                <div class="col-4">
                                    <div class="dispute-evidence-thumb" onclick="viewEvidenceModal('Ảnh bằng chứng khách gửi (Ảnh 1)', document.getElementById('detailEvidenceThumbImg').src)">
                                        <img src="${not empty firstDis ? firstDis.evidenceImageUrl : 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400'}" 
                                             alt="Ảnh 1" class="dispute-evidence-img" id="detailEvidenceThumbImg">
                                        <div class="dispute-evidence-overlay">
                                            <span><i class="bi bi-camera me-1"></i> Bằng chứng chụp thực tế</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-4">
                                    <div class="dispute-evidence-thumb" onclick="viewEvidenceModal('Cuống thối sâu (Ảnh 2)', 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=600&h=400&fit=crop')">
                                        <img src="https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&h=200&fit=crop" 
                                             alt="Ảnh 2" class="dispute-evidence-img">
                                        <div class="dispute-evidence-overlay">
                                            <span><i class="bi bi-camera me-1"></i> Cuống thối sâu (Ảnh 2)</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-4">
                                    <div class="dispute-evidence-thumb" onclick="viewEvidenceModal('Video mở hộp (01:42)', 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600&h=400&fit=crop')">
                                        <img src="https://images.unsplash.com/photo-1542838132-92c53300491e?w=300&h=200&fit=crop" 
                                             alt="Video mở hộp" class="dispute-evidence-img">
                                        <div class="dispute-evidence-overlay">
                                            <span><i class="bi bi-play-circle-fill text-warning me-1"></i> Video mở hộp (01:42)</span>
                                            <span class="badge bg-danger px-1 py-0 fs-8">HD</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Phán quyết Trọng Tài Sàn FreshFruit -->
                        <div class="dispute-arbitration-box mb-3" id="arbitrationDecisionBox">
                            <div class="d-flex align-items-center gap-2 mb-2">
                                <i class="bi bi-shield-check text-success fs-5"></i>
                                <h5 class="fw-bold text-dark mb-0 fs-7">Phán quyết Trọng Tài Sàn FreshFruit</h5>
                            </div>
                            <div class="text-muted fs-8 mb-2">Kết luận thẩm định chất lượng nông sản:</div>
                            
                            <div class="p-2 rounded-2 bg-light border mb-3 fs-7 text-dark" id="detailArbitrationText">
                                ${not empty firstDis ? firstDis.resolutionNote : 'Hồ sơ khiếu nại đang được hội đồng trọng tài sàn FreshFruit kiểm duyệt đối soát dữ liệu đóng gói cùng camera giao nhận vận chuyển.'}
                            </div>

                            <!-- 3 Arbitration Action Buttons -->
                            <div class="d-flex align-items-center flex-wrap gap-2">
                                <button class="btn btn-admin-primary btn-sm fw-bold px-3 py-2 shadow-xs" onclick="arbitrateApproveFull()">
                                    <i class="bi bi-check2-circle me-1"></i> Phán quyết hoàn 100% (<span id="detailArbitrateAmount">${not empty firstDis ? firstDis.claimAmountFormatted : '₫420,000'}</span>)
                                </button>
                                <button class="btn btn-outline-primary btn-sm fw-bold bg-white text-primary border px-3 py-2" onclick="arbitrateRequestMoreInfo()">
                                    <i class="bi bi-clock-history me-1"></i> Yêu cầu Shop bổ sung giải trình
                                </button>
                                <button class="btn btn-outline-danger btn-sm fw-bold bg-white text-danger border px-3 py-2" onclick="arbitrateRejectClaim()">
                                    <i class="bi bi-x-circle me-1"></i> Bác bỏ yêu cầu
                                </button>
                            </div>

                            <div class="text-muted fs-8 mt-2 d-flex align-items-center gap-1">
                                <i class="bi bi-exclamation-triangle text-warning"></i>
                                Lưu ý: Phán quyết hoàn tiền sẽ tự động trích ₫680,000 từ Ví ký quỹ của gian hàng và trừ 2 điểm uy tín vận hành.
                            </div>
                        </div>

                        <!-- Lịch Sử Đối Thoại & Nhật Ký Hệ Thống -->
                        <div>
                            <div class="d-flex align-items-center justify-content-between mb-3">
                                <div class="fw-bold text-dark fs-7 d-flex align-items-center">
                                    <i class="bi bi-chat-left-dots text-success me-2"></i>
                                    Lịch Sử Đối Thoại &amp; Nhật Ký Hệ Thống
                                </div>
                                <span class="badge bg-light text-muted border fs-8">4 bản ghi</span>
                            </div>

                            <div class="timeline-dispute-list" id="timelineDisputeList">
                                <!-- Entry 1 -->
                                <div class="timeline-item-dispute">
                                    <div class="timeline-avatar-box bg-danger-subtle text-danger">
                                        <i class="bi bi-exclamation"></i>
                                    </div>
                                    <div class="timeline-content-bubble">
                                        <div class="d-flex justify-content-between align-items-center mb-1">
                                            <strong class="text-dark">Hoàng Lan Anh (Người mua)</strong>
                                            <span class="text-muted fs-8">09:14 Hôm nay</span>
                                        </div>
                                        <div>Đã mở yêu cầu khiếu nại hoàn tiền 100% kèm 3 ảnh và 1 video clip tách sầu riêng</div>
                                    </div>
                                </div>

                                <!-- Entry 2 -->
                                <div class="timeline-item-dispute">
                                    <div class="timeline-avatar-box bg-light text-primary border">
                                        <i class="bi bi-shop"></i>
                                    </div>
                                    <div class="timeline-content-bubble">
                                        <div class="d-flex justify-content-between align-items-center mb-1">
                                            <strong class="text-dark">Sầu Riêng Ri6 Đắk Lắk (Gian hàng)</strong>
                                            <span class="text-muted fs-8">10:02 Hôm nay</span>
                                        </div>
                                        <div class="fst-italic text-secondary">"Dạ chào bạn, sầu riêng cắt vườn già 8.5 tuổi quá chín tự nhiên. Phần múi bị sầu bên mình xin lỗi và xin bồi hoàn 50% tiền để hỗ trợ quý khách ạ."</div>
                                    </div>
                                </div>

                                <!-- Entry 3 -->
                                <div class="timeline-item-dispute">
                                    <div class="timeline-avatar-box bg-primary-subtle text-primary">
                                        <i class="bi bi-person-fill"></i>
                                    </div>
                                    <div class="timeline-content-bubble">
                                        <div class="d-flex justify-content-between align-items-center mb-1">
                                            <strong class="text-dark">Hoàng Lan Anh (Người mua)</strong>
                                            <span class="text-muted fs-8">10:18 Hôm nay</span>
                                        </div>
                                        <div class="fst-italic text-secondary">"Quả bị sượng nước hoàn toàn không ăn được múi nào chứ không chỉ riêng múi sâu. Tôi từ chối đề xuất 50% và yêu cầu Sàn can thiệp hoàn 100%."</div>
                                    </div>
                                </div>

                                <!-- Entry 4 -->
                                <div class="timeline-item-dispute">
                                    <div class="timeline-avatar-box bg-success text-white">
                                        <i class="bi bi-shield-lock-fill"></i>
                                    </div>
                                    <div class="timeline-content-bubble bg-success-subtle border-success-subtle">
                                        <div class="d-flex justify-content-between align-items-center mb-1">
                                            <strong class="text-success-emphasis">FreshFruit SuperAdmin (Sarah Jenkins)</strong>
                                            <span class="text-muted fs-8">10:45 Hôm nay</span>
                                        </div>
                                        <div class="text-success-emphasis">Đã tiếp nhận hồ sơ sang giai đoạn phán quyết trọng tài cấp sàn. Tạm phong tỏa ₫680,000 trong ví đối tác.</div>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>

                <!-- RIGHT COLUMN: Dispute Queue & FreshFruit Policy (~35%) -->
                <div class="col-lg-4">
                    <div class="admin-card p-3 mb-3">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <h4 class="fw-bold mb-0 text-dark" style="font-size: 0.95rem;">Danh sách khiếu nại</h4>
                            <span class="text-success fs-8 fw-semibold"><i class="bi bi-arrow-repeat me-1"></i> Cập nhật 10:51</span>
                        </div>
                        <p class="text-muted fs-8 mb-3">Chọn một vụ việc để xem bằng chứng và ra phán quyết trọng tài.</p>

                        <!-- Dispute Queue Cards List -->
                        <div id="disputeQueueContainer">
                            <c:choose>
                                <c:when test="${not empty disputesList}">
                                    <c:forEach items="${disputesList}" var="d" varStatus="loop">
                                        <div class="dispute-queue-item ${loop.first ? 'active' : ''}" 
                                             onclick="selectDisputeItem(this, '${d.disputeCode}')" 
                                             data-code="${d.disputeCode}" 
                                             data-order="${d.orderCode}" 
                                             data-reason="${d.reasonCategory}" 
                                             data-status="${d.statusGroup}">
                                            <div class="d-flex justify-content-between align-items-center mb-1">
                                                <span class="badge bg-danger-subtle text-danger fw-bold fs-8">${d.disputeCode}</span>
                                                <span class="badge bg-danger-subtle text-danger border border-danger-subtle fs-8">${d.statusPill}</span>
                                            </div>
                                            <div class="fw-bold text-dark fs-7 mb-1 text-truncate">${d.reasonCategory}</div>
                                            <div class="text-muted fs-8 mb-2">Khách: ${d.customerName} • Shop: ${d.shopName}</div>
                                            <div class="d-flex justify-content-between align-items-center pt-2 border-top">
                                                <strong class="text-danger fs-7">${d.claimAmountFormatted}</strong>
                                                <span class="text-muted fs-8"><i class="bi bi-clock"></i> ${d.createdFormatted}</span>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-center py-4 text-muted fs-7">
                                        <i class="bi bi-inbox fs-2 d-block mb-2"></i>
                                        Hiện không có khiếu nại tranh chấp nào cần giải quyết.
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <!-- Green Policy Box: Cam Kết 100% Tươi Ngon -->
                    <div class="green-policy-card shadow-sm">
                        <div class="d-flex align-items-center gap-2 mb-2">
                            <i class="bi bi-shield-check fs-5 text-white"></i>
                            <h5 class="fw-bold text-white mb-0 fs-7">Cam Kết 100% Tươi Ngon</h5>
                        </div>
                        <p class="text-light fs-8 mb-3" style="line-height: 1.5; opacity: 0.9;">
                            Quy chế bảo vệ người tiêu dùng FreshFruit: Hoa quả hư hao trên 20% khi bóc hộp được quyền đổi hoàn 1 đổi 1 hoặc hoàn tiền trong vòng 24 giờ.
                        </p>
                        <div class="d-flex justify-content-between align-items-center pt-2 border-top border-success-subtle">
                            <span class="badge bg-white text-success fw-bold fs-8">PHẢN HỒI TỰ ĐỘNG: 8 GIỜ</span>
                            <a href="javascript:void(0)" onclick="openPolicyModal()" class="text-white text-decoration-underline fs-8 fw-semibold">Chi tiết quy chế</a>
                        </div>
                    </div>

                </div>

            </div>

            <!-- Bottom Full-Width Guarantee Banner -->
            <div class="freshguard-banner mt-3">
                <div class="d-flex align-items-center gap-3">
                    <div class="freshguard-icon-box" style="background: #dcfce7; color: #15803d;">
                        <i class="bi bi-shield-check"></i>
                    </div>
                    <div>
                        <div class="freshguard-title">Chính Sách Bảo Hành Độ Tươi FreshFruit 100% &amp; Ký Quỹ Bảo Lãnh Gian Hàng</div>
                        <div class="freshguard-desc">
                            Mỗi gian hàng trên FreshFruit đều duy trì tài khoản ký quỹ tối thiểu ₫10,000,000. Nếu gian hàng không phản hồi các khiếu nại chất lượng nông sản tươi trong vòng 8 giờ kể từ khi khách báo cáo, hệ thống Trọng tài thông minh sẽ tự động hoàn 100% số tiền cho khách hàng và ghi nhận cảnh cáo vi phạm cấp 1.
                        </div>
                    </div>
                </div>
                <div>
                    <button class="btn btn-outline-secondary btn-sm bg-white text-dark fw-bold border shadow-xs" onclick="openHandbookModal()">
                        Xem sổ tay Trọng tài
                    </button>
                </div>
            </div>

        </main>
    </div>
</div>

<!-- Modal: Bằng chứng hình ảnh/video phóng to -->
<div class="modal fade" id="evidencePreviewModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header border-bottom">
                <h5 class="modal-title fw-bold" id="evidenceModalTitle">Xem Bằng Chứng Giám Định</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body text-center p-3">
                <img id="evidenceModalImg" src="" alt="Evidence" class="img-fluid rounded-3 border" style="max-height: 480px;">
                <div class="text-muted fs-8 mt-2">Dữ liệu tệp đính kèm mã SHA-256 đã đóng dấu thời gian bảo mật chuỗi khối FreshFruit.</div>
            </div>
            <div class="modal-footer border-top bg-light">
                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Đóng</button>
                <button type="button" class="btn btn-admin-primary btn-sm" onclick="alert('Đã tải hình ảnh bằng chứng về máy tính')">
                    <i class="bi bi-download me-1"></i> Tải ảnh gốc
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Quy tắc bồi hoàn chuỗi lạnh -->
<div class="modal fade" id="coldChainRulesModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header border-bottom">
                <div class="d-flex align-items-center gap-2">
                    <div class="bg-success-subtle text-success p-2 rounded-2">
                        <i class="bi bi-snow2 fs-5"></i>
                    </div>
                    <div>
                        <h5 class="modal-title fw-bold mb-0">Quy Tắc Bồi Hoàn &amp; Trách Nhiệm Chuỗi Lạnh FreshFruit</h5>
                        <div class="text-muted fs-8">Cập nhật theo Quyết định Ban Trọng Tài Nông Sản 2024</div>
                    </div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div class="row g-3">
                    <div class="col-md-4">
                        <div class="border rounded-3 p-3 bg-light h-100">
                            <div class="fw-bold text-success mb-2"><i class="bi bi-thermometer-half"></i> 1. Đứt gãy bảo quản</div>
                            <div class="fs-7 text-muted">Nếu nhiệt độ thùng hàng vận chuyển vượt quá ngưỡng cho phép (&gt;15°C đối với trái cây nhạy cảm như dâu tây, nho) dẫn đến hỏng, đơn vị vận chuyển chịu 70% trách nhiệm bồi hoàn.</div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="border rounded-3 p-3 bg-light h-100">
                            <div class="fw-bold text-primary mb-2"><i class="bi bi-flower1"></i> 2. Lỗi ruột bên trong</div>
                            <div class="fs-7 text-muted">Với các loại quả vỏ dày như sầu riêng, dưa lưới, bưởi mà bên trong bị thối, sâu hoặc sượng đắng không phát hiện được qua ngoại quan, nhà vườn chịu 100% bồi hoàn.</div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="border rounded-3 p-3 bg-light h-100">
                            <div class="fw-bold text-danger mb-2"><i class="bi bi-stopwatch"></i> 3. Thời hạn khiếu nại</div>
                            <div class="fs-7 text-muted">Khách hàng được quyền gửi khiếu nại trong vòng 24 giờ kể từ khi ký nhận hàng thành công, có video mở hộp đối soát nguyên vẹn.</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer border-top bg-light">
                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/admin.js?v=7"></script>
<script>
    // Tab switching
    function switchDisputeTab(btn, statusKey) {
        document.querySelectorAll('#disputeTabButtons .tab-btn-pill').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');

        const items = document.querySelectorAll('#disputeQueueContainer .dispute-queue-item');
        items.forEach(item => {
            const itemStatus = item.getAttribute('data-status') || '';
            if (statusKey === 'all') {
                item.style.display = 'block';
            } else if (itemStatus.includes(statusKey)) {
                item.style.display = 'block';
            } else {
                item.style.display = 'none';
            }
        });
    }

    // Filter queue
    function filterDisputeQueue() {
        const query = (document.getElementById('disputeSearchInput').value || '').toLowerCase().trim();
        const reason = document.getElementById('disputeReasonFilter').value;
        const items = document.querySelectorAll('#disputeQueueContainer .dispute-queue-item');

        items.forEach(item => {
            const text = item.textContent.toLowerCase();
            const itemReason = item.getAttribute('data-reason');

            const matchQuery = !query || text.includes(query);
            const matchReason = reason === 'all' || itemReason === reason;

            if (matchQuery && matchReason) {
                item.style.display = 'block';
            } else {
                item.style.display = 'none';
            }
        });
    }

    // Select queue item
    const disputeDatabase = {
        <c:forEach items="${disputesList}" var="d" varStatus="loop">
        '${d.disputeCode}': {
            order: '${d.orderCode}',
            time: 'Khởi tạo lúc ${d.createdFormatted} • <span class="text-danger fw-semibold"><i class="bi bi-clock"></i> SLA: 03:45:12</span>',
            statusPill: '${d.statusPill}',
            buyerName: '${d.customerName}',
            buyerClaim: '${d.claimAmountFormatted} (100%)',
            shopName: '${d.shopName}',
            shopOffer: '${d.shopOfferFormatted} (50%)',
            incidentTag: 'Lý do: ${d.reasonCategory}',
            statement: "${fn:replace(d.complaintText, '\"', '\\\"')}",
            arbitration: "${fn:replace(d.resolutionNote, '\"', '\\\"')}",
            initials: '${d.initials}',
            evidenceImg: '${d.evidenceImageUrl}',
            claimFormatted: '${d.claimAmountFormatted}'
        }${!loop.last ? ',' : ''}
        </c:forEach>
    };

    function selectDisputeItem(el, code) {
        document.querySelectorAll('#disputeQueueContainer .dispute-queue-item').forEach(i => i.classList.remove('active'));
        el.classList.add('active');

        const data = disputeDatabase[code];
        if (data) {
            document.getElementById('detailDisCode').textContent = code;
            document.getElementById('detailOrderCode').textContent = 'Đơn hàng ' + data.order;
            document.getElementById('detailTimeInfo').innerHTML = data.time;
            document.getElementById('detailStatusPill').textContent = data.statusPill;
            document.getElementById('detailBuyerName').textContent = data.buyerName;
            document.getElementById('detailBuyerClaim').textContent = data.buyerClaim;
            document.getElementById('detailShopName').textContent = data.shopName;
            document.getElementById('detailShopOffer').textContent = data.shopOffer;
            document.getElementById('detailIncidentTag').textContent = data.incidentTag;
            document.getElementById('detailStatement').textContent = data.statement;
            document.getElementById('detailArbitrationText').textContent = data.arbitration;
            const buyerInitials = document.getElementById('detailBuyerInitials');
            if (buyerInitials && data.initials) buyerInitials.textContent = data.initials;
            const evImg = document.getElementById('detailEvidenceThumbImg');
            if (evImg && data.evidenceImg) evImg.src = data.evidenceImg;
            const arbAmt = document.getElementById('detailArbitrateAmount');
            if (arbAmt && data.claimFormatted) arbAmt.textContent = data.claimFormatted;
        }
    }

    // Arbitration actions
    function arbitrateApproveFull() {
        const box = document.getElementById('arbitrationDecisionBox');
        box.style.background = '#f0fdf4';
        box.style.borderColor = '#16a34a';
        showToast('ĐÃ RA PHÁN QUYẾT: Chấp thuận hoàn 100% tiền cho Người mua. Tiền đã tự động chuyển vào Ví FreshPay!');
    }

    function arbitrateRequestMoreInfo() {
        const reason = prompt('Nhập nội dung yêu cầu Gian hàng cung cấp giải trình:', 'Yêu cầu gửi ảnh camera đóng hàng tại kho trước khi bàn giao Shipper.');
        if (reason) {
            showToast('Đã gửi thông báo yêu cầu giải trình đến Gian hàng. Gia hạn SLA thêm 4 giờ.');
        }
    }

    function arbitrateRejectClaim() {
        if (confirm('Bạn có chắc chắn muốn bác bỏ yêu cầu khiếu nại này và trả tiền cho gian hàng?')) {
            showToast('Đã bác bỏ yêu cầu khiếu nại. Hệ thống giải phóng tiền tạm giữ về ví gian hàng.');
        }
    }

    // View evidence modal
    function viewEvidenceModal(title, imgUrl) {
        document.getElementById('evidenceModalTitle').textContent = title;
        document.getElementById('evidenceModalImg').src = imgUrl;
        const myModal = new bootstrap.Modal(document.getElementById('evidencePreviewModal'));
        myModal.show();
    }

    // Export dispute data
    function exportDisputeData() {
        showToast('Đang kết xuất báo cáo khiếu nại & tranh chấp dạng Excel (XLSX)...');
    }

    function openPolicyModal() {
        const myModal = new bootstrap.Modal(document.getElementById('coldChainRulesModal'));
        myModal.show();
    }

    function openHandbookModal() {
        alert('Đang mở Sổ tay Trọng tài Giải quyết Tranh chấp Nông sản Sàn FreshFruit (Phiên bản v2.4).');
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
