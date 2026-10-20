<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
    NÚT TRÁI TIM NỔI (GÓC DƯỚI BÊN PHẢI) + CẤU HÌNH & SCRIPT WISHLIST DÙNG CHUNG.
    Cách dùng (đặt trước </body> của trang, trang đó cần link sẵn /assets/css/wishlist.css
    và Font Awesome):
        <jsp:include page="/views/common/wishlist-fab.jsp" />
    Ẩn nút nổi nhưng vẫn nạp script (ví dụ ở chính trang wishlist):
        <jsp:include page="/views/common/wishlist-fab.jsp"><jsp:param name="hideButton" value="true" /></jsp:include>
--%>
<%
    Object wlUser = session.getAttribute("user");
    boolean wlLoggedIn = (wlUser instanceof model.User);
    if (request.getAttribute("wishlistCount") == null) {
        int wlCount = 0;
        if (wlLoggedIn) {
            try {
                wlCount = new service.impl.WishlistServiceImpl().count((long) ((model.User) wlUser).getId());
            } catch (RuntimeException ex) {
                wlCount = 0; // chưa tạo bảng wishlists hoặc lỗi DB: không làm hỏng trang
            }
        }
        request.setAttribute("wishlistCount", wlCount);
    }
%>
<c:set var="wlCtx" value="${pageContext.request.contextPath}" />

<script>
    window.WISHLIST = {
        ctx: '<c:out value="${wlCtx}"/>',
        csrf: '<c:out value="${sessionScope.cartCsrfToken}"/>',
        loggedIn: <%= wlLoggedIn %>,
        count: <c:out value="${wishlistCount}"/>
    };
</script>
<script src="${wlCtx}/assets/js/wishlist.js" defer></script>

<c:if test="${param.hideButton ne 'true'}">
    <a href="${wlCtx}/wishlist" id="wishlistFab" class="wishlist-fab"
       title="Danh sách yêu thích" aria-label="Danh sách yêu thích">
        <i class="fa-solid fa-heart"></i>
        <span id="wishlistFabBadge" class="wishlist-fab-badge" ${wishlistCount gt 0 ? '' : 'hidden'}>${wishlistCount gt 99 ? '99+' : wishlistCount}</span>
    </a>
</c:if>
