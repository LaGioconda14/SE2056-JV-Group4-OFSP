<%@page pageEncoding="UTF-8"%>
                <!-- ==================== MODAL CHỌN VOUCHER CỦA SHOP ==================== -->
                <dialog id="shop-voucher-modal"
                        class="p-0 rounded-2xl w-[min(520px,calc(100%-24px))] shadow-2xl backdrop:bg-black/50 border border-gray-200">
                    <div class="bg-white rounded-2xl overflow-hidden">
                        <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between bg-gray-50/50">
                            <div>
                                <h3 class="font-bold text-base text-gray-900" id="shop-voucher-modal-title">Chọn Voucher Của Shop</h3>
                                <p class="text-xs text-gray-500 mt-0.5" id="shop-voucher-modal-subtitle">Áp dụng cho sản phẩm của shop này</p>
                            </div>
                            <button type="button" onclick="closeShopVoucherModal()"
                                    class="w-8 h-8 rounded-full hover:bg-gray-200 flex items-center justify-center text-gray-400 hover:text-gray-700 cursor-pointer">
                                <span class="material-symbols-outlined text-[20px]">close</span>
                            </button>
                        </div>
                        <div class="p-6 max-h-[60vh] overflow-y-auto space-y-3">
                            <div class="flex gap-2">
                                <%-- Mã nhập thủ công áp dụng cho shop đang chọn. --%>
                                <input type="text" id="manual-shop-coupon-input" placeholder="Nhập mã voucher của shop..."
                                       class="flex-1 border rounded-xl px-3 py-2 text-xs uppercase outline-none focus:border-emerald-600">
                                <button type="button" onclick="applyManualShopCoupon()"
                                        class="px-4 py-2 bg-gray-900 text-white rounded-xl text-xs font-bold hover:bg-black cursor-pointer">
                                    Áp dụng
                                </button>
                            </div>
                            <%-- Danh sách được tạo theo shop khi mở hộp thoại. --%>
                            <div class="pt-3 border-t border-gray-100 space-y-2.5" id="shop-voucher-list-container">
                                <!-- Rendered dynamically by openShopVoucherModal -->
                            </div>
                        </div>
                        <div class="px-6 py-3 border-t border-gray-100 bg-gray-50/50 flex justify-end">
                            <button type="button" onclick="closeShopVoucherModal()"
                                    class="px-4 py-2 border rounded-xl text-xs font-semibold text-gray-700 hover:bg-gray-100 cursor-pointer">
                                Đóng
                            </button>
                        </div>
                    </div>
                </dialog>
