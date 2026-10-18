package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class CustomerAddress implements Serializable {
    private static final long serialVersionUID = 1L;

    private long addressId;
    private long userId;
    private String recipientName;
    private String recipientPhone;
    private String streetAddress;
    private String ward;
    private String district;
    private String city;
    private boolean isDefault;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public CustomerAddress() {
    }

    public CustomerAddress(long addressId, long userId, String recipientName, String recipientPhone,
                           String streetAddress, String ward, String district, String city,
                           boolean isDefault, Timestamp createdAt, Timestamp updatedAt) {
        this.addressId = addressId;
        this.userId = userId;
        this.recipientName = recipientName;
        this.recipientPhone = recipientPhone;
        this.streetAddress = streetAddress;
        this.ward = ward;
        this.district = district;
        this.city = city;
        this.isDefault = isDefault;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public long getAddressId() {
        return addressId;
    }

    public void setAddressId(long addressId) {
        this.addressId = addressId;
    }

    public long getUserId() {
        return userId;
    }

    public void setUserId(long userId) {
        this.userId = userId;
    }

    public String getRecipientName() {
        return recipientName;
    }

    public void setRecipientName(String recipientName) {
        this.recipientName = recipientName;
    }

    public String getRecipientPhone() {
        return recipientPhone;
    }

    public void setRecipientPhone(String recipientPhone) {
        this.recipientPhone = recipientPhone;
    }

    public String getStreetAddress() {
        return streetAddress;
    }

    public void setStreetAddress(String streetAddress) {
        this.streetAddress = streetAddress;
    }

    public String getWard() {
        return ward;
    }

    public void setWard(String ward) {
        this.ward = ward;
    }

    public String getDistrict() {
        return district;
    }

    public void setDistrict(String district) {
        this.district = district;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getFullAddress() {
        StringBuilder address = new StringBuilder();
        appendPart(address, streetAddress);
        appendPart(address, ward);
        appendPart(address, district);
        appendPart(address, city);
        return address.toString();
    }

    private void appendPart(StringBuilder address, String part) {
        if (part == null || part.trim().isEmpty()) {
            return;
        }
        if (address.length() > 0) {
            address.append(", ");
        }
        address.append(part.trim());
    }

    public boolean isDefault() {
        return isDefault;
    }

    public boolean getIsDefault() {
        return isDefault;
    }

    public void setDefault(boolean isDefault) {
        this.isDefault = isDefault;
    }

    public void setIsDefault(boolean isDefault) {
        this.isDefault = isDefault;
    }

    public boolean isDefaultAddress() {
        return isDefault;
    }

    public void setDefaultAddress(boolean defaultAddress) {
        this.isDefault = defaultAddress;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}
