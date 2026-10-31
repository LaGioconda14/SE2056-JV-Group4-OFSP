<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Voucher Shop - Kênh Người Bán</title>
    <jsp:include page="/views/shop/layout/head.jsp" />
    <link rel="stylesheet" href="${ctx}/assets/css/shop-marketing.css"/>
    <script src="${ctx}/assets/js/shop-marketing.js" defer></script>
</head>
<body class="bg-[#f8fafc] text-[#0f172a]">

    <jsp:include page="/views/shop/layout/sidebar.jsp"><jsp:param name="active" value="vouchers" /></jsp:include>
    <jsp:include page="/views/shop/layout/header.jsp" />

    <main class="shop-main-wrapper">
        <div class="shop-content-container">

            <jsp:include page="/views/shop/layout/mk-flash.jsp" />

            <nav class="flex items-center gap-2 text-xs text-slate-500 font-medium">
                <span>Kênh Người Bán</span>
                <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                <span>Tiếp thị &amp; Khách hàng</span>
                <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                <span class="text-slate-800 font-semibold">Voucher Shop</span>
            </nav>

            <div class="flex flex-col md:flex-row md:items-end justify-between gap-4">
                <div>
                    <h1 class="text-2xl font-black text-slate-900 tracking-tight">Voucher Shop</h1>
                    <p class="text-sm text-slate-500 mt-1">Tạo mã giảm giá để khách nhập khi thanh toán. Mỗi mã chỉ dùng được cho sản phẩm của shop bạn.</p>
                </div>
                <a href="${ctx}/shop/vouchers?action=new" class="mk-btn-primary self-start md:self-auto">
                    <i class="fa-solid fa-plus"></i> Tạo voucher mới
                </a>
            </div>

            <div class="grid grid-cols-2 xl:grid-cols-4 gap-4">
                <div class="mk-card mk-stat">
                    <span class="mk-stat-icon bg-emerald-50 text-emerald-600"><i class="fa-solid fa-ticket"></i></span>
                    <span><span class="mk-stat-num">${tabCounts.all}</span><span class="mk-stat-label">Tổng số voucher</span></span>
                </div>
                <div class="mk-card mk-stat">
                    <span class="mk-stat-icon bg-sky-50 text-sky-600"><i class="fa-solid fa-circle-play"></i></span>
                    <span><span class="mk-stat-num">${tabCounts.ongoing}</span><span class="mk-stat-label">Đang diễn ra</span></span>
                </div>
                <div class="mk-card mk-stat">
                    <span class="mk-stat-icon bg-violet-50 text-violet-600"><i class="fa-solid fa-receipt"></i></span>
                    <span><span class="mk-stat-num"><fmt:formatNumber value="${summary.totalUsed}" pattern="#,##0"/></span><span class="mk-stat-label">Lượt đã sử dụng · ${summary.uniqueCustomers} khách</span></span>
                </div>
                <div class="mk-card mk-stat">
                    <span class="mk-stat-icon bg-amber-50 text-amber-600"><i class="fa-solid fa-hand-holding-dollar"></i></span>
                    <span><span class="mk-stat-num"><fmt:formatNumber value="${summary.totalDiscount}" pattern="#,##0"/> ₫</span><span class="mk-stat-label">Tổng tiền đã giảm cho khách</span></span>
                </div>
            </div>

            <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-3">
                <div class="mk-tabs">
                    <a href="${ctx}/shop/vouchers?tab=ALL" class="mk-tab ${tab == 'ALL' ? 'active' : ''}">Tất cả <span class="cnt">${tabCounts.all}</span></a>
                    <a href="${ctx}/shop/vouchers?tab=ONGOING" class="mk-tab ${tab == 'ONGOING' ? 'active' : ''}">Đang diễn ra <span class="cnt">${tabCounts.ongoing}</span></a>
                    <a href="${ctx}/shop/vouchers?tab=UPCOMING" class="mk-tab ${tab == 'UPCOMING' ? 'active' : ''}">Sắp diễn ra <span class="cnt">${tabCounts.upcoming}</span></a>
                    <a href="${ctx}/shop/vouchers?tab=PAUSED" class="mk-tab ${tab == 'PAUSED' ? 'active' : ''}">Tạm dừng <span class="cnt">${tabCounts.paused}</span></a>
                    <a href="${ctx}/shop/vouchers?tab=FINISHED" class="mk-tab ${tab == 'FINISHED' ? 'active' : ''}">Đã kết thúc <span class="cnt">${tabCounts.finished}</span></a>
                </div>
                <form method="get" action="${ctx}/shop/vouchers" class="relative w-full lg:w-72">
                    <input type="hidden" name="tab" value="${tab}">
                    <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs"></i>
                    <input type="text" name="q" value="<c:out value='${q}'/>" class="mk-input !pl-9" placeholder="Tìm theo mã hoặc tên voucher...">
                </form>
            </div>

            <div class="mk-card overflow-hidden">
                <c:choose>
                    <c:when test="${not empty vouchers}">
                        <div class="overflow-x-auto">
                            <table class="mk-table">
                                <thead>
                                    <tr>
                                        <th>Voucher</th>
                                        <th>Mức giảm</th>
                                        <th>Phạm vi</th>
                                        <th>Lượt sử dụng</th>
                                        <th>Thời gian</th>
                                        <th>Trạng thái</th>
                                        <th class="text-right">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="v" items="${vouchers}">
                                        <tr>
                                            <td>
                                                <span class="mk-code"><c:out value="${v.code}"/>
                                                    <button type="button" class="mk-copy" title="Sao chép mã" onclick="copyVoucherCode(this, '${v.code}')"><i class="fa-regular fa-copy"></i></button>
                                                </span>
                                                <div class="text-[13px] font-semibold text-slate-800 mt-1.5"><c:out value="${v.title}"/></div>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${v.percentage}">
                                                        <div class="font-extrabold text-slate-900">Giảm <fmt:formatNumber value="${v.discountValue}" maxFractionDigits="1"/>%</div>
                                                        <c:if test="${not empty v.maxDiscountAmount and v.maxDiscountAmount > 0}">
                                                            <div class="text-[11px] text-slate-500">Tối đa <fmt:formatNumber value="${v.maxDiscountAmount}" pattern="#,##0"/> ₫</div>
                                                        </c:if>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="font-extrabold text-slate-900">Giảm <fmt:formatNumber value="${v.discountValue}" pattern="#,##0"/> ₫</div>
                                                    </c:otherwise>
                                                </c:choose>
                                                <div class="text-[11px] text-slate-500">
                                                    <c:choose>
                                                        <c:when test="${v.minOrderValue > 0}">Đơn từ <fmt:formatNumber value="${v.minOrderValue}" pattern="#,##0"/> ₫</c:when>
                                                        <c:otherwise>Không yêu cầu đơn tối thiểu</c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </td>
                                            <td class="text-[13px] text-slate-600">
                                                <c:choose>
                                                    <c:when test="${v.appliesTo == 'PRODUCTS'}"><i class="fa-solid fa-apple-whole text-emerald-500 mr-1"></i>${v.productCount} sản phẩm</c:when>
                                                    <c:otherwise><i class="fa-solid fa-store text-emerald-500 mr-1"></i>Toàn shop</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <div class="text-[13px] font-bold text-slate-800">${v.usedCount} / ${v.usageLimit}</div>
                                                <div class="mk-bar"><div style="width:${v.usedPercent}%"></div></div>
                                                <div class="text-[11px] text-slate-400">Tối đa ${v.perUserLimit} lần/khách</div>
                                            </td>
                                            <td class="text-[12px] text-slate-600 whitespace-nowrap">
                                                <fmt:formatDate value="${v.startDate}" pattern="dd/MM/yyyy HH:mm"/><br>
                                                <span class="text-slate-400">đến</span> <fmt:formatDate value="${v.endDate}" pattern="dd/MM/yyyy HH:mm"/>
                                            </td>
                                            <td>
                                                <jsp:include page="/views/shop/layout/mk-status.jsp"><jsp:param name="status" value="${v.status}"/></jsp:include>
                                            </td>
                                            <td>
                                                <div class="flex items-center justify-end gap-1.5">
                                                    <a href="${ctx}/shop/vouchers?action=usage&id=${v.couponId}" class="mk-act mk-act-view" title="Lịch sử sử dụng"><i class="fa-solid fa-chart-line"></i></a>
                                                    <c:if test="${v.status != 'ENDED'}">
                                                        <a href="${ctx}/shop/vouchers?action=edit&id=${v.couponId}" class="mk-act mk-act-edit" title="Chỉnh sửa"><i class="fa-solid fa-pen"></i></a>
                                                    </c:if>
                                                    <c:if test="${v.status == 'ONGOING' || v.status == 'UPCOMING'}">
                                                        <form method="post" action="${ctx}/shop/vouchers" data-confirm="Tạm dừng voucher ${v.code}? Khách sẽ không dùng được mã này cho đến khi bạn kích hoạt lại.">
                                                            <input type="hidden" name="action" value="toggle"><input type="hidden" name="id" value="${v.couponId}">
                                                            <input type="hidden" name="active" value="0"><input type="hidden" name="tab" value="${tab}">
                                                            <button type="submit" class="mk-act mk-act-pause" title="Tạm dừng"><i class="fa-solid fa-pause"></i></button>
                                                        </form>
                                                    </c:if>
                                                    <c:if test="${v.status == 'PAUSED'}">
                                                        <form method="post" action="${ctx}/shop/vouchers">
                                                            <input type="hidden" name="action" value="toggle"><input type="hidden" name="id" value="${v.couponId}">
                                                            <input type="hidden" name="active" value="1"><input type="hidden" name="tab" value="${tab}">
                                                            <button type="submit" class="mk-act mk-act-play" title="Kích hoạt lại"><i class="fa-solid fa-play"></i></button>
                                                        </form>
                                                    </c:if>
                                                    <c:if test="${v.status == 'ONGOING' || v.status == 'UPCOMING' || v.status == 'PAUSED'}">
                                                        <form method="post" action="${ctx}/shop/vouchers" data-confirm="Kết thúc sớm voucher ${v.code}? Thao tác này không thể hoàn tác (lịch sử sử dụng vẫn được giữ).">
                                                            <input type="hidden" name="action" value="terminate"><input type="hidden" name="id" value="${v.couponId}">
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
                            <i class="fa-solid fa-ticket"></i>
                            <div>
                                <c:choose>
                                    <c:when test="${not empty q}">Không tìm thấy voucher phù hợp với "<b><c:out value="${q}"/></b>".</c:when>
                                    <c:when test="${tab != 'ALL'}">Chưa có voucher nào ở nhóm này.</c:when>
                                    <c:otherwise>Shop chưa có voucher nào. Hãy tạo voucher đầu tiên để thu hút khách hàng!</c:otherwise>
                                </c:choose>
                            </div>
                            <a href="${ctx}/shop/vouchers?action=new" class="mk-btn-primary"><i class="fa-solid fa-plus"></i> Tạo voucher mới</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </main>
</body>
</html>
