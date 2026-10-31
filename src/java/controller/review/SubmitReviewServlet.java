package controller.review;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import model.User;
import service.IReviewService;
import service.impl.ReviewServiceImpl;

@WebServlet(name = "SubmitReviewServlet", urlPatterns = {"/review", "/submit-review"})
public class SubmitReviewServlet extends HttpServlet {

    private final IReviewService reviewService = new ReviewServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String itemParam = request.getParameter("orderItemId");
        if (itemParam == null || itemParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/products");
            return;
        }

        try {
            long orderItemId = Long.parseLong(itemParam.trim());
            boolean canReview = reviewService.canCustomerReview(user.getId(), orderItemId);
            if (!canReview) {
                if (session != null) {
                    session.setAttribute("reviewError", "Sản phẩm này chưa thể đánh giá hoặc bạn đã gửi đánh giá rồi.");
                }
                response.sendRedirect(request.getContextPath() + "/products");
                return;
            }

            Map<String, Object> item = reviewService.getOrderItemForReview(user.getId(), orderItemId);
            if (item == null) {
                response.sendRedirect(request.getContextPath() + "/products");
                return;
            }

            request.setAttribute("item", item);
            request.getRequestDispatcher("/views/review/submit-review.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/products");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String itemParam = request.getParameter("orderItemId");
        String shopParam = request.getParameter("shopId");
        String ratingParam = request.getParameter("rating");
        String comment = request.getParameter("comment");
        String productIdParam = request.getParameter("productId");

        long orderItemId = 0;
        long shopId = 0;
        int rating = 5;
        long productId = 0;

        try {
            if (itemParam != null) orderItemId = Long.parseLong(itemParam.trim());
            if (shopParam != null) shopId = Long.parseLong(shopParam.trim());
            if (ratingParam != null) rating = Integer.parseInt(ratingParam.trim());
            if (productIdParam != null) productId = Long.parseLong(productIdParam.trim());
        } catch (NumberFormatException ignored) {
        }

        List<String> imageUrls = new ArrayList<>();
        String img1 = request.getParameter("image1");
        String img2 = request.getParameter("image2");
        String img3 = request.getParameter("image3");
        if (img1 != null && !img1.trim().isEmpty()) imageUrls.add(img1.trim());
        if (img2 != null && !img2.trim().isEmpty()) imageUrls.add(img2.trim());
        if (img3 != null && !img3.trim().isEmpty()) imageUrls.add(img3.trim());

        long reviewId = reviewService.submitReview(user.getId(), orderItemId, shopId, rating, comment, imageUrls);
        if (reviewId > 0) {
            if (session != null) {
                session.setAttribute("reviewSuccess", "Cảm ơn bạn! Đánh giá nông sản của bạn đã được gửi thành công.");
            }
        } else if (reviewId == -2) {
            if (session != null) {
                session.setAttribute("reviewError", "Bạn đã đánh giá sản phẩm này rồi hoặc đơn hàng chưa hoàn tất giao hàng.");
            }
        } else {
            if (session != null) {
                session.setAttribute("reviewError", "Không thể gửi đánh giá lúc này. Vui lòng kiểm tra lại thông tin.");
            }
        }

        if (productId > 0) {
            response.sendRedirect(request.getContextPath() + "/detail?id=" + productId + "#reviews");
        } else {
            response.sendRedirect(request.getContextPath() + "/products");
        }
    }
}

