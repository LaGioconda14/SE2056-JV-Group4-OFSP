<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:include page="/views/auth/auth-layout.jsp">
    <jsp:param name="pageTitle" value="Quên mật khẩu - Gốc Vườn" />
    <jsp:param name="activeTab" value="forgot" />
    <jsp:param name="pillBadgeText" value="Bảo mật &amp; Khôi phục tài khoản" />
    <jsp:param name="pillBadgeIcon" value="bi-shield-lock-fill" />
    <jsp:param name="statusPill" value="Cổng khôi phục an toàn" />
    <jsp:param name="formTitle" value="Khôi phục mật khẩu" />
    <jsp:param name="formSubtitle" value="Nhập địa chỉ email đã đăng ký để nhận mã OTP xác thực gồm 6 chữ số." />
    <jsp:param name="contentPage" value="/views/auth/components/auth/forgot-password-content.jsp" />
</jsp:include>
