<%@page pageEncoding="UTF-8"%>
                <!-- ==================== MODAL CHỌN VOUCHER SÀN ==================== -->
                <dialog id="checkout-voucher-modal"
                        class="p-0 rounded-2xl w-[min(520px,calc(100%-24px))] shadow-2xl backdrop:bg-black/50 border border-gray-200">
                    <div class="bg-white rounded-2xl overflow-hidden">
                        <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between bg-gray-50/50">
                            <h3 class="font-bold text-base text-gray-900">Chọn Voucher Gốc Vườn</h3>
                            <button type="button" onclick="closeCheckoutVoucherModal()"
                                    class="w-8 h-8 rounded-full hover:bg-gray-200 flex items-center justify-center text-gray-400 hover:text-gray-700">
                                <span class="material-symbols-outlined text-[20px]">close</span>
                            </button>
                        </div>
                        <div class="p-6 max-h-[60vh] overflow-y-auto space-y-3">
                            <div class="flex gap-2">
                                <%-- Nhập mã thủ công được xử lý riêng với danh sách voucher. --%>
                                <input type="text" id="manual-coupon-input" placeholder="Nhập mã giảm giá..."
                                       class="flex-1 border rounded-xl px-3 py-2 text-xs uppercase outline-none focus:border-emerald-600">
                                <button type="button" onclick="applyManualCoupon()"
                                        class="px-4 py-2 bg-gray-900 text-white rounded-xl text-xs font-bold hover:bg-black">
                                    Áp dụng
                                </button>
                            </div>
                            <div class="pt-3 border-t border-gray-100 space-y-2.5">
                                <c:forEach var="c" items="${availableCoupons}">
                                    <div class="p-3.5 border border-emerald-200 bg-emerald-50/40 rounded-xl flex items-center justify-between gap-3 text-xs">
                                        <div>
                                            <div class="flex items-center gap-2">
                                                <strong class="text-sm font-bold text-[#00652c]"><c:out value="${c.code}"/></strong>
                                                <span class="px-1.5 py-0.5 rounded text-[10px] bg-emerald-100 text-[#00652c] font-semibold">Voucher Sàn</span>
                                            </div>
                                            <p class="text-gray-700 mt-1">
                                                <%-- Phần trăm hiển thị không có chữ số thập phân; số tiền dùng VND. --%>
                                                <c:choose>
                                                    <c:when test="${c.discountType eq 'PERCENTAGE'}">Giảm <fmt:formatNumber value="${c.discountValue}" maxFractionDigits="0"/>%</c:when>
                                                    <c:otherwise>Giảm <fmt:formatNumber value="${c.discountValue}" type="currency" currencyCode="VND" maxFractionDigits="0"/></c:otherwise>
                                                </c:choose>
                                                · Đơn từ <fmt:formatNumber value="${c.minOrderValue}" type="currency" currencyCode="VND" maxFractionDigits="0"/>
                                            </p>
                                        </div>
                                        <button type="button" onclick="applyCouponCode('<c:out value="${c.code}"/>')"
                                                class="px-3.5 py-1.5 bg-[#00652c] hover:bg-[#005323] text-white rounded-lg font-bold text-xs">
                                            Áp dụng
                                        </button>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                        <div class="px-6 py-3 border-t border-gray-100 bg-gray-50/50 flex justify-end">
                            <button type="button" onclick="closeCheckoutVoucherModal()"
                                    class="px-4 py-2 border rounded-xl text-xs font-semibold text-gray-700 hover:bg-gray-100">
                                Đóng
                            </button>
                        </div>
                    </div>
                </dialog>
