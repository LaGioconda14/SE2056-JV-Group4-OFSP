<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="sbShopName" value="${not empty sessionScope.shopName ? sessionScope.shopName : (not empty sessionScope.shopObj.shopName ? sessionScope.shopObj.shopName : 'Gian hàng của tôi')}" />
<c:set var="sbLowStock" value="${not empty requestScope.sidebarLowStockCount ? requestScope.sidebarLowStockCount : 0}" />
<c:set var="sbPendingOrders" value="${not empty requestScope.sidebarPendingOrdersCount ? requestScope.sidebarPendingOrdersCount : (not empty sessionScope.sidebarPendingOrdersCount ? sessionScope.sidebarPendingOrdersCount : 0)}" />

<div class="shop-sidebar-overlay" id="shopSidebarOverlay"></div>

<aside class="shop-sidebar" id="shopSidebar">
    <div>
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

        <nav class="space-y-1 mt-3">
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
            <a href="${ctx}/shop/waste" class="shop-sidebar-link ${param.active == 'waste' ? 'active' : ''}">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-trash-can text-slate-400 text-sm w-4 text-center"></i>
                    <span>Hao hụt & Hư hỏng</span>
                </span>
                <span class="px-2 py-0.5 rounded-md bg-rose-50 text-rose-600 text-[10px] font-bold">QC</span>
            </a>

            <div class="text-[10px] uppercase tracking-wider text-slate-400 px-3 pt-2 font-extrabold">ĐƠN HÀNG & GIAO VẬN</div>
            <a href="${pageContext.request.contextPath}/shop/orders" 
               class="shop-sidebar-link ${param.active == 'orders' || curMenu eq 'orders' ? 'active' : ''}">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-receipt text-slate-400 text-sm w-4 text-center"></i>
                    <span>Đơn hàng con</span>
                </span>
                <span class="badge-counter-orange">${sbPendingOrders}</span>
            </a>
            <a href="${pageContext.request.contextPath}/shop/shippers" 
               class="shop-sidebar-link ${param.active == 'shippers' || curMenu eq 'shippers' ? 'active' : ''}">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-truck-fast text-slate-400 text-sm w-4 text-center"></i>
                    <span>Nhân viên giao hàng</span>
                </span>
                <span class="px-2 py-0.5 bg-emerald-100 text-emerald-800 text-[10px] font-bold rounded-full">Shop</span>
            </a>

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
        </nav>
    </div>
</aside>
