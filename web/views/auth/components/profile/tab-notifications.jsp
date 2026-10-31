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
                <button type="button" onclick="markAllReadProfile()" class="btn btn-link text-success text-decoration-none small fw-semibold cursor-pointer">
                    <i class="bi bi-check2-all me-1"></i> Đánh dấu đã đọc tất cả
                </button>
            </c:if>
        </div>

        <c:choose>
            <c:when test="${not empty notifications}">
                <div class="border-top divide-y divide-gray-100" id="profile-noti-list">
                    <c:forEach items="${notifications}" var="noti">
                        <a href="${pageContext.request.contextPath}${noti.targetUrl}"
                           onclick="markReadItemProfile(${noti.notificationId})"
                           class="notification-item text-decoration-none d-flex align-items-start gap-3 p-3 transition ${noti.read ? 'bg-white' : 'bg-success bg-opacity-10'} rounded-3 mb-2">
                            <div class="p-2 rounded-circle fs-5 flex-shrink-0 ${noti.type == 'ORDER' ? 'bg-primary bg-opacity-10 text-primary' : (noti.type == 'REVIEW' ? 'bg-warning bg-opacity-10 text-warning' : 'bg-success bg-opacity-10 text-success')}">
                                <c:choose>
                                    <c:when test="${noti.type == 'ORDER'}"><i class="bi bi-box-seam"></i></c:when>
                                    <c:when test="${noti.type == 'REVIEW'}"><i class="bi bi-star"></i></c:when>
                                    <c:otherwise><i class="bi bi-bell"></i></c:otherwise>
                                </c:choose>
                            </div>
                            <div class="flex-grow-1">
                                <div class="d-flex align-items-center justify-content-between">
                                    <strong class="text-dark small">${noti.title}</strong>
                                    <span class="text-muted text-nowrap" style="font-size: 11px;">${noti.timeAgo}</span>
                                </div>
                                <p class="text-muted small mb-0 mt-1">${noti.message}</p>
                            </div>
                        </a>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty-state py-5 text-center">
                    <div class="empty-state-icon mb-3 text-muted fs-1">
                        <i class="bi bi-bell-slash"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Chưa có thông báo mới</h5>
                    <p class="text-muted small mb-0">Các cập nhật về đơn hàng, vận chuyển chuỗi lạnh, đánh giá và khuyến mãi sẽ xuất hiện tại đây.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script>
function markAllReadProfile() {
    fetch('${pageContext.request.contextPath}/api/notifications', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'action=read_all'
    }).then(res => res.json()).then(data => {
        if (data.success) {
            window.location.reload();
        }
    });
}

function markReadItemProfile(id) {
    fetch('${pageContext.request.contextPath}/api/notifications', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'action=read&id=' + id
    });
}
</script>
