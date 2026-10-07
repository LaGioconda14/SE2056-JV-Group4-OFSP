<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<c:url var="homeUrl" value="/home.jsp"/>
<c:url var="productsUrl" value="/products"/>
<c:url var="cartUrl" value="/cart"/>
<c:url var="placeOrderUrl" value="/order/place"/>
<c:url var="checkoutCssUrl" value="/assets/css/checkout.css"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán - FreshFruit</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&amp;family=Plus+Jakarta+Sans:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet">
    <link href="<c:out value='${checkoutCssUrl}'/>" rel="stylesheet">
</head>
<body>
<header class="site-header">
    <div class="header-main shell">
        <a class="brand" href="<c:out value='${homeUrl}'/>">
            <svg class="brand-apple" viewBox="0 0 36 36" aria-hidden="true">
                <path d="M19 4s5 0 4 5c-3 0-5-2-4-5Z" fill="#16a34a"/><path d="M18 6.5c-.5 2-2 4-3 5" stroke="#4b5563" stroke-width="2" stroke-linecap="round"/><path d="M18 12.5c-2-3-7-3-10 0-4 4-3 11 1 16 3 4 6 4 9 2 3 2 6 2 9-2 4-5 5-12 1-16-3-3-8-3-10 0Z" fill="#ef4444"/>
            </svg>
            <span><strong>FreshFruit</strong><small>DIRECT FROM ORCHARD</small></span>
        </a>
        <form class="header-search" method="get" action="<c:out value='${productsUrl}'/>">
            <input type="search" name="search" placeholder="Tìm kiếm trái cây tươi ngon..." aria-label="Tìm kiếm sản phẩm">
            <button type="submit" aria-label="Tìm kiếm"><span class="material-symbols-outlined">search</span></button>
        </form>
        <div class="header-actions">
            <a class="header-pill" href="<c:out value='${cartUrl}'/>"><span class="material-symbols-outlined">shopping_cart</span><span>Giỏ hàng</span></a>
            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <a class="header-pill user-pill" href="<c:url value='/profile'/>">
                        <span class="avatar"><c:choose><c:when test="${not empty sessionScope.user.fullName}"><c:out value="${sessionScope.user.fullName.substring(0, 1)}"/></c:when><c:otherwise>U</c:otherwise></c:choose></span>
                        <span><c:out value="${sessionScope.user.fullName}"/></span>
                    </a>
                </c:when>
                <c:otherwise><a class="header-pill user-pill" href="<c:url value='/login'/>">Đăng nhập</a></c:otherwise>
            </c:choose>
        </div>
    </div>
    <div class="nav-row">
        <nav class="shell">
            <a href="<c:out value='${homeUrl}'/>">Trang Chủ</a><a href="<c:out value='${productsUrl}'/>">Cửa Hàng</a><a href="<c:out value='${productsUrl}'/>">Danh Mục Trái Cây</a><a href="<c:out value='${productsUrl}'/>">Hộp Quà &amp; Combo</a><a href="<c:out value='${homeUrl}'/>#about">Về Nông Trại</a><a href="<c:out value='${homeUrl}'/>#contact">Liên Hệ</a>
        </nav>
    </div>
</header>

