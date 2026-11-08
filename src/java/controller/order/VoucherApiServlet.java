package controller.order;

import com.google.gson.Gson;
import dao.VoucherDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import model.VoucherCheckResult;

@WebServlet(name = "VoucherApiServlet", urlPatterns = {"/voucher/validate"})
public class VoucherApiServlet extends HttpServlet {

    private final VoucherDAO voucherDAO = new VoucherDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession(false);
        Object u = session != null ? session.getAttribute("user") : null;
        if (!(u instanceof User)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write(gson.toJson(error("Vui lòng đăng nhập để dùng voucher.")));
            return;
        }
        User user = (User) u;

        try {
            long shopId = Long.parseLong(request.getParameter("shopId"));
            BigDecimal subtotal = new BigDecimal(request.getParameter("subtotal"));
            Map<Long, BigDecimal> lines = parseItems(request.getParameter("items"));

            VoucherCheckResult r = voucherDAO.validate(request.getParameter("code"), shopId, user.getId(), subtotal, lines);

            Map<String, Object> out = new LinkedHashMap<>();
            out.put("valid", r.isValid());
            out.put("message", r.getMessage());
            if (r.isValid()) {
                out.put("couponId", r.getCouponId());
                out.put("code", r.getCode());
                out.put("title", r.getTitle());
                out.put("discountType", r.getDiscountType());
                out.put("discount", r.getDiscount());
            }
            response.getWriter().write(gson.toJson(out));
        } catch (NumberFormatException | NullPointerException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write(gson.toJson(error("Dữ liệu gửi lên không hợp lệ.")));
        }
    }

    private static Map<Long, BigDecimal> parseItems(String items) {
        if (items == null || items.trim().isEmpty()) {
            return null;
        }
        Map<Long, BigDecimal> map = new HashMap<>();
        for (String part : items.split(",")) {
            String[] kv = part.split(":");
            if (kv.length == 2) {
                try {
                    Long pid = Long.valueOf(kv[0].trim());
                    BigDecimal amount = new BigDecimal(kv[1].trim());
                    map.merge(pid, amount, BigDecimal::add);
                } catch (NumberFormatException ignored) {
                }
            }
        }
        return map;
    }

    private static Map<String, Object> error(String msg) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("valid", false);
        m.put("message", msg);
        return m;
    }
}
