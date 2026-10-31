<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="flex items-center gap-2 overflow-x-auto pb-1 text-xs">
    <a href="${pageContext.request.contextPath}/shop/products?statusTab=all" 
       class="px-4 py-2 rounded-xl font-bold transition-all flex items-center gap-2 whitespace-nowrap shadow-2xs ${empty statusTab || statusTab == 'all' ? 'bg-emerald-700 text-white shadow-emerald-700/20' : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'}">
        <span>Tất cả nông sản</span>
        <span class="px-2 py-0.5 rounded-md text-[10px] ${empty statusTab || statusTab == 'all' ? 'bg-emerald-800 text-white' : 'bg-slate-100 text-slate-600'}">${not empty tabAllCount ? tabAllCount : 0}</span>
    </a>

    <a href="${pageContext.request.contextPath}/shop/products?statusTab=active" 
       class="px-4 py-2 rounded-xl font-bold transition-all flex items-center gap-2 whitespace-nowrap shadow-2xs ${statusTab == 'active' ? 'bg-emerald-700 text-white shadow-emerald-700/20' : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'}">
        <span>Đang mở bán</span>
        <span class="px-2 py-0.5 rounded-md text-[10px] ${statusTab == 'active' ? 'bg-emerald-800 text-white' : 'bg-slate-100 text-slate-600'}">${not empty tabActiveCount ? tabActiveCount : 0}</span>
    </a>

    <a href="${pageContext.request.contextPath}/shop/products?statusTab=vietgap" 
       class="px-4 py-2 rounded-xl font-bold transition-all flex items-center gap-2 whitespace-nowrap shadow-2xs ${statusTab == 'vietgap' ? 'bg-emerald-700 text-white shadow-emerald-700/20' : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'}">
        <span>Chờ duyệt VietGAP</span>
        <span class="px-2 py-0.5 rounded-md text-[10px] bg-orange-100 text-orange-700">${not empty tabVietgapCount ? tabVietgapCount : 0}</span>
    </a>

    <a href="${pageContext.request.contextPath}/shop/products?statusTab=hidden" 
       class="px-4 py-2 rounded-xl font-bold transition-all flex items-center gap-2 whitespace-nowrap shadow-2xs ${statusTab == 'hidden' ? 'bg-emerald-700 text-white shadow-emerald-700/20' : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'}">
        <span>Hết hàng / Tạm ẩn</span>
        <span class="px-2 py-0.5 rounded-md text-[10px] bg-rose-100 text-rose-700">${not empty tabHiddenCount ? tabHiddenCount : 0}</span>
    </a>

    <a href="${pageContext.request.contextPath}/shop/products?statusTab=warning" 
       class="px-4 py-2 rounded-xl font-bold transition-all flex items-center gap-2 whitespace-nowrap shadow-2xs ${statusTab == 'warning' ? 'bg-emerald-700 text-white shadow-emerald-700/20' : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'}">
        <span>Vi phạm / Cảnh báo</span>
        <span class="px-2 py-0.5 rounded-md text-[10px] bg-slate-100 text-slate-600">${not empty tabWarningCount ? tabWarningCount : 0}</span>
    </a>
</div>

