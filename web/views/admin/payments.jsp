<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<c:url var="baseQ" value="/admin/payments">
    <c:param name="q" value="${q}"/>
    <c:param name="method" value="${method}"/>
    <c:param name="days" value="${days}"/>
</c:url>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gốc Vườn - Giám Sát Giao Dịch Thanh Toán</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css?v=14">
</head>
<body class="admin-body">
<div class="admin-wrapper">
    <jsp:include page="layout/sidebar.jsp">
        <jsp:param name="activePage" value="payments" />
    </jsp:include>

    <div class="admin-main">
        <jsp:include page="layout/header.jsp" />

        <main class="admin-page-content">
            <div class="users-page-header">
                <div>
                    <nav aria-label="breadcrumb" class="mb-1" style="font-size: 0.72rem;">
                        <ol class="breadcrumb mb-0">
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard" class="text-muted text-decoration-none">Quản trị sàn</a></li>
                            <li class="breadcrumb-item text-muted">Vận hành &amp; giám sát</li>
                            <li class="breadcrumb-item active text-success fw-bold" aria-current="page">Giao dịch thanh toán</li>
                        </ol>
                    </nav>
                    <h1 class="users-header-title">Giám Sát Giao Dịch Thanh Toán</h1>
                    <p class="users-header-desc">Theo dõi trạng thái thanh toán COD / VNPay / chuyển khoản của toàn bộ đơn hàng trên sàn.</p>
                </div>
            </div>

            <!-- KPI -->
            <div class="row g-3 mb-3">
                <div class="col-md-3"><div class="users-filter-card d-block">
                    <div class="text-muted" style="font-size:.7rem;font-weight:700;">ĐÃ THU THÀNH CÔNG</div>
                    <div class="fw-bold text-success" style="font-size:1.25rem;"><fmt:formatNumber value="${stats.totalPaidAmount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></div>
                    <div class="text-muted" style="font-size:.7rem;">${stats.successCount} giao dịch</div></div></div>
                <div class="col-md-3"><div class="users-filter-card d-block">
                    <div class="text-muted" style="font-size:.7rem;font-weight:700;">ĐANG CHỜ THU</div>
                    <div class="fw-bold text-warning" style="font-size:1.25rem;"><fmt:formatNumber value="${stats.totalPendingAmount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></div>
                    <div class="text-muted" style="font-size:.7rem;">${stats.pendingCount} giao dịch</div></div></div>
                <div class="col-md-3"><div class="users-filter-card d-block">
                    <div class="text-muted" style="font-size:.7rem;font-weight:700;">THẤT BẠI</div>
                    <div class="fw-bold text-danger" style="font-size:1.25rem;">${stats.failedCount}</div>
                    <div class="text-muted" style="font-size:.7rem;">Tỉ lệ thành công ${stats.successRate}%</div></div></div>
                <div class="col-md-3"><div class="users-filter-card d-block">
                    <div class="text-muted" style="font-size:.7rem;font-weight:700;">CƠ CẤU PHƯƠNG THỨC</div>
                    <div class="fw-bold" style="font-size:1.25rem;">Online ${stats.onlinePercent}%</div>
                    <div class="text-muted" style="font-size:.7rem;">COD ${stats.codPercent}%</div></div></div>
            </div>

            <!-- Tabs -->
            <div class="users-rbac-tabs">
                <a href="<c:out value='${baseQ}'/>&amp;status=ALL" class="rbac-tab-item ${status == 'ALL' ? 'active' : ''}"><span>Tất cả</span><span class="rbac-badge">${countAll}</span></a>
                <a href="<c:out value='${baseQ}'/>&amp;status=SUCCESS" class="rbac-tab-item ${status == 'SUCCESS' ? 'active' : ''}"><span>Thành công</span><span class="rbac-badge">${countSuccess}</span></a>
                <a href="<c:out value='${baseQ}'/>&amp;status=PENDING" class="rbac-tab-item ${status == 'PENDING' ? 'active' : ''}"><span>Đang xử lý</span><span class="rbac-badge">${countPending}</span></a>
                <a href="<c:out value='${baseQ}'/>&amp;status=FAILED" class="rbac-tab-item ${status == 'FAILED' ? 'active' : ''}"><span>Thất bại</span><span class="rbac-badge">${countFailed}</span></a>
            </div>

            <!-- Filter -->
            <form method="get" action="${pageContext.request.contextPath}/admin/payments" class="users-filter-card">
                <input type="hidden" name="status" value="<c:out value='${status}'/>">
                <div class="users-search-pill">
                    <i class="bi bi-search"></i>
                    <input type="text" name="q" value="<c:out value='${q}'/>" placeholder="Tìm theo mã giao dịch, mã đơn, khách hàng">
                </div>
                <div class="users-dropdown-filters">
                    <select name="method" class="form-select form-select-sm" onchange="this.form.submit()">
                        <option value="ALL" ${method == 'ALL' ? 'selected' : ''}>Mọi phương thức</option>
                        <option value="COD" ${method == 'COD' ? 'selected' : ''}>COD</option>
                        <option value="ONLINE" ${method == 'ONLINE' ? 'selected' : ''}>Tất cả online</option>
                        <option value="VNPAY" ${method == 'VNPAY' ? 'selected' : ''}>VNPay-QR</option>
                        <option value="BANK_TRANSFER" ${method == 'BANK_TRANSFER' ? 'selected' : ''}>Chuyển khoản</option>
                    </select>
                    <select name="days" class="form-select form-select-sm" onchange="this.form.submit()">
                        <option value="7" ${days == 7 ? 'selected' : ''}>7 ngày</option>
                        <option value="30" ${days == 30 ? 'selected' : ''}>30 ngày</option>
                        <option value="90" ${days == 90 ? 'selected' : ''}>90 ngày</option>
                        <option value="365" ${days == 365 ? 'selected' : ''}>1 năm</option>
                        <option value="0" ${days == 0 ? 'selected' : ''}>Tất cả</option>
                    </select>
                    <button type="submit" class="btn btn-sm btn-success">Lọc</button>
                </div>
            </form>

            <!-- Table -->
            <div class="shops-table-container">
                <table class="shops-modern-table">
                    <thead>
                        <tr>
                            <th>MÃ GIAO DỊCH</th>
                            <th>ĐƠN HÀNG &amp; KHÁCH</th>
                            <th>THỜI GIAN</th>
                            <th>SỐ TIỀN</th>
                            <th>PHƯƠNG THỨC</th>
                            <th>TRẠNG THÁI</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${payments}" var="p">
                            <tr>
                                <td><span class="order-code-green"><c:out value="${empty p.transactionCode ? '—' : p.transactionCode}"/></span></td>
                                <td>
                                    <strong class="text-dark" style="font-size:.8rem;"><c:out value="${p.orderCode}"/></strong>
                                    <div class="text-muted" style="font-size:.7rem;"><c:out value="${p.customerName}"/></div>
                                </td>
                                <td style="font-size:.78rem;"><c:out value="${p.createdAtFull}"/></td>
                                <td>
                                    <strong class="text-success"><fmt:formatNumber value="${p.amount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong>
                                    <c:if test="${p.failed and not empty p.failureReason}"><div class="text-danger" style="font-size:.68rem;"><c:out value="${p.failureReason}"/></div></c:if>
                                </td>
                                <td><span class="payment-tag payment-tag-online"><c:out value="${p.providerLabel}"/></span></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${p.success}"><span class="status-badge-delivered"><i class="bi bi-check-circle-fill"></i> Thành công</span></c:when>
                                        <c:when test="${p.failed}"><span class="status-badge-failed"><i class="bi bi-x-circle-fill"></i> Thất bại</span></c:when>
                                        <c:otherwise><span class="status-badge-sorting"><i class="bi bi-hourglass-split"></i> Đang xử lý</span></c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty payments}">
                            <tr><td colspan="6" class="text-center text-muted py-4">Không có giao dịch phù hợp.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>

            <div class="d-flex justify-content-between align-items-center mt-3" style="font-size:.78rem;">
                <span class="text-muted">Tổng <strong>${totalItems}</strong> giao dịch - Trang ${page}/${totalPages}</span>
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
