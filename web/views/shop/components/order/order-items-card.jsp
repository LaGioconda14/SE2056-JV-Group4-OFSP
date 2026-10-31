<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN" />

                        <div class="bg-white rounded-2xl border border-slate-200 p-6 shadow-xs">
                            <div class="flex items-center justify-between pb-4 border-b border-slate-100">
                                <div class="flex items-center gap-2.5">
                                    <div class="w-7 h-7 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center text-sm font-bold">
                                        <i class="fa-solid fa-bag-shopping"></i>
                                    </div>
                                    <div>
                                        <h2 class="text-base font-extrabold text-slate-900">Thông Tin Sản Phẩm Nông Sản (${not empty subOrder.items ? subOrder.items.size() : 0} món)</h2>
                                        <p class="text-[11px] text-slate-400">Được bảo chứng nguồn gốc và kiểm định chất lượng xuất xưởng</p>
                                    </div>
                                </div>
                            </div>

                            <div class="mt-4 overflow-x-auto">
                                <table class="w-full text-left text-xs">
                                    <thead>
                                        <tr class="text-slate-400 font-bold border-b border-slate-100 text-[11px]">
                                            <th class="pb-2.5 w-64">SẢN PHẨM</th>
                                            <th class="pb-2.5 text-center">ĐƠN VỊ</th>
                                            <th class="pb-2.5 text-center">SỐ LƯỢNG</th>
                                            <th class="pb-2.5 text-right">ĐƠN GIÁ</th>
                                            <th class="pb-2.5 text-right">THÀNH TIỀN</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-slate-100">
                                        <c:forEach items="${subOrder.items}" var="item">
                                            <tr>
                                                <td class="py-3.5">
                                                    <div class="flex items-center gap-3">
                                                        <c:choose>
                                                            <c:when test="${not empty item.imageUrl}">
                                                                <img src="${item.imageUrl}" alt="${item.productNameSnapshot}" class="w-14 h-14 rounded-xl object-cover border border-slate-100 shrink-0">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="w-14 h-14 rounded-xl bg-slate-100 border border-slate-200/60 flex items-center justify-center text-slate-400 shrink-0">
                                                                    <i class="fa-solid fa-image text-lg"></i>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <div>
                                                            <div class="flex items-center gap-2">
                                                                <span class="font-extrabold text-slate-900 text-xs">${item.productNameSnapshot}</span>
                                                                <c:if test="${not empty item.variantNameSnapshot}">
                                                                    <span class="px-1.5 py-0.5 rounded text-[9px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                                                                        ${item.variantNameSnapshot}
                                                                    </span>
                                                                </c:if>
                                                            </div>
                                                            <div class="text-[11px] text-slate-500 mt-0.5 flex flex-wrap items-center gap-2">
                                                                <span>SKU: <span class="font-mono text-slate-700">${item.skuSnapshot}</span></span>
                                                                <c:if test="${item.weightKg != null}">
                                                                    <span>• Trọng lượng: <b class="text-slate-700">${item.weightKg}kg/${item.unit}</b></span>
                                                                </c:if>
                                                                <span>• Tồn kho khả dụng: <span class="font-bold ${item.stockQuantity < 10 ? 'text-rose-600' : 'text-emerald-700'}">${item.stockQuantity} ${item.unit}</span></span>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="py-3.5 text-center font-medium text-slate-600">${item.unit}</td>
                                                <td class="py-3.5 text-center font-extrabold text-slate-900 text-sm">${item.quantity}</td>
                                                <td class="py-3.5 text-right font-medium text-slate-600">
                                                    <fmt:formatNumber value="${item.unitPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                </td>
                                                <td class="py-3.5 text-right font-extrabold text-slate-900">
                                                    <fmt:formatNumber value="${item.totalPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>

                            <div class="mt-4 pt-3 border-t border-slate-100 space-y-1.5 text-xs">
                                <div class="flex justify-between text-slate-600">
                                    <span>Tiền hàng (Tạm tính ${not empty subOrder.items ? subOrder.items.size() : 0} sản phẩm):</span>
                                    <span class="font-bold text-slate-800">
                                        <fmt:formatNumber value="${subOrder.shopSubtotal}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </span>
                                </div>
                                <div class="pt-3 border-t border-slate-100 flex items-baseline justify-between">
                                    <div>
                                        <c:choose>
                                            <c:when test="${subOrder.paymentStatus eq 'PAID' or (not empty subOrder.paymentMethod and !subOrder.paymentMethod.toUpperCase().contains('COD'))}">
                                                <div class="text-sm font-extrabold text-slate-900">Tổng Tiền Đã Thanh Toán</div>
                                                <div class="text-[11px] text-emerald-600 font-bold">
                                                    <i class="fa-solid fa-circle-check"></i> Đã thanh toán qua ${subOrder.paymentMethod} (Không thu COD)
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="text-sm font-extrabold text-slate-900">Tổng Thu Hộ COD</div>
                                                <div class="text-[11px] text-slate-400">Người mua thanh toán tiền mặt khi nhận hàng tươi</div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="text-2xl font-black text-emerald-700">
                                        <fmt:formatNumber value="${subOrder.shopTotal}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </div>
                                </div>
                            </div>
                        </div>