<form action="${pageContext.request.contextPath}/shop/products" method="GET" class="bg-white p-5 rounded-2xl border border-slate-200 shadow-2xs space-y-4">
    <input type="hidden" name="statusTab" value="${statusTab}">

    <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-12 gap-3 items-center">
        <div class="xl:col-span-5 relative">
            <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
            <input type="text" name="keyword" value="${param.keyword}" placeholder="Tìm theo tên trái cây, mã SKU, mã lô nông sản..." class="w-full pl-9 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all">
        </div>

        <div class="xl:col-span-3">
            <select name="categoryId" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all cursor-pointer" onchange="this.form.submit()">
                <option value="">Tất cả danh mục quả</option>
                <c:forEach var="c" items="${categories}">
                    <option value="${c.categoryId}" ${param.categoryId == c.categoryId ? 'selected' : ''}>
                        ${c.categoryName}
                    </option>
                </c:forEach>
            </select>
        </div>

        <div class="xl:col-span-2">
            <select name="certification" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all cursor-pointer" onchange="this.form.submit()">
                <option value="">Chứng nhận: Tất cả</option>
                <option value="VietGAP" ${param.certification == 'VietGAP' ? 'selected' : ''}>VietGAP</option>
                <option value="OCOP" ${param.certification == 'OCOP' ? 'selected' : ''}>OCOP</option>
                <option value="GlobalGAP" ${param.certification == 'GlobalGAP' ? 'selected' : ''}>GlobalGAP</option>
                <option value="Organic" ${param.certification == 'Organic' ? 'selected' : ''}>Organic</option>
            </select>
        </div>

        <div class="xl:col-span-2">
            <select name="stockLevel" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all cursor-pointer" onchange="this.form.submit()">
                <option value="">Tồn kho: Tất cả</option>
                <option value="critical" ${param.stockLevel == 'critical' ? 'selected' : ''}>Tồn &lt; 5 đơn vị</option>
                <option value="low" ${param.stockLevel == 'low' ? 'selected' : ''}>Sắp hết (&lt;= 15)</option>
                <option value="stable" ${param.stockLevel == 'stable' ? 'selected' : ''}>Ổn định (16 - 40)</option>
                <option value="abundant" ${param.stockLevel == 'abundant' ? 'selected' : ''}>Dồi dào (&gt; 40)</option>
            </select>
        </div>
    </div>

    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pt-3 border-t border-slate-100 text-xs">
        <div class="flex items-center flex-wrap gap-2">
            <span class="font-black text-[10px] uppercase tracking-wider text-slate-400 mr-1">LỌC NHANH:</span>

            <a href="${pageContext.request.contextPath}/shop/products?stockLevel=critical" 
               class="px-3 py-1.5 rounded-xl border border-slate-200 font-semibold text-slate-600 hover:border-emerald-500 hover:text-emerald-700 flex items-center gap-1.5 transition-all ${param.stockLevel == 'critical' ? 'bg-emerald-50 border-emerald-500 text-emerald-800' : 'bg-slate-50'}">
                <span class="w-1.5 h-1.5 rounded-full bg-red-500"></span>
                <span>Nguy cấp (&lt; 5)</span>
            </a>

            <a href="${pageContext.request.contextPath}/shop/products?stockLevel=low" 
               class="px-3 py-1.5 rounded-xl border border-slate-200 font-semibold text-slate-600 hover:border-emerald-500 hover:text-emerald-700 flex items-center gap-1.5 transition-all ${param.stockLevel == 'low' ? 'bg-emerald-50 border-emerald-500 text-emerald-800' : 'bg-slate-50'}">
                <span class="w-1.5 h-1.5 rounded-full bg-orange-500"></span>
                <span>Sắp hết (&lt;= 15)</span>
            </a>

            <a href="${pageContext.request.contextPath}/shop/products?certification=VietGAP" 
               class="px-3 py-1.5 rounded-xl border border-slate-200 font-semibold text-slate-600 hover:border-emerald-500 hover:text-emerald-700 flex items-center gap-1.5 transition-all ${param.certification == 'VietGAP' ? 'bg-emerald-50 border-emerald-500 text-emerald-800' : 'bg-slate-50'}">
                <i class="fa-solid fa-leaf text-emerald-600 text-[11px]"></i>
                <span>Chuẩn VietGAP</span>
            </a>
        </div>

        <div class="flex items-center gap-2">
            <select name="sortBy" class="px-3 py-1.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 cursor-pointer" onchange="this.form.submit()">
                <option value="newest" ${param.sortBy == 'newest' ? 'selected' : ''}>Mới cập nhật</option>
                <option value="price_asc" ${param.sortBy == 'price_asc' ? 'selected' : ''}>Giá thấp đến cao</option>
                <option value="price_desc" ${param.sortBy == 'price_desc' ? 'selected' : ''}>Giá cao đến thấp</option>
                <option value="stock_asc" ${param.sortBy == 'stock_asc' ? 'selected' : ''}>Tồn ít nhất trước</option>
                <option value="stock_desc" ${param.sortBy == 'stock_desc' ? 'selected' : ''}>Tồn nhiều nhất trước</option>
            </select>

            <button type="submit" class="px-4 py-1.5 bg-slate-900 hover:bg-slate-800 text-white rounded-xl text-xs font-bold transition shadow-xs">
                Lọc kết quả
            </button>
        </div>
    </div>
</form>
