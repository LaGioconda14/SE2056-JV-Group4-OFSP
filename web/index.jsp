<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Chuyển hướng mặc định tới trang chủ /home
    response.sendRedirect(request.getContextPath() + "/home");
%>