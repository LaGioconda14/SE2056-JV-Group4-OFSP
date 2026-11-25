<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<c:url var="cartUrl" value="/cart"/>
<c:url var="placeOrderUrl" value="/order/place"/>
<c:url var="checkoutUrl" value="/checkout"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán đơn hàng - Gốc Vườn</title>
    <!-- Google Fonts & Preconnect -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="dns-prefetch" href="https://cdn.tailwindcss.com">
    <!-- Tailwind CSS CDN (Non-blocking) -->
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&amp;family=Plus+Jakarta+Sans:wght@400;500;600;700;800&amp;display=swap"
          rel="stylesheet">
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
    <%-- Ưu tiên lỗi trong request; xóa lỗi trong session sau khi hiển thị. --%>
    <c:if test="${not empty checkoutError or not empty sessionScope.checkoutError}">
        <div class="mb-5 p-4 rounded-xl bg-red-50 border border-red-200 text-red-800 font-bold flex items-center gap-3 shadow-xs"
             role="alert">
            <span class="material-symbols-outlined text-red-600">error</span>
            <span><c:out value="${not empty checkoutError ? checkoutError : sessionScope.checkoutError}"/></span>
        </div>
        <c:remove var="checkoutError" scope="session"/>
    </c:if>
    <%-- Thông báo lỗi địa chỉ hoặc kết quả lưu địa chỉ thành công. --%>
    <c:if test="${not empty addressError}">
        <div class="mb-5 p-4 rounded-xl bg-red-50 border border-red-200 text-red-800" role="alert">
            <c:out value="${addressError}"/>
        </div>
    </c:if>
    <c:if test="${not empty sessionScope.checkoutAddressSuccess}">
        <div class="mb-5 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800" role="status">
            <c:out value="${sessionScope.checkoutAddressSuccess}"/>
        </div>
        <c:remove var="checkoutAddressSuccess" scope="session"/>
    </c:if>

    <%-- Nếu thiếu sản phẩm hoặc đơn nháp thì không hiển thị biểu mẫu thanh toán. --%>
    <c:choose>
        <c:when test="${empty selectedItems or empty draftOrder}">
            <%-- Hiển thị khi không có sản phẩm được chọn hoặc chưa có đơn nháp. --%>
            <div class="bg-white rounded-2xl p-12 text-center border border-gray-200/80 shadow-xs my-6">
                <span class="material-symbols-outlined text-gray-400 text-6xl">remove_shopping_cart</span>
                <h2 class="text-xl font-bold text-gray-900 mt-4 mb-2">Không có sản phẩm để thanh toán</h2>
                <p class="text-gray-500 text-sm mb-6">Vui lòng quay lại giỏ hàng và chọn ít nhất một sản phẩm.</p>
                <a href="<c:out value='${cartUrl}'/>"
                   class="inline-flex items-center gap-2 px-6 py-3 rounded-xl bg-[#00652c] text-white font-bold hover:bg-[#005323] transition shadow-md">
                    Về giỏ hàng
                </a>
            </div>
        </c:when>
        <c:otherwise>
            <%-- Các thành phần và hộp thoại dùng chung biểu mẫu để giữ dữ liệu khi gửi. --%>
            <form method="post" action="<c:out value='${placeOrderUrl}'/>" id="checkout-form"
                  class="space-y-4">

                <%-- Giữ nguồn chọn giỏ/buy-now qua các lần dựng lại bản nháp; hidden field và giá hiển thị không phải dữ liệu tin cậy khi đặt hàng. --%>
                <%-- cartCsrfToken bảo vệ yêu cầu POST; cartItemIds là các dòng giỏ đã chọn. --%>
                <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.cartCsrfToken}'/>">
                <c:forEach var="cartItemId" items="${cartItemIds}">
                    <input type="hidden" name="cartItemIds" value="<c:out value='${cartItemId}'/>">
                </c:forEach>
                <%-- Mua ngay dùng mã phân loại và số lượng thay cho các dòng giỏ hàng. --%>
                <c:if test="${buyNow}">
                    <input type="hidden" name="checkoutMode" value="buyNow">
                    <input type="hidden" name="variantId" value="<c:out value='${buyNowVariantId}'/>">
                    <input type="hidden" name="quantity" value="<c:out value='${buyNowQuantity}'/>">
                </c:if>
                <%-- Lưu mã voucher sàn và từng shop trong biểu mẫu thanh toán. --%>
                <input type="hidden" name="couponCode" id="checkout-coupon-code"
                       value="<c:out value='${couponCode}'/>">
                <c:forEach var="entry" items="${shopCouponCodes}">
                    <c:if test="${not empty entry.value}">
                        <input type="hidden" name="shopCoupon_${entry.key}" value="<c:out value='${entry.value}'/>">
                    </c:if>
                </c:forEach>
                <%-- Khi bật checkoutAction, cùng form này POST lại /checkout để đổi địa chỉ/voucher thay vì /order/place. --%>
                <input type="hidden" name="checkoutAction" id="checkout-action" disabled>
                <input type="hidden" name="targetShopId" id="target-shop-id" disabled>
                <input type="hidden" name="newCouponCode" id="new-coupon-code" disabled>
                <input type="hidden" name="newShopCouponCode" id="new-shop-coupon-code" disabled>

                <%@ include file="components/checkout-address.jsp" %>

                <%-- Tiêu đề lưới chỉ hiển thị từ màn hình trung bình; các cột tương ứng với từng dòng sản phẩm. --%>
                <!-- ==================== 2. TABLE HEADER (SẢN PHẨM | ĐƠN GIÁ | SỐ LƯỢNG | THÀNH TIỀN) ==================== -->
                <div class="hidden md:grid grid-cols-12 gap-4 bg-white px-6 py-4 rounded-xl border border-gray-200/70 text-sm font-semibold text-gray-500 shadow-xs">
                    <div class="col-span-6">Sản phẩm</div>
                    <div class="col-span-2 text-center">Đơn giá</div>
                    <div class="col-span-2 text-center">Số lượng</div>
                    <div class="col-span-2 text-right">Thành tiền</div>
                </div>

                <%@ include file="components/checkout-shops.jsp" %>

                <%-- Voucher sàn nằm ở cấp đơn tổng; khi POST đặt hàng điều kiện và mức giảm phải được kiểm tra lại. --%>
                <!-- ==================== 4. VOUCHER GỐC VƯỜN CARD (GIỐNG SHOPEE) ==================== -->
                <div class="bg-white rounded-xl shadow-xs border border-gray-200/70 px-6 py-4 flex flex-wrap items-center justify-between gap-4">
                    <div class="flex items-center gap-2.5">
                        <span class="material-symbols-outlined text-[22px] text-amber-600">confirmation_number</span>
                        <strong class="text-sm text-gray-900 font-bold">Voucher Gốc Vườn</strong>
                    </div>
                    <div class="flex items-center gap-3">
                        <%-- Có mã thì hiển thị mức giảm của đơn tổng và nút thay đổi hoặc xóa. --%>
                        <c:choose>
                            <c:when test="${not empty couponCode}">
                                <span class="bg-red-50 text-red-600 border border-red-200 px-3 py-1 rounded-lg text-xs font-bold flex items-center gap-1.5">
                                    <span class="material-symbols-outlined text-[16px]">check_circle</span>
                                    <span>Mã: <c:out value="${couponCode}"/> (-<fmt:formatNumber value="${draftOrder.platformDiscount}"
                                        type="currency" currencyCode="VND" maxFractionDigits="0"/>)</span>
                                </span>
                                <button type="button" onclick="openCheckoutVoucherModal()"
                                        class="text-blue-600 hover:underline text-xs font-semibold cursor-pointer">Thay Đổi</button>
                                <button type="button" onclick="removeCheckoutCoupon()"
                                        class="text-red-500 hover:underline text-xs cursor-pointer">Xóa</button>
                            </c:when>
                            <c:otherwise>
                                <button type="button" onclick="openCheckoutVoucherModal()"
                                        class="text-blue-600 hover:underline text-sm font-semibold cursor-pointer">
                                    Chọn hoặc nhập mã
                                </button>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <%@ include file="components/checkout-payment-summary.jsp" %>

                <%@ include file="components/address-dialog.jsp" %>

                <%@ include file="components/platform-voucher-dialog.jsp" %>

                <%@ include file="components/shop-voucher-dialog.jsp" %>
            </form>
        </c:otherwise>
    </c:choose>
</main>

<!-- Footer Chuẩn Đồng Bộ Website Gốc Vườn -->
<jsp:include page="/views/common/site-footer.jsp" />

<%-- Cấu hình server cung cấp cho checkout.js: URL và dữ liệu voucher theo shop. --%>
<script>
    window.CHECKOUT_CONFIG = {
        checkoutUrl: '<c:out value="${checkoutUrl}"/>',
        openAddressModal: ${not empty selectedItems and not empty draftOrder and formDraft.openAddressModal eq 'true'},
        <%-- availableShopCoupons nhóm các voucher có thể chọn theo mã shop. --%>
        shopCouponsData: {
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
        },
        <%-- shopCouponCodes chứa mã voucher đã áp dụng cho từng shop. --%>
        appliedShopCouponsData: {
            <c:forEach var="entry" items="${shopCouponCodes}" varStatus="status">
                "${entry.key}": "<c:out value='${entry.value}'/>"<c:if test="${not status.last}">,</c:if>
            </c:forEach>
        }
    };
</script>
<script src="${pageContext.request.contextPath}/assets/js/checkout.js?v=20261124" defer></script>

</body>
</html>
