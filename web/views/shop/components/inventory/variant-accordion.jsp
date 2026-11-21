<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- Danh Sách Biến Thể Gom Nhóm Nhiều Lô (HTML5 <details> Accordion thuần - 100% No-JS) -->
<section class="space-y-4" id="variantListContainer">
    <c:forEach var="entry" items="${variantBatchMap}">
        <c:set var="variantId" value="${entry.key}" />
        <c:set var="batches" value="${entry.value}" />
        <c:set var="firstBatch" value="${batches[0]}" />
        <c:set var="variantTotalStock" value="0" />
        <c:forEach var="b" items="${batches}">
            <c:set var="variantTotalStock" value="${variantTotalStock + b.currentQuantity}" />
        </c:forEach>

        <!-- Thẻ details bản địa của HTML5 tự động đóng/mở không cần 1 dòng JS -->
        <details class="variant-card group" open>
            <!-- Header Biến thể (thẻ summary) -->
            <summary class="p-4 bg-slate-50/70 border-b border-slate-200 flex flex-col sm:flex-row sm:items-center justify-between gap-4 cursor-pointer select-none list-none">
                <div class="flex items-center gap-3">
                    <span class="w-7 h-7 rounded-lg bg-white border border-slate-200 text-slate-500 flex items-center justify-center transition-transform group-open:rotate-0 -rotate-90">
                        <i class="fa-solid fa-chevron-down text-xs"></i>
                    </span>
                    <div class="w-11 h-11 rounded-xl bg-emerald-50 border border-slate-100 overflow-hidden shrink-0 flex items-center justify-center">
                        <c:choose>
                            <c:when test="${not empty firstBatch.imageUrl}">
                                <img src="${firstBatch.imageUrl}" alt="Product" class="w-full h-full object-cover">
                            </c:when>
                            <c:otherwise>
                                <i class="fa-solid fa-apple-whole text-emerald-600 text-lg"></i>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div>
                        <div class="flex items-center gap-2 flex-wrap">
                            <h3 class="font-extrabold text-sm text-slate-900">${firstBatch.productName}</h3>
                            <c:if test="${not empty firstBatch.variantName}">
                                <span class="px-2 py-0.5 rounded bg-emerald-100 text-emerald-800 text-[10px] font-bold">${firstBatch.variantName}</span>
                            </c:if>
                            <span class="px-2 py-0.5 rounded bg-slate-200/60 text-slate-600 text-[10px] font-mono font-bold">${firstBatch.sku}</span>
                        </div>
                        <div class="text-[11px] text-slate-500 font-medium mt-0.5 flex items-center gap-2">
                            <span class="font-bold text-slate-800">Tồn kho hiện tại: <span class="${variantTotalStock > 0 ? 'text-emerald-700' : 'text-slate-400'} font-black">${variantTotalStock}</span></span>
                            <span>•</span>
                            <c:choose>
                                <c:when test="${not empty batches and batches[0].batchId > 0}">
                                    <span>${batches.size()} lô hàng</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="px-2 py-0.5 rounded bg-amber-100 text-amber-800 font-bold text-[10px]">Chưa có lô hàng</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <div class="flex items-center gap-4 self-end sm:self-center">
                    <div class="flex items-center gap-1.5 pl-2 border-l border-slate-200">
                        <a href="${pageContext.request.contextPath}/shop/inventory/batches?action=restock&variantId=${variantId}" 
                           class="px-3 py-1.5 bg-emerald-50 text-emerald-700 hover:bg-emerald-100 rounded-lg text-xs font-bold transition-all flex items-center gap-1.5 text-decoration-none">
                            <i class="fa-solid fa-plus text-[10px]"></i>Nhập lô mới
                        </a>
                    </div>
                </div>
            </summary>

            <!-- Bảng chứa danh sách Lô con -->
            <div class="overflow-x-auto transition-all">
                <table class="w-full text-left text-xs min-w-[950px] table-fixed">
                    <thead>
                        <tr class="bg-slate-100/50 text-[10px] uppercase text-slate-400 font-extrabold border-b border-slate-100">
                            <th class="py-3 px-4 pl-6 w-[18%]">Mã Lô (Batch)</th>
                            <th class="py-3 px-4 w-[18%]">Hạn Sử Dụng (FEFO)</th>
                            <th class="py-3 px-4 text-center w-[14%]">Tồn Kho</th>
                            <th class="py-3 px-4 w-[14%]">Trạng Thái</th>
                            <th class="py-3 px-4 w-[14%]">Tình Trạng</th>
                            <th class="py-3 px-4 text-right pr-6 w-[22%]">Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 text-slate-700">
                        <c:choose>
                            <c:when test="${not empty batches and batches[0].batchId > 0}">
                                <c:forEach var="batch" items="${batches}">
                                    <tr class="hover:bg-slate-50/80 transition-colors">
                                        <td class="py-3.5 px-4 pl-6">
                                            <div class="flex items-center gap-2 truncate">
                                                <span class="font-mono font-bold text-slate-900">${batch.batchCode}</span>
                                            </div>
                                        </td>
                                        <td class="py-3.5 px-4 font-semibold">
                                            <div class="font-bold text-slate-900">${batch.expiryDate}</div>
                                            <div class="text-[10px] font-bold mt-0.5">
                                                <c:choose>
                                                    <c:when test="${batch.daysRemaining > 0}">
                                                        <span class="text-emerald-600">Còn ${batch.daysRemaining} ngày</span>
                                                    </c:when>
                                                    <c:when test="${batch.daysRemaining == 0}">
                                                        <span class="text-amber-600">Hôm nay hết hạn</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-rose-600">Quá hạn ${-batch.daysRemaining} ngày</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>
                                        <td class="py-3.5 px-4 text-center font-bold text-slate-900">
                                            ${batch.currentQuantity} / <span class="text-slate-400 font-normal">${batch.initialQuantity}</span>
                                        </td>

                                        <!-- CỘT TRẠNG THÁI -->
                                        <td class="py-3.5 px-4">
                                            <c:choose>
                                                <c:when test="${batch.status == 'ACTIVE'}">
                                                    <span class="px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200 text-[10px] font-bold inline-block">Đang bán</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="px-2.5 py-1 rounded-full bg-slate-100 text-slate-600 border border-slate-200 text-[10px] font-bold inline-block">Dừng bán</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- CỘT TÌNH TRẠNG -->
                                        <td class="py-3.5 px-4">
                                            <span class="px-2.5 py-1 rounded-full text-[10px] font-bold inline-block
                                                  <c:choose>
                                                      <c:when test="${batch.statusText == 'Quá hạn'}">bg-rose-50 text-rose-700 border border-rose-200</c:when>
                                                      <c:when test="${batch.statusText == 'Cận date'}">bg-amber-50 text-amber-700 border border-amber-200</c:when>
                                                      <c:otherwise>bg-emerald-50 text-emerald-700 border border-emerald-200</c:otherwise>
                                                  </c:choose>">
                                                ${batch.statusText}
                                            </span>
                                        </td>

                                        <!-- CỘT THAO TÁC (Thuần link <a> - 100% No-JS) -->
                                        <td class="py-3.5 px-4 text-right pr-6">
                                            <div class="flex items-center justify-end gap-1.5">
                                                <!-- 1. Nút Trừ hàng -->
                                                <a href="${pageContext.request.contextPath}/shop/inventory/batches?action=adjust&batchId=${batch.batchId}&variantId=${variantId}"
                                                   class="px-2.5 py-1 bg-amber-50 hover:bg-amber-100 text-amber-700 rounded-lg text-[11px] font-bold transition-all flex items-center gap-1 shadow-2xs text-decoration-none" title="Trừ số lượng hỏng / dập nát">
                                                    <i class="fa-solid fa-minus text-[10px]"></i> Trừ hàng
                                                </a>

                                                <c:if test="${batch.currentQuantity > 0}">
                                                    <!-- 2. Nút Hủy lô -->
                                                    <a href="${pageContext.request.contextPath}/shop/inventory/batches?action=dispose&batchId=${batch.batchId}&variantId=${batch.variantId != null ? batch.variantId : variantId}"
                                                       class="px-2.5 py-1 bg-rose-600 hover:bg-rose-700 text-white rounded-lg text-[11px] font-bold transition-all flex items-center gap-1 shadow-2xs text-decoration-none" title="Hủy toàn bộ lô hàng ngay lập tức">
                                                        <i class="fa-solid fa-ban text-[10px]"></i> Hủy lô
                                                    </a>
                                                </c:if>

                                                <!-- 3. Nút Lịch sử -->
                                                <c:url var="historyUrl" value="/shop/inventory/history">
                                                    <c:param name="variantId" value="${variantId}"/>
                                                    <c:param name="batchId" value="${batch.batchId}"/>
                                                    <c:param name="productName" value="${firstBatch.productName}"/>
                                                </c:url>
                                                <a href="${historyUrl}" class="px-2.5 py-1 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-lg text-[11px] font-bold transition-all flex items-center gap-1 shadow-2xs text-decoration-none">
                                                    <i class="fa-solid fa-clock text-[10px] text-slate-500"></i> Lịch sử
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="6" class="py-8 text-center text-slate-500 bg-slate-50/50">
                                        <div class="inline-flex flex-col items-center justify-center">
                                            <span class="w-10 h-10 rounded-full bg-amber-50 text-amber-600 flex items-center justify-center mb-2">
                                                <i class="fa-solid fa-boxes-stacked text-base"></i>
                                            </span>
                                            <p class="font-bold text-xs text-slate-700">Quy cách này chưa có lô hàng nào trong kho</p>
                                            <p class="text-[11px] text-slate-400 mt-0.5">Vui lòng nhập lô hàng đầu tiên (kèm hạn sử dụng) để bắt đầu mở bán.</p>
                                            <a href="${pageContext.request.contextPath}/shop/inventory/batches?action=restock&variantId=${variantId}" 
                                               class="mt-3 px-4 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-xs font-bold transition-all inline-flex items-center gap-1.5 text-decoration-none shadow-xs">
                                                <i class="fa-solid fa-plus text-[10px]"></i>Nhập lô hàng đầu tiên
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </details>
    </c:forEach>

    <c:if test="${empty variantBatchMap}">
        <div class="bg-white rounded-2xl border border-slate-200 p-12 text-center">
            <div class="w-12 h-12 mx-auto rounded-2xl bg-slate-50 text-slate-300 flex items-center justify-center mb-3">
                <i class="fa-solid fa-box-open text-xl"></i>
            </div>
            <p class="text-xs font-bold text-slate-600">Chưa có dữ liệu lô hàng nào trong kho</p>
        </div>
    </c:if>
</section>
