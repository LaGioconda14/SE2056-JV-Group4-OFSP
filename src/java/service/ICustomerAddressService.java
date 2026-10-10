package service;

import java.util.List;
import model.CustomerAddress;

public interface ICustomerAddressService {

    List<CustomerAddress> getAddressesByUserId(long userId);

    CustomerAddress getAddressById(long addressId, long userId);

    int countAddresses(long userId);

    boolean addAddress(CustomerAddress address);

    boolean setDefaultAddress(long addressId, long userId);

    boolean deleteAddress(long addressId, long userId);
}
