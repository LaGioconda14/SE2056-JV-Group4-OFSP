<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<c:url var="refundsUrl" value="/admin/refunds"/>
<c:url var="resolveUrl" value="/admin/disputes/resolve"/>
<c:url var="baseQ" value="/admin/refunds">
    <c:param name="q" value="${q}"/>
    <c:param name="source" value="${source}"/>
</c:url>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gốc Vườn - Hoàn Tiền &amp; Hoàn Tiền Một Phần</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css?v=14">
</head>
<body class="admin-body">
<div class="admin-wrapper">
    <jsp:include page="layout/sidebar.jsp">
        <jsp:param name="activePage" value="refunds" />
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
                            <li class="breadcrumb-item active text-success fw-bold" aria-current="page">Hoàn tiền</li>
                        </ol>
                    </nav>
                    <h1 class="users-header-title">Hoàn Tiền &amp; Hoàn Tiền Một Phần</h1>
                    <p class="users-header-desc">Hoàn toàn phần khi hủy đơn (tự động), hoàn một phần khi khách khiếu nại chất lượng hoa quả.</p>
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
                    <div class="text-muted" style="font-size:.7rem;font-weight:700;">TỔNG TIỀN ĐÃ HOÀN</div>
                    <div class="fw-bold text-danger" style="font-size:1.25rem;"><fmt:formatNumber value="${summary.totalAmount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></div>
                    <div class="text-muted" style="font-size:.7rem;">${summary.totalCount} khoản hoàn</div></div></div>
                <div class="col-md-3"><div class="users-filter-card d-block">
                    <div class="text-muted" style="font-size:.7rem;font-weight:700;">HOÀN MỘT PHẦN</div>
                    <div class="fw-bold" style="font-size:1.25rem;">${summary.partialCount}</div>
                    <div class="text-muted" style="font-size:.7rem;">Partial Refund</div></div></div>
                <div class="col-md-3"><div class="users-filter-card d-block">
                    <div class="text-muted" style="font-size:.7rem;font-weight:700;">DO KHIẾU NẠI</div>
                    <div class="fw-bold" style="font-size:1.25rem;">${summary.disputeCount}</div>
                    <div class="text-muted" style="font-size:.7rem;">${pendingDisputes.size()} khiếu nại đang chờ</div></div></div>
                <div class="col-md-3"><div class="users-filter-card d-block">
                    <div class="text-muted" style="font-size:.7rem;font-weight:700;">DO HỦY ĐƠN (TỰ ĐỘNG)</div>
                    <div class="fw-bold" style="font-size:1.25rem;">${summary.cancelCount}</div>
                    <div class="text-muted" style="font-size:.7rem;">Hoàn toàn phần</div></div></div>
            </div>

            <!-- Khiếu nại chờ phán quyết -->
            <div class="shops-table-container mb-3">
                <div class="px-3 pt-3 pb-1 fw-bold" style="font-size:.9rem;">Khiếu nại chờ phán quyết</div>
                <div class="px-3 pb-2 text-muted" style="font-size:.72rem;">
                    Gồm khiếu nại do khách gửi và khiếu nại tự sinh khi shipper ghi nhận khách từ chối nhận hàng.
                    Đơn COD chưa thu tiền thì không có gì để hoàn: hãy chọn <strong>Bác bỏ</strong> để đóng khiếu nại.
                </div>
                <table class="shops-modern-table">
                    <thead>
                        <tr>
                            <th>KHIẾU NẠI</th>
                            <th>KHÁCH &amp; SHOP</th>
                            <th>LÝ DO</th>
                            <th>KHÁCH YÊU CẦU</th>
                            <th>CÒN HOÀN ĐƯỢC</th>
                            <th>TRẠNG THÁI</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${pendingDisputes}" var="d">
                            <tr>
                                <td>
                                    <span class="order-code-green"><c:out value="${d.code}"/></span>
                                    <div class="text-muted" style="font-size:.68rem;"><c:out value="${d.subOrderCode}"/></div>
                                </td>
                                <td style="font-size:.78rem;">
                                    <strong><c:out value="${d.customer}"/></strong>
                                    <div class="text-muted" style="font-size:.7rem;"><c:out value="${d.shop}"/></div>
                                </td>
                                <td style="font-size:.78rem;"><c:out value="${d.reason}"/></td>
                                <td><strong class="text-danger"><fmt:formatNumber value="${d.claim}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></td>
                                <td><fmt:formatNumber value="${d.refundable}" type="currency" currencyCode="VND" maxFractionDigits="0"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${d.status == 'MEDIATING'}"><span class="status-badge-sorting"><i class="bi bi-hourglass-split"></i> Đang giải trình</span></c:when>
                                        <c:otherwise><span class="status-badge-failed"><i class="bi bi-flag-fill"></i> Mới mở</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end">
                                    <button type="button" class="btn btn-sm btn-success fw-bold btn-resolve"
                                            data-code="<c:out value='${d.code}'/>"
                                            data-claim="<c:out value='${d.claim.toBigInteger()}'/>"
                                            data-refundable="<c:out value='${d.refundable.toBigInteger()}'/>">Phán quyết</button>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty pendingDisputes}">
                            <tr><td colspan="7" class="text-center text-muted py-3">Không có khiếu nại nào đang chờ xử lý.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>

            <!-- Hoàn tiền thủ công -->
            <form method="post" action="<c:out value='${refundsUrl}'/>" class="users-filter-card mb-3">
                <div class="fw-bold w-100 mb-2" style="font-size:.9rem;">Tạo khoản hoàn tiền thủ công</div>
                <div class="row g-2 w-100 align-items-end">
                    <div class="col-md-3">
                        <label class="form-label mb-1" style="font-size:.7rem;font-weight:700;">MÃ ĐƠN CON</label>
                        <input type="text" name="subOrderCode" class="form-control form-control-sm" placeholder="VD: SUB-8821-1" required>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label mb-1" style="font-size:.7rem;font-weight:700;">SỐ TIỀN HOÀN (VNĐ)</label>
                        <input type="text" name="amount" class="form-control form-control-sm" inputmode="numeric" placeholder="Để trống = hoàn toàn bộ phần còn lại">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label mb-1" style="font-size:.7rem;font-weight:700;">LÝ DO</label>
                        <input type="text" name="reason" maxlength="200" class="form-control form-control-sm" placeholder="VD: Quả dập nát một phần">
                    </div>
                    <div class="col-md-2">
                        <button type="submit" class="btn btn-sm btn-success w-100 fw-bold">Hoàn tiền</button>
                    </div>
                </div>
                <div class="text-muted w-100 mt-2" style="font-size:.7rem;">Chỉ hoàn được cho đơn đã thanh toán; tổng tiền hoàn không vượt quá giá trị đơn con. Hoàn đủ sẽ tự chuyển trạng thái sang REFUNDED.</div>
            </form>

            <!-- Sổ hoàn tiền -->
            <form method="get" action="<c:out value='${refundsUrl}'/>" class="users-filter-card">
                <div class="users-search-pill">
                    <i class="bi bi-search"></i>
                    <input type="text" name="q" value="<c:out value='${q}'/>" placeholder="Tìm theo mã hoàn tiền, mã đơn, khách, shop">
                </div>
                <div class="users-dropdown-filters">
                    <select name="source" class="form-select form-select-sm" onchange="this.form.submit()">
                        <option value="ALL" ${source == 'ALL' ? 'selected' : ''}>Mọi nguồn</option>
                        <option value="CANCEL" ${source == 'CANCEL' ? 'selected' : ''}>Hủy đơn</option>
                        <option value="DISPUTE" ${source == 'DISPUTE' ? 'selected' : ''}>Khiếu nại</option>
                        <option value="MANUAL" ${source == 'MANUAL' ? 'selected' : ''}>Admin tạo tay</option>
                    </select>
                    <button type="submit" class="btn btn-sm btn-success">Lọc</button>
                </div>
            </form>

            <div class="shops-table-container">
                <table class="shops-modern-table">
                    <thead>
                        <tr>
                            <th>MÃ HOÀN TIỀN</th>
                            <th>ĐƠN HÀNG &amp; KHÁCH</th>
                            <th>NGUỒN</th>
                            <th>SỐ TIỀN</th>
                            <th>HOÀN VỀ</th>
                            <th>XỬ LÝ BỞI</th>
                            <th>THỜI GIAN</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${refunds}" var="r">
                            <tr>
                                <td>
                                    <span class="order-code-green"><c:out value="${r.refundCode}"/></span>
                                    <div style="font-size:.68rem;" class="${r.full ? 'text-success' : 'text-warning'} fw-bold"><c:out value="${r.typeLabel}"/></div>
                                </td>
                                <td style="font-size:.78rem;">
                                    <strong><c:out value="${r.subOrderCode}"/></strong>
                                    <div class="text-muted" style="font-size:.7rem;"><c:out value="${r.customerName}"/> · <c:out value="${r.shopName}"/></div>
                                </td>
                                <td style="font-size:.78rem;">
                                    <c:out value="${r.sourceLabel}"/>
                                    <c:if test="${not empty r.disputeCode}"><div class="text-muted" style="font-size:.68rem;"><c:out value="${r.disputeCode}"/></div></c:if>
                                </td>
                                <td><strong class="text-danger">-<fmt:formatNumber value="${r.amount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></td>
                                <td style="font-size:.75rem;"><c:out value="${r.refundMethod}"/></td>
                                <td style="font-size:.75rem;"><c:out value="${r.processorLabel}"/></td>
                                <td style="font-size:.75rem;"><c:out value="${r.createdAtFull}"/></td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty refunds}">
                            <tr><td colspan="7" class="text-center text-muted py-4">Chưa có khoản hoàn tiền nào.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>

            <div class="d-flex justify-content-between align-items-center mt-3" style="font-size:.78rem;">
                <span class="text-muted">Tổng <strong>${totalItems}</strong> khoản hoàn - Trang ${page}/${totalPages}</span>
                <div class="btn-group btn-group-sm">
                    <c:if test="${page > 1}"><a class="btn btn-outline-secondary" href="<c:out value='${baseQ}'/>&amp;page=${page - 1}">‹ Trước</a></c:if>
                    <c:if test="${page < totalPages}"><a class="btn btn-outline-secondary" href="<c:out value='${baseQ}'/>&amp;page=${page + 1}">Sau ›</a></c:if>
                </div>
            </div>
        </main>
    </div>
