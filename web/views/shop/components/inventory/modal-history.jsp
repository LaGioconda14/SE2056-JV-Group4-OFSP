<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!-- 4. Modal Lịch Sử Biến Động Kho (Server-Rendered - 100% No-JS) -->
<c:if test="${isOpenHistoryModal == true or param.action eq 'history'}">
    <div id="modalHistory" class="fixed inset-0 bg-slate-900/50 backdrop-blur-xs flex items-center justify-center z-50 p-4">
        <!-- Bấm ra ngoài nền đen để đóng popup (thẻ <a> sạch, không cần JS) -->
        <a href="${pageContext.request.contextPath}/shop/inventory/batches" class="absolute inset-0 cursor-default" tabindex="-1" aria-label="Đóng popup"></a>

        <div class="bg-white rounded-3xl shadow-2xl w-full max-w-2xl overflow-hidden border border-slate-100 relative z-10">
            <div class="flex items-center justify-between px-6 py-4 border-b border-slate-100">
                <div>
                    <h3 class="text-base font-black text-slate-900">Lịch Sử Biến Động Kho</h3>
                    <div class="flex flex-wrap items-center gap-2 mt-1">
                        <span class="text-xs text-slate-600 font-bold">Sản phẩm: <c:out value="${currentProductName}" default="--"/></span>
                        <c:set var="displayVariantName" value="${not empty currentVariantName ? currentVariantName : (not empty transactionHistoryList ? transactionHistoryList[0].variantName : '')}"/>
                        <c:set var="displayBatchCode" value="${not empty currentBatchCode ? currentBatchCode : (not empty transactionHistoryList ? transactionHistoryList[0].batchCode : '')}"/>
                        <c:if test="${not empty displayVariantName}">
                            <span class="px-2 py-0.5 rounded-md bg-emerald-50 border border-emerald-200 text-emerald-700 text-[11px] font-bold">
                                Biến thể: <c:out value="${displayVariantName}"/>
                            </span>
                        </c:if>
                        <c:if test="${not empty displayBatchCode}">
                            <span class="px-2 py-0.5 rounded-md bg-slate-100 border border-slate-200 text-slate-700 text-[11px] font-mono font-bold">
                                Lô: <c:out value="${displayBatchCode}"/>
                            </span>
                        </c:if>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/shop/inventory/batches" class="w-8 h-8 rounded-xl text-slate-400 hover:bg-slate-100 flex items-center justify-center text-decoration-none">
                    <i class="fa-solid fa-xmark text-sm"></i>
                </a>
            </div>
            <div class="p-6 space-y-3 max-h-[60vh] overflow-y-auto">
                <c:choose>
                    <c:when test="${not empty transactionHistoryList}">
                        <c:forEach var="trans" items="${transactionHistoryList}">
                            <div class="flex items-center justify-between p-3.5 bg-slate-50 rounded-2xl border border-slate-100">
                                <div class="flex items-center gap-3">
                                    <span class="w-9 h-9 rounded-xl flex items-center justify-center font-bold shrink-0 ${trans.quantityChanged > 0 ? 'bg-emerald-100 text-emerald-700' : 'bg-rose-100 text-rose-700'}">
                                        <i class="fa-solid ${trans.quantityChanged > 0 ? 'fa-plus' : 'fa-minus'} text-xs"></i>
                                    </span>
                                    <div>
                                        <div class="text-xs font-bold text-slate-900">
                                            <c:choose>
                                                <c:when test="${trans.transactionType == 'SALE'}">
                                                    SALE <span class="text-[11px] font-semibold text-emerald-700">(Xuất bán đơn hàng)</span>
                                                </c:when>
                                                <c:when test="${trans.transactionType == 'RESTOCK' and not empty trans.reason and trans.reason.contains('Hoàn kho')}">
                                                    RESTOCK <span class="text-[11px] font-semibold text-amber-600">(Hoàn kho do hủy đơn)</span>
                                                </c:when>
                                                <c:when test="${trans.transactionType == 'RESTOCK'}">
                                                    RESTOCK <span class="text-[11px] font-semibold text-emerald-600">(Nhập kho lô mới)</span>
                                                </c:when>
                                                <c:otherwise>
                                                    ${trans.transactionType}
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="text-[10px] text-slate-400 mt-0.5">
                                            <fmt:formatDate value="${trans.createdAt}" pattern="dd/MM/yyyy HH:mm"/> |
                                            <c:choose>
                                                <c:when test="${trans.transactionType == 'SALE'}">
                                                    Khách đặt đơn: <span class="font-semibold text-slate-600">${trans.fullName}</span>
                                                </c:when>
                                                <c:when test="${not empty trans.reason and trans.reason.contains('Hoàn kho')}">
                                                    Hoàn từ đơn của khách: <span class="font-semibold text-slate-600">${trans.fullName}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    Thực hiện bởi Shop: <span class="font-semibold text-slate-600">${trans.fullName}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <c:if test="${not empty trans.reason}">
                                            <div class="text-[11px] text-slate-600 font-medium mt-0.5">${trans.reason}</div>
                                        </c:if>
                                        <div class="text-[11px] text-slate-500 mt-1">Tồn: <span class="font-semibold">${trans.previousStock}</span> → <span class="font-semibold">${trans.newStock}</span></div>
                                    </div>
                                </div>
                                <div class="text-right shrink-0 ml-3">
                                    <div class="text-xs font-black ${trans.quantityChanged > 0 ? 'text-emerald-600' : 'text-rose-600'}">
                                        ${trans.quantityChanged > 0 ? '+' : ''}${trans.quantityChanged} đơn vị
                                    </div>
                                    <c:if test="${not empty trans.estimatedLoss and trans.estimatedLoss > 0}">
                                        <c:choose>
                                            <c:when test="${trans.transactionType == 'SALE'}">
                                                <div class="text-[11px] font-bold text-emerald-700 mt-0.5">
                                                    Doanh thu: +<fmt:formatNumber value="${trans.estimatedLoss}" pattern="#,###"/> ₫
                                                </div>
                                            </c:when>
                                            <c:when test="${trans.transactionType == 'RESTOCK' and not empty trans.reason and trans.reason.contains('Hoàn kho')}">
                                                <div class="text-[11px] font-bold text-amber-600 mt-0.5">
                                                    Hoàn đơn: <fmt:formatNumber value="${trans.estimatedLoss}" pattern="#,###"/> ₫
                                                </div>
                                            </c:when>
                                            <c:when test="${trans.quantityChanged < 0}">
                                                <div class="text-[11px] font-bold text-rose-600 mt-0.5">
                                                    Thiệt hại: -<fmt:formatNumber value="${trans.estimatedLoss}" pattern="#,###"/> ₫
                                                </div>
                                            </c:when>
                                        </c:choose>
                                    </c:if>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-8 text-xs text-slate-400 font-medium">Chưa có lịch sử biến động kho cho lô này.</div>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="flex items-center justify-end px-6 py-4 border-t border-slate-100 bg-slate-50/50">
                <a href="${pageContext.request.contextPath}/shop/inventory/batches" class="px-5 py-2.5 bg-slate-200 hover:bg-slate-300 text-slate-700 rounded-xl text-xs font-bold text-decoration-none">
                    Đóng
                </a>
            </div>
        </div>
    </div>
</c:if>
