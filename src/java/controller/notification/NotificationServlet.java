package controller.notification;

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
import model.Notification;
import model.User;
import service.INotificationService;
import service.impl.NotificationServiceImpl;

@WebServlet(name = "NotificationServlet", urlPatterns = {
    "/notifications",
    "/api/notifications/recent",
    "/api/notifications/unread-count",
    "/api/notifications/mark-read",
    "/api/notifications/mark-all-read"
})
public class NotificationServlet extends HttpServlet {

    private final INotificationService notificationService = new NotificationServiceImpl();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;

        if (user == null) {
            if (path.startsWith("/api/")) {
                response.setContentType("application/json;charset=UTF-8");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("{\"error\":\"Unauthorized\",\"count\":0,\"notifications\":[]}");
            } else {
                response.sendRedirect(request.getContextPath() + "/login");
            }
            return;
        }

        if ("/api/notifications/unread-count".equals(path)) {
            response.setContentType("application/json;charset=UTF-8");
            int count = notificationService.getUnreadCount(user.getId());
            response.getWriter().write("{\"count\":" + count + "}");
            return;
        }

        if ("/api/notifications/recent".equals(path)) {
            response.setContentType("application/json;charset=UTF-8");
            int limit = 15;
            try {
                String limitStr = request.getParameter("limit");
                if (limitStr != null) limit = Integer.parseInt(limitStr);
            } catch (Exception ignored) {}

            List<Notification> list = notificationService.getRecent(user.getId(), limit);
            int unread = notificationService.getUnreadCount(user.getId());

            Map<String, Object> res = new HashMap<>();
            res.put("notifications", list);
            res.put("unreadCount", unread);
            response.getWriter().write(gson.toJson(res));
            return;
        }

        // Default GET /notifications
        List<Notification> list = notificationService.getRecent(user.getId(), 50);
        int unread = notificationService.getUnreadCount(user.getId());
        request.setAttribute("notifications", list);
        request.setAttribute("unreadCount", unread);
        request.getRequestDispatcher("/views/auth/notifications.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        String path = request.getServletPath();
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\":false,\"message\":\"Chưa đăng nhập\"}");
            return;
        }

        if ("/api/notifications/mark-read".equals(path)) {
            try {
                long id = Long.parseLong(request.getParameter("notificationId"));
                boolean ok = notificationService.markRead(id, user.getId());
                response.getWriter().write("{\"success\":" + ok + "}");
            } catch (Exception ex) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\":false,\"error\":\"" + ex.getMessage() + "\"}");
            }
            return;
        }

        if ("/api/notifications/mark-all-read".equals(path)) {
            boolean ok = notificationService.markAllRead(user.getId());
            response.getWriter().write("{\"success\":" + ok + "}");
        }
    }
}
