<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="currentUser" value="${not empty sessionScope.account ? sessionScope.account : sessionScope.user}" />
<c:set var="cartSize" value="${sessionScope.cartSize != null ? sessionScope.cartSize : 0}" />
<c:url var="homeUrl" value="/home" />
<c:url var="cartUrl" value="/cart" />
<c:url var="productsUrl" value="/products" />
<c:url var="loginUrl" value="/login" />
<c:url var="logoutUrl" value="/logout" />
<c:url var="profileUrl" value="/profile" />
<c:url var="changePasswordUrl" value="/change-password" />

<!-- Material Symbols & Fonts -->
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet">
<style>
    .material-symbols-outlined {
        font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
    }
</style>

<!-- ==================== HEADER CHUẨN ĐỒNG BỘ CART ==================== -->
<header class="sticky top-0 left-0 right-0 w-full z-50 bg-white/95 backdrop-blur-xl shadow-[0_4px_20px_rgba(20,83,45,0.06)] border-b border-gray-100">
    <!-- Main Header Bar -->
    <div class="max-w-[1360px] mx-auto px-4 lg:px-8 h-20 flex items-center justify-between gap-4 lg:gap-6">
        <!-- 1. Brand Logo -->
        <a href="<c:out value='${homeUrl}'/>" class="flex items-center gap-3 shrink-0 no-underline">
            <!-- Apple Icon SVG -->
            <svg class="h-9 w-9 shrink-0" viewBox="0 0 36 36" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M19 4C19 4 24 4 23 9C20 9 18 7 19 4Z" fill="#16a34a"/>
                <path d="M18 6.5C17.5 8.5 16 10.5 15 11.5" stroke="#4b5563" stroke-width="2" stroke-linecap="round"/>
                <path d="M18 12.5C16 9.5 11 9.5 8 12.5C4 16.5 5 23.5 9 28.5C12 32.5 15 32.5 18 30.5C21 32.5 24 32.5 27 28.5C31 23.5 32 16.5 28 12.5C25 9.5 20 9.5 18 12.5Z" fill="url(#appleGradHeader)"/>
                <defs>
                    <linearGradient id="appleGradHeader" x1="8" y1="11" x2="28" y2="33" gradientUnits="userSpaceOnUse">
                        <stop stop-color="#fb7185"/>
                        <stop offset="0.6" stop-color="#ef4444"/>
                        <stop offset="1" stop-color="#dc2626"/>
                    </linearGradient>
                </defs>
            </svg>
            <div class="flex flex-col">
                <span class="text-2xl font-extrabold text-[#00652c] tracking-tight leading-none">Gốc Vườn</span>
                <span class="text-[9px] font-bold tracking-widest text-[#00652c]/80 uppercase mt-0.5">NÔNG SẢN TẬN VƯỜN</span>
            </div>
        </a>

        <!-- 2. Search Bar -->
        <form method="get" action="${pageContext.request.contextPath}/search" class="flex-1 max-w-2xl hidden md:flex items-center bg-[#f4f7f4] rounded-full px-4 py-1.5 border border-gray-200/80 focus-within:border-[#00652c] transition-colors">
            <div class="flex items-center gap-1 pr-3 text-gray-600 text-xs cursor-pointer shrink-0">
                <select name="categoryId" class="bg-transparent border-0 outline-none text-gray-700 cursor-pointer text-sm font-medium pr-1">
                    <option value="">Tất cả danh mục</option>
                    <option value="1">Trái Cây Nội Địa</option>
                    <option value="2">Trái Cây Nhập Khẩu</option>
                    <option value="3">Hộp Quà &amp; Combo</option>
                    <option value="4">Trái Cây Sấy</option>
                </select>
            </div>
            <div class="h-5 w-px bg-gray-300 mr-3"></div>
            <div class="flex items-center flex-1 gap-2">
                <input class="w-full bg-transparent border-0 outline-none text-gray-800 placeholder:text-gray-400 text-sm"
                       name="query" placeholder="Tìm kiếm dâu tây, bơ sáp, nho mẫu đơn..." type="text"
                       value="<c:out value='${param.query}'/>">
                <button type="submit" class="w-8 h-8 rounded-full bg-[#00652c] text-white flex items-center justify-center hover:bg-[#005323] transition-colors shrink-0" title="Tìm kiếm">
                    <span class="material-symbols-outlined text-[18px]">search</span>
                </button>
            </div>
        </form>

        <!-- 3. Right Header Action Buttons: [Thông báo] [Giỏ hàng] [Hồ sơ / Đăng nhập] -->
        <div class="flex items-center gap-3 shrink-0">
            <!-- Nút Thông Báo (Bell Button) -->
            <div class="relative" id="header-noti-container">
                <button type="button" id="header-noti-btn" onclick="toggleHeaderNotification(event)"
                        class="relative flex items-center justify-center w-10 h-10 rounded-full border border-gray-200 bg-white hover:bg-gray-50 text-gray-700 hover:text-[#00652c] transition-colors cursor-pointer"
                        title="Thông báo">
                    <span class="material-symbols-outlined text-[22px]">notifications</span>
                    <span id="header-noti-badge" class="absolute -top-1 -right-1 min-w-[18px] h-[18px] px-1 bg-red-600 text-white rounded-full text-[10px] font-bold flex items-center justify-center border-2 border-white shadow-xs">
                        1
                    </span>
                </button>

                <!-- Dropdown Thông Báo -->
                <div id="header-noti-popover" class="hidden absolute right-0 mt-2 w-80 sm:w-96 bg-white rounded-2xl shadow-2xl border border-gray-100 p-4 z-50 transform origin-top-right transition-all">
                    <div class="flex items-center justify-between pb-3 border-b border-gray-100 mb-3">
                        <div class="flex items-center gap-2">
                            <span class="material-symbols-outlined text-[#00652c] text-[20px]">notifications_active</span>
                            <span class="font-bold text-gray-900 text-sm">Thông báo</span>
                        </div>
                        <button type="button" onclick="clearAllNotifications(event)" class="text-xs text-[#00652c] hover:underline font-semibold cursor-pointer">Đánh dấu đã đọc</button>
                    </div>
                    <div class="max-h-72 overflow-y-auto space-y-2.5" id="header-noti-list">
                        <!-- Default notifications -->
                        <div class="flex items-start gap-3 p-2.5 rounded-xl bg-emerald-50/70 border border-emerald-100 text-xs text-gray-700">
                            <span class="material-symbols-outlined text-emerald-600 text-[18px] shrink-0 mt-0.5">shopping_bag</span>
                            <div class="flex-1">
                                <p class="font-bold text-gray-900">Giỏ hàng của bạn</p>
                                <p class="text-gray-600 text-[11px] mt-0.5">Bạn đang có <strong class="text-[#00652c]" id="noti-cart-count">${cartSize}</strong> món trong giỏ hàng.</p>
                            </div>
                        </div>
                        <div class="flex items-start gap-3 p-2.5 rounded-xl bg-amber-50/70 border border-amber-100 text-xs text-gray-700">
                            <span class="material-symbols-outlined text-amber-600 text-[18px] shrink-0 mt-0.5">confirmation_number</span>
                            <div class="flex-1">
                                <p class="font-bold text-gray-900">Mã giảm giá mới</p>
                                <p class="text-gray-600 text-[11px] mt-0.5">Mã SAN10K (giảm 10.000₫) và mã Shop giảm đến 10% đã sẵn sàng.</p>
                            </div>
                        </div>
                    </div>
                    <div class="pt-3 border-t border-gray-100 mt-3 text-center">
                        <a href="<c:out value='${profileUrl}'/>" class="text-xs text-[#00652c] font-semibold hover:underline">Xem trong tài khoản</a>
                    </div>
                </div>
            </div>

            <!-- Nút Giỏ Hàng (BÊN TRÁI PROFILE) -->
            <a href="<c:out value='${cartUrl}'/>" class="flex items-center gap-2.5 py-1.5 px-3.5 rounded-full border border-[#00652c]/30 bg-[#00652c]/5 hover:bg-[#00652c]/10 transition-colors" data-path="cart" title="Giỏ hàng">
                <div class="relative flex items-center justify-center">
                    <span class="material-symbols-outlined text-[#00652c] text-[22px]">shopping_cart</span>
                    <span class="absolute -top-2 -right-2.5 min-w-[18px] h-4 px-1 bg-red-600 text-white rounded-full font-bold text-[10px] flex items-center justify-center border border-white shadow-xs" id="nav-cart-badge">
                        <c:out value="${cartSize gt 99 ? '99+' : cartSize}"/>
                    </span>
                </div>
            </a>

            <!-- Nút Hồ Sơ / Đăng Nhập -->
            <div class="relative group">
                <c:choose>
                    <c:when test="${not empty currentUser}">
                        <div class="flex items-center gap-2 py-1.5 px-3 rounded-full bg-[#f4f7f4] hover:bg-gray-100 transition-colors cursor-pointer border border-gray-200">
                            <c:choose>
                                <c:when test="${not empty currentUser.avatarUrl}">
                                    <img alt="Profile" class="w-7 h-7 rounded-full object-cover" src="<c:out value='${currentUser.avatarUrl}'/>">
                                </c:when>
                                <c:otherwise>
                                    <span class="w-7 h-7 rounded-full bg-[#00652c]/20 text-[#00652c] flex items-center justify-center text-xs font-bold">
                                        <c:out value="${not empty currentUser.fullName ? currentUser.fullName.substring(0, 1) : 'U'}"/>
                                    </span>
                                </c:otherwise>
                            </c:choose>
                            <span class="font-medium text-sm text-gray-800 max-w-[130px] truncate">
                                <c:out value="${not empty currentUser.fullName ? currentUser.fullName : currentUser.email}"/>
                            </span>
                            <span class="material-symbols-outlined text-gray-500 text-[18px]">expand_more</span>
                        </div>
                        <!-- Dropdown Menu -->
                        <div class="absolute right-0 mt-1 w-48 bg-white rounded-xl shadow-xl border border-gray-100 py-2 hidden group-hover:block z-50">
                            <c:if test="${currentUser.role eq 'SHOP_OWNER'}">
                                <a href="${pageContext.request.contextPath}/shop/products" class="flex items-center gap-2 px-4 py-2 text-xs font-bold text-[#00652c] bg-emerald-50/50 hover:bg-emerald-50 transition-colors">
                                    <span class="material-symbols-outlined text-[18px]">storefront</span> Kênh Người Bán
                                </a>
                                <div class="h-px bg-gray-100 my-1"></div>
                            </c:if>
                            <c:if test="${currentUser.role eq 'DRIVER'}">
                                <a href="${pageContext.request.contextPath}/shipper/deliveries" class="flex items-center gap-2 px-4 py-2 text-xs font-bold text-amber-700 bg-amber-50/50 hover:bg-amber-50 transition-colors">
                                    <span class="material-symbols-outlined text-[18px]">local_shipping</span> Cổng Giao Vận
                                </a>
                                <div class="h-px bg-gray-100 my-1"></div>
                            </c:if>
                            <a href="<c:out value='${profileUrl}'/>" class="flex items-center gap-2 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 transition-colors">
                                <span class="material-symbols-outlined text-[18px]">person</span> Hồ sơ cá nhân
                            </a>
                            <a href="${pageContext.request.contextPath}/payment/history" class="flex items-center gap-2 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 transition-colors">
                                <span class="material-symbols-outlined text-[18px]">receipt_long</span> Lịch sử thanh toán
                            </a>
                            <a href="<c:out value='${changePasswordUrl}'/>" class="flex items-center gap-2 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 transition-colors">
                                <span class="material-symbols-outlined text-[18px]">key</span> Đổi mật khẩu
                            </a>
                            <div class="h-px bg-gray-100 my-1"></div>
                            <a href="<c:out value='${logoutUrl}'/>" class="flex items-center gap-2 px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition-colors">
                                <span class="material-symbols-outlined text-[18px]">logout</span> Đăng xuất
                            </a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="flex items-center gap-2">
                            <a href="<c:out value='${loginUrl}'/>" class="flex items-center gap-1.5 py-1.5 px-3.5 rounded-full bg-[#00652c] text-white text-sm font-semibold hover:bg-[#005323] transition-colors shadow-xs">
                                <span class="material-symbols-outlined text-[18px]">login</span> Đăng nhập
                            </a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <!-- Category Navigation Bar (Tông sáng đồng bộ Cart) -->
    <div class="bg-white border-t border-gray-100 shadow-[0_1px_4px_rgba(0,0,0,0.02)]">
        <div class="max-w-[1360px] mx-auto px-4 lg:px-8 h-11 flex items-center justify-between">
            <nav class="flex items-center gap-6 text-sm">
                <a class="text-gray-600 hover:text-[#00652c] transition-colors font-medium" href="<c:out value='${homeUrl}'/>">Trang Chủ</a>
                <a class="text-gray-600 hover:text-[#00652c] transition-colors font-medium" href="<c:out value='${productsUrl}'/>">Cửa Hàng</a>
                <a class="text-gray-600 hover:text-[#00652c] transition-colors font-medium" href="<c:out value='${productsUrl}'/>?category=trai-cay-noi-dia">Trái Cây Nội Địa</a>
                <a class="text-gray-600 hover:text-[#00652c] transition-colors font-medium" href="<c:out value='${productsUrl}'/>?category=trai-cay-nhap-khau">Trái Cây Nhập Khẩu</a>
                <a class="text-gray-600 hover:text-[#00652c] transition-colors font-medium" href="<c:out value='${productsUrl}'/>">Hộp Quà &amp; Combo</a>
                <a class="text-gray-600 hover:text-[#00652c] transition-colors font-medium" href="<c:out value='${homeUrl}'/>#about">Về Nông Trại</a>
                <a class="text-gray-600 hover:text-[#00652c] transition-colors font-medium" href="<c:out value='${homeUrl}'/>#contact">Liên Hệ</a>
            </nav>
            <div class="hidden sm:flex items-center">
                <span class="flex items-center gap-1.5 px-3 py-1 bg-amber-100 text-amber-900 rounded-full text-xs font-semibold">
                    <span class="material-symbols-outlined text-[14px] text-amber-700">bolt</span>
                    <span>Nông sản tươi sạch: <strong>Giao nhanh trong ngày</strong></span>
                </span>
            </div>
        </div>
    </div>
