<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:include page="/views/auth/auth-layout.jsp">
    <jsp:param name="pageTitle" value="Đổi mật khẩu - Gốc Vườn" />
    <jsp:param name="showTabs" value="false" />
    <jsp:param name="showUserBadge" value="true" />
    <jsp:param name="pillBadgeText" value="Trung Tâm Bảo Mật Tài Khoản" />
    <jsp:param name="pillBadgeIcon" value="bi-shield-lock-fill" />
    <jsp:param name="statusPill" value="Cổng bảo mật SSL" />
    <jsp:param name="formTitle" value="Đổi mật khẩu" />
    <jsp:param name="formSubtitle" value="Cập nhật mật khẩu để bảo vệ an toàn cho tài khoản Gốc Vườn của bạn." />
    <jsp:param name="contentPage" value="/views/auth/components/auth/change-password-content.jsp" />
</jsp:include>
