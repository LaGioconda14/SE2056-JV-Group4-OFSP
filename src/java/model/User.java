package model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Model entity representing a User in the Online Fruit Shopping Platform.
 */
public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String email;
    private String password;
    private String fullName;
    private String phone;
    private String role;
    private int status;
    private String resetOtp;
    private Timestamp otpExpiryTime;
    private Timestamp createdAt;

    public User() {
    }

    public User(int id, String email, String password, String fullName, String phone, String role, int status) {
        this.id = id;
        this.email = email;
        this.password = password;
        this.fullName = fullName;
        this.phone = phone;
        this.role = role;
        this.status = status;
    }

    public User(int id, String email, String password, String fullName, String phone, String role, int status, 
                String resetOtp, Timestamp otpExpiryTime, Timestamp createdAt) {
        this.id = id;
        this.email = email;
        this.password = password;
        this.fullName = fullName;
        this.phone = phone;
        this.role = role;
        this.status = status;
        this.resetOtp = resetOtp;
        this.otpExpiryTime = otpExpiryTime;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public String getResetOtp() {
        return resetOtp;
    }

    public void setResetOtp(String resetOtp) {
        this.resetOtp = resetOtp;
    }

    public Timestamp getOtpExpiryTime() {
        return otpExpiryTime;
    }

    public void setOtpExpiryTime(Timestamp otpExpiryTime) {
        this.otpExpiryTime = otpExpiryTime;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public boolean isActive() {
        return this.status == 1;
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", email='" + email + '\'' +
                ", fullName='" + fullName + '\'' +
                ", phone='" + phone + '\'' +
                ", role='" + role + '\'' +
                ", status=" + status +
                '}';
    }
}

