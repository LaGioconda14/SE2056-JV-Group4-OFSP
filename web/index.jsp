<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:choose>
    <c:when test="${not empty sessionScope.user and sessionScope.user.role eq 'ADMIN'}">
        <c:redirect url="/admin/dashboard" />
    </c:when>
    <c:when test="${not empty sessionScope.user and sessionScope.user.role eq 'SHOP_OWNER'}">
        <c:redirect url="/shop/dashboard" />
    </c:when>
    <c:otherwise>
        <c:redirect url="/home" />
    </c:otherwise>
</c:choose>
