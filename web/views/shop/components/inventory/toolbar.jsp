<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- Lọc & Tìm kiếm Server-Side (100% No-JS) -->
<section class="bg-white p-4 rounded-2xl border border-slate-200 shadow-sm">
    <form action="${pageContext.request.contextPath}/shop/inventory/batches" method="GET" class="flex flex-col lg:flex-row lg:items-center justify-between gap-3">
        <div class="relative w-full lg:max-w-md">
            <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs"></i>
            <input name="keyword" value="${param.keyword}" type="search" placeholder="Tìm tên trái cây, mã SKU, mã lô..." 
                   class="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium focus:outline-none focus:border-emerald-500">
        </div>
        <div class="flex items-center gap-2">
            <button type="submit" class="px-4 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold flex items-center gap-1.5 transition-colors shadow-xs">
                <i class="fa-solid fa-filter text-xs"></i>
                <span>Tìm kiếm / Lọc</span>
            </button>
            <c:if test="${not empty param.keyword}">
                <a href="${pageContext.request.contextPath}/shop/inventory/batches" class="w-10 h-10 rounded-xl text-slate-400 hover:text-rose-600 hover:bg-rose-50 border border-slate-200 flex items-center justify-center text-decoration-none transition-colors" title="Bỏ lọc">
                    <i class="fa-solid fa-xmark"></i>
                </a>
            </c:if>
        </div>
    </form>
</section>
