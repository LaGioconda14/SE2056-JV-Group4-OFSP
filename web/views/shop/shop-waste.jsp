<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quản Lý Hàng Hao Hụt & Tiêu Hủy Nông Sản - Kênh Người Bán</title>

    <jsp:include page="/views/shop/layout/head.jsp" />

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-products.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-inventory.css">
</head>
<body class="bg-[#f8fafc] text-[#0f172a]">

    <jsp:include page="/views/shop/layout/sidebar.jsp">
        <jsp:param name="active" value="waste" />
    </jsp:include>

    <jsp:include page="/views/shop/layout/header.jsp">
        <jsp:param name="searchAction" value="/shop/waste" />
    </jsp:include>

    <main class="shop-main-wrapper">
        <div class="shop-content-container">

            <jsp:include page="/views/shop/components/common/flash-message.jsp" />

            
            <div class="flex flex-col gap-2 mb-6">
                <nav class="flex items-center gap-2 text-xs text-slate-500 font-medium">
                    <span>Kênh Người Bán</span>
                    <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                    <span>Sản phẩm & Kho</span>
                    <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                    <span class="text-slate-800 font-semibold">Quản lý hao hụt & tiêu hủy</span>
                </nav>

                <div class="flex flex-col xl:flex-row xl:items-center justify-between gap-4 mt-1">
                    <div>
                        <div class="flex items-center flex-wrap gap-3">
                            <h1 class="text-2xl font-black text-gray-900 tracking-tight">Quản Lý Hàng Hao Hụt / Hư Hỏng Nông Sản</h1>
                            <span class="px-2.5 py-0.5 rounded-full bg-rose-100 text-rose-700 font-extrabold text-[11px] uppercase tracking-wider flex items-center gap-1.5">
                                <i class="fa-solid fa-shield-halved text-rose-600"></i>
                                Kiểm Soát Chất Lượng Nhà Vườn
                            </span>
                        </div>
                        <p class="text-xs text-slate-500 mt-1">
                            Ghi nhận nông sản dập nát, thối rữa, hết hạn bảo quản, trừ tồn kho tự động và xử lý kiện hàng hoàn đứt chuỗi lạnh.
                        </p>
                    </div>

                    <div class="flex items-center gap-3">
                        <button type="button" id="btnOpenManualWasteModal" class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-rose-600 hover:bg-rose-700 text-white font-extrabold text-xs transition shadow-sm cursor-pointer">
                            <i class="fa-solid fa-trash-can"></i>
                            <span>Báo Tiêu Hủy Nông Sản</span>
                        </button>
                    </div>
                </div>
            </div>


            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
                
                <div class="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs flex flex-col justify-between">
                    <div class="flex items-start justify-between">
                        <div>
                            <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Tổng sản lượng tiêu hủy</span>
                            <div class="text-2xl font-black text-rose-600 mt-1">
                                ${stats.totalWasteQuantity} <span class="text-sm font-semibold text-slate-500">kg/hộp</span>
                            </div>
                        </div>
                        <div class="w-10 h-10 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center text-lg font-bold">
                            <i class="fa-solid fa-weight-scale"></i>
                        </div>
                    </div>
                    <div class="text-[11px] text-slate-400 mt-3 pt-2 border-t border-slate-100 flex items-center gap-1.5">
                        <i class="fa-solid fa-boxes-stacked text-slate-400"></i>
                        <span>Đã tự động trừ khỏi kho thực tế</span>
                    </div>
                </div>

                
                <div class="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs flex flex-col justify-between">
                    <div class="flex items-start justify-between">
                        <div>
                            <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Tổng thiệt hại ước tính</span>
                            <div class="text-2xl font-black text-slate-900 mt-1">
                                <fmt:formatNumber value="${stats.totalLossAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                            </div>
                        </div>
                        <div class="w-10 h-10 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center text-lg font-bold">
                            <i class="fa-solid fa-sack-xmark"></i>
                        </div>
                    </div>
                    <div class="text-[11px] text-slate-400 mt-3 pt-2 border-t border-slate-100 flex items-center gap-1.5">
                        <i class="fa-solid fa-calculator text-slate-400"></i>
                        <span>Tính theo đơn giá niêm yết của nông sản</span>
                    </div>
                </div>

                
                <div class="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs flex flex-col justify-between">
                    <div class="flex items-start justify-between">
                        <div>
                            <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Tỷ lệ hao hụt nông sản</span>
                            <div class="flex items-center gap-2 mt-1">
                                <span class="text-2xl font-black ${stats.wasteRatePercent < 3.0 ? 'text-emerald-700' : (stats.wasteRatePercent <= 7.0 ? 'text-amber-700' : 'text-rose-700')}">
                                    ${stats.wasteRatePercent}%
                                </span>
                                <c:choose>
                                    <c:when test="${stats.wasteRatePercent < 3.0}">
                                        <span class="px-2 py-0.5 rounded-full text-[10px] font-black bg-emerald-100 text-emerald-800">Chuẩn tươi</span>
                                    </c:when>
                                    <c:when test="${stats.wasteRatePercent <= 7.0}">
                                        <span class="px-2 py-0.5 rounded-full text-[10px] font-black bg-amber-100 text-amber-800">Cảnh báo</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="px-2 py-0.5 rounded-full text-[10px] font-black bg-rose-100 text-rose-800">Nguy cấp</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="w-10 h-10 rounded-xl ${stats.wasteRatePercent < 3.0 ? 'bg-emerald-50 text-emerald-600' : (stats.wasteRatePercent <= 7.0 ? 'bg-amber-50 text-amber-600' : 'bg-rose-50 text-rose-600')} flex items-center justify-center text-lg font-bold">
                            <i class="fa-solid fa-chart-pie"></i>
                        </div>
                    </div>
                    
                    <div class="mt-3 pt-2 border-t border-slate-100">
                        <div class="w-full bg-slate-100 h-1.5 rounded-full overflow-hidden">
                            <div class="h-full ${stats.wasteRatePercent < 3.0 ? 'bg-emerald-500' : (stats.wasteRatePercent <= 7.0 ? 'bg-amber-500' : 'bg-rose-500')} rounded-full" 
                                 style="width: ${stats.wasteRatePercent > 100 ? 100 : stats.wasteRatePercent}%"></div>
                        </div>
                        <div class="text-[10px] text-slate-400 mt-1 flex justify-between">
                            <span>Mục tiêu: &lt; 3%</span>
                            <span>Hao hụt/Tổng sản lượng</span>
                        </div>
                    </div>
                </div>

                
                <div class="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs flex flex-col justify-between">
                    <div class="flex items-start justify-between">
                        <div>
                            <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Tổng số phiếu tiêu hủy</span>
                            <div class="text-2xl font-black text-slate-900 mt-1">
                                ${stats.totalLogsCount} <span class="text-sm font-semibold text-slate-500">phiếu</span>
                            </div>
                        </div>
                        <div class="w-10 h-10 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center text-lg font-bold">
                            <i class="fa-solid fa-clipboard-check"></i>
                        </div>
                    </div>
                    <div class="text-[11px] text-slate-400 mt-3 pt-2 border-t border-slate-100 flex items-center gap-1.5">
                        <i class="fa-solid fa-history text-slate-400"></i>
                        <span>Lưu vết chi tiết người và lý do hủy</span>
                    </div>
                </div>
            </div>


            <div class="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs mb-4 flex flex-col md:flex-row items-center justify-between gap-4">
                
                <div class="flex items-center gap-2 overflow-x-auto w-full md:w-auto pb-1 md:pb-0 text-xs font-bold">
                    <a href="?stage=ALL${not empty keyword ? '&keyword=' += keyword : ''}" 
                       class="px-3.5 py-2 rounded-xl transition flex items-center gap-1.5 whitespace-nowrap ${currentStage eq 'ALL' ? 'bg-slate-900 text-white' : 'bg-slate-100 text-slate-600 hover:bg-slate-200'}">
                        <span>Tất cả</span>
                    </a>
                    <a href="?stage=QC_PACKING${not empty keyword ? '&keyword=' += keyword : ''}" 
                       class="px-3.5 py-2 rounded-xl transition flex items-center gap-1.5 whitespace-nowrap ${currentStage eq 'QC_PACKING' ? 'bg-purple-600 text-white' : 'bg-slate-100 text-slate-600 hover:bg-slate-200'}">
                        <i class="fa-solid fa-boxes-packing text-xs"></i>
                        <span>Dập nát khi đóng gói / sơ chế</span>
                    </a>
                    <a href="?stage=TRANSIT_DAMAGE${not empty keyword ? '&keyword=' += keyword : ''}" 
                       class="px-3.5 py-2 rounded-xl transition flex items-center gap-1.5 whitespace-nowrap ${currentStage eq 'TRANSIT_DAMAGE' ? 'bg-amber-600 text-white' : 'bg-slate-100 text-slate-600 hover:bg-slate-200'}">
                        <i class="fa-solid fa-truck-ramp-box text-xs"></i>
                        <span>Hỏng do vận chuyển / Hàng hoàn</span>
                    </a>
                    <a href="?stage=WAREHOUSE_EXPIRED${not empty keyword ? '&keyword=' += keyword : ''}" 
                       class="px-3.5 py-2 rounded-xl transition flex items-center gap-1.5 whitespace-nowrap ${currentStage eq 'WAREHOUSE_EXPIRED' ? 'bg-rose-600 text-white' : 'bg-slate-100 text-slate-600 hover:bg-slate-200'}">
                        <i class="fa-solid fa-warehouse text-xs"></i>
                        <span>Hết hạn / Hỏng tại kho lưu trữ</span>
                    </a>
                </div>

                
                <form action="${pageContext.request.contextPath}/shop/waste" method="GET" class="w-full md:w-80 flex items-center gap-2">
                    <input type="hidden" name="stage" value="${currentStage}">
                    <div class="relative flex-1">
                        <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
                        <input type="text" name="keyword" value="${keyword}" placeholder="Tìm theo tên trái cây, SKU, mã đơn..." 
                               class="w-full pl-9 pr-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-800 focus:bg-white focus:outline-none focus:ring-2 focus:ring-rose-500/20">
                    </div>
                    <button type="submit" class="px-3.5 py-2 rounded-xl bg-slate-800 hover:bg-slate-900 text-white text-xs font-bold transition cursor-pointer">
                        Tìm
                    </button>
                </form>
            </div>


            <div class="bg-white rounded-2xl border border-slate-200 shadow-xs overflow-hidden mb-6">
                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse text-xs">
                        <thead>
                            <tr class="bg-slate-50 border-b border-slate-200 text-slate-600 font-extrabold uppercase tracking-wider text-[11px]">
                                <th class="py-3.5 px-4 min-w-[130px]">MÃ PHIẾU & NGÀY</th>
                                <th class="py-3.5 px-4 min-w-[260px]">NÔNG SẢN & BIẾN THỂ</th>
                                <th class="py-3.5 px-4 min-w-[120px]">SỐ LƯỢNG HỦY</th>
                                <th class="py-3.5 px-4 min-w-[140px]">TỔNG THIỆT HẠI</th>
                                <th class="py-3.5 px-4 min-w-[220px]">GIAI ĐOẠN & LÝ DO HỎNG</th>
                                <th class="py-3.5 px-4 min-w-[140px]">ĐƠN HÀNG</th>
                                <th class="py-3.5 px-4 min-w-[130px]">NGƯỜI XỬ LÝ</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            <c:choose>
                                <c:when test="${not empty wasteLogs}">
                                    <c:forEach items="${wasteLogs}" var="log">
                                        <tr class="hover:bg-slate-50/70 transition-colors">
                                            
                                            <td class="py-3.5 px-4">
                                                <div class="font-extrabold text-slate-900">#HHL-${log.wasteId}</div>
                                                <div class="text-[11px] text-slate-400 mt-0.5">
                                                    <fmt:formatDate value="${log.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                </div>
                                            </td>

                                            
                                            <td class="py-3.5 px-4">
                                                <div class="flex items-center gap-2.5">
                                                    <div class="w-10 h-10 rounded-xl bg-slate-100 flex items-center justify-center text-slate-400 shrink-0 font-bold overflow-hidden border border-slate-200">
                                                        <i class="fa-solid fa-apple-whole text-emerald-600"></i>
                                                    </div>
                                                    <div class="min-w-0">
                                                        <div class="font-bold text-slate-900 truncate hover:text-emerald-700 transition cursor-pointer">
                                                            ${log.productName}
                                                        </div>
                                                        <div class="text-[11px] text-slate-500 font-medium">
                                                            ${log.variantName} <span class="text-slate-400">(${log.sku})</span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </td>

                                            
                                            <td class="py-3.5 px-4">
                                                <span class="inline-flex items-center gap-1 font-black text-rose-700 bg-rose-50 px-2.5 py-1 rounded-lg border border-rose-200/60">
                                                    <i class="fa-solid fa-arrow-down text-[10px]"></i>
                                                    <span>${log.quantity} ${log.unit}</span>
                                                </span>
                                            </td>

                                            
                                            <td class="py-3.5 px-4">
                                                <div class="font-black text-slate-900">
                                                    <fmt:formatNumber value="${log.estimatedLoss}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                </div>
                                                <div class="text-[11px] text-slate-400">
                                                    Đơn giá: <fmt:formatNumber value="${log.costPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>/${log.unit}
                                                </div>
                                            </td>

                                            
                                            <td class="py-3.5 px-4">
                                                <div>
                                                    <c:choose>
                                                        <c:when test="${log.wasteStage eq 'QC_PACKING'}">
                                                            <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[10px] font-extrabold bg-purple-100 text-purple-800 border border-purple-200">
                                                                <i class="fa-solid fa-boxes-packing text-[9px]"></i> Đóng gói / Sơ chế
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${log.wasteStage eq 'TRANSIT_DAMAGE'}">
                                                            <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[10px] font-extrabold bg-amber-100 text-amber-800 border border-amber-200">
                                                                <i class="fa-solid fa-truck-ramp-box text-[9px]"></i> Hỏng do vận chuyển / Hoàn
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[10px] font-extrabold bg-rose-100 text-rose-800 border border-rose-200">
                                                                <i class="fa-solid fa-warehouse text-[9px]"></i> Kho lưu trữ / Hết hạn
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <div class="text-[11px] text-slate-700 font-semibold mt-1 leading-snug">
                                                        <c:out value="${log.reasonNote}"/>
                                                    </div>
                                                </div>
                                            </td>

                                            
                                            <td class="py-3.5 px-4">
                                                <c:choose>
                                                    <c:when test="${not empty log.subOrderCode}">
                                                        <a href="${pageContext.request.contextPath}/shop/order-detail?code=${log.subOrderCode}" target="_blank" class="inline-flex items-center gap-1 text-slate-700 hover:text-emerald-700 font-bold text-xs underline">
                                                            <i class="fa-solid fa-receipt text-[10px] text-slate-400"></i>
                                                            <span>${log.subOrderCode}</span>
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-slate-400 italic text-[11px]">Hủy tại kho</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            
                                            <td class="py-3.5 px-4">
                                                <div class="font-semibold text-slate-800">
                                                    ${not empty log.loggedByName ? log.loggedByName : 'Chủ gian hàng'}
                                                </div>
                                                <span class="text-[10px] text-slate-400">Đã đối soát kho</span>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="7" class="py-12 text-center text-slate-400">
                                            <div class="w-12 h-12 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mx-auto mb-3 text-lg font-bold">
                                                <i class="fa-solid fa-clipboard-check"></i>
                                            </div>
                                            <div class="text-sm font-bold text-slate-700">Không tìm thấy bản ghi hao hụt nào</div>
                                            <p class="text-xs text-slate-500 mt-1">Không có lịch sử tiêu hủy nông sản phù hợp với bộ lọc hiện tại.</p>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                
                <c:if test="${totalPages > 1}">
                    <div class="p-4 border-t border-slate-100 flex items-center justify-between text-xs text-slate-500">
                        <span>Hiển thị trang <b>${currentPage}</b> / <b>${totalPages}</b> (Tổng số ${totalItems} bản ghi)</span>
                        <div class="flex items-center gap-1">
                            <c:if test="${currentPage > 1}">
                                <a href="?stage=${currentStage}&keyword=${keyword}&page=${currentPage - 1}" class="px-3 py-1.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-50 text-slate-700 font-bold transition">
                                    &larr; Trước
                                </a>
                            </c:if>
                            <c:forEach begin="1" end="${totalPages}" var="p">
                                <a href="?stage=${currentStage}&keyword=${keyword}&page=${p}" 
                                   class="px-3 py-1.5 rounded-lg font-bold transition ${p eq currentPage ? 'bg-rose-600 text-white' : 'border border-slate-200 bg-white hover:bg-slate-50 text-slate-700'}">
                                    ${p}
                                </a>
                            </c:forEach>
                            <c:if test="${currentPage < totalPages}">
                                <a href="?stage=${currentStage}&keyword=${keyword}&page=${currentPage + 1}" class="px-3 py-1.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-50 text-slate-700 font-bold transition">
                                    Sau &rarr;
                                </a>
                            </c:if>
                        </div>
                    </div>
                </c:if>
            </div>

        </div>
    </main>


    <div id="modalManualWaste" class="fixed inset-0 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center z-50 p-4 hidden transition-opacity">
        <div class="bg-white rounded-2xl max-w-lg w-full shadow-2xl border border-slate-100 overflow-hidden animate-scaleIn">
            <div class="p-5 border-b border-slate-100 flex items-center justify-between">
                <div class="flex items-center gap-3">
                    <div class="w-9 h-9 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center text-base font-bold border border-rose-200">
                        <i class="fa-solid fa-trash-can"></i>
                    </div>
                    <div>
                        <h3 class="text-sm font-black text-slate-900">Báo Tiêu Hủy Nông Sản Kho Lạnh</h3>
                        <p class="text-[11px] text-slate-400">Trừ trực tiếp tồn kho thực tế và ghi nhận vào sổ hao hụt</p>
                    </div>
                </div>
                <button type="button" id="btnCloseManualWasteModal" class="w-8 h-8 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 flex items-center justify-center transition cursor-pointer">
                    <i class="fa-solid fa-xmark text-sm"></i>
                </button>
            </div>

            <form action="${pageContext.request.contextPath}/shop/waste" method="POST" class="p-5 space-y-4">
                <input type="hidden" name="action" value="manual_waste">

                
                <div>
                    <label for="selectVariantWaste" class="block text-xs font-bold text-slate-700 mb-1.5">
                        1. Chọn nông sản / biến thể cần tiêu hủy: <span class="text-rose-500">*</span>
                    </label>
                    <select name="variantId" id="selectVariantWaste" required class="w-full p-2.5 text-xs rounded-xl border border-slate-300 bg-white focus:outline-none focus:border-rose-500 font-medium">
                        <option value="">-- Chọn sản phẩm trong kho --</option>
                        <c:forEach items="${variants}" var="v">
                            <option value="${v.variantId}" data-stock="${v.stockQuantity}" data-unit="${v.unit}" data-price="${v.price}">
                                ${v.productName} - ${v.variantName} [Tồn kho: ${v.stockQuantity} ${v.unit}]
                            </option>
                        </c:forEach>
                    </select>
                </div>

                
                <div class="grid grid-cols-2 gap-3">
                    <div>
                        <label for="inputWasteQuantity" class="block text-xs font-bold text-slate-700 mb-1.5">
                            2. Số lượng tiêu hủy: <span class="text-rose-500">*</span>
                        </label>
                        <div class="relative">
                            <input type="number" name="quantity" id="inputWasteQuantity" min="1" required placeholder="0" 
                                   class="w-full p-2.5 text-xs rounded-xl border border-slate-300 bg-white focus:outline-none focus:border-rose-500 font-bold text-rose-600">
                            <span id="textUnitLabel" class="absolute right-3 top-2.5 text-xs font-bold text-slate-400">kg</span>
                        </div>
                    </div>

                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1.5">Tồn kho khả dụng:</label>
                        <div class="p-2.5 rounded-xl bg-slate-50 border border-slate-200 text-xs font-black text-slate-800 flex items-center justify-between">
                            <span id="textAvailableStock">0</span>
                            <span class="text-[11px] font-normal text-slate-400">trong kho</span>
                        </div>
                    </div>
                </div>

                
                <div>
                    <label for="selectWasteStage" class="block text-xs font-bold text-slate-700 mb-1.5">
                        3. Giai đoạn phát sinh hao hụt: <span class="text-rose-500">*</span>
                    </label>
                    <select name="wasteStage" id="selectWasteStage" required class="w-full p-2.5 text-xs rounded-xl border border-slate-300 bg-white focus:outline-none focus:border-rose-500 font-medium">
                        <option value="WAREHOUSE_EXPIRED">Hết hạn / Úng thối tại kho lưu trữ (WAREHOUSE_EXPIRED)</option>
                        <option value="QC_PACKING">Dập nát khi phân loại, đóng gói & sơ chế (QC_PACKING)</option>
                        <option value="TRANSIT_DAMAGE">Đứt chuỗi lạnh / Dập nát do vận chuyển (TRANSIT_DAMAGE)</option>
                    </select>
                </div>

                
                <div>
                    <label for="selectReasonCategory" class="block text-xs font-bold text-slate-700 mb-1.5">
                        4. Nguyên nhân chính: <span class="text-rose-500">*</span>
                    </label>
                    <select name="reasonCategory" id="selectReasonCategory" class="w-full p-2.5 text-xs rounded-xl border border-slate-300 bg-white focus:outline-none focus:border-rose-500 font-medium">
                        <option value="Dập nát do va chạm / rơi vỡ">Dập nát do va chạm / rơi vỡ khi bốc dỡ</option>
                        <option value="Nấm mốc, thối úng do đọng nước">Nấm mốc, thối úng do đọng nước trong hộp</option>
                        <option value="Quá hạn bảo quản, chín nẫu lên men">Quá hạn bảo quản, chín nẫu lên men không còn giòn ngọt</option>
                        <option value="Lỗi thiết bị kho lạnh làm hỏng hoa quả">Lỗi thiết bị kho lạnh (nhiệt độ tăng cao/đóng băng hỏng mô)</option>
                        <option value="Sâu bọ / côn trùng gây hại">Sâu bọ / côn trùng xâm nhập</option>
                        <option value="Khác">Lý do khác</option>
                    </select>
                </div>

                
                <div>
                    <label for="textareaReasonNote" class="block text-xs font-bold text-slate-700 mb-1">
                        5. Ghi chú chi tiết tình trạng quả:
                    </label>
                    <textarea name="reasonNote" id="textareaReasonNote" rows="2" placeholder="Ghi chú chi tiết tình trạng quả dập nát, mùi lạ, tỷ lệ hỏng của lô hàng..." 
                              class="w-full p-2.5 text-xs rounded-xl border border-slate-300 bg-white focus:outline-none focus:border-rose-500 font-medium"></textarea>
                </div>

                <div class="flex items-center justify-end gap-2 pt-3 border-t border-slate-100">
                    <button type="button" id="btnDismissManualWasteModal" class="px-4 py-2.5 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold text-xs transition cursor-pointer">
                        Đóng
                    </button>
                    <button type="submit" class="px-4 py-2.5 rounded-xl bg-rose-600 hover:bg-rose-700 text-white font-black text-xs transition shadow-sm cursor-pointer">
                        Xác Nhận Trừ Tồn Kho &amp; Tiêu Hủy
                    </button>
                </div>
            </form>
        </div>
    </div>


    
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // --- Xử lý Modal 1: Báo Tiêu Hủy Nông Sản Kho ---
            const modalManualWaste = document.getElementById('modalManualWaste');
            const btnOpenManualWasteModal = document.getElementById('btnOpenManualWasteModal');
            const btnCloseManualWasteModal = document.getElementById('btnCloseManualWasteModal');
            const btnDismissManualWasteModal = document.getElementById('btnDismissManualWasteModal');
            const selectVariantWaste = document.getElementById('selectVariantWaste');
            const inputWasteQuantity = document.getElementById('inputWasteQuantity');
            const textUnitLabel = document.getElementById('textUnitLabel');
            const textAvailableStock = document.getElementById('textAvailableStock');

            function openManualModal() {
                modalManualWaste.classList.remove('hidden');
            }
            function closeManualModal() {
                modalManualWaste.classList.add('hidden');
            }

            if (btnOpenManualWasteModal) btnOpenManualWasteModal.addEventListener('click', openManualModal);
            if (btnCloseManualWasteModal) btnCloseManualWasteModal.addEventListener('click', closeManualModal);
            if (btnDismissManualWasteModal) btnDismissManualWasteModal.addEventListener('click', closeManualModal);

            if (selectVariantWaste) {
                selectVariantWaste.addEventListener('change', function() {
                    const opt = this.options[this.selectedIndex];
                    if (opt && opt.value) {
                        const stock = opt.getAttribute('data-stock') || '0';
                        const unit = opt.getAttribute('data-unit') || 'kg';
                        textAvailableStock.textContent = stock + ' ' + unit;
                        textUnitLabel.textContent = unit;
                        inputWasteQuantity.max = stock;
                        inputWasteQuantity.placeholder = 'Tối đa ' + stock;
                    } else {
                        textAvailableStock.textContent = '0';
                        textUnitLabel.textContent = 'kg';
                        inputWasteQuantity.removeAttribute('max');
                        inputWasteQuantity.placeholder = '0';
                    }
                });
            }

            // Tự động tắt flash messages sau 4 giây
            setTimeout(function() {
                const msg = document.getElementById('flashMsg');
                if (msg) msg.remove();
                const msgErr = document.getElementById('flashMsgErr');
                if (msgErr) msgErr.remove();
            }, 4000);
        });
    </script>
</body>
</html>
