<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<c:url var="retryUrl" value="/payment/retry"/>
<c:url var="cancelUrl" value="/payment/cancel"/>
<c:url var="historyUrl" value="/payment/history"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán chưa hoàn tất - Gốc Vườn</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&amp;family=Plus+Jakarta+Sans:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; background: linear-gradient(180deg, #fef2f2 0%, #f8faf9 360px); }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
    </style>
</head>
<body class="text-gray-800 antialiased min-h-screen flex flex-col">
<jsp:include page="/views/common/header.jsp" />

<main class="flex-1 max-w-[760px] w-full mx-auto px-4 py-10">

    <c:if test="${not empty sessionScope.paymentError}">
        <div class="mb-5 p-4 rounded-xl bg-amber-50 border border-amber-200 text-amber-800 text-sm font-semibold flex items-center gap-2" role="alert">
            <span class="material-symbols-outlined">warning</span><c:out value="${sessionScope.paymentError}"/>
        </div>
        <c:remove var="paymentError" scope="session"/>
    </c:if>

    <section class="text-center mb-8">
        <div class="mx-auto w-20 h-20 rounded-full bg-red-500 text-white flex items-center justify-center shadow-lg shadow-red-200">
            <span class="material-symbols-outlined text-[44px]">close</span>
        </div>
        <p class="mt-5 text-xs font-extrabold tracking-[0.2em] text-red-600 uppercase">Thanh toán chưa hoàn tất</p>
        <h1 class="mt-2 text-2xl font-extrabold text-gray-900">${payment.failed ? 'Giao dịch không thành công' : 'Đơn hàng đang chờ thanh toán'}</h1>
        <p class="mt-3 text-sm text-gray-600 max-w-lg mx-auto leading-relaxed">
            Đơn hàng của bạn vẫn được giữ chỗ, không cần đặt lại từ đầu. Bạn có thể thanh toán lại bằng
            <strong>phương thức khác</strong> (VNPay, chuyển khoản hoặc thanh toán khi nhận hàng) hoặc hủy đơn.
        </p>
    </section>

    <section class="bg-white rounded-3xl shadow-lg border border-red-100 p-6 sm:p-8 space-y-5">
        <div class="flex items-center justify-between gap-4">
            <div>
                <p class="text-[11px] font-bold tracking-widest text-gray-400 uppercase">Mã giao dịch</p>
                <p class="mt-1 font-extrabold text-gray-900">#<c:out value="${empty payment.transactionCode ? '—' : payment.transactionCode}"/></p>
                <p class="text-xs text-gray-500 mt-1">Đơn hàng: <strong><c:out value="${payment.orderCode}"/></strong></p>
            </div>
            <div class="text-right">
                <p class="text-[11px] font-bold tracking-widest text-gray-400 uppercase">Số tiền cần thanh toán</p>
                <p class="mt-1 text-xl font-extrabold text-gray-900"><fmt:formatNumber value="${payment.amount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></p>
            </div>
        </div>

        <div class="rounded-2xl bg-red-50 border border-red-100 p-4 flex items-start gap-3 text-sm">
            <span class="material-symbols-outlined text-red-500">error</span>
            <div>
                <p class="font-bold text-red-700">Lý do</p>
                <p class="text-red-700/90"><c:out value="${empty payment.failureReason ? 'Giao dịch chưa được hoàn tất.' : payment.failureReason}"/></p>
            </div>
        </div>

        <c:choose>
            <c:when test="${payment.retryable}">
                <div class="pt-2 grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <!-- Option 1: thanh toán lại -->
                    <form method="post" action="<c:out value='${retryUrl}'/>">
                        <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.cartCsrfToken}'/>">
                        <input type="hidden" name="orderId" value="<c:out value='${payment.orderId}'/>">
                        <label class="block text-xs font-bold text-gray-600 mb-1.5" for="provider">Phương thức thanh toán</label>
                        <select id="provider" name="provider" class="w-full mb-3 rounded-xl border border-gray-200 px-3 py-2.5 text-sm bg-white">
                            <option value="VNPAY" ${payment.paymentProvider == 'VNPAY' ? 'selected' : ''}>VNPay-QR</option>
                            <option value="BANK_TRANSFER" ${payment.paymentProvider == 'BANK_TRANSFER' ? 'selected' : ''}>Chuyển khoản ngân hàng</option>
                            <option value="COD">Thanh toán khi nhận hàng (COD)</option>
                        </select>
                        <button type="submit" class="w-full px-6 py-3 rounded-full bg-[#00652c] hover:bg-[#005323] text-white font-bold text-sm flex items-center justify-center gap-2 shadow-md">
                            <span class="material-symbols-outlined text-[18px]">refresh</span>Tiếp tục thanh toán
                        </button>
                    </form>
                    <!-- Option 2: hủy đơn -->
                    <form method="post" action="<c:out value='${cancelUrl}'/>" onsubmit="return confirm('Bạn chắc chắn muốn hủy đơn hàng này?');" class="flex flex-col justify-end">
                        <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.cartCsrfToken}'/>">
                        <input type="hidden" name="orderId" value="<c:out value='${payment.orderId}'/>">
                        <button type="submit" class="w-full px-6 py-3 rounded-full border border-red-200 text-red-600 hover:bg-red-50 font-bold text-sm flex items-center justify-center gap-2">
                            <span class="material-symbols-outlined text-[18px]">delete</span>Hủy đơn hàng
                        </button>
                    </form>
                </div>
            </c:when>
            <c:otherwise>
                <p class="text-sm text-gray-600">Đơn hàng này không còn ở trạng thái chờ thanh toán.</p>
            </c:otherwise>
        </c:choose>

        <div class="text-center pt-2">
            <a href="<c:out value='${historyUrl}'/>" class="text-sm font-semibold text-[#00652c] hover:underline">Xem lịch sử thanh toán</a>
        </div>
    </section>
</main>
</body>
</html>
