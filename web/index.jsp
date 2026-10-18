<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Chuyển hướng mặc định theo phiên đăng nhập và vai trò người dùng
    model.User user = (model.User) session.getAttribute("user");
    if (user != null && "ADMIN".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/admin/dashboard");
    } else if (user != null && "SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/shop/products");
    } else {
        response.sendRedirect(request.getContextPath() + "/home");
    }
%>
