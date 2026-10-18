package service.impl;

import dao.DisputeDAO;
import java.util.List;
import model.Dispute;
import service.IDisputeService;

public class DisputeServiceImpl implements IDisputeService {

    private final DisputeDAO disputeDAO = new DisputeDAO();

    @Override
    public boolean createDispute(Dispute dispute) {
        return disputeDAO.createDispute(dispute);
    }

    @Override
    public Dispute getDisputeBySubOrderId(long subOrderId) {
        return disputeDAO.getDisputeBySubOrderId(subOrderId);
    }

    @Override
    public Dispute getDisputeByCode(String disputeCode) {
        return disputeDAO.getDisputeByCode(disputeCode);
    }

    @Override
    public List<Dispute> getDisputesByCustomerId(long customerId) {
        return disputeDAO.getDisputesByCustomerId(customerId);
    }
}

