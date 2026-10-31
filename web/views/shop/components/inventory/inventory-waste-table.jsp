<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN" />

<!-- WASTE LOGS CARD & TABLE -->
<div class="bg-white rounded-2xl border border-slate-200/80 p-6 shadow-xs space-y-4">
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-4 border-b border-slate-100">
        <div class="flex items-center gap-2.5">
            <div class="w-9 h-9 rounded-xl bg-rose-50 text-rose-700 flex items-center justify-center text-base font-bold border border-rose-100">
                <i class="fa-solid fa-book-skull"></i>
            </div>
            <div>
                <h3 class="text-base font-extrabold text-slate-900">Nhật Ký Hàng Hỏng &amp; Tiêu Hủy Nông Sản</h3>
                <p class="text-[11px] text-slate-400">Theo dõi chi tiết quả hỏng khi QC hủy đơn, xe lạnh hoàn trả hoặc tiêu hủy định kỳ</p>
            </div>
        </div>

        <form action="${pageContext.request.contextPath}/shop/waste" method="GET" class="flex flex-wrap items-center gap-2 m-0">
            <select name="stage" onchange="this.form.submit()" class="p-2 text-xs rounded-xl border border-slate-200 bg-white focus:outline-none focus:border-emerald-600 font-medium">
                <option value="ALL" ${currentStage eq 'ALL' ? 'selected' : ''}>-- Tất cả giai đoạn --</option>
                <option value="QC_PACKING" ${currentStage eq 'QC_PACKING' ? 'selected' : ''}>Hỏng khi QC đóng gói (Shop hủy)</option>
                <option value="TRANSIT_DAMAGE" ${currentStage eq 'TRANSIT_DAMAGE' ? 'selected' : ''}>Hỏng do vận chuyển xe lạnh (Giao hoàn)</option>
                <option value="WAREHOUSE_EXPIRED" ${currentStage eq 'WAREHOUSE_EXPIRED' ? 'selected' : ''}>Tiêu hủy tồn kho định kỳ</option>
                <option value="CUSTOMER_DISPUTE" ${currentStage eq 'CUSTOMER_DISPUTE' ? 'selected' : ''}>Khách khiếu nại dập nát</option>
            </select>

            <div class="relative">
                <input type="text" name="keyword" value="${keyword}" placeholder="Tìm theo tên quả, SKU, mã đơn..." class="pl-8 pr-3 py-2 text-xs rounded-xl border border-slate-200 bg-white focus:outline-none focus:border-emerald-600 w-52">
                <i class="fa-solid fa-magnifying-glass absolute left-2.5 top-2.5 text-slate-400 text-xs"></i>
            </div>

            <button type="submit" class="px-3.5 py-2 rounded-xl bg-slate-900 hover:bg-slate-800 text-white font-bold text-xs transition cursor-pointer">
                Lọc
            </button>
            <c:if test="${not empty keyword or (not empty currentStage and currentStage ne 'ALL')}">
                <a href="${pageContext.request.contextPath}/shop/waste" class="px-3 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-600 font-semibold text-xs transition">
                    Xóa lọc
                </a>
            </c:if>
        </form>
    </div>

    <div class="overflow-x-auto">
        <table class="w-full text-left text-xs">
            <thead>
                <tr class="text-slate-400 font-bold border-b border-slate-100 text-[11px]">
                    <th class="pb-3 w-44">THỜI GIAN / MÃ</th>
                    <th class="pb-3">SẢN PHẨM &amp; PHÂN LOẠI</th>
                    <th class="pb-3">GIAI ĐOẠN HỎNG</th>
                    <th class="pb-3 text-center">SỐ LƯỢNG HỎNG</th>
                    <th class="pb-3 text-right">ĐƠN GIÁ</th>
                    <th class="pb-3 text-right">TỔNG THIỆT HẠI</th>
                    <th class="pb-3 pl-4">LÝ DO TIÊU HỦY</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
                <c:choose>
                    <c:when test="${not empty wasteLogs}">
                        <c:forEach items="${wasteLogs}" var="log">
                            <tr class="hover:bg-slate-50/60 transition">
                                <td class="py-3.5">
                                    <div class="font-extrabold text-slate-800">#WH-${log.wasteId}</div>
                                    <div class="text-[11px] text-slate-400 mt-0.5">
                                        <fmt:formatDate value="${log.createdAt}" pattern="HH:mm dd/MM/yyyy" />
                                    </div>
                                    <c:if test="${not empty log.subOrderCode}">
                                        <a href="${pageContext.request.contextPath}/shop/order-detail?code=${log.subOrderCode}" class="inline-flex items-center gap-1 text-[10px] text-emerald-700 font-bold hover:underline mt-0.5">
                                            <i class="fa-solid fa-receipt text-[9px]"></i>
                                            <span>Đơn: #${log.subOrderCode}</span>
                                        </a>
                                    </c:if>
                                </td>
                                <td class="py-3.5">
                                    <div class="font-bold text-slate-900">${log.productName}</div>
                                    <div class="text-[11px] text-slate-500 mt-0.5">
                                        <span>${log.variantName}</span>
                                        <span class="text-slate-300 mx-1">•</span>
                                        <span class="font-mono text-slate-400 font-semibold">${log.sku}</span>
                                    </div>
                                </td>
                                <td class="py-3.5">
                                    <c:choose>
                                        <c:when test="${log.wasteStage eq 'QC_PACKING'}">
                                            <span class="badge-qc-packing px-2.5 py-1 rounded-md text-[10px] font-bold inline-flex items-center">
                                                <i class="fa-solid fa-box-open mr-1"></i> QC Đóng gói (Shop hủy)
                                            </span>
                                        </c:when>
                                        <c:when test="${log.wasteStage eq 'TRANSIT_DAMAGE'}">
                                            <span class="badge-transit-damage px-2.5 py-1 rounded-md text-[10px] font-bold inline-flex items-center">
                                                <i class="fa-solid fa-truck-fast mr-1"></i> Xe lạnh / Giao hoàn
                                            </span>
                                        </c:when>
                                        <c:when test="${log.wasteStage eq 'WAREHOUSE_EXPIRED'}">
                                            <span class="badge-warehouse-expired px-2.5 py-1 rounded-md text-[10px] font-bold inline-flex items-center">
                                                <i class="fa-solid fa-warehouse mr-1"></i> Hỏng tồn kho
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-customer-dispute px-2.5 py-1 rounded-md text-[10px] font-bold inline-flex items-center">
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
                                    <div class="text-slate-800 text-xs font-semibold leading-relaxed max-w-xs" title="${log.reasonNote}">
                                        ${log.reasonNote}
                                    </div>
                                    <c:if test="${not empty log.loggedByName}">
                                        <div class="text-[10px] text-slate-400 mt-0.5">Ghi nhận: ${log.loggedByName}</div>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="7" class="py-14 text-center text-slate-400">
                                <div class="w-12 h-12 rounded-2xl bg-emerald-50 text-emerald-600 flex items-center justify-center mx-auto mb-2 text-xl border border-emerald-100">
                                    <i class="fa-solid fa-shield-heart"></i>
                                </div>
                                <div class="font-bold text-xs text-slate-700">Chưa ghi nhận bản ghi hàng hỏng nào</div>
                                <div class="text-[11px] text-slate-400 mt-0.5">Kho hàng nông sản của gian hàng đang được kiểm soát chất lượng rất tốt</div>
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
                Trang <span class="font-bold text-slate-800">${currentPage}</span> / <span class="font-bold text-slate-800">${totalPages}</span> (Tổng <strong class="text-slate-800">${totalItems}</strong> sự cố hao hụt)
            </div>
            <div class="flex items-center gap-1">
                <c:if test="${currentPage > 1}">
                    <a href="${pageContext.request.contextPath}/shop/waste?stage=${currentStage}&keyword=${keyword}&page=${currentPage - 1}" class="px-3 py-1.5 rounded-lg border border-slate-200 hover:bg-slate-50 font-bold transition">Trước</a>
                </c:if>
                <c:forEach begin="1" end="${totalPages}" var="i">
                    <a href="${pageContext.request.contextPath}/shop/waste?stage=${currentStage}&keyword=${keyword}&page=${i}" class="px-3 py-1.5 rounded-lg border ${i eq currentPage ? 'bg-emerald-700 text-white border-emerald-700' : 'border-slate-200 hover:bg-slate-50 text-slate-700'} font-bold transition">
                        ${i}
                    </a>
                </c:forEach>
                <c:if test="${currentPage < totalPages}">
                    <a href="${pageContext.request.contextPath}/shop/waste?stage=${currentStage}&keyword=${keyword}&page=${currentPage + 1}" class="px-3 py-1.5 rounded-lg border border-slate-200 hover:bg-slate-50 font-bold transition">Sau</a>
                </c:if>
            </div>
        </div>
    </c:if>
</div>

