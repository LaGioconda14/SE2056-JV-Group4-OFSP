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
                    <div class="user-summary-val">${not empty totalCategories ? totalCategories : 26} <span class="fs-6 fw-normal text-muted">Ngành & Phân loại</span></div>
                    <div class="text-success d-flex align-items-center gap-1" style="font-size: 0.72rem;">
                        <i class="bi bi-check-circle-fill"></i> ${not empty activeCategoriesCount ? activeCategoriesCount : 26} đang kích hoạt
                    </div>
                </div>

                <!-- Card 2: TỔNG SẢN PHẨM / SKU -->
                <div class="user-summary-card">
                    <div class="d-flex align-items-center justify-content-between mb-1">
                        <span class="user-summary-title text-uppercase" style="letter-spacing: 0.04em;">TỔNG SKU SẢN PHẨM</span>
                        <div class="user-summary-icon-box bg-purple-subtle">
                            <i class="bi bi-share"></i>
                        </div>
                    </div>
                    <div class="user-summary-val">${not empty totalActiveSkus ? totalActiveSkus : 11} <span class="fs-6 fw-normal text-muted">SKU liên kết</span></div>
                    <div class="text-muted d-flex align-items-center gap-1" style="font-size: 0.72rem;">
                        <i class="bi bi-box-seam"></i> Đang mở bán trên toàn sàn
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
                    <div class="user-summary-val">8.0%</div>
                    <div class="text-muted d-flex align-items-center gap-1" style="font-size: 0.72rem;">
                        <i class="bi bi-graph-up"></i> Biên độ chiết khấu sàn
                    </div>
                </div>
            </div>

            <!-- 2.5 Visual Fruit Mega Menu Showcase (Farmers Market Style) -->
            <div class="fruit-showcase-panel">
                <div class="fruit-showcase-header">
                    <div class="fruit-showcase-title-box">
                        <div class="fruit-showcase-icon">
                            <i class="bi bi-basket-fill"></i>
                        </div>
                        <div>
                            <h2 class="fruit-showcase-title">MỤC TRÁI CÂY (KIẾN TRÚC PHÂN LOẠI & MEGA MENU)</h2>
                            <p class="fruit-showcase-desc">Thiết kế theo chuẩn chuỗi Farmers Market: 5 nhóm ngành quả chiến lược, phân loại chuyên sâu theo xuất xứ, sơ chế và mùa vụ.</p>
                        </div>
                    </div>
                    <div class="d-flex align-items-center gap-2">
                        <span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1" style="font-size: 0.72rem; font-weight: 700;">
                            <i class="bi bi-patch-check-fill me-1"></i> Chuẩn Farmers Market
                        </span>
                        <a href="${pageContext.request.contextPath}/admin/categories" class="btn btn-sm btn-outline-secondary" style="font-size: 0.72rem; border-radius: 8px;">
                            <i class="bi bi-grid-fill me-1"></i> Xem tất cả
                        </a>
                    </div>
                </div>

                <!-- 5 Circular Category Groups Grid -->
                <div class="fruit-categories-grid">
                    <c:forEach items="${fruitMegaMenu}" var="g">
                        <div class="fruit-cat-card">
                            <div class="fruit-cat-img-box">
                                <img src="${g.imageUrl}" alt="${g.categoryName}" class="fruit-cat-circle-img" onerror="this.src='https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&h=300&fit=crop'">
                            </div>
                            <a href="${pageContext.request.contextPath}/admin/categories?parent=${g.categoryId}" class="fruit-cat-title" title="Lọc theo nhóm ${g.categoryName}">
                                ${g.categoryName}
                            </a>
                            <span class="fruit-cat-sku-badge">${g.totalSkus} SKU liên kết</span>

                            <!-- Subcategories Link List -->
                            <ul class="fruit-cat-sub-list">
                                <c:forEach items="${g.subCategories}" var="sub">
                                    <li>
                                        <a href="${pageContext.request.contextPath}/admin/categories?search=${sub.slug}" class="fruit-cat-sub-link" title="Xem sản phẩm ${sub.categoryName}">
                                            <span>${sub.categoryName}</span>
                                            <c:if test="${sub.activeSkus > 0}">
                                                <span class="sub-count badge bg-light text-muted border">${sub.activeSkus}</span>
                                            </c:if>
                                        </a>
                                    </li>
                                </c:forEach>
                            </ul>
                        </div>
                    </c:forEach>
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
                            <span class="badge bg-light text-muted border" style="font-size: 0.65rem;">${not empty totalCategories ? totalCategories : 26} Phân Loại</span>
                        </div>

                        <!-- Tree Nodes List -->
                        <div class="d-flex flex-column" id="catTreeList">
                            <!-- Root: Trái Cây -->
                            <a href="${pageContext.request.contextPath}/admin/categories?search=trai-cay" class="tree-node-root ${searchKeyword == 'trai-cay' ? 'active' : ''}">
                                <div class="d-flex align-items-center gap-2 text-truncate">
                                    <i class="bi bi-basket-fill text-success"></i>
                                    <strong>Trái Cây (Root)</strong>
                                </div>
                                <span class="tree-badge">${not empty totalActiveSkus ? totalActiveSkus : 11} SKU</span>
                            </a>

                            <!-- 5 Nhóm Trái Cây Sub-container -->
                            <div class="tree-sub-container">
                                <c:forEach items="${fruitMegaMenu}" var="fmg">
                                    <a href="${pageContext.request.contextPath}/admin/categories?parent=${fmg.categoryId}" class="tree-sub-item ${selectedParent == fmg.categoryId.toString() ? 'bg-success text-white' : ''}">
                                        <span class="text-truncate">• ${fmg.categoryName}</span>
                                        <span class="sub-badge ${selectedParent == fmg.categoryId.toString() ? 'text-white' : ''}">${fmg.totalSkus} SKU</span>
                                    </a>
                                </c:forEach>
                            </div>

                            <!-- Other Root Categories -->
                            <c:forEach items="${allCategories}" var="node">
                                <c:if test="${empty node.parentId && node.categoryId != 1}">
                                    <a href="${pageContext.request.contextPath}/admin/categories?search=${node.slug}" class="tree-node-root ${searchKeyword == node.slug ? 'active' : ''}">
                                        <div class="d-flex align-items-center gap-2 text-truncate">
                                            <i class="bi ${not empty node.iconClass ? node.iconClass : 'bi-folder'}"></i>
                                            <span class="text-truncate">${node.categoryName}</span>
                                        </div>
                                        <span class="tree-badge">${node.activeSkus} SKU</span>
                                    </a>
                                </c:if>
                            </c:forEach>
                        </div>

                        <!-- Button Create Root Category -->
                        <button type="button" class="btn-create-category-root mt-3" onclick="alert('Đang mở form tạo Ngành hàng Cấp 1...');">
                            <i class="bi bi-folder-plus text-success"></i>
                            <span>Tạo Ngành Hàng Mới</span>
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

                <!-- Right Column: Detail Header, Filter & Categories Table -->
                <div>
                    <!-- Detail Header Banner -->
                    <div class="cat-detail-card mb-3">
                        <div class="d-flex align-items-center gap-2">
                            <div class="user-summary-icon-box bg-green-subtle">
                                <i class="bi bi-diagram-3-fill text-success"></i>
                            </div>
                            <div>
                                <h2 class="role-matrix-title mb-0" style="font-size: 1.05rem;">Bảng Quản Trị Danh Mục & Chuỗi Lạnh</h2>
                                <div class="text-muted" style="font-size: 0.72rem;">
                                    Đang hiển thị <strong>${not empty categoriesList ? categoriesList.size() : 0}</strong> danh mục phân cấp • Chuỗi cung ứng nông sản tươi
                                </div>
                            </div>
                        </div>

                        <div class="d-flex align-items-center gap-2">
                            <button type="button" class="btn-export-list" onclick="alert('Đang mở bảng cập nhật Take Rate hàng loạt...');">
                                <i class="bi bi-percent"></i>
                                <span>Cập nhật hoa hồng</span>
                            </button>
                            <button type="button" class="btn-add-admin" onclick="alert('Đang mở form thêm danh mục mới...');">
                                <i class="bi bi-plus-circle-fill"></i>
                                <span>Thêm Danh Mục Mới</span>
                            </button>
                        </div>
                    </div>

                    <!-- Filter Toolbar -->
                    <form method="GET" action="${pageContext.request.contextPath}/admin/categories" class="users-filter-card mb-3" id="catFilterForm">
                        <!-- Giữ nhóm trực thuộc đang chọn từ Showcase / Cây danh mục phía trên -->
                        <input type="hidden" name="parent" value="${selectedParent}">

                        <div class="users-search-pill">
                            <i class="bi bi-search"></i>
                            <input type="text" name="search" id="catSearchInput" value="<c:out value='${searchKeyword}'/>" placeholder="Tìm tên danh mục, slug, mô tả...">
                        </div>

                        <div class="users-dropdown-filters">

                            <!-- Dropdown: Trạng thái hiển thị -->
                            <select name="status" id="catStatusSelect" class="filter-select-btn" onchange="this.form.submit()">
                                <option value="ALL" ${selectedStatus == 'ALL' ? 'selected' : ''}>Trạng thái: Tất cả</option>
                                <option value="ACTIVE" ${selectedStatus == 'ACTIVE' ? 'selected' : ''}>Đang hiển thị</option>
                                <option value="INACTIVE" ${selectedStatus == 'INACTIVE' ? 'selected' : ''}>Đang tạm ẩn</option>
                            </select>

                            <button type="submit" class="btn btn-sm text-white d-inline-flex align-items-center gap-1" style="font-size: 0.75rem; padding: 0.38rem 0.85rem; border-radius: 8px; background: #15803d; border: 1px solid #15803d; font-weight: 600;">
                                <i class="bi bi-funnel"></i> Lọc
                            </button>

                            <!-- Nút Đặt lại / Reset -->
                            <c:if test="${(not empty selectedStatus && selectedStatus != 'ALL') || not empty searchKeyword || (not empty selectedParent && selectedParent != 'ALL')}">
                                <a href="${pageContext.request.contextPath}/admin/categories" class="btn btn-sm btn-outline-secondary d-inline-flex align-items-center gap-1" style="font-size: 0.75rem; padding: 0.38rem 0.85rem; border-radius: 8px;">
                                    <i class="bi bi-arrow-counterclockwise"></i> Đặt lại
                                </a>
                            </c:if>
                        </div>
                    </form>

                    <!-- Sub-items Table Card -->
                    <div class="shops-table-container">
                        <div class="shops-table-header">
                            <div class="text-muted d-flex align-items-center flex-wrap gap-2" style="font-size: 0.74rem;">
                                <span>Tìm thấy <strong>${not empty categoriesList ? categoriesList.size() : 0}</strong> danh mục</span>
                                <span>• Trạng thái: <strong class="text-dark">${selectedStatus == 'ACTIVE' ? 'Đang hiển thị' : (selectedStatus == 'INACTIVE' ? 'Đang tạm ẩn' : 'Tất cả')}</strong></span>
                                <c:if test="${not empty selectedParent && selectedParent != 'ALL'}">
                                    <span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1 d-inline-flex align-items-center gap-1">
                                        <i class="bi bi-folder2-open"></i> Nhóm:
                                        <c:forEach items="${fruitMegaMenu}" var="fm">
                                            <c:if test="${selectedParent == fm.categoryId.toString()}">${fm.categoryName}</c:if>
                                        </c:forEach>
                                        <a href="${pageContext.request.contextPath}/admin/categories?status=${selectedStatus}&search=${searchKeyword}" class="text-danger ms-1 text-decoration-none fw-bold" title="Bỏ lọc nhóm">✕</a>
                                    </span>
                                </c:if>
                            </div>
                            <div class="d-flex align-items-center gap-2">
                                <button type="button" class="btn btn-sm btn-light border p-1 px-2 text-muted" title="Làm mới" onclick="location.reload();">
                                    <i class="bi bi-arrow-clockwise"></i>
                                </button>
                                <button type="button" class="btn btn-sm btn-light border p-1 px-2 text-muted" title="Tải xuống dữ liệu" onclick="alert('Đang tải danh sách danh mục (.CSV)...');">
                                    <i class="bi bi-download"></i>
                                </button>
                            </div>
                        </div>

                        <table class="shops-modern-table">
                            <thead>
                                <tr>
                                    <th>HÌNH ẢNH & TÊN DANH MỤC</th>
                                    <th>CẤP BẬC / TRỰC THUỘC</th>
                                    <th>BẢO QUẢN LẠNH</th>
                                    <th>TAKE RATE</th>
                                    <th>SKU LIÊN KẾT</th>
                                    <th>HIỂN THỊ</th>
                                    <th class="text-end">THAO TÁC</th>
                                </tr>
                            </thead>
                            <tbody id="catSubTableBody">
                                <c:forEach items="${categoriesList}" var="c">
                                    <tr>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <c:choose>
                                                    <c:when test="${not empty c.imageUrl}">
                                                        <img src="${c.imageUrl}" alt="${c.categoryName}" style="width: 36px; height: 36px; border-radius: 50%; object-fit: cover; border: 1.5px solid #86efac; flex-shrink: 0;" onerror="this.style.display='none'">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="user-summary-icon-box bg-green-subtle" style="width: 36px; height: 36px; font-size: 0.9rem; flex-shrink: 0;">
                                                            <i class="bi ${not empty c.iconClass ? c.iconClass : 'bi-tag'} text-success"></i>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                                <div>
                                                    <strong class="text-dark" style="font-size: 0.82rem;">${c.categoryName}</strong>
                                                    <div class="text-muted" style="font-size: 0.68rem;">/${c.slug}</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty c.parentName}">
                                                    <span class="badge bg-light text-dark border px-2 py-1" style="font-size: 0.7rem; font-weight: 600;">
                                                        <i class="bi bi-folder2-open text-success me-1"></i>${c.parentName}
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1" style="font-size: 0.7rem; font-weight: 700;">
                                                        <i class="bi bi-star-fill me-1"></i>Ngành Hàng Gốc (L1)
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
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
                                        <td colspan="7" class="text-center text-muted py-4">Chưa có danh mục nào phù hợp điều kiện lọc.</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>

                        <!-- Pagination Footer -->
                        <div class="users-table-footer">
                            <span>Tổng cộng <strong>${not empty categoriesList ? categoriesList.size() : 0}</strong> danh mục hiển thị</span>
                        </div>
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
