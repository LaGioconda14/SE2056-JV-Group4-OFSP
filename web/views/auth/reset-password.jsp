<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:include page="/views/auth/auth-layout.jsp">
    <jsp:param name="pageTitle" value="Đặt lại mật khẩu - Gốc Vườn" />
    <jsp:param name="activeTab" value="reset" />
    <jsp:param name="forgotTabLabel" value="Đặt lại mật khẩu" />
    <jsp:param name="pillBadgeText" value="Cổng Khôi Phục Mật Khẩu" />
    <jsp:param name="pillBadgeIcon" value="bi-shield-check" />
    <jsp:param name="statusPill" value="Cổng bảo mật SSL" />
    <jsp:param name="formTitle" value="Đặt lại mật khẩu" />
    <jsp:param name="formSubtitle" value="Nhập mã xác thực OTP 6 số đã được gửi qua email và tạo mật khẩu mới." />
    <jsp:param name="contentPage" value="/views/auth/components/auth/reset-password-content.jsp" />
</jsp:include>
