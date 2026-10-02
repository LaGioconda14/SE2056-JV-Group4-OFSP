<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FreshFruit - Quản Lý Danh Mục Ngành Hàng (Global Categories)</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css?v=13">
</head>
<body class="admin-body">

<div class="admin-wrapper">
    <jsp:include page="layout/sidebar.jsp">
        <jsp:param name="activePage" value="categories" />
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
                            <li class="breadcrumb-item text-muted">Ngành hàng</li>
                            <li class="breadcrumb-item active text-success fw-bold" aria-current="page">Cấu hình Danh mục</li>
                        </ol>
                    </nav>
                    <h1 class="users-header-title">Quản Lý Danh Mục Ngành Hàng (Global Categories)</h1>
                    <p class="users-header-desc">Cấu hình cây danh mục trái cây toàn sàn, phân loại tiêu chuẩn chất lượng, mùa vụ thu hoạch và định mức phí hoa hồng (Take Rate).</p>
                </div>
                <div class="users-header-actions">
                    <button type="button" class="btn-export-list" onclick="alert('Đang mở chế độ sắp xếp thứ tự danh mục hiển thị...');">
                        <i class="bi bi-list-task"></i>
                        <span>Sắp xếp hiển thị ngoài sàn</span>
                    </button>
                    <button type="button" class="btn-add-admin" onclick="alert('Đang mở giao diện tạo mới danh mục...');">
                        <i class="bi bi-plus-circle-fill"></i>
                        <span>Thêm Danh mục Mới</span>
                    </button>
                </div>
            </div>

            <!-- 2. 4 Summary Metric Cards -->
            <div class="shops-summary-grid">
                <!-- Card 1: DANH MỤC CHÍNH (CẤP 1) -->
                <div class="user-summary-card">
                    <div class="d-flex align-items-center justify-content-between mb-1">
                        <span class="user-summary-title text-uppercase" style="letter-spacing: 0.04em;">DANH MỤC CHÍNH (CẤP 1)</span>
                        <div class="user-summary-icon-box bg-green-subtle">
                            <i class="bi bi-diagram-3"></i>
                        </div>
                    </div>
                    <div class="user-summary-val">${not empty categoriesList ? categoriesList.size() : 6} <span class="fs-6 fw-normal text-muted">Ngành hàng</span></div>
                    <div class="text-success d-flex align-items-center gap-1" style="font-size: 0.72rem;">
                        <i class="bi bi-check-circle-fill"></i> 100% đang hiển thị live
                    </div>
                </div>

                <!-- Card 2: DANH MỤC PHỤ (CẤP 2) -->
                <div class="user-summary-card">
                    <div class="d-flex align-items-center justify-content-between mb-1">
                        <span class="user-summary-title text-uppercase" style="letter-spacing: 0.04em;">DANH MỤC PHỤ (CẤP 2)</span>
                        <div class="user-summary-icon-box bg-purple-subtle">
                            <i class="bi bi-share"></i>
                        </div>
                    </div>
                    <div class="user-summary-val">28 <span class="fs-6 fw-normal text-muted">Phân loại quả</span></div>
                    <div class="text-muted d-flex align-items-center gap-1" style="font-size: 0.72rem;">
                        <i class="bi bi-box-seam"></i> 350+ sản phẩm liên kết sàn
                    </div>
                </div>

                <!-- Card 3: MÙA VỤ ĐANG THU HOẠCH -->
                <div class="user-summary-card">
                    <div class="d-flex align-items-center justify-content-between mb-1">
                        <span class="user-summary-title text-uppercase" style="letter-spacing: 0.04em;">MÙA VỤ ĐANG THU HOẠCH</span>
                        <div class="user-summary-icon-box" style="background: #ffedd5; color: #ea580c;">
                            <i class="bi bi-flower1"></i>
                        </div>
                    </div>
                    <div class="user-summary-val">8 <span class="fs-6 fw-normal text-muted">Loại quả chính vụ</span></div>
                    <div class="text-muted text-truncate" style="font-size: 0.72rem;" title="Táo Envy, Bơ 034, Sầu Riêng, Xoài Cát...">
                        Táo Envy, Bơ 034, Sầu Riên...
                    </div>
                </div>

                <!-- Card 4: TAKE RATE TRUNG BÌNH -->
                <div class="user-summary-card">
                    <div class="d-flex align-items-center justify-content-between mb-1">
                        <span class="user-summary-title text-uppercase" style="letter-spacing: 0.04em;">TAKE RATE TRUNG BÌNH</span>
                        <div class="user-summary-icon-box bg-green-subtle">
                            <i class="bi bi-percent"></i>
                        </div>
                    </div>
                    <div class="user-summary-val">5.0%</div>
                    <div class="text-muted d-flex align-items-center gap-1" style="font-size: 0.72rem;">
                        <i class="bi bi-graph-up"></i> Biên độ dao động: 3.5% - 8.0%
                    </div>
                </div>
            </div>

            <!-- 3. Main Two-Column Layout (Left 1/3, Right 2/3) -->
            <div class="cat-main-layout">
                <!-- Left Column: Cây Danh Mục & Độ Phủ -->
                <div>
                    <!-- Card 1: Cây Danh Mục Toàn Sàn -->
                    <div class="cat-sidebar-card">
                        <div class="d-flex align-items-center justify-content-between mb-3">
                            <div class="d-flex align-items-center gap-2">
                                <i class="bi bi-diagram-3-fill text-success"></i>
                                <strong class="text-dark" style="font-size: 0.85rem;">Cây Danh Mục Toàn Sàn</strong>
                            </div>
                            <span class="badge bg-light text-muted border" style="font-size: 0.65rem;">6 Cấp 1</span>
                        </div>

                        <!-- Tree Search Box -->
                        <div class="users-search-pill w-100 mb-3" style="max-width: 100%;">
                            <i class="bi bi-search"></i>
                            <input type="text" id="catTreeSearch" placeholder="Tìm kiếm nhanh danh mục...">
                        </div>

                        <!-- Tree Nodes List -->
                        <div class="d-flex flex-column">
                            <!-- Node 1: Active / Expanded -->
                            <div>
                                <a href="javascript:void(0)" class="tree-node-root active">
                                    <div class="d-flex align-items-center gap-2 text-truncate">
                                        <i class="bi bi-chevron-down" style="font-size: 0.65rem;"></i>
                                        <i class="bi bi-folder-fill"></i>
                                        <span class="text-truncate">Trái Cây Nội Địa & Đặc...</span>
                                    </div>
                                    <span class="tree-badge">14</span>
                                </a>

                                <!-- Children Nodes -->
                                <div class="tree-sub-container">
                                    <a href="javascript:void(0)" class="tree-sub-item">
                                        <div class="d-flex align-items-center gap-2 text-truncate">
                                            <span class="dot-green" style="width: 5px; height: 5px;"></span>
                                            <span class="text-truncate">Quả Có Múi (Bưởi, Cam, ...</span>
                                        </div>
                                        <span class="sub-badge">3 SP</span>
                                    </a>
                                    <a href="javascript:void(0)" class="tree-sub-item">
                                        <div class="d-flex align-items-center gap-2 text-truncate">
                                            <span class="dot-green" style="width: 5px; height: 5px;"></span>
                                            <span class="text-truncate">Quả Nhiệt Đới (Xoài, Bơ, ...</span>
                                        </div>
                                        <span class="sub-badge">4 SP</span>
                                    </a>
                                    <a href="javascript:void(0)" class="tree-sub-item">
                                        <div class="d-flex align-items-center gap-2 text-truncate">
                                            <span class="dot-green" style="width: 5px; height: 5px;"></span>
                                            <span class="text-truncate">Sầu Riêng & Mít Đắc Nông</span>
                                        </div>
                                        <span class="sub-badge">2 SP</span>
                                    </a>
                                    <a href="javascript:void(0)" class="tree-sub-item">
                                        <div class="d-flex align-items-center gap-2 text-truncate">
                                            <span class="dot-green" style="width: 5px; height: 5px;"></span>
                                            <span class="text-truncate">Dâu Tây & Quả Mọng Xứ L...</span>
                                        </div>
                                        <span class="sub-badge">5 SP</span>
                                    </a>
                                </div>
                            </div>

                            <!-- Node 2 -->
                            <a href="javascript:void(0)" class="tree-node-root">
                                <div class="d-flex align-items-center gap-2 text-truncate">
                                    <i class="bi bi-chevron-right text-muted" style="font-size: 0.65rem;"></i>
                                    <i class="bi bi-folder text-muted"></i>
                                    <span class="text-truncate">Trái Cây Nhập Khẩu Ca...</span>
                                </div>
                                <span class="tree-badge">8</span>
                            </a>

                            <!-- Node 3 -->
                            <a href="javascript:void(0)" class="tree-node-root">
                                <div class="d-flex align-items-center gap-2 text-truncate">
                                    <i class="bi bi-chevron-right text-muted" style="font-size: 0.65rem;"></i>
                                    <i class="bi bi-folder text-muted"></i>
                                    <span class="text-truncate">Giỏ Quà Trái Cây & Hộp ...</span>
                                </div>
                                <span class="tree-badge">4</span>
                            </a>

                            <!-- Node 4 -->
                            <a href="javascript:void(0)" class="tree-node-root">
                                <div class="d-flex align-items-center gap-2 text-truncate">
                                    <i class="bi bi-chevron-right text-muted" style="font-size: 0.65rem;"></i>
                                    <i class="bi bi-folder text-muted"></i>
                                    <span class="text-truncate">Trái Cây Sấy Thăng Hoa ...</span>
                                </div>
                                <span class="tree-badge">6</span>
                            </a>

                            <!-- Node 5 -->
                            <a href="javascript:void(0)" class="tree-node-root">
                                <div class="d-flex align-items-center gap-2 text-truncate">
                                    <i class="bi bi-chevron-right text-muted" style="font-size: 0.65rem;"></i>
                                    <i class="bi bi-folder text-muted"></i>
                                    <span class="text-truncate">Trái Cây Cắt Sẵn Eat-Cl...</span>
                                </div>
                                <span class="tree-badge">3</span>
                            </a>
                        </div>

                        <!-- Button Create Root Category -->
                        <button type="button" class="btn-create-category-root" onclick="alert('Đang mở form tạo Ngành hàng Cấp 1...');">
                            <i class="bi bi-folder-plus text-success"></i>
                            <span>Tạo Ngành Hàng Cấp 1 Mới</span>
                        </button>
                    </div>

                    <!-- Card 2: Độ Phủ Danh Mục -->
                    <div class="cat-sidebar-card">
                        <div class="d-flex align-items-center justify-content-between mb-2">
                            <strong class="text-dark" style="font-size: 0.85rem;">Độ Phủ Danh Mục</strong>
                            <span class="status-pill-green" style="font-size: 0.65rem;">TỐI ƯU 92%</span>
                        </div>
                        <p class="text-muted" style="font-size: 0.7rem; line-height: 1.45; margin-bottom: 0.75rem;">
                            Các phân loại quả có chứng nhận VietGAP và GlobalGAP hiện chiếm tỷ trọng hiển thị cao nhất ngoài sàn khách hàng.
                        </p>

                        <!-- Stacked Progress Bar -->
                        <div class="progress mb-2" style="height: 6px; background-color: #f1f5f9; border-radius: 3px;">
                            <div class="progress-bar bg-success" style="width: 55%;" title="Đặc sản: 55%"></div>
                            <div class="progress-bar" style="width: 25%; background: #ea580c;" title="Nhập khẩu: 25%"></div>
                            <div class="progress-bar bg-dark" style="width: 20%;" title="Chế biến: 20%"></div>
                        </div>

                        <!-- Progress Legend -->
                        <div class="d-flex align-items-center justify-content-between" style="font-size: 0.68rem; color: #64748b;">
                            <span class="d-flex align-items-center gap-1"><span class="dot-green" style="width: 6px; height: 6px;"></span> Đặc sản (55%)</span>
                            <span class="d-flex align-items-center gap-1"><span class="dot-orange" style="width: 6px; height: 6px;"></span> Nhập khẩu (25%)</span>
                            <span class="d-flex align-items-center gap-1"><span class="d-inline-block rounded-circle bg-dark" style="width: 6px; height: 6px;"></span> Chế biến (20%)</span>
                        </div>
                    </div>
                </div>

                <!-- Right Column: Detail Header & Sub-categories Table -->
                <div>
                    <!-- Detail Header Banner -->
                    <div class="cat-detail-card">
                        <div class="d-flex align-items-center gap-2">
                            <div class="user-summary-icon-box bg-green-subtle">
                                <i class="bi bi-flower1"></i>
                            </div>
                            <div>
                                <h2 class="role-matrix-title mb-0" style="font-size: 1.05rem;">Trái Cây Nội Địa & Đặc Sản Vùng Miền</h2>
                                <div class="text-muted" style="font-size: 0.72rem;">
                                    Đang quản lý 14 danh mục con | Mã nhận diện ID: <code class="text-success fw-bold">CAT-VN-DOMESTIC</code>
                                </div>
                            </div>
                        </div>

                        <div class="d-flex align-items-center gap-2">
                            <button type="button" class="btn-export-list" onclick="alert('Đang mở bảng cập nhật Take Rate hàng loạt...');">
                                <i class="bi bi-percent"></i>
                                <span>Cập nhật hoa hồng loạt</span>
                            </button>
                            <button type="button" class="btn-add-admin" onclick="alert('Đang mở form thêm phân loại con...');">
                                <i class="bi bi-plus-circle"></i>
                                <span>Thêm Phân Loại Con</span>
                            </button>
                        </div>
                    </div>

                    <!-- Sub-items Table Card -->
                    <div class="shops-table-container">
                        <div class="shops-table-header">
                            <div class="text-muted" style="font-size: 0.74rem;">
                                <strong>5</strong> phân loại quả tiêu biểu • Bộ lọc: <span class="text-dark fw-bold">Tất cả mùa vụ</span>
                            </div>
                            <div class="d-flex align-items-center gap-2">
                                <button type="button" class="btn btn-sm btn-light border p-1 px-2 text-muted" title="Lọc mùa vụ">
                                    <i class="bi bi-filter"></i>
                                </button>
                                <button type="button" class="btn btn-sm btn-light border p-1 px-2 text-muted" title="Tải xuống dữ liệu">
                                    <i class="bi bi-download"></i>
                                </button>
                            </div>
                        </div>

                        <table class="shops-modern-table">
                            <thead>
                                <tr>
                                    <th>TÊN DANH MỤC & SLUG</th>
                                    <th>MÙA VỤ THU HOẠCH</th>
                                    <th>TAKE RATE</th>
                                    <th>SHOP & SẢN PHẨM</th>
                                    <th>HIỂN THỊ</th>
                                    <th class="text-end">THAO TÁC</th>
                                </tr>
                            </thead>
                            <tbody id="catSubTableBody">
                                <c:forEach items="${categoriesList}" var="c">
                                    <tr>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="user-summary-icon-box bg-green-subtle" style="width: 34px; height: 34px; font-size: 0.9rem; flex-shrink: 0;">
                                                    <i class="bi bi-tag text-success"></i>
                                                </div>
                                                <div>
                                                    <strong class="text-dark" style="font-size: 0.82rem;">${c.categoryName}</strong>
                                                    <div class="text-muted" style="font-size: 0.68rem;">/${c.slug}</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="cert-pill-green" style="font-size: 0.65rem;">
                                                ${c.tempRange}
                                            </span>
                                            <div class="text-muted" style="font-size: 0.65rem;">${c.recommendedStorage}</div>
                                        </td>
                                        <td>
                                            <div><strong class="text-success" style="font-size: 0.8rem;">7.5% – 8.0%</strong></div>
                                            <div class="text-muted" style="font-size: 0.65rem;">Tiêu chuẩn sàn</div>
                                        </td>
                                        <td>
                                            <div><strong class="text-dark">${c.activeSkus}</strong></div>
                                            <div class="text-muted" style="font-size: 0.68rem;">sản phẩm liên kết</div>
                                        </td>
                                        <td>
                                            <div class="form-check form-switch m-0">
                                                <input class="form-check-input" type="checkbox" ${c.isActive ? 'checked' : ''} style="cursor: pointer;">
                                            </div>
                                        </td>
                                        <td class="text-end">
                                            <button type="button" class="action-tool-btn" title="Chỉnh sửa danh mục">
                                                <i class="bi bi-pencil"></i>
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty categoriesList}">
                                    <tr>
                                        <td colspan="6" class="text-center text-muted py-4">Chưa có danh mục nào.</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>

                        <!-- Pagination Footer -->
                        <div class="users-table-footer">
                            <span>Tổng cộng <strong>${not empty categoriesList ? categoriesList.size() : 0}</strong> danh mục toàn sàn</span>
                        </div>
                </div>
            </div>

            <!-- 4. Bottom Search Engine / SEO Banner -->
            <div class="engine-banner-card">
                <div class="d-flex align-items-center gap-3">
                    <div class="user-summary-icon-box bg-green-subtle" style="width: 38px; height: 38px; font-size: 1.15rem;">
                        <i class="bi bi-lightbulb-fill text-success"></i>
                    </div>
                    <div>
                        <strong class="text-dark fs-6">Tối ưu hóa Thuật toán Gợi ý & Tìm kiếm (FreshFruit Engine)</strong>
                        <p class="text-muted mb-0" style="font-size: 0.74rem; max-width: 720px; line-height: 1.45;">
                            Phân loại danh mục chuẩn giúp thuật toán tìm kiếm và đề xuất sản phẩm tới khách hàng <strong>chính xác hơn 40%</strong>. Đảm bảo gắn đúng vụ thu hoạch để kích hoạt chiến dịch flash sale tự động.
                        </p>
                    </div>
                </div>
                <a href="javascript:void(0)" onclick="alert('Đang mở tài liệu hướng dẫn SEO danh mục sàn nông sản...');" class="btn-seo-doc">
                    <i class="bi bi-journal-text text-success"></i>
                    <span>Xem tài liệu hướng dẫn SEO danh mục</span>
                </a>
            </div>
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/admin.js?v=13"></script>
</body>
</html>
