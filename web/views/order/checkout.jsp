<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<c:url var="cartUrl" value="/cart"/>
<c:url var="placeOrderUrl" value="/order/place"/>
<c:url var="paymentUrl" value="/payment"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán đơn hàng - Gốc Vườn</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Google Fonts & Material Symbols -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&amp;family=Plus+Jakarta+Sans:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background-color: #f5f5f5;
        }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .shopee-border-stripe {
            height: 3px;
            width: 100%;
            background-position-x: -30px;
            background-size: 116px 3px;
            background-image: repeating-linear-gradient(45deg, #6fa6d6, #6fa6d6 33px, transparent 0, transparent 41px, #f18d9b 0, #f18d9b 74px, transparent 0, transparent 82px);
        }
    </style>
</head>
<body class="text-gray-800 antialiased min-h-screen flex flex-col">

<!-- Header chuẩn đồng bộ với Cart & Home -->
<jsp:include page="/views/common/header.jsp" />

<main class="flex-1 max-w-[1240px] w-full mx-auto px-4 py-6">
    <c:if test="${not empty checkoutError or not empty sessionScope.checkoutError}">
        <div class="mb-5 p-4 rounded-xl bg-red-50 border border-red-200 text-red-800 font-bold flex items-center gap-3 shadow-xs" role="alert">
            <span class="material-symbols-outlined text-red-600">error</span>
            <span><c:out value="${not empty checkoutError ? checkoutError : sessionScope.checkoutError}"/></span>
        </div>
        <c:remove var="checkoutError" scope="session"/>
    </c:if>

    <c:choose>
        <c:when test="${empty selectedItems or empty draftOrder}">
            <div class="bg-white rounded-2xl p-12 text-center border border-gray-200/80 shadow-xs my-6">
                <span class="material-symbols-outlined text-gray-400 text-6xl">remove_shopping_cart</span>
                <h2 class="text-xl font-bold text-gray-900 mt-4 mb-2">Không có sản phẩm để thanh toán</h2>
                <p class="text-gray-500 text-sm mb-6">Vui lòng quay lại giỏ hàng và chọn ít nhất một sản phẩm.</p>
                <a href="<c:out value='${cartUrl}'/>" class="inline-flex items-center gap-2 px-6 py-3 rounded-xl bg-[#00652c] text-white font-bold hover:bg-[#005323] transition shadow-md">
                    Về giỏ hàng
                </a>
            </div>
        </c:when>
        <c:otherwise>
            <form method="post" action="<c:out value='${placeOrderUrl}'/>" id="checkout-form"
                  data-order-action="<c:out value='${placeOrderUrl}'/>"
                  data-payment-action="<c:out value='${paymentUrl}'/>"
                  class="space-y-4">

                <!-- Hidden parameters -->
                <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.cartCsrfToken}'/>">
                <c:forEach var="cartItemId" items="${cartItemIds}">
                    <input type="hidden" name="cartItemIds" value="<c:out value='${cartItemId}'/>">
                </c:forEach>
                <input type="hidden" name="couponCode" id="checkout-coupon-code" value="<c:out value='${couponCode}'/>">
                <c:forEach var="entry" items="${shopCouponCodes}">
                    <c:if test="${not empty entry.value}">
                        <input type="hidden" name="shopCoupon_${entry.key}" value="<c:out value='${entry.value}'/>">
                    </c:if>
                </c:forEach>
                <input type="hidden" name="deliverySlot" value="AFTERNOON">

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
                            <c:choose>
                                <c:when test="${not empty customerAddresses}">
                                    <c:set var="activeAddr" value="${not empty defaultAddress ? defaultAddress : customerAddresses[0]}"/>
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

                <!-- ==================== 2. TABLE HEADER (SẢN PHẨM | ĐƠN GIÁ | SỐ LƯỢNG | THÀNH TIỀN) ==================== -->
                <div class="hidden md:grid grid-cols-12 gap-4 bg-white px-6 py-4 rounded-xl border border-gray-200/70 text-sm font-semibold text-gray-500 shadow-xs">
                    <div class="col-span-6">Sản phẩm</div>
                    <div class="col-span-2 text-center">Đơn giá</div>
                    <div class="col-span-2 text-center">Số lượng</div>
                    <div class="col-span-2 text-right">Thành tiền</div>
                </div>

                <!-- ==================== 3. DANH SÁCH SẢN PHẨM THEO TỪNG GIAN HÀNG (GIỐNG SHOPEE) ==================== -->
                <c:choose>
                    <c:when test="${not empty itemsByShop}">
                        <c:forEach var="shopEntry" items="${itemsByShop}">
                            <c:set var="shopItems" value="${shopEntry.value}"/>
                            <c:set var="shop" value="${shopItems[0].variant.product}"/>
                            <c:set var="shopSubtotal" value="${0}"/>
                            <c:forEach var="item" items="${shopItems}">
                                <c:set var="shopSubtotal" value="${shopSubtotal + item.subtotal}"/>
                            </c:forEach>

                            <section class="bg-white rounded-xl shadow-xs border border-gray-200/70 overflow-hidden">
                                <!-- Shop Header -->
                                <div class="px-6 py-3.5 border-b border-gray-100 flex items-center justify-between">
                                    <div class="flex items-center gap-2.5">
                                        <span class="inline-flex items-center justify-center w-7 h-7 rounded-lg bg-emerald-50 text-[#00652c]">
                                            <span class="material-symbols-outlined text-[18px]">storefront</span>
                                        </span>
                                        <strong class="text-sm font-bold text-gray-900">
                                            <c:out value="${not empty shop.shopName ? shop.shopName : 'Gian hàng nông sản'}"/>
                                        </strong>
                                        <span class="text-gray-300">|</span>
                                        <button type="button" class="flex items-center gap-1 text-xs text-emerald-700 font-semibold hover:underline cursor-pointer">
                                            <span class="material-symbols-outlined text-[15px]">chat</span> Chat ngay
                                        </button>
                                    </div>
                                    <span class="text-xs text-gray-400 font-medium"><c:out value="${shopItems.size()}"/> sản phẩm</span>
                                </div>

                                <!-- Shop Items List -->
                                <div class="divide-y divide-gray-100">
                                    <c:forEach var="item" items="${shopItems}">
                                        <div class="px-6 py-4 grid grid-cols-1 md:grid-cols-12 gap-4 items-center">
                                            <div class="md:col-span-6 flex items-center gap-3.5 min-w-0">
                                                <div class="w-16 h-16 rounded-xl overflow-hidden bg-gray-50 border border-gray-100 shrink-0">
                                                    <c:choose>
                                                        <c:when test="${not empty item.variant.product.image}">
                                                            <img src="<c:out value='${item.variant.product.image}'/>" alt="<c:out value='${item.variant.product.name}'/>" class="w-full h-full object-cover">
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="w-full h-full flex items-center justify-center text-gray-300"><span class="material-symbols-outlined">image</span></div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="min-w-0">
                                                    <h4 class="text-sm font-bold text-gray-900 line-clamp-2 leading-snug"><c:out value="${item.variant.product.name}"/></h4>
                                                    <p class="text-xs text-gray-500 mt-1">Phân loại: <strong class="text-gray-700"><c:out value="${item.variant.variantName}"/><c:if test="${not empty item.variant.unit}">, <c:out value="${item.variant.unit}"/></c:if></strong></p>
                                                </div>
                                            </div>
                                            <div class="md:col-span-2 text-left md:text-center text-sm text-gray-700">
                                                <span class="md:hidden text-xs text-gray-400 mr-1">Đơn giá:</span>
                                                <fmt:formatNumber value="${item.variant.price}" type="currency" currencyCode="VND" maxFractionDigits="0"/>
                                            </div>
                                            <div class="md:col-span-2 text-left md:text-center text-sm text-gray-700">
                                                <span class="md:hidden text-xs text-gray-400 mr-1">Số lượng:</span>
                                                <c:out value="${item.quantity}"/>
                                            </div>
                                            <div class="md:col-span-2 text-left md:text-right text-sm font-extrabold text-[#00652c]">
                                                <span class="md:hidden text-xs text-gray-400 mr-1">Thành tiền:</span>
                                                <fmt:formatNumber value="${item.subtotal}" type="currency" currencyCode="VND" maxFractionDigits="0"/>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>

                                <!-- Shop Voucher Row (Giống Shopee) -->
                                <c:set var="currentShopCode" value="${shopCouponCodes[shopEntry.key]}"/>
                                <c:set var="currentSubOrder" value="${null}"/>
                                <c:forEach var="sub" items="${draftOrder.subOrders}">
                                    <c:if test="${sub.shopId eq shopEntry.key}">
                                        <c:set var="currentSubOrder" value="${sub}"/>
                                    </c:if>
                                </c:forEach>

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
                                                <button type="button" onclick="openShopVoucherModal('${shopEntry.key}', '<c:out value="${not empty shop.shopName ? shop.shopName : 'Shop'}"/>', ${shopSubtotal})" class="text-blue-600 hover:underline font-semibold cursor-pointer">
                                                    Thay Đổi
                                                </button>
                                                <button type="button" onclick="removeShopCoupon('${shopEntry.key}')" class="text-red-500 hover:underline font-semibold cursor-pointer">
                                                    Xóa
                                                </button>
                                            </c:when>
                                            <c:otherwise>
                                                <button type="button" onclick="openShopVoucherModal('${shopEntry.key}', '<c:out value="${not empty shop.shopName ? shop.shopName : 'Shop'}"/>', ${shopSubtotal})" class="text-blue-600 hover:underline font-semibold cursor-pointer">
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
                                        <input type="text" name="shopNote_${shopEntry.key}" placeholder="Lưu ý cho Người bán..." class="flex-1 bg-white border border-gray-200 rounded-lg px-3 py-1.5 text-xs outline-none focus:border-emerald-600">
                                    </div>
                                    <div class="md:col-span-7 flex flex-col md:flex-row md:items-center justify-between gap-2 md:pl-6 border-l-0 md:border-l border-gray-200">
                                        <div>
                                            <div class="flex items-center gap-2 flex-wrap">
                                                <span class="text-gray-700 font-semibold">Phương thức vận chuyển:</span>
                                                <span class="font-bold text-gray-900">Nhanh (Giao trong ngày / 2h - 4h)</span>
                                                <button type="button" class="text-blue-600 hover:underline text-[11px] font-semibold cursor-pointer">Thay Đổi</button>
                                            </div>
                                            <div class="text-[11px] text-gray-400 mt-0.5">Được đồng kiểm khi nhận hàng</div>
                                        </div>
                                        <strong class="text-sm font-bold text-gray-900">0₫</strong>
                                    </div>
                                </div>

                                <!-- Shop Subtotal (Giống Shopee) -->
                                <div class="px-6 py-3.5 border-t border-gray-100 bg-white flex justify-end items-center gap-3 text-sm">
                                    <span class="text-gray-500">Tổng số tiền (${shopItems.size()} sản phẩm):</span>
                                    <c:choose>
                                        <c:when test="${not empty currentSubOrder and currentSubOrder.shopDiscount gt 0}">
                                            <span class="text-xs text-gray-400 line-through">
                                                <fmt:formatNumber value="${shopSubtotal}" type="currency" currencyCode="VND" maxFractionDigits="0"/>
                                            </span>
                                            <strong class="text-base text-[#00652c] font-extrabold">
                                                <fmt:formatNumber value="${currentSubOrder.shopTotal}" type="currency" currencyCode="VND" maxFractionDigits="0"/>
                                            </strong>
                                        </c:when>
                                        <c:otherwise>
                                            <strong class="text-base text-[#00652c] font-extrabold">
                                                <fmt:formatNumber value="${shopSubtotal}" type="currency" currencyCode="VND" maxFractionDigits="0"/>
                                            </strong>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </section>
                        </c:forEach>
                    </c:when>
                </c:choose>

                <!-- ==================== 4. VOUCHER GỐC VƯỜN CARD (GIỐNG SHOPEE) ==================== -->
                <div class="bg-white rounded-xl shadow-xs border border-gray-200/70 px-6 py-4 flex flex-wrap items-center justify-between gap-4">
                    <div class="flex items-center gap-2.5">
                        <span class="material-symbols-outlined text-[22px] text-amber-600">confirmation_number</span>
                        <strong class="text-sm text-gray-900 font-bold">Voucher Gốc Vườn</strong>
                    </div>
                    <div class="flex items-center gap-3">
                        <c:choose>
                            <c:when test="${not empty couponCode}">
                                <span class="bg-red-50 text-red-600 border border-red-200 px-3 py-1 rounded-lg text-xs font-bold flex items-center gap-1.5">
                                    <span class="material-symbols-outlined text-[16px]">check_circle</span>
                                    <span>Mã: <c:out value="${couponCode}"/> (-<fmt:formatNumber value="${draftOrder.platformDiscount}" type="currency" currencyCode="VND" maxFractionDigits="0"/>)</span>
                                </span>
                                <button type="button" onclick="openCheckoutVoucherModal()" class="text-blue-600 hover:underline text-xs font-semibold cursor-pointer">Thay Đổi</button>
                                <button type="button" onclick="removeCheckoutCoupon()" class="text-red-500 hover:underline text-xs cursor-pointer">Xóa</button>
                            </c:when>
                            <c:otherwise>
                                <button type="button" onclick="openCheckoutVoucherModal()" class="text-blue-600 hover:underline text-sm font-semibold cursor-pointer">
                                    Chọn hoặc nhập mã
                                </button>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- ==================== 5. PHƯƠNG THỨC THANH TOÁN & TỔNG KẾT (GIỐNG SHOPEE) ==================== -->
                <div class="bg-white rounded-xl shadow-xs border border-gray-200/70 p-6 space-y-6">
                    <!-- Hàng chọn phương thức thanh toán -->
                    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-gray-100">
                        <strong class="text-base text-gray-900 font-bold">Phương thức thanh toán</strong>
                        <div class="flex flex-wrap items-center gap-3" id="payment-options-container">
                            <label class="payment-method-pill px-4 py-2 rounded-xl border-2 border-[#00652c] bg-emerald-50/60 text-[#00652c] text-xs font-bold cursor-pointer transition select-none flex items-center gap-1.5">
                                <input type="radio" name="paymentMethod" value="COD" checked class="hidden">
                                <span class="material-symbols-outlined text-[16px]">check</span>
                                <span>Thanh toán khi nhận hàng (COD)</span>
                            </label>
                            <label class="payment-method-pill px-4 py-2 rounded-xl border border-gray-200 hover:border-gray-300 text-gray-700 text-xs font-medium cursor-pointer transition select-none flex items-center gap-1.5">
                                <input type="radio" name="paymentMethod" value="VNPAY" class="hidden">
                                <span>Thanh toán qua VNPAY-QR</span>
                            </label>
                            <label class="payment-method-pill px-4 py-2 rounded-xl border border-gray-200 hover:border-gray-300 text-gray-700 text-xs font-medium cursor-pointer transition select-none flex items-center gap-1.5">
                                <input type="radio" name="paymentMethod" value="BANK_TRANSFER" class="hidden">
                                <span>Chuyển khoản ngân hàng</span>
                            </label>
                            <span class="px-4 py-2 rounded-xl border border-gray-200 bg-gray-50 text-gray-400 text-xs font-medium opacity-60 cursor-not-allowed">
                                Ví điện tử (Sắp có)
                            </span>
                        </div>
                    </div>

                    <!-- Khung nhập thẻ (Chỉ hiển thị khi chọn Thẻ ngân hàng) -->
                    <div id="online-payment-note" class="hidden bg-emerald-50/40 border border-emerald-200 rounded-xl p-4 text-xs text-gray-700 flex items-start gap-2">
                        <span class="material-symbols-outlined text-[#00652c] text-[20px]">verified_user</span>
                        <span>Sau khi bấm <strong>Thanh toán</strong>, bạn sẽ được chuyển sang cổng thanh toán (mô phỏng VNPay) để hoàn tất giao dịch trong 15 phút. FreshFruit không lưu thông tin thẻ của bạn.</span>
                    </div>

                    <!-- Bảng tổng hợp chi phí (Căn phải giống Shopee) -->
                    <div class="flex flex-col items-end space-y-3 pt-3 text-sm">
                        <div class="flex justify-between w-full sm:w-80 text-gray-500">
                            <span>Tổng tiền hàng:</span>
                            <span class="font-semibold text-gray-900"><fmt:formatNumber value="${draftOrder.totalGoodsAmount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></span>
                        </div>
                        <div class="flex justify-between w-full sm:w-80 text-gray-500">
                            <span>Tổng tiền phí vận chuyển:</span>
                            <span class="font-semibold text-gray-900"><fmt:formatNumber value="${draftOrder.totalShippingFee}" type="currency" currencyCode="VND" maxFractionDigits="0"/></span>
                        </div>
                        <c:set var="totalShopDiscount" value="${0}"/>
                        <c:forEach var="sub" items="${draftOrder.subOrders}">
                            <c:set var="totalShopDiscount" value="${totalShopDiscount + sub.shopDiscount}"/>
                        </c:forEach>
                        <c:if test="${totalShopDiscount gt 0}">
                            <div class="flex justify-between w-full sm:w-80 text-amber-700">
                                <span>Giảm giá Voucher Shop:</span>
                                <span class="font-bold">-<fmt:formatNumber value="${totalShopDiscount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></span>
                            </div>
                        </c:if>
                        <c:if test="${draftOrder.platformDiscount gt 0}">
                            <div class="flex justify-between w-full sm:w-80 text-red-600">
                                <span>Giảm giá Voucher Gốc Vườn:</span>
                                <span class="font-bold">-<fmt:formatNumber value="${draftOrder.platformDiscount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></span>
                            </div>
                        </c:if>
                        <div class="flex justify-between items-baseline w-full sm:w-80 pt-3 border-t border-gray-100">
                            <span class="text-sm font-bold text-gray-900">Tổng thanh toán:</span>
                            <strong class="text-2xl sm:text-3xl font-extrabold text-[#00652c]">
                                <fmt:formatNumber value="${draftOrder.finalAmount}" type="currency" currencyCode="VND" maxFractionDigits="0"/>
                            </strong>
                        </div>
                    </div>

                    <!-- Nút Đặt Hàng & Điều khoản (Giống Shopee) -->
                    <div class="pt-6 border-t border-gray-100 flex flex-col sm:flex-row items-center justify-between gap-4">
                        <p class="text-xs text-gray-500 text-center sm:text-left">
                            Nhấn "Đặt hàng" đồng nghĩa với việc bạn đồng ý tuân theo <a href="#" class="text-blue-600 hover:underline">Điều khoản Gốc Vườn</a>
                        </p>
                        <button type="submit" id="submit-order-btn" class="w-full sm:w-56 py-3.5 bg-[#00652c] hover:bg-[#005323] text-white font-extrabold rounded-xl text-base shadow-md transition duration-200 active:scale-95 cursor-pointer">
                            Đặt hàng
                        </button>
                    </div>
                </div>

                <!-- ==================== MODAL CHỌN / ĐỔI ĐỊA CHỈ NHẬN HÀNG ==================== -->
                <dialog id="address-modal" class="p-0 rounded-2xl w-[min(640px,calc(100%-24px))] shadow-2xl backdrop:bg-black/50 border border-gray-200">
                    <div class="bg-white rounded-2xl overflow-hidden">
                        <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between bg-gray-50/50">
                            <h3 class="font-bold text-base text-gray-900">Địa Chỉ Của Tôi</h3>
                            <button type="button" onclick="closeAddressModal()" class="w-8 h-8 rounded-full hover:bg-gray-200 flex items-center justify-center text-gray-400 hover:text-gray-700">
                                <span class="material-symbols-outlined text-[20px]">close</span>
                            </button>
                        </div>
                        <div class="p-6 max-h-[60vh] overflow-y-auto space-y-3">
                            <c:forEach var="address" items="${customerAddresses}">
                                <label class="p-4 border rounded-xl flex items-start gap-3 cursor-pointer hover:border-emerald-500 transition <c:if test='${address.defaultAddress or (not empty defaultAddress and defaultAddress.addressId eq address.addressId)}'>border-emerald-600 bg-emerald-50/20</c:if>">
                                    <input type="radio" name="addressSelection" value="saved:<c:out value='${address.addressId}'/>"
                                           data-name="<c:out value='${address.recipientName}'/>"
                                           data-phone="<c:out value='${address.recipientPhone}'/>"
                                           data-full="<c:out value='${address.fullAddress}'/>"
                                           data-default="${address.defaultAddress}"
                                           <c:if test="${address.defaultAddress or (not empty defaultAddress and defaultAddress.addressId eq address.addressId)}">checked</c:if>
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
                                <input type="radio" name="addressSelection" value="new" id="radio-address-new" class="mt-1 accent-[#00652c]" <c:if test="${empty customerAddresses}">checked</c:if>>
                                <div class="flex-1 text-xs">
                                    <strong class="text-sm font-bold text-gray-900">+ Thêm địa chỉ nhận hàng mới</strong>
                                </div>
                            </label>

                            <!-- Form nhập địa chỉ mới -->
                            <div id="new-address-inputs" class="space-y-3 pt-3 border-t border-dashed border-gray-200 <c:if test='${not empty customerAddresses}'>hidden</c:if>">
                                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs">
                                    <div>
                                        <label class="block font-bold text-gray-700 mb-1">Họ tên người nhận</label>
                                        <input type="text" name="recipientName" class="w-full border rounded-lg px-3 py-2 text-xs">
                                    </div>
                                    <div>
                                        <label class="block font-bold text-gray-700 mb-1">Số điện thoại</label>
                                        <input type="tel" name="recipientPhone" class="w-full border rounded-lg px-3 py-2 text-xs">
                                    </div>
                                    <div class="sm:col-span-2">
                                        <label class="block font-bold text-gray-700 mb-1" for="checkoutCitySelect">Tỉnh / Thành phố <span class="text-red-500">*</span></label>
                                        <select id="checkoutCitySelect" name="city" class="w-full border rounded-lg px-3 py-2 text-xs bg-white outline-none focus:border-emerald-600">
                                            <option value="" selected disabled>Chọn Tỉnh / Thành phố</option>
                                        </select>
                                    </div>
                                    <div>
                                        <label class="block font-bold text-gray-700 mb-1" for="checkoutDistrictSelect">Quận / Huyện <span class="text-red-500">*</span></label>
                                        <select id="checkoutDistrictSelect" name="district" disabled class="w-full border rounded-lg px-3 py-2 text-xs bg-white outline-none focus:border-emerald-600 disabled:bg-gray-100 disabled:text-gray-400">
                                            <option value="" selected disabled>Chọn Quận / Huyện</option>
                                        </select>
                                    </div>
                                    <div>
                                        <label class="block font-bold text-gray-700 mb-1" for="checkoutWardSelect">Phường / Xã</label>
                                        <select id="checkoutWardSelect" name="ward" disabled class="w-full border rounded-lg px-3 py-2 text-xs bg-white outline-none focus:border-emerald-600 disabled:bg-gray-100 disabled:text-gray-400">
                                            <option value="" selected disabled>Chọn Phường / Xã</option>
                                        </select>
                                    </div>
                                    <div class="sm:col-span-2">
                                        <label class="block font-bold text-gray-700 mb-1">Địa chỉ cụ thể (Số nhà, tên ngõ, tòa nhà...) <span class="text-red-500">*</span></label>
                                        <input type="text" name="streetAddress" placeholder="Ví dụ: Số 20 ngõ 10" class="w-full border rounded-lg px-3 py-2 text-xs outline-none focus:border-emerald-600">
                                    </div>
                                    <div class="sm:col-span-2">
                                        <label class="flex items-center gap-2 cursor-pointer">
                                            <input type="checkbox" name="saveAddress" value="true" checked class="accent-[#00652c]">
                                            <span class="text-gray-600">Lưu địa chỉ này vào sổ địa chỉ</span>
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="px-6 py-3 border-t border-gray-100 bg-gray-50/50 flex justify-end gap-2">
                            <button type="button" onclick="closeAddressModal()" class="px-4 py-2 border rounded-xl text-xs font-semibold text-gray-700 hover:bg-gray-100 cursor-pointer">
                                Đóng
                            </button>
                            <button type="button" id="btn-confirm-address" onclick="confirmAddressSelection()" class="px-5 py-2 bg-[#00652c] text-white rounded-xl text-xs font-bold hover:bg-[#005323] cursor-pointer">
                                Xác nhận
                            </button>
                        </div>
                    </div>
                </dialog>

                <!-- ==================== MODAL CHỌN VOUCHER SÀN ==================== -->
                <dialog id="checkout-voucher-modal" class="p-0 rounded-2xl w-[min(520px,calc(100%-24px))] shadow-2xl backdrop:bg-black/50 border border-gray-200">
                    <div class="bg-white rounded-2xl overflow-hidden">
                        <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between bg-gray-50/50">
                            <h3 class="font-bold text-base text-gray-900">Chọn Voucher Gốc Vườn</h3>
                            <button type="button" onclick="closeCheckoutVoucherModal()" class="w-8 h-8 rounded-full hover:bg-gray-200 flex items-center justify-center text-gray-400 hover:text-gray-700">
                                <span class="material-symbols-outlined text-[20px]">close</span>
                            </button>
                        </div>
                        <div class="p-6 max-h-[60vh] overflow-y-auto space-y-3">
                            <div class="flex gap-2">
                                <input type="text" id="manual-coupon-input" placeholder="Nhập mã giảm giá..." class="flex-1 border rounded-xl px-3 py-2 text-xs uppercase outline-none focus:border-emerald-600">
                                <button type="button" onclick="applyManualCoupon()" class="px-4 py-2 bg-gray-900 text-white rounded-xl text-xs font-bold hover:bg-black">
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
                                                <c:choose>
                                                    <c:when test="${c.discountType eq 'PERCENTAGE'}">Giảm <fmt:formatNumber value="${c.discountValue}" maxFractionDigits="0"/>%</c:when>
                                                    <c:otherwise>Giảm <fmt:formatNumber value="${c.discountValue}" type="currency" currencyCode="VND" maxFractionDigits="0"/></c:otherwise>
                                                </c:choose>
                                                · Đơn từ <fmt:formatNumber value="${c.minOrderValue}" type="currency" currencyCode="VND" maxFractionDigits="0"/>
                                            </p>
                                        </div>
                                        <button type="button" onclick="applyCouponCode('<c:out value="${c.code}"/>')" class="px-3.5 py-1.5 bg-[#00652c] hover:bg-[#005323] text-white rounded-lg font-bold text-xs">
                                            Áp dụng
                                        </button>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                        <div class="px-6 py-3 border-t border-gray-100 bg-gray-50/50 flex justify-end">
                            <button type="button" onclick="closeCheckoutVoucherModal()" class="px-4 py-2 border rounded-xl text-xs font-semibold text-gray-700 hover:bg-gray-100">
                                Đóng
                            </button>
                        </div>
                    </div>
                </dialog>

                <!-- ==================== MODAL CHỌN VOUCHER CỦA SHOP ==================== -->
                <dialog id="shop-voucher-modal" class="p-0 rounded-2xl w-[min(520px,calc(100%-24px))] shadow-2xl backdrop:bg-black/50 border border-gray-200">
                    <div class="bg-white rounded-2xl overflow-hidden">
                        <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between bg-gray-50/50">
                            <div>
                                <h3 class="font-bold text-base text-gray-900" id="shop-voucher-modal-title">Chọn Voucher Của Shop</h3>
                                <p class="text-xs text-gray-500 mt-0.5" id="shop-voucher-modal-subtitle">Áp dụng cho sản phẩm của shop này</p>
                            </div>
                            <button type="button" onclick="closeShopVoucherModal()" class="w-8 h-8 rounded-full hover:bg-gray-200 flex items-center justify-center text-gray-400 hover:text-gray-700 cursor-pointer">
                                <span class="material-symbols-outlined text-[20px]">close</span>
                            </button>
                        </div>
                        <div class="p-6 max-h-[60vh] overflow-y-auto space-y-3">
                            <div class="flex gap-2">
                                <input type="text" id="manual-shop-coupon-input" placeholder="Nhập mã voucher của shop..." class="flex-1 border rounded-xl px-3 py-2 text-xs uppercase outline-none focus:border-emerald-600">
                                <button type="button" onclick="applyManualShopCoupon()" class="px-4 py-2 bg-gray-900 text-white rounded-xl text-xs font-bold hover:bg-black cursor-pointer">
                                    Áp dụng
                                </button>
                            </div>
                            <div class="pt-3 border-t border-gray-100 space-y-2.5" id="shop-voucher-list-container">
                                <!-- Rendered dynamically by openShopVoucherModal -->
                            </div>
                        </div>
                        <div class="px-6 py-3 border-t border-gray-100 bg-gray-50/50 flex justify-end">
                            <button type="button" onclick="closeShopVoucherModal()" class="px-4 py-2 border rounded-xl text-xs font-semibold text-gray-700 hover:bg-gray-100 cursor-pointer">
                                Đóng
                            </button>
                        </div>
                    </div>
                </dialog>
            </form>
        </c:otherwise>
    </c:choose>
