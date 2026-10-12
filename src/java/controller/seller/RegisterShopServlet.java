package controller.seller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "RegisterShopServlet", urlPatterns = {"/register-shop"})
public class RegisterShopServlet extends HttpServlet {

    /**
     * Xử lý hiển thị trang giao diện đăng ký Shop (khi gõ URL hoặc click nút)
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Chuyển hướng người dùng sang trang register-shop.jsp
        // (Lưu ý kiểm tra đúng đường dẫn chứa file register-shop.jsp của bạn)
        request.getRequestDispatcher("/views/shop/register-shop.jsp").forward(request, response);
    }

    /**
     * Xử lý nhận dữ liệu từ Form khi người dùng ấn Submit Registration
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Thiết lập tiếng Việt cho dữ liệu gửi lên
        request.setCharacterEncoding("UTF-8");
        
        // Lấy thông tin từ Form (Ví dụ)
        String fullName = request.getParameter("fullName");
        String shopName = request.getParameter("shopName");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        
        // TODO: Xử lý lưu database hoặc gọi DAO/Service tại đây...

        // Chuyển hướng sau khi đăng ký thành công (ví dụ về trang chủ hoặc thông báo)
        response.sendRedirect(request.getContextPath() + "/home.jsp");
    }

    @Override
    public String getServletInfo() {
        return "Register Shop Controller for Tomcat 9";
    }
}