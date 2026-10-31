package controller.shop;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import model.Review;
import service.IReviewService;
import service.impl.ReviewServiceImpl;

@WebServlet(name = "ShopReviewServlet", urlPatterns = {"/shop/reviews"})
public class ShopReviewServlet extends BaseShopServlet {

    private final IReviewService reviewService = new ReviewServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Long shopId = requireShop(req, resp);
        if (shopId == null) return;

        String tab = req.getParameter("tab");
        if (tab == null || tab.trim().isEmpty()) {
            tab = "all";
        } else {
            tab = tab.trim().toLowerCase();
        }

        int page = 1;
        String pageParam = req.getParameter("page");
        if (pageParam != null) {
            try {
                page = Integer.parseInt(pageParam.trim());
            } catch (NumberFormatException ignored) {
            }
        }

        List<Review> reviews = reviewService.getReviewsByShop(shopId, tab, page, 10);
        int totalTabCount = reviewService.countReviewsByShop(shopId, tab);

        int countAll = reviewService.countReviewsByShop(shopId, "all");
        int countUnreplied = reviewService.countReviewsByShop(shopId, "unreplied");
        int countPositive = reviewService.countReviewsByShop(shopId, "positive");
        int countNegative = reviewService.countReviewsByShop(shopId, "negative");

        req.setAttribute("activeTab", "reviews");
        req.setAttribute("currentTab", tab);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", (int) Math.ceil((double) totalTabCount / 10));
        req.setAttribute("reviews", reviews);
        req.setAttribute("countAll", countAll);
        req.setAttribute("countUnreplied", countUnreplied);
        req.setAttribute("countPositive", countPositive);
        req.setAttribute("countNegative", countNegative);

        req.getRequestDispatcher("/views/shop/shop-reviews.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Long shopId = requireShop(req, resp);
        if (shopId == null) return;

        String action = req.getParameter("action");
        if ("reply".equalsIgnoreCase(action)) {
            String reviewIdStr = req.getParameter("reviewId");
            String replyComment = req.getParameter("replyComment");
            try {
                long reviewId = Long.parseLong(reviewIdStr.trim());
                boolean ok = reviewService.replyReview(shopId, reviewId, replyComment);
                if (ok) {
                    flash(req, true, "Đã gửi phản hồi đánh giá tới khách hàng thành công!");
                } else {
                    flash(req, false, "Không thể gửi phản hồi lúc này. Vui lòng thử lại.");
                }
            } catch (Exception e) {
                flash(req, false, "Dữ liệu phản hồi không hợp lệ.");
            }
        }

        String currentTab = req.getParameter("currentTab");
        resp.sendRedirect(req.getContextPath() + "/shop/reviews" + (currentTab != null ? "?tab=" + currentTab : ""));
    }
}

