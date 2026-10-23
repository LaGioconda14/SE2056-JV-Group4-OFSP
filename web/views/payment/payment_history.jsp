<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<c:url var="historyUrl" value="/payment/history"/>
<c:url var="retryUrl" value="/payment/retry"/>
<c:url var="successUrl" value="/payment/success"/>
<c:url var="orderUrl" value="/order/confirmation"/>
<c:url var="baseQ" value="/payment/history">
    <c:param name="q" value="${q}"/>
    <c:param name="method" value="${method}"/>
    <c:param name="days" value="${days}"/>
</c:url>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch sử thanh toán - Gốc Vườn</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&amp;family=Plus+Jakarta+Sans:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; background: #f6f8f7; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
    </style>
</head>
<body class="text-gray-800 antialiased min-h-screen flex flex-col">
<jsp:include page="/views/common/header.jsp" />

<main class="flex-1 max-w-[1100px] w-full mx-auto px-4 py-8">

    <nav class="text-xs text-gray-500 mb-4 flex items-center gap-2">
        <a href="${pageContext.request.contextPath}/home" class="hover:text-[#00652c]">Trang chủ</a> <span>•</span>
        <a href="${pageContext.request.contextPath}/profile" class="hover:text-[#00652c]">Tài khoản</a> <span>•</span>
        <strong class="text-gray-800">Lịch sử thanh toán</strong>
    </nav>

    <c:if test="${not empty sessionScope.paymentNotice}">
        <div class="mb-4 p-3.5 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm font-semibold flex items-center gap-2">
            <span class="material-symbols-outlined">check_circle</span><c:out value="${sessionScope.paymentNotice}"/>
        </div>
        <c:remove var="paymentNotice" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.paymentError}">
        <div class="mb-4 p-3.5 rounded-xl bg-red-50 border border-red-200 text-red-700 text-sm font-semibold flex items-center gap-2">
            <span class="material-symbols-outlined">error</span><c:out value="${sessionScope.paymentError}"/>
        </div>
        <c:remove var="paymentError" scope="session"/>
    </c:if>

    <div class="flex flex-col sm:flex-row sm:items-end justify-between gap-4 mb-6">
        <div>
            <h1 class="text-2xl font-extrabold text-gray-900">Lịch sử thanh toán &amp; Giao dịch</h1>
            <p class="text-sm text-gray-500 mt-1">Theo dõi và tra cứu toàn bộ biên lai, phương thức và trạng thái thanh toán đơn hàng của bạn.</p>
        </div>
        <a href="<c:out value='${baseQ}'/>&amp;status=${status}&amp;export=csv"
           class="px-4 py-2 rounded-xl bg-white border border-gray-200 hover:bg-gray-50 text-sm font-semibold flex items-center gap-2 shrink-0">
            <span class="material-symbols-outlined text-[18px]">download</span>Xuất file Excel (CSV)
        </a>
    </div>

    <!-- Thống kê -->
    <section class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <div class="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
            <p class="text-xs font-bold tracking-wider text-gray-500 uppercase">Tổng chi tiêu tích lũy</p>
            <p class="mt-3 text-2xl font-extrabold text-gray-900"><fmt:formatNumber value="${stats.totalPaidAmount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></p>
            <p class="mt-2 text-xs text-gray-500">Chỉ tính các giao dịch thành công</p>
        </div>
        <div class="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
            <p class="text-xs font-bold tracking-wider text-gray-500 uppercase">Giao dịch thành công</p>
            <p class="mt-3 text-2xl font-extrabold text-gray-900"><c:out value="${stats.successCount}"/> <span class="text-sm font-semibold text-gray-500">giao dịch</span></p>
            <span class="mt-2 inline-block px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-700 text-xs font-bold">Tỉ lệ hoàn tất <c:out value="${stats.successRate}"/>%</span>
        </div>
        <div class="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
            <p class="text-xs font-bold tracking-wider text-gray-500 uppercase">Đang chờ xử lý</p>
            <p class="mt-3 text-2xl font-extrabold text-gray-900"><c:out value="${stats.pendingCount}"/> <span class="text-sm font-semibold text-gray-500">giao dịch</span></p>
            <span class="mt-2 inline-block px-2.5 py-1 rounded-full bg-amber-50 text-amber-700 text-xs font-bold">
                <fmt:formatNumber value="${stats.totalPendingAmount}" type="currency" currencyCode="VND" maxFractionDigits="0"/> chờ thu
            </span>
        </div>
        <div class="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
            <p class="text-xs font-bold tracking-wider text-gray-500 uppercase">Phương thức ưa chuộng</p>
            <p class="mt-3 text-base font-extrabold text-gray-900">Online &amp; COD</p>
            <p class="mt-2 text-xs font-bold">
                <span class="text-[#00652c]">Online <c:out value="${stats.onlinePercent}"/>%</span>
                <span class="ml-3 text-gray-700">COD <c:out value="${stats.codPercent}"/>%</span>
            </p>
        </div>
    </section>

    <!-- Bộ lọc -->
    <form method="get" action="<c:out value='${historyUrl}'/>" class="bg-white rounded-2xl p-4 shadow-sm border border-gray-100 mb-4">
        <input type="hidden" name="status" value="<c:out value='${status}'/>">
        <div class="flex flex-col lg:flex-row gap-3">
            <div class="flex-1 relative">
                <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-[20px]">search</span>
                <input type="text" name="q" value="<c:out value='${q}'/>" placeholder="Tìm theo mã giao dịch hoặc mã đơn hàng..."
                       class="w-full pl-10 pr-3 py-2.5 rounded-xl border border-gray-200 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500/30">
            </div>
            <select name="method" class="rounded-xl border border-gray-200 px-3 py-2.5 text-sm bg-white" onchange="this.form.submit()">
                <option value="ALL" ${method == 'ALL' ? 'selected' : ''}>Tất cả phương thức thanh toán</option>
                <option value="COD" ${method == 'COD' ? 'selected' : ''}>COD (Tiền mặt)</option>
                <option value="ONLINE" ${method == 'ONLINE' ? 'selected' : ''}>Tất cả online</option>
                <option value="VNPAY" ${method == 'VNPAY' ? 'selected' : ''}>VNPay-QR</option>
                <option value="BANK_TRANSFER" ${method == 'BANK_TRANSFER' ? 'selected' : ''}>Chuyển khoản</option>
            </select>
            <select name="days" class="rounded-xl border border-gray-200 px-3 py-2.5 text-sm bg-white" onchange="this.form.submit()">
                <option value="7" ${days == 7 ? 'selected' : ''}>7 ngày gần nhất</option>
                <option value="30" ${days == 30 ? 'selected' : ''}>30 ngày gần nhất</option>
                <option value="90" ${days == 90 ? 'selected' : ''}>90 ngày gần nhất</option>
                <option value="365" ${days == 365 ? 'selected' : ''}>1 năm gần nhất</option>
                <option value="0" ${days == 0 ? 'selected' : ''}>Tất cả thời gian</option>
            </select>
            <button type="submit" class="px-5 py-2.5 rounded-xl bg-[#00652c] hover:bg-[#005323] text-white text-sm font-bold">Tìm kiếm</button>
        </div>

        <!-- Tab trạng thái -->
        <div class="mt-4 flex flex-wrap gap-2 text-sm">
            <a href="<c:out value='${baseQ}'/>&amp;status=ALL"
               class="px-3.5 py-1.5 rounded-full font-semibold ${status == 'ALL' ? 'bg-[#00652c] text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'}">Tất cả (${countAll})</a>
            <a href="<c:out value='${baseQ}'/>&amp;status=SUCCESS"
               class="px-3.5 py-1.5 rounded-full font-semibold ${status == 'SUCCESS' ? 'bg-[#00652c] text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'}">Thành công (${countSuccess})</a>
            <a href="<c:out value='${baseQ}'/>&amp;status=PENDING"
               class="px-3.5 py-1.5 rounded-full font-semibold ${status == 'PENDING' ? 'bg-[#00652c] text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'}">Đang xử lý (${countPending})</a>
            <a href="<c:out value='${baseQ}'/>&amp;status=FAILED"
               class="px-3.5 py-1.5 rounded-full font-semibold ${status == 'FAILED' ? 'bg-[#00652c] text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'}">Thất bại (${countFailed})</a>
        </div>
    </form>

    <!-- Bảng giao dịch -->
    <section class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead>
                    <tr class="text-left text-xs font-extrabold tracking-wider text-gray-500 uppercase border-b border-gray-100">
                        <th class="px-5 py-4">Mã giao dịch</th>
                        <th class="px-5 py-4">Ngày tạo</th>
                        <th class="px-5 py-4 text-right">Số tiền</th>
                        <th class="px-5 py-4">Phương thức</th>
                        <th class="px-5 py-4">Trạng thái</th>
                        <th class="px-5 py-4 text-right">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="p" items="${payments}">
                        <tr class="border-b border-gray-50 hover:bg-gray-50/60 align-top">
                            <td class="px-5 py-4">
                                <p class="font-extrabold text-gray-900">#<c:out value="${empty p.transactionCode ? p.orderCode : p.transactionCode}"/></p>
                                <p class="text-xs text-gray-500 mt-1">Đơn hàng <c:out value="${p.orderCode}"/>
                                    <c:if test="${not empty p.itemSummaryShort}">(<c:out value="${p.itemSummaryShort}"/>)</c:if></p>
                            </td>
                            <td class="px-5 py-4 whitespace-nowrap">
                                <p class="font-semibold"><c:out value="${p.createdTime}"/></p>
                                <p class="text-xs text-gray-500"><c:out value="${p.createdDate}"/></p>
                            </td>
                            <td class="px-5 py-4 text-right whitespace-nowrap">
                                <p class="font-extrabold text-gray-900"><fmt:formatNumber value="${p.amount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></p>
                                <p class="text-xs mt-1 ${p.refunded or p.partiallyRefunded ? 'text-sky-700' : (p.failed ? 'text-red-600' : (p.success ? 'text-emerald-700' : 'text-amber-700'))}"><c:out value="${p.note}"/></p>
                            </td>
                            <td class="px-5 py-4 whitespace-nowrap">
                                <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-slate-50 text-slate-700 text-xs font-bold">
                                    <span class="material-symbols-outlined text-[16px]">${p.cod ? 'payments' : 'qr_code_2'}</span><c:out value="${p.providerLabel}"/>
                                </span>
                            </td>
                            <td class="px-5 py-4 whitespace-nowrap">
                                <c:choose>
                                    <c:when test="${p.refunded}"><span class="px-3 py-1 rounded-full bg-sky-50 text-sky-700 text-xs font-bold">↩ Đã hoàn tiền</span></c:when>
                                    <c:when test="${p.partiallyRefunded}"><span class="px-3 py-1 rounded-full bg-sky-50 text-sky-700 text-xs font-bold">↩ Hoàn một phần</span></c:when>
                                    <c:when test="${p.success}"><span class="px-3 py-1 rounded-full bg-emerald-50 text-emerald-700 text-xs font-bold">✓ Thành công</span></c:when>
                                    <c:when test="${p.failed}"><span class="px-3 py-1 rounded-full bg-red-50 text-red-600 text-xs font-bold">✕ Thất bại</span></c:when>
                                    <c:otherwise><span class="px-3 py-1 rounded-full bg-amber-50 text-amber-700 text-xs font-bold">⏳ Đang xử lý</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="px-5 py-4 text-right whitespace-nowrap">
                                <c:choose>
                                    <c:when test="${p.online and p.success}">
                                        <a href="<c:out value='${successUrl}'/>?orderId=${p.orderId}" class="text-xs font-bold text-[#00652c] hover:underline">Xem biên lai</a>
                                    </c:when>
                                    <c:when test="${p.retryable}">
                                        <a href="${pageContext.request.contextPath}/payment/failed?orderId=${p.orderId}"
                                           class="text-xs font-bold px-3 py-1.5 rounded-full bg-[#00652c] text-white hover:bg-[#005323] inline-block">Thanh toán lại</a>
                                    </c:when>
                                    <c:otherwise><span class="text-xs text-gray-400">—</span></c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty payments}">
                        <tr><td colspan="6" class="px-5 py-12 text-center text-gray-500">
                            <span class="material-symbols-outlined text-[40px] text-gray-300 block mb-2">receipt_long</span>
                            Không có giao dịch nào phù hợp với bộ lọc.
                        </td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <!-- Phân trang -->
        <div class="px-5 py-4 flex flex-col sm:flex-row items-center justify-between gap-3 text-sm text-gray-600">
            <span>Hiển thị <strong>${fromItem} - ${toItem}</strong> trong <strong>${totalItems}</strong> giao dịch</span>
            <div class="flex items-center gap-1">
                <c:if test="${page > 1}">
                    <a href="<c:out value='${baseQ}'/>&amp;status=${status}&amp;page=${page - 1}" class="px-3 py-1.5 rounded-lg hover:bg-gray-100">‹</a>
                </c:if>
                <c:forEach begin="1" end="${totalPages}" var="i">
                    <a href="<c:out value='${baseQ}'/>&amp;status=${status}&amp;page=${i}"
                       class="px-3 py-1.5 rounded-lg ${i == page ? 'bg-[#00652c] text-white font-bold' : 'hover:bg-gray-100'}">${i}</a>
                </c:forEach>
                <c:if test="${page < totalPages}">
                    <a href="<c:out value='${baseQ}'/>&amp;status=${status}&amp;page=${page + 1}" class="px-3 py-1.5 rounded-lg hover:bg-gray-100">›</a>
                </c:if>
            </div>
        </div>
    </section>

    <!-- Hỗ trợ -->
    <section class="mt-6 bg-[#00652c] rounded-2xl p-6 text-white flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
            <p class="font-extrabold">Cần đối soát hoặc hỗ trợ giao dịch?</p>
            <p class="text-sm text-emerald-100 mt-1">Mọi thắc mắc về tiền trừ, trạng thái thanh toán hoặc hoàn tiền, vui lòng liên hệ bộ phận tài chính FreshFruit.</p>
        </div>
        <div class="flex gap-3 shrink-0">
            <a href="tel:19006868" class="px-5 py-2.5 rounded-xl bg-white text-[#00652c] font-bold text-sm">Hotline 1900 6868</a>
            <a href="mailto:support@freshfruit.vn?subject=Yeu%20cau%20soat%20xet%20giao%20dich" class="px-5 py-2.5 rounded-xl bg-white/15 hover:bg-white/25 font-bold text-sm">Gửi yêu cầu soát xét</a>
        </div>
    </section>
</main>
</body>
</html>
