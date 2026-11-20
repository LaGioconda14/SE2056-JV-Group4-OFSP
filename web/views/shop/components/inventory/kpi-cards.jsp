<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- Header Tiêu đề & Nút thao tác -->
<div class="flex flex-col xl:flex-row xl:items-center justify-between gap-4">
    <div>
        <h1 class="text-2xl font-black text-slate-900 tracking-tight">Quản lý Kho Hàng & Lô Nông Sản</h1>
        <p class="text-xs text-slate-500 font-medium mt-1">Theo dõi tồn kho theo thời gian thực, hạn sử dụng và lịch sử biến động lô hàng.</p>
    </div>
    <div class="flex items-center flex-wrap gap-2.5">
        <a href="${pageContext.request.contextPath}/shop/waste" class="px-4 py-2.5 bg-white border border-slate-200 text-slate-700 hover:bg-rose-50 hover:text-rose-700 rounded-xl text-xs font-bold flex items-center gap-2 shadow-sm transition-all text-decoration-none">
            <i class="fa-solid fa-clipboard-list text-rose-500"></i>Sổ Hao Hụt & Tiêu Hủy
        </a>
        <a href="${pageContext.request.contextPath}/shop/inventory/batches?action=adjust" class="px-4 py-2.5 bg-white border border-slate-200 text-slate-700 hover:bg-amber-50 hover:text-amber-700 rounded-xl text-xs font-bold flex items-center gap-2 shadow-sm transition-all text-decoration-none">
            <i class="fa-solid fa-minus text-amber-500"></i>Trừ hàng hỏng / Dập
        </a>
        <a href="${pageContext.request.contextPath}/shop/inventory/batches?action=restock" class="px-4 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold flex items-center gap-2 shadow-sm transition-all text-decoration-none">
            <i class="fa-solid fa-plus"></i>Nhập Kho Lô Mới
        </a>
    </div>
</div>

<!-- 4 Thẻ Thống Kê Tổng Quan -->
<section class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
    <div class="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-start justify-between">
        <div>
            <p class="text-[10px] uppercase tracking-wider text-slate-500 font-bold">Tổng sản lượng tồn kho</p>
            <p class="text-2xl font-black text-slate-900 mt-1">${not empty totalStock ? totalStock : '0'} <span class="text-xs font-semibold text-slate-400">đơn vị</span></p>
            <p class="text-[10px] text-emerald-600 font-semibold mt-1"><i class="fa-solid fa-arrow-trend-up mr-1"></i>Tồn kho thời gian thực</p>
        </div>
        <span class="w-11 h-11 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center"><i class="fa-solid fa-boxes-stacked"></i></span>
    </div>

    <div class="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-start justify-between">
        <div>
            <p class="text-[10px] uppercase tracking-wider text-slate-500 font-bold">Cảnh báo sắp hết hàng</p>
            <p class="text-2xl font-black text-slate-900 mt-1">${not empty lowStockCount ? lowStockCount : '0'} <span class="text-xs font-semibold text-slate-400">sản phẩm</span></p>
            <p class="text-[10px] text-rose-500 font-semibold mt-1">Cần nhập kho gấp</p>
        </div>
        <span class="w-11 h-11 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center"><i class="fa-solid fa-triangle-exclamation"></i></span>
    </div>

    <div class="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-start justify-between">
        <div>
            <p class="text-[10px] uppercase tracking-wider text-slate-500 font-bold">Tổng số lô hàng</p>
            <p class="text-2xl font-black text-slate-900 mt-1">${not empty totalBatches ? totalBatches : '0'} <span class="text-xs font-semibold text-slate-400">lô</span></p>
            <p class="text-[10px] text-amber-600 font-semibold mt-1">Đang lưu trữ trong kho</p>
        </div>
        <span class="w-11 h-11 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center"><i class="fa-solid fa-warehouse"></i></span>
    </div>

    <div class="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-start justify-between">
        <div>
            <p class="text-[10px] uppercase tracking-wider text-slate-500 font-bold">Lô cận Date / Quá hạn</p>
            <p class="text-2xl font-black text-amber-600 mt-1">${not empty nearExpiryCount ? nearExpiryCount : '0'} <span class="text-xs font-semibold text-slate-400">lô</span></p>
            <p class="text-[10px] text-amber-600 font-semibold mt-1">Ưu tiên xuất kho / Hủy</p>
        </div>
        <span class="w-11 h-11 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center"><i class="fa-solid fa-hourglass-half"></i></span>
    </div>
</section>
