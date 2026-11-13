<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<c:url var="loyaltyUrl" value="/admin/loyalty"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Luật Điểm Thưởng - Gốc Vườn Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css?v=14">
</head>
<body class="admin-body">
<div class="admin-wrapper">
    <jsp:include page="layout/sidebar.jsp">
        <jsp:param name="activePage" value="loyalty" />
    </jsp:include>

    <div class="admin-main">
        <jsp:include page="layout/header.jsp" />

        <main class="admin-page-content">
            <div class="admin-breadcrumbs mb-2 text-muted" style="font-size:.76rem;">
                <span>Quản trị sàn</span> <span class="mx-1">&gt;</span> <span>Thành viên &amp; điểm thưởng</span>
                <span class="mx-1">&gt;</span> <span class="text-dark fw-semibold">Luật điểm thưởng</span>
            </div>
            <h1 class="users-header-title">Luật Chương Trình Điểm Thưởng</h1>
            <p class="users-header-desc">Cấu hình tỉ lệ tích điểm, giá trị quy đổi và điều chỉnh điểm của từng khách hàng.</p>

            <c:if test="${not empty sessionScope.adminFlash}">
                <div class="alert alert-success py-2 fw-semibold" style="font-size:.82rem;"><i class="bi bi-check-circle-fill me-1"></i><c:out value="${sessionScope.adminFlash}"/></div>
                <c:remove var="adminFlash" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.adminError}">
                <div class="alert alert-danger py-2 fw-semibold" style="font-size:.82rem;"><i class="bi bi-exclamation-triangle-fill me-1"></i><c:out value="${sessionScope.adminError}"/></div>
                <c:remove var="adminError" scope="session"/>
            </c:if>

            <!-- ===== Luật chương trình ===== -->
            <form method="post" action="<c:out value='${loyaltyUrl}'/>" class="users-filter-card d-block mb-3">
                <input type="hidden" name="action" value="saveRules">
                <div class="fw-bold mb-2" style="font-size:.9rem;">Luật tích điểm &amp; dùng điểm</div>
                <div class="row g-3 align-items-end">
                    <div class="col-md-3">
                        <label class="form-label mb-1" style="font-size:.7rem;font-weight:700;">SỐ TIỀN CHO 1 ĐIỂM (VNĐ)</label>
                        <input type="number" name="earnVndPerPoint" min="1000" max="1000000" step="1000" required class="form-control form-control-sm" value="${settings.earnVndPerPoint}">
                        <div class="form-text" style="font-size:.68rem;">Đơn hoàn tất: cứ chừng này đồng được 1 điểm</div>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label mb-1" style="font-size:.7rem;font-weight:700;">GIÁ TRỊ 1 ĐIỂM KHI DÙNG (VNĐ)</label>
                        <input type="number" name="redeemVndPerPoint" min="1" max="10000" required class="form-control form-control-sm" value="${settings.redeemVndPerPoint}">
                        <div class="form-text" style="font-size:.68rem;">Số tiền giảm của mỗi điểm khi thanh toán</div>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label mb-1" style="font-size:.7rem;font-weight:700;">TRẦN DÙNG ĐIỂM (% ĐƠN HÀNG)</label>
                        <input type="number" name="maxRedeemPercent" min="0" max="100" required class="form-control form-control-sm" value="${settings.maxRedeemPercent}">
                        <div class="form-text" style="font-size:.68rem;">Hạng thành viên có thể đặt trần riêng</div>
                    </div>
                    <div class="col-md-3">
                        <button type="submit" class="btn btn-sm btn-success w-100 fw-bold"><i class="bi bi-save me-1"></i>Lưu luật</button>
                    </div>
                </div>
                <div class="text-muted mt-2" style="font-size:.7rem;">
                    Chỉ đơn hoàn tất từ <strong><c:out value="${settings.earnStartDate}"/></strong> mới được cộng điểm. Thay đổi luật chỉ áp dụng cho các đơn sau này.
                </div>
            </form>

            <!-- ===== Tìm khách & điều chỉnh điểm ===== -->
            <div class="row g-3">
                <div class="col-lg-6">
                    <form method="get" action="<c:out value='${loyaltyUrl}'/>" class="users-filter-card d-block h-100">
                        <div class="fw-bold mb-2" style="font-size:.9rem;">Tìm khách hàng</div>
                        <div class="input-group input-group-sm mb-2">
                            <input type="text" name="q" value="<c:out value='${q}'/>" class="form-control" placeholder="Tên, email hoặc số điện thoại">
                            <button class="btn btn-success" type="submit"><i class="bi bi-search"></i> Tìm</button>
                        </div>
                        <c:if test="${not empty q}">
                            <table class="table table-sm align-middle mb-0" style="font-size:.78rem;">
                                <tbody>
                                <c:forEach items="${results}" var="r">
                                    <tr>
                                        <td><strong><c:out value="${r.fullName}"/></strong>
                                            <div class="text-muted" style="font-size:.7rem;"><c:out value="${r.email}"/></div></td>
                                        <td class="text-end"><fmt:formatNumber value="${r.points}"/> điểm</td>
                                        <td class="text-end"><a class="btn btn-sm btn-outline-success py-0" href="<c:out value='${loyaltyUrl}'/>?q=<c:out value='${q}'/>&amp;customerId=${r.userId}">Chọn</a></td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty results}"><tr><td class="text-muted">Không tìm thấy khách hàng phù hợp.</td></tr></c:if>
                                </tbody>
                            </table>
                        </c:if>
                    </form>
                </div>

                <div class="col-lg-6">
                    <div class="users-filter-card d-block h-100">
                        <div class="fw-bold mb-2" style="font-size:.9rem;">Điều chỉnh điểm</div>
                        <c:choose>
                            <c:when test="${not empty customer}">
                                <div class="mb-2" style="font-size:.8rem;">
                                    <strong><c:out value="${customer.fullName}"/></strong> · <span class="text-muted"><c:out value="${customer.email}"/></span><br>
                                    Điểm hiện có: <strong class="text-success"><fmt:formatNumber value="${customerAccount.currentPoints}"/></strong>
                                    · Hạng: <strong><c:out value="${customerAccount.tier.tierName}"/></strong>
                                    · Tích luỹ: <fmt:formatNumber value="${customerAccount.lifetimePoints}"/>
                                </div>
                                <form method="post" action="<c:out value='${loyaltyUrl}'/>" class="row g-2 align-items-end">
                                    <input type="hidden" name="action" value="adjust">
                                    <input type="hidden" name="customerId" value="${customer.userId}">
                                    <div class="col-md-4">
                                        <label class="form-label mb-1" style="font-size:.7rem;font-weight:700;">SỐ ĐIỂM (+ / -)</label>
                                        <input type="number" name="delta" class="form-control form-control-sm" placeholder="VD: 100 hoặc -50" required>
                                    </div>
                                    <div class="col-md-8">
                                        <label class="form-label mb-1" style="font-size:.7rem;font-weight:700;">LÝ DO</label>
                                        <input type="text" name="reason" maxlength="200" class="form-control form-control-sm" placeholder="VD: Bù điểm do lỗi hệ thống" required>
                                    </div>
                                    <div class="col-12">
                                        <button type="submit" class="btn btn-sm btn-success fw-bold"><i class="bi bi-check2-circle me-1"></i>Áp dụng điều chỉnh</button>
                                    </div>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <p class="text-muted mb-0" style="font-size:.8rem;">Tìm và chọn một khách hàng ở bên trái để điều chỉnh điểm.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/admin.js?v=7"></script>
</body>
</html>
