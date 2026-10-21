<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="curMenu" value="${not empty param.activeMenu ? param.activeMenu : activeMenu}" />

<aside class="w-64 shrink-0 bg-white border-r border-slate-200 h-screen sticky top-0 flex flex-col justify-between z-30 overflow-y-auto">
    <div>
        <div class="p-5 border-b border-slate-100 flex items-center justify-between">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-full overflow-hidden shrink-0 border-2 border-emerald-500 shadow-xs">
                    <c:choose>
                        <c:when test="${not empty sessionScope.shopLogo}">
                            <img src="${sessionScope.shopLogo}" alt="Shop Avatar" class="w-full h-full object-cover">
                        </c:when>
                        <c:when test="${not empty sessionScope.shop.logoUrl}">
                            <img src="${sessionScope.shop.logoUrl}" alt="Shop Avatar" class="w-full h-full object-cover">
                        </c:when>
                        <c:when test="${not empty shopLogo}">
                            <img src="${shopLogo}" alt="Shop Avatar" class="w-full h-full object-cover">
                        </c:when>
                        <c:otherwise>
                            <img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop" alt="Default Avatar" class="w-full h-full object-cover">
                        </c:otherwise>
                    </c:choose>
                </div>
                <div>
                    <h4 class="text-xs font-extrabold text-slate-900 leading-tight">
                        <c:out value="${not empty sessionScope.shopName ? sessionScope.shopName : (not empty sessionScope.shop.shopName ? sessionScope.shop.shopName : 'Mộc Châu Farm')}"/>
                    </h4>
                    <p class="text-[10px] font-bold text-emerald-700 tracking-wider mt-0.5">SELLER CENTER</p>
                </div>
            </div>
            <div>
                <span class="px-2 py-0.5 text-[10px] font-black text-emerald-800 bg-emerald-100 rounded-md tracking-wider">
                    PRO
                </span>
            </div>
        </div>

        <nav class="space-y-1.5 px-3 mt-4">
            <div class="text-[10px] uppercase tracking-wider text-slate-400 px-3 pt-2 font-extrabold">SẢN PHẨM & KHO</div>
            <a href="${pageContext.request.contextPath}/shop/products" 
               class="flex items-center justify-between px-3 py-2.5 rounded-xl ${curMenu eq 'products' ? 'bg-emerald-50 text-emerald-800 font-bold border border-emerald-200/60 shadow-2xs' : 'text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold'} text-xs transition-all">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-seedling ${curMenu eq 'products' ? 'text-emerald-600' : 'text-slate-400'} text-sm w-4 text-center"></i>
                    <span>Tất cả sản phẩm</span>
                </span>
            </a>
            <a href="${pageContext.request.contextPath}/shop/product/add" 
               class="flex items-center justify-between px-3 py-2.5 rounded-xl ${curMenu eq 'add-product' ? 'bg-emerald-50 text-emerald-800 font-bold border border-emerald-200/60 shadow-2xs' : 'text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold'} text-xs transition-all">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-circle-plus ${curMenu eq 'add-product' ? 'text-emerald-600' : 'text-slate-400'} text-sm w-4 text-center"></i>
                    <span>Thêm mới nông sản</span>
                </span>
            </a>
            <a href="${pageContext.request.contextPath}/shop/inventory" 
               class="flex items-center justify-between px-3 py-2.5 rounded-xl ${curMenu eq 'inventory' ? 'bg-emerald-50 text-emerald-800 font-bold border border-emerald-200/60 shadow-2xs' : 'text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold'} text-xs transition-all">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-warehouse ${curMenu eq 'inventory' ? 'text-emerald-600' : 'text-slate-400'} text-sm w-4 text-center"></i>
                    <span>Kho & Cảnh báo tồn</span>
                </span>
                <span class="px-2 py-0.5 bg-rose-100 text-rose-700 text-[10px] font-bold rounded-full">${not empty lowStockCount ? lowStockCount : 3}</span>
            </a>

            <div class="text-[10px] uppercase tracking-wider text-slate-400 px-3 pt-2 font-extrabold">ĐƠN HÀNG & GIAO VẬN</div>
            <a href="${pageContext.request.contextPath}/shop/orders" 
               class="flex items-center justify-between px-3 py-2.5 rounded-xl ${curMenu eq 'orders' ? 'bg-emerald-50 text-emerald-800 font-bold border border-emerald-200/60 shadow-2xs' : 'text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold'} text-xs transition-all">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-receipt ${curMenu eq 'orders' ? 'text-emerald-600' : 'text-slate-400'} text-sm w-4 text-center"></i>
                    <span>Đơn hàng</span>
                </span>
                <span class="px-2 py-0.5 bg-amber-100 text-amber-800 text-[10px] font-bold rounded-full">${not empty countAll ? countAll : (not empty shopSubOrdersCount ? shopSubOrdersCount : (not empty sessionScope.shopSubOrdersCount ? sessionScope.shopSubOrdersCount : 0))}</span>
            </a>
            <a href="${pageContext.request.contextPath}/shop/shippers" 
               class="flex items-center justify-between px-3 py-2.5 rounded-xl ${curMenu eq 'shippers' ? 'bg-emerald-50 text-emerald-800 font-bold border border-emerald-200/60 shadow-2xs' : 'text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold'} text-xs transition-all">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-truck-fast ${curMenu eq 'shippers' ? 'text-emerald-600' : 'text-slate-400'} text-sm w-4 text-center"></i>
                    <span>Nhân viên giao hàng</span>
                </span>
                <span class="px-2 py-0.5 bg-emerald-100 text-emerald-800 text-[10px] font-bold rounded-full">Shop</span>
            </a>

            <div class="text-[10px] uppercase tracking-wider text-slate-400 px-3 pt-2 font-extrabold">TIẾP THỊ & KHÁCH</div>
            <a href="${pageContext.request.contextPath}/shop/coupons" 
               class="flex items-center justify-between px-3 py-2.5 rounded-xl ${curMenu eq 'coupons' ? 'bg-emerald-50 text-emerald-800 font-bold border border-emerald-200/60 shadow-2xs' : 'text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold'} text-xs transition-all">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-tags ${curMenu eq 'coupons' ? 'text-emerald-600' : 'text-slate-400'} text-sm w-4 text-center"></i>
                    <span>Mã giảm giá Shop</span>
                </span>
            </a>
            <a href="${pageContext.request.contextPath}/shop/reviews" 
               class="flex items-center justify-between px-3 py-2.5 rounded-xl ${curMenu eq 'reviews' ? 'bg-emerald-50 text-emerald-800 font-bold border border-emerald-200/60 shadow-2xs' : 'text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold'} text-xs transition-all">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-star-half-stroke ${curMenu eq 'reviews' ? 'text-emerald-600' : 'text-slate-400'} text-sm w-4 text-center"></i>
                    <span>Đánh giá từ khách</span>
                </span>
            </a>

            <div class="text-[10px] uppercase tracking-wider text-slate-400 px-3 pt-2 font-extrabold">HỆ THỐNG</div>
            <a href="${pageContext.request.contextPath}/shop/finance" 
               class="flex items-center justify-between px-3 py-2.5 rounded-xl ${curMenu eq 'finance' ? 'bg-emerald-50 text-emerald-800 font-bold border border-emerald-200/60 shadow-2xs' : 'text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold'} text-xs transition-all">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-wallet ${curMenu eq 'finance' ? 'text-emerald-600' : 'text-slate-400'} text-sm w-4 text-center"></i>
                    <span>Doanh thu & Rút tiền</span>
                </span>
            </a>
            <a href="${pageContext.request.contextPath}/shop/settings" 
               class="flex items-center justify-between px-3 py-2.5 rounded-xl ${curMenu eq 'settings' ? 'bg-emerald-50 text-emerald-800 font-bold border border-emerald-200/60 shadow-2xs' : 'text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold'} text-xs transition-all">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-sliders ${curMenu eq 'settings' ? 'text-emerald-600' : 'text-slate-400'} text-sm w-4 text-center"></i>
                    <span>Cài đặt Shop</span>
                </span>
            </a>
        </nav>
    </div>

    <div class="p-3 border-t border-slate-200 space-y-1">
        <a href="${pageContext.request.contextPath}/store?id=${sessionScope.shopId != null ? sessionScope.shopId : (sessionScope.shop != null ? sessionScope.shop.shopId : 1)}" 
           target="_blank" 
           class="flex items-center gap-3 px-3 py-2 rounded-xl text-slate-600 hover:text-emerald-700 font-semibold text-xs transition-all">
            <i class="fa-solid fa-store text-xs w-4 text-center"></i>
            <span>Xem gian hàng của tôi</span>
        </a>
        <a href="${pageContext.request.contextPath}/home" 
           class="flex items-center gap-3 px-3 py-2 rounded-xl text-slate-600 hover:text-emerald-700 font-semibold text-xs transition-all">
            <i class="fa-solid fa-bag-shopping text-xs w-4 text-center"></i>
            <span>Về trang mua sắm</span>
        </a>
        <a href="${pageContext.request.contextPath}/logout" 
           class="flex items-center gap-3 px-3 py-2 rounded-xl text-rose-600 hover:bg-rose-50 hover:text-rose-700 font-semibold text-xs transition-all">
            <i class="fa-solid fa-power-off text-xs w-4 text-center"></i>
            <span>Đăng xuất</span>
        </a>
    </div>
</aside>
