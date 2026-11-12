package controller.loyalty;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.entity.user.User;
import service.ILoyaltyService;
import service.impl.LoyaltyServiceImpl;

/** Quyền lợi các hạng thành viên (FE-14). Khách chưa đăng nhập vẫn xem được, chỉ không có dòng "hạng của bạn". */
@WebServlet(name = "LoyaltyBenefitsServlet", urlPatterns = {"/loyalty/benefits"})
public class LoyaltyBenefitsServlet extends HttpServlet {

    private final ILoyaltyService loyaltyService = new LoyaltyServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user != null) {
            request.setAttribute("account", loyaltyService.getAccount(user.getId()));
        }
        request.setAttribute("tiers", loyaltyService.listTiers(true, null));
        request.setAttribute("settings", loyaltyService.getSettings());
        request.getRequestDispatcher("/views/loyalty/loyalty-benefits.jsp").forward(request, response);
    }
}
