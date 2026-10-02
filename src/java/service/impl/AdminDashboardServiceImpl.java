package service.impl;

import dao.AdminDashboardDAO;
import model.AdminDashboardStats;
import service.IAdminDashboardService;

/**
 * Implementation of IAdminDashboardService.
 */
public class AdminDashboardServiceImpl implements IAdminDashboardService {

    private final AdminDashboardDAO adminDashboardDAO;

    public AdminDashboardServiceImpl() {
        this.adminDashboardDAO = new AdminDashboardDAO();
    }

    public AdminDashboardServiceImpl(AdminDashboardDAO adminDashboardDAO) {
        this.adminDashboardDAO = adminDashboardDAO;
    }

    @Override
    public AdminDashboardStats getDashboardStats() {
        return adminDashboardDAO.getDashboardStats();
    }
}
