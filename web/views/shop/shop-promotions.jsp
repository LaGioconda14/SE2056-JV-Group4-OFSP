<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Khuyến mãi (Promotion) - Kênh Người Bán</title>
    <jsp:include page="/views/shop/layout/head.jsp" />
    <link rel="stylesheet" href="${ctx}/assets/css/shop-marketing.css"/>
    <script src="${ctx}/assets/js/shop-marketing.js" defer></script>
</head>
<body class="bg-[#f8fafc] text-[#0f172a]">

    <jsp:include page="/views/shop/layout/sidebar.jsp"><jsp:param name="active" value="promotions" /></jsp:include>
    <jsp:include page="/views/shop/layout/header.jsp" />

    <main class="shop-main-wrapper">
        <div class="shop-content-container">

            <jsp:include page="/views/shop/layout/mk-flash.jsp" />

            <nav class="flex items-center gap-2 text-xs text-slate-500 font-medium">
                <span>Kênh Người Bán</span>
                <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                <span>Tiếp thị &amp; Khách hàng</span>
                <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                <span class="text-slate-800 font-semibold">Khuyến mãi</span>
            </nav>

            <div class="flex flex-col md:flex-row md:items-end justify-between gap-4">
                <div>
                    <h1 class="text-2xl font-black text-slate-900 tracking-tight">Chương trình khuyến mãi</h1>
                    <p class="text-sm text-slate-500 mt-1">Giảm giá tự động trên sản phẩm được chọn trong một khoảng thời gian — khách không cần nhập mã.</p>
                </div>
                <a href="${ctx}/shop/promotions?action=new" class="mk-btn-primary self-start md:self-auto">
                    <i class="fa-solid fa-plus"></i> Tạo khuyến mãi mới
                </a>
            </div>

            <div class="grid grid-cols-2 xl:grid-cols-4 gap-4">
                <div class="mk-card mk-stat">
                    <span class="mk-stat-icon bg-emerald-50 text-emerald-600"><i class="fa-solid fa-bolt"></i></span>
                    <span><span class="mk-stat-num">${tabCounts.all}</span><span class="mk-stat-label">Tổng chương trình</span></span>
                </div>
                <div class="mk-card mk-stat">
                    <span class="mk-stat-icon bg-sky-50 text-sky-600"><i class="fa-solid fa-circle-play"></i></span>
                    <span><span class="mk-stat-num">${tabCounts.ongoing}</span><span class="mk-stat-label">Đang diễn ra</span></span>
                </div>
                <div class="mk-card mk-stat">
                    <span class="mk-stat-icon bg-orange-50 text-orange-600"><i class="fa-solid fa-apple-whole"></i></span>
                    <span><span class="mk-stat-num">${summary.productsOnPromo}</span><span class="mk-stat-label">Sản phẩm đang khuyến mãi</span></span>
                </div>
                <div class="mk-card mk-stat">
                    <span class="mk-stat-icon bg-amber-50 text-amber-600"><i class="fa-solid fa-hand-holding-dollar"></i></span>
                    <span><span class="mk-stat-num"><fmt:formatNumber value="${summary.totalDiscount}" pattern="#,##0"/> ₫</span><span class="mk-stat-label">Đã giảm · ${summary.unitsSold} sản phẩm bán ra</span></span>
                </div>
            </div>

            <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-3">
                <div class="mk-tabs">
                    <a href="${ctx}/shop/promotions?tab=ALL" class="mk-tab ${tab == 'ALL' ? 'active' : ''}">Tất cả <span class="cnt">${tabCounts.all}</span></a>
                    <a href="${ctx}/shop/promotions?tab=ONGOING" class="mk-tab ${tab == 'ONGOING' ? 'active' : ''}">Đang diễn ra <span class="cnt">${tabCounts.ongoing}</span></a>
                    <a href="${ctx}/shop/promotions?tab=UPCOMING" class="mk-tab ${tab == 'UPCOMING' ? 'active' : ''}">Sắp diễn ra <span class="cnt">${tabCounts.upcoming}</span></a>
                    <a href="${ctx}/shop/promotions?tab=PAUSED" class="mk-tab ${tab == 'PAUSED' ? 'active' : ''}">Tạm dừng <span class="cnt">${tabCounts.paused}</span></a>
                    <a href="${ctx}/shop/promotions?tab=FINISHED" class="mk-tab ${tab == 'FINISHED' ? 'active' : ''}">Đã kết thúc <span class="cnt">${tabCounts.finished}</span></a>
                </div>
                <form method="get" action="${ctx}/shop/promotions" class="relative w-full lg:w-72">
                    <input type="hidden" name="tab" value="${tab}">
                    <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs"></i>
                    <input type="text" name="q" value="<c:out value='${q}'/>" class="mk-input !pl-9" placeholder="Tìm theo tên chương trình...">
                </form>
            </div>

            <div class="mk-card overflow-hidden">
                <c:choose>
                    <c:when test="${not empty promotions}">
                        <div class="overflow-x-auto">
                            <table class="mk-table">
                                <thead>
                                    <tr>
                                        <th>Chương trình</th>
                                        <th>Mức giảm</th>
                                        <th>Sản phẩm tham gia</th>
                                        <th>Thời gian</th>
                                        <th>Trạng thái</th>
                                        <th class="text-right">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="p" items="${promotions}">
                                        <tr>
                                            <td>
                                                <div class="text-[13px] font-bold text-slate-900"><c:out value="${p.name}"/></div>
                                                <c:if test="${not empty p.description}"><div class="text-[11px] text-slate-400 max-w-xs truncate"><c:out value="${p.description}"/></div></c:if>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${p.percentage}">
                                                        <div class="font-extrabold text-slate-900">Giảm <fmt:formatNumber value="${p.discountValue}" maxFractionDigits="1"/>%</div>
                                                        <c:if test="${not empty p.maxDiscountAmount and p.maxDiscountAmount > 0}">
                                                            <div class="text-[11px] text-slate-500">Tối đa <fmt:formatNumber value="${p.maxDiscountAmount}" pattern="#,##0"/> ₫/sp</div>
                                                        </c:if>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="font-extrabold text-slate-900">Giảm <fmt:formatNumber value="${p.discountValue}" pattern="#,##0"/> ₫</div>
                                                        <div class="text-[11px] text-slate-500">trên mỗi sản phẩm</div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-[13px] text-slate-600 max-w-[220px]">
                                                <div class="font-bold text-slate-800">${p.productCount} sản phẩm</div>
                                                <div class="text-[11px] text-slate-400 truncate">
                                                    <c:forEach var="n" items="${p.productNames}" varStatus="st"><c:out value="${n}"/><c:if test="${!st.last}">, </c:if></c:forEach><c:if test="${p.productCount > 3}">…</c:if>
                                                </div>
                                            </td>
                                            <td class="text-[12px] text-slate-600 whitespace-nowrap">
                                                <fmt:formatDate value="${p.startDate}" pattern="dd/MM/yyyy HH:mm"/><br>
                                                <span class="text-slate-400">đến</span> <fmt:formatDate value="${p.endDate}" pattern="dd/MM/yyyy HH:mm"/>
                                            </td>
                                            <td><jsp:include page="/views/shop/layout/mk-status.jsp"><jsp:param name="status" value="${p.status}"/></jsp:include></td>
                                            <td>
                                                <div class="flex items-center justify-end gap-1.5">
                                                    <c:if test="${p.status != 'ENDED'}">
                                                        <a href="${ctx}/shop/promotions?action=edit&id=${p.promotionId}" class="mk-act mk-act-edit" title="Chỉnh sửa"><i class="fa-solid fa-pen"></i></a>
                                                    </c:if>
                                                    <c:if test="${p.status == 'ONGOING' || p.status == 'UPCOMING'}">
                                                        <form method="post" action="${ctx}/shop/promotions" data-confirm="Tạm dừng chương trình &quot;${p.name}&quot;? Giá sản phẩm sẽ trở về giá gốc.">
                                                            <input type="hidden" name="action" value="toggle"><input type="hidden" name="id" value="${p.promotionId}">
                                                            <input type="hidden" name="active" value="0"><input type="hidden" name="tab" value="${tab}">
                                                            <button type="submit" class="mk-act mk-act-pause" title="Tạm dừng"><i class="fa-solid fa-pause"></i></button>
                                                        </form>
                                                    </c:if>
                                                    <c:if test="${p.status == 'PAUSED'}">
                                                        <form method="post" action="${ctx}/shop/promotions">
                                                            <input type="hidden" name="action" value="toggle"><input type="hidden" name="id" value="${p.promotionId}">
                                                            <input type="hidden" name="active" value="1"><input type="hidden" name="tab" value="${tab}">
                                                            <button type="submit" class="mk-act mk-act-play" title="Kích hoạt lại"><i class="fa-solid fa-play"></i></button>
                                                        </form>
                                                    </c:if>
                                                    <c:if test="${p.status == 'ONGOING' || p.status == 'UPCOMING' || p.status == 'PAUSED'}">
                                                        <form method="post" action="${ctx}/shop/promotions" data-confirm="Kết thúc sớm chương trình? Thao tác này không thể hoàn tác.">
                                                            <input type="hidden" name="action" value="terminate"><input type="hidden" name="id" value="${p.promotionId}">
                                                            <input type="hidden" name="tab" value="${tab}">
                                                            <button type="submit" class="mk-act mk-act-stop" title="Kết thúc sớm"><i class="fa-solid fa-ban"></i></button>
                                                        </form>
                                                    </c:if>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="mk-empty">
                            <i class="fa-solid fa-bolt"></i>
                            <div>
                                <c:choose>
                                    <c:when test="${not empty q}">Không tìm thấy chương trình phù hợp với "<b><c:out value="${q}"/></b>".</c:when>
                                    <c:when test="${tab != 'ALL'}">Chưa có chương trình nào ở nhóm này.</c:when>
                                    <c:otherwise>Shop chưa có chương trình khuyến mãi nào. Hãy tạo chương trình đầu tiên!</c:otherwise>
                                </c:choose>
                            </div>
                            <a href="${ctx}/shop/promotions?action=new" class="mk-btn-primary"><i class="fa-solid fa-plus"></i> Tạo khuyến mãi mới</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </main>
</body>
</html>
