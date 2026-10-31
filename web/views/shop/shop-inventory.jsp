<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quản Lý Kho Hàng & Cảnh Báo Độ Tươi - FreshFruit Kênh Người Bán</title>
    <jsp:include page="/views/shop/layout/head.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-inventory.css">
</head>
<body class="bg-[#f8fafc] text-[#0f172a]">

    <jsp:include page="/views/shop/layout/sidebar.jsp">
        <jsp:param name="active" value="inventory" />
    </jsp:include>
    <jsp:include page="/views/shop/layout/header.jsp" />

    <main class="shop-main-wrapper">
        <div class="shop-content-container">

            <div class="flex flex-col gap-2 mb-6">
                <nav class="flex items-center gap-2 text-xs text-slate-500 font-medium">
                    <span>Kênh Người Bán</span>
                    <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                    <span>Sản phẩm & Kho</span>
                    <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                    <span class="text-emerald-700 font-semibold">Tồn kho & Độ tươi nông sản</span>
                </nav>

                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mt-1">
                    <div>
                        <h1 class="text-2xl font-black text-slate-900 tracking-tight">Quản Lý Tồn Kho Nông Sản Tươi</h1>
                        <p class="text-xs text-slate-500 mt-0.5">Giám sát theo thời gian thực (IoT Sensor) mức tồn, hạn sử dụng và kích hoạt xả hàng chống hao hụt.</p>
                    </div>

                    <div class="flex items-center flex-wrap gap-2.5">
                        <a href="${pageContext.request.contextPath}/shop/inventory?action=export" class="px-3.5 py-2 rounded-xl bg-white border border-slate-300 hover:bg-slate-50 text-slate-700 text-xs font-bold transition flex items-center gap-2 shadow-2xs">
                            <i class="fa-solid fa-file-excel text-emerald-700 text-sm"></i>
                            <span>Xuất Báo Cáo Tồn</span>
                        </a>

                        <button type="button" onclick="openRestockModal()" class="px-4 py-2 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white text-xs font-extrabold transition flex items-center gap-2 shadow-sm">
                            <i class="fa-solid fa-plus text-xs"></i>
                            <span>Nhập Kho Lô Mới</span>
                        </button>
                    </div>
                </div>
            </div>

            <c:if test="${not empty sessionScope.flashSuccess}">
                <div id="flashMsg" class="mb-5 bg-emerald-50 border border-emerald-200 text-emerald-800 px-4 py-3 rounded-xl flex items-center justify-between shadow-2xs">
                    <div class="flex items-center gap-3">
                        <i class="fa-solid fa-circle-check text-emerald-600 text-base"></i>
                        <span class="text-xs font-bold">${sessionScope.flashSuccess}</span>
                    </div>
                    <button type="button" onclick="this.parentElement.remove()" class="text-emerald-600 hover:text-emerald-900">
                        <i class="fa-solid fa-xmark"></i>
                    </button>
                </div>
                <c:remove var="flashSuccess" scope="session"/>
            </c:if>

            <c:if test="${not empty sessionScope.flashError}">
                <div id="flashMsg" class="mb-5 bg-rose-50 border border-rose-200 text-rose-800 px-4 py-3 rounded-xl flex items-center justify-between shadow-2xs">
                    <div class="flex items-center gap-3">
                        <i class="fa-solid fa-circle-exclamation text-rose-600 text-base"></i>
                        <span class="text-xs font-bold">${sessionScope.flashError}</span>
                    </div>
                    <button type="button" onclick="this.parentElement.remove()" class="text-rose-600 hover:text-rose-900">
                        <i class="fa-solid fa-xmark"></i>
                    </button>
                </div>
                <c:remove var="flashError" scope="session"/>
            </c:if>

            <div class="bg-white p-2 rounded-2xl border border-slate-200/80 shadow-xs flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                <div class="flex items-center gap-1.5 overflow-x-auto hide-scrollbar py-0.5">
                    <a href="${pageContext.request.contextPath}/shop/inventory?viewTab=waste"
                       class="inv-tab-btn ${viewTab == 'waste' ? 'active' : ''}">
                        <i class="fa-solid fa-dumpster text-rose-500 text-xs"></i>
                        <span>Hao hụt &amp; Tiêu hủy</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/shop/inventory?viewTab=alert"
                       class="inv-tab-btn ${viewTab == 'alert' ? 'active' : ''}">
                        <i class="fa-solid fa-triangle-exclamation text-red-500 text-xs"></i>
                        <span>Cảnh báo khẩn & Tồn thấp</span>
                        <span class="px-1.5 py-0.2 rounded-full bg-red-100 text-red-600 text-[10px] font-black">${criticalStockCount}</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/shop/inventory?viewTab=all"
                       class="inv-tab-btn ${viewTab == 'all' ? 'active' : ''}">
                        <i class="fa-solid fa-boxes-stacked text-slate-500 text-xs"></i>
                        <span>Quản lý toàn bộ tồn kho</span>
                        <span class="text-slate-400 text-xs">${totalSkus}</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/shop/inventory?viewTab=freshness"
                       class="inv-tab-btn ${viewTab == 'freshness' ? 'active' : ''}">
                        <i class="fa-regular fa-clock text-slate-500 text-xs"></i>
                        <span>Độ tươi & Ngày hái lô hàng</span>
                        <span class="px-1.5 py-0.2 rounded-full bg-emerald-100 text-emerald-800 text-[10px] font-black">12 LÔ</span>
                    </a>
                </div>

                <div class="flex items-center gap-2 text-xs">
                    <span class="text-[11px] font-bold text-slate-400 uppercase tracking-wider">LỌC THEO:</span>
                    <a href="#" class="inv-filter-pill active">Tất cả kho lạnh</a>
                    <a href="#" class="inv-filter-pill">Kho hái sáng (06:00)</a>
                    <a href="#" class="inv-filter-pill">Kho hái chiều (14:00)</a>
                </div>
            </div>

            <c:if test="${viewTab == 'waste'}">
                <div class="flex justify-end mb-4">
                    <button type="button" id="btnOpenManualWasteModal" class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-rose-600 hover:bg-rose-700 text-white font-extrabold text-xs transition shadow-sm cursor-pointer">
                        <i class="fa-solid fa-trash-can"></i>
                        <span>Báo Tiêu Hủy Nông Sản Kho</span>
                    </button>
                </div>
            </c:if>

            <c:choose>
                <c:when test="${viewTab == 'waste'}">
                    <jsp:include page="/views/shop/components/inventory/inventory-alerts-table.jsp" />
                </c:when>
                <c:otherwise>
                    <jsp:include page="/views/shop/components/inventory/inventory-main-table.jsp" />
                    <jsp:include page="/views/shop/components/inventory/inventory-sensor-widgets.jsp" />
                </c:otherwise>
            </c:choose>
        </div>
    </main>

    <jsp:include page="/views/shop/components/inventory/modal-restock.jsp" />
    <jsp:include page="/views/shop/components/inventory/modal-discount.jsp" />
    <jsp:include page="/views/shop/components/inventory/modal-waste.jsp" />

    <script src="${pageContext.request.contextPath}/assets/js/shop-inventory.js"></script>
</body>
</html>
