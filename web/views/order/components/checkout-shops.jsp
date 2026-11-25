<%@page pageEncoding="UTF-8"%>
                <!-- ==================== 3. DANH SÁCH SẢN PHẨM THEO TỪNG GIAN HÀNG (GIỐNG SHOPEE) ==================== -->
                <c:choose>
                    <c:when test="${not empty itemsByShop}">
                        <c:forEach var="shopEntry" items="${itemsByShop}">
                            <%-- Mỗi nhóm dùng khóa gian hàng để lấy sản phẩm, lời nhắn và đơn con tương ứng. --%>
                            <c:set var="shopItems" value="${shopEntry.value}"/>
                            <c:set var="shopNoteKey" value="shopNote_${shopEntry.key}"/>
                            <c:set var="shop" value="${shopItems[0].variant}"/>
                            <c:set var="currentSubOrder" value="${draftOrder.subOrdersByShop[shopEntry.key]}"/>

                            <section class="bg-white rounded-xl shadow-xs border border-gray-200/70 overflow-hidden">
                                <!-- Shop Header -->
                                <div class="px-6 py-3.5 border-b border-gray-100 flex items-center justify-between">
                                    <div class="flex items-center gap-2.5">
                                        <a href="${pageContext.request.contextPath}/store?id=${shopEntry.key}" class="flex items-center gap-2.5 group hover:opacity-85 transition-opacity">
                                            <span class="inline-flex items-center justify-center w-7 h-7 rounded-lg bg-emerald-50 text-[#00652c]">
                                                <span class="material-symbols-outlined text-[18px]">storefront</span>
                                            </span>
                                            <strong class="text-sm font-bold text-gray-900 group-hover:text-[#00652c] transition-colors">
                                                <c:out value="${not empty shop.shopName ? shop.shopName : 'Gian hàng nông sản'}"/>
                                            </strong>
                                        </a>
                                    </div>
                                    <span class="text-xs text-gray-400 font-medium"><c:out value="${shopItems.size()}"/> sản phẩm</span>
                                </div>

                                <!-- Shop Items List -->
                                <div class="divide-y divide-gray-100">
                                    <c:forEach var="item" items="${shopItems}">
                                        <div class="px-6 py-4 grid grid-cols-1 md:grid-cols-12 gap-4 items-center">
                                            <div class="md:col-span-6 flex items-center gap-3.5 min-w-0">
                                                <div class="w-16 h-16 rounded-xl overflow-hidden bg-gray-50 border border-gray-100 shrink-0">
                                                    <%-- Dùng ảnh sản phẩm nếu có, nếu không hiển thị biểu tượng thay thế. --%>
                                                    <c:choose>
                                                        <c:when test="${not empty item.variant.image}">
                                                            <img src="<c:out value='${item.variant.image}'/>" alt="<c:out value='${item.variant.productName}'/>" class="w-full h-full object-cover">
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="w-full h-full flex items-center justify-center text-gray-300">
                                                                <span class="material-symbols-outlined">image</span>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="min-w-0">
                                                    <h4 class="text-sm font-bold text-gray-900 line-clamp-2 leading-snug"><c:out value="${item.variant.productName}"/></h4>
                                                    <p class="text-xs text-gray-500 mt-1">Phân loại: <strong class="text-gray-700"><c:out value="${item.variant.variantName}"/><c:if test="${not empty item.variant.unit}">, <c:out value="${item.variant.unit}"/></c:if></strong></p>
                                                </div>
                                            </div>
                                            <div class="md:col-span-2 text-left md:text-center text-sm text-gray-700">
                                                <span class="md:hidden text-xs text-gray-400 mr-1">Đơn giá:</span>
                                                <%-- Giá hiển thị và các khoản tiền được định dạng bằng VND, không có phần thập phân. --%>
                                                <fmt:formatNumber value="${item.displayUnitPrice}" type="currency" currencyCode="VND" maxFractionDigits="0"/>
                                                <c:if test="${item.unitPriceReduced}">
                                                    <div class="text-[11px] text-gray-400 line-through"><fmt:formatNumber value="${item.variant.price}" type="currency" currencyCode="VND" maxFractionDigits="0"/></div>
                                                </c:if>
                                            </div>
                                            <div class="md:col-span-2 text-left md:text-center text-sm text-gray-700">
                                                <span class="md:hidden text-xs text-gray-400 mr-1">Số lượng:</span>
                                                <c:out value="${item.quantity}"/>
                                            </div>
                                            <div class="md:col-span-2 text-left md:text-right text-sm font-extrabold text-[#00652c]">
                                                <span class="md:hidden text-xs text-gray-400 mr-1">Thành tiền:</span>
                                                <fmt:formatNumber value="${item.subtotal}" type="currency" currencyCode="VND" maxFractionDigits="0"/>
                                                <c:if test="${item.onPromotion}">
                                                    <div class="text-[11px] font-semibold text-rose-600">KM: <c:out value="${item.promotion.badgeLabel}"/> · giảm <fmt:formatNumber value="${item.promotionDiscount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></div>
                                                </c:if>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>

                                <%-- Mỗi shop có mã giảm riêng; chiết khấu lấy từ draftOrder, không từ phép tính trên trình duyệt. --%>
                                <!-- Shop Voucher Row (Giống Shopee) -->
                                <c:set var="currentShopCode" value="${shopCouponCodes[shopEntry.key]}"/>

                                <div class="px-6 py-3 border-t border-dashed border-gray-200 flex flex-wrap items-center justify-between gap-3 text-xs bg-gray-50/40">
                                    <div class="flex items-center gap-2 text-gray-700 flex-wrap">
                                        <span class="material-symbols-outlined text-[18px] text-amber-600">confirmation_number</span>
                                        <span class="font-semibold">Voucher của Shop</span>
                                        <c:if test="${not empty currentShopCode and not empty currentSubOrder and currentSubOrder.shopDiscount gt 0}">
                                            <span class="bg-amber-50 text-amber-800 border border-amber-300 px-2.5 py-0.5 rounded-lg text-xs font-bold flex items-center gap-1">
                                                <span class="material-symbols-outlined text-[14px]">check_circle</span>
                                                <span>Mã: <c:out value="${currentShopCode}"/> (-<fmt:formatNumber value="${currentSubOrder.shopDiscount}" type="currency" currencyCode="VND" maxFractionDigits="0"/>)</span>
                                            </span>
                                        </c:if>
                                    </div>
                                    <div class="flex items-center gap-2">
                                        <c:choose>
                                            <c:when test="${not empty currentShopCode and not empty currentSubOrder and currentSubOrder.shopDiscount gt 0}">
                                                <button type="button" onclick="openShopVoucherModal('${shopEntry.key}', '<c:out value="${not empty shop.shopName ? shop.shopName : 'Gian hàng'}"/>', ${not empty currentSubOrder ? currentSubOrder.shopSubtotal : 0})" class="text-blue-600 hover:underline font-semibold cursor-pointer">
                                                    Thay Đổi
                                                </button>
                                                <button type="button" onclick="removeShopCoupon('${shopEntry.key}')" class="text-red-500 hover:underline font-semibold cursor-pointer">
                                                    Xóa
                                                </button>
                                            </c:when>
                                            <c:otherwise>
                                                <button type="button" onclick="openShopVoucherModal('${shopEntry.key}', '<c:out value="${not empty shop.shopName ? shop.shopName : 'Gian hàng'}"/>', ${not empty currentSubOrder ? currentSubOrder.shopSubtotal : 0})" class="text-blue-600 hover:underline font-semibold cursor-pointer">
                                                    Chọn Voucher
                                                </button>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>

                                <!-- Delivery & Note Row (Giống Shopee) -->
                                <div class="px-6 py-4 border-t border-gray-100 bg-gray-50/50 grid grid-cols-1 md:grid-cols-12 gap-4 items-center text-xs">
                                    <div class="md:col-span-5 flex items-center gap-2.5">
                                        <span class="text-gray-600 shrink-0 font-medium">Lời nhắn:</span>
                                        <input type="text" name="shopNote_${shopEntry.key}"
                                               value="<c:out value='${formDraft[shopNoteKey]}'/>"
                                               placeholder="Lưu ý cho Người bán..."
                                               class="flex-1 bg-white border border-gray-200 rounded-lg px-3 py-1.5 text-xs outline-none focus:border-emerald-600">
                                    </div>
                                    <div class="md:col-span-7 flex flex-col md:flex-row md:items-center justify-between gap-2 md:pl-6 border-l-0 md:border-l border-gray-200">
                                        <div>
                                            <div class="flex items-center gap-2 flex-wrap">
                                                <span class="text-gray-700 font-semibold">Phương thức vận chuyển:</span>
                                                <span class="font-bold text-gray-900">Giao hàng bảo quản chuỗi lạnh Fresh-Lock (2h - 4h)</span>
                                            </div>
                                            <div class="text-[11px] text-gray-400 mt-0.5">Được đồng kiểm độ tươi khi nhận hàng</div>
                                        </div>
                                        <div class="text-right shrink-0">
                                            <div class="text-[10px] text-gray-400">Phí vận chuyển</div>
                                            <strong class="text-sm font-bold text-gray-900">
                                                <fmt:formatNumber value="${not empty currentSubOrder ? currentSubOrder.shopShippingFee : 0}" type="currency" currencyCode="VND" maxFractionDigits="0"/>
                                            </strong>
                                        </div>
                                    </div>
                                </div>

                                <!-- Shop Cost Breakdown -->
                                <%-- Tổng gian hàng lấy từ đơn con khi có, nếu không dùng giá trị tạm tính dự phòng. --%>
                                <div class="px-6 py-4 border-t border-gray-100 bg-white flex justify-end">
                                    <div class="w-full sm:w-80 space-y-1.5 text-xs">
                                        <div class="flex justify-between gap-4 text-gray-500">
                                            <span>Tiền hàng (${shopItems.size()} sản phẩm)</span>
                                            <strong class="text-gray-800"><fmt:formatNumber value="${not empty currentSubOrder ? currentSubOrder.shopSubtotal : shopSubtotal}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong>
                                        </div>
                                        <div class="flex justify-between gap-4 text-gray-500">
                                            <span>Phí vận chuyển</span>
                                            <strong class="text-gray-800"><fmt:formatNumber value="${not empty currentSubOrder ? currentSubOrder.shopShippingFee : 0}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong>
                                        </div>
                                        <c:if test="${not empty currentSubOrder and currentSubOrder.shopDiscount gt 0}">
                                            <div class="flex justify-between gap-4 text-amber-700">
                                                <span>Voucher của Shop</span>
                                                <strong>-<fmt:formatNumber value="${currentSubOrder.shopDiscount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong>
                                            </div>
                                        </c:if>
                                        <div class="flex justify-between items-baseline gap-4 pt-2 mt-2 border-t border-dashed border-gray-200">
                                            <span class="text-sm font-bold text-gray-800">Tạm tính Shop</span>
                                            <strong class="text-lg text-[#00652c] font-extrabold">
                                                <fmt:formatNumber value="${not empty currentSubOrder ? currentSubOrder.shopTotal : shopSubtotal}" type="currency" currencyCode="VND" maxFractionDigits="0"/>
                                            </strong>
                                        </div>
                                    </div>
                                </div>
                            </section>
                        </c:forEach>
                    </c:when>
                </c:choose>
