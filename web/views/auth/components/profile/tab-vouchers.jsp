<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="tab-pane fade" id="nav-vouchers" role="tabpanel">
    <div class="profile-section-card">
        <div class="profile-section-header">
            <div>
                <span class="section-tag">ƯU ĐÃI DÀNH RIÊNG CHO BẠN</span>
                <h3 class="section-heading">Kho Voucher & Mã Khuyến Mãi</h3>
            </div>
            <span class="badge-soft-warning">
                ${not empty vouchers ? vouchers.size() : 0} voucher sẵn sàng sử dụng
            </span>
        </div>

        <c:choose>
            <c:when test="${not empty vouchers}">
                <div class="row g-3">
                    <c:forEach items="${vouchers}" var="voucher">
                        <div class="col-md-6">
                            <div class="voucher-ticket">
                                <span class="badge bg-success mb-2">${voucher.discountPercent}% OFF</span>
                                <h5 class="fw-bold text-dark mb-1">Mã: ${voucher.code}</h5>
                                <p class="text-muted small mb-0">${voucher.description}</p>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <div class="empty-state-icon">
                        <i class="bi bi-ticket-perforated"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Chưa có mã giảm giá nào</h5>
                    <p class="text-muted small mb-4">Hiện tại bạn chưa có mã voucher nào. Hãy theo dõi các sự kiện khuyến mãi mới nhất trên sàn nhé!</p>
                    <a href="${pageContext.request.contextPath}/home.jsp" class="btn-pill-success py-2">
                        <i class="bi bi-tag me-1"></i> Xem ưu đãi hôm nay
                    </a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