</div>

<!-- Modal phán quyết khiếu nại -->
<div class="modal fade" id="resolveModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <form method="post" action="<c:out value='${resolveUrl}'/>" class="modal-content">
            <input type="hidden" name="returnTo" value="refunds">
            <input type="hidden" name="disputeCode" id="rmCode">
            <div class="modal-header">
                <h5 class="modal-title fw-bold">Phán quyết khiếu nại <span id="rmCodeLabel" class="text-success"></span></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <label class="form-label fw-bold" style="font-size:.78rem;">Quyết định</label>
                <select name="decision" id="rmDecision" class="form-select mb-3">
                    <option value="REFUND_BUYER">Hoàn 100% số tiền khách yêu cầu</option>
                    <option value="PARTIAL_REFUND">Hoàn một phần (nhập số tiền)</option>
                    <option value="REJECT_CLAIM">Bác bỏ khiếu nại</option>
                    <option value="REQUEST_INFO">Yêu cầu shop bổ sung giải trình</option>
                </select>
                <div id="rmAmountBox" class="mb-3" style="display:none;">
                    <label class="form-label fw-bold" style="font-size:.78rem;">Số tiền hoàn (VNĐ)</label>
                    <input type="text" name="amount" id="rmAmount" inputmode="numeric" class="form-control">
                    <div class="form-text" id="rmAmountHint"></div>
                </div>
                <label class="form-label fw-bold" style="font-size:.78rem;">Ghi chú / lý do</label>
                <textarea name="note" rows="3" maxlength="500" class="form-control" placeholder="Lưu vào hồ sơ khiếu nại và gửi cho các bên liên quan"></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-light" data-bs-dismiss="modal">Đóng</button>
                <button type="submit" class="btn btn-success fw-bold">Xác nhận</button>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/admin.js?v=14"></script>
<script>
    (function () {
        const modal = new bootstrap.Modal(document.getElementById('resolveModal'));
        const dec = document.getElementById('rmDecision');
        const box = document.getElementById('rmAmountBox');
        const amount = document.getElementById('rmAmount');
        const hint = document.getElementById('rmAmountHint');
        function sync() {
            const partial = dec.value === 'PARTIAL_REFUND';
            box.style.display = partial ? 'block' : 'none';
            amount.required = partial;
        }
        dec.addEventListener('change', sync);
        document.querySelectorAll('.btn-resolve').forEach(function (b) {
            b.addEventListener('click', function () {
                document.getElementById('rmCode').value = b.dataset.code;
                document.getElementById('rmCodeLabel').textContent = b.dataset.code;
                amount.value = '';
                hint.textContent = 'Khách yêu cầu ' + Number(b.dataset.claim).toLocaleString('vi-VN') + 'đ, còn hoàn được tối đa '
                        + Number(b.dataset.refundable).toLocaleString('vi-VN') + 'đ.';
                dec.value = 'REFUND_BUYER';
                sync();
                modal.show();
            });
        });
    })();
</script>
</body>
</html>
