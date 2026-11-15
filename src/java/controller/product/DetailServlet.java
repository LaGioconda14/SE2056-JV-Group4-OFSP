package controller.product;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import model.entity.shop.Shop;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.entity.review.Review;
import model.dto.product.ProductDetailDTO;
import model.dto.review.ReviewSummary;
import service.IProductService;
import service.impl.ProductServiceImpl;
import service.IReviewService;
import service.impl.ReviewServiceImpl;
import service.IShopProductService;
import service.impl.ShopProductServiceImpl;

@WebServlet(name="DetailServlet", urlPatterns={"/detail"})
public class DetailServlet extends HttpServlet {

    private final IProductService productService = new ProductServiceImpl();
    private final IReviewService reviewService = new ReviewServiceImpl();
    private final IShopProductService shopProductService = new ShopProductServiceImpl();

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        
        // 1. Lấy tham số id từ URL gửi lên
        String idStr = request.getParameter("id");

        try {
            if (idStr != null && !idStr.trim().isEmpty()) {
                int productId = Integer.parseInt(idStr);
                
                // 2. Gọi Service lấy thông tin sản phẩm chi tiết
                ProductDetailDTO product = productService.getProductById(productId);

                if (product != null) {
                    request.setAttribute("product", product);

                    // Lấy thông tin Shop bán sản phẩm này hoàn toàn từ Service
                    Shop shop = null;
                    int shopTotalProducts = 0;
                    try {
                        long targetShopId = product.getShopId() > 0 ? product.getShopId() : 1L;
                        shop = shopProductService.getShopById(targetShopId);
                        if (shop == null && targetShopId != 1L) {
                            shop = shopProductService.getShopById(1L);
                        }
                        if (shop != null) {
                            shopTotalProducts = productService.countProductsByShopId(shop.getShopId());
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    if (shop == null) {
                        shop = new Shop();
                        shop.setShopId(product.getShopId() > 0 ? product.getShopId() : 1L);
                        String defaultShopName = "GỐC VƯỜN OFFICIAL STORE";
                        if (product.getOrigin() != null && !product.getOrigin().trim().isEmpty()) {
                            defaultShopName = "NÔNG TRẠI " + product.getOrigin().trim().toUpperCase() + " OFFICIAL";
                        }
                        shop.setShopName(defaultShopName);
                        shop.setStatus("ACTIVE");
                        shop.setRating(BigDecimal.ZERO);
                        shop.setProvince(product.getOrigin() != null && !product.getOrigin().trim().isEmpty() ? product.getOrigin() : "Đà Lạt, Lâm Đồng");
                        shop.setDescription("Hệ thống phân phối nông sản tươi sạch, chuẩn hữu cơ VietGAP & GlobalGAP hàng đầu Việt Nam.");
                        shop.setLogoUrl("https://images.unsplash.com/photo-1542838132-92c53300491e?w=150");
                        shopTotalProducts = 0;
                    }
                    request.setAttribute("shop", shop);
                    request.setAttribute("shopTotalProducts", shopTotalProducts);

                    // Lấy danh sách đánh giá thật từ bảng reviews qua ReviewService
                    List<Review> reviews = reviewService.getReviewsByProduct(product.getId(), 1, 20);
                    ReviewSummary reviewSummary = reviewService.getReviewSummary(product.getId());
                    if (reviewSummary != null && reviewSummary.getTotalReviews() > 0) {
                        product.setRating(reviewSummary.getAverageRating());
                        product.setReviewsCount(reviewSummary.getTotalReviews());
                    }
                    request.setAttribute("reviews", reviews);
                    request.setAttribute("reviewSummary", reviewSummary);

                    // Tính thời gian tham gia thực tế từ createdAt của shop
                    String shopJoinedTime = "Đã xác minh";
                    if (shop.getCreatedAt() != null) {
                        long diffMillis = System.currentTimeMillis() - shop.getCreatedAt().getTime();
                        long days = diffMillis / (1000L * 60 * 60 * 24);
                        long months = days / 30;
                        if (months >= 12) {
                            long years = months / 12;
                            shopJoinedTime = years + " năm trước";
                        } else if (months > 0) {
                            shopJoinedTime = months + " tháng trước";
                        } else if (days > 0) {
                            shopJoinedTime = days + " ngày trước";
                        } else {
                            shopJoinedTime = "Gần đây";
                        }
                    }
                    request.setAttribute("shopJoinedTime", shopJoinedTime);
                    HttpSession session = request.getSession(false);
                    if (session != null) {
                        request.setAttribute("currentUser", session.getAttribute("user"));
                        transferFlashMessage(session, request, "cartSuccess", "successMessage");
                        transferFlashMessage(session, request, "cartError", "errorMessage");
                    }
                    
                    // 3. Forward dữ liệu sang trang detail.jsp đã tạo
                    request.getRequestDispatcher("/views/product/product-detail.jsp").forward(request, response);
                    return;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            if (!response.isCommitted()) {
                response.sendRedirect(request.getContextPath() + "/products");
            }
            return;
        }
        // Nếu ID không hợp lệ hoặc không tìm thấy sản phẩm thì mới chuyển hướng về trang danh sách
        if (!response.isCommitted()) {
            response.sendRedirect(request.getContextPath() + "/products");
        }
    } 

    private void transferFlashMessage(HttpSession session, HttpServletRequest request,
            String sessionKey, String requestKey) {
        Object message = session.getAttribute(sessionKey);
        if (message != null) {
            request.setAttribute(requestKey, message);
            session.removeAttribute(sessionKey);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    } 

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "DetailServlet";
    }
}