</header>

<!-- Floating Toast Container -->
<div id="global-toast-container" class="fixed top-24 right-5 z-[100] flex flex-col gap-2.5 max-w-sm pointer-events-none"></div>

<!-- ==================== HEADER & NOTIFICATION SCRIPT ==================== -->
<script>
    window.contextPath = '${pageContext.request.contextPath}';

    function toggleHeaderNotification(e) {
        if (e) e.stopPropagation();
        const popover = document.getElementById('header-noti-popover');
        if (popover) {
            popover.classList.toggle('hidden');
        }
    }

    function clearAllNotifications(e) {
        if (e) e.stopPropagation();
        const badge = document.getElementById('header-noti-badge');
        if (badge) badge.classList.add('hidden');
        localStorage.setItem('gocvuon_noti_read', 'true');
    }

    function addHeaderNotification(title, message) {
        const list = document.getElementById('header-noti-list');
        const badge = document.getElementById('header-noti-badge');
        if (badge) {
            badge.classList.remove('hidden');
            let count = parseInt(badge.textContent.trim()) || 0;
            badge.textContent = count + 1;
        }
        if (list) {
            const item = document.createElement('div');
            item.className = 'flex items-start gap-3 p-2.5 rounded-xl bg-emerald-50/90 border border-emerald-200 text-xs text-gray-800 shadow-2xs';
            item.innerHTML = '<span class="material-symbols-outlined text-emerald-600 text-[18px] shrink-0 mt-0.5">check_circle</span>'
                + '<div class="flex-1">'
                + '<p class="font-bold text-gray-900">' + title + '</p>'
                + '<p class="text-gray-600 text-[11px] mt-0.5">' + message + '</p>'
                + '</div>';
            list.insertBefore(item, list.firstChild);
        }
    }

    window.showToast = function(message, type = 'success') {
        const container = document.getElementById('global-toast-container');
        if (!container) return;
        const toast = document.createElement('div');
        const isSuccess = type === 'success';
        toast.className = 'pointer-events-auto flex items-center justify-between gap-3 p-4 rounded-2xl shadow-xl border backdrop-blur-md transition-all duration-300 transform translate-y-2 opacity-0 '
            + (isSuccess ? 'bg-emerald-50/95 border-emerald-200 text-emerald-900' : 'bg-red-50/95 border-red-200 text-red-900');
        toast.innerHTML = '<div class="flex items-center gap-2.5">'
            + '<span class="material-symbols-outlined text-[22px] ' + (isSuccess ? 'text-emerald-600' : 'text-red-600') + '">' + (isSuccess ? 'check_circle' : 'error') + '</span>'
            + '<span class="text-sm font-semibold">' + message + '</span>'
            + '</div>'
            + '<a href="' + window.contextPath + '/cart" class="text-xs font-bold underline shrink-0 hover:opacity-80">Xem giỏ</a>';
        container.appendChild(toast);
        requestAnimationFrame(() => {
            toast.classList.remove('translate-y-2', 'opacity-0');
        });
        setTimeout(() => {
            toast.classList.add('opacity-0', 'translate-x-4');
            setTimeout(() => toast.remove(), 300);
        }, 4000);
    };

    // Close notifications popover on click outside or escape
    document.addEventListener('click', function(e) {
        const container = document.getElementById('header-noti-container');
        const popover = document.getElementById('header-noti-popover');
        if (container && popover && !container.contains(e.target)) {
            popover.classList.add('hidden');
        }
    });

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            const popover = document.getElementById('header-noti-popover');
            if (popover) popover.classList.add('hidden');
        }
    });

    // Intercept Add to Cart form submissions for smooth instant notification & badge update
    document.addEventListener('submit', function(e) {
        const form = e.target;
        if (form && form.action && form.action.includes('/cart/add')) {
            const submitter = e.submitter;
            if (submitter && submitter.value === 'buyNow') {
                return; // allow normal Buy Now submission to /checkout
            }
            e.preventDefault();
            const formData = new FormData(form);
            const params = new URLSearchParams();
            for (const [key, value] of formData.entries()) {
                params.append(key, value);
            }
            params.append('ajax', 'true');

            const submitBtn = form.querySelector('button[type="submit"]');
            if (submitBtn) submitBtn.disabled = true;

            fetch(form.action, {
                method: 'POST',
                body: params,
                headers: {
                    'X-Requested-With': 'XMLHttpRequest',
                    'Accept': 'application/json'
                }
            })
            .then(res => {
                if (res.status === 401) {
                    return res.json().then(data => {
                        window.location.href = data.redirect || (window.contextPath + '/login');
                    });
                }
                return res.json();
            })
            .then(data => {
                if (submitBtn) submitBtn.disabled = false;
                if (!data) return;
                if (data.redirect) {
                    window.location.href = data.redirect;
                    return;
                }
                if (data.success) {
                    if (data.cartSize !== undefined) {
                        const badges = document.querySelectorAll('#nav-cart-badge, #cartBadge');
                        badges.forEach(b => b.textContent = data.cartSize > 99 ? '99+' : data.cartSize);
                        const notiCartCount = document.getElementById('noti-cart-count');
                        if (notiCartCount) notiCartCount.textContent = data.cartSize;
                    }
                    window.showToast(data.message || 'Đã thêm sản phẩm vào giỏ hàng thành công!', 'success');
                    addHeaderNotification('Thêm giỏ hàng', data.message || 'Đã thêm sản phẩm vào giỏ hàng!');
                } else {
                    window.showToast(data.message || 'Không thể thêm vào giỏ hàng!', 'error');
                }
            })
            .catch(err => {
                if (submitBtn) submitBtn.disabled = false;
                form.submit(); // fallback
            });
        }
    });
</script>
