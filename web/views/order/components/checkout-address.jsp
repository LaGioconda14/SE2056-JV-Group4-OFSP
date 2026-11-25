<%@page pageEncoding="UTF-8"%>
                <!-- ==================== 1. KHỐI ĐỊA CHỈ NHẬN HÀNG (GIỐNG SHOPEE) ==================== -->
                <div class="bg-white rounded-xl shadow-xs overflow-hidden border border-gray-200/70">
                    <div class="shopee-border-stripe"></div>
                    <div class="p-6">
                        <div class="flex items-center justify-between gap-4 mb-3">
                            <div class="flex items-center gap-2 text-[#00652c] font-bold text-base">
                                <span class="material-symbols-outlined text-[22px]">location_on</span>
                                <span>Địa Chỉ Nhận Hàng</span>
                            </div>
                            <button type="button" onclick="openAddressModal()" class="text-xs font-bold text-blue-600 hover:underline cursor-pointer">
                                Thay Đổi
                            </button>
                        </div>

                        <!-- Active Selected Address Display -->
                        <div id="active-address-display">
                            <%-- Địa chỉ mới cần xác nhận trước khi sử dụng; nếu không thì hiển thị địa chỉ đã chọn. --%>
                            <c:choose>
                                <c:when test="${formDraft.addressSelection eq 'new'}">
                                    <div class="text-sm text-amber-800">Địa chỉ mới chưa được lưu. Vui lòng bấm Xác nhận trong hộp địa chỉ.</div>
                                </c:when>
                                <c:when test="${not empty customerAddresses}">
                                    <%-- Ưu tiên địa chỉ mặc định, sau đó ghi đè nếu có địa chỉ được chọn. --%>
                                    <c:set var="activeAddr" value="${not empty defaultAddress ? defaultAddress : customerAddresses[0]}"/>
                                    <c:forEach var="candidateAddress" items="${customerAddresses}">
                                        <c:if test="${selectedAddressId eq candidateAddress.addressId}">
                                            <c:set var="activeAddr" value="${candidateAddress}"/>
                                        </c:if>
                                    </c:forEach>
                                    <div class="flex flex-wrap items-baseline gap-3 text-sm">
                                        <strong class="font-extrabold text-gray-900" id="display-recipient-name">
                                            <c:out value="${activeAddr.recipientName}"/> (<c:out value="${activeAddr.recipientPhone}"/>)
                                        </strong>
                                        <span class="text-gray-700" id="display-recipient-address">
                                            <c:out value="${activeAddr.fullAddress}"/>
                                        </span>
                                        <span id="display-default-badge" class="px-2 py-0.5 text-[11px] font-bold text-red-600 border border-red-500 rounded bg-red-50 <c:if test='${not activeAddr.defaultAddress}'>hidden</c:if>">
                                            Mặc định
                                        </span>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="flex flex-wrap items-baseline gap-3 text-sm">
                                        <strong class="font-extrabold text-gray-900" id="display-recipient-name">
                                            Chưa có địa chỉ nhận hàng
                                        </strong>
                                        <span class="text-gray-700" id="display-recipient-address">
                                            Vui lòng bấm Thay Đổi để chọn hoặc nhập địa chỉ.
                                        </span>
                                        <span id="display-default-badge" class="px-2 py-0.5 text-[11px] font-bold text-red-600 border border-red-500 rounded bg-red-50 hidden">
                                            Mặc định
                                        </span>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
