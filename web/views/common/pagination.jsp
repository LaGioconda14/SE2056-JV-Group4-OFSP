<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
    THANH PHÂN TRANG DÙNG CHUNG (Voucher, Khuyến mãi, Yêu thích...)
    Servlet cần đặt các attribute: currentPage, totalPages, totalItems, pageSize
    (với kênh người bán dùng BaseShopServlet.paginate(...)).

    Cách dùng:
        <jsp:include page="/views/common/pagination.jsp">
            <jsp:param name="baseUrl" value="/shop/vouchers" />   đường dẫn không kèm context path
            <jsp:param name="tab" value="${tab}" />               (tuỳ chọn) giữ tab đang lọc
            <jsp:param name="q" value="${q}" />                   (tuỳ chọn) giữ từ khoá tìm kiếm
            <jsp:param name="wrapClass" value="mt-8" />           (tuỳ chọn) class của khung ngoài
        </jsp:include>
--%>
<c:if test="${totalPages > 1}">
    <c:set var="cp" value="${currentPage}" />
    <c:set var="wrap" value="${empty param.wrapClass ? 'px-4 py-3 border-t border-slate-100' : param.wrapClass}" />
    <c:set var="fromItem" value="${(cp - 1) * pageSize + 1}" />
    <c:set var="toItem" value="${cp * pageSize > totalItems ? totalItems : cp * pageSize}" />

    <div class="${wrap} flex flex-col sm:flex-row items-center justify-between gap-3">
        <p class="text-xs text-slate-500">
            Hiển thị <b class="text-slate-700">${fromItem}–${toItem}</b> / <b class="text-slate-700">${totalItems}</b>
        </p>

        <nav class="flex items-center gap-1" aria-label="Phân trang">
            <%-- Trang trước --%>
            <c:choose>
                <c:when test="${cp > 1}">
                    <c:url var="prevUrl" value="${param.baseUrl}">
                        <c:if test="${not empty param.tab}"><c:param name="tab" value="${param.tab}" /></c:if>
                        <c:if test="${not empty param.q}"><c:param name="q" value="${param.q}" /></c:if>
                        <c:param name="page" value="${cp - 1}" />
                    </c:url>
                    <a href="<c:out value='${prevUrl}'/>" class="inline-flex h-8 w-8 items-center justify-center rounded-lg border border-slate-200 bg-white text-xs text-slate-600 transition hover:border-emerald-500 hover:text-emerald-700" title="Trang trước" aria-label="Trang trước"><i class="fa-solid fa-chevron-left"></i></a>
                </c:when>
                <c:otherwise>
                    <span class="inline-flex h-8 w-8 cursor-not-allowed items-center justify-center rounded-lg border border-slate-100 bg-slate-50 text-xs text-slate-300"><i class="fa-solid fa-chevron-left"></i></span>
                </c:otherwise>
            </c:choose>

            <%-- Các số trang: luôn hiện trang đầu, trang cuối và 2 trang quanh trang hiện tại --%>
            <c:forEach begin="1" end="${totalPages}" var="i">
                <c:set var="showNum" value="${i == 1 || i == totalPages || (i >= cp - 2 && i <= cp + 2) || (i == 2 && i == cp - 3) || (i == totalPages - 1 && i == cp + 3)}" />
                <c:choose>
                    <c:when test="${showNum}">
                        <c:choose>
                            <c:when test="${i == cp}">
                                <span class="inline-flex h-8 min-w-[2rem] items-center justify-center rounded-lg bg-emerald-600 px-2 text-xs font-bold text-white shadow-sm" aria-current="page">${i}</span>
                            </c:when>
                            <c:otherwise>
                                <c:url var="pageUrl" value="${param.baseUrl}">
                                    <c:if test="${not empty param.tab}"><c:param name="tab" value="${param.tab}" /></c:if>
                                    <c:if test="${not empty param.q}"><c:param name="q" value="${param.q}" /></c:if>
                                    <c:param name="page" value="${i}" />
                                </c:url>
                                <a href="<c:out value='${pageUrl}'/>" class="inline-flex h-8 min-w-[2rem] items-center justify-center rounded-lg border border-slate-200 bg-white px-2 text-xs font-semibold text-slate-600 transition hover:border-emerald-500 hover:text-emerald-700">${i}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:when>
                    <c:when test="${i == cp - 3 || i == cp + 3}">
                        <span class="px-1 text-xs text-slate-400">…</span>
                    </c:when>
                </c:choose>
            </c:forEach>

            <%-- Trang sau --%>
            <c:choose>
                <c:when test="${cp < totalPages}">
                    <c:url var="nextUrl" value="${param.baseUrl}">
                        <c:if test="${not empty param.tab}"><c:param name="tab" value="${param.tab}" /></c:if>
                        <c:if test="${not empty param.q}"><c:param name="q" value="${param.q}" /></c:if>
                        <c:param name="page" value="${cp + 1}" />
                    </c:url>
                    <a href="<c:out value='${nextUrl}'/>" class="inline-flex h-8 w-8 items-center justify-center rounded-lg border border-slate-200 bg-white text-xs text-slate-600 transition hover:border-emerald-500 hover:text-emerald-700" title="Trang sau" aria-label="Trang sau"><i class="fa-solid fa-chevron-right"></i></a>
                </c:when>
                <c:otherwise>
                    <span class="inline-flex h-8 w-8 cursor-not-allowed items-center justify-center rounded-lg border border-slate-100 bg-slate-50 text-xs text-slate-300"><i class="fa-solid fa-chevron-right"></i></span>
                </c:otherwise>
            </c:choose>
        </nav>
    </div>
</c:if>
