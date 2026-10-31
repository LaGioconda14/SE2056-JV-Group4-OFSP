<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<div class="overflow-x-auto">
    <table class="w-full text-left border-collapse">
        <thead>
            <tr class="bg-slate-50/75 border-b border-slate-200 text-[11px] font-black tracking-wider text-slate-500 uppercase">
                <th class="w-12 text-center py-3.5 px-4">
                    <input type="checkbox" id="selectAllCheckbox" class="w-4 h-4 rounded border-slate-300 text-emerald-600 focus:ring-emerald-500 cursor-pointer">
                </th>
                <th class="py-3.5 px-4 min-w-[280px]">SẢN PHẨM & PHÂN LOẠI</th>
                <th class="py-3.5 px-4 min-w-[170px]">QUY CÁCH ĐÓNG GÓI</th>
                <th class="py-3.5 px-4 min-w-[140px]">GIÁ BÁN LẺ</th>
                <th class="py-3.5 px-4 min-w-[190px]">TỒN KHO THỰC TẾ</th>
                <th class="py-3.5 px-4 min-w-[170px] text-right">CHỨNG NHẬN / THAO TÁC</th>
            </tr>
        </thead>
        <tbody class="divide-y divide-slate-100 text-xs">
            <c:choose>
                <c:when test="${not empty listVariants}">
                    <c:forEach var="v" items="${listVariants}">
                        <tr class="hover:bg-slate-50/80 transition-colors">
                            <td class="text-center py-4 px-4">
                                <input type="checkbox" name="selectedProductIds" value="${v.variantId}" class="product-row-checkbox w-4 h-4 rounded border-slate-300 text-emerald-600 focus:ring-emerald-500 cursor-pointer">
                            </td>

                            <td class="py-4 px-4">
                                <div class="flex items-center gap-3">
                                    <div class="w-14 h-14 rounded-xl border border-slate-200 overflow-hidden shrink-0 bg-slate-100 relative group">
                                        <img src="${v.image}" alt="${v.productName}" class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-300" onerror="this.src='https://images.unsplash.com/photo-1595246140625-573b715d11dc?w=100&h=100&fit=crop';">
                                        <span class="absolute bottom-1 right-1 px-1.5 py-0.2 bg-black/60 backdrop-blur-xs text-[9px] font-mono font-bold text-white rounded">
                                            ID:${v.variantId}
                                        </span>
                                    </div>
                                    <div class="flex flex-col min-w-0">
                                        <div class="flex items-center gap-2">
                                            <a href="${pageContext.request.contextPath}/shop/product/edit?id=${v.variantId}" class="font-extrabold text-slate-900 hover:text-emerald-700 text-sm truncate transition-colors">
                                                ${v.productName}
                                            </a>
                                            <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-extrabold ${v.active ? 'bg-emerald-50 text-emerald-700 border border-emerald-200' : 'bg-slate-100 text-slate-500 border border-slate-200'}">
                                                ${v.active ? 'Đang bán' : 'Tạm ẩn'}
                                            </span>
                                        </div>
                                        <div class="flex items-center gap-2 text-[11px] text-slate-500 mt-0.5">
                                            <span class="font-mono font-bold text-slate-700 bg-slate-100 px-1.5 py-0.5 rounded border border-slate-200/60">
                                                SKU: ${v.sku}
                                            </span>
                                            <span class="text-slate-300">•</span>
                                            <span class="text-slate-600 font-medium">Danh mục: ${v.categoryName}</span>
                                        </div>
                                        <div class="text-[11px] text-slate-400 mt-0.5 flex items-center gap-1.5">
                                            <i class="fa-solid fa-location-dot text-slate-400 text-[10px]"></i>
                                            <span class="truncate">${not empty v.origin ? v.origin : 'Mộc Châu, Sơn La'}</span>
                                        </div>
                                    </div>
                                </div>
                            </td>

                            <td class="py-4 px-4">
                                <div class="flex flex-col gap-1">
                                    <span class="font-bold text-slate-800 text-xs">
                                        ${v.unit}
                                    </span>
                                    <span class="text-[11px] text-slate-500 flex items-center gap-1">
                                        <i class="fa-solid fa-snowflake text-blue-500 text-[10px]"></i>
                                        <span>${not empty v.storageTemp ? v.storageTemp : 'Kho lạnh 2-8°C'}</span>
                                    </span>
                                </div>
                            </td>

                            <td class="py-4 px-4">
                                <div class="flex flex-col">
                                    <span class="font-black text-slate-900 text-sm">
                                        <fmt:formatNumber value="${v.price}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </span>
                                    <c:if test="${v.originalPrice > v.price}">
                                        <span class="text-[11px] text-slate-400 line-through">
                                            <fmt:formatNumber value="${v.originalPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                        </span>
                                    </c:if>
                                </div>
                            </td>

                            <td class="py-4 px-4">
                                <div class="flex flex-col gap-1.5 max-w-[170px]">
                                    <div class="flex items-center justify-between">
                                        <c:choose>
                                            <c:when test="${v.stockQuantity == 0}">
                                                <span class="text-xs font-black text-rose-600 flex items-center gap-1.5">
                                                    <i class="fa-solid fa-circle-xmark text-rose-500 text-xs"></i> Hết hàng
                                                </span>
                                            </c:when>
                                            <c:when test="${v.stockQuantity <= 10}">
                                                <span class="text-xs font-black text-amber-600 flex items-center gap-1.5">
                                                    <i class="fa-solid fa-triangle-exclamation text-amber-500 text-xs"></i> ${v.stockQuantity} ${v.unit}
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-xs font-black text-emerald-700 flex items-center gap-1.5">
                                                    <i class="fa-solid fa-circle-check text-emerald-600 text-xs"></i> ${v.stockQuantity} ${v.unit}
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                        <span class="text-[10px] text-slate-400 font-bold">
                                            ${v.stockStatusText}
                                        </span>
                                    </div>
                                    <div class="w-full bg-slate-100 h-2 rounded-full overflow-hidden border border-slate-200/50">
                                        <div class="h-full rounded-full ${v.stockBarColor}" style="width: ${v.stockProgressPercent}%;"></div>
                                    </div>
                                </div>
                            </td>

                            <td class="py-4 px-4 text-right">
                                <div class="flex items-center justify-end gap-2.5">
                                    <c:choose>
                                        <c:when test="${v.certification == 'VietGAP'}">
                                            <span class="px-2.5 py-1 rounded-lg bg-emerald-50 text-emerald-700 text-[10px] font-black border border-emerald-200 flex items-center gap-1">
                                                <i class="fa-solid fa-shield-check text-[10px]"></i> VietGAP
                                            </span>
                                        </c:when>
                                        <c:when test="${v.certification != null && v.certification.contains('OCOP')}">
                                            <span class="px-2.5 py-1 rounded-lg bg-amber-50 text-amber-700 text-[10px] font-black border border-amber-200 flex items-center gap-1">
                                                <i class="fa-solid fa-star text-[10px]"></i> ${v.certification}
                                            </span>
                                        </c:when>
                                        <c:when test="${v.certification == 'GlobalGAP'}">
                                            <span class="px-2.5 py-1 rounded-lg bg-blue-50 text-blue-700 text-[10px] font-black border border-blue-200 flex items-center gap-1">
                                                <i class="fa-solid fa-certificate text-[10px]"></i> GlobalGAP
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="px-2.5 py-1 rounded-lg bg-slate-100 text-slate-600 text-[10px] font-black border border-slate-200">
                                                ${not empty v.certification ? v.certification : 'Tiêu chuẩn'}
                                            </span>
                                        </c:otherwise>
                                    </c:choose>

                                    <div class="inline-flex items-center gap-1 bg-slate-50 p-1 rounded-xl border border-slate-200">
                                        <a href="${pageContext.request.contextPath}/shop/product/edit?id=${v.variantId}" class="w-7 h-7 rounded-lg bg-white border border-slate-200 text-slate-600 hover:text-emerald-700 hover:border-emerald-500 flex items-center justify-center transition-all shadow-2xs" title="Chỉnh sửa">
                                            <i class="fa-solid fa-pen text-[11px]"></i>
                                        </a>
                                        <a href="${pageContext.request.contextPath}/shop/product/variants?productId=${v.productId}" class="w-7 h-7 rounded-lg bg-white border border-slate-200 text-slate-600 hover:text-indigo-700 hover:border-indigo-500 flex items-center justify-center transition-all shadow-2xs" title="Quản lý biến thể">
                                            <i class="fa-solid fa-layer-group text-xs"></i>
                                        </a>
                                        <a href="${pageContext.request.contextPath}/shop/product/toggle?id=${v.variantId}" class="w-7 h-7 rounded-lg bg-white border border-slate-200 text-slate-600 hover:text-blue-700 hover:border-blue-500 flex items-center justify-center transition-all shadow-2xs" title="Ẩn / Hiện">
                                            <i class="fa-regular fa-eye text-[11px]"></i>
                                        </a>
                                        <a href="${pageContext.request.contextPath}/shop/product/delete?id=${v.variantId}" onclick="return confirm('Bạn có chắc chắn muốn xóa sản phẩm này?');" class="w-7 h-7 rounded-lg bg-white border border-slate-200 text-slate-600 hover:text-rose-700 hover:border-rose-500 flex items-center justify-center transition-all shadow-2xs" title="Xóa">
                                            <i class="fa-regular fa-trash-can text-[11px]"></i>
                                        </a>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <tr>
                        <td colspan="6" class="py-20 text-center text-slate-400">
                            <i class="fa-solid fa-basket-shopping text-4xl mb-3 text-slate-300 block"></i>
                            <span class="text-sm font-bold text-slate-600">Không tìm thấy nông sản nào phù hợp với bộ lọc.</span>
                        </td>
                    </tr>
                </c:otherwise>
            </c:choose>
        </tbody>
    </table>
</div>

