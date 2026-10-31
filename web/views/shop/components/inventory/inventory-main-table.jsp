<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<form action="${pageContext.request.contextPath}/shop/inventory" method="GET" class="bg-white p-3.5 rounded-2xl border border-slate-200/80 shadow-xs flex flex-col md:flex-row items-center gap-3">
    <input type="hidden" name="viewTab" value="${viewTab}">

    <div class="relative flex-1 w-full">
        <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
        <input type="text" name="keyword" value="${param.keyword}" placeholder="Tìm theo mã SKU, tên trái cây (Dâu, Bơ, Nho,...), mã lô thu hoạch" class="w-full pl-9 pr-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-800 focus:bg-white focus:outline-none focus:ring-2 focus:ring-emerald-500/20">
    </div>

    <div class="w-full md:w-56">
        <select name="riskLevel" class="filter-select-box !py-2 text-xs" onchange="this.form.submit()">
            <option value="">Mức độ rủi ro: Tất cả</option>
            <option value="critical" ${param.riskLevel == 'critical' ? 'selected' : ''}>Nguy cấp (&lt;= 5)</option>
            <option value="warning" ${param.riskLevel == 'warning' ? 'selected' : ''}>Cảnh báo vàng</option>
            <option value="safe" ${param.riskLevel == 'safe' ? 'selected' : ''}>An toàn</option>
        </select>
    </div>

    <div class="w-full md:w-60">
        <select name="sortBy" class="filter-select-box !py-2 text-xs" onchange="this.form.submit()">
            <option value="stock_asc" ${sortBy == 'stock_asc' ? 'selected' : ''}>Sắp xếp: Tồn kho ít nhất trước ⇅</option>
            <option value="stock_desc" ${sortBy == 'stock_desc' ? 'selected' : ''}>Sắp xếp: Tồn kho nhiều nhất trước</option>
            <option value="freshness_desc" ${sortBy == 'freshness_desc' ? 'selected' : ''}>Sắp xếp: Độ tươi cao nhất trước</option>
            <option value="freshness_asc" ${sortBy == 'freshness_asc' ? 'selected' : ''}>Sắp xếp: Độ tươi giảm dần</option>
        </select>
    </div>
</form>

