<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<div class="bg-white rounded-2xl border border-red-200/80 shadow-xs overflow-hidden mt-6">
    <div class="p-4 bg-red-50/50 border-b border-red-100 flex items-center justify-between">
        <div class="flex items-center gap-2.5">
            <div class="w-8 h-8 rounded-xl bg-red-100 text-red-600 flex items-center justify-center text-xs font-black">
                <i class="fa-solid fa-bell"></i>
            </div>
            <div>
                <h3 class="text-xs font-black text-slate-900 uppercase tracking-wider">Danh Sách Sản Phẩm Cần Nhập Kho Gấp</h3>
                <p class="text-[11px] text-slate-500">Các mặt hàng có số lượng dưới mức tối thiểu cần thu hoạch bổ sung</p>
            </div>
        </div>
        <span class="px-2.5 py-1 bg-red-100 text-red-700 text-[11px] font-black rounded-lg">
            ${criticalStockCount} MẶT HÀNG
        </span>
    </div>

    <div class="overflow-x-auto">
        <table class="w-full text-left text-xs">
            <thead class="bg-slate-50 border-b border-slate-100 text-[10px] uppercase font-black tracking-wider text-slate-500">
                <tr>
                    <th class="py-3 px-4">Sản phẩm</th>
                    <th class="py-3 px-4">Mã SKU</th>
                    <th class="py-3 px-4 text-center">Tồn kho hiện tại</th>
                    <th class="py-3 px-4 text-center">Ngưỡng tối thiểu</th>
                    <th class="py-3 px-4 text-center">Tình trạng</th>
                    <th class="py-3 px-4 text-right">Thao tác nhanh</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
                <c:set var="hasAlert" value="false" />
                <c:forEach var="item" items="${listItems}">
                    <c:if test="${item.currentQuantity <= 5}">
                        <c:set var="hasAlert" value="true" />
                        <tr class="hover:bg-red-50/20 transition">
                            <td class="py-3 px-4 font-bold text-slate-900 flex items-center gap-2">
                                <img src="${not empty item.image ? item.image : 'https://images.unsplash.com/photo-1543528176-61b239494933?w=100'}" class="w-8 h-8 rounded-lg object-cover border border-slate-200">
                                <span>${item.productName}</span>
                            </td>
                            <td class="py-3 px-4 font-mono font-bold text-slate-600">${item.sku}</td>
                            <td class="py-3 px-4 text-center">
                                <span class="px-2 py-0.5 rounded-full bg-red-100 text-red-700 font-black text-xs">
                                    ${item.currentQuantity} ${item.unit}
                                </span>
                            </td>
                            <td class="py-3 px-4 text-center font-bold text-slate-500">5 ${item.unit}</td>
                            <td class="py-3 px-4 text-center">
                                <c:choose>
                                    <c:when test="${item.currentQuantity == 0}">
                                        <span class="text-red-700 font-black text-[11px]">HẾT HÀNG</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-orange-600 font-bold text-[11px]">SẮP HẾT</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="py-3 px-4 text-right">
                                <button type="button" onclick="quickRestockItem('${item.variantId}', '${item.productName}', '${item.unit}')" class="px-3 py-1.5 bg-[#166534] text-white rounded-lg font-bold text-[11px] hover:bg-[#14532d] shadow-sm transition">
                                    <i class="fa-solid fa-plus text-[10px] mr-1"></i> Nhập hàng
                                </button>
                            </td>
                        </tr>
                    </c:if>
                </c:forEach>
                <c:if test="${!hasAlert}">
                    <tr>
                        <td colspan="6" class="py-8 text-center text-slate-400">
                            <i class="fa-solid fa-circle-check text-emerald-500 text-2xl mb-2 block"></i>
                            Tất cả mặt hàng đều duy trì mức tồn kho an toàn!
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>
