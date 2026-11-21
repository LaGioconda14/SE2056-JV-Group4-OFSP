<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="hdSearchAction" value="${not empty param.searchAction ? param.searchAction : '/shop/products'}" />

<header class="shop-header">
    <div class="flex items-center gap-3">
        <button type="button" class="shop-sidebar-toggle" id="shopSidebarToggle" aria-label="Mở menu">
            <i class="fa-solid fa-bars text-sm"></i>
        </button>

        <div class="header-search-container" style="width: 390px;">
            <form id="shopHeaderSearchForm" action="${ctx}${hdSearchAction}" method="GET" onsubmit="handleShopHeaderSearch(event)" class="relative flex items-center">
                <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs"></i>
                <input type="text" id="shopHeaderSearch" name="keyword" value="<c:out value='${param.keyword}'/>"
                       placeholder="Tìm nông sản, SKU hoặc mã đơn... (Ctrl + K)"
                       class="header-search-input">
            </form>
        </div>
    </div>

    <div class="flex items-center gap-4">
        <a href="${ctx}/home" class="hidden sm:inline-flex items-center gap-2 px-3 py-1.5 rounded-xl border border-emerald-200 bg-emerald-50 text-emerald-700 text-xs font-bold hover:bg-emerald-100 transition"
           title="Về trang chủ mua sắm">
            <i class="fa-solid fa-house text-[11px]"></i> Về trang chủ
        </a>

        <div class="status-receiving-orders">
            <span class="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
            <span>Đang nhận đơn</span>
        </div>

        <button class="header-icon-action" type="button" title="Tin nhắn">
            <i class="fa-regular fa-comment-dots text-sm"></i>
        </button>

        <div class="relative" id="shop-noti-container">
            <button type="button" id="shop-noti-btn" onclick="toggleShopNotifications(event)"
                    class="header-icon-action relative flex items-center justify-center cursor-pointer" 
                    title="Thông báo Shop" aria-label="Thông báo Shop">
                <i class="fa-regular fa-bell text-sm"></i>
                <span id="shop-header-noti-badge" class="hidden header-icon-badge">0</span>
            </button>

            <div id="shop-noti-popover" class="hidden absolute right-0 mt-2 w-80 sm:w-96 bg-white rounded-2xl shadow-2xl border border-slate-200 p-4 z-50 transform origin-top-right transition-all">
                <div class="flex items-center justify-between pb-3 border-b border-slate-100 mb-2.5">
                    <div class="flex items-center gap-2">
                        <i class="fa-solid fa-bell text-emerald-700 text-sm"></i>
                        <span class="font-extrabold text-slate-900 text-xs uppercase tracking-wider">Thông báo Shop</span>
                    </div>
                    <button type="button" onclick="clearAllShopNotifications(event)" class="text-[11px] text-emerald-700 hover:text-emerald-800 hover:underline font-bold cursor-pointer">
                        Đánh dấu đã đọc
                    </button>
                </div>
                <div class="max-h-80 overflow-y-auto space-y-2" id="shop-noti-list">
                    <div class="py-8 text-center text-slate-400 text-xs">
                        <i class="fa-regular fa-bell-slash text-2xl text-slate-300 block mb-2"></i>
                        Đang tải thông báo...
                    </div>
                </div>
                <div class="pt-2.5 border-t border-slate-100 mt-2.5 text-center">
                    <a href="${ctx}/profile#notifications" class="text-xs font-bold text-emerald-700 hover:text-emerald-800 hover:underline inline-flex items-center gap-1">
                        Xem tất cả thông báo <i class="fa-solid fa-chevron-right text-[10px]"></i>
                    </a>
                </div>
            </div>
        </div>

        <!-- User Profile Dropdown Menu -->
        <div class="relative group" id="shop-user-menu-container">
            <button type="button" id="shop-user-menu-btn" onclick="toggleShopUserMenu(event)"
                    class="flex items-center gap-2.5 pl-3 border-l border-slate-200 cursor-pointer focus:outline-none"
                    title="Menu tài khoản chủ shop">
                <div class="text-right hidden sm:block">
                    <span class="text-xs font-bold text-gray-900 block leading-tight group-hover:text-emerald-700 transition">
                        <c:out value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Chủ gian hàng'}" />
                    </span>
                    <span class="text-[11px] text-gray-500 block leading-tight">Chủ gian hàng</span>
                </div>
                <div class="w-9 h-9 rounded-full bg-[#166534] text-white flex items-center justify-center font-bold text-sm shrink-0 shadow-xs ring-2 ring-transparent group-hover:ring-emerald-500/30 transition overflow-hidden">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user.avatarUrl}">
                            <c:set var="userAvt" value="${sessionScope.user.avatarUrl.startsWith('http://') or sessionScope.user.avatarUrl.startsWith('https://') ? sessionScope.user.avatarUrl : (sessionScope.user.avatarUrl.startsWith('/') ? pageContext.request.contextPath.concat(sessionScope.user.avatarUrl) : pageContext.request.contextPath.concat('/').concat(sessionScope.user.avatarUrl))}" />
                            <img src="${userAvt}" alt="Avatar" class="w-full h-full object-cover" onerror="this.onerror=null; this.src='https://ui-avatars.com/api/?name=${sessionScope.user.fullName}&background=166534&color=fff';">
                        </c:when>
                        <c:otherwise>
                            <i class="fa-regular fa-user text-xs"></i>
                        </c:otherwise>
                    </c:choose>
                </div>
                <i class="fa-solid fa-chevron-down text-[10px] text-slate-400 group-hover:text-slate-700 transition"></i>
            </button>

            <!-- Dropdown Menu Popover (Mở khi hover hoặc click) -->
            <div id="shop-user-menu-popover"
                 class="hidden group-hover:block absolute right-0 top-full pt-1.5 w-72 z-50 transform origin-top-right transition-all">
                <div class="bg-white rounded-2xl shadow-2xl border border-slate-200 p-2 text-left">
                    <!-- Thông tin tóm tắt -->
                    <div class="px-3 py-2.5 bg-slate-50 rounded-xl mb-1.5 border border-slate-100">
                        <p class="text-xs font-extrabold text-slate-900 truncate">
                            <c:out value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Chủ gian hàng'}" />
                        </p>
                        <p class="text-[11px] text-slate-500 truncate mt-0.5">
                            <c:out value="${not empty sessionScope.user.email ? sessionScope.user.email : ''}" />
                        </p>
                        <div class="mt-2 flex items-center gap-1.5 flex-wrap">
                            <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[10px] font-bold bg-emerald-100 text-emerald-800 border border-emerald-200 truncate max-w-[180px]">
                                <i class="fa-solid fa-leaf text-[9px]"></i> <c:out value="${not empty sessionScope.shopName ? sessionScope.shopName : (not empty sessionScope.shopObj.shopName ? sessionScope.shopObj.shopName : 'Gian hàng')}" />
                            </span>
                            <span class="px-1.5 py-0.5 rounded text-[9px] font-black uppercase bg-slate-200 text-slate-700 tracking-wider">
                                SELLER
                            </span>
                        </div>
                    </div>

                    <!-- Các mục điều hướng -->
                    <div class="space-y-0.5">
                        <!-- Xem gian hàng thực tế (khách hàng nhìn thấy) -->
                        <c:set var="targetShopId" value="${not empty sessionScope.shopId ? sessionScope.shopId : (not empty sessionScope.shopObj.shopId ? sessionScope.shopObj.shopId : 1)}" />
                        <a href="${ctx}/store?id=${targetShopId}" target="_blank"
                           class="flex items-center justify-between px-3 py-2 text-xs font-semibold text-slate-700 hover:text-emerald-700 hover:bg-emerald-50 rounded-xl transition group/item">
                            <span class="flex items-center gap-2.5">
                                <i class="fa-solid fa-store text-slate-400 group-hover/item:text-emerald-600 w-4 text-center"></i>
                                <span>Xem gian hàng (khách thấy)</span>
                            </span>
                            <i class="fa-solid fa-arrow-up-right-from-square text-[10px] text-slate-400 group-hover/item:text-emerald-600"></i>
                        </a>

                        <!-- Cài đặt & Thông tin Shop -->
                        <a href="${ctx}/shop/profile"
                           class="flex items-center gap-2.5 px-3 py-2 text-xs font-semibold text-slate-700 hover:text-emerald-700 hover:bg-emerald-50 rounded-xl transition group/item">
                            <i class="fa-solid fa-id-card text-slate-400 group-hover/item:text-emerald-600 w-4 text-center"></i>
                            <span>Hồ sơ &amp; Cài đặt Shop</span>
                        </a>

                        <!-- Profile của chủ shop -->
                        <a href="${ctx}/profile"
                           class="flex items-center gap-2.5 px-3 py-2 text-xs font-semibold text-slate-700 hover:text-emerald-700 hover:bg-emerald-50 rounded-xl transition group/item">
                            <i class="fa-regular fa-user text-slate-400 group-hover/item:text-emerald-600 w-4 text-center"></i>
                            <span>Hồ sơ cá nhân chủ shop</span>
                        </a>

                        <!-- Đổi mật khẩu -->
                        <a href="${ctx}/change-password"
                           class="flex items-center gap-2.5 px-3 py-2 text-xs font-semibold text-slate-700 hover:text-emerald-700 hover:bg-emerald-50 rounded-xl transition group/item">
                            <i class="fa-solid fa-key text-slate-400 group-hover/item:text-emerald-600 w-4 text-center"></i>
                            <span>Đổi mật khẩu</span>
                        </a>

                        <div class="h-px bg-slate-100 my-1"></div>

                        <!-- Về trang chủ mua sắm -->
                        <a href="${ctx}/home"
                           class="flex items-center gap-2.5 px-3 py-2 text-xs font-semibold text-slate-700 hover:text-emerald-700 hover:bg-emerald-50 rounded-xl transition group/item">
                            <i class="fa-solid fa-house text-slate-400 group-hover/item:text-emerald-600 w-4 text-center"></i>
                            <span>Về trang chủ mua sắm</span>
                        </a>

                        <div class="h-px bg-slate-100 my-1"></div>

                        <!-- Đăng xuất -->
                        <a href="${ctx}/logout"
                           class="flex items-center gap-2.5 px-3 py-2 text-xs font-bold text-rose-600 hover:bg-rose-50 rounded-xl transition group/item">
                            <i class="fa-solid fa-right-from-bracket text-rose-400 group-hover/item:text-rose-600 w-4 text-center"></i>
                            <span>Đăng xuất</span>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</header>

