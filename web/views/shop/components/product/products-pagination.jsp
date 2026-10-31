<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="px-6 py-4 bg-slate-50 border-t border-slate-200 flex flex-col sm:flex-row items-center justify-between gap-4">
    <div class="flex items-center gap-2 text-xs font-semibold text-slate-500">
        <span>Hiển thị</span>
        <select class="px-3 py-1.5 rounded-xl border border-slate-200 text-xs font-bold bg-white cursor-pointer focus:outline-none focus:border-emerald-500" onchange="location.href = '${pageContext.request.contextPath}/shop/products?page=1&pageSize=' + this.value;">
            <option value="10" ${pageSize == 10 ? 'selected' : ''}>10</option>
            <option value="20" ${pageSize == 20 ? 'selected' : ''}>20</option>
            <option value="50" ${pageSize == 50 ? 'selected' : ''}>50</option>
        </select>
        <span>trên tổng <strong class="text-slate-900">${not empty totalVariantsCount ? totalVariantsCount : (not empty listVariants ? listVariants.size() : 0)}</strong> nông sản</span>
    </div>

    <div class="flex items-center gap-1.5">
        <c:if test="${currentPage > 1}">
            <a href="${pageContext.request.contextPath}/shop/products?page=${currentPage - 1}&pageSize=${pageSize}&keyword=${param.keyword}&categoryId=${param.categoryId}&certification=${param.certification}&stockLevel=${param.stockLevel}&statusTab=${statusTab}" class="w-8 h-8 rounded-xl bg-white border border-slate-200 text-slate-600 font-bold flex items-center justify-center hover:bg-emerald-50 hover:border-emerald-500 hover:text-emerald-700 transition-all text-xs">
                <i class="fa-solid fa-chevron-left text-[10px]"></i>
            </a>
        </c:if>

        <c:forEach begin="1" end="${totalPages > 0 ? totalPages : 1}" var="p">
            <a href="${pageContext.request.contextPath}/shop/products?page=${p}&pageSize=${pageSize}&keyword=${param.keyword}&categoryId=${param.categoryId}&certification=${param.certification}&stockLevel=${param.stockLevel}&statusTab=${statusTab}" class="w-8 h-8 rounded-xl font-bold flex items-center justify-center transition-all text-xs ${p == currentPage ? 'bg-emerald-700 text-white shadow-sm shadow-emerald-700/20' : 'bg-white border border-slate-200 text-slate-600 hover:bg-slate-50'}">
                ${p}
            </a>
        </c:forEach>

        <c:if test="${currentPage < totalPages}">
            <a href="${pageContext.request.contextPath}/shop/products?page=${currentPage + 1}&pageSize=${pageSize}&keyword=${param.keyword}&categoryId=${param.categoryId}&certification=${param.certification}&stockLevel=${param.stockLevel}&statusTab=${statusTab}" class="w-8 h-8 rounded-xl bg-white border border-slate-200 text-slate-600 font-bold flex items-center justify-center hover:bg-emerald-50 hover:border-emerald-500 hover:text-emerald-700 transition-all text-xs">
                <i class="fa-solid fa-chevron-right text-[10px]"></i>
            </a>
        </c:if>
    </div>
</div>
