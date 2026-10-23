<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<c:url var="gatewayUrl" value="/payment/gateway"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cổng thanh toán VNPay (Mô phỏng)</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&amp;family=Plus+Jakarta+Sans:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; background: #eef2f7; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
    </style>
</head>
<body class="min-h-screen flex items-center justify-center p-4 text-gray-800">

<div class="w-full max-w-[460px]">
    <div class="mb-3 rounded-xl bg-amber-100 border border-amber-300 text-amber-900 text-xs font-bold px-4 py-2 flex items-center gap-2">
        <span class="material-symbols-outlined text-[18px]">science</span>
        CỔNG THANH TOÁN GIẢ LẬP - dùng cho đồ án, không phát sinh giao dịch thật.
    </div>

    <div class="bg-white rounded-3xl shadow-xl overflow-hidden">
        <div class="bg-[#005baa] text-white px-6 py-4 flex items-center justify-between">
            <span class="text-xl font-extrabold tracking-tight">VN<span class="text-[#ed1c24]">PAY</span></span>
            <span class="text-xs font-semibold opacity-90">Còn lại <strong id="countdown">--:--</strong></span>
        </div>

        <div class="p-6 space-y-5">
            <div class="text-center">
                <p class="text-xs font-bold tracking-widest text-gray-400 uppercase">Số tiền thanh toán</p>
                <p class="mt-1 text-3xl font-extrabold text-[#005baa]"><fmt:formatNumber value="${gwAmount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></p>
                <p class="mt-1 text-sm text-gray-500"><c:out value="${gwOrderInfo}"/></p>
                <p class="text-xs text-gray-400 mt-1">Mã giao dịch: <strong class="text-gray-600"><c:out value="${gwTxnRef}"/></strong></p>
            </div>

            <c:choose>
                <c:when test="${gwBankTransfer}">
                    <div class="rounded-2xl border border-gray-200 divide-y divide-gray-100 text-sm">
                        <div class="flex justify-between px-4 py-3"><span class="text-gray-500">Ngân hàng</span><strong>Vietcombank (mô phỏng)</strong></div>
                        <div class="flex justify-between px-4 py-3"><span class="text-gray-500">Số tài khoản</span><strong>0123 456 789</strong></div>
                        <div class="flex justify-between px-4 py-3"><span class="text-gray-500">Chủ tài khoản</span><strong>CTY FRESHFRUIT</strong></div>
                        <div class="flex justify-between px-4 py-3"><span class="text-gray-500">Nội dung CK</span><strong class="text-[#005baa]"><c:out value="${gwTxnRef}"/></strong></div>
                    </div>
                    <p class="text-xs text-gray-500 text-center">Chuyển khoản đúng số tiền và nội dung, sau đó bấm xác nhận bên dưới.</p>
                </c:when>
                <c:otherwise>
                    <div class="flex justify-center">
                        <canvas id="qr" width="200" height="200" class="rounded-2xl border border-gray-200 p-2"></canvas>
                    </div>
                    <p class="text-xs text-gray-500 text-center">Quét mã bằng ứng dụng ngân hàng hoặc ví điện tử để thanh toán.</p>
                </c:otherwise>
            </c:choose>

            <!-- Giả lập kết quả mà khách thực hiện trên cổng -->
            <form method="post" action="<c:out value='${gatewayUrl}'/>" id="gw-form" class="space-y-2.5">
                <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.cartCsrfToken}'/>">
                <c:forEach var="e" items="${gwParams}">
                    <input type="hidden" name="<c:out value='${e.key}'/>" value="<c:out value='${e.value}'/>">
                </c:forEach>
                <button type="submit" name="result" value="SUCCESS" class="w-full py-3 rounded-xl bg-[#00652c] hover:bg-[#005323] text-white font-bold text-sm flex items-center justify-center gap-2">
                    <span class="material-symbols-outlined text-[18px]">task_alt</span>
                    ${gwBankTransfer ? 'Tôi đã chuyển khoản' : 'Giả lập: Thanh toán thành công'}
                </button>
                <button type="submit" name="result" value="INSUFFICIENT" class="w-full py-2.5 rounded-xl bg-white border border-gray-200 hover:bg-gray-50 text-gray-700 font-semibold text-sm">
                    Giả lập: Tài khoản không đủ số dư
                </button>
                <button type="submit" name="result" value="CANCEL" class="w-full py-2.5 rounded-xl text-red-600 hover:bg-red-50 font-semibold text-sm">
                    Hủy giao dịch
                </button>
            </form>
        </div>
    </div>
</div>

<script>
    // Đếm ngược tới thời điểm hết hạn; hết giờ thì tải lại để server trả mã timeout (15).
    const expireAt = ${gwExpireMillis};
    const cd = document.getElementById('countdown');
    function tick() {
        const left = Math.max(0, Math.floor((expireAt - Date.now()) / 1000));
        cd.textContent = String(Math.floor(left / 60)).padStart(2, '0') + ':' + String(left % 60).padStart(2, '0');
        if (left === 0) { location.reload(); }
    }
    tick(); setInterval(tick, 1000);

    // Vẽ mã QR giả (chỉ để minh họa, được sinh cố định theo mã giao dịch).
    const canvas = document.getElementById('qr');
    if (canvas) {
        const ctx = canvas.getContext('2d'), n = 25, cell = canvas.width / n;
        let seed = 0; const ref = '<c:out value="${gwTxnRef}"/>';
        for (let i = 0; i < ref.length; i++) seed = (seed * 31 + ref.charCodeAt(i)) >>> 0;
        const rnd = () => (seed = (seed * 1664525 + 1013904223) >>> 0) / 4294967296;
        ctx.fillStyle = '#fff'; ctx.fillRect(0, 0, canvas.width, canvas.height);
        ctx.fillStyle = '#111';
        const finder = (x, y) => { ctx.fillRect(x * cell, y * cell, 7 * cell, 7 * cell); ctx.fillStyle = '#fff'; ctx.fillRect((x + 1) * cell, (y + 1) * cell, 5 * cell, 5 * cell); ctx.fillStyle = '#111'; ctx.fillRect((x + 2) * cell, (y + 2) * cell, 3 * cell, 3 * cell); };
        const inFinder = (x, y) => (x < 8 && y < 8) || (x > n - 9 && y < 8) || (x < 8 && y > n - 9);
        for (let y = 0; y < n; y++) for (let x = 0; x < n; x++) if (!inFinder(x, y) && rnd() > 0.52) ctx.fillRect(x * cell, y * cell, cell, cell);
        finder(0, 0); finder(n - 7, 0); finder(0, n - 7);
    }
</script>
</body>
</html>
