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
                    <p class="text-[11px] text-slate-500 font-medium mt-0.5">Sản phẩm: <c:out value="${currentProductName}" default="--"/></p>
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
                                        <div class="text-xs font-bold text-slate-900">${trans.transactionType}</div>
                                        <div class="text-[10px] text-slate-400 mt-0.5"><fmt:formatDate value="${trans.createdAt}" pattern="dd/MM/yyyy HH:mm"/> | Thực hiện: <span class="font-semibold text-slate-600">${trans.fullName}</span></div>
                                        <div class="text-[11px] text-slate-500 mt-1">Tồn: <span class="font-semibold">${trans.previousStock}</span> → <span class="font-semibold">${trans.newStock}</span></div>
                                    </div>
                                </div>
                                <span class="text-xs font-black ${trans.quantityChanged > 0 ? 'text-emerald-600' : 'text-rose-600'}">${trans.quantityChanged > 0 ? '+' : ''}${trans.quantityChanged} đơn vị</span>
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
