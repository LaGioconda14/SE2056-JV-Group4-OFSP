<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<c:url var="historyUrl" value="/loyalty/history"/>
<c:url var="loyaltyUrl" value="/loyalty"/>
<c:url var="baseQ" value="/loyalty/history">
    <c:param name="type" value="${type}"/>
    <c:param name="from" value="${from}"/>
    <c:param name="to" value="${to}"/>
</c:url>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch sử điểm thưởng - Gốc Vườn</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&amp;family=Plus+Jakarta+Sans:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
    </style>
</head>
<body class="bg-gray-50 text-gray-800 antialiased min-h-screen flex flex-col">
<jsp:include page="/views/common/header.jsp" />

<main class="flex-1 max-w-[1000px] w-full mx-auto px-4 py-8">

    <nav class="text-xs text-gray-500 mb-4 flex items-center gap-2">
        <a href="${pageContext.request.contextPath}/home" class="hover:text-green-700">Trang chủ</a> <span>•</span>
        <a href="<c:out value='${loyaltyUrl}'/>" class="hover:text-green-700">Điểm thưởng</a> <span>•</span>
        <strong class="text-gray-800">Lịch sử điểm</strong>
    </nav>

    <h1 class="text-2xl font-extrabold text-gray-900">Lịch sử điểm thưởng</h1>
    <p class="text-sm text-gray-500 mt-1">Theo dõi mọi lần tích điểm, dùng điểm và điều chỉnh điểm của bạn.</p>

    <!-- Tóm tắt -->
    <section class="grid grid-cols-1 sm:grid-cols-3 gap-4 mt-5">
        <div class="bg-white rounded-2xl border border-gray-100 p-4">
            <p class="text-[11px] font-bold tracking-wider text-gray-400 uppercase">Số dư hiện tại</p>
            <p class="text-2xl font-extrabold text-gray-900 mt-1"><fmt:formatNumber value="${account.currentPoints}"/> <span class="text-sm font-semibold text-gray-500">điểm</span></p>
        </div>
        <div class="bg-white rounded-2xl border border-gray-100 p-4">
            <p class="text-[11px] font-bold tracking-wider text-gray-400 uppercase">Tổng điểm đã nhận</p>
            <p class="text-2xl font-extrabold text-green-700 mt-1">+<fmt:formatNumber value="${totals[0]}"/></p>
        </div>
        <div class="bg-white rounded-2xl border border-gray-100 p-4">
            <p class="text-[11px] font-bold tracking-wider text-gray-400 uppercase">Tổng điểm đã dùng</p>
            <p class="text-2xl font-extrabold text-rose-600 mt-1">-<fmt:formatNumber value="${totals[1]}"/></p>
        </div>
    </section>

    <!-- Bộ lọc -->
    <form method="get" action="<c:out value='${historyUrl}'/>" class="mt-5 bg-white rounded-2xl border border-gray-100 p-4 flex flex-col md:flex-row gap-3 md:items-end">
        <div class="flex-1">
            <label class="block text-[11px] font-bold text-gray-500 mb-1" for="type">Loại giao dịch</label>
            <select id="type" name="type" class="w-full rounded-xl border border-gray-200 px-3 py-2 text-sm bg-white">
                <option value="ALL" ${type == 'ALL' ? 'selected' : ''}>Tất cả</option>
                <option value="EARN" ${type == 'EARN' ? 'selected' : ''}>Tích điểm</option>
                <option value="REDEEM" ${type == 'REDEEM' ? 'selected' : ''}>Dùng điểm</option>
                <option value="RESTORE" ${type == 'RESTORE' ? 'selected' : ''}>Hoàn điểm</option>
                <option value="REVERSE" ${type == 'REVERSE' ? 'selected' : ''}>Thu hồi điểm</option>
                <option value="ADJUST" ${type == 'ADJUST' ? 'selected' : ''}>Điều chỉnh</option>
            </select>
        </div>
        <div>
            <label class="block text-[11px] font-bold text-gray-500 mb-1" for="from">Từ ngày</label>
            <input id="from" type="date" name="from" value="<c:out value='${from}'/>" class="rounded-xl border border-gray-200 px-3 py-2 text-sm">
        </div>
        <div>
            <label class="block text-[11px] font-bold text-gray-500 mb-1" for="to">Đến ngày</label>
            <input id="to" type="date" name="to" value="<c:out value='${to}'/>" class="rounded-xl border border-gray-200 px-3 py-2 text-sm">
        </div>
        <div class="flex gap-2">
            <button type="submit" class="px-5 py-2 rounded-xl bg-green-700 hover:bg-green-800 text-white text-sm font-bold">Lọc</button>
            <a href="<c:out value='${historyUrl}'/>" class="px-4 py-2 rounded-xl bg-gray-100 hover:bg-gray-200 text-gray-700 text-sm font-bold">Đặt lại</a>
        </div>
    </form>
    <c:if test="${not empty filterError}">
        <p class="mt-2 text-sm text-rose-600 font-semibold"><c:out value="${filterError}"/></p>
    </c:if>

    <!-- Bảng lịch sử -->
    <section class="mt-5 bg-white rounded-2xl border border-gray-100 overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead>
                    <tr class="text-left text-[11px] font-extrabold tracking-wider text-gray-500 uppercase border-b border-gray-100">
                        <th class="px-5 py-3">Thời gian</th>
                        <th class="px-5 py-3">Nội dung</th>
                        <th class="px-5 py-3">Loại</th>
                        <th class="px-5 py-3 text-right">Điểm</th>
                        <th class="px-5 py-3 text-right">Số dư sau</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="t" items="${transactions}">
                        <tr class="border-b border-gray-50 align-top">
                            <td class="px-5 py-3 whitespace-nowrap text-gray-600"><c:out value="${t.createdAtFull}"/></td>
                            <td class="px-5 py-3">
                                <c:out value="${t.description}"/>
                                <c:if test="${not empty t.orderCode}">
                                    <a href="${pageContext.request.contextPath}/order/confirmation?orderId=${t.orderId}" class="block text-xs text-green-700 font-semibold hover:underline">Đơn hàng #<c:out value="${t.orderCode}"/></a>
                                </c:if>
                            </td>
                            <td class="px-5 py-3 whitespace-nowrap text-xs font-bold text-gray-600"><c:out value="${t.typeLabel}"/></td>
                            <td class="px-5 py-3 text-right whitespace-nowrap font-extrabold ${t.positive ? 'text-green-700' : 'text-rose-600'}">
                                ${t.positive ? '+' : ''}<fmt:formatNumber value="${t.pointsDelta}"/>
                            </td>
                            <td class="px-5 py-3 text-right whitespace-nowrap text-gray-600">
                                <c:if test="${t.balanceAfter != null}"><fmt:formatNumber value="${t.balanceAfter}"/></c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty transactions}">
                        <tr><td colspan="5" class="px-5 py-12 text-center text-gray-500">
                            <span class="material-symbols-outlined text-[40px] text-gray-300 block mb-2">receipt_long</span>
                            Chưa có giao dịch điểm nào phù hợp.
                        </td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
        <div class="px-5 py-3 flex flex-col sm:flex-row items-center justify-between gap-2 text-xs text-gray-600">
            <span>Tổng <strong>${totalItems}</strong> giao dịch · Trang ${page}/${totalPages}</span>
            <div class="flex items-center gap-1">
                <c:if test="${page > 1}"><a class="px-3 py-1.5 rounded-lg bg-gray-100 hover:bg-gray-200 font-bold" href="<c:out value='${baseQ}'/>&amp;page=${page - 1}">‹ Trước</a></c:if>
                <c:forEach begin="1" end="${totalPages}" var="i">
                    <c:if test="${i == 1 or i == totalPages or (i >= page - 2 and i <= page + 2)}">
                        <a class="px-3 py-1.5 rounded-lg ${i == page ? 'bg-green-700 text-white font-bold' : 'bg-gray-100 hover:bg-gray-200'}" href="<c:out value='${baseQ}'/>&amp;page=${i}">${i}</a>
                    </c:if>
                </c:forEach>
                <c:if test="${page < totalPages}"><a class="px-3 py-1.5 rounded-lg bg-gray-100 hover:bg-gray-200 font-bold" href="<c:out value='${baseQ}'/>&amp;page=${page + 1}">Sau ›</a></c:if>
            </div>
        </div>
    </section>
</main>
</body>
</html>
