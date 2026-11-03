<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gốc Vườn - Quản Lý Danh Mục Ngành Hàng</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css?v=16">
    <meta name="context-path" content="${pageContext.request.contextPath}">
</head>
<body class="admin-body">

<div class="admin-wrapper">
    <jsp:include page="layout/sidebar.jsp">
        <jsp:param name="activePage" value="categories" />
    </jsp:include>

    <div class="admin-main">
        <jsp:include page="layout/header.jsp" />

        <main class="admin-page-content">
            <!-- Alert Notifications -->
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success alert-dismissible fade show d-flex align-items-center gap-2 mb-3 shadow-sm" role="alert" style="border-radius: 10px; font-size: 0.88rem; background: #f0fdf4; border-color: #bbf7d0; color: #166534;">
                    <i class="bi bi-check-circle-fill text-success fs-5"></i>
                    <div class="flex-grow-1">${successMessage}</div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center gap-2 mb-3 shadow-sm" role="alert" style="border-radius: 10px; font-size: 0.88rem; background: #fef2f2; border-color: #fecaca; color: #991b1b;">
                    <i class="bi bi-exclamation-triangle-fill text-danger fs-5"></i>
                    <div class="flex-grow-1">${errorMessage}</div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <!-- 1. Breadcrumbs & Header -->
            <div class="users-page-header">
                <div>
                    <nav aria-label="breadcrumb" class="mb-1" style="font-size: 0.72rem;">
                        <ol class="breadcrumb mb-0">
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/users" class="text-muted text-decoration-none">Quản trị sàn</a></li>
                            <li class="breadcrumb-item text-muted">Ngành hàng</li>
                            <li class="breadcrumb-item active text-success fw-bold" aria-current="page">Cấu hình Danh mục</li>
                        </ol>
                    </nav>
                    <h1 class="users-header-title">Quản Lý Danh Mục Ngành Hàng Dùng Chung</h1>
                    <p class="users-header-desc">Admin nắm toàn quyền CRUD danh mục cấp sàn. Shop chỉ được chọn danh mục có sẵn để đăng sản phẩm, không được tự tạo danh mục sàn.</p>
                </div>
                <div class="users-header-actions">
                    <button type="button" class="btn-export-list" onclick="alert('Đang mở chế độ sắp xếp thứ tự danh mục hiển thị...');">
                        <i class="bi bi-list-task"></i>
                        <span>Sắp xếp hiển thị ngoài sàn</span>
                    </button>
                    <button type="button" class="btn-add-admin" onclick="openAddCategoryModal()">
                        <i class="bi bi-plus-circle-fill"></i>
                        <span>Thêm Danh mục Mới</span>
                    </button>
                </div>
            </div>

            <!-- 2. Segmented Navigation Tabs (Lọc trạng thái danh mục) -->
            <div class="users-rbac-tabs">
                <a href="${pageContext.request.contextPath}/admin/categories?status=ALL" class="rbac-tab-item ${selectedStatus == 'ALL' || empty selectedStatus ? 'active' : ''}">
                    <i class="bi bi-grid-fill"></i>
                    <span>Tất cả danh mục</span>
                    <span class="rbac-badge">${not empty totalCategories ? totalCategories : (not empty categoriesList ? categoriesList.size() : 0)}</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/categories?status=ACTIVE" class="rbac-tab-item ${selectedStatus == 'ACTIVE' ? 'active' : ''}">
                    <i class="bi bi-check-circle-fill"></i>
                    <span>Đang hiển thị ngoài sàn</span>
                    <span class="rbac-badge" style="background: #dcfce7; color: #15803d;">${not empty activeCategoriesCount ? activeCategoriesCount : 0}</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/categories?status=INACTIVE" class="rbac-tab-item ${selectedStatus == 'INACTIVE' ? 'active' : ''}">
                    <i class="bi bi-eye-slash-fill"></i>
                    <span>Đang tạm ẩn</span>
                    <span class="rbac-badge" style="background: #fee2e2; color: #b91c1c;">${(not empty totalCategories && not empty activeCategoriesCount) ? (totalCategories - activeCategoriesCount) : 0}</span>
                </a>
            </div>

            <!-- 3. Filter Toolbar -->
            <form method="GET" action="${pageContext.request.contextPath}/admin/categories" class="users-filter-card mb-3" id="catFilterForm">
                <input type="hidden" name="status" value="${selectedStatus}">

                <div class="users-search-pill">
                    <i class="bi bi-search"></i>
                    <input type="text" name="search" id="catSearchInput" value="<c:out value='${searchKeyword}'/>" placeholder="Tìm tên danh mục, slug, mô tả...">
                </div>

                <div class="users-dropdown-filters">
                    <!-- Dropdown: Danh mục cha -->
                    <select name="parent" id="catParentSelect" class="filter-select-btn" onchange="this.form.submit()">
                        <option value="ALL" ${selectedParent == 'ALL' ? 'selected' : ''}>Cấp phân loại: Tất cả</option>
                        <c:forEach items="${allCategories}" var="cat">
                            <c:if test="${empty cat.parentId}">
                                <option value="${cat.categoryId}" ${selectedParent == cat.categoryId.toString() ? 'selected' : ''}>Trực thuộc: ${cat.categoryName}</option>
                            </c:if>
                        </c:forEach>
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

            <!-- 4. Danh sách Danh mục Ngành Hàng -->
            <div class="shops-table-container mb-4">
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
                                            <form method="POST" action="${pageContext.request.contextPath}/admin/categories" class="m-0 d-inline">
                                                <input type="hidden" name="action" value="toggleCategoryStatus">
                                                <input type="hidden" name="categoryId" value="${c.categoryId}">
                                                <input type="hidden" name="isActive" value="${c.isActive ? '0' : '1'}">
                                                <div class="form-check form-switch m-0" title="Bật/Tắt hiển thị danh mục ngoài sàn">
                                                    <input class="form-check-input" type="checkbox" ${c.isActive ? 'checked' : ''} style="cursor: pointer;" onchange="this.form.submit()">
                                                </div>
                                            </form>
                                        </td>
                                        <td class="text-end">
                                            <div class="d-inline-flex align-items-center gap-1">
                                                <button type="button" class="btn btn-sm btn-outline-primary p-1 px-2" title="Chỉnh sửa danh mục & slug"
                                                        data-category-id="${c.categoryId}"
                                                        data-category-name="${fn:escapeXml(c.categoryName)}"
                                                        data-slug="${c.slug}"
                                                        data-description="${fn:escapeXml(c.description)}"
                                                        data-parent-id="${empty c.parentId ? '0' : c.parentId}"
                                                        data-display-order="${empty c.displayOrder ? '0' : c.displayOrder}"
                                                        data-icon-class="${empty c.iconClass ? 'bi-tag' : c.iconClass}"
                                                        data-image-url="${c.imageUrl}"
                                                        data-is-active="${c.isActive ? '1' : '0'}"
                                                        onclick="openEditCategoryModal(this)">
                                                    <i class="bi bi-pencil-square"></i>
                                                </button>
                                                <button type="button" class="btn btn-sm btn-outline-danger p-1 px-2" title="Xóa danh mục" onclick="openDeleteCategoryModal(${c.categoryId}, '${c.categoryName}', ${c.activeSkus})">
                                                    <i class="bi bi-trash3"></i>
                                                </button>
                                            </div>
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

            <!-- 4. Bottom Search Engine / SEO Banner -->
            <div class="engine-banner-card">
                <div class="d-flex align-items-center gap-3">
                    <div class="user-summary-icon-box bg-green-subtle" style="width: 38px; height: 38px; font-size: 1.15rem;">
                        <i class="bi bi-lightbulb-fill text-success"></i>
                    </div>
                    <div>
                        <strong class="text-dark fs-6">Tối ưu hóa Thuật toán Gợi ý & Tìm kiếm (Gốc Vườn Engine)</strong>
                        <p class="text-muted mb-0" style="font-size: 0.74rem; max-width: 720px; line-height: 1.45;">
                            Phân loại danh mục chuẩn giúp thuật toán tìm kiếm và đề xuất sản phẩm tới khách hàng <strong>chính xác hơn 40%</strong>. Đảm bảo gán đúng vụ thu hoạch để kích hoạt chiến dịch flash sale tự động.
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

