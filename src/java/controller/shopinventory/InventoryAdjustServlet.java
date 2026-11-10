/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.shopinventory;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.entity.user.User;
import service.IInventoryService;
import service.impl.InventoryServiceImpl;

/**
 *
 * @author ADMIN
 */
@WebServlet(name = "InventoryAdjustServlet", urlPatterns = {"/shop/inventory/adjust"})
public class InventoryAdjustServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet InventoryAdjustServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet InventoryAdjustServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    private final IInventoryService inventoryService = new InventoryServiceImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Long shopId = session.getAttribute("shopId") instanceof Long
                ? (Long) session.getAttribute("shopId") : null;
        if (shopId == null || shopId <= 0) {
            response.sendRedirect(request.getContextPath() + "/shop/inventory");
            return;
        }

        try {
            int batchId = Integer.parseInt(request.getParameter("batchId"));
            int variantId = Integer.parseInt(request.getParameter("variantId"));
            int deductQuantity = Integer.parseInt(request.getParameter("deductQuantity"));
            String transactionType = request.getParameter("reason"); // Giá trị từ select: DAMAGED, EXPIRED, LOST...
            String description = request.getParameter("description");   // Chi tiết mô tả từ textarea
            boolean success = inventoryService.adjustBatch(batchId, variantId, Math.toIntExact(shopId), user.getId(), deductQuantity, transactionType, description);

            if (success) {
                session.setAttribute("inventoryAdjustSuccess", Boolean.TRUE);
                session.setAttribute("inventoryAdjustMessage", "Trừ hao thành công.");
            } else {
                session.setAttribute("inventoryAdjustSuccess", Boolean.FALSE);
                session.setAttribute("inventoryAdjustMessage", "Không thể điều chỉnh tồn kho.");
            }
        } catch (NumberFormatException | ArithmeticException e) {
            e.printStackTrace();
            session.setAttribute("inventoryAdjustSuccess", Boolean.FALSE);
            session.setAttribute("inventoryAdjustMessage", "Dữ liệu số nhập vào không hợp lệ.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("inventoryAdjustSuccess", Boolean.FALSE);
            session.setAttribute("inventoryAdjustMessage", e.getMessage() != null ? e.getMessage() : "Đã xảy ra lỗi hệ thống.");
        }
        response.sendRedirect(request.getContextPath() + "/shop/inventory/batches");
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
