package model.entity.user;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;

/**
 * Database Entity ánh xạ bảng [dbo].[users].
 * Đại diện cho tài khoản người dùng trên hệ thống OFSP.
 */
public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    // =========================================================================
    // 1. DATABASE ENTITY FIELDS (Khớp bảng [dbo].[users])
    // =========================================================================
    private int id;
    private String email;
    private String phone;
    private String password;      // password_hash
    private String fullName;
    private String avatarUrl;
    private String gender;
    private Date birthDate;
    private int status;           // Trạng thái dạng số (1 = ACTIVE, 0 = INACTIVE)
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // =========================================================================
    // 2. JOINED / BRIDGE FIELDS (Phục vụ phân quyền & tương thích kiểu dữ liệu)
    // =========================================================================
    private String role;          // Tên vai trò từ bảng roles (CUSTOMER, SHOP_OWNER, DRIVER, ADMIN)
    private String statusName = "ACTIVE";

    public User() {
    }

    // -------------------------------------------------------------------------
    // Getters & Setters
    // -------------------------------------------------------------------------
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    /** Alias trả về long khớp kiểu BIGINT của user_id trong Database. */
    public long getUserId() {
        return id;
    }

    public void setUserId(long userId) {
        this.id = (int) userId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
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

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public Date getBirthDate() {
        return birthDate;
    }

    public void setBirthDate(Date birthDate) {
        this.birthDate = birthDate;
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

    public boolean isActive() {
        return this.status == 1;
    }

    public String getStatusName() {
        return statusName != null ? statusName : (status == 1 ? "ACTIVE" : "INACTIVE");
    }

    public void setStatusName(String statusName) {
        this.statusName = statusName;
        this.status = "ACTIVE".equalsIgnoreCase(statusName) ? 1 : 0;
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