<!-- MODAL: Thêm / Sửa Danh Mục Ngành Hàng -->
<div class="modal fade" id="categoryModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content shadow-lg border-0" style="border-radius: 12px; overflow: hidden;">
            <form id="categoryForm" method="POST" action="${pageContext.request.contextPath}/admin/categories">
                <input type="hidden" name="action" id="categoryFormAction" value="addCategory">
                <input type="hidden" name="categoryId" id="categoryFormId" value="">

                <div class="modal-header bg-success text-white px-4 py-3">
                    <div class="d-flex align-items-center gap-2">
                        <i class="bi bi-folder-plus fs-5" id="categoryModalIcon"></i>
                        <h5 class="modal-title fw-bold mb-0" id="categoryModalTitle">Thêm Danh Mục Ngành Hàng Mới</h5>
                    </div>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body p-4">
                    <div class="row g-3">
                        <!-- Tên danh mục -->
                        <div class="col-md-6">
                            <label class="form-label fw-semibold text-dark" style="font-size: 0.82rem;">Tên danh mục <span class="text-danger">*</span></label>
                            <input type="text" name="categoryName" id="modalCategoryName" class="form-control" placeholder="Ví dụ: Trái Cây Nội Địa, Táo Envy..." required oninput="handleCategoryNameInput(this.value)">
                            <div class="form-text" style="font-size: 0.72rem;">Tên ngành hàng hiển thị trên menu toàn sàn.</div>
                        </div>

                        <!-- Đường dẫn tĩnh / Slug -->
                        <div class="col-md-6">
                            <label class="form-label fw-semibold text-dark" style="font-size: 0.82rem;">Đường dẫn tĩnh (Slug) <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text bg-light text-muted" style="font-size: 0.78rem;">/</span>
                                <input type="text" name="slug" id="modalCategorySlug" class="form-control" placeholder="trai-cay-noi-dia" required>
                            </div>
                            <div class="form-text" style="font-size: 0.72rem;">Đường dẫn URL thân thiện SEO (tự sinh từ tên hoặc nhập tay tùy chỉnh).</div>
                        </div>

                        <!-- Danh mục cha / Trực thuộc -->
                        <div class="col-md-6">
                            <label class="form-label fw-semibold text-dark" style="font-size: 0.82rem;">Danh mục trực thuộc</label>
                            <select name="parentId" id="modalCategoryParent" class="form-select">
                                <option value="0">-- Là ngành hàng gốc cấp 1 (Root Category) --</option>
                                <c:forEach items="${allCategories}" var="cat">
                                    <option value="${cat.categoryId}">[Cấp ${empty cat.parentId ? '1' : '2'}] ${cat.categoryName}</option>
                                </c:forEach>
                            </select>
                            <div class="form-text" style="font-size: 0.72rem;">Chọn danh mục cha để xây dựng phân cấp cây ngành hàng (Tree Hierarchy).</div>
                        </div>

                        <!-- Thứ tự hiển thị -->
                        <div class="col-md-3">
                            <label class="form-label fw-semibold text-dark" style="font-size: 0.82rem;">Thứ tự hiển thị</label>
                            <input type="number" name="displayOrder" id="modalCategoryOrder" class="form-control" value="0" min="0">
                            <div class="form-text" style="font-size: 0.72rem;">Số nhỏ hơn hiển thị trước.</div>
                        </div>

                        <!-- Icon Bootstrap Class -->
                        <div class="col-md-3">
                            <label class="form-label fw-semibold text-dark" style="font-size: 0.82rem;">Icon Class</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light" id="iconPreviewBox"><i class="bi bi-tag" id="iconPreview"></i></span>
                                <input type="text" name="iconClass" id="modalCategoryIcon" class="form-control" value="bi-tag" placeholder="bi-basket-fill" oninput="updateIconPreview(this.value)">
                            </div>
                            <div class="form-text" style="font-size: 0.72rem;">Tên class Bootstrap Icon.</div>
                        </div>

                        <!-- URL hình ảnh đại diện -->
                        <div class="col-md-12">
                            <label class="form-label fw-semibold text-dark" style="font-size: 0.82rem;">URL hình ảnh minh họa (Showcase Mega Menu)</label>
                            <input type="url" name="imageUrl" id="modalCategoryImageUrl" class="form-control" placeholder="https://images.unsplash.com/photo-...">
                            <div class="form-text" style="font-size: 0.72rem;">Đường dẫn ảnh định dạng tròn hiển thị ở cụm Showcase ngoài sàn.</div>
                        </div>

                        <!-- Mô tả ngành hàng -->
                        <div class="col-md-12">
                            <label class="form-label fw-semibold text-dark" style="font-size: 0.82rem;">Mô tả chi tiết ngành hàng</label>
                            <textarea name="description" id="modalCategoryDesc" rows="3" class="form-control" placeholder="Mô tả tiêu chuẩn chất lượng, xuất xứ hoặc yêu cầu nhiệt độ bảo quản lạnh..."></textarea>
                        </div>

                        <!-- Kích hoạt hiển thị -->
                        <div class="col-md-12">
                            <div class="p-3 rounded-3 border bg-light d-flex align-items-center justify-content-between">
                                <div>
                                    <div class="fw-bold text-dark" style="font-size: 0.85rem;">Bật/Tắt hiển thị ngoài sàn (is_active = 0/1)</div>
                                    <div class="text-muted" style="font-size: 0.72rem;">Khi tắt, gian hàng không thể gắn sản phẩm vào danh mục này và danh mục sẽ ẩn khỏi menu người mua.</div>
                                </div>
                                <div class="form-check form-switch m-0 fs-5">
                                    <input class="form-check-input" type="checkbox" name="isActive" id="modalCategoryIsActive" value="1" checked style="cursor: pointer;">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal-footer px-4 py-3 bg-light border-top">
                    <button type="button" class="btn btn-secondary btn-sm px-3 fw-semibold" data-bs-dismiss="modal">Hủy bỏ</button>
                    <button type="submit" class="btn btn-success btn-sm px-4 fw-bold" id="btnSaveCategory">
                        <i class="bi bi-check-circle me-1"></i> Lưu Danh Mục
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- MODAL: Xác Nhận Xóa Danh Mục (Kiểm Tra Ràng Buộc Dữ Liệu) -->
<div class="modal fade" id="deleteCategoryModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content shadow-lg border-0" style="border-radius: 12px; overflow: hidden;">
            <form method="POST" action="${pageContext.request.contextPath}/admin/categories">
                <input type="hidden" name="action" value="deleteCategory">
                <input type="hidden" name="categoryId" id="deleteCategoryId" value="">

                <div class="modal-header bg-danger text-white px-4 py-3">
                    <div class="d-flex align-items-center gap-2">
                        <i class="bi bi-exclamation-triangle-fill fs-5"></i>
                        <h5 class="modal-title fw-bold mb-0">Xác Nhận Xóa Danh Mục Ngành Hàng</h5>
                    </div>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body p-4">
                    <p class="mb-3" style="font-size: 0.9rem;">
                        Bạn có chắc chắn muốn xóa vĩnh viễn danh mục: <strong id="deleteCategoryName" class="text-danger"></strong>?
                    </p>

                    <div class="alert alert-warning d-flex align-items-start gap-2 mb-0" style="font-size: 0.78rem; border-radius: 8px;">
                        <i class="bi bi-shield-lock-fill text-warning fs-5 flex-shrink-0"></i>
                        <div>
                            <strong>Quy tắc ràng buộc toàn vẹn dữ liệu:</strong> Hệ thống sẽ <strong>chặn xóa cứng</strong> nếu danh mục đang có sản phẩm liên kết hoặc có danh mục con trực thuộc. Để ẩn khỏi chợ mà không làm gián đoạn dữ liệu đơn hàng cũ, vui lòng chọn tắt trạng thái hiển thị (is_active = 0).
                        </div>
                    </div>
                </div>

                <div class="modal-footer px-4 py-3 bg-light border-top">
                    <button type="button" class="btn btn-secondary btn-sm px-3 fw-semibold" data-bs-dismiss="modal">Hủy bỏ</button>
                    <button type="submit" class="btn btn-danger btn-sm px-4 fw-bold">
                        <i class="bi bi-trash3 me-1"></i> Xác Nhận Xóa
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/admin.js?v=16"></script>
<script src="${pageContext.request.contextPath}/assets/js/admin-categories.js"></script>
</body>
</html>
