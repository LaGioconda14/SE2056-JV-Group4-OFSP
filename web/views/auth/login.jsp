<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:include page="/views/auth/auth-layout.jsp">
    <jsp:param name="pageTitle" value="Đăng nhập - Gốc Vườn" />
    <jsp:param name="activeTab" value="login" />
    <jsp:param name="statusPill" value="Cổng bảo mật SSL" />
    <jsp:param name="formTitle" value="Chào mừng trở lại!" />
    <jsp:param name="formSubtitle" value="Đăng nhập tài khoản để khám phá mùa vụ nông sản tươi ngon mỗi ngày." />
    <jsp:param name="showGoogle" value="true" />
    <jsp:param name="googleBtnText" value="Đăng nhập bằng Google" />
    <jsp:param name="contentPage" value="/views/auth/components/auth/login-content.jsp" />
</jsp:include>
