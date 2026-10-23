package service;

import model.CashflowReport;

public interface IPaymentAnalyticsService {

    /** @param days số ngày gần nhất, 0 = toàn bộ thời gian */
    CashflowReport getReport(int days);
}
