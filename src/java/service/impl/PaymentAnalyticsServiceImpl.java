package service.impl;

import dao.PaymentAnalyticsDAO;
import model.CashflowReport;
import service.IPaymentAnalyticsService;

public class PaymentAnalyticsServiceImpl implements IPaymentAnalyticsService {

    private final PaymentAnalyticsDAO dao = new PaymentAnalyticsDAO();

    @Override
    public CashflowReport getReport(int days) {
        return dao.getReport(days);
    }
}
