<%@page pageEncoding="UTF-8"%>
                <%-- Phần chọn giao hàng, thanh toán và tổng kết đơn hàng. --%>
                <!-- ==================== 5. PHƯƠNG THỨC THANH TOÁN & TỔNG KẾT (GIỐNG SHOPEE) ==================== -->
                <div class="bg-white rounded-xl shadow-xs border border-gray-200/70 p-6 space-y-6">
                    <!-- Hàng chọn ngày & khung giờ giao hàng (Delivery Slot & Date) -->
                    <div class="pb-5 border-b border-gray-100 space-y-4">
                        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-2">
                            <div>
                                <strong class="text-base text-gray-900 font-bold flex items-center gap-2">
                                    <span class="material-symbols-outlined text-[#00652c] text-[22px]">schedule</span>
                                    <span>Thời gian nhận hàng chuỗi lạnh</span>
                                </strong>
                                <p class="text-xs text-gray-500 mt-0.5">Chọn ngày và khung giờ thuận tiện để shipper bảo quản và giao hoa quả lạnh tươi ngon nhất</p>
                            </div>
                        </div>

                        <!-- 1. Tabs chọn Ngày nhận hàng (4 ngày) -->
                        <div class="space-y-1.5">
                            <span class="text-xs font-semibold text-gray-700">1. Chọn ngày nhận hàng:</span>
                            <div class="flex flex-wrap gap-2" id="delivery-date-tabs">
                                <!-- Dynamic date tabs injected by JS -->
                            </div>
                        </div>

                        <!-- 2. Lưới khung giờ theo buổi (Sáng / Chiều / Tối) -->
                        <div class="space-y-2">
                            <span class="text-xs font-semibold text-gray-700">2. Chọn khung giờ giao:</span>
                            <div id="delivery-slots-grid" class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-2.5">
                                <!-- Dynamic slot cards injected by JS -->
                            </div>
                        </div>

                        <%-- Giữ ngày và khung giờ đã chọn trong bản nháp để gửi cùng biểu mẫu. --%>
                        <!-- Hidden fields to submit with form -->
                        <input type="hidden" name="deliveryDate" id="checkout-delivery-date"
                               value="<c:out value='${not empty formDraft.deliveryDate ? formDraft.deliveryDate : ""}'/>">
                        <input type="hidden" name="deliverySlot" id="checkout-delivery-slot"
                               value="<c:out value='${not empty formDraft.deliverySlot ? formDraft.deliverySlot : ""}'/>">
                    </div>

                    <%-- Khôi phục VNPAY từ bản nháp; mặc định chọn COD. --%>
                    <!-- Hàng chọn phương thức thanh toán -->
                    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-gray-100">
                        <strong class="text-base text-gray-900 font-bold">Phương thức thanh toán</strong>
                        <div class="flex flex-wrap items-center gap-3" id="payment-options-container">
                            <label
                                class="payment-method-pill px-4 py-2 rounded-xl border-2 border-[#00652c] bg-emerald-50/60 text-[#00652c] text-xs font-bold cursor-pointer transition select-none flex items-center gap-1.5">
                                <input type="radio" name="paymentMethod" value="COD"
                                       <c:if test="${formDraft.paymentMethod ne 'VNPAY'}">checked</c:if> class="hidden">
                                <span class="material-symbols-outlined text-[16px]">check</span>
                                <span>Thanh toán khi nhận hàng (COD)</span>
                            </label>
                            <label
                                class="payment-method-pill px-4 py-2 rounded-xl border border-gray-200 hover:border-gray-300 text-gray-700 text-xs font-medium cursor-pointer transition select-none flex items-center gap-1.5">
                                <input type="radio" name="paymentMethod" value="VNPAY"
                                       <c:if test="${formDraft.paymentMethod eq 'VNPAY'}">checked</c:if> class="hidden">
                                <span>VNPAY</span>
                            </label>
                        </div>
                    </div>

                    <%-- Tổng tiền hàng, phí giao và giảm giá được liệt kê theo từng shop khi có. --%>
                    <!-- Bảng tổng hợp chi phí (Căn phải giống Shopee) -->
                    <div class="flex flex-col items-end space-y-2.5 pt-3 text-sm">
                        <!-- 1. Tổng tiền hàng & chi tiết từng shop -->
                        <div class="flex justify-between w-full sm:w-96 text-gray-500">
                            <span>Tổng tiền hàng:</span>
                            <span class="font-semibold text-gray-900"><fmt:formatNumber value="${draftOrder.totalGoodsAmount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></span>
                        </div>
                        <c:forEach var="sub" items="${draftOrder.subOrders}">
                            <div class="flex justify-between w-full sm:w-96 text-xs text-gray-500 pl-3">
                                <span class="truncate pr-2">• <c:out value="${sub.shopName}"/>:</span>
                                <span class="font-medium text-gray-700 shrink-0"><fmt:formatNumber value="${sub.shopSubtotal}" type="currency" currencyCode="VND" maxFractionDigits="0"/></span>
                            </div>
                        </c:forEach>

                        <!-- 2. Tổng tiền phí vận chuyển -->
                        <div class="flex justify-between w-full sm:w-96 text-gray-500 pt-1">
                            <span>Tổng tiền phí vận chuyển:</span>
                            <span class="font-semibold text-gray-900"><fmt:formatNumber value="${draftOrder.totalShippingFee}" type="currency" currencyCode="VND" maxFractionDigits="0"/></span>
                        </div>
                        <c:forEach var="sub" items="${draftOrder.subOrders}">
                            <div class="flex justify-between w-full sm:w-96 text-xs text-blue-700 pl-3">
                                <span class="truncate pr-2">• Phí giao từ <c:out value="${sub.shopName}"/>:</span>
                                <span class="font-semibold shrink-0"><fmt:formatNumber value="${sub.shopShippingFee}" type="currency" currencyCode="VND" maxFractionDigits="0"/></span>
                            </div>
                        </c:forEach>

                        <%-- Chỉ hiển thị chi tiết giảm giá dương; không có giảm giá thì hiện 0 đ. --%>
                        <!-- 3. Tổng cộng giảm giá từ voucher -->
                        <c:choose>
                            <c:when test="${draftOrder.totalVoucherDiscount gt 0}">
                                <div class="flex justify-between w-full sm:w-96 text-amber-700 font-medium pt-1">
                                    <span>Tổng cộng giảm giá từ voucher:</span>
                                    <span class="font-bold text-amber-700">-<fmt:formatNumber value="${draftOrder.totalVoucherDiscount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></span>
                                </div>
                                <c:forEach var="sub" items="${draftOrder.subOrders}">
                                    <c:if test="${sub.shopDiscount gt 0}">
                                        <div class="flex justify-between w-full sm:w-96 text-xs text-amber-700 pl-3">
                                            <span class="truncate pr-2">• Giảm giá sản phẩm từ <c:out value="${sub.shopName}"/>:</span>
                                            <span class="font-semibold shrink-0">-<fmt:formatNumber value="${sub.shopDiscount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></span>
                                        </div>
                                    </c:if>
                                </c:forEach>
                                <c:if test="${draftOrder.platformDiscount gt 0}">
                                    <div class="flex justify-between w-full sm:w-96 text-xs text-rose-600 pl-3">
                                        <span class="truncate pr-2">• Voucher sàn Gốc Vườn:</span>
                                        <span class="font-semibold shrink-0">-<fmt:formatNumber value="${draftOrder.platformDiscount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></span>
                                    </div>
                                </c:if>
                            </c:when>
                            <c:otherwise>
                                <div class="flex justify-between w-full sm:w-96 text-gray-500 pt-1">
                                    <span>Tổng cộng giảm giá từ voucher:</span>
                                    <span class="font-semibold text-gray-900">0 đ</span>
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <%-- Số tiền cuối cùng của đơn, định dạng theo VND. --%>
                        <div class="flex justify-between items-baseline w-full sm:w-96 pt-3 border-t border-gray-100">
                            <span class="text-sm font-bold text-gray-900">Tổng thanh toán:</span>
                            <strong class="text-2xl sm:text-3xl font-extrabold text-[#00652c]">
                                <fmt:formatNumber value="${draftOrder.finalAmount}" type="currency" currencyCode="VND" maxFractionDigits="0"/>
                            </strong>
                        </div>
                    </div>

                    <%-- Nút đặt hàng POST /order/place; chọn VNPAY chỉ dẫn sang cổng thanh toán sau khi tạo đơn. --%>
                    <!-- Nút Hủy / Đặt Hàng -->
                    <div class="pt-6 border-t border-gray-100 flex flex-col-reverse sm:flex-row sm:justify-end gap-3">
                        <a href="<c:out value='${cartUrl}'/>"
                           class="w-full sm:w-56 py-3.5 border border-gray-300 hover:border-gray-400 hover:bg-gray-50 text-gray-700 font-extrabold rounded-xl text-base transition duration-200 active:scale-95 inline-flex items-center justify-center gap-2">
                            <span class="material-symbols-outlined text-[20px]">arrow_back</span>
                            Hủy, về giỏ hàng
                        </a>
                        <button type="submit" id="submit-order-btn"
                                class="w-full sm:w-56 py-3.5 bg-[#00652c] hover:bg-[#005323] text-white font-extrabold rounded-xl text-base shadow-md transition duration-200 active:scale-95 cursor-pointer">
                            Đặt hàng
                        </button>
                    </div>
                </div>
