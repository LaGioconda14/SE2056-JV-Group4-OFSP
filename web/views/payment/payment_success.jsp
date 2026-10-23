<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<c:url var="homeUrl" value="/home"/>
<c:url var="productsUrl" value="/products"/>
<c:url var="historyUrl" value="/payment/history"/>
<c:url var="orderUrl" value="/order/confirmation"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán thành công - Gốc Vườn</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&amp;family=Plus+Jakarta+Sans:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; background: linear-gradient(180deg, #ecfdf3 0%, #f8faf9 360px); }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
    </style>
</head>
<body class="text-gray-800 antialiased min-h-screen flex flex-col">
<jsp:include page="/views/common/header.jsp" />

<main class="flex-1 max-w-[860px] w-full mx-auto px-4 py-10">

    <!-- Hero -->
    <section class="text-center mb-8">
        <div class="mx-auto w-20 h-20 rounded-full bg-[#00652c] text-white flex items-center justify-center shadow-lg shadow-emerald-200">
            <span class="material-symbols-outlined text-[44px]">check</span>
        </div>
        <p class="mt-5 text-xs font-extrabold tracking-[0.2em] text-[#00652c] uppercase">Giao dịch trực tuyến thành công</p>
        <h1 class="mt-2 text-2xl font-extrabold text-gray-900">Thanh toán thành công!</h1>
        <p class="mt-3 text-sm text-gray-600 max-w-xl mx-auto leading-relaxed">
            Cảm ơn bạn đã tin chọn FreshFruit. Đơn hàng đã được tiếp nhận và nhà vườn đang chuẩn bị thu hoạch, đóng gói
            những giỏ trái cây tươi ngon gửi đến bạn.
        </p>
    </section>

    <!-- Biên lai -->
    <section class="bg-white rounded-3xl shadow-xl shadow-emerald-100/60 overflow-hidden border border-emerald-100">
        <div class="bg-[#00652c] text-white px-6 py-3.5 flex items-center justify-between text-sm font-bold">
            <span class="flex items-center gap-2"><span class="material-symbols-outlined text-[20px]">receipt_long</span>BIÊN LAI THU NGÂN ĐIỆN TỬ</span>
            <span class="hidden sm:flex items-center gap-1.5 text-xs font-semibold opacity-90"><span class="material-symbols-outlined text-[16px]">lock</span>Bảo mật chuẩn HMAC-SHA512</span>
        </div>

        <div class="p-6 sm:p-8 space-y-7">
            <div class="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
                <div>
                    <p class="text-[11px] font-bold tracking-widest text-gray-400 uppercase">Mã giao dịch</p>
                    <p class="mt-1 text-lg font-extrabold text-gray-900 flex items-center gap-2">
                        <span id="txn-code">#<c:out value="${payment.transactionCode}"/></span>
                        <button type="button" onclick="copyTxn()" class="text-gray-400 hover:text-[#00652c]" title="Sao chép mã giao dịch">
                            <span class="material-symbols-outlined text-[18px]">content_copy</span>
                        </button>
                    </p>
                    <p class="mt-1 text-xs text-gray-500">Đơn hàng: <strong><c:out value="${payment.orderCode}"/></strong></p>
                </div>
                <div class="sm:text-right">
                    <p class="text-[11px] font-bold tracking-widest text-gray-400 uppercase">Tổng tiền đã thanh toán</p>
                    <p class="mt-1 text-2xl font-extrabold text-[#00652c]"><fmt:formatNumber value="${payment.amount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></p>
                    <p class="text-xs text-emerald-700 font-semibold flex sm:justify-end items-center gap-1"><span class="material-symbols-outlined text-[14px]">task_alt</span>Đã thanh toán đầy đủ</p>
                </div>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-3 gap-5 pt-5 border-t border-gray-100 text-sm">
                <div>
                    <p class="text-[11px] font-bold tracking-widest text-gray-400 uppercase">Phương thức thanh toán</p>
                    <p class="mt-1.5 font-bold text-gray-900"><c:out value="${payment.providerLabel}"/></p>
                    <p class="text-xs text-gray-500">Thanh toán tức thời</p>
                </div>
                <div>
                    <p class="text-[11px] font-bold tracking-widest text-gray-400 uppercase">Thời gian ghi nhận</p>
                    <p class="mt-1.5 font-bold text-gray-900"><c:out value="${payment.paidTime}"/></p>
                    <p class="text-xs text-gray-500"><c:out value="${payment.paidDate}"/></p>
                </div>
                <div>
                    <p class="text-[11px] font-bold tracking-widest text-gray-400 uppercase">Trạng thái xử lý</p>
                    <p class="mt-1.5 font-bold text-emerald-700 flex items-center gap-1.5"><span class="material-symbols-outlined text-[18px]">check_circle</span>Đã hoàn tất</p>
                    <p class="text-xs text-gray-500">Đơn đã chuyển tới nhà vườn</p>
                </div>
            </div>

            <c:if test="${not empty order and not empty order.shippingAddress}">
                <div class="flex items-start gap-3 pt-5 border-t border-gray-100 text-sm">
                    <span class="material-symbols-outlined text-[#00652c] bg-emerald-50 rounded-xl p-2">local_shipping</span>
                    <div>
                        <p class="text-[11px] font-bold tracking-widest text-gray-400 uppercase">Địa chỉ nhận hàng</p>
                        <p class="mt-1 font-bold text-gray-900"><c:out value="${order.shippingAddress.recipientName}"/> <span class="font-normal text-gray-500">(<c:out value="${order.shippingAddress.recipientPhone}"/>)</span></p>
                        <p class="text-gray-600"><c:out value="${order.shippingAddress.fullAddress}"/></p>
                    </div>
                </div>
            </c:if>

            <c:if test="${not empty order and not empty order.subOrders}">
                <div class="pt-5 border-t border-gray-100">
                    <p class="text-[11px] font-bold tracking-widest text-gray-400 uppercase mb-3">Sản phẩm trong đơn hàng</p>
                    <div class="space-y-2.5">
                        <c:forEach var="sub" items="${order.subOrders}">
                            <c:forEach var="item" items="${sub.items}">
                                <div class="flex items-center justify-between gap-4 text-sm">
                                    <div class="min-w-0">
                                        <p class="font-semibold text-gray-900 truncate"><c:out value="${item.productNameSnapshot}"/></p>
                                        <p class="text-xs text-gray-500"><c:out value="${item.variantNameSnapshot}"/> × <c:out value="${item.quantity}"/> · <c:out value="${sub.shopName}"/></p>
                                    </div>
                                    <strong class="shrink-0"><fmt:formatNumber value="${item.totalPrice}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong>
                                </div>
                            </c:forEach>
                        </c:forEach>
                    </div>
                </div>
            </c:if>
        </div>
    </section>

    <div class="mt-8 flex flex-col sm:flex-row items-center justify-center gap-3">
        <a href="<c:out value='${orderUrl}'/>?orderId=${payment.orderId}" class="w-full sm:w-auto px-7 py-3 rounded-full bg-white border border-gray-200 hover:bg-gray-50 font-bold text-sm text-gray-800 flex items-center justify-center gap-2">
            <span class="material-symbols-outlined text-[18px]">description</span>Xem chi tiết đơn hàng</a>
        <a href="<c:out value='${historyUrl}'/>" class="w-full sm:w-auto px-7 py-3 rounded-full bg-white border border-gray-200 hover:bg-gray-50 font-bold text-sm text-gray-800 flex items-center justify-center gap-2">
            <span class="material-symbols-outlined text-[18px]">history</span>Lịch sử thanh toán</a>
        <a href="<c:out value='${productsUrl}'/>" class="w-full sm:w-auto px-8 py-3 rounded-full bg-[#00652c] hover:bg-[#005323] text-white font-bold text-sm flex items-center justify-center gap-2 shadow-md">
            <span class="material-symbols-outlined text-[18px]">storefront</span>Tiếp tục mua sắm</a>
    </div>

    <!-- Quy trình -->
    <section class="mt-12">
        <h2 class="font-extrabold text-gray-900">Quy trình thu hoạch &amp; giao nhận</h2>
        <p class="text-sm text-gray-500 mb-4">Đơn hàng của bạn được điều phối qua 4 bước chuẩn kiểm định</p>
        <div class="grid grid-cols-2 lg:grid-cols-4 gap-3">
            <div class="bg-white rounded-2xl p-4 border-t-4 border-[#00652c] shadow-sm"><p class="font-bold text-sm">1. Xác nhận đơn</p><p class="text-xs text-gray-500 mt-1">Hệ thống đã nhận lệnh và điều phối tới nhà vườn liên kết.</p></div>
            <div class="bg-white rounded-2xl p-4 shadow-sm"><p class="font-bold text-sm">2. Hái tươi tại vườn</p><p class="text-xs text-gray-500 mt-1">Chọn lọc từng quả đạt độ chín và độ mọng nước tối ưu.</p></div>
            <div class="bg-white rounded-2xl p-4 shadow-sm"><p class="font-bold text-sm">3. Đóng thùng bảo ôn</p><p class="text-xs text-gray-500 mt-1">Chèn đệm giấy sinh học và túi gel giữ lạnh tiêu chuẩn cao.</p></div>
            <div class="bg-white rounded-2xl p-4 shadow-sm"><p class="font-bold text-sm">4. Giao hỏa tốc</p><p class="text-xs text-gray-500 mt-1">Shipper nội thành trao tận tay với trạng thái trái cây tươi mát.</p></div>
        </div>
    </section>
</main>

<script>
    function copyTxn() {
        const text = document.getElementById('txn-code').textContent.replace('#', '').trim();
        if (navigator.clipboard) navigator.clipboard.writeText(text);
    }
</script>
</body>
</html>
