<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<c:url var="analyticsUrl" value="/admin/payment-analytics"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gốc Vườn - Phân Tích Thanh Toán &amp; Dòng Tiền</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css?v=14">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
</head>
<body class="admin-body">
<div class="admin-wrapper">
    <jsp:include page="layout/sidebar.jsp">
        <jsp:param name="activePage" value="payment-analytics" />
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
                            <li class="breadcrumb-item active text-success fw-bold" aria-current="page">Phân tích dòng tiền</li>
                        </ol>
                    </nav>
                    <h1 class="users-header-title">Phân Tích Thanh Toán &amp; Dòng Tiền</h1>
                    <p class="users-header-desc">Tỉ lệ COD và Online, tỉ lệ giao dịch lỗi, doanh thu tiền mặt và tiền điện tử.</p>
                </div>
                <form method="get" action="<c:out value='${analyticsUrl}'/>" class="d-flex align-items-center gap-2">
                    <div class="form-check form-switch mb-0" style="font-size:.75rem;">
                        <input class="form-check-input" type="checkbox" id="autoRefresh">
                        <label class="form-check-label" for="autoRefresh">Tự làm mới 30s</label>
                    </div>
                    <select name="days" class="form-select form-select-sm" onchange="this.form.submit()">
                        <option value="7" ${days == 7 ? 'selected' : ''}>7 ngày gần nhất</option>
                        <option value="30" ${days == 30 ? 'selected' : ''}>30 ngày gần nhất</option>
                        <option value="90" ${days == 90 ? 'selected' : ''}>90 ngày gần nhất</option>
                        <option value="365" ${days == 365 ? 'selected' : ''}>1 năm gần nhất</option>
                        <option value="0" ${days == 0 ? 'selected' : ''}>Toàn bộ thời gian</option>
                    </select>
                </form>
            </div>

            <!-- KPI dòng tiền -->
            <div class="row g-3 mb-3">
                <div class="col-md-3"><div class="users-filter-card d-block">
                    <div class="text-muted" style="font-size:.7rem;font-weight:700;">TỔNG TIỀN THU</div>
                    <div class="fw-bold text-success" style="font-size:1.25rem;"><fmt:formatNumber value="${report.collectedTotal}" type="currency" currencyCode="VND" maxFractionDigits="0"/></div>
                    <div class="text-muted" style="font-size:.7rem;">${report.successCount} giao dịch thành công</div></div></div>
                <div class="col-md-3"><div class="users-filter-card d-block">
                    <div class="text-muted" style="font-size:.7rem;font-weight:700;">ĐÃ HOÀN CHO KHÁCH</div>
                    <div class="fw-bold text-danger" style="font-size:1.25rem;">-<fmt:formatNumber value="${report.refundedTotal}" type="currency" currencyCode="VND" maxFractionDigits="0"/></div>
                    <div class="text-muted" style="font-size:.7rem;">Hoàn toàn phần + một phần</div></div></div>
                <div class="col-md-3"><div class="users-filter-card d-block">
                    <div class="text-muted" style="font-size:.7rem;font-weight:700;">ĐÃ CHI TRẢ CHO SHOP</div>
                    <div class="fw-bold text-danger" style="font-size:1.25rem;">-<fmt:formatNumber value="${report.payoutPaid}" type="currency" currencyCode="VND" maxFractionDigits="0"/></div>
                    <div class="text-muted" style="font-size:.7rem;">Các kỳ quyết toán COMPLETED</div></div></div>
                <div class="col-md-3"><div class="users-filter-card d-block">
                    <div class="text-muted" style="font-size:.7rem;font-weight:700;">DÒNG TIỀN RÒNG TẠI SÀN</div>
                    <div class="fw-bold" style="font-size:1.25rem;"><fmt:formatNumber value="${report.netCashflow}" type="currency" currencyCode="VND" maxFractionDigits="0"/></div>
                    <div class="text-muted" style="font-size:.7rem;">Thu − hoàn − chi trả shop</div></div></div>
            </div>

            <div class="row g-3 mb-3">
                <!-- Doanh thu theo ngày -->
                <div class="col-lg-8">
                    <div class="users-filter-card d-block h-100">
                        <div class="fw-bold mb-2" style="font-size:.9rem;">Doanh thu theo ngày: tiền mặt (COD) vs tiền điện tử</div>
                        <div class="d-flex gap-3 mb-2" style="font-size:.75rem;">
                            <span>Tiền mặt: <strong><fmt:formatNumber value="${report.collectedCod}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong> (${report.cashPercent}%)</span>
                            <span>Tiền điện tử: <strong><fmt:formatNumber value="${report.collectedOnline}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong> (${report.electronicPercent}%)</span>
                        </div>
                        <c:choose>
                            <c:when test="${empty report.daily}"><div class="text-muted text-center py-5">Chưa có dữ liệu trong khoảng thời gian này.</div></c:when>
                            <c:otherwise><div style="height:280px;"><canvas id="dailyChart"></canvas></div></c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <!-- COD vs Online -->
                <div class="col-lg-4">
                    <div class="users-filter-card d-block h-100">
                        <div class="fw-bold mb-2" style="font-size:.9rem;">Tỉ lệ sử dụng phương thức</div>
                        <div style="height:200px;"><canvas id="methodChart"></canvas></div>
                        <div class="d-flex justify-content-between mt-3" style="font-size:.78rem;">
                            <span>COD: <strong>${report.codCount}</strong> (${report.codPercent}%)</span>
                            <span>Online: <strong>${report.onlineCount}</strong> (${report.onlinePercent}%)</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-3 mb-3">
                <!-- Tỉ lệ lỗi -->
                <div class="col-lg-4">
                    <div class="users-filter-card d-block h-100">
                        <div class="fw-bold mb-2" style="font-size:.9rem;">Tỉ lệ giao dịch online lỗi</div>
                        <div class="fw-bold ${report.onlineFailureRate >= 20 ? 'text-danger' : 'text-success'}" style="font-size:2rem;">${report.onlineFailureRate}%</div>
                        <div class="progress mb-2" style="height:8px;"><div class="progress-bar bg-danger" style="width:${report.onlineFailureRate}%"></div></div>
                        <div class="text-muted" style="font-size:.75rem;">${report.onlineFailed} lỗi / ${report.onlineSuccess + report.onlineFailed} giao dịch online đã có kết quả</div>
                        <div class="text-muted mt-1" style="font-size:.75rem;">${report.pendingCount} giao dịch đang xử lý</div>
                        <hr>
                        <div class="fw-bold mb-1" style="font-size:.78rem;">Lý do lỗi phổ biến</div>
                        <c:forEach items="${report.failureReasons}" var="fr">
                            <div class="d-flex justify-content-between" style="font-size:.75rem;"><span><c:out value="${fr.reason}"/></span><strong>${fr.count}</strong></div>
                        </c:forEach>
                        <c:if test="${empty report.failureReasons}"><div class="text-muted" style="font-size:.75rem;">Không có giao dịch lỗi.</div></c:if>
                    </div>
                </div>
                <!-- Theo phương thức -->
                <div class="col-lg-8">
                    <div class="shops-table-container h-100">
                        <div class="px-3 pt-3 pb-1 fw-bold" style="font-size:.9rem;">Chi tiết theo phương thức thanh toán</div>
                        <table class="shops-modern-table">
                            <thead>
                                <tr><th>PHƯƠNG THỨC</th><th>GIAO DỊCH</th><th>THÀNH CÔNG</th><th>THẤT BẠI</th><th>ĐANG XỬ LÝ</th><th>TIỀN THU</th></tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${report.byMethod}" var="m">
                                    <tr>
                                        <td><strong><c:out value="${m.provider}"/></strong></td>
                                        <td>${m.count}</td>
                                        <td class="text-success">${m.success}</td>
                                        <td class="text-danger">${m.failed}</td>
                                        <td class="text-warning">${m.pending}</td>
                                        <td><strong><fmt:formatNumber value="${m.amount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty report.byMethod}">
                                    <tr><td colspan="6" class="text-center text-muted py-4">Chưa có giao dịch.</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/admin.js?v=14"></script>
