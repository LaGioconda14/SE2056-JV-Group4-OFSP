package controller.cart;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;
import java.util.logging.Logger;
import model.User;
import service.CartVoucherService;

@WebServlet(name = "CartVouchersServlet", urlPatterns = {"/cart/vouchers"})
public class CartVouchersServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Gson GSON = new GsonBuilder().serializeNulls().create();
    private static final Logger LOGGER = Logger.getLogger(CartVouchersServlet.class.getName());
    private transient CartVoucherService voucherService;

    public CartVouchersServlet() {
        this(new CartVoucherService());
    }

    CartVouchersServlet(CartVoucherService voucherService) {
        this.voucherService = voucherService;
    }

    @Override
    public void init() {
        if (voucherService == null) {
            voucherService = new CartVoucherService();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store");
        HttpSession session = request.getSession(false);
        Object sessionUser = session == null ? null : session.getAttribute("user");
        User user = sessionUser instanceof User ? (User) sessionUser : null;
        if (user == null || user.getId() <= 0 || !user.isActive()) {
            writeError(response, HttpServletResponse.SC_UNAUTHORIZED, "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại!");
            return;
        }
        String json;
        try {
            json = GSON.toJson(Map.of("vouchers", voucherService.findVouchers(user.getId(),
                    request.getParameterValues("itemId"), request.getParameterValues("quantity"))));
        } catch (IllegalArgumentException ex) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, "Sản phẩm hoặc số lượng trong giỏ hàng không hợp lệ!");
            return;
        } catch (SQLException | RuntimeException ex) {
            LOGGER.severe("Cart voucher lookup failed");
            writeError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không thể tải mã giảm giá. Vui lòng thử lại sau!");
            return;
        }
        response.getWriter().write(json);
    }

    private void writeError(HttpServletResponse response, int status, String message) throws IOException {
        response.setStatus(status);
        response.getWriter().write(GSON.toJson(Map.of("error", message)));
    }
}
