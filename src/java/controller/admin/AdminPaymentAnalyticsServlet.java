package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import model.CashflowReport;
import service.IPaymentAnalyticsService;
import service.impl.PaymentAnalyticsServiceImpl;
import util.AdminGuard;

/**
 * Báo cáo phân tích thanh toán & dòng tiền: tỉ lệ COD vs Online, tỉ lệ giao dịch lỗi,
 * doanh thu tiền mặt vs tiền điện tử theo ngày. Mỗi lần mở / làm mới trang là một lần truy vấn mới.
 */
@WebServlet(name = "AdminPaymentAnalyticsServlet", urlPatterns = {"/admin/payment-analytics"})
public class AdminPaymentAnalyticsServlet extends HttpServlet {

    private static final List<Integer> RANGES = Arrays.asList(7, 30, 90, 365, 0);

    private final IPaymentAnalyticsService analyticsService = new PaymentAnalyticsServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (AdminGuard.requireAdmin(request, response) == null) {
            return;
        }
        int days;
        try {
            days = Integer.parseInt(request.getParameter("days"));
        } catch (NumberFormatException ex) {
            days = 30;
        }
        if (!RANGES.contains(days)) {
            days = 30;
        }

        CashflowReport report = analyticsService.getReport(days);
        request.setAttribute("report", report);
        request.setAttribute("days", days);

        // Dữ liệu cho Chart.js (chuỗi JSON dựng thủ công từ dữ liệu số / ngày do hệ thống sinh ra).
        StringBuilder labels = new StringBuilder("[");
        StringBuilder cash = new StringBuilder("[");
        StringBuilder electronic = new StringBuilder("[");
        boolean first = true;
        for (Map<String, Object> d : report.getDaily()) {
            if (!first) {
                labels.append(',');
                cash.append(',');
                electronic.append(',');
            }
            first = false;
            labels.append('"').append(d.get("date")).append('"');
            cash.append(d.get("cash"));
            electronic.append(d.get("electronic"));
        }
        request.setAttribute("chartLabels", labels.append(']').toString());
        request.setAttribute("chartCash", cash.append(']').toString());
        request.setAttribute("chartElectronic", electronic.append(']').toString());
        request.getRequestDispatcher("/views/admin/payment-analytics.jsp").forward(request, response);
    }
}
