<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<c:url var="payoutsUrl" value="/admin/payouts"/>
<c:url var="baseQ" value="/admin/payouts">
    <c:param name="q" value="${q}"/>
</c:url>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gốc Vườn - Quyết Toán &amp; Chi Trả Gian Hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css?v=14">
</head>
<body class="admin-body">
<div class="admin-wrapper">
    <jsp:include page="layout/sidebar.jsp">
        <jsp:param name="activePage" value="payouts" />
    </jsp:include>

    <div class="admin-main">
        <jsp:include page="layout/header.jsp" />

        <main class="admin-page-content">
            <div class="users-page-header">
                <div>
                    <nav aria-label="breadcrumb" class="mb-1" style="font-size: 0.72rem;">
                        <ol class="breadcrumb mb-0">
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard" class="text-muted text-decoration-none">Quản trị sàn</a></li>
                            <li class="breadcrumb-item text-muted">Tài chính</li>
                            <li class="breadcrumb-item active text-success fw-bold" aria-current="page">Quyết toán &amp; chi trả</li>
                        </ol>
                    </nav>
                    <h1 class="users-header-title">Quyết Toán &amp; Chi Trả Gian Hàng</h1>
                    <p class="users-header-desc">Tính doanh thu thực nhận của shop sau hoa hồng và khoản hoàn tiền do khiếu nại, rồi xác nhận chuyển tiền.</p>
                </div>
            </div>

            <c:if test="${not empty sessionScope.adminFlash}">
                <div class="alert alert-success py-2 fw-semibold" style="font-size:.82rem;"><i class="bi bi-check-circle-fill me-1"></i><c:out value="${sessionScope.adminFlash}"/></div>
                <c:remove var="adminFlash" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.adminError}">
                <div class="alert alert-danger py-2 fw-semibold" style="font-size:.82rem;"><i class="bi bi-exclamation-triangle-fill me-1"></i><c:out value="${sessionScope.adminError}"/></div>
                <c:remove var="adminError" scope="session"/>
            </c:if>

            <!-- KPI -->
            <div class="row g-3 mb-3">
                <div class="col-md-3"><div class="users-filter-card d-block">
                    <div class="text-muted" style="font-size:.7rem;font-weight:700;">CHỜ CHI TRẢ</div>
                    <div class="fw-bold text-warning" style="font-size:1.25rem;"><fmt:formatNumber value="${summary.processingNet}" type="currency" currencyCode="VND" maxFractionDigits="0"/></div>
                    <div class="text-muted" style="font-size:.7rem;">${summary.processingCount} kỳ</div></div></div>
                <div class="col-md-3"><div class="users-filter-card d-block">
                    <div class="text-muted" style="font-size:.7rem;font-weight:700;">ĐANG TẠM GIỮ</div>
                    <div class="fw-bold text-danger" style="font-size:1.25rem;"><fmt:formatNumber value="${summary.holdNet}" type="currency" currencyCode="VND" maxFractionDigits="0"/></div>
                    <div class="text-muted" style="font-size:.7rem;">${summary.holdCount} kỳ</div></div></div>
                <div class="col-md-3"><div class="users-filter-card d-block">
                    <div class="text-muted" style="font-size:.7rem;font-weight:700;">ĐÃ CHI TRẢ</div>
                    <div class="fw-bold text-success" style="font-size:1.25rem;"><fmt:formatNumber value="${summary.paidNet}" type="currency" currencyCode="VND" maxFractionDigits="0"/></div>
                    <div class="text-muted" style="font-size:.7rem;">${summary.paidCount} kỳ</div></div></div>
                <div class="col-md-3"><div class="users-filter-card d-block">
                    <div class="text-muted" style="font-size:.7rem;font-weight:700;">HOA HỒNG SÀN ĐÃ THU</div>
                    <div class="fw-bold" style="font-size:1.25rem;"><fmt:formatNumber value="${summary.commissionPaid}" type="currency" currencyCode="VND" maxFractionDigits="0"/></div>
                    <div class="text-muted" style="font-size:.7rem;">Trên các kỳ đã chi trả</div></div></div>
            </div>

            <!-- Tạo kỳ quyết toán -->
            <form method="post" action="<c:out value='${payoutsUrl}'/>" class="users-filter-card mb-3">
                <input type="hidden" name="action" value="generate">
                <div class="fw-bold w-100 mb-2" style="font-size:.9rem;">Tạo kỳ quyết toán</div>
                <div class="row g-2 w-100 align-items-end">
                    <div class="col-md-3">
                        <label class="form-label mb-1" style="font-size:.7rem;font-weight:700;">GIAN HÀNG</label>
                        <select name="shopId" class="form-select form-select-sm">
                            <option value="ALL">Tất cả gian hàng đang hoạt động</option>
                            <c:forEach items="${shops}" var="s"><option value="${s.shopId}"><c:out value="${s.shopName}"/></option></c:forEach>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label mb-1" style="font-size:.7rem;font-weight:700;">TỪ NGÀY</label>
                        <input type="date" name="startDate" value="${weekAgo}" max="${today}" class="form-control form-control-sm" required>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label mb-1" style="font-size:.7rem;font-weight:700;">ĐẾN NGÀY</label>
                        <input type="date" name="endDate" value="${today}" max="${today}" class="form-control form-control-sm" required>
                    </div>
                    <div class="col-md-3">
                        <button type="submit" class="btn btn-sm btn-success w-100 fw-bold"><i class="bi bi-calculator me-1"></i>Tính quyết toán</button>
                    </div>
                </div>
                <div class="text-muted w-100 mt-2" style="font-size:.7rem;">
                    Công thức: <strong>Thực nhận = Doanh thu đơn đã giao − Hoa hồng sàn − Khấu trừ khiếu nại</strong>.
                    Mỗi shop không có hai kỳ chồng lấn thời gian; shop đang có khiếu nại chưa xử lý sẽ bị tạm giữ.
                </div>
            </form>

            <!-- Tabs -->
            <div class="users-rbac-tabs">
                <a href="<c:out value='${baseQ}'/>&amp;status=ALL" class="rbac-tab-item ${status == 'ALL' ? 'active' : ''}"><span>Tất cả</span><span class="rbac-badge">${countAll}</span></a>
                <a href="<c:out value='${baseQ}'/>&amp;status=PROCESSING" class="rbac-tab-item ${status == 'PROCESSING' ? 'active' : ''}"><span>Chờ chi trả</span><span class="rbac-badge">${countProcessing}</span></a>
                <a href="<c:out value='${baseQ}'/>&amp;status=ON_HOLD" class="rbac-tab-item ${status == 'ON_HOLD' ? 'active' : ''}"><span>Tạm giữ</span><span class="rbac-badge">${countHold}</span></a>
                <a href="<c:out value='${baseQ}'/>&amp;status=COMPLETED" class="rbac-tab-item ${status == 'COMPLETED' ? 'active' : ''}"><span>Đã chi trả</span><span class="rbac-badge">${countCompleted}</span></a>
            </div>

            <form method="get" action="<c:out value='${payoutsUrl}'/>" class="users-filter-card">
                <input type="hidden" name="status" value="<c:out value='${status}'/>">
                <div class="users-search-pill">
                    <i class="bi bi-search"></i>
                    <input type="text" name="q" value="<c:out value='${q}'/>" placeholder="Tìm theo mã kỳ, tên gian hàng">
                </div>
                <div class="users-dropdown-filters"><button type="submit" class="btn btn-sm btn-success">Tìm</button></div>
            </form>

            <!-- Bảng kỳ quyết toán -->
            <div class="shops-table-container">
                <table class="shops-modern-table">
                    <thead>
                        <tr>
                            <th>KỲ QUYẾT TOÁN</th>
                            <th>GIAN HÀNG</th>
                            <th>DOANH THU</th>
                            <th>HOA HỒNG</th>
                            <th>KHẤU TRỪ KN</th>
                            <th>THỰC NHẬN</th>
                            <th>TRẠNG THÁI</th>
                            <th class="text-end">THAO TÁC</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${payouts}" var="p">
                            <tr>
                                <td>
                                    <span class="order-code-green"><c:out value="${p.payoutCode}"/></span>
                                    <div class="text-muted" style="font-size:.68rem;"><c:out value="${p.periodLabel}"/> · ${p.totalOrdersCount} đơn</div>
                                </td>
                                <td style="font-size:.78rem;">
                                    <strong><c:out value="${p.shopName}"/></strong>
                                    <div class="text-muted" style="font-size:.68rem;"><c:out value="${empty p.bankName ? 'Chưa có TK ngân hàng' : p.bankName}"/> <c:out value="${p.maskedAccount}"/></div>
                                </td>
                                <td style="font-size:.78rem;"><fmt:formatNumber value="${p.grossSales}" type="currency" currencyCode="VND" maxFractionDigits="0"/></td>
                                <td style="font-size:.78rem;" class="text-danger">-<fmt:formatNumber value="${p.commissionWithheld}" type="currency" currencyCode="VND" maxFractionDigits="0"/>
                                    <div class="text-muted" style="font-size:.66rem;">${p.commissionRate}%</div></td>
                                <td style="font-size:.78rem;" class="${p.disputeDeductions.signum() > 0 ? 'text-danger' : 'text-muted'}">-<fmt:formatNumber value="${p.disputeDeductions}" type="currency" currencyCode="VND" maxFractionDigits="0"/></td>
                                <td><strong class="text-success"><fmt:formatNumber value="${p.netPayout}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${p.completed}">
                                            <span class="status-badge-delivered"><i class="bi bi-check-circle-fill"></i> Đã chi trả</span>
                                            <div class="text-muted" style="font-size:.66rem;"><c:out value="${p.paidAtFull}"/> · <c:out value="${p.processedByName}"/></div>
                                        </c:when>
                                        <c:when test="${p.onHold}"><span class="status-badge-failed"><i class="bi bi-pause-circle-fill"></i> Tạm giữ</span></c:when>
                                        <c:otherwise><span class="status-badge-sorting"><i class="bi bi-hourglass-split"></i> Chờ chi trả</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end text-nowrap">
                                    <c:if test="${p.processing}">
                                        <form method="post" action="<c:out value='${payoutsUrl}'/>" class="d-inline"
                                              onsubmit="return confirm('Xác nhận ĐÃ chuyển tiền cho kỳ ${p.payoutCode}?');">
                                            <input type="hidden" name="action" value="complete"><input type="hidden" name="payoutId" value="${p.payoutId}">
                                            <button class="btn btn-sm btn-success fw-bold" style="font-size:.7rem;">Đã chuyển tiền</button>
                                        </form>
                                        <form method="post" action="<c:out value='${payoutsUrl}'/>" class="d-inline">
                                            <input type="hidden" name="action" value="hold"><input type="hidden" name="payoutId" value="${p.payoutId}">
                                            <button class="btn btn-sm btn-outline-secondary" style="font-size:.7rem;" title="Tạm giữ">Giữ</button>
                                        </form>
                                    </c:if>
                                    <c:if test="${p.onHold}">
                                        <form method="post" action="<c:out value='${payoutsUrl}'/>" class="d-inline">
                                            <input type="hidden" name="action" value="release"><input type="hidden" name="payoutId" value="${p.payoutId}">
                                            <button class="btn btn-sm btn-outline-success" style="font-size:.7rem;">Gỡ giữ</button>
                                        </form>
                                    </c:if>
                                    <c:if test="${not p.completed}">
                                        <form method="post" action="<c:out value='${payoutsUrl}'/>" class="d-inline"
                                              onsubmit="return confirm('Hủy kỳ quyết toán này để tính lại?');">
                                            <input type="hidden" name="action" value="delete"><input type="hidden" name="payoutId" value="${p.payoutId}">
                                            <button class="btn btn-sm btn-outline-danger" style="font-size:.7rem;" title="Hủy kỳ"><i class="bi bi-trash"></i></button>
                                        </form>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty payouts}">
                            <tr><td colspan="8" class="text-center text-muted py-4">Chưa có kỳ quyết toán nào. Hãy chọn khoảng ngày và bấm "Tính quyết toán".</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>

            <div class="d-flex justify-content-between align-items-center mt-3" style="font-size:.78rem;">
                <span class="text-muted">Tổng <strong>${totalItems}</strong> kỳ - Trang ${page}/${totalPages}</span>
                <div class="btn-group btn-group-sm">
                    <c:if test="${page > 1}"><a class="btn btn-outline-secondary" href="<c:out value='${baseQ}'/>&amp;status=${status}&amp;page=${page - 1}">‹ Trước</a></c:if>
                    <c:if test="${page < totalPages}"><a class="btn btn-outline-secondary" href="<c:out value='${baseQ}'/>&amp;status=${status}&amp;page=${page + 1}">Sau ›</a></c:if>
                </div>
            </div>
        </main>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/admin.js?v=14"></script>
</body>
</html>