<script>
    window.handleShopHeaderSearch = function(e) {
        if (e) e.preventDefault();
        var input = document.getElementById('shopHeaderSearch');
        var kw = input ? input.value.trim() : '';
        if (!kw) return;

        var isOrder = /^SUB-/i.test(kw) || /^ORD-/i.test(kw) || /^\d{4,}$/.test(kw);
        if (isOrder) {
            window.location.href = '${ctx}/shop/orders?keyword=' + encodeURIComponent(kw);
        } else {
            window.location.href = '${ctx}/shop/products?keyword=' + encodeURIComponent(kw);
        }
    };

    window.toggleShopUserMenu = function(e) {
        if (e) {
            e.stopPropagation();
            e.preventDefault();
        }
        var notiPop = document.getElementById('shop-noti-popover');
        if (notiPop) notiPop.classList.add('hidden');

        var menu = document.getElementById('shop-user-menu-popover');
        if (menu) {
            if (menu.classList.contains('hidden')) {
                menu.classList.remove('hidden');
                menu.classList.add('block');
            } else {
                menu.classList.add('hidden');
                menu.classList.remove('block');
            }
        }
    };

    window.toggleShopNotifications = function(e) {
        if (e) {
            e.stopPropagation();
            e.preventDefault();
        }
        var popover = document.getElementById('shop-noti-popover');
        if (popover) {
            var isHidden = popover.classList.contains('hidden');
            if (isHidden) {
                popover.classList.remove('hidden');
                loadShopNotifications();
            } else {
                popover.classList.add('hidden');
            }
        }
    };

    window.clearAllShopNotifications = async function(e) {
        if (e) e.stopPropagation();
        try {
            var res = await fetch('${ctx}/api/notifications/mark-all-read', { method: 'POST' });
            if (res.ok) {
                var badge = document.getElementById('shop-header-noti-badge');
                if (badge) {
                    badge.classList.add('hidden');
                    badge.textContent = '0';
                }
                loadShopNotifications();
            }
        } catch (err) {
            console.error(err);
        }
    };

    window.markShopNotificationRead = async function(id, redirectUrl, e) {
        if (e) e.stopPropagation();
        try {
            await fetch('${ctx}/api/notifications/mark-read?notificationId=' + encodeURIComponent(id) + '&id=' + encodeURIComponent(id), { method: 'POST' });
        } catch (err) {
            console.error(err);
        }
        if (redirectUrl) {
            window.location.href = redirectUrl;
        } else {
            loadShopNotifications();
            loadShopNotiBadge();
        }
    };

    async function loadShopNotifications() {
        var list = document.getElementById('shop-noti-list');
        if (!list) return;
        try {
            var res = await fetch('${ctx}/api/notifications/recent?limit=10');
            if (!res.ok) {
                list.innerHTML = '<div class="py-6 text-center text-slate-400 text-xs">Không thể tải thông báo</div>';
                return;
            }
            var data = await res.json();
            var badge = document.getElementById('shop-header-noti-badge');
            if (badge) {
                var unread = data.unreadCount || 0;
                if (unread > 0) {
                    badge.textContent = unread > 99 ? '99+' : unread;
                    badge.classList.remove('hidden');
                } else {
                    badge.classList.add('hidden');
                }
            }
            if (!data.notifications || data.notifications.length === 0) {
                list.innerHTML = '<div class="py-8 text-center text-slate-400 text-xs"><i class="fa-regular fa-bell-slash text-2xl text-slate-300 block mb-2"></i>Hiện tại chưa có thông báo nào</div>';
                return;
            }
            list.innerHTML = data.notifications.map(function(n) {
                var link = '';
                if (n.referenceType === 'ORDER' || n.referenceType === 'SUB_ORDER') {
                    link = '${ctx}/shop/orders';
                } else if (n.referenceType === 'BATCH' || (n.type === 'SYSTEM' && n.title && n.title.indexOf('Lô') !== -1)) {
                    link = '${ctx}/shop/inventory';
                }
                var bgCls = n.isRead ? 'bg-slate-50/70 border-slate-100 hover:bg-slate-100/70' : 'bg-emerald-50/70 border-emerald-100 hover:bg-emerald-100/70';
                var icon = n.type === 'ORDER' ? 'fa-box-open text-emerald-600' : (n.type === 'PROMOTION' ? 'fa-tags text-amber-500' : (n.referenceType === 'BATCH' ? 'fa-boxes-stacked text-amber-500' : 'fa-bell text-blue-500'));
                var unreadDot = !n.isRead ? '<span class="w-2 h-2 rounded-full bg-emerald-600 shrink-0 mt-1"></span>' : '';
                return '<div onclick="markShopNotificationRead(' + n.notificationId + ', \'' + link + '\', event)" ' +
                       'class="flex items-start gap-3 p-2.5 rounded-xl border ' + bgCls + ' text-xs cursor-pointer transition">' +
                       '<div class="w-7 h-7 rounded-lg bg-white shadow-2xs border border-slate-200 flex items-center justify-center shrink-0 mt-0.5">' +
                       '<i class="fa-solid ' + icon + ' text-xs"></i>' +
                       '</div>' +
                       '<div class="flex-1 min-w-0">' +
                       '<p class="font-extrabold text-slate-900 truncate leading-tight">' + (n.title || 'Thông báo mới') + '</p>' +
                       '<p class="text-slate-600 text-[11px] mt-1 line-clamp-2 leading-relaxed">' + (n.message || '') + '</p>' +
                       '<span class="text-[10px] text-slate-400 mt-1 inline-block">' + (n.timeAgo || '') + '</span>' +
                       '</div>' +
                       unreadDot +
                       '</div>';
            }).join('');
        } catch (err) {
            list.innerHTML = '<div class="py-6 text-center text-slate-400 text-xs">Lỗi khi tải thông báo</div>';
        }
    }

    async function loadShopNotiBadge() {
        try {
            var res = await fetch('${ctx}/api/notifications/unread-count');
            if (!res.ok) return;
            var data = await res.json();
            var badge = document.getElementById('shop-header-noti-badge');
            if (badge && data && data.count > 0) {
                badge.textContent = data.count > 99 ? '99+' : data.count;
                badge.classList.remove('hidden');
            } else if (badge) {
                badge.classList.add('hidden');
            }
        } catch (e) {}
    }

    document.addEventListener('DOMContentLoaded', loadShopNotiBadge);

    document.addEventListener('click', function(e) {
        var container = document.getElementById('shop-noti-container');
        var popover = document.getElementById('shop-noti-popover');
        if (container && popover && !container.contains(e.target)) {
            popover.classList.add('hidden');
        }

        var userContainer = document.getElementById('shop-user-menu-container');
        var userPopover = document.getElementById('shop-user-menu-popover');
        if (userContainer && userPopover && !userContainer.contains(e.target)) {
            userPopover.classList.add('hidden');
            userPopover.classList.remove('block');
        }
    });

    document.addEventListener('keydown', function(e) {
        if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') {
            e.preventDefault();
            var searchInput = document.getElementById('shopHeaderSearch');
            if (searchInput) {
                searchInput.focus();
                searchInput.select();
            }
        }
        if (e.key === 'Escape') {
            var popover = document.getElementById('shop-noti-popover');
            if (popover) popover.classList.add('hidden');
            var userPopover = document.getElementById('shop-user-menu-popover');
            if (userPopover) {
                userPopover.classList.add('hidden');
                userPopover.classList.remove('block');
            }
        }
    });
</script>