</main>

<!-- ==================== JAVASCRIPT XỬ LÝ THANH TOÁN ==================== -->
<script>
    // 1. Xử lý nạp danh mục hành chính từ backend & modal địa chỉ
    const checkoutCitySelect = document.getElementById('checkoutCitySelect');
    const checkoutDistrictSelect = document.getElementById('checkoutDistrictSelect');
    const checkoutWardSelect = document.getElementById('checkoutWardSelect');

    async function initCheckoutProvinces() {
        if (!checkoutCitySelect || checkoutCitySelect.options.length > 1) return;
        try {
            const res = await fetch('${pageContext.request.contextPath}/api/address/provinces');
            if (!res.ok) throw new Error();
            const list = await res.json();
            checkoutCitySelect.innerHTML = '<option value="" selected disabled>Chọn Tỉnh / Thành phố</option>';
            list.forEach(p => {
                const opt = document.createElement('option');
                opt.value = p.name;
                opt.textContent = p.name;
                opt.dataset.code = p.code;
                checkoutCitySelect.appendChild(opt);
            });
        } catch (e) {
            console.warn('Không thể nạp danh sách tỉnh thành:', e);
        }
    }

    if (checkoutCitySelect) {
        checkoutCitySelect.addEventListener('change', async function() {
            const selectedOpt = checkoutCitySelect.options[checkoutCitySelect.selectedIndex];
            const pCode = selectedOpt.dataset.code;
            checkoutDistrictSelect.disabled = true;
            checkoutDistrictSelect.innerHTML = '<option value="" selected disabled>Đang tải danh sách...</option>';
            checkoutWardSelect.disabled = true;
            checkoutWardSelect.innerHTML = '<option value="" selected disabled>Chọn Phường / Xã</option>';

            if (!pCode) return;
            try {
                const res = await fetch('${pageContext.request.contextPath}/api/address/districts?provinceCode=' + encodeURIComponent(pCode));
                if (!res.ok) throw new Error();
                const data = await res.json();
                checkoutDistrictSelect.innerHTML = '<option value="" selected disabled>Chọn Quận / Huyện</option>';
                data.districts.forEach(d => {
                    const opt = document.createElement('option');
                    opt.value = d.name;
                    opt.textContent = d.name;
                    opt.dataset.code = d.code;
                    checkoutDistrictSelect.appendChild(opt);
                });
                checkoutDistrictSelect.disabled = false;
            } catch (e) {
                checkoutDistrictSelect.innerHTML = '<option value="" selected disabled>Chọn Quận / Huyện</option>';
                checkoutDistrictSelect.disabled = false;
            }
        });
    }

    if (checkoutDistrictSelect) {
        checkoutDistrictSelect.addEventListener('change', async function() {
            const selectedOpt = checkoutDistrictSelect.options[checkoutDistrictSelect.selectedIndex];
            const dCode = selectedOpt.dataset.code;
            checkoutWardSelect.disabled = true;
            checkoutWardSelect.innerHTML = '<option value="" selected disabled>Đang tải danh sách...</option>';

            if (!dCode) return;
            try {
                const res = await fetch('${pageContext.request.contextPath}/api/address/wards?districtCode=' + encodeURIComponent(dCode));
                if (!res.ok) throw new Error();
                const data = await res.json();
                checkoutWardSelect.innerHTML = '<option value="" selected disabled>Chọn Phường / Xã</option>';
                data.wards.forEach(w => {
                    const opt = document.createElement('option');
                    opt.value = w.name;
                    opt.textContent = w.name;
                    checkoutWardSelect.appendChild(opt);
                });
                checkoutWardSelect.disabled = false;
            } catch (e) {
                checkoutWardSelect.innerHTML = '<option value="" selected disabled>Chọn Phường / Xã</option>';
                checkoutWardSelect.disabled = false;
            }
        });
    }

    function openAddressModal() {
        const dialog = document.getElementById('address-modal');
        if (dialog) {
            dialog.showModal();
            initCheckoutProvinces();
        }
    }

    function closeAddressModal() {
        const dialog = document.getElementById('address-modal');
        if (dialog) dialog.close();
    }

    // Toggle hiển thị form địa chỉ mới khi chọn radio
    document.querySelectorAll('input[name="addressSelection"]').forEach(radio => {
        radio.addEventListener('change', function() {
            const newInputs = document.getElementById('new-address-inputs');
            if (newInputs) {
                if (this.value === 'new') {
                    newInputs.classList.remove('hidden');
                    initCheckoutProvinces();
                } else {
                    newInputs.classList.add('hidden');
                }
            }
        });
    });

    function escapeHtml(s) {
        if (!s) return '';
        return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }

    function confirmAddressSelection() {
        const selected = document.querySelector('input[name="addressSelection"]:checked');
        if (!selected) {
            closeAddressModal();
            return;
        }

        const nameEl = document.getElementById('display-recipient-name');
        const addrEl = document.getElementById('display-recipient-address');
        const badgeEl = document.getElementById('display-default-badge');

        if (selected.value === 'new') {
            const name = (document.querySelector('input[name="recipientName"]')?.value || '').trim();
            const phone = (document.querySelector('input[name="recipientPhone"]')?.value || '').trim();
            const street = (document.querySelector('input[name="streetAddress"]')?.value || '').trim();
            const city = (document.getElementById('checkoutCitySelect')?.value || '').trim();
            const district = (document.getElementById('checkoutDistrictSelect')?.value || '').trim();
            const ward = (document.getElementById('checkoutWardSelect')?.value || '').trim();
            const isDefault = document.querySelector('input[name="saveAddress"]')?.checked ? 'true' : 'false';

            if (!name || !phone || !street || !city || !district) {
                alert('Vui lòng điền đầy đủ họ tên, số điện thoại, tỉnh/thành phố, quận/huyện và địa chỉ cụ thể!');
                return;
            }

            const confirmBtn = document.getElementById('btn-confirm-address');
            if (confirmBtn) {
                confirmBtn.disabled = true;
                confirmBtn.textContent = 'Đang lưu...';
            }

            const bodyParams = new URLSearchParams();
            bodyParams.append('recipientName', name);
            bodyParams.append('recipientPhone', phone);
            bodyParams.append('streetAddress', street);
            bodyParams.append('city', city);
            bodyParams.append('district', district);
            bodyParams.append('ward', ward);
            bodyParams.append('isDefault', isDefault);

            fetch('${pageContext.request.contextPath}/api/address/create', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                    'Accept': 'application/json'
                },
                body: bodyParams.toString()
            })
            .then(res => res.json())
            .then(data => {
                if (confirmBtn) {
                    confirmBtn.disabled = false;
                    confirmBtn.textContent = 'Xác nhận';
                }
                if (data && data.success) {
                    // Cập nhật hiển thị địa chỉ ra ngoài trang thanh toán
                    if (nameEl) nameEl.textContent = data.recipientName + ' (' + data.recipientPhone + ')';
                    if (addrEl) addrEl.textContent = data.fullAddress;
                    if (badgeEl) {
                        if (data.isDefault) badgeEl.classList.remove('hidden');
                        else badgeEl.classList.add('hidden');
                    }

                    // Chèn option mới vào danh sách địa chỉ đã lưu trong modal và chọn nó
                    const modalList = document.querySelector('#address-modal .p-6.max-h-\\[60vh\\]');
                    const newOptionLabel = document.querySelector('#radio-address-new')?.closest('label');
                    if (modalList && newOptionLabel) {
                        const newLabel = document.createElement('label');
                        newLabel.className = 'p-4 border rounded-xl flex items-start gap-3 cursor-pointer hover:border-emerald-500 transition border-emerald-600 bg-emerald-50/20';
                        newLabel.innerHTML = '<input type="radio" name="addressSelection" value="saved:' + data.addressId + '" checked '
                            + 'data-name="' + escapeHtml(data.recipientName) + '" '
                            + 'data-phone="' + escapeHtml(data.recipientPhone) + '" '
                            + 'data-full="' + escapeHtml(data.fullAddress) + '" '
                            + 'data-default="' + Boolean(data.isDefault) + '" class="mt-1 accent-[#00652c]">'
                            + '<div class="flex-1 text-xs space-y-1">'
                            + '<div class="flex items-center gap-2">'
                            + '<strong class="text-sm font-bold text-gray-900">' + escapeHtml(data.recipientName) + '</strong>'
                            + '<span class="text-gray-400">|</span>'
                            + '<span class="text-gray-600">' + escapeHtml(data.recipientPhone) + '</span>'
                            + (data.isDefault ? '<span class="px-2 py-0.5 text-[10px] font-bold text-red-600 border border-red-500 rounded bg-red-50">Mặc định</span>' : '')
                            + '</div>'
                            + '<p class="text-gray-700">' + escapeHtml(data.fullAddress) + '</p>'
                            + '</div>';
                        modalList.insertBefore(newLabel, newOptionLabel);
                    }

                    // Reset form nhập mới
                    const newInputs = document.getElementById('new-address-inputs');
                    if (newInputs) newInputs.classList.add('hidden');
                    const radioNew = document.getElementById('radio-address-new');
                    if (radioNew) radioNew.checked = false;

                    closeAddressModal();
                } else {
                    alert(data && data.message ? data.message : 'Lỗi khi lưu địa chỉ vào cơ sở dữ liệu!');
                }
            })
            .catch(err => {
                if (confirmBtn) {
                    confirmBtn.disabled = false;
                    confirmBtn.textContent = 'Xác nhận';
                }
                alert('Không thể kết nối máy chủ để lưu địa chỉ: ' + err.message);
            });
            return;
        }

        // Chọn một địa chỉ đã có sẵn
        const name = selected.dataset.name;
        const phone = selected.dataset.phone;
        const full = selected.dataset.full;
        const isDef = selected.dataset.default === 'true';

        if (nameEl) nameEl.textContent = name + ' (' + phone + ')';
        if (addrEl) addrEl.textContent = full;
        if (badgeEl) {
            if (isDef) badgeEl.classList.remove('hidden');
            else badgeEl.classList.add('hidden');
        }
        closeAddressModal();
    }

    // Dữ liệu voucher của các shop và voucher đã áp dụng
    const shopCouponsData = {
        <c:forEach var="entry" items="${availableShopCoupons}" varStatus="status">
            "${entry.key}": [
                <c:forEach var="c" items="${entry.value}" varStatus="cStatus">
                    {
                        code: "<c:out value='${c.code}'/>",
                        discountType: "<c:out value='${c.discountType}'/>",
                        discountValue: <c:out value='${c.discountValue}'/>,
                        minOrderValue: <c:out value='${c.minOrderValue}'/>,
                        maxDiscountAmount: <c:out value='${not empty c.maxDiscountAmount ? c.maxDiscountAmount : "null"}'/>,
                        active: <c:out value='${c.active}'/>
                    }<c:if test="${not cStatus.last}">,</c:if>
                </c:forEach>
            ]<c:if test="${not status.last}">,</c:if>
        </c:forEach>
    };

    const appliedShopCouponsData = {
        <c:forEach var="entry" items="${shopCouponCodes}" varStatus="status">
            "${entry.key}": "<c:out value='${entry.value}'/>"<c:if test="${not status.last}">,</c:if>
        </c:forEach>
    };

    let currentModalShopId = null;

    function formatVND(amount) {
        if (amount == null) return '0₫';
        return Number(amount).toLocaleString('vi-VN') + '₫';
    }

    // 2. Xử lý Voucher của Shop
    function openShopVoucherModal(shopId, shopName, shopSubtotal) {
        currentModalShopId = String(shopId);
        const dialog = document.getElementById('shop-voucher-modal');
        const title = document.getElementById('shop-voucher-modal-title');
        const input = document.getElementById('manual-shop-coupon-input');
        const container = document.getElementById('shop-voucher-list-container');

        if (title) title.textContent = 'Chọn Voucher của ' + (shopName || 'Shop');
        if (input) input.value = '';

        if (container) {
            container.innerHTML = '';
            const coupons = shopCouponsData[currentModalShopId] || [];
            const currentApplied = appliedShopCouponsData[currentModalShopId] || '';

            if (coupons.length === 0) {
                container.innerHTML = '<div class="p-6 text-center text-xs text-gray-500 bg-gray-50 rounded-xl border border-gray-100">'
                    + '<span class="material-symbols-outlined text-gray-400 text-3xl mb-1 block">sentiment_dissatisfied</span>'
                    + 'Cửa hàng hiện chưa có voucher hiển thị sẵn. Bạn có thể nhập mã voucher ở trên nếu có!</div>';
            } else {
                coupons.forEach(c => {
                    const isApplied = currentApplied && currentApplied.toUpperCase() === c.code.toUpperCase();
                    const isEligible = Number(shopSubtotal) >= Number(c.minOrderValue);

                    let discountLabel = '';
                    if (c.discountType === 'PERCENTAGE') {
                        discountLabel = 'Giảm ' + c.discountValue + '%';
                        if (c.maxDiscountAmount) {
                            discountLabel += ' (tối đa ' + formatVND(c.maxDiscountAmount) + ')';
                        }
                    } else {
                        discountLabel = 'Giảm ' + formatVND(c.discountValue);
                    }

                    const card = document.createElement('div');
                    card.className = 'p-3.5 border rounded-xl flex items-center justify-between gap-3 text-xs '
                        + (isApplied ? 'border-amber-400 bg-amber-50/50' : (isEligible ? 'border-amber-200 bg-amber-50/30' : 'border-gray-200 bg-gray-50/60 opacity-60'));

                    const info = document.createElement('div');
                    info.className = 'min-w-0 flex-1';

                    const headerRow = document.createElement('div');
                    headerRow.className = 'flex items-center gap-2';

                    const codeStrong = document.createElement('strong');
                    codeStrong.className = 'text-sm font-bold text-amber-800';
                    codeStrong.textContent = c.code;
                    headerRow.appendChild(codeStrong);

                    const tag = document.createElement('span');
                    tag.className = 'px-1.5 py-0.5 rounded text-[10px] bg-amber-100 text-amber-900 font-semibold';
                    tag.textContent = 'Voucher Shop';
                    headerRow.appendChild(tag);

                    if (isApplied) {
                        const appliedBadge = document.createElement('span');
                        appliedBadge.className = 'px-1.5 py-0.5 rounded text-[10px] bg-emerald-100 text-emerald-800 font-bold';
                        appliedBadge.textContent = 'Đang dùng';
                        headerRow.appendChild(appliedBadge);
                    }

                    info.appendChild(headerRow);

                    const desc = document.createElement('p');
                    desc.className = 'text-gray-700 mt-1';
                    desc.textContent = discountLabel + ' · Đơn từ ' + formatVND(c.minOrderValue);
                    info.appendChild(desc);

                    if (!isEligible) {
                        const reason = document.createElement('p');
                        reason.className = 'text-[11px] text-red-500 mt-0.5';
                        reason.textContent = 'Chưa đủ điều kiện (Đơn tối thiểu ' + formatVND(c.minOrderValue) + ')';
                        info.appendChild(reason);
                    }

                    card.appendChild(info);

                    const btn = document.createElement('button');
                    btn.type = 'button';
                    if (isApplied) {
                        btn.className = 'px-3.5 py-1.5 bg-gray-200 text-gray-500 rounded-lg font-bold text-xs cursor-default';
                        btn.textContent = 'Đang chọn';
                        btn.disabled = true;
                    } else if (isEligible) {
                        btn.className = 'px-3.5 py-1.5 bg-amber-600 hover:bg-amber-700 text-white rounded-lg font-bold text-xs cursor-pointer transition';
                        btn.textContent = 'Áp dụng';
                        btn.onclick = function() {
                            applyShopCoupon(currentModalShopId, c.code);
                        };
                    } else {
                        btn.className = 'px-3.5 py-1.5 bg-gray-200 text-gray-400 rounded-lg font-bold text-xs cursor-not-allowed';
                        btn.textContent = 'Chưa đủ';
                        btn.disabled = true;
                    }
                    card.appendChild(btn);

                    container.appendChild(card);
                });
            }
        }

        if (dialog) dialog.showModal();
    }

    function closeShopVoucherModal() {
        const dialog = document.getElementById('shop-voucher-modal');
        if (dialog) dialog.close();
    }

    function applyShopCoupon(shopId, code) {
        if (!code || !code.trim()) return;
        window.location.href = '${pageContext.request.contextPath}/checkout?shopId=' + encodeURIComponent(shopId)
            + '&shopCouponCode=' + encodeURIComponent(code.trim().toUpperCase());
    }

    function applyManualShopCoupon() {
        const input = document.getElementById('manual-shop-coupon-input');
        if (!input || !input.value.trim()) {
            alert('Vui lòng nhập mã voucher của shop!');
            return;
        }
        if (currentModalShopId) {
            applyShopCoupon(currentModalShopId, input.value.trim().toUpperCase());
        }
    }

    function removeShopCoupon(shopId) {
        window.location.href = '${pageContext.request.contextPath}/checkout?removeShopCoupon=' + encodeURIComponent(shopId);
    }

    // 3. Xử lý Voucher Sàn
    function openCheckoutVoucherModal() {
        const dialog = document.getElementById('checkout-voucher-modal');
        if (dialog) dialog.showModal();
    }

    function closeCheckoutVoucherModal() {
        const dialog = document.getElementById('checkout-voucher-modal');
        if (dialog) dialog.close();
    }

    function applyCouponCode(code) {
        document.getElementById('checkout-coupon-code').value = code;
        window.location.href = '${pageContext.request.contextPath}/checkout?couponCode=' + encodeURIComponent(code);
    }

    function applyManualCoupon() {
        const input = document.getElementById('manual-coupon-input');
        if (input && input.value.trim()) {
            applyCouponCode(input.value.trim().toUpperCase());
        }
    }

    function removeCheckoutCoupon() {
        document.getElementById('checkout-coupon-code').value = '';
        window.location.href = '${pageContext.request.contextPath}/checkout?removeCoupon=true';
    }

    // 3. Xử lý chuyển đổi phương thức thanh toán (COD vs CARD)
    const paymentForm = document.getElementById('checkout-form');
    const paymentLabels = document.querySelectorAll('.payment-method-pill');
    const onlineNote = document.getElementById('online-payment-note');
    const submitBtn = document.getElementById('submit-order-btn');

    paymentLabels.forEach(label => {
        label.addEventListener('click', function() {
            paymentLabels.forEach(l => {
                l.classList.remove('border-2', 'border-[#00652c]', 'bg-emerald-50/60', 'text-[#00652c]', 'font-bold');
                l.classList.add('border-gray-200', 'text-gray-700', 'font-medium');
                const checkIcon = l.querySelector('.material-symbols-outlined');
                if (checkIcon) checkIcon.remove();
            });

            this.classList.add('border-2', 'border-[#00652c]', 'bg-emerald-50/60', 'text-[#00652c]', 'font-bold');
            this.classList.remove('border-gray-200', 'text-gray-700', 'font-medium');

            const check = document.createElement('span');
            check.className = 'material-symbols-outlined text-[16px]';
            check.textContent = 'check';
            this.prepend(check);

            const radio = this.querySelector('input[type="radio"]');
            if (radio) {
                radio.checked = true;
                if (radio.value !== 'COD') {
                    if (onlineNote) onlineNote.classList.remove('hidden');
                    if (submitBtn) submitBtn.textContent = 'Thanh toán';
                } else {
                    if (onlineNote) onlineNote.classList.add('hidden');
                    if (submitBtn) submitBtn.textContent = 'Đặt hàng';
                }
            }
        });
    });

    // Format số thẻ & Expiry
    const cardNumber = document.getElementById('cardNumber');
    const cardExpiry = document.getElementById('cardExpiry');
    if (cardNumber) {
        cardNumber.addEventListener('input', function() {
            let v = this.value.replace(/\D/g, '').slice(0, 19);
            this.value = v.replace(/(.{4})/g, '$1 ').trim();
        });
    }
    if (cardExpiry) {
        cardExpiry.addEventListener('input', function() {
            let v = this.value.replace(/\D/g, '').slice(0, 4);
            if (v.length > 2) this.value = v.slice(0, 2) + '/' + v.slice(2);
            else this.value = v;
        });
    }

    document.addEventListener('DOMContentLoaded', function() {
        const manualPlatform = document.getElementById('manual-coupon-input');
        if (manualPlatform) {
            manualPlatform.addEventListener('keydown', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    applyManualCoupon();
                }
            });
        }
        const manualShop = document.getElementById('manual-shop-coupon-input');
        if (manualShop) {
            manualShop.addEventListener('keydown', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    applyManualShopCoupon();
                }
            });
        }

        // Close on clicking backdrop
        const shopDialog = document.getElementById('shop-voucher-modal');
        if (shopDialog) {
            shopDialog.addEventListener('click', function(e) {
                if (e.target === shopDialog) closeShopVoucherModal();
            });
        }
        const platformDialog = document.getElementById('checkout-voucher-modal');
        if (platformDialog) {
            platformDialog.addEventListener('click', function(e) {
                if (e.target === platformDialog) closeCheckoutVoucherModal();
            });
        }
    });
</script>

</body>
</html>
