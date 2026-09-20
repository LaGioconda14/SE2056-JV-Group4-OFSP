<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Chuyển hướng mặc định tới trang đăng nhập (hoặc trang chủ sau này)
    response.sendRedirect(request.getContextPath() + "/login");
%>

