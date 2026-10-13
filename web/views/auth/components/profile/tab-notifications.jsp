<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="tab-pane fade" id="nav-notifications" role="tabpanel">
    <div class="profile-section-card">
        <div class="profile-section-header">
            <div>
                <span class="section-tag">KẾT NỐI & CẬP NHẬT</span>
                <h3 class="section-heading">Hộp Thư Thông Báo</h3>
            </div>
            <c:if test="${not empty notifications}">
                <button class="btn btn-link text-success text-decoration-none small fw-semibold">
                    <i class="bi bi-check2-all me-1"></i> Đánh dấu đã đọc tất cả
                </button>
            </c:if>
        </div>

        <c:choose>
            <c:when test="${not empty notifications}">
                <div class="border-top">
                    <c:forEach items="${notifications}" var="noti">
                        <div class="notification-item">
                            <div class="bg-primary bg-opacity-10 text-primary p-2 rounded-circle fs-5 flex-shrink-0">
                                <i class="bi bi-bell"></i>
                            </div>
                            <div class="flex-grow-1">
                                <strong class="text-dark small">${noti.title}</strong>
                                <p class="text-muted small mb-0 mt-1">${noti.content}</p>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <div class="empty-state-icon">
                        <i class="bi bi-bell-slash"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Chưa có thông báo mới</h5>
                    <p class="text-muted small mb-0">Các cập nhật về đơn hàng, vận chuyển chuỗi lạnh và khuyến mãi sẽ xuất hiện tại đây.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

