<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<c:url var="loyaltyUrl" value="/loyalty"/>
<c:url var="loginUrl" value="/login"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quyền lợi thành viên - Gốc Vườn</title>
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

<main class="flex-1 max-w-[1100px] w-full mx-auto px-4 py-8">

    <nav class="text-xs text-gray-500 mb-4 flex items-center gap-2">
        <a href="${pageContext.request.contextPath}/home" class="hover:text-green-700">Trang chủ</a> <span>•</span>
        <a href="<c:out value='${loyaltyUrl}'/>" class="hover:text-green-700">Điểm thưởng</a> <span>•</span>
        <strong class="text-gray-800">Quyền lợi thành viên</strong>
    </nav>

    <h1 class="text-2xl font-extrabold text-gray-900">Quyền lợi các hạng thành viên</h1>
    <p class="text-sm text-gray-500 mt-1">Mua sắm càng nhiều, hạng càng cao, điểm tích càng nhanh.</p>

    <!-- Cách tích & dùng điểm -->
    <section class="mt-5 grid grid-cols-1 sm:grid-cols-3 gap-4 text-sm">
        <div class="bg-white rounded-2xl border border-gray-100 p-4 flex gap-3">
            <span class="material-symbols-outlined text-green-700 bg-green-50 rounded-xl p-2 h-fit">add_circle</span>
            <div><p class="font-bold text-gray-900">Tích điểm</p>
                <p class="text-gray-500 text-xs mt-0.5">Mỗi <strong><fmt:formatNumber value="${settings.earnVndPerPoint}"/>đ</strong> của đơn hàng hoàn tất được 1 điểm, nhân theo hệ số của hạng.</p></div>
        </div>
        <div class="bg-white rounded-2xl border border-gray-100 p-4 flex gap-3">
            <span class="material-symbols-outlined text-sky-700 bg-sky-50 rounded-xl p-2 h-fit">redeem</span>
            <div><p class="font-bold text-gray-900">Dùng điểm</p>
                <p class="text-gray-500 text-xs mt-0.5">1 điểm = <strong><fmt:formatNumber value="${settings.redeemVndPerPoint}"/>đ</strong> giảm giá ngay ở bước thanh toán.</p></div>
        </div>
        <div class="bg-white rounded-2xl border border-gray-100 p-4 flex gap-3">
            <span class="material-symbols-outlined text-amber-700 bg-amber-50 rounded-xl p-2 h-fit">percent</span>
            <div><p class="font-bold text-gray-900">Giới hạn</p>
                <p class="text-gray-500 text-xs mt-0.5">Mỗi đơn dùng điểm tối đa <strong>${settings.maxRedeemPercent}%</strong> giá trị đơn (hạng cao có thể cao hơn).</p></div>
        </div>
    </section>

    <!-- So sánh các hạng -->
    <section class="mt-6 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <c:forEach var="t" items="${tiers}">
            <article class="bg-white rounded-3xl border p-5 flex flex-col ${(not empty account and t.tierCode == account.tier.tierCode) ? 'border-green-500 ring-2 ring-green-100' : 'border-gray-100'}">
                <div class="flex items-center justify-between">
                    <span class="material-symbols-outlined filled text-[32px]" style="color: <c:out value='${t.badgeColor}'/>">workspace_premium</span>
                    <c:if test="${not empty account and t.tierCode == account.tier.tierCode}">
                        <span class="text-[11px] font-bold px-2.5 py-1 rounded-full bg-green-100 text-green-800">Hạng của bạn</span>
                    </c:if>
                </div>
                <h2 class="mt-3 text-lg font-extrabold text-gray-900"><c:out value="${t.tierName}"/></h2>
                <p class="text-xs text-gray-500">Từ <strong><fmt:formatNumber value="${t.minPoints}"/></strong> điểm tích luỹ</p>
                <dl class="mt-4 space-y-2 text-sm flex-1">
                    <div class="flex justify-between"><dt class="text-gray-500">Hệ số tích điểm</dt><dd class="font-bold"><c:out value="${t.multiplierLabel}"/></dd></div>
                    <div class="flex justify-between gap-2"><dt class="text-gray-500">Dùng điểm</dt><dd class="font-bold text-right"><c:out value="${t.redeemCapLabel}"/></dd></div>
                </dl>
                <c:if test="${not empty t.description}"><p class="mt-3 text-xs text-gray-500"><c:out value="${t.description}"/></p></c:if>
            </article>
        </c:forEach>
        <c:if test="${empty tiers}">
            <p class="col-span-full text-center text-gray-500 py-10">Chưa có hạng thành viên nào được thiết lập.</p>
        </c:if>
    </section>

    <div class="mt-8 text-center">
        <c:choose>
            <c:when test="${not empty account}">
                <a href="<c:out value='${loyaltyUrl}'/>" class="inline-flex items-center gap-2 px-6 py-3 rounded-full bg-green-700 hover:bg-green-800 text-white font-bold text-sm">
                    <span class="material-symbols-outlined text-[18px]">trending_up</span>Xem tiến độ của tôi</a>
            </c:when>
            <c:otherwise>
                <a href="<c:out value='${loginUrl}'/>" class="inline-flex items-center gap-2 px-6 py-3 rounded-full bg-green-700 hover:bg-green-800 text-white font-bold text-sm">Đăng nhập để xem hạng của bạn</a>
            </c:otherwise>
        </c:choose>
    </div>
</main>
</body>
</html>
