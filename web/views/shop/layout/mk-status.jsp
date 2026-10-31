<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:choose>
    <c:when test="${param.status == 'ONGOING'}"><span class="mk-st mk-st-ONGOING">Đang diễn ra</span></c:when>
    <c:when test="${param.status == 'UPCOMING'}"><span class="mk-st mk-st-UPCOMING">Sắp diễn ra</span></c:when>
    <c:when test="${param.status == 'PAUSED'}"><span class="mk-st mk-st-PAUSED">Tạm dừng</span></c:when>
    <c:when test="${param.status == 'EXPIRED'}"><span class="mk-st mk-st-EXPIRED">Đã hết hạn</span></c:when>
    <c:when test="${param.status == 'ENDED'}"><span class="mk-st mk-st-ENDED">Kết thúc sớm</span></c:when>
    <c:when test="${param.status == 'SOLD_OUT'}"><span class="mk-st mk-st-SOLD_OUT">Hết lượt</span></c:when>
    <c:otherwise><span class="mk-st mk-st-EXPIRED">${param.status}</span></c:otherwise>
</c:choose>
