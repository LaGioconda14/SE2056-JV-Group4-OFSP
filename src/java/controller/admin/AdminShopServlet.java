package controller.admin;

import dao.AdminManagementDAO;
import model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "AdminShopServlet", urlPatterns = {"/admin/shops"})
public class AdminShopServlet extends HttpServlet {
    private final AdminManagementDAO dao = new AdminManagementDAO();

@Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    // --- THÊM ĐOẠN LOG NÀY ĐỂ KIỂM TRA ---
    System.out.println("--------------------------------------------------");
    System.out.println("Đã gọi đến AdminShopServlet!");
    System.out.println("Action nhận được: " + request.getParameter("action"));
    System.out.println("ID nhận được: " + request.getParameter("id"));
    // --------------------------------------------------

    String action = request.getParameter("action");
    if (action != null && !action.trim().isEmpty()) {
        HttpSession session = request.getSession();
        User admin = (User) session.getAttribute("account");
        if (admin == null) {
            admin = (User) session.getAttribute("user");
        }
        
        int adminId = (admin != null) ? admin.getId() : 1; 

        try {
            int reqId = Integer.parseInt(request.getParameter("id"));
            System.out.println("Đang tiến hành gọi DAO update cho Request ID: " + reqId);
            
            boolean updateSuccess = false;
            if ("approve".equals(action)) {
                updateSuccess = dao.updateRequestStatus(reqId, "APPROVED", null, adminId);
            } else if ("reject".equals(action)) {
                String reason = request.getParameter("reason");
                updateSuccess = dao.updateRequestStatus(reqId, "REJECTED", reason, adminId);
            }
            
            System.out.println("Kết quả thực thi DAO update: " + updateSuccess);
            
        } catch (Exception e) {
            System.err.println("Lỗi ngoại lệ trong Servlet: " + e.getMessage());
            e.printStackTrace();
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/shops?status=PENDING_KYC");
        return;
    }
    
    // ... các phần code hiển thị danh sách phía dưới giữ nguyên ...

        // 2. Xử lý các tham số hiển thị, lọc và tìm kiếm hiện tại của bạn
        String status = request.getParameter("status");
        if (status == null || status.trim().isEmpty()) {
            status = request.getParameter("tab");
        }
        if (status == null || status.trim().isEmpty()) {
            status = "ALL";
        }

        String type = request.getParameter("type");
        if (type == null || type.trim().isEmpty()) {
            type = "ALL";
        }

        String cert = request.getParameter("cert");
        if (cert == null || cert.trim().isEmpty()) {
            cert = "ALL";
        }

        String search = request.getParameter("search");
        if (search != null) {
            search = search.trim();
        }

        request.setAttribute("selectedStatus", status.toUpperCase());
        request.setAttribute("selectedType", type);
        request.setAttribute("selectedCert", cert);
        request.setAttribute("searchKeyword", search != null ? search : "");
        request.setAttribute("shopStats", dao.getShopStats());
        request.setAttribute("shopsList", dao.getShopsList(status, type, cert, search));
        
        request.getRequestDispatcher("/views/admin/shops.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}