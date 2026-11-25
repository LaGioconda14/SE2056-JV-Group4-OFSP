<%@page pageEncoding="UTF-8"%>
                <!-- ==================== MODAL CHỌN / ĐỔI ĐỊA CHỈ NHẬN HÀNG ==================== -->
                <dialog id="address-modal"
                        class="p-0 rounded-2xl w-[min(640px,calc(100%-24px))] shadow-2xl backdrop:bg-black/50 border border-gray-200">
                    <div class="bg-white rounded-2xl overflow-hidden">
                        <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between bg-gray-50/50">
                            <h3 class="font-bold text-base text-gray-900">Địa Chỉ Của Tôi</h3>
                            <button type="button" onclick="closeAddressModal()"
                                    class="w-8 h-8 rounded-full hover:bg-gray-200 flex items-center justify-center text-gray-400 hover:text-gray-700">
                                <span class="material-symbols-outlined text-[20px]">close</span>
                            </button>
                        </div>
                        <div class="p-6 max-h-[60vh] overflow-y-auto space-y-3">
                            <%-- Địa chỉ đã lưu: ưu tiên lựa chọn hiện tại, địa chỉ mặc định rồi địa chỉ đầu tiên. --%>
                            <c:forEach var="address" items="${customerAddresses}">
                                <label class="p-4 border rounded-xl flex items-start gap-3 cursor-pointer hover:border-emerald-500 transition <c:if test='${address.defaultAddress or (not empty defaultAddress and defaultAddress.addressId eq address.addressId)}'>border-emerald-600 bg-emerald-50/20</c:if>">
                                    <input type="radio" name="addressSelection" value="saved:<c:out value='${address.addressId}'/>"
                                           data-name="<c:out value='${address.recipientName}'/>"
                                           data-phone="<c:out value='${address.recipientPhone}'/>"
                                           data-full="<c:out value='${address.fullAddress}'/>"
                                           data-default="${address.defaultAddress}"
                                           <c:if test="${selectedAddressId eq address.addressId or (empty formDraft.addressSelection and ((not empty defaultAddress and defaultAddress.addressId eq address.addressId) or (empty defaultAddress and customerAddresses[0].addressId eq address.addressId)))}">checked</c:if>
                                           class="mt-1 accent-[#00652c]">
                                    <div class="flex-1 text-xs space-y-1">
                                        <div class="flex items-center gap-2">
                                            <strong class="text-sm font-bold text-gray-900"><c:out value="${address.recipientName}"/></strong>
                                            <span class="text-gray-400">|</span>
                                            <span class="text-gray-600"><c:out value="${address.recipientPhone}"/></span>
                                            <c:if test="${address.defaultAddress}">
                                                <span class="px-2 py-0.5 text-[10px] font-bold text-red-600 border border-red-500 rounded bg-red-50">Mặc định</span>
                                            </c:if>
                                        </div>
                                        <p class="text-gray-700"><c:out value="${address.fullAddress}"/></p>
                                    </div>
                                </label>
                            </c:forEach>

                            <!-- Thêm địa chỉ mới option -->
                            <label class="p-4 border rounded-xl flex items-start gap-3 cursor-pointer hover:border-emerald-500 transition">
                                <input type="radio" name="addressSelection" value="new" id="radio-address-new"
                                       class="mt-1 accent-[#00652c]"
                                       <c:if test="${formDraft.addressSelection eq 'new' or (empty formDraft.addressSelection and empty customerAddresses)}">checked</c:if>>
                                <div class="flex-1 text-xs">
                                    <strong class="text-sm font-bold text-gray-900">+ Thêm địa chỉ nhận hàng mới</strong>
                                </div>
                            </label>

                            <!-- Form nhập địa chỉ mới -->
                            <%-- Giữ dữ liệu đã nhập và chỉ hiện biểu mẫu khi cần địa chỉ mới. --%>
                            <div id="new-address-inputs" class="space-y-3 pt-3 border-t border-dashed border-gray-200 <c:if test='${not empty customerAddresses and formDraft.addressSelection ne "new"}'>hidden</c:if>">
                                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs">
                                    <div>
                                        <label class="block font-bold text-gray-700 mb-1">Họ tên người nhận</label>
                                        <input type="text" name="recipientName" value="<c:out value='${formDraft.recipientName}'/>"
                                               class="w-full border rounded-lg px-3 py-2 text-xs">
                                    </div>
                                    <div>
                                        <label class="block font-bold text-gray-700 mb-1">Số điện thoại</label>
                                        <input type="tel" name="recipientPhone" value="<c:out value='${formDraft.recipientPhone}'/>"
                                               class="w-full border rounded-lg px-3 py-2 text-xs">
                                    </div>
                                    <div>
                                        <label class="block font-bold text-gray-700 mb-1" for="checkoutCitySelect">Tỉnh / Thành phố <span class="text-red-500">*</span></label>
                                        <select id="checkoutCitySelect" name="provinceCode"
                                                class="w-full border rounded-lg px-3 py-2 text-xs bg-white outline-none focus:border-emerald-600">
                                            <option value="" disabled <c:if test="${empty formDraft.provinceCode}">selected</c:if>>Chọn Tỉnh / Thành phố</option>
                                            <%-- Mã tỉnh và phường khôi phục lựa chọn từ bản nháp. --%>
                                            <c:forEach var="province" items="${provinces}">
                                                <option value="<c:out value='${province.code}'/>"
                                                        <c:if test="${formDraft.provinceCode eq province.code}">selected</c:if>><c:out value="${province.name}"/></option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div>
                                        <label class="block font-bold text-gray-700 mb-1" for="checkoutWardSelect">Phường / Xã <span class="text-red-500">*</span></label>
                                        <select id="checkoutWardSelect" name="wardCode" <c:if test="${empty wards}">disabled</c:if>
                                                class="w-full border rounded-lg px-3 py-2 text-xs bg-white outline-none focus:border-emerald-600 disabled:bg-gray-100 disabled:text-gray-400">
                                            <option value="" disabled <c:if test="${empty formDraft.wardCode}">selected</c:if>>Chọn Phường / Xã</option>
                                            <c:forEach var="ward" items="${wards}">
                                                <option value="<c:out value='${ward.code}'/>"
                                                        <c:if test="${formDraft.wardCode eq ward.code}">selected</c:if>><c:out value="${ward.name}"/></option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="sm:col-span-2">
                                        <label class="block font-bold text-gray-700 mb-1">Địa chỉ cụ thể (Số nhà, tên ngõ, tòa nhà...) <span class="text-red-500">*</span></label>
                                        <input type="text" name="streetAddress" value="<c:out value='${formDraft.streetAddress}'/>"
                                               placeholder="Ví dụ: Số 20 ngõ 10"
                                               class="w-full border rounded-lg px-3 py-2 text-xs outline-none focus:border-emerald-600">
                                    </div>
                                    <div class="sm:col-span-2">
                                        <label class="flex items-center gap-2 cursor-pointer">
                                            <input type="checkbox" name="isDefault" value="true"
                                                   <c:if test="${formDraft.isDefault eq 'true'}">checked</c:if> class="accent-[#00652c]">
                                            <span class="text-gray-600">Đặt làm địa chỉ mặc định</span>
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="px-6 py-3 border-t border-gray-100 bg-gray-50/50 flex justify-end gap-2">
                            <button type="button" onclick="closeAddressModal()"
                                    class="px-4 py-2 border rounded-xl text-xs font-semibold text-gray-700 hover:bg-gray-100 cursor-pointer">
                                Đóng
                            </button>
                            <button type="button" id="btn-confirm-address" onclick="confirmAddressSelection()"
                                    class="px-5 py-2 bg-[#00652c] text-white rounded-xl text-xs font-bold hover:bg-[#005323] cursor-pointer">
                                Xác nhận
                            </button>
                        </div>
                    </div>
                </dialog>
