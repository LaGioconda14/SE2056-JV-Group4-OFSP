package controller.shop;

import dao.ShopDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import model.Category;
import service.IProductService;
import service.impl.ProductServiceImpl;

@WebServlet(name="ShopSearchProductServlet", urlPatterns={"/shop/product/search"})
public class ShopSearchProductServlet extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ShopSearchProductServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ShopSearchProductServlet at " + request.getContextPath () + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    private final ShopDAO shopDAO = new ShopDAO();
    private final IProductService productService = new ProductServiceImpl();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        Object shopIdObj = session.getAttribute("shopId");
        long shopId = (Long)shopIdObj;

        String keyword = request.getParameter("keyword");

        String categoryIdStr = request.getParameter("categoryId");
        Long categoryId = (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) ? Long.parseLong(categoryIdStr) : null;

        String certification = request.getParameter("certification");
        String stockLevel = request.getParameter("stockLevel");

        List<model.Product> products = productService.getShopFilteredProducts(shopId, keyword, categoryId, certification, stockLevel);

        request.setAttribute("products", products);
        List<Category> categoryList = productService.getAllCategories();
        request.setAttribute("categories", categoryList);
        List<String> certificationList = productService.getAllCertifications();
        request.setAttribute("certifications", certificationList);
        request.getRequestDispatcher("/views/shop/shop-products.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }
}
