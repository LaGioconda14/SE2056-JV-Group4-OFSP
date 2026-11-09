package service;

import model.dto.admin.AdminDashboardStats;

/**
 * Service interface for Admin Dashboard business logic.
 */
public interface IAdminDashboardService {

    /**
     * Retrieve aggregated platform dashboard statistics.
     *
     * @return AdminDashboardStats populated with real-time database data.
     */
    AdminDashboardStats getDashboardStats();
}
