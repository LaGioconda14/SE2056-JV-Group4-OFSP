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
    private String avatarUrl;
    private String role;
    private int status;
    private String gender;
    private java.sql.Date birthDate;
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

    public User(int id, String email, String password, String fullName, String phone, String role, int status, Timestamp createdAt) {
        this.id = id;
        this.email = email;
        this.password = password;
        this.fullName = fullName;
        this.phone = phone;
        this.role = role;
        this.status = status;
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

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public java.sql.Date getBirthDate() {
        return birthDate;
    }

    public void setBirthDate(java.sql.Date birthDate) {
        this.birthDate = birthDate;
    }

    public String getMaskedEmail() {
        if (email == null || email.isEmpty()) return "Chưa cập nhật";
        int atIndex = email.indexOf('@');
        if (atIndex <= 1) return email;
        String name = email.substring(0, atIndex);
        String domain = email.substring(atIndex);
        if (name.length() <= 3) {
            return name.charAt(0) + "****" + domain;
        }
        return name.substring(0, 3) + "****" + domain;
    }

    public String getMaskedPhone() {
        if (phone == null || phone.isEmpty()) return "Chưa cập nhật";
        String clean = phone.trim();
        if (clean.length() <= 4) return clean;
        if (clean.length() >= 9) {
            return clean.substring(0, 3) + "****" + clean.substring(clean.length() - 3);
        }
        return clean.substring(0, 2) + "****" + clean.substring(clean.length() - 2);
    }

    public String getMaskedBirthDate() {
        if (birthDate == null) return "Chưa cập nhật";
        String s = birthDate.toString(); // YYYY-MM-DD
        String[] parts = s.split("-");
        if (parts.length == 3) {
            return "**/**/" + parts[0];
        }
        return "**/**/****";
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

