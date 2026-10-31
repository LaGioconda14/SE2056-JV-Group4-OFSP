<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chỉnh Sửa Nông Sản - FreshFruit Kênh Người Bán</title>
    <jsp:include page="/views/shop/layout/head.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-product-add.css">
</head>
<body class="bg-[#f8fafc] text-[#0f172a]">

    <jsp:include page="/views/shop/layout/sidebar.jsp">
        <jsp:param name="active" value="products" />
    </jsp:include>
    <jsp:include page="/views/shop/layout/header.jsp" />

    <main class="shop-main-wrapper">
        <div class="shop-content-container">

            <div class="flex flex-col gap-2 mb-5">
                <nav class="flex items-center gap-2 text-xs text-slate-500 font-medium">
                    <span>Kênh Người Bán</span>
                    <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                    <a href="${pageContext.request.contextPath}/shop/products" class="hover:text-emerald-700">Quản lý nông sản</a>
                    <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                    <span class="text-emerald-700 font-semibold">Chỉnh sửa nông sản #${product.productId}</span>
                </nav>

                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mt-1">
                    <div>
                        <div class="flex items-center gap-2.5">
                            <h1 class="text-2xl font-black text-slate-900 tracking-tight">Chỉnh Sửa Sản Phẩm Nông Sản</h1>
                            <span class="px-2.5 py-0.5 rounded-full text-[11px] font-mono font-bold bg-slate-100 text-slate-700 border border-slate-200">
                                SKU: ${product.sku}
                            </span>
                        </div>
                        <p class="text-xs text-slate-500 mt-0.5">Cập nhật thông tin chi tiết vườn hái, giá bán và lượng tồn kho sản phẩm.</p>
                    </div>

                    <div class="flex items-center flex-wrap gap-3">
                        <button type="button" onclick="submitEditForm('save_draft')" class="px-4 py-2 bg-white border border-slate-300 text-slate-700 hover:bg-slate-50 rounded-lg text-xs font-bold transition shadow-sm">
                            Lưu nháp / Tạm ẩn
                        </button>
                        <button type="button" onclick="submitEditForm('save_active')" class="px-5 py-2 bg-emerald-700 hover:bg-emerald-800 text-white rounded-lg text-xs font-bold transition shadow-sm flex items-center gap-2">
                            <i class="fa-solid fa-floppy-disk text-xs"></i>
                            <span>Lưu & Cập nhật ngay</span>
                        </button>
                    </div>
                </div>
            </div>

            <c:if test="${not empty errorMessage}">
                <div class="mb-5 bg-red-50 border border-red-200 text-red-800 px-4 py-3 rounded-xl flex items-center justify-between shadow-sm">
                    <div class="flex items-center gap-3">
                        <i class="fa-solid fa-circle-exclamation text-red-600 text-lg"></i>
                        <span class="text-sm font-semibold">${errorMessage}</span>
                    </div>
                    <button type="button" onclick="this.parentElement.remove()" class="text-red-500 hover:text-red-800">
                        <i class="fa-solid fa-xmark"></i>
                    </button>
                </div>
            </c:if>

            <form id="editProductForm" action="${pageContext.request.contextPath}/shop/product/edit" method="POST">
                <input type="hidden" name="variantId" value="${product.variantId}">
                <input type="hidden" name="productId" value="${product.productId}">
                <input type="hidden" name="storageTemp" id="inputStorageTemp" value="${not empty product.storageTemp ? product.storageTemp : 'Kho lạnh 2°C - 8°C'}">
                <input type="hidden" name="unit" id="inputUnit" value="${not empty product.unit ? product.unit : 'Hộp (500g - 1kg)'}">
                <input type="hidden" name="status" id="inputStatus" value="${product.active ? 'active' : 'hidden'}">

                <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">
                    <div class="lg:col-span-8 space-y-6">
                        <jsp:include page="/views/shop/components/product/product-edit-general-card.jsp" />
                        <jsp:include page="/views/shop/components/product/product-pricing-card.jsp" />
                    </div>

                    <div class="lg:col-span-4 space-y-6">
                        <jsp:include page="/views/shop/components/product/product-images-card.jsp" />
                        <jsp:include page="/views/shop/components/product/product-status-card.jsp" />
                    </div>
                </div>
            </form>

        </div>
    </main>

    <script src="${pageContext.request.contextPath}/assets/js/shop-product-form.js"></script>
</body>
</html>
