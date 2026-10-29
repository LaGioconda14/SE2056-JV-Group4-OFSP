<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
    SIDEBAR DÙNG CHUNG CHO KÊNH NGƯỜI BÁN (SELLER DASHBOARD)
    Cách dùng (đặt ngay sau <body>):
        <jsp:include page="/views/shop/layout/sidebar.jsp">
            <jsp:param name="active" value="products" />
        </jsp:include>

    Giá trị "active" hợp lệ:
        overview | profile | products | add | inventory | orders | shipping | promotions | vouchers | reviews | finance | settings

    Dữ liệu lấy từ:
        - sessionScope.shopName / sessionScope.shopObj  (set lúc đăng nhập, cập nhật khi sửa Profile Shop)
        - request attribute sidebarLowStockCount        (set bởi filter.ShopLayoutFilter cho mọi trang /shop/*)
--%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="sbShopName" value="${not empty sessionScope.shopName ? sessionScope.shopName : (not empty sessionScope.shopObj.shopName ? sessionScope.shopObj.shopName : 'Gian hàng của tôi')}" />
<c:set var="sbLowStock" value="${not empty requestScope.sidebarLowStockCount ? requestScope.sidebarLowStockCount : 0}" />

<div class="shop-sidebar-overlay" id="shopSidebarOverlay"></div>

<aside class="shop-sidebar" id="shopSidebar">
    <div>
        <!-- Shop Brand Header -->
        <div class="shop-sidebar-brand">
            <div class="flex items-center gap-3 min-w-0">
                <div class="w-9 h-9 rounded-full bg-[#166534] flex items-center justify-center text-white text-lg shrink-0 shadow-sm">
                    <i class="fa-solid fa-leaf text-white text-sm"></i>
                </div>
                <div class="min-w-0">
                    <span class="font-extrabold text-sm text-gray-900 leading-tight block truncate" style="max-width: 120px;" title="<c:out value='${sbShopName}'/>">
                        <c:out value="${sbShopName}" />
                    </span>
                    <span class="text-[10px] font-bold text-[#15803d] tracking-wider uppercase block">Kênh Người Bán</span>
                </div>
            </div>
            <span class="px-2 py-0.5 rounded-md bg-[#f1f5f9] text-[#64748b] text-[10px] font-black uppercase tracking-wider">SHOP</span>
        </div>

        <!-- Sidebar Navigation Groups -->
        <nav class="space-y-1 mt-3">
            <!-- Group: TỔNG QUAN -->
            <div class="shop-sidebar-group-title">TỔNG QUAN</div>
            <a href="${ctx}/shop/dashboard" class="shop-sidebar-link ${param.active == 'overview' ? 'active' : ''}">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-table-cells-large text-slate-400 text-sm w-4 text-center"></i>
                    <span>Tổng quan Shop</span>
                </span>
            </a>
            <a href="${ctx}/shop/profile" class="shop-sidebar-link ${param.active == 'profile' ? 'active' : ''}">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-store text-slate-400 text-sm w-4 text-center"></i>
                    <span>Profile Shop</span>
                </span>
            </a>

            <!-- Group: SẢN PHẨM & KHO -->
            <div class="shop-sidebar-group-title">SẢN PHẨM & KHO</div>
            <a href="${ctx}/shop/products" class="shop-sidebar-link ${param.active == 'products' ? 'active' : ''}">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-apple-whole text-slate-400 text-sm w-4 text-center"></i>
                    <span>Tất cả sản phẩm</span>
                </span>
            </a>
            <a href="${ctx}/shop/product/add" class="shop-sidebar-link ${param.active == 'add' ? 'active' : ''}">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-circle-plus text-slate-400 text-sm w-4 text-center"></i>
                    <span>Thêm mới nông sản</span>
                </span>
            </a>
            <a href="${ctx}/shop/inventory" class="shop-sidebar-link ${param.active == 'inventory' ? 'active' : ''}">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-boxes-stacked text-slate-400 text-sm w-4 text-center"></i>
                    <span>Kho & Cảnh báo tồn</span>
                </span>
                <span class="badge-counter-red">${sbLowStock}</span>
            </a>

            <div class="text-[10px] uppercase tracking-wider text-slate-400 px-3 pt-2 font-extrabold">ĐƠN HÀNG & GIAO VẬN</div>
            <a href="${pageContext.request.contextPath}/shop/orders" 
               class="flex items-center justify-between px-3 py-2.5 rounded-xl ${curMenu eq 'orders' ? 'bg-emerald-50 text-emerald-800 font-bold border border-emerald-200/60 shadow-2xs' : 'text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold'} text-xs transition-all">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-receipt text-slate-400 text-sm w-4 text-center"></i>
                    <span>Đơn hàng con</span>
                </span>
                <%-- TODO: thay số 8 bằng số đơn chờ xử lý thật khi có chức năng đơn hàng của shop --%>
                <span class="badge-counter-orange">8</span>
            </a>
            <a href="${ctx}/shop/shipping" class="shop-sidebar-link ${param.active == 'shipping' ? 'active' : ''}">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-truck-fast text-slate-400 text-sm w-4 text-center"></i>
                    <span>Đóng gói & Vận đơn</span>
                </span>
            </a>
            <a href="${pageContext.request.contextPath}/shop/shippers" 
               class="flex items-center justify-between px-3 py-2.5 rounded-xl ${curMenu eq 'shippers' ? 'bg-emerald-50 text-emerald-800 font-bold border border-emerald-200/60 shadow-2xs' : 'text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold'} text-xs transition-all">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-truck-fast ${curMenu eq 'shippers' ? 'text-emerald-600' : 'text-slate-400'} text-sm w-4 text-center"></i>
                    <span>Nhân viên giao hàng</span>
                </span>
                <span class="px-2 py-0.5 bg-emerald-100 text-emerald-800 text-[10px] font-bold rounded-full">Shop</span>
            </a>

            <!-- Group: TIẾP THỊ & KHÁCH HÀNG -->
            <div class="shop-sidebar-group-title">TIẾP THỊ & KHÁCH HÀNG</div>
            <a href="${ctx}/shop/promotions" class="shop-sidebar-link ${param.active == 'promotions' ? 'active' : ''}">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-bolt text-slate-400 text-sm w-4 text-center"></i>
                    <span>Khuyến mãi (Promotion)</span>
                </span>
            </a>
            <a href="${ctx}/shop/vouchers" class="shop-sidebar-link ${param.active == 'vouchers' ? 'active' : ''}">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-ticket text-slate-400 text-sm w-4 text-center"></i>
                    <span>Voucher Shop</span>
                </span>
            </a>
            <a href="${ctx}/shop/reviews" class="shop-sidebar-link ${param.active == 'reviews' ? 'active' : ''}">
                <span class="flex items-center gap-3">
                    <i class="fa-regular fa-star text-slate-400 text-sm w-4 text-center"></i>
                    <span>Đánh giá từ khách</span>
                </span>
            </a>


            <div class="text-[10px] uppercase tracking-wider text-slate-400 px-3 pt-2 font-extrabold">HỆ THỐNG</div>
            <a href="${ctx}/shop/finance" class="shop-sidebar-link ${param.active == 'finance' ? 'active' : ''}">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-wallet text-slate-400 text-sm w-4 text-center"></i>
                    <span>Doanh thu & Rút tiền</span>
                </span>
            </a>
            <a href="${ctx}/shop/settings" class="shop-sidebar-link ${param.active == 'settings' ? 'active' : ''}">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-sliders text-slate-400 text-sm w-4 text-center"></i>
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
