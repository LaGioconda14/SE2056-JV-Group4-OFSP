<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN" />
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>Tất cả sản phẩm - Kênh Người Bán FreshFruit</title>
        <jsp:include page="/views/shop/layout/head.jsp" />
    </head>
    <body class="bg-[#f8fafc] text-[#0f172a]">

        <!-- Sidebar chung của nhóm -->
        <jsp:include page="/views/shop/layout/sidebar.jsp">
            <jsp:param name="active" value="products" />
        </jsp:include>

        <!-- Header chung của nhóm -->
        <jsp:include page="/views/shop/layout/header.jsp">
            <jsp:param name="searchAction" value="${ctx}/shop/products" />
        </jsp:include>

        <main class="shop-main-wrapper">
            <div class="shop-content-container space-y-6">

                <!-- Success Notification Alert -->
                <c:if test="${not empty sessionScope.successMessage}">
                    <div class="bg-emerald-50 border border-emerald-300 text-emerald-900 px-4 py-3 rounded-2xl flex items-center justify-between shadow-xs animate-fade-in">
                        <div class="flex items-center gap-3">
                            <i class="fa-solid fa-circle-check text-emerald-600 text-base"></i>
                            <span class="text-xs font-bold">${sessionScope.successMessage}</span>
                        </div>
                        <button type="button" onclick="this.parentElement.remove()" class="text-emerald-500 hover:text-emerald-900">
                            <i class="fa-solid fa-xmark text-sm"></i>
                        </button>
                    </div>
                    <c:remove var="successMessage" scope="session"/>
                </c:if>

                <!-- Breadcrumb & Header Title -->
                <div class="flex flex-col gap-3">
                    <nav class="flex items-center gap-2 text-xs text-slate-500 font-medium">
                        <span>Kênh Người Bán</span>
                        <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                        <span>Sản phẩm & Kho</span>
                        <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                        <span class="text-slate-800 font-bold">Tất cả sản phẩm</span>
                    </nav>

                    <div class="flex flex-col xl:flex-row xl:items-center justify-between gap-4">
                        <div>
                            <div class="flex items-center flex-wrap gap-3">
                                <h1 class="text-2xl font-extrabold text-slate-900 tracking-tight">Danh sách sản phẩm nông sản</h1>
                                <span class="inline-flex items-center gap-1.5 px-3 py-1 bg-emerald-100 border border-emerald-200 text-emerald-800 text-xs font-extrabold rounded-full shadow-2xs">
                                    <span class="w-2 h-2 rounded-full bg-emerald-600 animate-pulse"></span>
                                    ${not empty totalProductsCount ? totalProductsCount : 0} SẢN PHẨM
                                </span>
                            </div>
                            <p class="text-xs text-slate-500 font-medium mt-1">
                                Quản lý tổng quan sản phẩm nông sản. Giá hiển thị là khoảng giá biến thể; tồn kho là tổng số lượng các phân loại.
                            </p>
                        </div>

                        <!-- Action buttons -->
                        <div class="flex items-center flex-wrap gap-2.5">
                            <a href="${ctx}/shop/product/add" class="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold flex items-center gap-2 shadow-sm shadow-emerald-600/30 transition-all">
                                <i class="fa-solid fa-circle-plus text-sm"></i>
                                <span>Thêm mới nông sản</span>
                            </a>
                        </div>
                    </div>
                </div>

                <!-- STATUS TABS -->
                <div class="flex items-center gap-2 overflow-x-auto pb-1 text-xs">
                    <a href="${ctx}/shop/products?statusTab=all"
                       class="px-4 py-2 rounded-xl font-bold transition-all flex items-center gap-2 whitespace-nowrap shadow-2xs ${empty statusTab || statusTab == 'all' ? 'bg-emerald-700 text-white shadow-emerald-700/20' : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'}">
                        <span>Tất cả</span>
                        <span class="px-2 py-0.5 rounded-md text-[10px] ${empty statusTab || statusTab == 'all' ? 'bg-emerald-800 text-white' : 'bg-slate-100 text-slate-600'}">${not empty tabAllProductCount ? tabAllProductCount : 0}</span>
                    </a>

                    <a href="${ctx}/shop/products?statusTab=active"
                       class="px-4 py-2 rounded-xl font-bold transition-all flex items-center gap-2 whitespace-nowrap shadow-2xs ${statusTab == 'active' ? 'bg-emerald-700 text-white shadow-emerald-700/20' : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'}">
                        <span>Đang mở bán</span>
                        <span class="px-2 py-0.5 rounded-md text-[10px] ${statusTab == 'active' ? 'bg-emerald-800 text-white' : 'bg-slate-100 text-slate-600'}">${not empty tabActiveProductCount ? tabActiveProductCount : 0}</span>
                    </a>

                    <a href="${ctx}/shop/products?statusTab=vietgap"
                       class="px-4 py-2 rounded-xl font-bold transition-all flex items-center gap-2 whitespace-nowrap shadow-2xs ${statusTab == 'vietgap' ? 'bg-emerald-700 text-white shadow-emerald-700/20' : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'}">
                        <span>Chờ duyệt VietGAP</span>
                        <span class="px-2 py-0.5 rounded-md text-[10px] bg-amber-100 text-amber-800 font-extrabold">${not empty tabVietgapProductCount ? tabVietgapProductCount : 0}</span>
                    </a>

                    <a href="${ctx}/shop/products?statusTab=hidden"
                       class="px-4 py-2 rounded-xl font-bold transition-all flex items-center gap-2 whitespace-nowrap shadow-2xs ${statusTab == 'hidden' ? 'bg-emerald-700 text-white shadow-emerald-700/20' : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'}">
                        <span>Hết hàng / Tạm ẩn</span>
                        <span class="px-2 py-0.5 rounded-md text-[10px] bg-rose-100 text-rose-700 font-extrabold">${not empty tabHiddenProductCount ? tabHiddenProductCount : 0}</span>
                    </a>

                    <a href="${ctx}/shop/products?statusTab=warning"
                       class="px-4 py-2 rounded-xl font-bold transition-all flex items-center gap-2 whitespace-nowrap shadow-2xs ${statusTab == 'warning' ? 'bg-emerald-700 text-white shadow-emerald-700/20' : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'}">
                        <span>Vi phạm / Cảnh báo</span>
                        <span class="px-2 py-0.5 rounded-md text-[10px] bg-slate-100 text-slate-600">${not empty tabWarningProductCount ? tabWarningProductCount : 0}</span>
                    </a>
                </div>

                <!-- SEARCH & FILTER TOOLBAR -->
                <form action="${ctx}/shop/product/search" method="GET" class="bg-white p-5 rounded-2xl border border-slate-200 shadow-2xs space-y-4">
                    <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-12 gap-3 items-center">
                        <div class="xl:col-span-5 relative">
                            <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
                            <input type="text" name="keyword" value="${param.keyword}" placeholder="Tìm theo tên nông sản, mã xuất xứ..." class="w-full pl-9 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium focus:outline-none focus:border-emerald-500 focus:bg-white transition-all">
                        </div>

                        <div class="xl:col-span-3">
                            <select name="categoryId" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-700 focus:outline-none focus:border-emerald-500 focus:bg-white transition-all cursor-pointer" onchange="this.form.submit()">
                                <option value="">Tất cả danh mục quả</option>
                                <c:forEach var="c" items="${categories}">
                                    <option value="${c.categoryId}" ${param.categoryId == c.categoryId ? 'selected' : ''}>${c.categoryName}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="xl:col-span-2">
                            <select name="certification" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-700 focus:outline-none focus:border-emerald-500 focus:bg-white transition-all cursor-pointer" onchange="this.form.submit()">
                                <option value="">Chứng nhận: Tất cả</option>
                                <c:forEach var="cert" items="${certifications}">
                                    <option value="${cert}" ${param.certification == cert ? 'selected' : ''}>${cert}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="xl:col-span-2">
                            <select name="stockLevel" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-700 focus:outline-none focus:border-emerald-500 focus:bg-white transition-all cursor-pointer" onchange="this.form.submit()">
                                <option value="">Tồn kho: Tất cả</option>
                                <option value="critical" ${param.stockLevel == 'critical' ? 'selected' : ''}>Tồn &lt; 5 đơn vị</option>
                                <option value="low" ${param.stockLevel == 'low' ? 'selected' : ''}>Sắp hết (&lt;= 15)</option>
                                <option value="stable" ${param.stockLevel == 'stable' ? 'selected' : ''}>Ổn định (16 - 40)</option>
                                <option value="abundant" ${param.stockLevel == 'abundant' ? 'selected' : ''}>Dồi dào (&gt; 40)</option>
                            </select>
                        </div>
                    </div>

                    <div class="flex items-center justify-between pt-2 border-t border-slate-100 text-xs">
                        <div class="text-slate-500 font-semibold">
                            Đang hiển thị: <span class="text-slate-900 font-extrabold">${not empty products ? products.size() : 0}</span> / tổng <span class="text-slate-900 font-extrabold">${not empty totalProductsCount ? totalProductsCount : (not empty products ? products.size() : 0)}</span> nông sản
                        </div>
                        <c:if test="${not empty param.keyword or not empty param.categoryId or not empty param.certification or not empty param.stockLevel}">
                            <a href="${ctx}/shop/products" class="text-emerald-600 font-bold hover:underline">
                                <i class="fa-solid fa-rotate-left mr-1"></i> Xóa bộ lọc
                            </a>
                        </c:if>
                    </div>
                </form>

                <!-- PRODUCT TABLE (Đã bỏ table-fixed để tự động giãn đủ không gian) -->
                <div class="bg-white rounded-2xl border border-slate-200 shadow-2xs overflow-x-auto">
                    <table class="w-full text-left border-collapse min-w-[1000px]">
                        <thead>
                            <tr class="bg-slate-50/80 border-b border-slate-200 text-[11px] font-black text-slate-500 uppercase tracking-wider">
                                <th class="py-3.5 px-5">SẢN PHẨM NÔNG SẢN</th>
                                <th class="py-3.5 px-3">KHOẢNG GIÁ</th>
                                <th class="py-3.5 px-3">TỔNG TỒN KHO</th>
                                <th class="py-3.5 px-3">TRẠNG THÁI</th>
                                <th class="py-3.5 px-3">CHỨNG NHẬN</th>
                                <th class="py-3.5 px-5 text-right">THAO TÁC</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100 text-xs">
                            <c:choose>
                                <c:when test="${not empty products}">
                                    <c:forEach var="product" items="${products}">
                                        <tr class="hover:bg-slate-50/80 transition-colors group">
                                            <!-- Cột Sản phẩm -->
                                            <td class="py-4 px-5">
                                                <div class="flex items-center gap-3">
                                                    <div class="relative w-11 h-11 rounded-xl overflow-hidden border border-slate-200 shrink-0 shadow-2xs group-hover:border-emerald-400 transition-all">
                                                        <img src="${product.image}" alt="${product.name}" class="w-full h-full object-cover" onerror="this.src='https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=120&h=120&fit=crop';">
                                                    </div>
                                                    <div>
                                                        <a href="${ctx}/detail?id=${product.id}" class="font-extrabold text-sm text-slate-900 hover:text-emerald-700 transition-colors block" title="${product.name}">
                                                            ${product.name}
                                                        </a>
                                                        <div class="flex items-center gap-1.5 mt-0.5 text-[11px] text-slate-500">
                                                            <span><i class="fa-solid fa-seedling text-[9px] mr-0.5 text-slate-400"></i>${not empty product.categoryName ? product.categoryName : 'Trái Cây Theo Mùa'}</span>
                                                            <c:if test="${not empty product.origin}">
                                                                <span class="text-slate-400"><i class="fa-solid fa-location-dot text-[9px] mr-0.5"></i>${product.origin}</span>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                </div>
                                            </td>

                                            <!-- Cột Khoảng giá -->
                                            <td class="py-4 px-3 align-middle">
                                                <c:choose>
                                                    <c:when test="${product.price > 0}">
                                                        <div class="flex flex-col">
                                                            <span class="font-black text-xs text-emerald-700 tracking-tight whitespace-nowrap">
                                                                <fmt:formatNumber value="${product.price}" type="number" maxFractionDigits="0"/> ₫
                                                                <c:if test="${product.oldPrice > product.price}">
                                                                    – <fmt:formatNumber value="${product.oldPrice}" type="number" maxFractionDigits="0"/> ₫
                                                                </c:if>
                                                            </span>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-[11px] font-semibold text-slate-400 italic">Chưa thiết lập giá</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <!-- Cột Tổng tồn kho -->
                                            <td class="py-4 px-3 align-middle">
                                                <div class="flex flex-col space-y-1 w-36">
                                                    <div class="flex items-center justify-between gap-1">
                                                        <span class="font-black text-[11px] text-slate-800">
                                                            ${product.stockQuantity}
                                                        </span>
                                                        <c:choose>
                                                            <c:when test="${product.stockQuantity < 5}">
                                                                <span class="text-[9px] font-black text-rose-600 bg-rose-50 px-1.5 py-0.5 rounded border border-rose-200">Cực thấp</span>
                                                            </c:when>
                                                            <c:when test="${product.stockQuantity <= 15}">
                                                                <span class="text-[9px] font-black text-amber-600 bg-amber-50 px-1.5 py-0.5 rounded border border-amber-200">Sắp hết</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-[9px] font-black text-emerald-600 bg-emerald-50 px-1.5 py-0.5 rounded border border-emerald-200">Dồi dào</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div class="w-full bg-slate-100 rounded-full h-1.5 overflow-hidden">
                                                        <c:choose>
                                                            <c:when test="${product.stockQuantity < 5}">
                                                                <div class="bg-rose-500 h-1.5 rounded-full" style="width: ${product.stockQuantity * 10}%"></div>
                                                            </c:when>
                                                            <c:when test="${product.stockQuantity <= 15}">
                                                                <div class="bg-amber-500 h-1.5 rounded-full" style="width: ${product.stockQuantity * 5}%"></div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="bg-emerald-500 h-1.5 rounded-full" style="width: ${product.stockQuantity > 100 ? 100 : product.stockQuantity}%"></div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </td>

                                            <!-- Cột Trạng thái -->
                                            <td class="py-4 px-3 align-middle whitespace-nowrap">
                                                <div class="flex flex-col items-start gap-1">
                                                    <c:choose>
                                                        <c:when test="${product.active && product.stockQuantity > 0}">
                                                            <span class="px-2.5 py-1 rounded-full bg-emerald-50 border border-emerald-200 text-emerald-700 text-[10px] font-extrabold flex items-center gap-1">
                                                                <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span> Đang mở bán
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${product.active}">
                                                            <span class="px-2.5 py-1 rounded-full bg-amber-50 border border-amber-200 text-amber-700 text-[10px] font-extrabold">Hết hàng</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="px-2.5 py-1 rounded-full bg-rose-50 border border-rose-200 text-rose-700 text-[10px] font-extrabold flex items-center gap-1">
                                                                <span class="w-1.5 h-1.5 rounded-full bg-rose-500"></span> Đã ẩn / Tạm ngưng
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <span class="text-[10px] text-slate-400 font-semibold pl-1">${product.variantCount} phân loại</span>
                                                </div>
                                            </td>

                                            <!-- Cột Chứng nhận -->
                                            <td class="py-4 px-3 align-middle whitespace-nowrap">
                                                <c:choose>
                                                    <c:when test="${product.certification == 'VietGAP'}">
                                                        <span class="inline-flex items-center px-2.5 py-1 rounded-lg bg-emerald-50 text-emerald-700 border border-emerald-300 text-[10px] font-black">
                                                            VietGAP
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${product.certification == 'OCOP'}">
                                                        <span class="inline-flex items-center px-2.5 py-1 rounded-lg bg-amber-50 text-amber-700 border border-amber-300 text-[10px] font-black">
                                                            OCOP 4★
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="inline-flex items-center px-2.5 py-1 rounded-lg bg-slate-100 text-slate-600 border border-slate-200 text-[10px] font-bold">
                                                            ${not empty product.certification ? product.certification : 'Tiêu chuẩn Sàn'}
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <!-- Cột Thao tác -->
                                            <td class="py-4 px-5 align-middle text-right whitespace-nowrap">
                                                <div class="inline-flex items-center gap-1 bg-slate-100/80 p-1 rounded-xl border border-slate-200/80 shadow-2xs">
                                                    <a href="${ctx}/shop/product/variants?productId=${product.id}" class="h-8 px-2 rounded-lg bg-white border border-slate-200 text-slate-600 hover:text-indigo-700 hover:border-indigo-300 flex flex-col items-center justify-center transition-all text-[9px] font-black leading-tight" title="Quản lý biến thể">
                                                        <span>Biến</span>
                                                        <span>thể</span>
                                                    </a>
                                                    <a href="${ctx}/shop/product/edit?productId=${product.id}" class="w-8 h-8 rounded-lg bg-white border border-slate-200 text-slate-600 hover:text-emerald-700 hover:border-emerald-300 flex items-center justify-center transition-all" title="Sửa">
                                                        <i class="fa-solid fa-pen-to-square text-[11px]"></i>
                                                    </a>
                                                    <a href="${ctx}/detail?id=${product.id}" class="w-8 h-8 rounded-lg bg-white border border-slate-200 text-slate-600 hover:text-blue-700 hover:border-blue-300 flex items-center justify-center transition-all" title="Xem">
                                                        <i class="fa-regular fa-eye text-[12px]"></i>
                                                    </a>
                                                    <a href="${ctx}/shop/product/delete?productId=${product.id}" onclick="return confirm('Bạn có chắc chắn muốn xóa sản phẩm nông sản này không?');" class="w-8 h-8 rounded-lg bg-white border border-slate-200 text-slate-600 hover:text-rose-700 hover:border-rose-300 flex items-center justify-center transition-all" title="Xóa">
                                                        <i class="fa-regular fa-trash-can text-[11px]"></i>
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="6" class="py-16 text-center bg-slate-50/50">
                                            <div class="flex flex-col items-center justify-center space-y-2">
                                                <div class="w-12 h-12 rounded-full bg-slate-100 flex items-center justify-center text-slate-400">
                                                    <i class="fa-solid fa-seedling text-xl"></i>
                                                </div>
                                                <p class="text-xs font-bold text-slate-600">Không tìm thấy nông sản nào phù hợp</p>
                                            </div>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>

                    <!-- Pagination Footer -->
                    <div class="px-6 py-4 bg-slate-50/80 border-t border-slate-200 flex flex-col sm:flex-row items-center justify-between gap-4">
                    </div>
                </div>

            </div>
        </main>

    </body>
</html>