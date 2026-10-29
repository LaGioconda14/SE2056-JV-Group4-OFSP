<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN" />

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Quản Lý Tồn Kho & Hao Hụt Nông Sản | Gốc Vườn Seller Center</title>

        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">

        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">

        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-inventory.css">
    </head>

    <body class="bg-slate-50 text-slate-800 antialiased font-['Inter'] min-h-screen flex">

        <jsp:include page="/views/shop/layout/sidebar.jsp">
            <jsp:param name="activeMenu" value="inventory" />
        </jsp:include>

        <div class="flex-1 flex flex-col min-w-0 overflow-y-auto">

            <jsp:include page="/views/shop/layout/header.jsp" />

            <main class="flex-1 p-6 max-w-7xl w-full mx-auto space-y-6">

                <div class="flex items-center justify-between text-xs text-slate-500">
                    <div class="flex items-center gap-2">
                        <a href="${pageContext.request.contextPath}/shop/products" class="hover:text-emerald-700 transition">Kênh Người Bán</a>
                        <span>&gt;</span>
                        <span class="font-bold text-slate-800">Quản lý kho &amp; Hao hụt nông sản</span>
                    </div>
                    <button type="button" id="btnOpenManualWasteModal" class="inline-flex items-center gap-2 px-3.5 py-2 rounded-xl bg-rose-600 hover:bg-rose-700 text-white font-extrabold text-xs transition shadow-sm cursor-pointer">
                        <i class="fa-solid fa-trash-can"></i>
                        <span>Báo Tiêu Hủy Nông Sản Kho</span>
                    </button>
                </div>

                <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
                    <div>
                        <h1 class="text-2xl font-black text-slate-900 tracking-tight">
                            Báo Cáo Hao Hụt &amp; Quả Hỏng Nông Sản
                        </h1>
                        <p class="text-xs text-slate-500 mt-1">
                            Hạch toán chính xác tổn thất bảo quản lạnh, kiểm định QC đóng gói và hàng hỏng khi vận chuyển
                        </p>
                    </div>
                </div>

                <c:if test="${param.success eq '1'}">
                    <div class="p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs font-semibold flex items-center justify-between shadow-2xs">
                        <div class="flex items-center gap-2">
                            <i class="fa-solid fa-circle-check text-emerald-600 text-base"></i>
                            <span>Đã ghi nhận tiêu hủy nông sản hỏng và tự động giảm trừ tồn kho thành công!</span>
                        </div>
                        <a href="${pageContext.request.contextPath}/shop/inventory" class="text-emerald-700 hover:underline font-bold">Đóng</a>
                    </div>
                </c:if>

                <c:if test="${param.error eq 'stock_exceeded'}">
                    <div class="p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 text-xs font-semibold flex items-center justify-between shadow-2xs">
                        <div class="flex items-center gap-2">
                            <i class="fa-solid fa-triangle-exclamation text-rose-600 text-base"></i>
                            <span>Số lượng tiêu hủy vượt quá tồn kho khả dụng hiện tại!</span>
                        </div>
                        <a href="${pageContext.request.contextPath}/shop/inventory" class="text-rose-700 hover:underline font-bold">Đóng</a>
                    </div>
                </c:if>

                <div class="bg-white rounded-2xl border border-slate-200 p-6 shadow-xs space-y-4">
                    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-4 border-b border-slate-100">
                        <div class="flex items-center gap-2">
                            <div class="w-8 h-8 rounded-xl bg-emerald-50 text-emerald-700 flex items-center justify-center text-sm font-bold">
                                <i class="fa-solid fa-book-skull"></i>
                            </div>
                            <div>
                                <h3 class="text-base font-extrabold text-slate-900">Nhật Ký Hao Hụt &amp; Tiêu Hủy Nông Sản</h3>
                                <p class="text-[11px] text-slate-400">Theo dõi toàn bộ vết hao hụt từ đơn hủy và tiêu hủy kho</p>
                            </div>
                        </div>

                        <form action="${pageContext.request.contextPath}/shop/inventory" method="GET" class="flex flex-wrap items-center gap-2 m-0">
                            <select name="stage" onchange="this.form.submit()" class="p-2 text-xs rounded-xl border border-slate-200 bg-white focus:outline-none focus:border-emerald-600 font-medium">
                                <option value="ALL" ${currentStage eq 'ALL' ? 'selected' : ''}>-- Tất cả giai đoạn --</option>
                                <option value="QC_PACKING" ${currentStage eq 'QC_PACKING' ? 'selected' : ''}>Hỏng khi QC đóng gói</option>
                                <option value="TRANSIT_DAMAGE" ${currentStage eq 'TRANSIT_DAMAGE' ? 'selected' : ''}>Hỏng do vận chuyển xe lạnh</option>
                                <option value="WAREHOUSE_EXPIRED" ${currentStage eq 'WAREHOUSE_EXPIRED' ? 'selected' : ''}>Tiêu hủy tồn kho định kỳ</option>
                                <option value="CUSTOMER_DISPUTE" ${currentStage eq 'CUSTOMER_DISPUTE' ? 'selected' : ''}>Khách khiếu nại dập nát</option>
                            </select>

                            <div class="relative">
                                <input type="text" name="keyword" value="${keyword}" placeholder="Tìm theo tên quả, SKU..." class="pl-8 pr-3 py-2 text-xs rounded-xl border border-slate-200 bg-white focus:outline-none focus:border-emerald-600 w-48">
                                <i class="fa-solid fa-magnifying-glass absolute left-2.5 top-2.5 text-slate-400 text-xs"></i>
                            </div>

                            <button type="submit" class="px-3.5 py-2 rounded-xl bg-slate-900 hover:bg-slate-800 text-white font-bold text-xs transition cursor-pointer">
                                Lọc
                            </button>
                        </form>
                    </div>

                    <div class="overflow-x-auto">
                        <table class="w-full text-left text-xs">
                            <thead>
                                <tr class="text-slate-400 font-bold border-b border-slate-100 text-[11px]">
                                    <th class="pb-3 w-44">THỜI GIAN / MÃ</th>
                                    <th class="pb-3">SẢN PHẨM &amp; PHÂN LOẠI</th>
                                    <th class="pb-3">GIAI ĐOẠN HỎNG</th>
                                    <th class="pb-3 text-center">SỐ LƯỢNG</th>
                                    <th class="pb-3 text-right">ĐƠN GIÁ</th>
                                    <th class="pb-3 text-right">TỔNG THIỆT HẠI</th>
                                    <th class="pb-3 pl-4">LÝ DO TIÊU HỦY</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100">
                                <c:choose>
                                    <c:when test="${not empty wasteLogs}">
                                        <c:forEach items="${wasteLogs}" var="log">
                                            <tr>
                                                <td class="py-3.5">
                                                    <div class="font-extrabold text-slate-800">#WH-${log.wasteId}</div>
                                                    <div class="text-[11px] text-slate-400 mt-0.5">
                                                        <fmt:formatDate value="${log.createdAt}" pattern="HH:mm dd/MM/yyyy" />
                                                    </div>
                                                    <c:if test="${not empty log.subOrderCode}">
                                                        <a href="${pageContext.request.contextPath}/shop/order-detail?code=${log.subOrderCode}" class="inline-block text-[10px] text-emerald-700 font-bold hover:underline mt-0.5">
                                                            Đơn: #${log.subOrderCode}
                                                        </a>
                                                    </c:if>
                                                </td>
                                                <td class="py-3.5">
                                                    <div class="font-bold text-slate-900">${log.productName}</div>
                                                    <div class="text-[11px] text-slate-500 mt-0.5">
                                                        <span>${log.variantName}</span>
                                                        <span class="text-slate-300 mx-1">•</span>
                                                        <span class="font-mono text-slate-400">${log.sku}</span>
                                                    </div>
                                                </td>
                                                <td class="py-3.5">
                                                    <c:choose>
                                                        <c:when test="${log.wasteStage eq 'QC_PACKING'}">
                                                            <span class="badge-qc-packing px-2.5 py-1 rounded-md text-[10px] font-bold">
                                                                <i class="fa-solid fa-box-open mr-1"></i> QC Đóng gói
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${log.wasteStage eq 'TRANSIT_DAMAGE'}">
                                                            <span class="badge-transit-damage px-2.5 py-1 rounded-md text-[10px] font-bold">
                                                                <i class="fa-solid fa-truck-fast mr-1"></i> Xe lạnh hỏng
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${log.wasteStage eq 'WAREHOUSE_EXPIRED'}">
                                                            <span class="badge-warehouse-expired px-2.5 py-1 rounded-md text-[10px] font-bold">
                                                                <i class="fa-solid fa-warehouse mr-1"></i> Hỏng tồn kho
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge-customer-dispute px-2.5 py-1 rounded-md text-[10px] font-bold">
                                                                <i class="fa-solid fa-user-xmark mr-1"></i> Khách khiếu nại
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="py-3.5 text-center font-extrabold text-rose-600 text-sm">
                                                    -${log.quantity} <span class="text-xs font-normal text-slate-500">${log.unit}</span>
                                                </td>
                                                <td class="py-3.5 text-right font-medium text-slate-600">
                                                    <fmt:formatNumber value="${log.costPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                </td>
                                                <td class="py-3.5 text-right font-black text-rose-600 text-sm">
                                                    -<fmt:formatNumber value="${log.estimatedLoss}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                </td>
                                                <td class="py-3.5 pl-4">
                                                    <div class="text-slate-800 text-xs font-semibold leading-relaxed max-w-xs truncate" title="${log.reasonNote}">
                                                        ${log.reasonNote}
                                                    </div>
                                                    <c:if test="${not empty log.loggedByName}">
                                                        <div class="text-[10px] text-slate-400 mt-0.5">Bởi: ${log.loggedByName}</div>
                                                    </c:if>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="7" class="py-12 text-center text-slate-400">
                                                <div class="w-12 h-12 rounded-2xl bg-slate-100 text-slate-400 flex items-center justify-center mx-auto mb-2 text-xl">
                                                    <i class="fa-solid fa-box-archive"></i>
                                                </div>
                                                <div class="font-bold text-xs text-slate-600">Không có bản ghi hao hụt nào</div>
                                                <div class="text-[11px] text-slate-400 mt-0.5">Kho hàng của shop đang bảo quản nông sản rất tốt</div>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>

                    <c:if test="${totalPages > 1}">
                        <div class="flex items-center justify-between pt-4 border-t border-slate-100 text-xs text-slate-500">
                            <div>
                                Trang <span class="font-bold text-slate-800">${currentPage}</span> / <span class="font-bold text-slate-800">${totalPages}</span> (Tổng ${totalItems} bản ghi)
                            </div>
                            <div class="flex items-center gap-1">
                                <c:if test="${currentPage > 1}">
                                    <a href="${pageContext.request.contextPath}/shop/inventory?stage=${currentStage}&keyword=${keyword}&page=${currentPage - 1}" class="px-3 py-1.5 rounded-lg border border-slate-200 hover:bg-slate-50 font-bold transition">Trước</a>
                                </c:if>
                                <c:forEach begin="1" end="${totalPages}" var="i">
                                    <a href="${pageContext.request.contextPath}/shop/inventory?stage=${currentStage}&keyword=${keyword}&page=${i}" class="px-3 py-1.5 rounded-lg border ${i eq currentPage ? 'bg-emerald-700 text-white border-emerald-700' : 'border-slate-200 hover:bg-slate-50 text-slate-700'} font-bold transition">
                                        ${i}
                                    </a>
                                </c:forEach>
                                <c:if test="${currentPage < totalPages}">
                                    <a href="${pageContext.request.contextPath}/shop/inventory?stage=${currentStage}&keyword=${keyword}&page=${currentPage + 1}" class="px-3 py-1.5 rounded-lg border border-slate-200 hover:bg-slate-50 font-bold transition">Sau</a>
                                </c:if>
                            </div>
                        </div>
                    </c:if>

                </div>

            </main>
        </div>

        <div id="wasteModalBackdrop" class="waste-modal-backdrop">
            <div class="waste-modal-dialog">
                <div class="p-5 border-b border-slate-100 flex items-center justify-between">
                    <div class="flex items-center gap-2.5">
                        <div class="w-8 h-8 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center text-sm font-bold border border-rose-200">
                            <i class="fa-solid fa-trash-can"></i>
                        </div>
                        <div>
                            <h3 class="text-sm font-black text-slate-900">Báo Tiêu Hủy Nông Sản Kho Lạnh</h3>
                            <p class="text-[10px] text-slate-400">Trừ trực tiếp số lượng tồn kho và ghi nhận chi phí hao hụt</p>
                        </div>
                    </div>
                    <button type="button" id="btnCloseManualWasteModal" class="w-7 h-7 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 flex items-center justify-center transition cursor-pointer">
                        <i class="fa-solid fa-xmark text-sm"></i>
                    </button>
                </div>

                <form id="formManualWaste" action="${pageContext.request.contextPath}/shop/inventory" method="POST" class="p-5 space-y-4">
                    <input type="hidden" name="action" value="manual_waste">

                    <div>
                        <label for="selectVariantWaste" class="block text-xs font-bold text-slate-700 mb-1.5">
                            1. Chọn nông sản / biến thể cần tiêu hủy: <span class="text-rose-500">*</span>
                        </label>
                        <select name="variantId" id="selectVariantWaste" required class="w-full p-2.5 text-xs rounded-xl border border-slate-300 bg-white focus:outline-none focus:border-rose-500 font-medium">
                            <option value="">-- Chọn một sản phẩm trong kho --</option>
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
                                <input type="number" name="quantity" id="inputWasteQuantity" min="1" required placeholder="0" class="w-full p-2.5 text-xs rounded-xl border border-slate-300 bg-white focus:outline-none focus:border-rose-500 font-bold text-rose-600">
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
                        <label for="textareaReasonNote" class="block text-xs font-bold text-slate-700 mb-1.5">
                            3. Lý do hoa quả bị hỏng / thâm úng: <span class="text-rose-500">*</span>
                        </label>
                        <textarea name="reasonNote" id="textareaReasonNote" rows="3" required placeholder="Mô tả hiện trạng (VD: Nho bị thâm đốm do đứt lạnh kho bảo ôn, dâu tây chín quá độ bị dập bề mặt)..." class="w-full p-2.5 text-xs rounded-xl border border-slate-300 bg-white focus:outline-none focus:border-rose-500"></textarea>
                    </div>

                    <div class="p-3 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 text-xs flex items-start gap-2">
                        <i class="fa-solid fa-triangle-exclamation text-amber-600 mt-0.5 text-sm shrink-0"></i>
                        <div class="leading-relaxed">
                            <b>Lưu ý toàn vẹn kho:</b> Sau khi xác nhận, số lượng tồn kho của biến thể này sẽ bị <b>giảm trừ ngay lập tức</b> và được ghi nhận vào báo cáo tài chính hao hụt.
                        </div>
                    </div>

                    <div class="flex items-center justify-end gap-2 pt-2 border-t border-slate-100">
                        <button type="button" id="btnCancelManualWasteModal" class="px-4 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs transition cursor-pointer">
                            Hủy bỏ
                        </button>
                        <button type="submit" class="px-4 py-2 rounded-xl bg-rose-600 hover:bg-rose-700 text-white font-extrabold text-xs transition shadow-sm cursor-pointer">
                            Xác Nhận Tiêu Hủy
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <script src="${pageContext.request.contextPath}/assets/js/shop-inventory.js"></script>
    </body>
</html>
