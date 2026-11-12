package controller.loyalty;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.LoyaltyAccount;
import model.entity.user.User;
import service.ILoyaltyService;
import service.impl.LoyaltyServiceImpl;

/**
 * Điểm thưởng của tôi (FE-14): số dư điểm, giá trị quy đổi, hạng thành viên hiện tại và tiến độ lên hạng.
 */
@WebServlet(name = "LoyaltyServlet", urlPatterns = {"/loyalty"})
public class LoyaltyServlet extends HttpServlet {

    private final ILoyaltyService loyaltyService = new LoyaltyServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập để xem điểm thưởng!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        LoyaltyAccount account = loyaltyService.getAccount(user.getId());
        request.setAttribute("account", account);
        request.setAttribute("settings", loyaltyService.getSettings());
        request.setAttribute("tiers", loyaltyService.listTiers(true, null));
        request.getRequestDispatcher("/views/loyalty/loyalty.jsp").forward(request, response);
    }
}
