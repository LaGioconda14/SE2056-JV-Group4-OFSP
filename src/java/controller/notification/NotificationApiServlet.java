package controller.notification;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.Notification;
import model.User;
import service.INotificationService;
import service.impl.NotificationServiceImpl;

@WebServlet(name = "NotificationApiServlet", urlPatterns = {"/api/notifications"})
public class NotificationApiServlet extends HttpServlet {

    private final INotificationService notificationService = new NotificationServiceImpl();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        Map<String, Object> result = new HashMap<>();
        if (user == null) {
            result.put("logged", false);
            result.put("unread", 0);
            result.put("notifications", List.of());
            response.getWriter().write(gson.toJson(result));
            return;
        }

        long userId = user.getId();
        int unread = notificationService.getUnreadCount(userId);
        String action = request.getParameter("action");

        if ("count".equalsIgnoreCase(action)) {
            result.put("logged", true);
            result.put("unread", unread);
            response.getWriter().write(gson.toJson(result));
            return;
        }

        List<Notification> list = notificationService.getUserNotifications(userId, 1, 10);
        List<Map<String, Object>> notiDtos = new ArrayList<>();
        String ctx = request.getContextPath();

        for (Notification n : list) {
            Map<String, Object> dto = new HashMap<>();
            dto.put("id", n.getNotificationId());
            dto.put("title", n.getTitle());
            dto.put("message", n.getMessage());
            dto.put("type", n.getType());
            dto.put("isRead", n.isRead());
            dto.put("timeAgo", n.getTimeAgo());
            dto.put("targetUrl", n.getTargetUrl(ctx));
            notiDtos.add(dto);
        }

        result.put("logged", true);
        result.put("unread", unread);
        result.put("notifications", notiDtos);
        response.getWriter().write(gson.toJson(result));
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        Map<String, Object> result = new HashMap<>();
        if (user == null) {
            result.put("success", false);
            result.put("message", "Chưa đăng nhập");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        long userId = user.getId();
        String action = request.getParameter("action");

        if ("read_all".equalsIgnoreCase(action)) {
            boolean ok = notificationService.markAllAsRead(userId);
            result.put("success", ok);
            result.put("unread", 0);
        } else if ("read".equalsIgnoreCase(action)) {
            String idStr = request.getParameter("id");
            try {
                long notiId = Long.parseLong(idStr.trim());
                boolean ok = notificationService.markAsRead(notiId, userId);
                result.put("success", ok);
                result.put("unread", notificationService.getUnreadCount(userId));
            } catch (Exception e) {
                result.put("success", false);
            }
        } else {
            result.put("success", false);
        }

        response.getWriter().write(gson.toJson(result));
    }
}

