<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Chuyển hướng mặc định theo phiên đăng nhập và vai trò người dùng
    model.User user = (model.User) session.getAttribute("user");
    if (user != null && "ADMIN".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/admin");
    } else if (user != null) {
        response.sendRedirect(request.getContextPath() + "/home.jsp");
    } else {
        response.sendRedirect(request.getContextPath() + "/login");
    }
%>

