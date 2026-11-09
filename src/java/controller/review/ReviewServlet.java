package controller.review;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.entity.review.Review;
import model.dto.review.ReviewSummary;
import model.entity.user.User;
import service.IReviewService;
import service.impl.ReviewServiceImpl;
import service.INotificationService;
import service.impl.NotificationServiceImpl;

@WebServlet(name = "ReviewServlet", urlPatterns = {
    "/reviews",
    "/review/create",
    "/review/eligible",
    "/review/reply"
})
public class ReviewServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ReviewServlet.class.getName());
    private final IReviewService reviewService = new ReviewServiceImpl();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/review/eligible".equals(path)) {
            response.setContentType("application/json;charset=UTF-8");
            HttpSession session = request.getSession(false);
            User user = session != null ? (User) session.getAttribute("user") : null;
            if (user == null) {
                response.getWriter().write("{\"eligible\":false,\"message\":\"Chưa đăng nhập\"}");
                return;
            }
            try {
                long orderItemId = Long.parseLong(request.getParameter("orderItemId"));
                boolean eligible = reviewService.canReviewOrderItem(user.getId(), orderItemId);
                response.getWriter().write("{\"eligible\":" + eligible + "}");
            } catch (Exception ex) {
                response.getWriter().write("{\"eligible\":false,\"error\":\"" + ex.getMessage() + "\"}");
            }
            return;
        }

        // Default GET /reviews: fetch reviews for a product
        response.setContentType("application/json;charset=UTF-8");
        try {
            long productId = Long.parseLong(request.getParameter("productId"));
            int page = 1;
            int pageSize = 10;
            try {
                page = Integer.parseInt(request.getParameter("page"));
            } catch (Exception ignored) {}

            List<Review> reviews = reviewService.getReviewsByProduct(productId, page, pageSize);
            ReviewSummary summary = reviewService.getReviewSummary(productId);

            Map<String, Object> result = new HashMap<>();
            result.put("reviews", reviews);
            result.put("summary", summary);
            result.put("page", page);
            result.put("pageSize", pageSize);

            response.getWriter().write(gson.toJson(result));
        } catch (Exception ex) {
            LOGGER.log(Level.WARNING, "Failed to load reviews JSON", ex);
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"" + ex.getMessage() + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;

        if (user == null || !user.isActive()) {
            sendResponseOrRedirect(request, response, false, "Vui lòng đăng nhập để thực hiện tính năng này!", "/login");
            return;
        }

        if ("/review/create".equals(path)) {
            try {
                long orderItemId = Long.parseLong(request.getParameter("orderItemId"));
                int rating = Integer.parseInt(request.getParameter("rating"));
                String comment = request.getParameter("comment");

                long reviewId = reviewService.createReview(user.getId(), orderItemId, rating, comment);
                try {
                    INotificationService notiService = new NotificationServiceImpl();
                    notiService.notifyShopReviewCreated(reviewId);
                } catch (Exception ignored) {}
                sendResponseOrRedirect(request, response, true, "Đánh giá sản phẩm thành công! Cảm ơn bạn đã phản hồi.", "/profile#orders");
            } catch (IllegalArgumentException | IllegalStateException ex) {
                sendResponseOrRedirect(request, response, false, ex.getMessage(), "/profile#orders");
            } catch (Exception ex) {
                LOGGER.log(Level.SEVERE, "Failed to create review", ex);
                sendResponseOrRedirect(request, response, false, "Lỗi tạo đánh giá: " + ex.getMessage(), "/profile#orders");
            }
            return;
        }

        if ("/review/reply".equals(path)) {
            if (!"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
                sendResponseOrRedirect(request, response, false, "Chỉ chủ gian hàng mới có quyền phản hồi đánh giá!", "/shop/dashboard");
                return;
            }
            Long shopId = (Long) session.getAttribute("shopId");
            if (shopId == null || shopId <= 0) {
                sendResponseOrRedirect(request, response, false, "Không tìm thấy thông tin cửa hàng của bạn!", "/shop/dashboard");
                return;
            }
            try {
                long reviewId = Long.parseLong(request.getParameter("reviewId"));
                String replyComment = request.getParameter("replyComment");
                boolean ok = reviewService.replyReview(reviewId, shopId, replyComment);
                if (ok) {
                    try {
                        new NotificationServiceImpl().notifyCustomerReviewReplied(reviewId);
                    } catch (Exception ignored) {}
                }
                sendResponseOrRedirect(request, response, ok, ok ? "Phản hồi đánh giá thành công!" : "Không thể phản hồi đánh giá này!", "/shop/reviews");
            } catch (Exception ex) {
                LOGGER.log(Level.SEVERE, "Failed to reply review", ex);
                sendResponseOrRedirect(request, response, false, "Lỗi: " + ex.getMessage(), "/shop/dashboard");
            }
        }
    }

    private void sendResponseOrRedirect(HttpServletRequest request, HttpServletResponse response,
            boolean success, String message, String fallbackRedirect) throws IOException {
        String isAjax = request.getHeader("X-Requested-With");
        String accept = request.getHeader("Accept");
        boolean wantsJson = (isAjax != null && !isAjax.isBlank())
                || (accept != null && accept.contains("application/json"));

        if (wantsJson) {
            response.setContentType("application/json;charset=UTF-8");
            response.setStatus(success ? HttpServletResponse.SC_OK : HttpServletResponse.SC_BAD_REQUEST);
            Map<String, Object> map = new HashMap<>();
            map.put("success", success);
            map.put("message", message);
            response.getWriter().write(gson.toJson(map));
        } else {
            HttpSession session = request.getSession(true);
            if (success) {
                session.setAttribute("successMessage", message);
            } else {
                session.setAttribute("errorMessage", message);
            }
            String redirectUrl = request.getParameter("redirectUrl");
            if (redirectUrl != null && !redirectUrl.isBlank()) {
                response.sendRedirect(redirectUrl);
            } else {
                response.sendRedirect(request.getContextPath() + fallbackRedirect);
            }
        }
    }
}
