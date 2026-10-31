<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Thêm Mới Sản Phẩm Nông Sản - FreshFruit Kênh Người Bán</title>
    <jsp:include page="/views/shop/layout/head.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-product-add.css">
</head>
<body class="bg-[#f8fafc] text-[#0f172a]">

    <jsp:include page="/views/shop/layout/sidebar.jsp">
        <jsp:param name="active" value="add" />
    </jsp:include>
    <jsp:include page="/views/shop/layout/header.jsp" />

    <main class="shop-main-wrapper">
        <div class="shop-content-container">

            <div class="flex flex-col gap-2 mb-5">
                <nav class="flex items-center gap-2 text-xs text-slate-500 font-medium">
                    <span>Kênh Người Bán</span>
                    <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                    <span>Sản phẩm & Kho</span>
                    <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                    <span class="text-emerald-700 font-semibold">Thêm mới nông sản</span>
                </nav>

                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mt-1">
                    <div>
                        <h1 class="text-2xl font-black text-slate-900 tracking-tight">Thêm Mới Sản Phẩm Nông Sản</h1>
                        <p class="text-xs text-slate-500 mt-0.5">Khai báo quy cách, nguồn gốc vườn hái và tiêu chuẩn kiểm định độ tươi ngon.</p>
                    </div>

                    <div class="flex items-center flex-wrap gap-3">
                        <span class="px-3 py-1.5 rounded-full bg-indigo-50 border border-indigo-200 text-indigo-700 font-semibold text-xs flex items-center gap-1.5">
                            <i class="fa-solid fa-shield-check text-indigo-600"></i>
                            Mẫu chuẩn hóa VietGAP / OCOP
                        </span>
                        <button type="button" onclick="submitForm('draft')" class="px-4 py-2 bg-white border border-slate-300 text-slate-700 hover:bg-slate-50 rounded-lg text-xs font-bold transition shadow-sm">
                            Lưu nháp
                        </button>
                        <button type="button" onclick="submitForm('publish')" class="px-5 py-2 bg-emerald-700 hover:bg-emerald-800 text-white rounded-lg text-xs font-bold transition shadow-sm flex items-center gap-2">
                            <i class="fa-solid fa-paper-plane text-xs"></i>
                            <span>Phát hành ngay lên sàn</span>
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

            <form id="addProductForm" action="${pageContext.request.contextPath}/shop/product/add" method="POST">
                <input type="hidden" name="action" id="formAction" value="publish">
                <input type="hidden" name="storageTemp" id="inputStorageTemp" value="Kho lạnh 2°C - 8°C">
                <input type="hidden" name="unit" id="inputUnit" value="Hộp (500g - 1kg)">

                <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">
                    <div class="lg:col-span-8 space-y-6">
                        <jsp:include page="/views/shop/components/product/product-add-general-card.jsp" />
                        <jsp:include page="/views/shop/components/product/product-add-pricing-card.jsp" />
                        <jsp:include page="/views/shop/components/product/product-shipping-card.jsp" />
                    </div>

                    <div class="lg:col-span-4 space-y-6">
                        <jsp:include page="/views/shop/components/product/product-images-card.jsp" />

                        <div class="form-section-card bg-white">
                            <button type="button" onclick="submitForm('publish')" class="btn-publish-main">
                                <i class="fa-solid fa-rocket text-sm"></i>
                                <span>Phát hành ngay lên sàn</span>
                            </button>
                            <a href="${pageContext.request.contextPath}/shop/products" class="btn-cancel-back">
                                <span>Hủy bỏ & Quay lại danh sách</span>
                            </a>
                            <div class="verification-notice-card">
                                <i class="fa-solid fa-shield-halved text-emerald-600 text-sm mt-0.5 shrink-0"></i>
                                <span>Sản phẩm mới sẽ được hệ thống kiểm duyệt thông tin mã số vùng trồng và tiêu chuẩn VietGAP tự động trong vòng <strong>15 phút</strong>.</span>
                            </div>
                        </div>
                    </div>
                </div>
            </form>

        </div>
    </main>

    <script src="${pageContext.request.contextPath}/assets/js/shop-product-form.js"></script>
</body>
</html>
