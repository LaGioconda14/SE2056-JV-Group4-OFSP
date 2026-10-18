package service;

import java.util.List;
import model.Dispute;

public interface IDisputeService {

    boolean createDispute(Dispute dispute);

    Dispute getDisputeBySubOrderId(long subOrderId);

    Dispute getDisputeByCode(String disputeCode);

    List<Dispute> getDisputesByCustomerId(long customerId);
}

