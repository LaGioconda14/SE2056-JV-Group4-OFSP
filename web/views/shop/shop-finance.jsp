<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN" />
<c:url var="financeUrl" value="/shop/finance"/>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Doanh Thu &amp; Rút Tiền - Gốc Vườn Seller Center</title>

        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

        <script src="https://cdn.tailwindcss.com"></script>

        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-orders.css">
    </head>
    <body class="bg-slate-50 text-slate-800 antialiased font-['Inter'] min-h-screen flex m-0">

        <jsp:include page="/views/shop/layout/sidebar.jsp">
            <jsp:param name="activeMenu" value="finance" />
        </jsp:include>

        <div class="flex-1 flex flex-col min-w-0 overflow-y-auto">

            <jsp:include page="/views/shop/layout/header.jsp" />

            <main class="flex-1 p-6 max-w-7xl w-full mx-auto space-y-5">

                <div class="flex flex-col md:flex-row md:items-center justify-between gap-2">
                    <div>
                        <h1 class="text-2xl font-extrabold text-slate-900 tracking-tight">Doanh Thu &amp; Rút Tiền</h1>
                        <p class="text-xs text-slate-500 mt-1">Theo dõi các kỳ quyết toán và tài khoản nhận tiền của gian hàng</p>
                    </div>
                    <span class="self-start text-xs font-bold text-emerald-700 bg-emerald-50 border border-emerald-200/60 px-3 py-1.5 rounded-full">
                        Hoa hồng sàn: <c:out value="${info.commissionRate}"/>%
                    </span>
                </div>


                <c:if test="${not empty sessionScope.shopFlash}">
                    <div class="p-3.5 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm font-semibold"><c:out value="${sessionScope.shopFlash}"/></div>
                    <c:remove var="shopFlash" scope="session"/>
                </c:if>
                <c:if test="${not empty sessionScope.shopError}">
                    <div class="p-3.5 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-sm font-semibold"><c:out value="${sessionScope.shopError}"/></div>
                    <c:remove var="shopError" scope="session"/>
                </c:if>

                <!-- KPI -->
                <section class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
                    <div class="bg-white rounded-2xl p-5 border border-slate-200 shadow-2xs">
                        <p class="text-[11px] font-extrabold tracking-wider text-slate-500 uppercase">Chờ sàn chi trả</p>
                        <p class="mt-2 text-2xl font-extrabold text-amber-600"><fmt:formatNumber value="${summary.processingNet}" type="currency" currencyCode="VND" maxFractionDigits="0"/></p>
                        <p class="text-xs text-slate-500 mt-1">${summary.processingCount} kỳ quyết toán</p>
                    </div>
                    <div class="bg-white rounded-2xl p-5 border border-slate-200 shadow-2xs">
                        <p class="text-[11px] font-extrabold tracking-wider text-slate-500 uppercase">Đang tạm giữ</p>
                        <p class="mt-2 text-2xl font-extrabold text-rose-600"><fmt:formatNumber value="${summary.holdNet}" type="currency" currencyCode="VND" maxFractionDigits="0"/></p>
                        <p class="text-xs text-slate-500 mt-1">${summary.holdCount} kỳ (chờ xử lý khiếu nại)</p>
                    </div>
                    <div class="bg-white rounded-2xl p-5 border border-slate-200 shadow-2xs">
                        <p class="text-[11px] font-extrabold tracking-wider text-slate-500 uppercase">Đã nhận về tài khoản</p>
                        <p class="mt-2 text-2xl font-extrabold text-emerald-700"><fmt:formatNumber value="${summary.paidNet}" type="currency" currencyCode="VND" maxFractionDigits="0"/></p>
                        <p class="text-xs text-slate-500 mt-1">${summary.paidCount} kỳ đã chi trả</p>
                    </div>
                    <div class="bg-white rounded-2xl p-5 border border-slate-200 shadow-2xs">
                        <p class="text-[11px] font-extrabold tracking-wider text-slate-500 uppercase">Hoa hồng đã khấu trừ</p>
                        <p class="mt-2 text-2xl font-extrabold text-slate-800"><fmt:formatNumber value="${summary.commissionPaid}" type="currency" currencyCode="VND" maxFractionDigits="0"/></p>
                        <p class="text-xs text-slate-500 mt-1">Trên các kỳ đã chi trả</p>
                    </div>
                </section>

                <!-- Tài khoản nhận tiền -->
                <section class="bg-white rounded-2xl p-5 border border-slate-200 shadow-2xs">
                    <div class="flex items-start justify-between flex-wrap gap-2 mb-4">
                        <div>
                            <h2 class="font-extrabold text-slate-900 text-sm">Tài khoản nhận tiền quyết toán</h2>
                            <p class="text-xs text-slate-500 mt-0.5">Admin sẽ chuyển doanh thu của từng kỳ vào tài khoản này. Cần cập nhật trước khi được chi trả.</p>
                        </div>
                        <c:if test="${empty info.bankAccount}">
                            <span class="text-[11px] font-bold px-2.5 py-1 rounded-full bg-amber-100 text-amber-800">Chưa cập nhật</span>
                        </c:if>
                    </div>
                    <form method="post" action="<c:out value='${financeUrl}'/>" class="grid grid-cols-1 md:grid-cols-4 gap-3 items-end">
                        <div>
                            <label class="block text-[11px] font-bold text-slate-600 mb-1">Ngân hàng</label>
                            <input type="text" name="bankName" required maxlength="100" value="<c:out value='${info.bankName}'/>" placeholder="VD: Vietcombank"
                                   class="w-full rounded-xl border border-slate-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500/30">
                        </div>
                        <div>
                            <label class="block text-[11px] font-bold text-slate-600 mb-1">Số tài khoản</label>
                            <input type="text" name="bankAccount" required pattern="[0-9]{6,20}" title="6-20 chữ số" value="<c:out value='${info.bankAccount}'/>" placeholder="Chỉ gồm chữ số"
                                   class="w-full rounded-xl border border-slate-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500/30">
                        </div>
                        <div>
                            <label class="block text-[11px] font-bold text-slate-600 mb-1">Chủ tài khoản</label>
                            <input type="text" name="bankHolder" required maxlength="100" value="<c:out value='${info.bankHolder}'/>" placeholder="NGUYEN VAN A"
                                   class="w-full rounded-xl border border-slate-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500/30">
                        </div>
                        <button type="submit" class="px-4 py-2.5 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white text-sm font-bold">Lưu tài khoản</button>
                    </form>
                </section>

                <!-- Lịch sử quyết toán -->
                <section class="bg-white rounded-2xl border border-slate-200 shadow-2xs overflow-hidden">
                    <div class="p-5 flex flex-wrap items-center justify-between gap-3 border-b border-slate-100">
                        <h2 class="font-extrabold text-slate-900 text-sm">Lịch sử quyết toán</h2>
                        <div class="flex flex-wrap gap-2 text-xs font-bold">
                            <a href="<c:out value='${financeUrl}'/>?status=ALL" class="px-3 py-1.5 rounded-full ${status == 'ALL' ? 'bg-emerald-700 text-white' : 'bg-slate-100 text-slate-700 hover:bg-slate-200'}">Tất cả</a>
                            <a href="<c:out value='${financeUrl}'/>?status=PROCESSING" class="px-3 py-1.5 rounded-full ${status == 'PROCESSING' ? 'bg-emerald-700 text-white' : 'bg-slate-100 text-slate-700 hover:bg-slate-200'}">Chờ chi trả</a>
                            <a href="<c:out value='${financeUrl}'/>?status=ON_HOLD" class="px-3 py-1.5 rounded-full ${status == 'ON_HOLD' ? 'bg-emerald-700 text-white' : 'bg-slate-100 text-slate-700 hover:bg-slate-200'}">Tạm giữ</a>
                            <a href="<c:out value='${financeUrl}'/>?status=COMPLETED" class="px-3 py-1.5 rounded-full ${status == 'COMPLETED' ? 'bg-emerald-700 text-white' : 'bg-slate-100 text-slate-700 hover:bg-slate-200'}">Đã chi trả</a>
                        </div>
                    </div>
                    <div class="overflow-x-auto">
                        <table class="w-full text-sm">
                            <thead>
                                <tr class="text-left text-[11px] font-extrabold tracking-wider text-slate-500 uppercase border-b border-slate-100">
                                    <th class="px-5 py-3">Kỳ quyết toán</th>
                                    <th class="px-5 py-3 text-right">Doanh thu</th>
                                    <th class="px-5 py-3 text-right">Hoa hồng</th>
                                    <th class="px-5 py-3 text-right">Khấu trừ KN</th>
                                    <th class="px-5 py-3 text-right">Thực nhận</th>
                                    <th class="px-5 py-3">Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="p" items="${payouts}">
                                    <tr class="border-b border-slate-50 hover:bg-slate-50/60 align-top">
                                        <td class="px-5 py-3.5">
                                            <p class="font-bold text-slate-900"><c:out value="${p.payoutCode}"/></p>
                                            <p class="text-xs text-slate-500"><c:out value="${p.periodLabel}"/> · ${p.totalOrdersCount} đơn</p>
                                        </td>
                                        <td class="px-5 py-3.5 text-right whitespace-nowrap"><fmt:formatNumber value="${p.grossSales}" type="currency" currencyCode="VND" maxFractionDigits="0"/></td>
                                        <td class="px-5 py-3.5 text-right whitespace-nowrap text-rose-600">-<fmt:formatNumber value="${p.commissionWithheld}" type="currency" currencyCode="VND" maxFractionDigits="0"/><br><span class="text-[11px] text-slate-400">${p.commissionRate}%</span></td>
                                        <td class="px-5 py-3.5 text-right whitespace-nowrap ${p.disputeDeductions.signum() > 0 ? 'text-rose-600' : 'text-slate-400'}">-<fmt:formatNumber value="${p.disputeDeductions}" type="currency" currencyCode="VND" maxFractionDigits="0"/></td>
                                        <td class="px-5 py-3.5 text-right whitespace-nowrap font-extrabold text-emerald-700"><fmt:formatNumber value="${p.netPayout}" type="currency" currencyCode="VND" maxFractionDigits="0"/></td>
                                        <td class="px-5 py-3.5 whitespace-nowrap">
                                            <c:choose>
                                                <c:when test="${p.completed}">
                                                    <span class="px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-700 text-xs font-bold">✓ Đã chi trả</span>
                                                    <p class="text-[11px] text-slate-500 mt-1"><c:out value="${p.paidAtFull}"/> · <c:out value="${p.bankName}"/> <c:out value="${p.maskedAccount}"/></p>
                                                </c:when>
                                                <c:when test="${p.onHold}"><span class="px-2.5 py-1 rounded-full bg-rose-50 text-rose-600 text-xs font-bold">⏸ Tạm giữ</span></c:when>
                                                <c:otherwise><span class="px-2.5 py-1 rounded-full bg-amber-50 text-amber-700 text-xs font-bold">⏳ Chờ chi trả</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty payouts}">
                                    <tr><td colspan="6" class="px-5 py-10 text-center text-slate-500">Chưa có kỳ quyết toán nào.</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                    <div class="px-5 py-3 flex items-center justify-between text-xs text-slate-600">
                        <span>Tổng <strong>${totalItems}</strong> kỳ · Trang ${page}/${totalPages}</span>
                        <div class="flex gap-1">
                            <c:if test="${page > 1}"><a class="px-3 py-1.5 rounded-lg bg-slate-100 hover:bg-slate-200 font-bold" href="<c:out value='${financeUrl}'/>?status=${status}&amp;page=${page - 1}">‹ Trước</a></c:if>
                            <c:if test="${page < totalPages}"><a class="px-3 py-1.5 rounded-lg bg-slate-100 hover:bg-slate-200 font-bold" href="<c:out value='${financeUrl}'/>?status=${status}&amp;page=${page + 1}">Sau ›</a></c:if>
                        </div>
                    </div>
                </section>

                <p class="text-xs text-slate-500">
                    Công thức: <strong>Thực nhận = Doanh thu − Hoa hồng sàn − Khấu trừ khiếu nại</strong>.
                    Kỳ bị tạm giữ khi gian hàng có khiếu nại chưa được xử lý.
                </p>

            </main>
        </div>

    </body>
</html>
