<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:include page="/views/auth/auth-layout.jsp">
    <jsp:param name="pageTitle" value="Đăng ký tài khoản - Gốc Vườn" />
    <jsp:param name="activeTab" value="register" />
    <jsp:param name="statusPill" value="Đăng ký an toàn SSL" />
    <jsp:param name="formTitle" value="Đăng ký tài khoản" />
    <jsp:param name="formSubtitle" value="Tạo tài khoản để nhận ưu đãi và mua sắm nông sản hữu cơ tươi ngon mỗi ngày." />
    <jsp:param name="showGoogle" value="true" />
    <jsp:param name="googleBtnText" value="Đăng ký bằng Google" />
    <jsp:param name="contentPage" value="/views/auth/components/auth/register-content.jsp" />
</jsp:include>
