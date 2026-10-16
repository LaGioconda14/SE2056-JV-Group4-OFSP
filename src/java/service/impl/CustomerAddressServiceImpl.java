package service.impl;

import dao.CustomerAddressDAO;
import java.util.List;
import model.CustomerAddress;
import service.ICustomerAddressService;

public class CustomerAddressServiceImpl implements ICustomerAddressService {

    private final CustomerAddressDAO addressDAO;

    public CustomerAddressServiceImpl() {
        this.addressDAO = new CustomerAddressDAO();
    }

    public CustomerAddressServiceImpl(CustomerAddressDAO addressDAO) {
        this.addressDAO = addressDAO;
    }

    @Override
    public List<CustomerAddress> getAddressesByUserId(long userId) {
        return addressDAO.getAddressesByUserId(userId);
    }

    @Override
    public CustomerAddress getAddressById(long addressId, long userId) {
        return addressDAO.getAddressById(addressId, userId);
    }

    @Override
    public int countAddresses(long userId) {
        return addressDAO.countAddresses(userId);
    }

    @Override
    public boolean addAddress(CustomerAddress address) {
        if (address == null) {
            throw new IllegalArgumentException("Thông tin địa chỉ không được để trống!");
        }

        if (address.getRecipientName() == null || address.getRecipientName().trim().isEmpty()) {
            throw new IllegalArgumentException("Họ và tên người nhận không được để trống!");
        }

        if (address.getRecipientPhone() == null || address.getRecipientPhone().trim().isEmpty()) {
            throw new IllegalArgumentException("Số điện thoại nhận hàng không được để trống!");
        }

        String phoneClean = address.getRecipientPhone().replaceAll("\\s+", "");
        if (!phoneClean.matches("^0\\d{9,10}$")) {
            throw new IllegalArgumentException("Số điện thoại nhận hàng không hợp lệ (cần 10 hoặc 11 chữ số, bắt đầu bằng 0)!");
        }
        address.setRecipientPhone(phoneClean);

        if (address.getStreetAddress() == null || address.getStreetAddress().trim().isEmpty()) {
            throw new IllegalArgumentException("Địa chỉ cụ thể không được để trống!");
        }

        if (address.getCity() == null || address.getCity().trim().isEmpty()) {
            throw new IllegalArgumentException("Tỉnh/Thành phố không được để trống!");
        }

        return addressDAO.addAddress(address);
    }

    @Override
    public boolean setDefaultAddress(long addressId, long userId) {
        return addressDAO.setDefaultAddress(addressId, userId);
    }

    @Override
    public boolean deleteAddress(long addressId, long userId) {
        return addressDAO.deleteAddress(addressId, userId);
    }
}
