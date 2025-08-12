package com.gramconnect.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.index.Indexed;

import java.time.LocalDateTime;

@Document(collection = "users")
public class User {
    @Id
    private String id;
    
    private String fullName;
    
    @Indexed(unique = true)
    private String email;
    
    @Indexed(unique = true)
    private String phoneNumber;
    
    private String password;
    
    private String district;
    
    private String panchayat;
    
    private String ward;
    
    private String homeAddress;
    
    private String aadhaarNumber;
    
    private boolean aadhaarVerified = false;
    
    private AuthType authType;
    
    private boolean isActive = true;
    
    private boolean profileCompleted = false;
    
    @CreatedDate
    private LocalDateTime createdAt;
    
    @LastModifiedDate
    private LocalDateTime updatedAt;

    public enum AuthType {
        PASSWORD, EMAIL_OTP, PHONE_OTP, GMAIL_OAUTH
    }

    // Constructors
    public User() {}

    public User(String fullName, String email, String phoneNumber, String district, String panchayat, String ward) {
        this.fullName = fullName;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.district = district;
        this.panchayat = panchayat;
        this.ward = ward;
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }

    public String getPanchayat() { return panchayat; }
    public void setPanchayat(String panchayat) { this.panchayat = panchayat; }

    public String getWard() { return ward; }
    public void setWard(String ward) { this.ward = ward; }

    public String getHomeAddress() { return homeAddress; }
    public void setHomeAddress(String homeAddress) { this.homeAddress = homeAddress; }

    public String getAadhaarNumber() { return aadhaarNumber; }
    public void setAadhaarNumber(String aadhaarNumber) { this.aadhaarNumber = aadhaarNumber; }

    public boolean isAadhaarVerified() { return aadhaarVerified; }
    public void setAadhaarVerified(boolean aadhaarVerified) { this.aadhaarVerified = aadhaarVerified; }

    public AuthType getAuthType() { return authType; }
    public void setAuthType(AuthType authType) { this.authType = authType; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public boolean isProfileCompleted() { return profileCompleted; }
    public void setProfileCompleted(boolean profileCompleted) { this.profileCompleted = profileCompleted; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}