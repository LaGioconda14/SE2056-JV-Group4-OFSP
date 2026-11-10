<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<c:url var="homeUrl" value="/home"/>
<c:url var="productsUrl" value="/products"/>
<c:url var="cartUrl" value="/cart"/>
<c:url var="checkoutCssUrl" value="/assets/css/checkout.css"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác nhận đơn hàng - Gốc Vườn</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&amp;family=Plus+Jakarta+Sans:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet">
    <link href="<c:out value='${checkoutCssUrl}'/>" rel="stylesheet">
    <style>
        .page-main.confirmation-main {
            padding-top: 32px !important;
        }
        .success-hero h1 {
            font-weight: 800;
        }
        .panel-heading h2 {
            font-weight: 700;
        }
        .empty-state h1 {
            font-weight: 700;
        }
    </style>
</head>
<body class="bg-gray-50 text-gray-800 antialiased min-h-screen flex flex-col">

<!-- Header chuẩn đồng bộ với Cart, Home, Checkout -->
<jsp:include page="/views/common/header.jsp" />

<main class="page-main confirmation-main flex-1">
    <div class="shell confirmation-shell">
        <nav class="stepper" aria-label="Tiến trình thanh toán"><div class="step complete"><span class="step-dot"><span class="material-symbols-outlined">check</span></span><span>Giỏ hàng</span></div><span class="step-line active"></span><div class="step complete"><span class="step-dot"><span class="material-symbols-outlined">check</span></span><span>Thanh toán</span></div><span class="step-line active"></span><div class="step complete current" aria-current="step"><span class="step-dot"><span class="material-symbols-outlined">check</span></span><span>Hoàn tất</span></div></nav>

        <c:choose>
            <c:when test="${empty order}">
                <section class="empty-state"><span class="material-symbols-outlined">receipt_long</span><h1>Không tìm thấy đơn hàng</h1><p>Thông tin đơn hàng không khả dụng.</p><a class="primary-button" href="<c:out value='${homeUrl}'/>">Về trang chủ</a></section>
            </c:when>
            <c:otherwise>
                <section class="success-hero">
                    <div class="success-icon"><span class="material-symbols-outlined"><c:choose><c:when test="${param.payment eq 'failed' or param.payment eq 'invalid'}">error</c:when><c:otherwise>check</c:otherwise></c:choose></span></div>
                    <p class="eyebrow"><c:choose><c:when test="${param.payment eq 'success'}">Thanh toán thành công</c:when><c:when test="${param.payment eq 'failed'}">Thanh toán chưa thành công</c:when><c:when test="${param.payment eq 'invalid'}">Kết quả thanh toán không hợp lệ</c:when><c:otherwise>Đặt hàng thành công</c:otherwise></c:choose></p>
                    <h1><c:choose><c:when test="${param.payment eq 'success'}">VNPAY đã xác nhận thanh toán!</c:when><c:when test="${param.payment eq 'failed' or param.payment eq 'invalid'}">Đơn hàng đã được ghi nhận</c:when><c:otherwise>Cảm ơn bạn đã mua hàng!</c:otherwise></c:choose></h1>
                    <p><c:choose><c:when test="${not empty sessionScope.orderSuccess}"><c:out value="${sessionScope.orderSuccess}"/></c:when><c:otherwise>Đơn hàng của bạn đã được Gốc Vườn tiếp nhận.</c:otherwise></c:choose></p>
                    <c:if test="${order.paymentStatus eq 'PENDING' and order.paymentMethod eq 'CARD'}"><p>Đơn hàng đã được ghi nhận, thanh toán chưa hoàn tất. Không có khoản thanh toán thẻ nào được thực hiện tại trang này.</p></c:if>
                    <c:if test="${order.paymentMethod eq 'VNPAY' and param.payment eq 'failed'}"><p>VNPAY chưa ghi nhận thanh toán thành công. Bạn có thể thực hiện lại thanh toán từ đơn hàng của mình.</p></c:if>
                    <c:if test="${order.paymentMethod eq 'VNPAY' and param.payment eq 'invalid'}"><p>Không thể xác minh chữ ký phản hồi từ VNPAY. Trạng thái thanh toán không được thay đổi.</p></c:if>
                    <c:if test="${order.paymentMethod eq 'VNPAY' and (param.payment eq 'failed' or param.payment eq 'invalid')}">
                        <div class="mt-3 mb-2">
                            <a href="${pageContext.request.contextPath}/payment/vnpay/create?orderId=${order.orderId}"
                               class="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-extrabold text-xs transition shadow-sm text-decoration-none">
                                <span class="material-symbols-outlined text-[16px]">refresh</span>
                                Thanh toán lại qua VNPAY
                            </a>
                        </div>
                    </c:if>
                    <c:remove var="orderSuccess" scope="session"/>
                    <div class="order-number">Mã đơn hàng <strong>#<c:out value="${order.orderId}"/></strong></div>
                </section>

                <div class="confirmation-grid">
                    <div class="confirmation-content">
                        <section class="panel">
                            <div class="panel-heading"><span class="panel-icon material-symbols-outlined">inventory_2</span><div><p class="section-kicker">Chi tiết đơn hàng</p><h2>Sản phẩm đã đặt</h2></div></div>
                            <c:forEach var="subOrder" items="${order.subOrders}">
                                <div class="shop-block">
                                    <div class="shop-heading"><span><span class="material-symbols-outlined">storefront</span><strong><c:out value="${subOrder.shopName}"/></strong></span><span class="order-status"><c:choose><c:when test="${subOrder.status eq 'NEW'}">Chờ Shop xác nhận</c:when><c:when test="${subOrder.status eq 'PACKING'}">Đang đóng gói</c:when><c:when test="${subOrder.status eq 'SHIPPING'}">Đang giao hàng</c:when><c:when test="${subOrder.status eq 'DELIVERED'}">Đã giao hàng</c:when><c:when test="${subOrder.status eq 'CANCELLED'}">Đã hủy</c:when><c:otherwise><c:out value="${subOrder.status}"/></c:otherwise></c:choose></span></div>
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
                            <c:set var="totalVoucherDiscount" value="${order.platformDiscount}"/>
                            <c:forEach var="sub" items="${order.subOrders}">
                                <c:set var="totalVoucherDiscount" value="${totalVoucherDiscount + sub.shopDiscount}"/>
                            </c:forEach>
                            <div class="totals confirmation-totals">
                                <div><span>Tổng tiền hàng</span><strong><fmt:formatNumber value="${order.totalGoodsAmount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></div>
                                <c:forEach var="sub" items="${order.subOrders}">
                                    <div class="total-detail"><span>• <c:out value="${sub.shopName}"/></span><strong><fmt:formatNumber value="${sub.shopSubtotal}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></div>
                                </c:forEach>
                                <div><span>Tổng phí vận chuyển</span><strong><fmt:formatNumber value="${order.totalShippingFee}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></div>
                                <c:forEach var="sub" items="${order.subOrders}">
                                    <div class="total-detail"><span>• <c:out value="${sub.shopName}"/></span><strong><fmt:formatNumber value="${sub.shopShippingFee}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></div>
                                </c:forEach>
                                <div class="discount"><span>Tổng giảm giá voucher</span><strong><c:if test="${totalVoucherDiscount gt 0}">-</c:if><fmt:formatNumber value="${totalVoucherDiscount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></div>
                                <c:forEach var="sub" items="${order.subOrders}">
                                    <c:if test="${sub.shopDiscount gt 0}">
                                        <div class="total-detail discount"><span>• Voucher <c:out value="${sub.shopName}"/></span><strong>-<fmt:formatNumber value="${sub.shopDiscount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></div>
                                    </c:if>
                                </c:forEach>
                                <c:if test="${order.platformDiscount gt 0}">
                                    <div class="total-detail discount platform-discount"><span>• Voucher sàn Gốc Vườn</span><strong>-<fmt:formatNumber value="${order.platformDiscount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></div>
                                </c:if>
                                <div class="payment-method-row"><span>Phương thức thanh toán</span><strong><c:choose><c:when test="${order.paymentMethod eq 'VNPAY'}">VNPAY</c:when><c:when test="${order.paymentMethod eq 'COD'}">Thanh toán khi nhận hàng</c:when><c:when test="${order.paymentMethod eq 'CARD'}">Thẻ ngân hàng</c:when><c:otherwise><c:out value="${order.paymentMethod}"/></c:otherwise></c:choose></strong></div>
                                <div class="grand-total"><span>Tổng thanh toán</span><strong><fmt:formatNumber value="${order.finalAmount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></div>
                            </div>
                            <div class="payment-state">
                                <span class="material-symbols-outlined"><c:choose><c:when test="${order.paymentStatus eq 'PAID'}">check_circle</c:when><c:when test="${order.paymentStatus eq 'FAILED'}">cancel</c:when><c:when test="${order.paymentStatus eq 'REFUNDED'}">currency_exchange</c:when><c:otherwise>schedule</c:otherwise></c:choose></span>
                                <span>
                                    <small>Trạng thái thanh toán</small>
                                    <strong><c:choose><c:when test="${order.paymentStatus eq 'PAID'}">Đã thanh toán</c:when><c:when test="${order.paymentStatus eq 'FAILED'}">Thanh toán thất bại</c:when><c:when test="${order.paymentStatus eq 'REFUNDED'}">Đã hoàn tiền</c:when><c:when test="${order.paymentStatus eq 'PENDING'}">Chờ thanh toán</c:when><c:otherwise><c:out value="${order.paymentStatus}"/></c:otherwise></c:choose></strong>
                                </span>
                            </div>
                        </section>
                    </aside>
                </div>
                <div class="confirmation-actions"><a class="secondary-button" href="<c:out value='${homeUrl}'/>"><span class="material-symbols-outlined">home</span> Về trang chủ</a><a class="primary-button" href="<c:out value='${productsUrl}'/>">Tiếp tục mua sắm <span class="material-symbols-outlined">arrow_forward</span></a></div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<footer class="site-footer"><div class="shell footer-main"><div><strong class="footer-brand">Gốc Vườn</strong><p>Trái cây tươi hái tận vườn, giao hàng tận nơi.</p></div><nav><a href="<c:out value='${homeUrl}'/>">Trang Chủ</a><a href="<c:out value='${productsUrl}'/>">Cửa Hàng</a><a href="<c:out value='${homeUrl}'/>#about">Về Chúng Tôi</a><a href="<c:out value='${homeUrl}'/>#contact">Liên Hệ</a></nav><span class="hotline"><span class="material-symbols-outlined">call</span>1900 6868</span></div><div class="shell footer-bottom"><span>&copy; 2026 Gốc Vườn Marketplace. Đã đăng ký bản quyền.</span><span>Trái cây sạch cho mọi gia đình.</span></div></footer>
</body>
</html>
