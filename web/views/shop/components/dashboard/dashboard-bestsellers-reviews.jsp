<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<div class="grid grid-cols-1 xl:grid-cols-12 gap-6">
    <div class="xl:col-span-7 panel">
        <div class="panel-head">
            <h2>Top trái cây bán chạy</h2>
            <a href="${ctx}/shop/products" class="panel-link">Xem sản phẩm <i class="fa-solid fa-arrow-right text-[10px]"></i></a>
        </div>
        <c:choose>
            <c:when test="${not empty bestSellers}">
                <c:set var="topQty" value="${bestSellers[0].qty}"/>
                <ul class="flex flex-col gap-4">
                    <c:forEach var="b" items="${bestSellers}" varStatus="st">
                        <li class="flex items-center gap-3">
                            <span class="rank-badge rank-${st.index + 1}">${st.index + 1}</span>
                            <c:choose>
                                <c:when test="${not empty b.image}"><img src="${b.image}" alt="" class="w-11 h-11 rounded-xl object-cover border border-slate-100"/></c:when>
                                <c:otherwise><span class="w-11 h-11 rounded-xl bg-emerald-50 text-emerald-500 flex items-center justify-center"><i class="fa-solid fa-apple-whole"></i></span></c:otherwise>
                            </c:choose>
                            <div class="flex-1 min-w-0">
                                <div class="flex items-center justify-between gap-3">
                                    <span class="text-sm font-semibold text-slate-800 truncate"><c:out value="${b.name}"/></span>
                                    <span class="text-sm font-bold text-slate-900 whitespace-nowrap"><fmt:formatNumber value="${b.revenue}" pattern="#,##0"/> ₫</span>
                                </div>
                                <div class="bar-track"><div class="bar-fill" style="width: ${topQty > 0 ? (b.qty * 100 / topQty) : 0}%"></div></div>
                                <span class="text-[11px] text-slate-500">${b.qty} đã bán · ${b.orders} đơn</span>
                            </div>
                        </li>
                    </c:forEach>
                </ul>
            </c:when>
            <c:otherwise><div class="empty-state"><i class="fa-solid fa-apple-whole"></i>Chưa có sản phẩm nào được bán trong kỳ này</div></c:otherwise>
        </c:choose>
    </div>

    <div class="xl:col-span-5 panel">
        <div class="panel-head">
            <h2>Đánh giá của khách hàng</h2>
            <a href="${ctx}/shop/reviews" class="panel-link">Xem tất cả <i class="fa-solid fa-arrow-right text-[10px]"></i></a>
        </div>
        <c:choose>
            <c:when test="${ratingStats.total > 0}">
                <div class="flex items-center gap-5">
                    <div class="text-center">
                        <div class="text-4xl font-extrabold text-slate-900"><fmt:formatNumber value="${ratingStats.avg}" minFractionDigits="1" maxFractionDigits="1"/></div>
                        <div class="text-amber-400 text-xs mt-1">
                            <c:forEach begin="1" end="5" var="i"><i class="fa-solid fa-star ${ratingStats.avg >= i - 0.25 ? '' : 'opacity-25'}"></i></c:forEach>
                        </div>
                        <div class="text-[11px] text-slate-500 mt-1">${ratingStats.total} đánh giá</div>
                    </div>
                    <div class="flex-1 flex flex-col gap-1.5">
                        <div class="rate-row"><span>5★</span><div class="bar-track"><div class="bar-fill bg-amber-400" style="width:${ratingStats.p5}%"></div></div><span>${ratingStats.c5}</span></div>
                        <div class="rate-row"><span>4★</span><div class="bar-track"><div class="bar-fill bg-amber-400" style="width:${ratingStats.p4}%"></div></div><span>${ratingStats.c4}</span></div>
                        <div class="rate-row"><span>3★</span><div class="bar-track"><div class="bar-fill bg-amber-400" style="width:${ratingStats.p3}%"></div></div><span>${ratingStats.c3}</span></div>
                        <div class="rate-row"><span>2★</span><div class="bar-track"><div class="bar-fill bg-amber-400" style="width:${ratingStats.p2}%"></div></div><span>${ratingStats.c2}</span></div>
                        <div class="rate-row"><span>1★</span><div class="bar-track"><div class="bar-fill bg-amber-400" style="width:${ratingStats.p1}%"></div></div><span>${ratingStats.c1}</span></div>
                    </div>
                </div>
                <p class="text-xs text-slate-500 mt-3"><b>${ratingStats.newInPeriod}</b> đánh giá mới trong kỳ này</p>

                <div class="mt-4 pt-4 border-t border-slate-100 flex flex-col gap-4">
                    <c:forEach var="r" items="${latestReviews}">
                        <div>
                            <div class="flex items-center justify-between">
                                <span class="text-sm font-semibold text-slate-800"><c:out value="${r.customer}"/></span>
                                <span class="text-amber-400 text-[10px]">
                                    <c:forEach begin="1" end="5" var="i"><i class="fa-solid fa-star ${r.rating >= i ? '' : 'opacity-25'}"></i></c:forEach>
                                </span>
                            </div>
                            <p class="text-[11px] text-slate-400"><c:out value="${r.product}"/> · <fmt:formatDate value="${r.createdAt}" pattern="dd/MM/yyyy"/></p>
                            <c:if test="${not empty r.comment}"><p class="text-sm text-slate-600 mt-1 line-clamp-2"><c:out value="${r.comment}"/></p></c:if>
                            <c:if test="${empty r.reply}"><span class="inline-block mt-1 text-[11px] font-semibold text-violet-600">Chưa phản hồi</span></c:if>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise><div class="empty-state"><i class="fa-regular fa-star"></i>Shop chưa có đánh giá nào</div></c:otherwise>
        </c:choose>
    </div>
</div>