<main class="page-main">
    <div class="shell checkout-shell">
        <div class="page-heading">
            <div><p class="eyebrow">FreshFruit checkout</p><h1>Hoàn tất đơn hàng</h1><p>Kiểm tra sản phẩm và điền thông tin nhận hàng của bạn.</p></div>
            <a class="back-link" href="<c:out value='${cartUrl}'/>"><span class="material-symbols-outlined">arrow_back</span> Quay lại giỏ hàng</a>
        </div>

        <c:if test="${not empty checkoutError or not empty sessionScope.checkoutError}">
            <div class="alert error" role="alert"><span class="material-symbols-outlined">error</span><c:out value="${not empty checkoutError ? checkoutError : sessionScope.checkoutError}"/></div>
            <c:remove var="checkoutError" scope="session"/>
        </c:if>

        <c:choose>
            <c:when test="${empty selectedItems or empty draftOrder}">
                <section class="empty-state">
                    <span class="material-symbols-outlined">remove_shopping_cart</span><h2>Không có sản phẩm để thanh toán</h2><p>Vui lòng quay lại giỏ hàng và chọn ít nhất một sản phẩm.</p>
                    <a class="primary-button" href="<c:out value='${cartUrl}'/>">Về giỏ hàng</a>
                </section>
            </c:when>
            <c:otherwise>
                <form method="post" action="<c:out value='${placeOrderUrl}'/>" class="checkout-grid" id="checkout-form">
                    <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.cartCsrfToken}'/>">
                    <c:forEach var="cartItemId" items="${cartItemIds}"><input type="hidden" name="cartItemIds" value="<c:out value='${cartItemId}'/>"></c:forEach>
                    <input type="hidden" name="couponCode" value="<c:out value='${couponCode}'/>">

                    <div class="checkout-content">
                        <section class="panel products-panel">
                            <div class="products-panel-heading">
                                <div class="panel-heading products-title">
                                    <span class="panel-icon material-symbols-outlined">nutrition</span>
                                    <div>
                                        <p class="section-kicker">Sản phẩm đã chọn</p>
                                        <h2>Sản phẩm đặt mua (<c:out value="${selectedItems.size()}"/> món)</h2>
                                        <p>Kiểm tra lại sản phẩm, phân loại và số lượng trước khi đặt hàng.</p>
                                    </div>
                                </div>
                                <a class="edit-cart-button" href="<c:out value='${cartUrl}'/>"><span class="material-symbols-outlined">edit_note</span>Chỉnh sửa giỏ hàng</a>
                            </div>
                            <div class="checkout-product-list">
                                <c:forEach var="item" items="${selectedItems}">
                                    <article class="checkout-product-row">
                                        <div class="checkout-product-image">
                                            <c:choose><c:when test="${not empty item.variant.product.image}"><img src="<c:out value='${item.variant.product.image}'/>" alt="<c:out value='${item.variant.product.name}'/>" loading="lazy"></c:when><c:otherwise><span class="material-symbols-outlined">image</span></c:otherwise></c:choose>
                                            <span class="checkout-quantity-badge">SL: <c:out value="${item.quantity}"/></span>
                                        </div>
                                        <div class="checkout-product-info">
                                            <div class="product-meta"><span class="fresh-label">Nông sản sạch</span><c:if test="${not empty item.variant.product.origin}"><span><span class="material-symbols-outlined">pin_drop</span><c:out value="${item.variant.product.origin}"/></span></c:if></div>
                                            <h3><c:out value="${item.variant.product.name}"/></h3>
                                            <p>Quy cách: <strong><c:out value="${item.variant.variantName}"/></strong><c:if test="${not empty item.variant.unit}"> · <c:out value="${item.variant.unit}"/></c:if> · Số lượng: <strong><c:out value="${item.quantity}"/></strong></p>
                                            <small>Đơn giá: <fmt:formatNumber value="${item.variant.price}" type="currency" currencyCode="VND" maxFractionDigits="0"/> / <c:out value="${item.variant.unit}"/></small>
                                        </div>
                                        <div class="checkout-line-total"><strong><fmt:formatNumber value="${item.subtotal}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong><span>Tổng <c:out value="${item.quantity}"/> <c:out value="${item.variant.unit}"/></span></div>
                                    </article>
                                </c:forEach>
                            </div>
                            <div class="products-panel-footer"><span><span class="material-symbols-outlined">verified</span>Tất cả sản phẩm được kiểm tra tồn kho và trạng thái cửa hàng trước khi đặt.</span><strong>Tổng tiền hàng: <fmt:formatNumber value="${draftOrder.totalGoodsAmount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></div>
                        </section>

                        <section class="panel">
                            <div class="panel-heading"><span class="panel-icon material-symbols-outlined">location_on</span><div><p class="section-kicker">Bước 1</p><h2>Thông tin giao hàng</h2></div></div>
                            <div class="address-options">
                                <c:forEach var="address" items="${customerAddresses}">
                                    <label class="address-option"><input type="radio" name="addressSelection" value="saved:<c:out value='${address.addressId}'/>" <c:if test="${address.defaultAddress or (not empty defaultAddress and defaultAddress.addressId eq address.addressId)}">checked</c:if> required><span class="address-radio"></span><span class="address-copy"><span class="address-name"><strong><c:out value="${address.recipientName}"/></strong><c:if test="${address.defaultAddress}"><em>Mặc định</em></c:if></span><span><c:out value="${address.fullAddress}"/></span><small><span class="material-symbols-outlined">phone_iphone</span><c:out value="${address.recipientPhone}"/></small></span></label>
                                </c:forEach>
                                <label class="address-option add-address-option"><input type="radio" name="addressSelection" value="new" <c:if test="${empty customerAddresses}">checked</c:if> required><span class="address-radio"></span><span class="material-symbols-outlined add-address-icon">add_location_alt</span><span class="address-copy"><strong>Thêm địa chỉ mới</strong><small>Nhập địa chỉ khác cho đơn hàng này.</small></span></label>
                            </div>
                            <div class="new-address-form <c:if test='${not empty customerAddresses}'>is-hidden</c:if>" data-new-address-form>
                                <div class="form-grid">
                                    <label class="field"><span>Họ và tên người nhận</span><input type="text" name="recipientName" autocomplete="name" data-new-address-field></label>
                                    <label class="field"><span>Số điện thoại</span><input type="tel" name="recipientPhone" autocomplete="tel" inputmode="tel" data-new-address-field></label>
                                    <label class="field full"><span>Địa chỉ (số nhà, tên đường)</span><input type="text" name="streetAddress" autocomplete="street-address" data-new-address-field></label>
                                    <label class="field"><span>Phường / Xã</span><input type="text" name="ward" data-new-address-field></label>
                                    <label class="field"><span>Quận / Huyện</span><input type="text" name="district" data-new-address-field></label>
                                    <label class="field full"><span>Tỉnh / Thành phố</span><input type="text" name="city" data-new-address-field></label>
                                </div>
                                <label class="save-address-option"><input type="checkbox" name="saveAddress" value="true" checked><span><strong>Lưu địa chỉ này vào sổ địa chỉ</strong><small>Lần mua sau bạn có thể chọn lại địa chỉ này mà không cần nhập lại.</small></span></label>
                            </div>
                        </section>

                        <input type="hidden" name="deliverySlot" value="AFTERNOON">

                        <section class="panel">
                            <div class="panel-heading"><span class="panel-icon material-symbols-outlined">payments</span><div><p class="section-kicker">Bước 2</p><h2>Phương thức thanh toán</h2></div></div>
                            <div class="payment-list">
                                <label class="payment-option"><input type="radio" name="paymentMethod" value="COD" checked required><span class="payment-radio"></span><span class="payment-icon material-symbols-outlined">payments</span><span><strong>Thanh toán khi nhận hàng (COD)</strong><small>Thanh toán bằng tiền mặt cho nhân viên giao hàng.</small></span><span class="status-tag">Khả dụng</span></label>
                                <div class="payment-option disabled" aria-disabled="true"><span class="payment-radio"></span><span class="payment-icon material-symbols-outlined">account_balance_wallet</span><span><strong>Ví điện tử</strong><small>Phương thức này chưa được hỗ trợ.</small></span><span class="status-tag muted">Sắp có</span></div>
                                <div class="payment-option disabled" aria-disabled="true"><span class="payment-radio"></span><span class="payment-icon material-symbols-outlined">credit_card</span><span><strong>Thẻ ngân hàng</strong><small>Phương thức này chưa được hỗ trợ.</small></span><span class="status-tag muted">Sắp có</span></div>
                            </div>
                        </section>
                    </div>

                    <aside class="order-summary">
                        <section class="panel summary-panel">
                            <div class="summary-title"><div><p class="section-kicker">Đơn hàng của bạn</p><h2><c:out value="${selectedItems.size()}"/> sản phẩm</h2></div><span class="material-symbols-outlined">shopping_bag</span></div>
                            <div class="summary-product-note"><span class="material-symbols-outlined">inventory_2</span><span><strong><c:out value="${selectedItems.size()}"/> dòng sản phẩm</strong><small>Chi tiết sản phẩm được hiển thị ở cột bên trái.</small></span></div>
                            <div class="checkout-voucher">
                                <div class="checkout-voucher-heading"><span><span class="material-symbols-outlined">sell</span>Voucher</span><button type="button" data-voucher-toggle><c:choose><c:when test="${not empty couponCode}"><c:out value="${couponCode}"/></c:when><c:otherwise>Chọn mã</c:otherwise></c:choose><span class="material-symbols-outlined">chevron_right</span></button></div>
                                <div class="voucher-options is-hidden" data-voucher-options>
                                    <label class="voucher-option"><input type="radio" name="couponPicker" value="" <c:if test="${empty couponCode}">checked</c:if>><span><strong>Không dùng voucher</strong><small>Thanh toán theo giá gốc.</small></span></label>
                                    <c:forEach var="coupon" items="${availableCoupons}">
                                        <label class="voucher-option"><input type="radio" name="couponPicker" value="<c:out value='${coupon.code}'/>" <c:if test="${coupon.code eq couponCode}">checked</c:if>><span><strong><c:out value="${coupon.code}"/></strong><small><c:choose><c:when test="${coupon.discountType eq 'PERCENTAGE'}">Giảm <fmt:formatNumber value="${coupon.discountValue}" maxFractionDigits="0"/>%</c:when><c:otherwise>Giảm <fmt:formatNumber value="${coupon.discountValue}" type="currency" currencyCode="VND" maxFractionDigits="0"/></c:otherwise></c:choose> · Đơn từ <fmt:formatNumber value="${coupon.minOrderValue}" type="currency" currencyCode="VND" maxFractionDigits="0"/></small></span><button type="button" data-apply-voucher>Áp dụng</button></label>
                                    </c:forEach>
                                </div>
                                <c:if test="${not empty couponCode}"><p class="voucher-applied"><span class="material-symbols-outlined">check_circle</span>Đã áp dụng mã <strong><c:out value="${couponCode}"/></strong></p></c:if>
                            </div>
                            <div class="totals">
                                <div><span>Tạm tính</span><strong><fmt:formatNumber value="${draftOrder.totalGoodsAmount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></div>
                                <div><span>Phí giao hàng</span><strong><fmt:formatNumber value="${draftOrder.totalShippingFee}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></div>
                                <c:if test="${draftOrder.platformDiscount gt 0}"><div class="discount"><span>Giảm giá<c:if test="${not empty couponCode}"> (<c:out value="${couponCode}"/>)</c:if></span><strong>-<fmt:formatNumber value="${draftOrder.platformDiscount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></div></c:if>
                                <div class="grand-total"><span>Tổng thanh toán</span><strong><fmt:formatNumber value="${draftOrder.finalAmount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></div>
                            </div>
                            <button class="submit-order" type="submit"><span>Đặt hàng</span><span class="material-symbols-outlined">arrow_forward</span></button>
                            <p class="secure-note"><span class="material-symbols-outlined">verified_user</span> Thông tin của bạn được bảo mật an toàn.</p>
                        </section>
                    </aside>
                </form>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<footer class="site-footer"><div class="shell footer-main"><div><strong class="footer-brand">FreshFruit</strong><p>Trái cây tươi hái tận vườn, giao hàng tận nơi.</p></div><nav><a href="<c:out value='${homeUrl}'/>">Trang Chủ</a><a href="<c:out value='${productsUrl}'/>">Cửa Hàng</a><a href="<c:out value='${homeUrl}'/>#about">Về Chúng Tôi</a><a href="<c:out value='${homeUrl}'/>#contact">Liên Hệ</a></nav><span class="hotline"><span class="material-symbols-outlined">call</span>1900 6868</span></div><div class="shell footer-bottom"><span>&copy; 2026 FreshFruit Marketplace. Đã đăng ký bản quyền.</span><span>Trái cây sạch cho mọi gia đình.</span></div></footer>
