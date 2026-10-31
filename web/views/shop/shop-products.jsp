<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>Quản Lý Sản Phẩm Nông Sản - FreshFruit Kênh Người Bán</title>
        <jsp:include page="/views/shop/layout/head.jsp" />
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-products.css">
    </head>
    <body class="bg-[#f8fafc] text-[#0f172a]">

        <jsp:include page="/views/shop/layout/sidebar.jsp">
            <jsp:param name="active" value="products" />
        </jsp:include>
        <jsp:include page="/views/shop/layout/header.jsp" />

        <div class="shop-main-wrapper">
            <main class="shop-content-container">
                <div class="w-full max-w-7xl mx-auto space-y-6">

                    <c:if test="${not empty sessionScope.errorMessage}">
                        <div class="bg-rose-50 border border-rose-300 text-rose-900 px-4 py-3 rounded-2xl flex items-center justify-between shadow-2xs">
                            <div class="flex items-center gap-3">
                                <i class="fa-solid fa-circle-exclamation text-rose-600 text-base"></i>
                                <span class="text-xs font-bold">${sessionScope.errorMessage}</span>
                            </div>
                            <button type="button" onclick="this.parentElement.remove()" class="text-rose-500 hover:text-rose-900">
                                <i class="fa-solid fa-xmark text-sm"></i>
                            </button>
                        </div>
                        <c:remove var="errorMessage" scope="session"/>
                    </c:if>

                    <c:if test="${not empty sessionScope.successMessage}">
                        <div class="bg-emerald-50 border border-emerald-300 text-emerald-900 px-4 py-3 rounded-2xl flex items-center justify-between shadow-2xs">
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

                    <div class="flex flex-col gap-3">
                        <nav class="flex items-center gap-2 text-xs text-slate-400 font-semibold">
                            <span>Kênh Người Bán</span>
                            <i class="fa-solid fa-chevron-right text-[9px] text-slate-300"></i>
                            <span>Sản phẩm & Kho</span>
                            <i class="fa-solid fa-chevron-right text-[9px] text-slate-300"></i>
                            <span class="text-slate-800 font-bold">Tất cả sản phẩm</span>
                        </nav>

                        <div class="flex flex-col xl:flex-row xl:items-center justify-between gap-4">
                            <div>
                                <div class="flex items-center flex-wrap gap-3">
                                    <h1 class="text-2xl font-black text-slate-900 tracking-tight">Danh Sách Sản Phẩm Nông Sản</h1>
                                    <span class="inline-flex items-center gap-1.5 px-3 py-1 bg-emerald-100 text-emerald-800 text-xs font-extrabold rounded-full">
                                        <span class="w-2 h-2 rounded-full bg-emerald-600"></span>
                                        ${not empty totalProducts ? totalProducts : 0} SẢN PHẨM / ${not empty totalSkus ? totalSkus : 0} SKUS
                                    </span>
                                </div>
                                <p class="text-xs text-slate-500 font-medium mt-1">
                                    Hệ thống quản lý biến thể, định danh mã SKU, kiểm soát tồn kho và chứng nhận chất lượng VietGAP/OCOP.
                                </p>
                            </div>

                            <div class="flex items-center flex-wrap gap-2.5">
                                <button type="button" class="px-4 py-2 bg-white border border-slate-200 text-slate-700 hover:bg-slate-50 rounded-xl text-xs font-bold flex items-center gap-2 shadow-2xs transition-all" onclick="alert('Đang xuất dữ liệu danh sách nông sản ra file Excel (.xlsx)...');">
                                    <i class="fa-solid fa-file-excel text-emerald-600"></i>
                                    <span>Xuất Excel</span>
                                </button>
                                <button type="button" class="px-4 py-2 bg-white border border-slate-200 text-slate-700 hover:bg-slate-50 rounded-xl text-xs font-bold flex items-center gap-2 shadow-2xs transition-all" onclick="alert('Hệ thống đang đồng bộ bảng giá loạt...');">
                                    <i class="fa-solid fa-arrows-rotate text-purple-600"></i>
                                    <span>Đồng bộ giá loạt</span>
                                </button>
                                <a href="${pageContext.request.contextPath}/shop/product/add" class="px-4 py-2 bg-emerald-700 hover:bg-emerald-800 text-white rounded-xl text-xs font-bold flex items-center gap-2 shadow-sm transition-all">
                                    <i class="fa-solid fa-circle-plus text-sm"></i>
                                    <span>Thêm mới nông sản</span>
                                </a>
                            </div>
                        </div>
                    </div>

                    <jsp:include page="/views/shop/components/product/products-filter-bar.jsp" />

                    <div class="bg-white rounded-2xl border border-slate-200 shadow-2xs overflow-hidden">
                        <jsp:include page="/views/shop/components/product/products-table.jsp" />
                        <jsp:include page="/views/shop/components/product/products-pagination.jsp" />
                    </div>

                </div>
            </main>
        </div>

        <script src="${pageContext.request.contextPath}/assets/js/shop-products.js"></script>
    </body>
</html>