<script>
    const dailyEl = document.getElementById('dailyChart');
    if (dailyEl) {
        new Chart(dailyEl, {
            type: 'bar',
            data: {
                labels: ${chartLabels},
                datasets: [
                    {label: 'Tiền mặt (COD)', data: ${chartCash}, backgroundColor: '#f59e0b', stack: 's'},
                    {label: 'Tiền điện tử', data: ${chartElectronic}, backgroundColor: '#16a34a', stack: 's'}
                ]
            },
            options: {
                responsive: true, maintainAspectRatio: false,
                scales: {
                    x: {stacked: true},
                    y: {stacked: true, ticks: {callback: v => Number(v).toLocaleString('vi-VN') + 'đ'}}
                },
                plugins: {tooltip: {callbacks: {label: c => c.dataset.label + ': ' + Number(c.raw).toLocaleString('vi-VN') + 'đ'}}}
            }
        });
    }
    new Chart(document.getElementById('methodChart'), {
        type: 'doughnut',
        data: {
            labels: ['COD', 'Online'],
            datasets: [{data: [${report.codCount}, ${report.onlineCount}], backgroundColor: ['#f59e0b', '#16a34a']}]
        },
        options: {responsive: true, maintainAspectRatio: false, plugins: {legend: {position: 'bottom'}}}
    });

    // Làm mới tự động (mỗi lần tải lại trang là một lần truy vấn dữ liệu mới).
    const auto = document.getElementById('autoRefresh');
    let timer = null;
    auto.checked = sessionStorage.getItem('paymentAnalyticsAuto') === '1';
    function applyAuto() {
        sessionStorage.setItem('paymentAnalyticsAuto', auto.checked ? '1' : '0');
        if (timer) { clearInterval(timer); timer = null; }
        if (auto.checked) { timer = setInterval(() => location.reload(), 30000); }
    }
    auto.addEventListener('change', applyAuto);
    applyAuto();
</script>
</body>
</html>