<div class="table-container-card">
    <div class="overflow-x-auto">
        <table class="inventory-table">
            <thead>
                <tr>
                    <th class="min-w-[280px]">SẢN PHẨM & LÔ HÀNG</th>
                    <th class="min-w-[170px]">NGÀY HÁI TẠI VƯỜN</th>
                    <th class="min-w-[140px]">TỒN HIỆN TẠI</th>
                    <th class="min-w-[140px]">NGƯỠNG AN TOÀN</th>
                    <th class="min-w-[160px]">MỨC ĐỘ RỦI RO</th>
                    <th class="min-w-[140px]">ĐANG CHỜ ĐÓNG GÓI</th>
                    <th class="min-w-[150px] text-right">THAO TÁC NHANH</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${not empty listItems}">
                        <c:forEach var="item" items="${listItems}">
                            <tr>
                                <td>
                                    <div class="flex items-center gap-3">
                                        <div class="inv-thumb-wrapper">
                                            <img src="${item.image}" alt="${item.productName}" class="inv-thumb-img" onerror="this.src='https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=120&h=120&fit=crop';">
                                            <span class="inv-thumb-cert-badge">
                                                ${not empty item.certification ? item.certification : 'BIO'}
                                            </span>
                                        </div>
                                        <div class="flex flex-col min-w-0">
                                            <a href="${pageContext.request.contextPath}/shop/product/edit?id=${item.variantId}" class="inv-product-name truncate hover:text-emerald-700">
                                                ${item.productName}
                                            </a>
                                            <div class="inv-sku-row">
                                                <span class="font-mono text-slate-500 font-semibold">${item.sku}</span>
                                                <span class="text-slate-300">•</span>
                                                <span class="text-slate-500 font-medium">${item.categoryName}</span>
                                            </div>
                                            <div class="inv-lot-tag">
                                                <i class="fa-solid fa-qrcode text-[10px]"></i>
                                                <span>LÔ: ${item.lotCode} (${item.storageTemp})</span>
                                            </div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div class="flex flex-col">
                                        <span class="text-xs font-semibold text-slate-700">${item.harvestDate}</span>
                                        <span class="text-[11px] text-slate-400">Đã lưu kho: <strong class="text-slate-600">${item.daysInStock} ngày</strong></span>
                                        <div class="freshness-progress-bar">
                                            <div class="freshness-fill ${item.freshnessPercent > 70 ? 'bg-emerald-500' : (item.freshnessPercent > 40 ? 'bg-amber-500' : 'bg-red-500')}"
                                                 style="width: ${item.freshnessPercent}%"></div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div class="flex items-baseline gap-1">
                                        <span class="inv-stock-num ${item.stockQuantity <= item.minThreshold ? 'text-red-700' : 'text-slate-900'}">
                                            ${item.stockQuantity}
                                        </span>
                                        <span class="inv-unit-lbl">${item.unit}</span>
                                    </div>
                                    <span class="text-[10px] text-slate-400 font-medium">Khả dụng xuất bán</span>
                                </td>
                                <td>
                                    <div class="flex items-center gap-1.5">
                                        <span class="text-xs font-bold text-slate-700">${item.minThreshold}</span>
                                        <span class="text-[11px] text-slate-400">${item.unit}</span>
                                    </div>
                                    <span class="text-[10px] text-slate-400">Ngưỡng tự động</span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${item.riskLevel == 'CRITICAL'}">
                                            <span class="status-risk-pill critical">
                                                <i class="fa-solid fa-circle text-[6px]"></i>
                                                <span>CỰC KỲ NGUY CẤP</span>
                                            </span>
                                        </c:when>
                                        <c:when test="${item.riskLevel == 'WARNING'}">
                                            <span class="status-risk-pill warning">
                                                <i class="fa-solid fa-circle text-[6px]"></i>
                                                <span>CẢNH BÁO TỒN THẤP</span>
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-risk-pill safe">
                                                <i class="fa-solid fa-circle text-[6px]"></i>
                                                <span>AN TOÀN BẢO QUẢN</span>
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <span class="text-xs font-semibold text-slate-600">${item.reservedQuantity} ${item.unit}</span>
                                    <span class="text-[10px] text-slate-400 block">Đang giao / Đặt trước</span>
                                </td>
                                <td class="text-right">
                                    <div class="flex items-center justify-end gap-1.5">
                                        <c:choose>
                                            <c:when test="${item.riskLevel == 'CRITICAL'}">
                                                <button type="button" onclick="quickRestockItem(${item.variantId}, '${item.productName}', '${item.unit}')" class="btn-table-action">
                                                    <i class="fa-solid fa-plus text-xs"></i>
                                                    <span>Nhập kho</span>
                                                </button>
                                                <form action="${pageContext.request.contextPath}/shop/inventory" method="POST" class="inline">
                                                    <input type="hidden" name="action" value="toggle">
                                                    <input type="hidden" name="variantId" value="${item.variantId}">
                                                    <button type="submit" class="btn-table-icon" title="Ẩn tạm thời">
                                                        <i class="fa-regular fa-eye-slash text-xs"></i>
                                                    </button>
                                                </form>
                                            </c:when>
                                            <c:when test="${item.riskLevel == 'WARNING'}">
                                                <button type="button" onclick="quickDiscountItem(${item.variantId}, '${item.productName}')" class="btn-table-discount">
                                                    <i class="fa-solid fa-bolt text-xs"></i>
                                                    <span>Xả tươi -15%</span>
                                                </button>
                                                <a href="${pageContext.request.contextPath}/shop/product/edit?id=${item.variantId}" class="btn-table-icon" title="Chi tiết">
                                                    <i class="fa-regular fa-circle-question text-xs"></i>
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <button type="button" onclick="quickRestockItem(${item.variantId}, '${item.productName}', '${item.unit}')" class="btn-table-edit">
                                                    <i class="fa-solid fa-pen text-xs"></i>
                                                    <span>Cập nhật</span>
                                                </button>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="7" class="py-16 text-center text-slate-400">
                                <i class="fa-solid fa-boxes-stacked text-3xl mb-2 text-slate-300 block"></i>
                                <span class="text-sm font-semibold">Tất cả mặt hàng đang trong ngưỡng an toàn tuyệt đối.</span>
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>

    <div class="table-pagination-footer">
        <div class="text-xs text-slate-500">
            Hiển thị <strong class="text-slate-800">${not empty listItems ? listItems.size() : 0}</strong> trên <strong class="text-slate-800">${totalCount}</strong> mặt hàng nông sản • <span class="text-emerald-700 font-semibold">Tự động đồng bộ với cảm biến kho lạnh Đà Lạt</span>
        </div>

        <div class="flex items-center gap-1.5">
            <c:if test="${currentPage > 1}">
                <a href="${pageContext.request.contextPath}/shop/inventory?page=${currentPage - 1}&pageSize=${pageSize}&keyword=${param.keyword}&riskLevel=${param.riskLevel}&sortBy=${sortBy}&viewTab=${viewTab}" class="page-num-btn">
                    <i class="fa-solid fa-chevron-left text-[11px]"></i>
                </a>
            </c:if>

            <c:forEach begin="1" end="${totalPages > 0 ? totalPages : 1}" var="p">
                <a href="${pageContext.request.contextPath}/shop/inventory?page=${p}&pageSize=${pageSize}&keyword=${param.keyword}&riskLevel=${param.riskLevel}&sortBy=${sortBy}&viewTab=${viewTab}" class="page-num-btn ${p == currentPage ? 'active' : ''}">
                    ${p}
                </a>
            </c:forEach>

            <c:if test="${currentPage < totalPages}">
                <a href="${pageContext.request.contextPath}/shop/inventory?page=${currentPage + 1}&pageSize=${pageSize}&keyword=${param.keyword}&riskLevel=${param.riskLevel}&sortBy=${sortBy}&viewTab=${viewTab}" class="page-num-btn">
                    <i class="fa-solid fa-chevron-right text-[11px]"></i>
                </a>
            </c:if>
        </div>
    </div>
</div>

