<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông Báo | Gốc Vườn Marketplace</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="bg-gray-50 text-gray-800 font-sans min-h-screen flex flex-col justify-between">

    <jsp:include page="/views/common/header.jsp"/>

    <main class="max-w-4xl mx-auto px-4 py-8 flex-1 w-full">
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 md:p-8">
            <div class="flex items-center justify-between pb-6 border-b border-gray-100 flex-wrap gap-4">
                <div class="flex items-center gap-3">
                    <div class="w-12 h-12 rounded-2xl bg-emerald-100 text-[#00652c] flex items-center justify-center text-xl font-bold">
                        <i class="bi bi-bell-fill"></i>
                    </div>
                    <div>
                        <h1 class="text-xl sm:text-2xl font-black text-gray-900">Trung Tâm Thông Báo</h1>
                        <p class="text-xs text-gray-500">Cập nhật lộ trình đơn hàng, mã giảm giá và tin tức từ nhà vườn</p>
                    </div>
                </div>
                <div class="flex items-center gap-2">
                    <c:if test="${unreadCount > 0}">
                        <button type="button" onclick="markAllNotificationsRead()" class="text-xs font-bold text-[#00652c] hover:underline flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-emerald-50 border border-emerald-200 transition">
                            <i class="bi bi-check2-all"></i> Đánh dấu đã đọc tất cả
                        </button>
                    </c:if>
                    <button type="button" onclick="deleteAllReadNotifications()" class="text-xs font-bold text-gray-500 hover:text-red-600 hover:underline flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-gray-50 border border-gray-200 transition" title="Xóa các thông báo đã đọc">
                        <i class="bi bi-trash3"></i> Xóa đã đọc
                    </button>
                </div>

            <div class="mt-6 divide-y divide-gray-100" id="notification-list">
                <c:choose>
                    <c:when test="${not empty notifications}">
                        <c:forEach items="${notifications}" var="n">
                            <div class="py-4.5 flex items-start gap-3.5 transition hover:bg-gray-50/70 p-3 rounded-2xl ${n.read ? 'opacity-70' : 'bg-emerald-50/20'}" id="notif-row-${n.notificationId}">
                                <div class="w-10 h-10 rounded-xl bg-white border border-gray-200 flex items-center justify-center text-lg shrink-0 shadow-xs">
                                    <i class="bi ${n.iconClass}"></i>
                                </div>
                                <div class="flex-1 min-w-0">
                                    <div class="flex items-baseline justify-between gap-2">
                                        <h3 class="text-sm font-bold text-gray-900 truncate ${n.read ? '' : 'text-[#00652c]'}"><c:out value="${n.title}"/></h3>
                                        <div class="flex items-center gap-2 shrink-0">
                                            <span class="text-[11px] text-gray-400 whitespace-nowrap"><c:out value="${n.timeAgo}"/></span>
                                            <button type="button" onclick="deleteNotification(${n.notificationId})" class="text-gray-300 hover:text-red-600 p-1 rounded-lg transition" title="Xóa thông báo này">
                                                <i class="bi bi-x-lg text-xs"></i>
                                            </button>
                                        </div>
                                    </div>
                                    <p class="text-xs text-gray-600 mt-1 leading-relaxed"><c:out value="${n.message}"/></p>
                                    <c:if test="${not n.read}">
                                        <button type="button" onclick="markSingleRead(${n.notificationId})" class="text-[11px] text-emerald-700 font-bold hover:underline mt-2 inline-block">
                                            Đánh dấu đã đọc
                                        </button>
                                    </c:if>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="py-16 text-center text-gray-400">
                            <i class="bi bi-bell-slash text-4xl text-gray-300 mb-3 block"></i>
                            <p class="text-sm font-semibold text-gray-600">Bạn chưa có thông báo nào</p>
                            <p class="text-xs text-gray-400 mt-1">Các thông tin về đơn hàng và cập nhật sẽ xuất hiện tại đây.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </main>

    <jsp:include page="/views/common/footer.jsp"/>

    <script>
        async function markAllNotificationsRead() {
            try {
                const res = await fetch('${pageContext.request.contextPath}/api/notifications/mark-all-read', { method: 'POST' });
                if (res.ok) {
                    location.reload();
                }
            } catch (e) {
                console.error(e);
            }
        }

        async function markSingleRead(id) {
            try {
                const res = await fetch('${pageContext.request.contextPath}/api/notifications/mark-read?notificationId=' + id, { method: 'POST' });
                if (res.ok) {
                    const row = document.getElementById('notif-row-' + id);
                    if (row) {
                        row.classList.add('opacity-70');
                        row.classList.remove('bg-emerald-50/20');
                    }
                }
            } catch (e) {
                console.error(e);
            }
        }

        async function deleteNotification(id) {
            if (!confirm('Bạn có chắc muốn xóa thông báo này?')) return;
            try {
                const res = await fetch('${pageContext.request.contextPath}/api/notifications/delete?notificationId=' + id, { method: 'POST' });
                if (res.ok) {
                    const row = document.getElementById('notif-row-' + id);
                    if (row) {
                        row.remove();
                    }
                    const list = document.getElementById('notification-list');
                    if (list && list.children.length === 0) {
                        location.reload();
                    }
                }
            } catch (e) {
                console.error(e);
            }
        }

        async function deleteAllReadNotifications() {
            if (!confirm('Xóa tất cả các thông báo đã đọc?')) return;
            try {
                const res = await fetch('${pageContext.request.contextPath}/api/notifications/delete-all-read', { method: 'POST' });
                if (res.ok) {
                    location.reload();
                }
            } catch (e) {
                console.error(e);
            }
        }
    </script>
</body>
</html>
