<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<c:url var="homeUrl" value="/home.jsp"/>
<c:url var="productsUrl" value="/products"/>
<c:url var="cartUrl" value="/cart"/>
<c:url var="checkoutCssUrl" value="/assets/css/checkout.css"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác nhận đơn hàng - FreshFruit</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&amp;family=Plus+Jakarta+Sans:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet">
    <link href="<c:out value='${checkoutCssUrl}'/>" rel="stylesheet">
</head>
<body>
<header class="site-header">
    <div class="header-main shell">
        <a class="brand" href="<c:out value='${homeUrl}'/>"><svg class="brand-apple" viewBox="0 0 36 36" aria-hidden="true"><path d="M19 4s5 0 4 5c-3 0-5-2-4-5Z" fill="#16a34a"/><path d="M18 6.5c-.5 2-2 4-3 5" stroke="#4b5563" stroke-width="2" stroke-linecap="round"/><path d="M18 12.5c-2-3-7-3-10 0-4 4-3 11 1 16 3 4 6 4 9 2 3 2 6 2 9-2 4-5 5-12 1-16-3-3-8-3-10 0Z" fill="#ef4444"/></svg><span><strong>FreshFruit</strong><small>DIRECT FROM ORCHARD</small></span></a>
        <form class="header-search" method="get" action="<c:out value='${productsUrl}'/>"><input type="search" name="search" placeholder="Tìm kiếm trái cây tươi ngon..." aria-label="Tìm kiếm sản phẩm"><button type="submit" aria-label="Tìm kiếm"><span class="material-symbols-outlined">search</span></button></form>
        <div class="header-actions"><a class="header-pill" href="<c:out value='${cartUrl}'/>"><span class="material-symbols-outlined">shopping_cart</span><span>Giỏ hàng</span></a><c:choose><c:when test="${not empty sessionScope.user}"><a class="header-pill user-pill" href="<c:url value='/profile'/>"><span class="avatar"><c:choose><c:when test="${not empty sessionScope.user.fullName}"><c:out value="${sessionScope.user.fullName.substring(0, 1)}"/></c:when><c:otherwise>U</c:otherwise></c:choose></span><span><c:out value="${sessionScope.user.fullName}"/></span></a></c:when><c:otherwise><a class="header-pill user-pill" href="<c:url value='/login'/>">Đăng nhập</a></c:otherwise></c:choose></div>
    </div>
    <div class="nav-row"><nav class="shell"><a href="<c:out value='${homeUrl}'/>">Trang Chủ</a><a href="<c:out value='${productsUrl}'/>">Cửa Hàng</a><a href="<c:out value='${productsUrl}'/>">Danh Mục Trái Cây</a><a href="<c:out value='${productsUrl}'/>">Hộp Quà &amp; Combo</a><a href="<c:out value='${homeUrl}'/>#about">Về Nông Trại</a><a href="<c:out value='${homeUrl}'/>#contact">Liên Hệ</a></nav></div>
</header>

