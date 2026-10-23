<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản lý biến thể sản phẩm</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="min-h-screen bg-slate-100 text-slate-800 font-['Plus_Jakarta_Sans',sans-serif]">
    <main class="max-w-6xl mx-auto p-6 md:p-10">
        <a href="${pageContext.request.contextPath}/shop/products" class="inline-flex items-center gap-2 text-sm font-bold text-slate-600 hover:text-emerald-700 mb-6">
            <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách sản phẩm
        </a>

        <section class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
            <header class="p-6 border-b border-slate-200 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div>
                    <p class="text-xs font-bold uppercase tracking-wide text-emerald-700">Quản lý biến thể</p>
                    <h1 class="text-2xl font-extrabold text-slate-900 mt-1">${productSummary.name}</h1>
                    <p class="text-sm text-slate-500 mt-1">${variants.size()} biến thể</p>
                </div>
                <div class="flex items-center gap-2">
                    <a href="${pageContext.request.contextPath}/shop/product/variant/add?productId=${productSummary.id}" class="inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl bg-emerald-700 text-white font-bold text-sm hover:bg-emerald-800">
                        <i class="fa-solid fa-plus"></i> Thêm biến thể
                    </a>
                    <a href="${pageContext.request.contextPath}/detail?id=${productSummary.id}" class="inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl border border-slate-200 font-bold text-sm hover:border-emerald-500 hover:text-emerald-700">
                        <i class="fa-regular fa-eye"></i> Xem chi tiết sản phẩm
                    </a>
                </div>
            </header>

            <c:if test="${not empty successMessage}">
                <div class="mx-6 mt-5 rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm font-semibold text-emerald-800">${successMessage}</div>
            </c:if>

            <section class="mx-6 my-5 rounded-2xl border border-slate-200 bg-slate-50 overflow-hidden">
                <div class="flex items-center gap-4 p-5 bg-white border-b border-slate-200">
                    <img src="${productSummary.image}" alt="${productSummary.name}" class="w-14 h-14 rounded-xl object-cover border border-slate-200 shrink-0" onerror="this.src='https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=120&h=120&fit=crop';">
                    <div class="min-w-0">
                        <p class="text-[10px] font-extrabold uppercase tracking-wide text-emerald-700">Thông tin sản phẩm gốc</p>
                        <h2 class="mt-1 text-lg font-extrabold text-slate-900">${productSummary.name}</h2>
                        <p class="text-xs text-slate-500">Mã sản phẩm: #${productSummary.id}</p>
                    </div>
                </div>
                <div class="grid grid-cols-2 md:grid-cols-3 gap-x-6 gap-y-4 p-5 text-xs">
                    <div><p class="font-semibold text-slate-400">Danh mục</p><p class="mt-1 font-bold text-slate-800">${not empty productSummary.categoryName ? productSummary.categoryName : 'Chưa phân loại'}</p></div>
                    <div><p class="font-semibold text-slate-400">Xuất xứ</p><p class="mt-1 font-bold text-slate-800">${not empty productSummary.origin ? productSummary.origin : 'Chưa cập nhật'}</p></div>
                    <div><p class="font-semibold text-slate-400">Chứng nhận</p><p class="mt-1 font-bold text-slate-800">${not empty productSummary.certification ? productSummary.certification : 'Chưa cập nhật'}</p></div>
                    <div><p class="font-semibold text-slate-400">Bảo quản</p><p class="mt-1 font-bold text-slate-800">${not empty productSummary.storageTemp ? productSummary.storageTemp : 'Chưa cập nhật'}</p></div>
                    <div>
                        <p class="font-semibold text-slate-400">Khoảng giá hiện tại</p>
                        <p class="mt-1 font-bold text-emerald-800"><fmt:formatNumber value="${productSummary.price}" type="number" maxFractionDigits="0"/> – <fmt:formatNumber value="${productSummary.oldPrice}" type="number" maxFractionDigits="0"/> ₫</p>
                    </div>
                    <div><p class="font-semibold text-slate-400">Tổng tồn kho · Số biến thể</p><p class="mt-1 font-bold text-slate-800">${productSummary.stockQuantity} · ${productSummary.variantCount}</p></div>
                    <c:if test="${not empty productSummary.description}">
                        <div class="col-span-2 md:col-span-3"><p class="font-semibold text-slate-400">Mô tả</p><p class="mt-1 leading-relaxed text-slate-700 whitespace-pre-line">${productSummary.description}</p></div>
                    </c:if>
                </div>
            </section>

            <div class="overflow-x-auto">
                <table class="w-full text-left">
                    <thead class="bg-slate-50 text-[11px] uppercase tracking-wide text-slate-500">
                        <tr>
                            <th class="px-6 py-4">Tên biến thể</th>
                            <th class="px-6 py-4">SKU</th>
                            <th class="px-6 py-4">Đơn vị</th>
                            <th class="px-6 py-4">Giá</th>
                            <th class="px-6 py-4">Tồn kho</th>
                            <th class="px-6 py-4">Trạng thái</th>
                            <th class="px-6 py-4 text-right">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 text-sm">
                        <c:choose>
                            <c:when test="${not empty variants}">
                                <c:forEach var="variant" items="${variants}">
                                    <tr class="hover:bg-slate-50">
                                        <td class="px-6 py-4 font-bold text-slate-900">${variant.variantName}</td>
                                        <td class="px-6 py-4 font-mono text-xs text-slate-500">${variant.sku}</td>
                                        <td class="px-6 py-4">${variant.unit}</td>
                                        <td class="px-6 py-4">
                                            <div class="font-bold text-emerald-800"><fmt:formatNumber value="${variant.price}" type="number" maxFractionDigits="0"/> ₫</div>
                                            <div class="text-xs text-slate-400 line-through">
                                                <fmt:formatNumber value="${not empty variant.originalPrice ? variant.originalPrice : variant.price}" type="number" maxFractionDigits="0"/> ₫
                                            </div>
                                        </td>
                                        <td class="px-6 py-4">${variant.stockQuantity}</td>
                                        <td class="px-6 py-4">
                                            <c:choose>
                                                <c:when test="${variant.active}"><span class="px-2.5 py-1 rounded-full bg-emerald-100 text-emerald-800 text-xs font-bold">Đang bán</span></c:when>
                                                <c:otherwise><span class="px-2.5 py-1 rounded-full bg-slate-100 text-slate-600 text-xs font-bold">Ngưng bán</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="px-6 py-4">
                                            <div class="flex justify-end gap-2">
                                                <a href="${pageContext.request.contextPath}/shop/product/edit?id=${variant.variantId}" class="w-9 h-9 rounded-lg border border-slate-200 flex items-center justify-center hover:text-emerald-700" title="Sửa biến thể"><i class="fa-solid fa-pen"></i></a>
                                                <a href="${pageContext.request.contextPath}/shop/product/delete?id=${variant.variantId}" onclick="return confirm('Bạn có chắc muốn xóa biến thể này?');" class="w-9 h-9 rounded-lg border border-slate-200 flex items-center justify-center hover:text-rose-700" title="Xóa biến thể"><i class="fa-regular fa-trash-can"></i></a>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr><td colspan="7" class="px-6 py-16 text-center text-slate-500">Sản phẩm chưa có biến thể nào.</td></tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </section>
    </main>
</body>
</html>
