package controller.shop;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.entity.review.Review;
import model.entity.user.User;
import service.INotificationService;
import service.IReviewService;
import service.IShopProductService;
import service.impl.NotificationServiceImpl;
import service.impl.ReviewServiceImpl;
import service.impl.ShopProductServiceImpl;

@WebServlet(name = "ShopReviewsServlet", urlPatterns = {"/shop/reviews"})
public class ShopReviewsServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ShopReviewsServlet.class.getName());
    private static final int DEFAULT_PAGE_SIZE = 10;

    private final IReviewService reviewService = new ReviewServiceImpl();
    private final IShopProductService shopProductService = new ShopProductServiceImpl();
    private final INotificationService notificationService = new NotificationServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Long shopId = (Long) session.getAttribute("shopId");
        if (shopId == null || shopId <= 0) {
            shopId = shopProductService.getShopIDByOwnerID(user.getId());
            if (shopId != null && shopId > 0) {
                session.setAttribute("shopId", shopId);
            }
        }
        if (shopId == null || shopId <= 0) {
            response.sendRedirect(request.getContextPath() + "/register-shop");
            return;
        }

        // Filters
        String ratingParam = request.getParameter("rating");
        Integer rating = null;
        if (ratingParam != null && !ratingParam.isBlank()) {
            try {
                int r = Integer.parseInt(ratingParam.trim());
                if (r >= 1 && r <= 5) {
                    rating = r;
                }
            } catch (NumberFormatException ignored) {}
        }

        String statusParam = request.getParameter("status");
        if (statusParam == null || statusParam.isBlank()) {
            statusParam = request.getParameter("tab");
        }
        if (statusParam == null || statusParam.isBlank()) {
            statusParam = "ALL";
        }
        statusParam = statusParam.toUpperCase().trim();
        if (!"UNREPLIED".equals(statusParam) && !"REPLIED".equals(statusParam)) {
            statusParam = "ALL";
        }

        String keyword = request.getParameter("keyword");
        if (keyword != null) {
            keyword = keyword.trim();
            if (keyword.isEmpty()) {
                keyword = null;
            }
        }

        int page = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.isBlank()) {
            try {
                page = Math.max(1, Integer.parseInt(pageParam.trim()));
            } catch (NumberFormatException ignored) {}
        }

        int pageSize = DEFAULT_PAGE_SIZE;
        String sizeParam = request.getParameter("pageSize");
        if (sizeParam != null && !sizeParam.isBlank()) {
            try {
                pageSize = Math.max(5, Integer.parseInt(sizeParam.trim()));
            } catch (NumberFormatException ignored) {}
        }

        try {
            Map<String, Object> stats = reviewService.getShopReviewStats(shopId);
            int totalCount = reviewService.countReviewsByShop(shopId, rating, statusParam, keyword);
            int totalPages = (int) Math.ceil((double) totalCount / pageSize);
            if (totalPages < 1) totalPages = 1;
            if (page > totalPages) page = totalPages;

            List<Review> reviews = reviewService.getReviewsByShop(shopId, rating, statusParam, keyword, page, pageSize);

            request.setAttribute("stats", stats);
            request.setAttribute("reviews", reviews);
            request.setAttribute("totalCount", totalCount);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", page);
            request.setAttribute("pageSize", pageSize);
            request.setAttribute("selectedRating", rating);
            request.setAttribute("selectedStatus", statusParam);
            request.setAttribute("keyword", keyword != null ? keyword : "");

            request.getRequestDispatcher("/views/shop/marketing/reviews.jsp").forward(request, response);
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Error loading shop reviews", ex);
            request.setAttribute("errorMessage", "Không thể tải danh sách đánh giá: " + ex.getMessage());
            request.getRequestDispatcher("/views/shop/marketing/reviews.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Long shopId = (Long) session.getAttribute("shopId");
        if (shopId == null || shopId <= 0) {
            shopId = shopProductService.getShopIDByOwnerID(user.getId());
            if (shopId != null && shopId > 0) {
                session.setAttribute("shopId", shopId);
            }
        }
        if (shopId == null || shopId <= 0) {
            response.sendRedirect(request.getContextPath() + "/register-shop");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.isBlank()) {
            action = "reply";
        }

        if ("reply".equalsIgnoreCase(action)) {
            try {
                long reviewId = Long.parseLong(request.getParameter("reviewId"));
                String replyComment = request.getParameter("replyComment");

                if (replyComment == null || replyComment.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "Nội dung phản hồi không được để trống!");
                } else {
                    boolean ok = reviewService.replyReview(reviewId, shopId, replyComment);
                    if (ok) {
                        try {
                            notificationService.notifyCustomerReviewReplied(reviewId);
                        } catch (Exception notiEx) {
                            LOGGER.log(Level.WARNING, "Failed to send notification for replied review: " + reviewId, notiEx);
                        }
                        session.setAttribute("successMessage", "Phản hồi đánh giá của khách hàng thành công!");
                    } else {
                        session.setAttribute("errorMessage", "Không thể gửi phản hồi cho đánh giá này!");
                    }
                }
            } catch (Exception ex) {
                LOGGER.log(Level.SEVERE, "Error processing review reply", ex);
                session.setAttribute("errorMessage", "Lỗi: " + ex.getMessage());
            }
        }

        String redirectUrl = request.getParameter("redirectUrl");
        if (redirectUrl != null && !redirectUrl.isBlank()) {
            response.sendRedirect(redirectUrl);
        } else {
            response.sendRedirect(request.getContextPath() + "/shop/reviews");
        }
    }
}
