<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<c:url var="tiersUrl" value="/admin/membership-tiers"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hạng Thành Viên - Gốc Vườn Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css?v=14">
</head>
<body class="admin-body">
<div class="admin-wrapper">
    <jsp:include page="layout/sidebar.jsp">
        <jsp:param name="activePage" value="membership-tiers" />
    </jsp:include>

    <div class="admin-main">
        <jsp:include page="layout/header.jsp" />

        <main class="admin-page-content">
            <div class="admin-breadcrumbs mb-2 text-muted" style="font-size:.76rem;">
                <span>Quản trị sàn</span> <span class="mx-1">&gt;</span> <span>Thành viên &amp; điểm thưởng</span>
                <span class="mx-1">&gt;</span> <span class="text-dark fw-semibold">Hạng thành viên</span>
            </div>
            <h1 class="users-header-title">Quản Lý Hạng Thành Viên</h1>
            <p class="users-header-desc">Thêm, sửa, ngừng kích hoạt hoặc xóa hạng. Hạng của khách được xét theo tổng điểm tích luỹ.</p>

            <c:if test="${not empty sessionScope.adminFlash}">
                <div class="alert alert-success py-2 fw-semibold" style="font-size:.82rem;"><i class="bi bi-check-circle-fill me-1"></i><c:out value="${sessionScope.adminFlash}"/></div>
                <c:remove var="adminFlash" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.adminError}">
                <div class="alert alert-danger py-2 fw-semibold" style="font-size:.82rem;"><i class="bi bi-exclamation-triangle-fill me-1"></i><c:out value="${sessionScope.adminError}"/></div>
                <c:remove var="adminError" scope="session"/>
            </c:if>

            <!-- ===== Form thêm / sửa ===== -->
            <form method="post" action="<c:out value='${tiersUrl}'/>" class="users-filter-card d-block mb-3">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="tierId" value="${empty editTier ? '' : editTier.tierId}">
                <div class="fw-bold mb-2" style="font-size:.9rem;">
                    <c:choose>
                        <c:when test="${not empty editTier}">Sửa hạng: <c:out value="${editTier.tierName}"/></c:when>
                        <c:otherwise>Thêm hạng mới</c:otherwise>
                    </c:choose>
                </div>
                <div class="row g-2 align-items-end">
                    <div class="col-md-3">
                        <label class="form-label mb-1" style="font-size:.7rem;font-weight:700;">TÊN HẠNG</label>
                        <input type="text" name="tierName" maxlength="50" required class="form-control form-control-sm" value="<c:out value='${editTier.tierName}'/>">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label mb-1" style="font-size:.7rem;font-weight:700;">ĐIỂM TÍCH LUỸ TỐI THIỂU</label>
                        <input type="number" name="minPoints" min="0" required class="form-control form-control-sm" value="${empty editTier ? '' : editTier.minPoints}">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label mb-1" style="font-size:.7rem;font-weight:700;">HỆ SỐ NHÂN ĐIỂM</label>
                        <input type="number" name="pointMultiplier" min="0.5" max="5" step="0.05" required class="form-control form-control-sm" value="${empty editTier ? '1.00' : editTier.pointMultiplier}">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label mb-1" style="font-size:.7rem;font-weight:700;">TRẦN DÙNG ĐIỂM (%)</label>
                        <input type="number" name="redeemCapPercent" min="0" max="100" step="1" class="form-control form-control-sm" placeholder="Trống = theo luật chung" value="${empty editTier or empty editTier.redeemCapPercent ? '' : editTier.redeemCapPercent.intValue()}">
                    </div>
                    <div class="col-md-1">
                        <label class="form-label mb-1" style="font-size:.7rem;font-weight:700;">MÀU</label>
                        <input type="color" name="badgeColor" class="form-control form-control-sm form-control-color w-100" value="${empty editTier ? '#16a34a' : editTier.badgeColor}">
                    </div>
                    <div class="col-md-2">
                        <div class="form-check form-switch">
                            <input class="form-check-input" type="checkbox" name="active" id="tierActive" ${empty editTier or editTier.active ? 'checked' : ''}>
                            <label class="form-check-label" for="tierActive" style="font-size:.78rem;">Kích hoạt</label>
                        </div>
                    </div>
                    <div class="col-md-8">
                        <label class="form-label mb-1" style="font-size:.7rem;font-weight:700;">MÔ TẢ QUYỀN LỢI</label>
                        <input type="text" name="description" maxlength="255" class="form-control form-control-sm" value="<c:out value='${editTier.description}'/>">
                    </div>
                    <div class="col-md-4 d-flex gap-2">
                        <button type="submit" class="btn btn-sm btn-success fw-bold flex-fill"><i class="bi bi-save me-1"></i>Lưu hạng</button>
                        <c:if test="${not empty editTier}"><a href="<c:out value='${tiersUrl}'/>" class="btn btn-sm btn-light flex-fill">Hủy sửa</a></c:if>
                    </div>
                </div>
            </form>

            <!-- ===== Tìm kiếm ===== -->
            <form method="get" action="<c:out value='${tiersUrl}'/>" class="users-filter-card mb-3">
                <div class="users-search-pill">
                    <i class="bi bi-search"></i>
                    <input type="text" name="q" value="<c:out value='${q}'/>" placeholder="Tìm theo tên hoặc mã hạng">
                </div>
                <div class="users-dropdown-filters"><button type="submit" class="btn btn-sm btn-success">Tìm</button></div>
            </form>

            <!-- ===== Danh sách hạng ===== -->
            <div class="shops-table-container">
                <table class="shops-modern-table">
                    <thead>
                        <tr>
                            <th>HẠNG</th><th>ĐIỂM TỐI THIỂU</th><th>HỆ SỐ</th><th>TRẦN DÙNG ĐIỂM</th><th>THÀNH VIÊN</th><th>TRẠNG THÁI</th><th class="text-end">THAO TÁC</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${tiers}" var="t">
                            <tr>
                                <td>
                                    <span style="display:inline-block;width:12px;height:12px;border-radius:50%;background:<c:out value='${t.badgeColor}'/>;"></span>
                                    <strong class="ms-1"><c:out value="${t.tierName}"/></strong>
                                    <div class="text-muted" style="font-size:.68rem;"><c:out value="${t.tierCode}"/> · <c:out value="${t.description}"/></div>
                                </td>
                                <td><fmt:formatNumber value="${t.minPoints}"/></td>
                                <td><c:out value="${t.multiplierLabel}"/></td>
                                <td style="font-size:.78rem;"><c:out value="${t.redeemCapLabel}"/></td>
                                <td>${t.memberCount}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${t.active}"><span class="status-badge-delivered"><i class="bi bi-check-circle-fill"></i> Đang dùng</span></c:when>
                                        <c:otherwise><span class="status-badge-failed"><i class="bi bi-pause-circle-fill"></i> Ngừng</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end text-nowrap">
                                    <a class="btn btn-sm btn-outline-secondary" style="font-size:.7rem;" href="<c:out value='${tiersUrl}'/>?edit=${t.tierId}"><i class="bi bi-pencil"></i> Sửa</a>
                                    <form method="post" action="<c:out value='${tiersUrl}'/>" class="d-inline"
                                          onsubmit="return confirm('Xóa hạng này? Hạng đang có thành viên sẽ không xóa được.');">
                                        <input type="hidden" name="action" value="delete"><input type="hidden" name="tierId" value="${t.tierId}">
                                        <button class="btn btn-sm btn-outline-danger" style="font-size:.7rem;"><i class="bi bi-trash"></i> Xóa</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty tiers}">
                            <tr><td colspan="7" class="text-center text-muted py-4">Chưa có hạng nào. Hãy thêm hạng khởi đầu (điểm tối thiểu = 0).</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </main>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/admin.js?v=7"></script>
</body>
</html>
