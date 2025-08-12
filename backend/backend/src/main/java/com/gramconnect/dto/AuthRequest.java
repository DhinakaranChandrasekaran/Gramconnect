package com.gramconnect.dto;

import jakarta.validation.constraints.NotBlank;

public class AuthRequest {

    private String email;
    private String phoneNumber;

    @NotBlank(message = "Password is required")
    private String password;

    private String fullName;

    private String district;
    private String panchayat;
    private String ward;
    private String homeAddress;
    private String aadhaarNumber;
    private boolean aadhaarVerified;

    private AuthType authType;

    public enum AuthType {
        PASSWORD,
        EMAIL_OTP,
        PHONE_OTP,
        GMAIL_OAUTH
    }

    // Default Constructor
    public AuthRequest() {}

    // Getters and Setters
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

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
}