<script>
document.addEventListener('DOMContentLoaded',function(){
const addressInputs=document.querySelectorAll('input[name="addressSelection"]'),newAddressForm=document.querySelector('[data-new-address-form]'),newAddressFields=document.querySelectorAll('[data-new-address-field]');
function syncAddressForm(){const selected=document.querySelector('input[name="addressSelection"]:checked'),isNew=selected&&selected.value==='new';if(newAddressForm)newAddressForm.classList.toggle('is-hidden',!isNew);newAddressFields.forEach(function(field){field.required=Boolean(isNew);});}
addressInputs.forEach(function(input){input.addEventListener('change',syncAddressForm);});syncAddressForm();
const voucherToggle=document.querySelector('[data-voucher-toggle]'),voucherOptions=document.querySelector('[data-voucher-options]');if(voucherToggle&&voucherOptions)voucherToggle.addEventListener('click',function(){voucherOptions.classList.toggle('is-hidden');});
document.querySelectorAll('[data-apply-voucher]').forEach(function(button){button.addEventListener('click',function(){const option=button.closest('.voucher-option'),radio=option?option.querySelector('input[name="couponPicker"]'):null;if(!radio)return;radio.checked=true;const url=new URL(window.location.href);url.searchParams.set('couponCode',radio.value);window.location.href=url.toString();});});
const noVoucher=document.querySelector('.voucher-option input[value=""]');if(noVoucher)noVoucher.addEventListener('change',function(){if(this.checked){const url=new URL(window.location.href);url.searchParams.set('couponCode','');window.location.href=url.toString();}});
});
</script>
</body>
</html>
