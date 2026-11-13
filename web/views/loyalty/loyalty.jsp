<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<c:url var="historyUrl" value="/loyalty/history"/>
<c:url var="benefitsUrl" value="/loyalty/benefits"/>
<c:url var="productsUrl" value="/products"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Điểm thưởng &amp; hạng thành viên - Gốc Vườn</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&amp;family=Plus+Jakarta+Sans:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
        .material-symbols-outlined.filled { font-variation-settings: 'FILL' 1, 'wght' 500, 'GRAD' 0, 'opsz' 24; }
    </style>
</head>
<body class="bg-gray-50 text-gray-800 antialiased min-h-screen flex flex-col">
<jsp:include page="/views/common/header.jsp" />

<main class="flex-1 max-w-[1000px] w-full mx-auto px-4 py-8">

    <nav class="text-xs text-gray-500 mb-4 flex items-center gap-2">
        <a href="${pageContext.request.contextPath}/home" class="hover:text-green-700">Trang chủ</a> <span>•</span>
        <a href="${pageContext.request.contextPath}/profile" class="hover:text-green-700">Tài khoản</a> <span>•</span>
        <strong class="text-gray-800">Điểm thưởng</strong>
    </nav>

    <c:choose>
        <c:when test="${empty account}">
            <div class="bg-white rounded-2xl border border-gray-100 p-10 text-center text-gray-500">
                Không tải được thông tin điểm thưởng. Vui lòng thử lại sau.
            </div>
        </c:when>
        <c:otherwise>

            <!-- ============ F1: Điểm thưởng & số dư ============ -->
            <section class="rounded-3xl p-6 sm:p-8 text-white shadow-lg" style="background: linear-gradient(135deg, #14532d 0%, <c:out value='${account.tier.badgeColor}'/> 160%);">
                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
                    <div>
                        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/20 text-xs font-bold">
                            <span class="material-symbols-outlined filled text-[16px]">workspace_premium</span>
                            Hạng <c:out value="${account.tier.tierName}"/>
                        </span>
                        <p class="mt-4 text-xs font-bold tracking-widest uppercase text-white/70">Điểm hiện có</p>
                        <p class="text-5xl font-extrabold leading-tight"><fmt:formatNumber value="${account.currentPoints}"/> <span class="text-lg font-semibold text-white/80">điểm</span></p>
                        <p class="mt-1 text-sm text-white/85">
                            Tương đương <strong><fmt:formatNumber value="${account.pointValueVnd}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong>
                            giảm giá khi thanh toán
                        </p>
                    </div>
                    <div class="sm:w-72">
                        <c:choose>
                            <c:when test="${account.topTier}">
                                <p class="text-sm font-semibold">Bạn đang ở hạng cao nhất</p>
                                <p class="text-xs text-white/75 mt-1">Cảm ơn bạn đã đồng hành cùng Gốc Vườn!</p>
                            </c:when>
                            <c:otherwise>
                                <p class="text-sm font-semibold">Còn <fmt:formatNumber value="${account.pointsToNextTier}"/> điểm nữa để lên hạng <c:out value="${account.nextTier.tierName}"/></p>
                            </c:otherwise>
                        </c:choose>
                        <div class="mt-2 h-2.5 rounded-full bg-white/25 overflow-hidden" role="progressbar" aria-valuenow="${account.progressPercent}" aria-valuemin="0" aria-valuemax="100">
                            <div class="h-full rounded-full bg-white" style="width: ${account.progressPercent}%"></div>
                        </div>
                        <p class="text-[11px] text-white/70 mt-1.5">Thành viên từ <c:out value="${account.memberSince}"/></p>
                    </div>
                </div>
                <div class="mt-6 flex flex-wrap gap-3">
                    <a href="<c:out value='${historyUrl}'/>" class="px-5 py-2.5 rounded-full bg-white text-green-800 font-bold text-sm flex items-center gap-2 hover:bg-green-50">
                        <span class="material-symbols-outlined text-[18px]">history</span>Xem lịch sử điểm</a>
                    <a href="<c:out value='${benefitsUrl}'/>" class="px-5 py-2.5 rounded-full bg-white/15 hover:bg-white/25 font-bold text-sm flex items-center gap-2">
                        <span class="material-symbols-outlined text-[18px]">info</span>Cách tích &amp; dùng điểm</a>
                </div>
            </section>

            <!-- ============ F6: Hạng thành viên & tiến độ ============ -->
            <section class="mt-6 bg-white rounded-3xl border border-gray-100 shadow-sm p-6 sm:p-8">
                <h2 class="text-lg font-extrabold text-gray-900">Hạng thành viên của bạn</h2>
                <p class="text-xs text-gray-500 mt-1">Hạng được xét theo <strong>tổng điểm đã tích luỹ</strong> nên việc tiêu điểm không làm bạn tụt hạng.</p>

                <div class="mt-5 grid grid-cols-1 sm:grid-cols-3 gap-4 text-sm">
                    <div class="rounded-2xl border border-gray-100 p-4">
                        <p class="text-[11px] font-bold tracking-wider text-gray-400 uppercase">Hạng hiện tại</p>
                        <p class="mt-1.5 flex items-center gap-2 font-extrabold text-gray-900">
                            <span class="material-symbols-outlined filled text-[26px]" style="color: <c:out value='${account.tier.badgeColor}'/>">workspace_premium</span>
                            <c:out value="${account.tier.tierName}"/>
                        </p>
                        <p class="text-xs text-gray-500 mt-1">Từ <fmt:formatNumber value="${account.tier.minPoints}"/> điểm tích luỹ</p>
                    </div>
                    <div class="rounded-2xl border border-gray-100 p-4">
                        <p class="text-[11px] font-bold tracking-wider text-gray-400 uppercase">Điểm tích luỹ</p>
                        <p class="mt-1.5 font-extrabold text-gray-900 text-xl"><fmt:formatNumber value="${account.lifetimePoints}"/></p>
                        <p class="text-xs text-gray-500 mt-1">
                            <c:choose>
                                <c:when test="${account.topTier}">Hạng cao nhất</c:when>
                                <c:otherwise>Hạng kế tiếp: <strong><c:out value="${account.nextTier.tierName}"/></strong>
                                    (còn <fmt:formatNumber value="${account.pointsToNextTier}"/> điểm)</c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                    <div class="rounded-2xl border border-gray-100 p-4">
                        <p class="text-[11px] font-bold tracking-wider text-gray-400 uppercase">Quyền lợi hạng này</p>
                        <p class="mt-1.5 text-sm font-semibold text-gray-900">Tích điểm <c:out value="${account.tier.multiplierLabel}"/></p>
                        <p class="text-xs text-gray-500 mt-1"><c:out value="${account.tier.redeemCapLabel}"/></p>
                    </div>
                </div>

                <!-- Thang hạng -->
                <ol class="mt-6 flex flex-col sm:flex-row gap-3">
                    <c:forEach var="t" items="${tiers}">
                        <li class="flex-1 rounded-2xl border p-3 text-center ${t.tierCode == account.tier.tierCode ? 'border-green-500 bg-green-50' : 'border-gray-100'}">
                            <span class="material-symbols-outlined filled text-[24px]" style="color: <c:out value='${t.badgeColor}'/>">workspace_premium</span>
                            <p class="text-sm font-bold text-gray-900"><c:out value="${t.tierName}"/></p>
                            <p class="text-[11px] text-gray-500"><fmt:formatNumber value="${t.minPoints}"/>+ điểm</p>
                            <c:if test="${t.tierCode == account.tier.tierCode}"><p class="text-[11px] font-bold text-green-700 mt-0.5">Hạng của bạn</p></c:if>
                        </li>
                    </c:forEach>
                </ol>
            </section>

            <div class="mt-6 text-center">
                <a href="<c:out value='${productsUrl}'/>" class="inline-flex items-center gap-2 px-6 py-3 rounded-full bg-green-700 hover:bg-green-800 text-white font-bold text-sm">
                    <span class="material-symbols-outlined text-[18px]">shopping_basket</span>Mua sắm để tích thêm điểm</a>
                <p class="text-xs text-gray-500 mt-2">Mỗi <fmt:formatNumber value="${settings.earnVndPerPoint}"/>đ của đơn hàng hoàn tất được 1 điểm.</p>
            </div>
        </c:otherwise>
    </c:choose>
</main>
</body>
</html>
