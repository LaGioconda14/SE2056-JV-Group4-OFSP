<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="tab-pane fade" id="nav-notifications" role="tabpanel">
    <div class="profile-section-card">
        <div class="profile-section-header">
            <div>
                <h3 class="section-heading mb-0">Hộp Thư Thông Báo</h3>
            </div>
            <c:if test="${not empty notifications}">
                <button type="button" onclick="markAllNotificationsReadProfile()" class="btn btn-link text-success text-decoration-none small fw-semibold">
                    <i class="bi bi-check2-all me-1"></i> Đánh dấu đã đọc tất cả
                </button>
            </c:if>
        </div>

        <c:choose>
            <c:when test="${not empty notifications}">
                <div class="border-top">
                    <c:forEach items="${notifications}" var="noti">
                        <div class="notification-item py-3 d-flex align-items-start gap-3 border-bottom ${noti.read ? 'opacity-75' : ''}" id="profile-noti-${noti.notificationId}">
                            <div class="rounded-circle d-flex align-items-center justify-content-center flex-shrink-0 ${noti.read ? 'bg-secondary bg-opacity-10 text-secondary' : 'bg-success bg-opacity-10 text-success'}" style="width: 42px; height: 42px;">
                                <i class="bi ${noti.iconClass} fs-5"></i>
                            </div>
                            <div class="flex-grow-1 min-w-0">
                                <div class="d-flex align-items-baseline justify-content-between gap-2">
                                    <strong class="text-dark small ${noti.read ? '' : 'fw-bold text-success'}"><c:out value="${noti.title}"/></strong>
                                    <div class="d-flex align-items-center gap-2 flex-shrink-0">
                                        <span class="text-muted" style="font-size: 0.75rem;"><c:out value="${noti.timeAgo}"/></span>
                                        <button type="button" onclick="deleteNotificationProfile(${noti.notificationId})" class="btn btn-link p-0 text-muted" title="Xóa thông báo" style="font-size: 0.8rem; line-height: 1;">
                                            <i class="bi bi-x-lg"></i>
                                        </button>
                                    </div>
                                </div>
                                <p class="text-muted small mb-1 mt-1"><c:out value="${noti.message}"/></p>
                                <c:if test="${not noti.read}">
                                    <button type="button" onclick="markSingleNotificationReadProfile(${noti.notificationId})" class="btn-mark-read-single btn btn-sm btn-link p-0 text-success text-decoration-none fw-semibold" style="font-size: 0.75rem;">
                                        <i class="bi bi-check2"></i> Đánh dấu đã đọc
                                    </button>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty-state py-5 text-center">
                    <div class="empty-state-icon mb-3">
                        <i class="bi bi-bell-slash text-muted" style="font-size: 2.5rem;"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Chưa có thông báo mới</h5>
                    <p class="text-muted small mb-0">Các cập nhật về đơn hàng, vận chuyển chuỗi lạnh và khuyến mãi sẽ xuất hiện tại đây.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script>
async function markAllNotificationsReadProfile() {
    try {
        const res = await fetch('${pageContext.request.contextPath}/api/notifications/mark-all-read', { method: 'POST' });
        if (res.ok) {
            window.location.reload();
        }
    } catch (e) {
        console.error(e);
    }
}

async function markSingleNotificationReadProfile(id) {
    try {
        const res = await fetch('${pageContext.request.contextPath}/api/notifications/mark-read?notificationId=' + id, { method: 'POST' });
        if (res.ok) {
            const item = document.getElementById('profile-noti-' + id);
            if (item) {
                item.classList.add('opacity-75');
                const title = item.querySelector('strong');
                if (title) title.classList.remove('text-success');
                const btn = item.querySelector('.btn-mark-read-single');
                if (btn) btn.remove();
            }
        }
    } catch (e) {
        console.error(e);
    }
}

async function deleteNotificationProfile(id) {
    try {
        const res = await fetch('${pageContext.request.contextPath}/api/notifications/delete?notificationId=' + id, { method: 'POST' });
        if (res.ok) {
            const item = document.getElementById('profile-noti-' + id);
            if (item) item.remove();
        }
    } catch (e) {
        console.error(e);
    }
}
</script>
