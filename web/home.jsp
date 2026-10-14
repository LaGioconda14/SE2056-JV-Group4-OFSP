<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Chuyển hướng tới servlet /home để nạp đầy đủ dữ liệu và chuyển tiếp tới /views/home.jsp
    response.sendRedirect(request.getContextPath() + "/home");
%>