<main class="page-main confirmation-main">
    <div class="shell confirmation-shell">
        <nav class="stepper" aria-label="Tiến trình thanh toán"><div class="step complete"><span class="step-dot"><span class="material-symbols-outlined">check</span></span><span>Giỏ hàng</span></div><span class="step-line active"></span><div class="step complete"><span class="step-dot"><span class="material-symbols-outlined">check</span></span><span>Thanh toán</span></div><span class="step-line active"></span><div class="step complete current" aria-current="step"><span class="step-dot"><span class="material-symbols-outlined">check</span></span><span>Hoàn tất</span></div></nav>

        <c:choose>
            <c:when test="${empty order}">
                <section class="empty-state"><span class="material-symbols-outlined">receipt_long</span><h1>Không tìm thấy đơn hàng</h1><p>Thông tin đơn hàng không khả dụng.</p><a class="primary-button" href="<c:out value='${homeUrl}'/>">Về trang chủ</a></section>
            </c:when>
            <c:otherwise>
                <section class="success-hero">
                    <div class="success-icon"><span class="material-symbols-outlined">check</span></div>
                    <p class="eyebrow">Đặt hàng thành công</p>
                    <h1>Cảm ơn bạn đã mua hàng!</h1>
                    <p><c:choose><c:when test="${not empty sessionScope.orderSuccess}"><c:out value="${sessionScope.orderSuccess}"/></c:when><c:otherwise>Đơn hàng của bạn đã được FreshFruit tiếp nhận.</c:otherwise></c:choose></p>
                    <c:remove var="orderSuccess" scope="session"/>
                    <div class="order-number">Mã đơn hàng <strong>#<c:out value="${order.orderId}"/></strong></div>
                </section>

                <div class="confirmation-grid">
                    <div class="confirmation-content">
                        <section class="panel">
                            <div class="panel-heading"><span class="panel-icon material-symbols-outlined">inventory_2</span><div><p class="section-kicker">Chi tiết đơn hàng</p><h2>Sản phẩm đã đặt</h2></div></div>
                            <c:forEach var="subOrder" items="${order.subOrders}">
                                <div class="shop-block">
                                    <div class="shop-heading"><span><span class="material-symbols-outlined">storefront</span><strong><c:out value="${subOrder.shopName}"/></strong></span><span class="order-status"><c:out value="${subOrder.status}"/></span></div>
                                    <div class="confirmed-items">
                                        <c:forEach var="item" items="${subOrder.items}">
                                            <article class="confirmed-product"><div class="snapshot-icon"><span class="material-symbols-outlined">nutrition</span></div><div><strong><c:out value="${item.productNameSnapshot}"/></strong><small><c:out value="${item.variantNameSnapshot}"/><c:if test="${not empty item.unit}"> · <c:out value="${item.unit}"/></c:if></small><span><fmt:formatNumber value="${item.unitPrice}" type="currency" currencyCode="VND" maxFractionDigits="0"/> × <c:out value="${item.quantity}"/></span></div><strong><fmt:formatNumber value="${item.totalPrice}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></article>
                                        </c:forEach>
                                    </div>
                                    <div class="shop-totals"><span>Tiền hàng: <strong><fmt:formatNumber value="${subOrder.shopSubtotal}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></span><span>Phí giao: <strong><fmt:formatNumber value="${subOrder.shopShippingFee}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></span><c:if test="${not empty subOrder.deliverySlot}"><span>Khung giờ: <strong><c:out value="${subOrder.deliverySlot}"/></strong></span></c:if></div>
                                </div>
                            </c:forEach>
                        </section>
                    </div>

                    <aside class="confirmation-aside">
                        <section class="panel compact-panel">
                            <div class="panel-heading"><span class="panel-icon material-symbols-outlined">location_on</span><div><p class="section-kicker">Giao đến</p><h2>Địa chỉ nhận hàng</h2></div></div>
                            <c:choose><c:when test="${not empty order.shippingAddress}"><address class="address-card"><strong><c:out value="${order.shippingAddress.recipientName}"/></strong><span><c:out value="${order.shippingAddress.recipientPhone}"/></span><p><c:out value="${order.shippingAddress.fullAddress}"/></p></address></c:when><c:otherwise><p class="muted-text">Không có thông tin địa chỉ.</p></c:otherwise></c:choose>
                        </section>
                        <section class="panel compact-panel">
                            <div class="panel-heading"><span class="panel-icon material-symbols-outlined">receipt_long</span><div><p class="section-kicker">Thanh toán</p><h2>Tổng đơn hàng</h2></div></div>
                            <div class="totals confirmation-totals"><div><span>Tiền hàng</span><strong><fmt:formatNumber value="${order.totalGoodsAmount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></div><div><span>Phí giao hàng</span><strong><fmt:formatNumber value="${order.totalShippingFee}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></div><c:if test="${order.platformDiscount gt 0}"><div class="discount"><span>Giảm giá</span><strong>-<fmt:formatNumber value="${order.platformDiscount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></div></c:if><div class="grand-total"><span>Tổng thanh toán</span><strong><fmt:formatNumber value="${order.finalAmount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></div></div>
                            <div class="payment-state"><span class="material-symbols-outlined">schedule</span><span><small>Trạng thái thanh toán</small><strong><c:out value="${order.paymentStatus}"/></strong></span></div>
                        </section>
                    </aside>
                </div>
                <div class="confirmation-actions"><a class="secondary-button" href="<c:out value='${homeUrl}'/>"><span class="material-symbols-outlined">home</span> Về trang chủ</a><a class="primary-button" href="<c:out value='${productsUrl}'/>">Tiếp tục mua sắm <span class="material-symbols-outlined">arrow_forward</span></a></div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<footer class="site-footer"><div class="shell footer-main"><div><strong class="footer-brand">FreshFruit</strong><p>Trái cây tươi hái tận vườn, giao hàng tận nơi.</p></div><nav><a href="<c:out value='${homeUrl}'/>">Trang Chủ</a><a href="<c:out value='${productsUrl}'/>">Cửa Hàng</a><a href="<c:out value='${homeUrl}'/>#about">Về Chúng Tôi</a><a href="<c:out value='${homeUrl}'/>#contact">Liên Hệ</a></nav><span class="hotline"><span class="material-symbols-outlined">call</span>1900 6868</span></div><div class="shell footer-bottom"><span>&copy; 2026 FreshFruit Marketplace. Đã đăng ký bản quyền.</span><span>Trái cây sạch cho mọi gia đình.</span></div></footer>
</body>
</html>
